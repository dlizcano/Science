function [Qs,varargout] = TANK(x,data,states)
%
% TANK
%
% Modified version : 7 parameters
% Structure similaire aux premières versions de Tank.
% Même seuil de vidange pour les trois premiers réservoirs.
% Même constante de vidange pour toutes les sorties du premier réservoir.
% On ajoute un délai en sortie.
% On introduit un coefficient correctif d’ETP.
%
%
% INPUTS (time series of daily observations [n,1])
% P = mean areal rainfall (mm)
% E = mean areal evapotranspiration (mm)
% Q = stream flow (mm)
% x = the seven model parameters (see "param" below) - [7,1]
%
% OUTPUTS
% Qs = simulated stream flow (mm)
% perf = model performances
% inter = TANK's internal values
% param -->
% .x(1) = seuil supérieur d’écoulement du premier réservoir
% .x(2) = seuil inférieur d’écoulement
% .x(3) = constante de vidange du premier réservoir
% .x(4) = constante de vidange du deuxième réservoir
% .x(5) = délai
% .x(6) = coefficient de correction de l’ETP
% .x(7) = constante de vidange du troisième réservoir
%
% .S = Réservoir de surface (mm)
% .R = Réservoir sol supérieur (mm)
% .T = Réservoir sol inférieur (mm)
% .L = Réservoir souterrain (mm)
%
% FOLLOWING
% Sugawara (1979)
% National Research Centre for Disaster Prevention, Tokyo, Japon
%
%
% Program : G. Seiller (U. Laval, 2010)

param.x = x ;

if nargin < 3
    param.S = 30;
    param.R = 50;
    param.T = 50;
    param.L = 100;
else
    param.S = states.S;
    param.R = states.R;
    param.T = states.T;
    param.L = states.L;
end

if size(data,2) ~= 3 % 3 column is Qb
    error('wrong data inputs')
end

P = data(:,1); E = data(:,2); Qb = data(:,3);

x(5) = round(x(5));

% Apply TANK for all time steps
%
lP = length( P ) ;
Qs = zeros(lP+x(5),1);
inter = zeros( lP+x(5),12);

for i = 1 : lP
    [Qs(i+x(5)),param,inter(i+x(5),:)] = TANKonestep( P(i), E(i), param, Qb(i) ) ;
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


function [Q,param,inter] = TANKonestep( P, E, param, Qb ) % Introduce Flowbase
% [Q,param,inter] = TANKonestep( P, E, param )
%
% The TANK model as such.
%

% Get parameters
%
x = param.x ;
S = param.S ;
R = param.R ;
T = param.T ;
L = param.L ;

% Surface storage (S)
%
S = S+P;
E1 = E*x(6);
Qs1 = max(0,(S-(x(1)+x(2)))/x(3));
S = S-Qs1;
Qs2 = max(0,(S-x(2))/x(3));
S = S-Qs2;
Is = S/x(3);
S = S-Is;
Es = min(E1,S);
S = S-Es;
E2 = E1-Es;

% Upper soil storage (R)
%
R = R+Is;
Qr = max(0,(R-x(2))/(x(3)*x(4)));
R = R-Qr;
Ir = R/(x(3)*x(4));
R = R-Ir;
Er = min(E2,R);
R = R-Er;
E3 = E2-Er;

% Lower soil storage (T)
%
T = T+Ir;
Qt = max(0,(T-x(2))/(x(3)*x(4)*x(7)));
T = T-Qt;
It = T/(x(3)*x(4)*x(7));
T = T-It;
Et = min(E3,T);
T = T-Et;
E4 = E3-Et;

% Groundwater storage (L)
%
L = L+It;
Ql = L/(x(3)*x(4)*(x(7)^2)); % x(7)^2 sur graph et que x(7) sur formules
L = L-Ql;
El = min(E4,L);
L = L-El;

% Total discharge
%
Q = Qs1 + Qs2 + Qr + Qt + Ql + Qb;

% Data
param.S = S;
param.R = R;
param.T = T;
param.L = L;

inter = [ S R T L Is Ir It Qs1 Qs2 Qr Qt Ql ];
end
