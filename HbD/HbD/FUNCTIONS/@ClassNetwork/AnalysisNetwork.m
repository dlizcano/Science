function [FuncNetwork, varargout] = AnalysisNetwork(Network, Mode, CurrID, varargin)
% -------------------------------------------------------------
% INPUTS DATA
% -------------------------------------------------------------
% NameVar2Pro           = Name varaibles to Progate
% NameVar2Accum         = Name varaibles to Acumulated
% NameVar2AccumClip     = Name varaibles to Accumulate with Clipping
% Loss Rate             = Name varaibles with Loss Rate (%)
% NameVar2AccumLoss     = Name varaibles to Accumulate with Losses
% NameVar2AccumClipLoss = Name varaibles to Accumulate with Losses and Clipping
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

% -------------------------------------------------------------
% Properties Check
PropertiesCheck(Network)

% Parameters 
NameInput   = {'Network.ProVar','Network.AccumVar','Network.AccumClipVar',...
               'Network.LossRate','Network.AccumLossVar','Network.AccumLossClipVar'};

NumVar      = length(varargin);

% Operation Mode of the AnalysisNetwork
Network.Mode    = Mode;
% ID of the of the AnalysisNetwork
Network.CurrID  = CurrID;

% Configuration input data 
if (NumVar > 0)
    for i = 1:NumVar
        if ~isempty( varargin{i} )
            Tmp = ['Network.Variables.',varargin{i}{1}];
            for j = 2:length( varargin{i} )
                Tmp = [Tmp,',', ['Network.Variables.',varargin{i}{j}] ];
            end
            eval( [NameInput{i},' = [', Tmp, '];'] )
        end
    end
end

if Network.Mode
    [FuncNetwork,O1,O2,O3,O4,O5,O6] = Analysis_Network(Network);

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
else 
    [FuncNetwork, PoNet_i] = Analysis_Network(Network);
    
    varargout{1} = PoNet_i;
end

end