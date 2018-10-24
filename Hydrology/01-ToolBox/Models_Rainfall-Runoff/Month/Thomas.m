function [varargout] = Thomas(varargin)
% [Qs, States, StatesTime] = Thomas(Data, Param, States)
%% BASE DATA 
% Project               : Landscape planning for agro-industrial expansion 
%                         in a large, well-preserved savanna: how to plan 
%                         multifunctional landscapes at scale for nature and 
%                         people in the Orinoquia region, Colombia
% Author                : Jonathan Nogales Pimentel
% Email                 : nogales02@hotmail.com
% Hydrology Specialist  : Carlos Andrés Rogéliz
% Company               : The Nature Conservancy - TNC
% 
%% MODEL OF THOMAS - (1981) - "abcd"
% Copyright (C) 2017 Apox Technologies
% This program is free software: you can redistribute it and/or modify it 
% under the terms of the GNU General Public License as published by the 
% Free Software Foundation, either version 3 of the License, or option) any 
% later version. This program is distributed in the hope that it will be 
% useful, but WITHOUT ANY WARRANTY; without even the implied warranty of 
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
% ee the GNU General Public License for more details. You should have 
% received a copy of the GNU General Public License along with this program.  
% If not, see http://www.gnu.org/licenses/.
%
%% INPUT 
% Data(:,1) = Precipitation                                 [mm/month]
% Data(:,2) = Actual Evapotrasnpiration                     [mm/month]
% Param -->
%   .Sgo    = Aquifer Storage                               [mm/month]
%   .Swo    = Soil Moinsture                                [mm/month]
%   .a      = Soil Retention Capacity                       [dimensionless]
%   .b      = Soil Moisture                                 [dimensionless]
%   .c      = Distribution Coefficient Runoff-Infiltration  [dimensionless]
%   .d      = Aquifer Store                                 [dimensionless]
%
%% OUTPUT 
% Q         = Stremflow      - [n,1]                        [mm]
% States    = System States  - [n,5]
% Param -->
%   .Sgo    = Aquifer Storage                               [mm/month]
%   .Swo    = Soil Moinsture                                [mm/month]
%   .a      = Soil Retention Capacity                       [dimensionless]
%   .b      = Soil Moisture                                 [dimensionless]
%   .c      = Distribution Coefficient Runoff-Infiltration  [dimensionless]
%   .d      = Aquifer Store                                 [dimensionless]
%
%% STATES VARIABLE
% Ro        = Direct runoff                                 [mm]
% Rg        = Aquifer reload                                [mm]
%
%%
% Input Number Verification
if nargin < 2, error('Not enough input arguments'), end

% Data
Data  = varargin{1};

% Input Parameter Verification 
if nargin == 2
    States.Sgo  = 100;
    States.Swo  = 100;
else
    States      = varargin{3};
    if isfield(States, 'Sgo'), else error('Varible State "Sgo" not found'),  end
    if isfield(States, 'Swo'), else error('Varible State "Swo" not found'),  end
end

% Parameters
Param = varargin{2};

% Input Variable States
if isfield(Param, 'a'),     else error('Paremeter "a" not found'),  end
if isfield(Param, 'b'),     else error('Paremeter "b" not found'),  end
if isfield(Param, 'c'),     else error('Paremeter "c" not found'),  end
if isfield(Param, 'd'),     else error('Paremeter "d" not found'),  end

%% INPUT DATA 
% Precipitation [mm]
P           = Data(:,1);
% Actual Evapotranspiration [mm]
ETR         = Data(:,2);
% length Data 
n           = length(P);
% States Model
StatesTime  = zeros(n,5);

for i = 1:n
    [Qs(i), States, StatesTime(i,:)] = ThomasOneStep(P(i), ETR(i), Param, States);
end

varargout(1) = {Qs};
varargout(2) = {States};
varargout(3) = {StatesTime};
end

%% Models Thomas
function [Q, States, StatesTime] = ThomasOneStep(P, ETR, Param, States)
    % Soli Moinsture initial
    Sw     = States.Swo;
    % Aquifer Storage initial
    Sg     = States.Sgo; 
    % Get Parameters
    a      = Param.a;
    b      = Param.b;
    c      = Param.c;
    d      = Param.d;

    %%
    W      = P + Sw;    
    Y      = ((W + b) / (2 * a)) - ((((W + b) / (2 * a))^2) - ((W * b) / a))^0.5; 
    Sw     = Y * exp((-ETR) / b);   
    Ro     = (1 - c) * (W - Y);
    Rg     = c * (W - Y); 
    Sg     = (Rg + Sg) / (1 + d);
    Qg     = d * Sg;
    Q      = Ro + Qg;

    States.Sgo   = Sg;
    States.Swo   = Sw;
    StatesTime   = [ Sw Ro Rg Sg Qg ];
end
