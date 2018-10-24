function [Qs,varargout] = BUCKET(x,data,states)
%
% BUCKET (6 parameters)
% Ajout d'un réservoir de routage linéaire destiné à router une partie des débordements et la partie de la pluie ne transitant pas par le réservoir de production.
% Le partage des débordements est réalisé par un coefficient de partage.
% On rajoute également un délai.
% 
%
% INPUTS (time series of daily observations [n,1])
% P       = mean areal rainfall (mm)
% E       = mean areal evapotranspiration (mm)
% Q       = stream flow (mm)
% x       = the six model parameters (see "param" below) - [6,1]
%
% OUTPUTS
% Qs      = simulated stream flow (mm)
% perf    = model performances
% inter   = BUCKET's internal values
% param -->
%   .x(1) = capacité du réservoir sol
%   .x(2) = constante de dissociation du débordement du réservoir sol
%   .x(3) = constante de vidange du réservoir de routage (R)
%   .x(4) = délai
%   .x(5) = coefficient de partition de la pluie
%   .x(6) = constante de vidange du réservoir de routage (R,T)
%   .S    = Réservoir de sol
%   .R    = Réservoir de routage linéaire
%   .T    = Réservoir de routage direct
%
% FOLLOWING
% Thornthwaite et Mather (1955)
% Climatology Drexel Institute of Technology, Etats-Unis
%
% Program : G. Seiller (U. Laval, 2010)

param.x = x ;

if nargin < 3
    param.S = 150;
    param.R = 50;
    param.T = 5;
else
    param.S = states.S;
    param.R = states.R;
    param.T = states.T;
end

if size(data,2) ~= 3 % 3 column is Qb
    error('wrong data inputs')
end

P = data(:,1); E = data(:,2); Qb = data(:,3);

x(4) = round(x(4));

% Apply BUCKET for all time steps
%
lP    = length( P ) ;
Qs    = zeros( lP+x(4),1 ) ;
inter = zeros( lP+x(4),8 ) ;

for i = 1 : lP
    [Qs(i+x(4)),param,inter(i+x(4),:)] = BUCKETonestep( P(i), E(i), param, Qb(i) ) ;
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


function [Q,param,inter] = BUCKETonestep( P, E, param, Qb ) % Introduce Flowbase
%        [Q,param,inter] = BUCKETonestep( P, E, param )
%
% The BUCKET model as such.
%

% get parameters
%
x   = param.x ;
S   = param.S ;
R   = param.R ;
T   = param.T ;

%%%
%%% PRODUCTION PART
%%%

% Soil moisture accounting (S)
%
Ps = (1-x(5))*P;
Pr = P-Ps;

if Ps >= E
    S = S+Ps-E;
    Is = max(0,S-x(1));
    S = S-Is;
else
    S = S*exp((Ps-E)/x(1));
    Is = 0;
end

%%%
%%% ROUTING PART
%%%

% Slow routing (R)
%
R = R+Is*(1-x(2));
Qr = R/(x(3)*x(6));
R = R-Qr;

% Fast routing (T)
%
T = T+Pr+Is*x(2);
Qt = T/x(6);
T = T-Qt;

% Calcul du débit total
%
Q = Qt + Qr + Qb;

% Data
param.S  = S ;
param.R  = R ;
param.T  = T ;

inter = [ S R T Ps Pr Is Qr Qt ];
end