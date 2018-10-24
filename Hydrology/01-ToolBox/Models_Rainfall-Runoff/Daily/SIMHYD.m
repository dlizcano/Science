function [Qs,perf,inter,param] = SIMHYD( x, data )
%
% SIMHYD
%
% Modified version : 8 parameters
%
%% INPUT DATA
% (time series of daily observations [n,1])
% P = mean areal rainfall (mm)
% E = mean areal evapotranspiration (mm)
% x = the eight model parameters (see "param" below) - [8,1]
%
%% OUTPUTS
% Qs = simulated stream flow (mm)
% inter = SIMHYD's internal values
% param -->
% .x(1) = paramètre d'interception (évaporation)
% .x(2) = capacité maximale du réservoir de sol
% .x(3) = constante de vidange hypodermique
% .x(4) = délai
% .x(5) = constante de vidange de routage
% .x(6) = constante de ruissellement directe
% .x(7) = constante de percolation
% .x(8) = paramètre d'interception (infiltration)
% .S    = Réservoir sol
% .R    = Réservoir de sous-sol
% .T    = Réservoir de routage (réservoir "rivière")
%
%% FOLLOWING
% Chiew (2002)
% University of Melbourne, Australia
%
% Program : G. Seiller (U. Laval, 2010)

if size(data,2) ~= 3 % 3 column is Qb
    error('wrong data inputs')
end

P = data(:,1); E = data(:,2); Qb = data(:,3);

param.x = x ;
x(4) = round(x(4));

% Initialization of the reservoir states
%
param.S = 150;
param.R = 0;
param.T = 0;

% Apply SIMHYD
%
lP = length( P ) ;
S = zeros( lP,1 );
R = zeros( lP,1 );
T = zeros( lP,1 );
Qs = zeros( lP,1 );

inter = zeros( lP,5);

for i = 1 : lP-x(4)
    [Qs(i+x(4)),param,inter(i,:)] = SIMHYDonestep( P(i), E(i), param, Qb(i) ) ;
end

% Assess the simulation performance (remove first year)
%
% perf = det_scores( Q(366:end), Qs(366:end) ) ;
perf = 0;
end


function [Q,param,inter] = SIMHYDonestep( P, E, param, Qb ) % Introduce Flowbase
% [Q,param,inter] = SIMHYDonestep( P, E, param )
%
% The SIMHYD model as such.
%

% Get parameters
%
x = param.x ;
S = param.S ;
R = param.R ;
T = param.T ;

%%%
%%% PRODUCTION AND ROUTING
%%%

CAP1=x(1);
CAP=min(CAP1,E);
CAP=min(P,CAP);

if P > CAP;
    EXC=P-CAP;
	E1=CAP;
else
    EXC=0;
	E1=P;
end

COEF=x(8);
SQ=2;
RINF=COEF*exp(-SQ*S/x(2));

if EXC > RINF
    SRUN=EXC-RINF;
	FILT=RINF;
else
	SRUN=0;
	FILT=EXC;
end

SINT=S/x(2)*FILT/x(6);
REC=S/x(2)*(FILT-SINT)/x(7);
S=S+FILT-SINT-REC;
EX2=0;

if S > x(2)
	EX2=S-x(2);
	S=x(2);
end

CAP2=10;
ET=min(E-E1,CAP2*S/x(2));
S=max(0,S-ET);

R=R+EX2+REC;
Qr=R/x(3)/x(5);
R=R-Qr;
      
T=T+SINT+SRUN+Qr;
Qt=T/x(5);
T=T-Qt;

% Total discharge
%
Q = Qt + Qb;

% Data
%
inter = [ S R T Qt Qr ];

param.S = S;
param.R = R;
param.T = T;
end
