function [FuncNetwork, varargout] = AnalysisNetwork(UserData)
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
%   .AccumVar           [n,m] = Variables to Accumulate
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
%   AccumVarOut         [n,m] = Cumulative Variables
%   AccumClipVarOut     [n,h] = Cumulative Variables With Clipping
%   AccumLossVarOut     [n,k] = Cumulative Variables With Losses
%   AccumLossClipVarOut [n,h] = Cumulative Variables With Losses and Clipping
%   PoNet               [n,1] = Position of the Network in one River Sections Special

%% CHECKS INPUT DATA
if nargin < 1, error('Not enough input data'), end

%% INPUT DATA 
if isfield(UserData,'Mode'),                Mode                = UserData.Mode;                else, error('The varaible Mode was not found'),     end 
if isfield(UserData,'ArcID'),               ArcID               = UserData.ArcID;               else, error('The varaible ArcID was not found'),    end 
if isfield(UserData,'FromNode'),            FromNode            = UserData.FromNode;            else, error('The varaible FromNode was not found'), end
if isfield(UserData,'ToNode'),              ToNode              = UserData.ToNode;              else, error('The varaible ToNode was not found'),   end
if isfield(UserData,'ArcID_RM'),            ArcID_RM            = UserData.ArcID_RM;            else, error('The varaible ArcID_RM was not found'), end
if isfield(UserData,'PoNet'),               PoNet               = UserData.PoNet;               else, PoNet = zeros(length(ArcID),1);               end
if isfield(UserData,'ProVar'),              ProVar              = UserData.ProVar;              else, ProVar            = []; end
if isfield(UserData,'AccumVar'),            AccumVar            = UserData.AccumVar;            else, AccumVar          = []; end
if isfield(UserData,'AccumClipVar'),        AccumClipVar        = UserData.AccumClipVar;        else, AccumClipVar      = []; end
if isfield(UserData,'AccumLossVar'),        AccumLossVar        = UserData.AccumLossVar;        else, AccumLossVar      = []; end
if isfield(UserData,'AccumClipLossVar'),    AccumClipLossVar    = UserData.AccumClipLossVar;    else, AccumClipLossVar  = []; end
if isfield(UserData,'ArcBarrier'),          ArcBarrier          = UserData.ArcBarrier;          else, ArcBarrier        = zeros(length(ArcID ),1);  end
if isfield(UserData,'CurrID'),              CurrID              = UserData.CurrID;              else, CurrID            = 0;  end
if isfield(UserData,'LossRate'),            LossRate            = UserData.LossRate;            else, LossRate          = []; end
    
%% VERIFICATION OF THE CONSISTENCY IN THE INPUT DATA
if ~isempty(AccumLossVar) && isempty(LossRate) && (Mode==1),         error('inconsistency in variables with Losses'), end
if ~isempty(AccumClipLossVar) && isempty(LossRate) && (Mode==1),     error('inconsistency in variables with Losses and Clipping'), end
if (isempty(AccumClipLossVar) && isempty(AccumLossVar)) && ~isempty(LossRate) && (Mode==1),     error('inconsistency in variables with Losses and Clipping'), end

clearvars UserData

%% FunctionalBranch
if Mode == 0
    PoNet_i     = zeros(length(ArcID),1);
    [FuncNetwork, PoNet_i] = FunB_GetNetwork(ArcID, FromNode, ToNode, ArcID_RM, ArcID_RM, PoNet, PoNet_i);
    
    varargout{1} = PoNet_i;
    
else
    % Position Network
    [FuncNetwork,O1,O2,O3,O4,O5,O6] = FunctionalBranch( ArcID, FromNode, ToNode, ArcID_RM,...
                                            ProVar, ProVar, ... 
                                            AccumVar, AccumVar,...
                                            AccumClipVar, AccumClipVar,...
                                            AccumLossVar, AccumLossVar,...
                                            AccumClipLossVar, AccumClipLossVar,...
                                            ArcBarrier, CurrID, ...
                                            LossRate, ArcID_RM, PoNet);

    %% OUTPUT DATA
    % ProVarOut
    varargout{1} = O1;
    % AccumVarOut
    varargout{2} = O2;
    % AccumClipVarOut
    varargout{3} = O3;
    % AccumLossVarOut
    varargout{4} = O4;
    % AccumClipLossVarOut
    varargout{5} = O5;   
    % Position Network
    varargout{6} = O6; 
end

end

%% FunctionalBranch
%--------------------------------------------------------------------------
function [  FuncNetwork,...
            ProVarOut,...
            AccumVarOut,...
            AccumClipVarOut,...
            AccumLossVarOut,...
            AccumClipLossVarOut,...
            PoNet] = ...
            FunctionalBranch(   ArcID, FromNode, ToNode, ArcID_RM,...
                                ProVar, ProVarTmp, ... 
                                AccumVar, AccumVarTmp,...
                                AccumClipVar, AccumClipVarTmp,...
                                AccumLossVar, AccumLossVarTmp,...
                                AccumClipLossVar, AccumClipLossVarTmp,...
                                ArcBarrier, CurrID,...
                                LossRate, ArcID_RM_i, PoNet)
% -------------------------------------------------------------------------                    
FuncNetwork         = 0 * ArcID;
% Variables to Propagated
ProVarOut           = ProVarTmp;
% Variables to Accumulate
AccumVarOut         = AccumVarTmp; 
% Variables to Propagate
AccumClipVarOut     = AccumClipVarTmp;
% Variables to Degration
AccumLossVarOut     = AccumLossVarTmp;
% Variables to Propagate and Degration
AccumClipLossVarOut = AccumClipLossVarTmp;
% Current ArcID
CurrentID           = ArcID_RM;
% Position of the Current ArcID
Posi                = find(ArcID == CurrentID);
% Position Network
PoNet(Posi)         = 1;
% Branch Number
NumBranch           = 1;

while (NumBranch == 1)

    FuncNetwork(Posi) = CurrID;
    
    if (ArcBarrier(Posi) > 0)                      
        % a barrier was found, a new functional network must be assigned to upstream reaches:
        CurrIDOut = ArcBarrier(Posi);         
    else
        % uses barrier_id as network_id for upstream network
        CurrIDOut = CurrID;
    end
    
    Npre = Posi;
    
    % keeps going upstream
    Posi = find(ToNode == FromNode(Posi)); 
            
    try
        Posi1   = find(ToNode == FromNode(Posi));
        Posi2   = find(ToNode == FromNode(Posi1));
    catch
        Posi1 = [0 1 0 1];
        Posi2 = [0 1 0 1];
    end
    
    NumBranch   = length(Posi);
    
    if length(Posi) == 1 && isempty(Posi2)
        if (ArcBarrier(Posi) > 0)                      
            % a barrier was found, a new functional network must be assigned to upstream reaches:
            CurrIDOut = ArcBarrier(Posi);         
        else
            % uses barrier_id as network_id for upstream network
            CurrIDOut = CurrID;
        end
    end
    
    if NumBranch == 0
        Posi1 = [];
    end
    
    if (NumBranch == 1  && isempty(Posi1))
        
        % Position Network
        % -------------------------------------------------------------------------
        PoNet(Posi)       = 1;

        % Functional Network
        % -------------------------------------------------------------------------
        FuncNetwork(Posi) = CurrID;
        
        % Variables to Propagated
        % -------------------------------------------------------------------------
        if ~isempty(ProVarTmp)
            ProVarOut                   = ProVarTmp;
            ProVarOut(Npre,:)           = ProVarOut(Npre,:) + ProVarTmp(Posi,:);  
        end

        % Variables to Accumulate
        % -------------------------------------------------------------------------
        if ~isempty(AccumVarTmp)
            AccumVarOut                 = AccumVarTmp;
            AccumVarOut(Npre,:)         = AccumVarOut(Npre,:) + AccumVarTmp(Posi,:);
        end

        % Variables to Accumulate With Clipping
        % -------------------------------------------------------------------------
        if ~isempty(AccumClipVarTmp)
            AccumClipVarOut             = AccumClipVarTmp;
            AccumClipVarOut(Npre,:)     = AccumClipVarOut(Npre,:) + AccumClipVarTmp(Posi,:);
        end

        % Variables to Accumulate With Losses
        % -------------------------------------------------------------------------
        if ~isempty(AccumLossVarTmp)
            AccumLossVarOut             = AccumLossVarTmp;
            AccumLossVarOut(Npre,:)     = (AccumLossVarOut(Npre,:) + AccumLossVarTmp(Posi,:));
        end

        % Variables to Accumulate With Clipping and Losses
        % -------------------------------------------------------------------------
        if ~isempty(AccumClipLossVarTmp)
            AccumClipLossVarOut         = AccumClipLossVarTmp;
            AccumClipLossVarOut(Npre,:) = (AccumClipLossVarOut(Npre,:) + AccumClipLossVarTmp(Posi,:));
        end
        
        % Branch Number
        NumBranch = 0;
        
    elseif (NumBranch > 1  || ~isempty(Posi1)) || (NumBranch == 1  || isempty(Posi1))
        for i = 1:NumBranch 
            New_ArcID_RM = ArcID(Posi(i));
            
            %% Functional Branch
            [FuncNetwork_i,...
            ProVar_i,...
            AccumVar_i,...
            AccumClipVar_i,...
            AccumLossVar_i,...
            AccumClipLossVar_i,...
            PoNet] = ...
            FunctionalBranch(  ArcID, FromNode, ToNode, New_ArcID_RM,...                         
                                 ProVar, ProVarOut, ...
                                 AccumVar, AccumVarOut, ... 
                                 AccumClipVar, AccumClipVarOut,...
                                 AccumLossVar, AccumLossVarOut,...
                                 AccumClipLossVar, AccumClipLossVarOut,...
                                 ArcBarrier, CurrIDOut,... 
                                 LossRate, ArcID_RM_i, PoNet);
            
            % Functional Network
            % -------------------------------------------------------------------------
            FuncNetwork                     = FuncNetwork + FuncNetwork_i;
            
            % Variables to Propagated
            % -------------------------------------------------------------------------
            if ~isempty(ProVar_i)
                ProVarOut                   = ProVar_i;
                ProVarOut(Npre,:)           = ProVarOut(Npre,:) + ProVar_i(Posi(i),:);  
            end
            
            % Variables to Accumulate
            % -------------------------------------------------------------------------
            if ~isempty(AccumVar_i)
                AccumVarOut                 = AccumVar_i;
                AccumVarOut(Npre,:)         = AccumVarOut(Npre,:) + AccumVar_i(Posi(i),:);
            end
            
            % Variables to Accumulate With Clipping
            % -------------------------------------------------------------------------
            if ~isempty(AccumClipVar_i)
                AccumClipVarOut             = AccumClipVar_i;
                AccumClipVarOut(Npre,:)     = AccumClipVarOut(Npre,:) + AccumClipVar_i(Posi(i),:);
            end
            
            % Variables to Accumulate With Losses
            % -------------------------------------------------------------------------
            if ~isempty(AccumLossVar_i)
                AccumLossVarOut             = AccumLossVar_i;
                AccumLossVarOut(Npre,:)     = (AccumLossVarOut(Npre,:) + AccumLossVar_i(Posi(i),:));
            end
            
            % Variables to Accumulate With Clipping and Losses
            % -------------------------------------------------------------------------
            if ~isempty(AccumClipLossVar_i)
                AccumClipLossVarOut         = AccumClipLossVar_i;
                AccumClipLossVarOut(Npre,:) = (AccumClipLossVarOut(Npre,:) + AccumClipLossVar_i(Posi(i),:));
            end
            
            % Branch Number
            if NumBranch == 1
                NumBranch = 0;
            end
        end
    end
    
    % Variables to Accumulate With Losses
    % -------------------------------------------------------------------------
    if ~isempty(AccumLossVarOut)
        AccumLossVarOut(Npre,:) = AccumLossVarOut(Npre,:) * (1 - (LossRate(Npre)/100));
    end
    
    % Variables to Accumulate With Clipping
    % -------------------------------------------------------------------------
    if ~isempty(AccumClipVar)
        if (ArcBarrier(Npre) > 0)                      
            % a barrier was found, resets river network accumulation:
            AccumClipVarOut(Npre,:) = AccumClipVar(Npre,:);
        end
    end
    
    % Variables to Accumulate With Clipping and Losses
    % ------------------------------------------------------------------------
    if ~isempty(AccumClipLossVar)
        AccumClipLossVarOut(Npre,:) = AccumClipLossVarOut(Npre,:) * (1 - (LossRate(Npre)/100));
        if (ArcBarrier(Npre) > 0) 
            AccumClipLossVarOut(Npre,:) = AccumClipLossVar(Npre,:);
        end
    end
    
    % Variables to Propagated
    % -------------------------------------------------------------------------
    if ~isempty(ProVar)
        if (ProVar(Npre) > 0)
            ProVarOut(Npre) = ProVar(Npre);
        end
    end
    
    % Break While
    % -------------------------------------------------------------------------
    if Npre == ArcID_RM_i
        break
    end
    
end 

end


%% GetNetwork
%--------------------------------------------------------------------------
function [PoNet, PoNet_i ] = FunB_GetNetwork(   ArcID, FromNode, ToNode, ArcID_RM, ArcID_RM_i, PoNet, PoNet_i)
% -------------------------------------------------------------------------                    
% Position of the Current ArcID
Posi                = find(ArcID == ArcID_RM);
% Position Network
PoNet(Posi)         = 1;
% Position Network
PoNet_i(Posi)       = 1;
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
        
        % Position Network
        % -------------------------------------------------------------------------
        PoNet(Posi) = 1;
        
        PoNet_i(Posi) = 1;
        
        % Branch Number
        NumBranch   = 0;
        
    elseif (NumBranch > 1  || ~isempty(Posi1)) || (NumBranch == 1  || isempty(Posi1))
        for i = 1:NumBranch 
            New_ArcID_RM = ArcID(Posi(i));
            
            %% Functional Branch
            [PoNet, PoNet_i] = FunB_GetNetwork(  ArcID, FromNode, ToNode, New_ArcID_RM, ArcID_RM_i, PoNet, PoNet_i);
            
            % Branch Number
            if NumBranch == 1
                NumBranch = 0;
            end
            
        end
    end
    
    % Break While
    % -------------------------------------------------------------------------
    if Npre == ArcID_RM_i
        break
    end
    
end 

end