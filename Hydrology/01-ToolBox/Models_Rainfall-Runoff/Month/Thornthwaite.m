function [varargout] = Thornthwaite(P, ETo, param)
% [Q, states, param] = Model_Thornthwaite(P, ETo, param)
%% THORNTHWAITE MODEL, C.W. and J.R. MATHER
%% BASIC DATA
% Author      : Jonathan Nogales Pimentel
% Email       : nogales02@hotmail.com
% Description : The Thornthwaite water balance (Thornthwaite, 1948; Mather, 1978; 1979) 
%               uses an accounting procedure to analyze the allocation of water among various 
%               components of the hydrologic system
%
%% INPUT DATA
% P   = Precipitation (mm-month)
% ETo = Potential Evapotranspiration (mm-mounth)
% param -->
%    .CAS = quantity of water that is soil stored (mm-month)
%    .FAI = Fraction that is infiltrates (dimensinless)
%
%% OUTPUT
% Q   = Simulated Streamflow (mm)
% D   = Soil Moisture Defict (mm)
% R   = Reload (mm)
%%

% Input Number Verification
if nargin < 3, disp('Error'), end

% Input Parameter Verification 
if isfield(param, 'CAS'), CAS = param.CAS; else disp('Paremeter "CAS" not found'), end
if isfield(param, 'FAI'), FAI = param.FAI; else disp('Paremeter "FAI" not found'), end
if isfield(param, 'S'),   S   = param.S;   else S = param.CAS;      end
if isfield(param, 'Q'),                    else param.Q = mean(P);  end


%% STOREGE DATA
n       = length(P);
Q       = zeros(n,1); 
states  = zeros(n,3);

%% MODEL
for i = 1:n
    if P(i) > ETo(i)
        S = min([((P(i) - ETo(i)) + S), CAS]);
    else 
        S = S * exp((-(ETo(i) - P(i))) / CAS);
    end 
    if ((P(i) - ETo(i)) + S) >= CAS
        dQ = (P(i) - ETo(i)) + S - CAS;
    else
        dQ = 0;
    end
    
    D    = CAS - S;
    R    = FAI * (param.Q + dQ);
    Q(i) = (1 - FAI) * (param.Q + dQ);
    
    param.Q = Q(i);
    param.S = S;
    states(i,:) = [So D R];
end

varargout(1) = {Q};
varargout(2) = {states};
varargout(3) = {param};

