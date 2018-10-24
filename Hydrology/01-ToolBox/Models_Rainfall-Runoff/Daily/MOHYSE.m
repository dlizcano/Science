function [Qs,varargout] = MOHYSE(x,data,states)
%
% MOHYSE (7 parameters)
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
% inter   = MOHYSE's internal values
% param -->
%   Cetp non utilisé (calcul ETP)
%   .x(1) = Ctr : coefficient d’ajustement de la transpiration
%   Cf non utilisé (fonte)
%   Tf non utilisé (fonte)
%   .x(2) = Cinf : taux maximal d’infiltration
%   .x(3) = Cva : coefficient de vidange de la zone vadose à l’aquifère
%   .x(4) = Cv : coefficient de vidange de la zone vadose au cours d’eau
%   .x(5) = Ca : coefficient  de  vidange  de  l’aquifère  vers  cours d’eau
%   .x(6) = Alpha : ? paramètre de  forme  de  l’hydrogramme unitaire
%   .x(7) = Beta : ? paramètre  d’échelle  de  l’hydrogramme  unitaire
%   .S    = Réservoir de surface
%   .R    = Réservoir souterrain
%   .UH   = Unit hydrograph
%   .HU   = Hydrograph values (mm) - updated at each time step
%
% FOLLOWING
% V. Fortin (Environnement Canada), R. Turcotte (CEHQ)
%
%
% Program : G. Seiller (U. Laval, 2010)

param.x = x ;

if nargin < 3
    param.S = 0 ;
    param.R = 0 ;
else
    param.S = states.S;
    param.R = states.R;
end

if size(data,2) ~= 3 % 3 column is Qb
    error('wrong data inputs')
end

P = data(:,1); E = data(:,2); Qb = data(:,3);

% UH initialization
%
k        = 12; % mémoire
t        = ( 1:k )' ;
SH       = t.^(x(6)-1).*exp(-t/x(7));
sumSH    = sum(SH);
param.UH = SH./sumSH;

if nargin < 3
    param.HU = zeros( size(param.UH) ) ;
else
    param.HU = states.HU ;
end

% Apply MOHYSE for all time steps
%
lP    = length( P ) ;
Qs    = zeros( lP+1,1 ) ;
inter = zeros( lP+1,9+size(param.UH,1) ) ;

for i = 1 : lP
       [Qs(i+1),param,inter(i+1,:)] = MOHYSEonestep( P(i), E(i), param, Qb(i) ) ;
       %%%%% +1 : décalage de l'eau en transit
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


function [Q,param,inter] = MOHYSEonestep( P, E, param, Qb ) % Introduce Flowbase
%        [Q,param,inter] = MOHYSEonestep( P, E, param )
%
% The MOHYSE model as such.
%

% get parameters
%
x   = param.x ;
S   = param.S ;
R   = param.R ;
UH  = param.UH ;
HU  = param.HU ;

%%%
%%% PRODUCTION AND ROUTING
%%%

ED = min(P,E);

TR = min(x(1)*S,E-ED);

if S >= x(2)
    I = 0;
else
    I = (P-ED)*(1-S/x(2));
end


% Calcul des flux

Q1 = P-ED-I;

Q2 = x(4)*S;

Q3 = x(5)*R;

qt = x(3)*S;

% Mise à jour des réservoirs

S = S+I-TR-qt-Q2;

R = R+qt-Q3;


% Calcul du débit total
Qt = Q1 + Q2 + Q3 + Qb;


% Mise à jour de l'hydrogramme
%
HU = [HU(2:end); 0] + UH .* Qt ;


% Calcul du débit total
%
Q = HU(1);

param.S  = S ;
param.R  = R ;
param.HU = HU ;

inter = [ S R ED I TR Q1 Q2 Q3 Qt HU' ] ;
end