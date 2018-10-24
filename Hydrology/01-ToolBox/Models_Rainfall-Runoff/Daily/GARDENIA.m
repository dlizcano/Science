function [Qs,varargout] = GARDENIA(x,data,states)
%
% GARDENIA
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
% inter = GARDENIA's internal values
% param -->
% .x(1) = capacité du réservoir de surface
% .x(2) = constante de percolations linéaires
% .x(3) = paramètre de vidange latérale du réservoir sol
% .x(4) = constante de vidange linéaire du réservoir souterrain
% .x(5) = coefficient de correction des ETP
% .x(6) = délai
%
% .S = Réservoir de surface (mm)
% .R = Réservoir de sol (mm)
% .T = Réservoir souterrain (mm)
%
% FOLLOWING
% Thiery (1982)
% Bureau de Recherches Géologiques et Minières (BRGM, ), Orléans (FR)
%
%
% Program : G. Seiller (U. Laval, 2010)

param.x = x ;

if nargin < 3
    param.S = 100;
    param.R = 10;
    param.T = 50;
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

% Apply GARDENIA
%
lP = length( P ) ;
Qs = zeros(lP+x(6),1);
inter = zeros( lP+x(6),8);

for i = 1 : lP
    [Qs(i+x(6)),param,inter(i+x(6),:)] = GARDENIAonestep( P(i), E(i), param, Qb(i) ) ;
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


function [Q,param,inter] = GARDENIAonestep( P, E, param, Qb ) % Introduce Flowbase
% [Q,param,inter] = GARDENIAonestep( P, E, param )
%
% The GARDENIA model as such.
%

% Get parameters
%
x = param.x ;
S = param.S ;
R = param.R ;
T = param.T ;

%%%
%%% PRODUCTION PART
%%%

% Surface storage (S)
%
S = S+P;
Pr = max(0,S-x(1));
S = S-Pr;
Es = x(5)*E;
S = max(0,S-Es);

%%%
%%% ROUTING
%%%

% Soil storage (R)
%
R = R+Pr;
Qr = (R^2)/(R+x(2)*x(3));
R = R-Qr;
Ir = R/x(2);
R = R-Ir;

% Groundwater storage (T)
%
T = T+Ir;
Qt = T/x(4);
T = T-Qt;

% Total discharge
%
Q = Qt + Qr + Qb;

% Data

param.S = S;
param.R = R;
param.T = T;

inter = [ S R T Es Pr Ir Qr Qt ];
end
