function [AccumUpVar,Vh,Ql,Rl, PoPo, PoPoFlood] = Network(ArcID, Arc_InitNode, Arc_EndNode, ArcID_Downstream,...
                                                          AccumVar, AccumStatus, ArcIDFlood, FloodArea,...
                                                          IDExt,IDRet, P, ETP,...
                                                          Vh,Ql, Rl,Trp,Tpr, Q_Umb, V_Umb, b, Y, PoPo, PoPoFlood, ArcID_Downstream2)
% /usr/bin/Matlab-R2016b
% -------------------------------------------------------------------------
% Network
% -------------------------------------------------------------------------
% BASE DATA 
% -------------------------------------------------------------------------
% Project               : Landscape planning for agro-industrial expansion 
%                         in a large, well-preserved savanna: how to plan 
%                         multifunctional landscapes at scale for nature and 
%                         people in the Orinoquia region, Colombia
% Modified              : Jonathan Nogales Pimentel
% Email                 : jonathannogales02@gmail.com
% Company               : The Nature Conservancy - TNC
% 
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
% -------------------------------------------------------------------------
% INPUT DATA
% -------------------------------------------------------------------------
%   ArcID               [Cat,1]         = ID of each section of the network                     [Ad]
%   Arc_InitNode        [Cat,1]         = Initial node of each section of the network           [Ad]
%   Arc_EndNode         [Cat,1]         = End node of each section of the network               [Ad]
%   ArcID_Downstream    [1,1]           = ID of the end node of accumulation                    [Ad]
%   AccumVar            [Cat,Var]       = Variable to accumulate                                
%   AccumStatus         [Cat,Var]       = Status of the accumulation variable == AccumVar       
%   ArcIDFlood          [CatFlood,1]    = ID of the section of the network with floodplain      [Ad]
%   FloodArea           [CatFlood,1]    = Floodplain Area                                       [m^2]
%   IDExt               [Cat,1:5]  
%       IDExtAgri       [Cat,1]         = ID of the HUA where to extraction Agricultural Demand [Ad]
%       IDExtDom        [Cat,2]         = ID of the HUA where to extraction Domestic Demand     [Ad]
%       IDExtLiv        [Cat,3]         = ID of the HUA where to extraction Livestock Demand    [Ad]
%       IDExtHy         [Cat,4]         = ID of the HUA where to extraction Hydrocarbons Demand [Ad]
%       IDExtMin        [Cat,5]         = ID of the HUA where to extraction Mining Demand       [Ad]
%   IDRet
%       IDRetDom        [Cat,1]         = ID of the HUA where to return Domestic Demand         [Ad]
%       IDRetLiv        [Cat,1]         = ID of the HUA where to return Livestock Demand        [Ad]
%       IDRetMin        [Cat,1]         = ID of the HUA where to return Mining Demand           [Ad]
%       IDRetHy         [Cat,1]         = ID of the HUA where to return Hydrocarbons Demand     [Ad]
%   P                   [Cat,1]         = Precipitation                                         [mm]
%   ETP                 [Cat,1]         = Actual Evapotrasnpiration                             [mm]
%   Vh                  [CatFlood,1]    = Volume of the floodplain Initial                      [mm]
%   Ql                  [CatFlood,1]    = Lateral flow between river and floodplain             [mm]
%   Rl                  [CatFlood,1]    = Return flow from floodplain to river                  [mm]
%   Trp                 [CatFlood,1]    = Percentage lateral flow between river and floodplain  [Ad]
%   Tpr                 [CatFlood,1]    = Percentage return flow from floodplain to river       [Ad]
%   Q_Umb               [CatFlood,1]    = Threshold lateral flow between river and floodplain   [mm]
%   V_Umb               [CatFlood,1]    = Threshold return flow from floodplain to river        [mm]
%   a                   [Cat,1]         = Soil Retention Capacity                               [Ad]
%   b                   [Cat,1]         = Maximum Capacity of Soil Storage                      [Ad]
%   Y                   [Cat,1]         = Evapotranspiration Potential                          [mm]
%   PoPo                [Cat,1]         = ID of the HUA to calibrate                            [Ad]
%   PoPoFlood           [Cat,1]         = ID of the HUA to calibrate with floodplains           [Ad]
%   ArcID_Downstream2   [1,1]           = ID of the end node of accumulation                    [Ad]
%
% -------------------------------------------------------------------------
% OUTPUT DATA
% -------------------------------------------------------------------------
%   AccumUpVar          [Cat,Var]       = Accumulated variable in each section of the network
%   Vh                  [CatFlood,1]    = Volume of the floodplain Initial                      [mm]
%   Ql                  [CatFlood,1]    = Lateral flow between river and floodplain             [mm]
%   Rl                  [CatFlood,1]    = Return flow from floodplain to river                  [mm]
%   PoPo                [Cat,1]         = ID of the HUA to calibrate                            [Ad]
%   PoPoFlood           [Cat,1]         = ID of the HUA to calibrate with floodplains           [Ad]

AccumUpVar      = AccumStatus;
current_id      = ArcID_Downstream;
Posi            = find(ArcID == current_id);
PoPo(Posi)      = 1;
NumberBranches  = 1;

while NumberBranches == 1
    %        
    Npre            = Posi;
    Posi            = find(Arc_EndNode == Arc_InitNode( Posi)); 
    NumberBranches  = length(Posi);

    if NumberBranches > 1           
        for i = 1:NumberBranches 
            start_sub_id    = ArcID( Posi(i));

            [cum_vars, Vh,Ql,Rl, PoPo, PoPoFlood] = Network( ArcID, Arc_InitNode, Arc_EndNode, start_sub_id,...
                      AccumVar, AccumUpVar, ArcIDFlood, FloodArea, IDExt, IDRet, P, ETP,...
                      Vh,Ql, Rl,Trp,Tpr, Q_Umb, V_Umb, b, Y, PoPo, PoPoFlood, ArcID_Downstream2);

            AccumUpVar          = cum_vars;
            
            %% Extraction Demand
            AccumUpVar(Posi(i),1)       = AccumUpVar(Posi(i),1) - ( AccumUpVar(Posi(i),3:7).*IDExt(Posi(i),:) );
            AccumUpVar(Posi(i),3:7)     = AccumUpVar(Posi(i),3:7).*(~IDExt(Posi(i),:));

            %% Returns
            AccumUpVar(Posi(i),1)       = AccumUpVar(Posi(i),1) + ( AccumUpVar(Posi(i),8:11).*IDRet(Posi(i),:) );
            AccumUpVar(Posi(i),8:11)    = AccumUpVar(Posi(i),8:11).*(~IDRet(Posi(i),:));

            %% Model Flood Plains
            if sum(ArcIDFlood == ArcID(Posi(i))) == 1
                PoPoFlood(Posi(i)) = 1;
                nn      = find(ArcIDFlood == ArcID(Posi(i)));
                % [Q_Umb] mm -> m3
                [AccumUpVar(Posi(i),1), Vh(nn), Ql(nn), Rl(nn)] = Floodplains(P(Posi(i)),...
                    ETP(Posi(i)), AccumUpVar(Posi(i),1), FloodArea(nn), Vh(nn), Trp(nn), Tpr(nn),...
                    (Q_Umb(nn)/1000)*AccumUpVar(Posi(i),2) , V_Umb(nn), b(nn), Y(nn) );

            end
            
            %% AccumVar
            AccumUpVar(Npre,:)  = AccumUpVar(Npre,:) + cum_vars( Posi(i),:);
            
        end
        
        if ArcID_Downstream2 == ArcID(Npre)            
            %% Extraction Demand
            AccumUpVar(Npre,1)      = AccumUpVar(Npre,1) - ( AccumUpVar(Npre,3:7).*IDExt(Npre,:) );
            AccumUpVar(Npre,3:7)    = AccumUpVar(Npre,3:7).*(~IDExt(Npre,:));

            %% Returns
            AccumUpVar(Npre,1)      = AccumUpVar(Npre,1) + ( AccumUpVar(Npre,8:11).*IDRet(Npre,:) );
            AccumUpVar(Npre,8:11)   = AccumUpVar(Npre,8:11).*(~IDRet(Npre,:));
            
            %% Model Flood Plains
            if sum(ArcIDFlood == ArcID(Npre)) == 1
                PoPoFlood(Npre) = 1;
                nn      = find(ArcIDFlood == ArcID(Npre));
                [AccumUpVar(Npre,1), Vh(nn), Ql(nn), Rl(nn)] = Floodplains(P(Npre),...
                    ETP(Npre), AccumUpVar(Npre,1), FloodArea(nn), Vh(nn), Trp(nn), Tpr(nn),...
                    (Q_Umb(nn)/1000)*AccumUpVar(Npre,2), V_Umb(nn), b(nn), Y(nn) );

            end
        end
    end

end  

