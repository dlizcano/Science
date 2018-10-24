function [Qs,varargout] = XINANJIANG(x,data,states)
%
% XINANJIANG
%
% Modified version : only 8 parameters
% No impervious land
% B parameter = 0.25
%
%
% INPUTS (time series of daily observations [n,1])
% P = mean areal rainfall (mm)
% E = mean areal evapotranspiration (mm)
% Q = stream flow (mm)
% x = the ten model parameters (see "param" below) - [8,1]
%
% OUTPUTS
% Qs = simulated stream flow (mm)
% perf = model performances
% inter = XINANJIANG's internal values
% param -->
% .x(1) = Coefficient de partage des écoulements
% .x(2) = Coefficient de vidange du réservoir de la composante rapide
% .x(3) = Coefficient de vidange du réservoir de la composante lente
% .x(4) = Capacité du réservoir eau-sol
% .x(5) = Capacité du réservoir sol
% .x(6) = Délai
% .x(7) = Coefficient de vidange du réservoir eau liée
% .x(8) = Exposant du réservoir eau libre (param ex)
%
% .S = Réservoir sol (mm)
% .R = Réservoir eau-sol (mm)
% .T = Réservoir de routage rapide (mm)
% .M = Réservoir de routage lent (mm)
%
% FOLLOWING
% Zhao et al. (1980), Zhao and Liu (1995)
% 
%
% Program : G. Seiller (U. Laval, 2010)

param.x = x ;

if nargin < 3
    param.S = 150;
    param.R = 5;
    param.T = 5;
    param.M = 20;
else
    param.S = states.S;
    param.R = states.R;
    param.T = states.T;
    param.M = states.M;
end

if size(data,2) ~= 3 % 3 column is Qb
    error('wrong data inputs')
end

P = data(:,1); E = data(:,2); Qb = data(:,3);

x(6) = round(x(6));

% Apply XINANJIANG for all time steps
%
lP = length( P ) ;
Qs = zeros(lP+x(6),1);
inter = zeros( lP+x(6),10);

for i = 1 : lP
    [Qs(i+x(6)),param,inter(i+x(6),:)] = XINANJIANGonestep( P(i), E(i), param, Qb(i) ) ;
end

% Others outputs
nout = max(nargout,1)-1;
if nout == 2
    varargout(1) = {inter};
    varargout(2) = {param};
elseif nout == 1
    varargout(1) = {inter};
end
end


function [Q,param,inter] = XINANJIANGonestep( P, E, param, Qb ) % Introduce Flowbase
% [Q,param,inter] = XINANJIANGonestep( P, E, param )
%
% The XINANJIANG model as such.
%

% get parameters
%
x = param.x ;
S = param.S ;
R = param.R ;
T = param.T ;
M = param.M ;
XF1 = 1/4;

%%% PRODUCTION PART

% Net inputs
%
Pn = max(0,P-E);
En = max(0,E-P);

% If Evaporation
%
if En > 0
    if S/x(5) >= 0.9
        Es = min(S,En);
    elseif S/x(5) < 0.09
        Es = min(S,En*0.1);
    else
        Es = min(S,(En*S)/(0.9*x(5)));
    end
    S=S-Es;
    Qs0 = 0;
    Ir = 0;
else
    En = 0;
    Ir = 0;
end

% If Net rainfall
%
if Pn > 0
    Fs = ( ( max(0,1-(S/x(5))) )^(1/(1+XF1)) )-(Pn/((1+XF1)*x(5)));
    Fs = (max(Fs,0))^(1+XF1);
    Ps = max(0,x(5)-S-Fs*x(5));
    S = min(x(5),S+Ps);
    Pr = max(0,Pn-Ps);
    Fr = ( (max(0,1-(R/x(4))))^(1/(1+x(8))) )-(Pr/((1+x(8))*x(4)));
    Fr = (max(Fr,0))^(1+x(8));
    Pr2 = max(0,x(4)-R-Fr*x(4));
    R = min(x(4),R+Pr2);
    Qs0 = max(0,Pr-Pr2);
    Ir = R/x(7);
else
    Pn = 0;
    Ir = 0;
    Pr = 0;
    Ps = 0;
    Qs0 = 0;
end

%%% UPDATE and ROUTING
%
R = R-Ir;
T = T+Ir*x(1);
Qt = T/x(2);
T = T-Qt;
M = M+Ir*(1-x(1));
Qm = M/(x(2)*x(3));
M = M-Qm;

% Total discharge
Q = Qs0 + Qm + Qt + Qb;

% Data
param.S = S;
param.R = R;
param.T = T;
param.M = M;

inter = [ S R T M Pn Pr Ps Qs0 Qt Qm ];
end
