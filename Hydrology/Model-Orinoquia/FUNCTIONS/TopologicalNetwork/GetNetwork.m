function [PoPo, PoPoFlood] = GetNetwork( ArcID, Arc_InitNode, Arc_EndNode, ArcID_Downstream, PoPo, PoPoFlood, ArcIDFlood)
% /usr/bin/Matlab-R2016b
% -------------------------------------------------------------------------
% Original Author: Hector Angarita, 2015 Version 3.Beta;  Email: flector@gmail.com
%
% -------------------------------------------------------------------------
% BASE DATA 
% -------------------------------------------------------------------------
% Project               : Landscape planning for agro-industrial expansion 
%                         in a large, well-preserved savanna: how to plan 
%                         multifunctional landscapes at scale for nature and 
%                         people in the Orinoquia region, Colombia
% Modified              : Jonathan Nogales Pimentel
% Email                 : nogales02@hotmail.com
% Supervisor            : Carlos Andrés Rogéliz
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
%   ArcID               [n,1] = ID of each section of the network                                                   [Ad]
%   Arc_InitNode        [n,1] = Initial node of each section of the network                                         [Ad]
%   Arc_EndNode         [n,1] = End node of each section of the network                                             [Ad]
%   ArcID_Downstream    [n,1] = ID of the end node of accumulation                                                  [Ad]
%   PoPo                [n,1] = ID of each section of the network upstream of the ArcID_Downstream                  [Ad]
%   PoPoFlood           [n,1] = ID of each section of the network upstream of the ArcID_Downstream with floodplains [Ad]
%   IDFlood             [n,1] = ID of the section of the network with floodplain                                    [Ad]
%
% -------------------------------------------------------------------------
% OUTPUT DATA
% -------------------------------------------------------------------------
%   PoPo                [n,1] = ID of each section of the network upstream of the ArcID_Downstream                  [Ad]
%   PoPoFlood           [n,1] = ID of each section of the network upstream of the ArcID_Downstream with floodplains [Ad]

current_id      = ArcID_Downstream;
Posi            = find(ArcID == current_id);
PoPo(Posi)      = 1;
NumberBranches  = 1;

while NumberBranches == 1
    Npre            =  Posi;
    Posi            = find(Arc_EndNode == Arc_InitNode( Posi)); 
    NumberBranches  = length(Posi);

    if NumberBranches > 1           
        for i = 1:NumberBranches 
            start_sub_id        = ArcID( Posi(i));
            [PoPo, PoPoFlood]   = GetNetwork( ArcID, Arc_InitNode, Arc_EndNode, start_sub_id, PoPo, PoPoFlood, ArcIDFlood);
            
        end
    end
    
    if sum(ArcIDFlood == ArcID(Npre)) == 1
        PoPoFlood(ArcIDFlood == ArcID(Npre)) = 1;
    end
    
end  