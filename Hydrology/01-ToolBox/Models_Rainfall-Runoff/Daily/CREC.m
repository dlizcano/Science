function [Qs,varargout] = CREC(x,data,states)
%
% CREC (Centre de Recherches et d'études de Chatou)
%
% Modified version : 6 parameters
%
%
% INPUTS (time series of daily observations [n,1])
% P = mean areal rainfall (mm)
% E = mean areal evapotranspiration (mm)
% Q = stream flow (mm)
% x = the six model parameters (see "param" below) - [6,1]
%
% OUTPUTS
% Qs = simulated stream flow (mm)
% perf = model performances
% inter = CREC's internal values
% param -->
% .x(1) = constante de vidange du réservoir sol
% .x(2) = paramètre de vidange linéaire du réservoir souterrain
% .x(3) = paramètre de séparation de la pluie brute
% .x(4) = paramètre de séparation de la pluie brute et de rendement d'ETP
% .x(5) = paramètre de percolation linéaire du réservoir sol
% .x(6) = délai
%
% .S = Réservoir de sol (mm)
% .R = Réservoir de surface (mm)
% .T = Réservoir souterrain (mm)
%
% FOLLOWING
% Cormary et Guilbot (1973)
% Laboratoire d’Hydrologie Mathématique, Université des Sciences, Montp.
%
% Program : G. Seiller (U. Laval, 2010)

param.x = x ;

if nargin < 3
    param.S = 300;
    param.R = 10;
    param.T = 30;
else
    param.S = states.S;
    param.R = states.R;
    param.T = states.T;
end

if size(data,2) ~= 3 % 3 column is Qb
    error('wrong data inputs')
end

P = data(:,1); E = data(:,2); Qb = data(:,3);

x(6) = round(x(6));

% Initialization of the reservoir states
%
param.XF = 245;

% Apply CREC for all time steps
%
lP = length( P ) ;
Qs = zeros( lP+x(6),1 );
inter = zeros( lP+x(6),9 );

for i = 1 : lP
    [Qs(i+x(6)),param,inter(i+x(6),:)] = CREConestep( P(i), E(i), param, Qb(i) ) ;
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


function [Q,param,inter] = CREConestep( P, E, param, Qb ) % Introduce Flowbase
% [Q,param,inter] = CREConestep( P, E, param )
%
% The CREC model as such.
%

% Get parameters
%
x = param.x ;
S = param.S ;
R = param.R ;
T = param.T ;
XF = param.XF;

%%%
%%% PRODUCTION PART
%%%

% Net inputs
%
Pr = P/(1+exp((x(3)-S)/x(4)));
Ps = P-Pr;

% Soil storage (S)
%
S = S+Ps;
Es = E*(1-exp(-(S/XF)));
S = max(0,S-Es);

%%%
%%% ROUTING
%%%

% Surface storage (R)
%
R = R+Pr;
Qr = (R^2)/(R+x(1));
R = R-Qr;
Ir = R/x(5);
R = R-Ir;

% Groundwater storage (T)
%
T = T+Ir;
Qt = T/x(2);
T = T-Qt;

% Total discharge
%
Q = Qr + Qt + Qb;

% Data

param.S = S;
param.R = R;
param.T = T;

inter = [ S R T Ps Pr Es Ir Qr Qt];
end
