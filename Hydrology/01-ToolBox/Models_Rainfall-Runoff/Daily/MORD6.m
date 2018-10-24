function [Qs,varargout] = MORD6(x,data,states)
%
% MORD6 (MORDOR 6 parameters)
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
% inter   = MORD6's internal values
% param -->
%   .x(1) = Coefficient correcteur sur la pluie
%   .x(2) = Constante de vidange du réservoir L
%   .x(3) = Constante de vidange du réservoir N
%   .x(4) = Temps de réponse de l’hydrogramme unitaire HU2
%   .x(5) = Capacité du réservoir U
%   .x(6) = Capacité du réservoir L
%   .U    = Réservoir de surface
%   .L    = Réservoir de sol
%   .Z    = Réservoir de sol profond
%   .N    = Réservoir souterrain
%   .UH2  = Unit hydrograph 2
%   .H2   = Hydrograph 2 values (mm) - updated at each time step
%
% FOLLOWING
% Mathevet, T., Quels modéles pluie-débit globaux au pas de temps horaires,
% 2005
%
%
% Program : G. Seiller (U. Laval, 2010)

param.x = x ;

if nargin < 3
    param.U = 100 ;
    param.L = 20 ;
    param.Z = 50 ;
    param.N = 5 ;
else
    param.U = states.U;
    param.L = states.L;
    param.Z = states.Z;
    param.N = states.N;
end

if size(data,2) ~= 3 % 3 column is Qb
    error('wrong data inputs')
end

P = data(:,1); E = data(:,2); Qb = data(:,3);

% UH2 initialization --> An imaginary part is produced when t > 2x4
%
x4c       = ceil( x(4) ) ;
t         = ( 0:x4c )' ;
t2        = ( x4c+1:2*x4c )' ;
SH2       = [ 0.5*(t/x(4)).^(5/2); 1-0.5*(2-t2/x(4)).^(5/2) ] ;
SH2       = real( SH2 ) ;
param.UH2 = diff( SH2 ) ;

if nargin < 3
    param.H2  = zeros( size(param.UH2) ) ;
else
    param.H2 = states.H2 ;
end

% Apply MORD6 for all time steps
%
lP    = length( P ) ;
Qs    = zeros( lP,1 ) ;
inter = zeros( lP,12+size(param.UH2,1) ) ;
for i = 1 : lP
    [Qs(i),param,inter(i,:)] = MORD6onestep( P(i), E(i), param, Qb(i) ) ;
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


function [Q,param,inter] = MORD6onestep( P, E, param, Qb ) % Introduce Flowbase
%        [Q,param,inter] = MORD6onestep( P, E, param )
%
% The MORD6 model as such.
%

% get parameters
%
x   = param.x ;
U   = param.U ;
L   = param.L ;
Z   = param.Z ;
N   = param.N ;
UH2 = param.UH2 ;
H2  = param.H2 ;

%%%
%%% PRODUCTION PART
%%%

% Net inputs
%
Pl = P*x(1);
dtr1 = Pl*(U/x(5));
dtu1 = Pl-dtr1;

% Soil moisture accounting
%
vs = dtr1+max(0,U-x(5));
U = min(U+dtu1,x(5));
evu = min(x(5),(E*U)/x(5));
U = U-evu;

al = min(x(6)-L,vs*(1-(L/x(6))));
L = L+al;
vl = L/x(2);
L = L-vl;

% Percolation
%
dtz = vl*(1-(Z/90));
rur = 0.2*vl*(Z/90);
an = 0.8*vl*(Z/90);
Z = Z+dtz;
evz = min(Z,((E-evu)*Z)/90);
Z = min(90,Z-evz);

N = N+an;
vn = min(N,(N/x(3))^3);
N = N-vn;

%%%
%%% ROUTING
%%%

% Somme et routage des différentes contributions
%
Qt = vs - al + rur + vn;

% Mise à jour de l'hydrogramme
%
H2 = [H2(2:end); 0] + UH2* Qt ;
      
% Calcul du débit total
%
Q = max( [0; H2(1)] );
Q = Q + Qb;

param.U  = U ;
param.L  = L ;
param.Z  = Z ;
param.N  = N ;
param.H2 = H2 ;

inter = [ U L Z N dtu1 dtr1 evu evz dtz vn rur Qt H2' ] ;
end