%/usr/bin/Matlab-R2016b
function [AccumUpVar,Vh,Ql,Rl, PoPo, PoPoFlood] = Network( ArcID,...
                      Arc_InitNode, Arc_EndNode, ArcID_Downstream,...
                      AccumVar, AccumStatus, ArcIDFlood, FloodArea, IDExtAgri, IDExtDom, IDExtLiv,...
                      IDExtMin,IDExtHy, IDRetDom,IDRetLiv,IDRetMin,IDRetHy, P, ETP,...
                      Vh,Ql, Rl,Trp,Tpr, Q_Umb, V_Umb, b, Y, PoPo, PoPoFlood)
%% DATA PRE-PROCESING
%% Original Author: Hector Angarita, 2015 Version 3.Beta;  Email: flector@gmail.com
%% BASE DATA 
% Project               : Landscape planning for agro-industrial expansion 
%                         in a large, well-preserved savanna: how to plan 
%                         multifunctional landscapes at scale for nature
%                         and people in the Orinoquia region, Colombia
% Modified by           : Jonathan Nogales Pimentel
% Email                 : nogales02@hotmail.com
% Hydrology Specialist  : Carlos Andrés Rogéliz
% Company               : The Nature Conservancy - TNC
% 
% Copyright (C) 2017 Apox Technologies
% This program is free software: you can redistribute it and/or modify it 
% under the terms of the GNU General Public License as published by the 
% Free Software Foundation, either version 3 of the License, or option) any 
% later version. This program is distributed in the hope that it will be 
% useful, but WITHOUT ANY WARRANTY; without even the implied warranty of 
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
% ee the GNU General Public License for more details. You should have 
% received a copy of the GNU General Public License along with this program
% If not, see http://www.gnu.org/licenses/.
%
%% INPUT DATA
%   ArcID                 : ID of each section of the network
%   Arc_InitNode          : Initial node of each section of the network
%   Arc_EndNode           : End node of each section of the network 
%   ArcID_Downstream      : ID of the end node of accumulation
%   AccumVar              : Variable to accumulate
%   AccumStatus           : Status of the accumulation variable == AccumVar
%   IDFlood               : ID of the section of the network with floodplain
%   IDExtDemand           : ID of the section of the network with demand extraction
%   Data(:,1) = Precipitation                                         [mm]
%   Data(:,2) = Actual Evapotrasnpiration                             [mm]
%   Data(:,3) = Streamflow                                            [mm]
%   Param -->
%     .Vh     = Volume of the floodplain Initial                      [mm]
%     .Ah     = Area of the Floodplain                                [Km2]
%     .At     = Area of the Basin                                     [Km2]
%     .Trp    = Percentage lateral flow between river and floodplain  [dimensionless]
%     .Tpr    = Percentage return flow from floodplain to river       [dimensionless]
%     .Q_Umb  = Threshold lateral flow between river and floodplain   [mm]
%     .V_Umb  = Threshold return flow from floodplain to river        [mm]
%     .a      = Soil Retention Capacity                               [dimensionless]
%     .b      = Maximum Capacity of Soil Storage                      [dimensionless]
%
%% OUTPUT DATA
%   AccumUpVar            : Accumulated variable in each section of the network

AccumUpVar  = AccumStatus; 
% Toma el Id del arco de cierre de la red 
current_id  = ArcID_Downstream;
% Identifica la posicion del arco de cierre de la red
Posi        = find(ArcID == current_id);
% Posi Basin 
PoPo(Posi)  = 1;

NumberBranches = 1;

while NumberBranches == 1
    %        
    Npre  =  Posi;
    % Identifica la posicion de los arcos que convergen en el arco 
    % de salida
    Posi    = find(Arc_EndNode == Arc_InitNode( Posi)); 

    % Calcula el numero de arcos que debe recorrer
    NumberBranches = length(Posi);

    if NumberBranches > 1           
        for i = 1:NumberBranches 
            start_sub_id    = ArcID( Posi(i));

            [cum_vars, Vh,Ql,Rl, PoPo, PoPoFlood] = Network( ArcID, Arc_InitNode, Arc_EndNode, start_sub_id,...
                      AccumVar, AccumUpVar, ArcIDFlood, FloodArea, IDExtAgri, IDExtDom, IDExtLiv,...
                      IDExtMin,IDExtHy, IDRetDom,IDRetLiv,IDRetMin,IDRetHy, P, ETP,...
                      Vh,Ql, Rl,Trp,Tpr, Q_Umb, V_Umb, b, Y, PoPo, PoPoFlood);

            AccumUpVar          = cum_vars;
            AccumUpVar(Npre,:)  = AccumUpVar(Npre,:) + cum_vars( Posi(i),:);
            
        end
        
        %% Extraction
        % Extraction Agricultutal Demand
        if sum( IDExtAgri == ArcID(Npre)) == 1
            AccumUpVar(Npre,1) = AccumUpVar(Npre,1) - AccumUpVar(Npre,2);
            AccumUpVar(Npre,2) = 0;
        end
        
        % Extraction Domestic Demand
        if sum( IDExtDom == ArcID(Npre)) == 1
            AccumUpVar(Npre,1) = AccumUpVar(Npre,1) - AccumUpVar(Npre,3);
            AccumUpVar(Npre,3) = 0;
        end
        
        % Extraction Livestock Demand
        if sum( IDExtLiv == ArcID(Npre)) == 1
            AccumUpVar(Npre,1) = AccumUpVar(Npre,1) - AccumUpVar(Npre,4);
            AccumUpVar(Npre,4) = 0;
        end
        
        % Extraction Hydrocarbons Demand
        if sum( IDExtHy == ArcID(Npre)) == 1
            AccumUpVar(Npre,1) = AccumUpVar(Npre,1) - AccumUpVar(Npre,5);
            AccumUpVar(Npre,5) = 0;
        end
        
        % Extraction Mining Demand
        if sum( IDExtMin == ArcID(Npre)) == 1
            AccumUpVar(Npre,1) = AccumUpVar(Npre,1) - AccumUpVar(Npre,6);
            AccumUpVar(Npre,6) = 0;
        end
        
        
        %% Returns
        % Returns Domestic Demand
        if sum(IDRetDom == ArcID(Npre)) == 1
            AccumUpVar(Npre,1) = AccumUpVar(Npre,1) + AccumUpVar(Npre,7);
            AccumUpVar(Npre,7) = 0;
        end
        
        % Returns Livestock Demand
        if sum(IDRetLiv == ArcID(Npre)) == 1
            AccumUpVar(Npre,1) = AccumUpVar(Npre,1) + AccumUpVar(Npre,8);
            AccumUpVar(Npre,8) = 0;
        end
        
        % Returns Hydrocarbons Demand
        if sum(IDRetHy == ArcID(Npre)) == 1
            AccumUpVar(Npre,1) = AccumUpVar(Npre,1) + AccumUpVar(Npre,9);
            AccumUpVar(Npre,9) = 0;
        end
        
        % Returns Mining Demand
        if sum(IDRetMin == ArcID(Npre)) == 1
            AccumUpVar(Npre,1) = AccumUpVar(Npre,1) + AccumUpVar(Npre,10);
            AccumUpVar(Npre,10) = 0;
        end
        
        %% Model Flood Plains
        if sum(ArcIDFlood == ArcID(Npre)) == 1
            PoPoFlood(ArcIDFlood == ArcID(Npre)) = 1;
            nn      = find(ArcIDFlood == ArcID(Npre));
            [AccumUpVar(Npre,1), Vh(nn), Ql(nn), Rl(nn)] = Floodplains_Network(P(Npre),...
                ETP(Npre), AccumUpVar(Npre,1), FloodArea(nn), Vh(nn), Trp(nn), Tpr(nn),...
                Q_Umb(nn), V_Umb(nn), b(nn), Y(nn) );
            
        end
        
    end

end  

