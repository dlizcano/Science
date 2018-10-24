function [Qs,perf,inter,param] = HBV( x, data )
%
% HBV (Hydrologiska Byrans Vattenbalansavdelning)
%
% Version : 9 parameters

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
% inter = HBV's internal values
% param -->
% .x(1) = Capacité du réservoir sol (mm)
% .x(2) = Seuil pour l'ETP
% .x(3) = Constante de vidange supérieure du réservoir intermédiaire
% .x(4) = Constante de vidange du réservoir souterrain
% .x(5) = Coefficient de percolation
% .x(6) = Constante de temps de l'hydrogramme triangulaire
% .x(7) = Exposant B
% .x(8) = Seuil d'écoulement du réservoir intermédiaire
% .x(9) = Constante de vidange inférieure du réservoir intermédiaire
%
% .S = Réservoir de sol (mm)
% .R = Réservoir intermédiaire (mm)
% .T = Réservoir souterrain (mm)
%
% .UH  = Unit hydrograph
% .H   = Hydrograph values (mm) - updated at each time step
%
% FOLLOWING
% Bergström and Forsman (1973)
% 
%
% Program : G. Seiller (U. Laval, 2010)

if size(data,2) ~= 3 % 3 column is Qb
    error('wrong data inputs')
end

P = data(:,1); E = data(:,2); Qb = data(:,3);

param.x = x ;

% Initialization of the reservoir states
%
param.S = 150;
param.R = 50;
param.T = 0;

% UH initialization (triangular weighting function)
%
x6c      = ceil(x(6)/2);
t1       = ( 0:x6c )' ;
t2       = ( x6c+1:2*x6c )' ;
SH       = [ ((2/x(6))-abs(t1-(x(6)/2))*((4/(x(6)^2)))).*(0.5*t1); 1-((2/x(6))-abs(t2-(x(6)/2))*((4/(x(6)^2)))).*(0.5*(x(6)-t2)) ] ;
SH       = real( SH ) ;
param.UH = diff( SH ) ;
param.H  = zeros( size(param.UH) ) ;

% Apply HBV
%
lP = length( P ) ;
Qs = zeros(lP,1);
inter = zeros( lP,7);

for i = 1 : lP
    [Qs(i),param,inter(i,:)] = HBVonestep( P(i), E(i), param, Qb(i) ) ;
end

% Assess the simulation performance (remove first year)
%
% perf = det_scores( Q(366:end), Qs(366:end) ) ;
perf = 0;
end


function [Q,param,inter] = HBVonestep( P, E, param, Qb ) % Introduce Flowbase
% [Q,param,inter] = HBVonestep( P, E, param )
%
% The HBV model as such.
%

% get parameters
%
x = param.x ;
S = param.S ;
R = param.R ;
T = param.T ;

UH = param.UH ;
H  = param.H ;

%%% PRODUCTION PART

% Soil storage (S) routine (5 steps)
%
Pr = 0;

P5 = P/5;
E5 = E/5;

Pr1 = P5*((min(1,S/x(1)))^x(7));
Pr = Pr + Pr1;
S = S + (P5 - Pr1);
Es1 = min(S,E5*(S/x(2)));
S = S-Es1;

Pr2 = P5*((min(1,S/x(1)))^x(7));
Pr = Pr + Pr2;
S = S + (P5 - Pr2);
Es2 = min(S,E5*(S/x(2)));
S = S-Es2;

Pr3 = P5*((min(1,S/x(1)))^x(7));
Pr = Pr + Pr3;
S = S + (P5 - Pr3);
Es3 = min(S,E5*(S/x(2)));
S = S-Es3;

Pr4 = P5*((min(1,S/x(1)))^x(7));
Pr = Pr + Pr4;
S = S + (P5 - Pr4);
Es4 = min(S,E5*(S/x(2)));
S = S-Es4;

Pr5 = P5*((min(1,S/x(1)))^x(7));
Pr = Pr + Pr5;
S = S + (P5 - Pr5);
Es5 = min(S,E5*(S/x(2)));
S = S-Es5;

%%% ROUTING
%
% Routing storage (R)
%
R = R+Pr;
Qr1 = max(0,(R-x(8))/x(3));
R = R-Qr1;
Qr2 = R/(x(3)*x(9));
R = R-Qr2;
Ir = min(R,x(5));
R = R-Ir;

% Groundwater storage (T)
%
T = T+Ir;
Qt = T/x(4);
T = T-Qt;

% Total discharge
%
Q = Qr1 + Qr2 + Qt + Qb;

% Mise à jour de l'hydrogramme
%
H = [H(2:end); 0] + UH * Q ;

Q = max( [0; H(1)] ) ;

Q = Q + Qb;

% Data
%
inter = [ S R T Pr Qr1 Qr2 Qt ];

param.S = S;
param.R = R;
param.T = T;

param.H = H ;

end