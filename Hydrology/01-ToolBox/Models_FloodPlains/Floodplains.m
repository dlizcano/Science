function [varargout] = Floodplains_Network(Param, Data)
% [Qs, States, Param] = Thomas(Param, Data)
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
%% Floodplains (Angarita, 2017)
% Floodplains  => http://revistas.javeriana.edu.co/index.php/iyu/article/view/1137/807
%
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
% Data(:,1) = Precipitation                                         [mm]
% Data(:,2) = Actual Evapotrasnpiration                             [mm]
% Data(:,3) = Streamflow                                            [mm]
% Param -->
%   .Vh     = Volume of the floodplain Initial                      [mm]
%   .Ah     = Area of the Floodplain                                [Km2]
%   .At     = Area of the Basin                                     [Km2]
%   .Trp    = Percentage lateral flow between river and floodplain  [dimensionless]
%   .Tpr    = Percentage return flow from floodplain to river       [dimensionless]
%   .Q_Umb  = Threshold lateral flow between river and floodplain   [mm]
%   .V_Umb  = Threshold return flow from floodplain to river        [mm]
%
%% OUTPUT 
% Q         = Streamflow     - [n,1]                                [mm]
% States    = System States  - [n,8]
% Param -->
%   .Vh     = Volume of the floodplain Initial                      [mm]
%   .Ah     = Area of the Floodplain                                [Km2]
%   .At     = Area of the Basin                                     [Km2]
%   .Trp    = Percentage lateral flow between river and floodplain  [dimensionless]
%   .Tpr    = Percentage return flow from floodplain to river       [dimensionless]
%   .Q_Umb  = Threshold lateral flow between river and floodplain   [mm]
%   .V_Umb  = Threshold return flow from floodplain to river        [mm]

%%
% Input Number Verification
if nargin < 2, error('Not enough input arguments'), end

% Variable state Verification 
if isfield(Param, 'Qh'),    else Param.Qh  = 0;                         end
if isfield(Param, 'Vh'),    else Param.Vh  = 0;                         end

% Parameter Verification 
if isfield(Param, 'Ah'),    else error('Paremeter "Ah" not found'),     end
if isfield(Param, 'At'),    else error('Paremeter "At" not found'),     end
if isfield(Param, 'Trp'),   else error('Paremeter "Trp" not found'),    end
if isfield(Param, 'Tpr'),   else error('Paremeter "Tpr" not found'),    end
if isfield(Param, 'Q_Umb'), else error('Paremeter "Q_Umb" not found'),  end
if isfield(Param, 'V_Umb'), else error('Paremeter "Q_Umb" not found'),  end

%% INPUT DATA 
% Precipitation [mm]
P       = Data(:,1);
% Actual Evapotranspiration [mm]
ETR     = Data(:,2);
% Streamflow
Q       = Data(:,3);
% length Data 
n       = length(P);
% States Model
States  = zeros(n,5);

for i = 1:n
    [Qs(i), States(i,:), Param] = FloodplainsOneStep(P(i), ETR(i), Q(i), Param);
end

varargout(1) = {Qs};
varargout(2) = {States};
varargout(3) = {Param};
end

%% Models Thomas
function [Q, States, Param] = FloodplainsOneStep(P, ETR, Q, Param)
    % volume of the floodplain
    Vh  = Param.Vh;
    % Get Parameters
    At  = Param.At;
    Ah  = Param.Ah;
    Trp = Param.Trp;
    Tpr = Param.Tpr;
    
    %% Floodplains hydrologic dynamics
    % Lateral flow between river and floodplain
    if Q > Q_Umb
        Ql = Trp * (Q - Q_Umb);
    else
        Ql = 0;
    end
    
    % Return flow from floodplain to river
    if Vh > V_Umb
        Rl = Tpr * (Vh - V_Umb);
    else
        Rl = 0;
    end
    
    % Volume of the floodplain
    Vh  = Vh - Ql + Rl + ((Ah / At)*(P - ETR));
    
    Q   = Q - Ql + Rl;
    
    Param.Vh    = Vh;
    States      = [ Ql Rl Vh ];
end
