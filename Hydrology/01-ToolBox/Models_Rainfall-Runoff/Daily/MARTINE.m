function [Qs,varargout] = MARTINE(x,data,states)
%
% MARTINE (7 parameters)
% Modified version :
% On ne garde que le réservoir quadratique pour le routage de la composante rapide de l’écoulement.
% Toutes les sorties du réservoir intermédiaire transitent par le réservoir souterrain.
% On ajoute un délai en sortie.
%
% INPUTS (time series of daily observations [n,1])
% P       = mean areal rainfall (mm)
% E       = mean areal evapotranspiration (mm)
% Q       = stream flow (mm)
% x       = the seven model parameters (see "param" below) - [7,1]
%
% OUTPUTS
% Qs      = simulated stream flow (mm)
% perf    = model performances
% inter   = MARTINE's internal values
% param -->
%   .x(1) = capacité du réservoir superficiel
%   .x(2) = capacité du réservoir intermédiaire
%   .x(3) = capacité du réservoir de routage quadratique
%   .x(4) = constante de vidange du réservoir souterrain
%   .x(5) = coefficient de partage
%   .x(6) = délai
%   .x(7) = constante de vidange du réservoir intermédiaire
%   .S    = Réservoir de superficiel
%   .T    = Réservoir de intermédiaire
%   .L    = Réservoir souterrain
%   .R    = Réservoir de routage quadratique
%
% FOLLOWING
% Mazenc et al. (1984)
% Bureau de Recherches Géologiques et Minières, Orléans, France
%
% Program : G. Seiller (U. Laval, 2010)

param.x = x ;

if nargin < 3
    param.S = 100 ;
    param.T = 50 ;
    param.L = 10 ;
    param.R = 5 ;
else
    param.S = states.S;
    param.T = states.T;
    param.L = states.L;
    param.R = states.R;
end

if size(data,2) ~= 3 % 3 column is Qb
    error('wrong data inputs')
end

P = data(:,1); E = data(:,2); Qb = data(:,3);

x(6) = round(x(6));

% Apply MARTINE for all time steps
%
lP    = length( P ) ;
Qs    = zeros( lP+x(6),1 ) ;
inter = zeros( lP+x(6),10 ) ;

for i = 1 : lP
    [Qs(i+x(6)),param,inter(i+x(6),:)] = MARTINEonestep( P(i), E(i), param, Qb(i) ) ;
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


function [Q,param,inter] = MARTINEonestep( P, E, param, Qb ) % Introduce Flowbase
%        [Q,param,inter] = MARTINEonestep( P, E, param )
%
% The MARTINE model as such.
%

% get parameters
%
x   = param.x ;
S   = param.S ;
T   = param.T ;
L   = param.L ;
R   = param.R ;

%%%
%%% PRODUCTION AND ROUTING
%%%

% Soil storage (S)
%
S = S+P;
Pr = max(0,S-x(1));
S = S-Pr;
Es = min(S,E);
S = S-Es;
Er = E-Es;

% Direct routing storage (R)
%
R = R+x(5)*Pr;
Qr = (R^2)/(R+x(3));
R = R-Qr;

% Lower storage (T)
%
T = T+(1-x(5))*Pr;
Qt1 = T/x(7);
T = T-Qt1;
Qt2 = max(0,T-x(2));
T = T-Qt2;

% Groundwater storage (L)
%
L = L+Qt1+Qt2;
Ql = L/x(4);
L = L-Ql;

% Total discharge
%
Q = Ql + Qr + Qb;

% Data
param.S  = S ;
param.T  = T ;
param.L  = L ;
param.R  = R ;

inter = [ S T L R Pr Es Qt1 Qt2 Ql Qr ] ;
end