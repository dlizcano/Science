function [Qs,perf,inter,param] = GR4J( x, data )
%
% GR4J global hydrological model
%
% INPUTS (time series of daily observations [n,1])
% P       = mean areal rainfall (mm)
% E       = mean areal evapotranspiration (mm)
% Q       = stream flow (mm)
% x       = the four model parameters (see "param" below) - [4,1]
%
% OUTPUTS
% Qs      = simulated stream flow (mm)
% perf    = model performances
% inter   = GR4J's internal values
% param -->
%   .x(1) = maximum capacity of the production store (mm)
%   .x(2) = groundwater exchange coefficient (mm)
%   .x(3) = one-day-ahead maximum capacity of the routing store (mm)
%   .x(4) = time base of unit hydrograph UH1 (day)
%   .B    = fraction of Pr routed by UH1 (fixed to 0.9)
%   .S    = production store level (mm)
%   .R    = routing store level (mm)
%   .UH1  = Unit hydrograph 1 - rapid flow
%   .UH2  = Unit hydrograph 2 - slower flow
%   .H1   = Hydrograph 1 values (mm) - updated at each time step
%   .H2   = Hydrograph 2 values (mm) - updated at each time step
%
% FOLLOWING
% Perrin C, Michel C & Andréassian V. 2003. Improvement of a parsimonious 
%    model for stramflow simulation. J. Hydrol. 279, 275-289.
%
% F.Anctil, Univ. Laval (01-2009)

% if size(data,2) ~= 3 % 3 column is Qb
%     error('wrong data inputs')
% end
if size(data,2) ~= 3 , Qb = zeros(length(data(:,1)),1); else Qb = data(:,3); end
P = data(:,1); E = data(:,2); 

param.x = x ;
% Initialization of the reservoir states
%
param.B = 0.9 ;
param.S = 0.5 * param.x(1) ;
param.R = 0.5 * param.x(3) ;

% UH1 initialization --> the last one always has a value of 1
%
x4c       = ceil( x(4) ) ;
t         = ( 0:x4c )' ;
SH1       = [( t(1:end-1)/x(4) ) .^2.5; 1] ;
param.UH1 = diff( SH1 ) ;
param.H1  = zeros( size(param.UH1) ) ;

% UH2 initialization --> An imaginary part is produced when t > 2x4
%
t2        = ( x4c+1:2*x4c )' ;
SH2       = [ 0.5*(t/x(4)).^2.5; 1-0.5*(2-t2/x(4)).^2.5 ] ;
SH2       = real( SH2 ) ;
param.UH2 = diff( SH2 ) ;
param.H2  = zeros( size(param.UH2) ) ;

% Apply GR4J for all time steps
%
lP    = length( P ) ;
Qs    = zeros( lP,1 ) ;
inter = zeros( lP,9 ) ;
for i = 1 : lP
    [Qs(i),param,inter(i,:)] = GR4Jonestep( P(i), E(i), param, Qb(i) ) ;
end

% Assess the simulation performance (remove first year)
%
% perf = det_scores( Q(366:end), Qs(366:end) ) ;
perf = 0;
end


function [Q,param,inter] = GR4Jonestep( P, E, param, Qb ) % Introduce Flowbase
%        [Q,param,inter] = GR4Jonestep( P, E, param )
%
% The GR4J model as such.
%
% F.Anctil, Univ. Laval (01-2009)

% get parameters
%
x   = param.x ;
S   = param.S ;
R   = param.R ;
B   = param.B ;
UH1 = param.UH1 ;
UH2 = param.UH2 ;
H1  = param.H1 ;
H2  = param.H2 ;

%%%
%%% PRODUCTION PART
%%%

% Net inputs
%
if P >= E
    Pn = P - E ;
    En = 0 ;
else
    En = E - P ;
    Pn = 0 ;
end

% Soil moisture accounting
%
if Pn > 0
    tilap1 = S / x(1) ;
    tilap2 = tanh( Pn / x(1) ) ;
    Ps = ( x(1)*( 1-tilap1.^2 )*tilap2 ) / ( 1+tilap1*tilap2 ) ;
    Es = 0 ;
else
    tilap1 = S / x(1) ;
    tilap2 = tanh( En / x(1) ) ;
    Es = ( S*(2-tilap1)*tilap2 ) / ( 1+(1-tilap1)*tilap2 ) ;
    Ps = 0 ;
end
S = S - Es + Ps ;

% Percolation
%
if x(1)/S > 0.001
    Perc =  S * ( 1- ( 1+ (4*S/9/x(1)).^4).^-0.25 ) ;
    S = S - Perc ;
else
    Perc = 0 ;
end
Pr = Pn - Ps + Perc ;

%%%
%%% ROUTING
%%%

% Mise à jour des hydrogrammes 1 & 2
%
H1 = [H1(2:end); 0] + UH1 * Pr * B ;
H2 = [H2(2:end); 0] + UH2 * Pr * (1-B) ;

% Calcul de l'échange
%
F = x(2) * (R/x(3))^3.5 ;
      
% Mise à jour du niveau du réservoir de routage
%
R = max( [0.001*x(3); R + H1(1) + F] ) ;
      
% Calcul de la vidange du réservoir de routage et mise à jour du niveau
%
Qr = R * ( 1- ( 1+ (R/x(3)).^4 ).^-0.25 ) ;
R = R - Qr ;
     
% Calcul de la composante pseudo-direct de l'écoulement
%
Qd = max( [0; H2(1) + F] ) ;

% Calcul du débit total
%
Q = Qr + Qd + Qb;

param.S  = S ;
param.R  = R ;
param.H1 = H1 ;
param.H2 = H2 ;

inter = [ Es Ps S Perc Pr F R Qr Qd ] ;
end
