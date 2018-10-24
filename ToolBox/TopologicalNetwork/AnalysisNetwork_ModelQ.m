function [Qcor] = AnalysisNetwork_ModelQ(UserData)
% -------------------------------------------------------------------------
% /usr/bin/Matlab-R2016b
% -------------------------------------------------------------------------
% Functional-Branch - 2015 Version 3.Beta;
% -------------------------------------------------------------------------
% BASE DATA 
% -------------------------------------------------------------------------
% Author            : Hector Angarita  
% Email             : flector@gmail.com
% Modified by       : Jonathan Nogales Pimentel - Jonathan.nogales@tnc.org
%                     Carlos Andres Rog�liz - carlos.rogeliz@tnc.org
% Company           : The Nature Conservancy - TNC
% 
% Please do not share without permision of the autor
% -------------------------------------------------------------------------
% Description 
% -------------------------------------------------------------------------
% Function that calculates: Fragmentation, Accumulation and Propagation of a 
% topological fluvial network. These analyzes allow us to characterize the 
% fluvial network, to later evaluate the cumulative impacts of a set of 
% infrastructure works such as reservoirs, dams, etc., located in a fluvial 
% network, in terms of loss of Free Rivers, effects downstream by modification 
% of the regime of flows and sediments, among others.
%
% -------------------------------------------------------------------------
% License
% -------------------------------------------------------------------------
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
% INPUTS DATA
% -------------------------------------------------------------------------
% UserData [Struct]
%   .ArcID              [n,1] = ID of the River Sections (Ad)
%   .FromNode           [n,1] = Initial Node of the River Sections (Ad)
%   .ToNode             [n,1] = End Node of the River Sections (Ad)
%   .ArcID_RM           [1,1] = ArcID of the River Sections corresponding to the River Mouth (Ad)
%   .ProVar             [n,w] = Variables to Propagate
%   .Qsim           [n,m] = Variables to Accumulate
%   .AccumClipVar       [n,k] = Variables to Accumulate with Clipping
%   .AccumLossVar       [n,h] = Variables to Accumulate with Losses
%   .AccumLossClipVar   [n,l] = Variables to Accumulate with Losses and Clipping
%   .ArcBarrier         [n,1] = ArcID of the River Sections with Barriers (Ad)
%   .CurrID             [1,1] = ID of the Functional Network.                                      
%   .ArcLossRate        [n,1] = Loss Rate (%)
%
% -------------------------------------------------------------------------
% OUTPUTS DATA
% -------------------------------------------------------------------------
%   FuncNetwork         [n,1] = ID of the Functional Network by Barrier. 
%   ProVarOut           [n,w] = Propagated Variables
%   QsimOut         [n,m] = Cumulative Variables
%   AccumClipVarOut     [n,h] = Cumulative Variables With Clipping
%   AccumLossVarOut     [n,k] = Cumulative Variables With Losses
%   AccumLossClipVarOut [n,h] = Cumulative Variables With Losses and Clipping
%   PoNet               [n,1] = Position of the Network in one River Sections Special

%% CHECKS INPUT DATA
if nargin < 1, error('Not enough input data'), end

%% INPUT DATA 
if isfield(UserData,'ArcID'),               ArcID               = UserData.ArcID;               else, error('The varaible ArcID was not found'),    end 
if isfield(UserData,'FromNode'),            FromNode            = UserData.FromNode;            else, error('The varaible FromNode was not found'), end
if isfield(UserData,'ToNode'),              ToNode              = UserData.ToNode;              else, error('The varaible ToNode was not found'),   end
if isfield(UserData,'ArcID_RM'),            ArcID_RM            = UserData.ArcID_RM;            else, error('The varaible ArcID_RM was not found'), end
if isfield(UserData,'Q'),                   Q                   = UserData.Q;                   else, Q          = []; end

clearvars UserData

%% FunctionalBranch
% Position Network

[Qcor]    = FunctionalBranch( ArcID, FromNode, ToNode, ArcID_RM,...
                                        Q, Q, ArcID_RM);

end

%% FunctionalBranch
%--------------------------------------------------------------------------
function [QsimOut]  = FunctionalBranch(   ArcID, FromNode, ToNode, ArcID_RM,...
                                        Qsim, Qsim_Tmp,...
                                        ArcID_RM_i)
% -------------------------------------------------------------------------                    
% Variables to Accumulate
QsimOut             = Qsim_Tmp; 
% Position of the Current ArcID
Posi                = find(ArcID == ArcID_RM);
% Branch Number
NumBranch           = 1;

while (NumBranch == 1)

    
    Npre = Posi;
    
    % keeps going upstream
    Posi = find(ToNode == FromNode(Posi)); 
    
    try
        Posi1   = find(ToNode == FromNode(Posi));
    catch
        Posi1 = [0 1 0 1];
    end
    
    NumBranch   = length(Posi);
    
    if NumBranch == 0
        Posi1 = [];
    end
    
    if (NumBranch == 1  && isempty(Posi1))
        
        % Branch Number
        NumBranch = 0;
        
    elseif (NumBranch > 1  || ~isempty(Posi1)) || (NumBranch == 1  || isempty(Posi1))
        
        %% Abajo hacia Arriba
        if NumBranch >= 2
            Qb      = NaN(2,1);
            for i = 1:NumBranch 
                Qb(i)  = Qsim(Posi(i));
            end
            
            if QsimOut(Npre) < sum(Qb)
                Dif     = sum(Qb) - QsimOut(Npre);                
                for i = 1:NumBranch 
                    Factor = QsimOut(Posi(i))/(sum(Qb) + QsimOut(Npre));
                    QsimOut(Posi(i)) = QsimOut(Posi(i)) - (Dif*Factor);
                end
                
                Factor = QsimOut(Npre,:)/(sum(Qb) + QsimOut(Npre));
                QsimOut(Npre) = QsimOut(Npre) + (Dif*Factor);
            end
            
        end
        
        for i = 1:NumBranch 
            New_ArcID_RM = ArcID(Posi(i));
            
            %% Functional Branch
            [Qsim_i] = FunctionalBranch(  ArcID, FromNode, ToNode,...
                                        New_ArcID_RM, Qsim, QsimOut, ArcID_RM_i);  
            QsimOut = Qsim_i;
            % arriba hacia abajo
%             Qb(i)  = Qsim_i(Posi(i));
            
            % Branch Number
            if NumBranch == 1
                NumBranch = 0;
            end
        end
        
        %% Arriba hacia abajo
%         if NumBranch >= 2
%             Qb      = NaN(2,1);
%             for i = 1:NumBranch 
%                 Qb(i)  = Qsim(Posi(i));
%             end
%             
%             if QsimOut(Npre) < sum(Qb)
%                 Dif     = sum(Qb) - QsimOut(Npre);                
%                 for i = 1:NumBranch 
%                     Factor = QsimOut(Posi(i))/(sum(Qb) + QsimOut(Npre));
%                     QsimOut(Posi(i)) = QsimOut(Posi(i)) - (Dif*Factor);
%                 end
%                 
%                 Factor = QsimOut(Npre,:)/(sum(Qb) + QsimOut(Npre));
%                 QsimOut(Npre) = QsimOut(Npre) + (Dif*Factor);
%             end
%             
%         end
        
    end
       
    % Break While
    % -------------------------------------------------------------------------
    if Npre == ArcID_RM_i
        break
    end
    
end 

end
