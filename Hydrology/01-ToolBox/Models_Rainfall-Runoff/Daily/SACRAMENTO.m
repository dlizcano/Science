function [Qs,varargout] = SACRAMENTO(x,data,states)
%
% SACRAMENTO, NWSRFS (National Weather Service River Forecast System)
%
% Modified version : only 9 parameters
% La proportion de surface imperm�able du bassin est consid�r�e nulle
% On s�pare le r�servoir sol en deux r�servoirs, avec un r�servoir
... d�interception et un r�servoir de vidange
% On fixe la capacit� du r�servoir d�interception � 3 mm
% On prend un r�servoir souterrain avec deux compartiments au lieu de trois
% On fixe la capacit� du compartiment d��vaporation � 30 mm
% La fonction d�infiltration est simplifi�e.
%
%
% INPUTS (time series of daily observations [n,1])
% P = mean areal rainfall (mm)
% E = mean areal evapotranspiration (mm)
% Q = stream flow (mm)
% x = the nine model parameters (see "param" below) - [9,1]
%
% OUTPUTS
% Qs = simulated stream flow (mm)
% perf = model performances
% inter = SACRAMENTO's internal values
% param -->
% .x(1) = capacit� uzfwm
% .x(2) = capacit� uztwm
% .x(3) = constante de vidange du r�servoir souterrain
% .x(4) = coefficient de percolations
% .x(5) = constante d�infiltration
% .x(6) = constante de vidange du d�bit hypodermique
% .x(7) = coefficient de partage pfree
% .x(8) = coefficient de percolations profondes
% .x(9) = d�lai
%
% .S = R�servoir d'interception (mm)
% .T = R�servoir de vidange (mm)
% .R = R�servoir souterrain soumis � l'�vaporation (mm)
% .L = R�servoir de routage souterrain (mm)
% .M = R�servoir de routage direct (mm)
%
% FOLLOWING
% Burnash et al. (1973)
% 
%
% Program : G. Seiller (U. Laval, 2010)

param.x = x ;

if nargin < 3
    param.S = 3;
    param.T = 10;
    param.R = 100;
    param.L = 10;
    param.M = 0;
else
    param.S = states.S;
    param.T = states.T;
    param.R = states.R;
    param.L = states.L;
    param.M = states.M;
end

if size(data,2) ~= 3 % 3 column is Qb
    error('wrong data inputs')
end

P = data(:,1); E = data(:,2); Qb = data(:,3);

x(9) = round(x(9));

% Initialization of the reservoir states
%
param.XF1 = 3;
param.XF2 = 30;

% Apply SACRAMENTO
%
lP = length( P );
Qs = zeros(lP+x(9),1);
inter = zeros( lP+x(9),11);

for i = 1 : lP
    [Qs(i+x(9)),param,inter(i+x(9),:)] = SACRAMENTOonestep( P(i), E(i), param, Qb(i) ) ;
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


function [Q,param,inter] = SACRAMENTOonestep( P, E, param, Qb ) % Introduce Flowbase
% [Q,param,inter] = SACRAMENTOonestep( P, E, param )
%
% The SACRAMENTO model as such.
%

% get parameters
%
x = param.x ;
S = param.S ;
T = param.T ;
R = param.R ;
L = param.L ;
M = param.M ;
XF1 = param.XF1;
XF2 = param.XF2;

% Surface storage (S)
%
S = S+P;
Es = min(E,S);
S = S-Es;
Er = E-Es;
Is = max(0,S-XF1);
S = S-Is;

% Soil storage (T)
%
T = T+Is;
It = min(T,x(5)*(1-(R/x(2)))*(T/x(4)));
T = T-It;
Qt1 = T/x(6);
T = T-Qt1;
Et = min(Er*min(1,T/x(4)),T);
T = T-Et;
Ez = Er-Et;
Qt0 = max(0,T-x(4));
T = T-Qt0;

% Groundwater storages (L & R)
%
L = L+x(7)*It;
Il = max(0,L-XF2);
L = L-Il;
R = R+(1-x(7))*It+Il;
El = (Ez*L)/(XF1+XF2);
L = L-El;
if L < 0
    Ir = min(-L,max(0,R-(x(2)-XF2)));
else
    Ir = 0;
end
L = max(0,L+Ir);
R = R-Ir;
Qr = R/x(3);
R = R-Qr;
Qr = Qr/x(8);

% Direct routing storage (M)
%
M = M+Qt0;
Qm = M/x(1);
M = M-Qm;

% Total discharge
%
Q = Qr + Qm + Qt1 + Qb;

% Data
param.S = S;
param.T = T;
param.R = R;
param.L = L;
param.M = M;

inter = [ S T R L M Is It Qt0 Qt1 Qr Qm ];
end
