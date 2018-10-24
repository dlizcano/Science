function [Sed, varargout]  = DegreeRegulation_Qs( Hp, NameVarQs, varargin)
% Properties Check 
PropertiesCheck(Hp.Network)

% Parameters 
NameInput   = {'Hp.Network.ProVar','Hp.Network.AccumVar','Hp.Network.AccumClipVar',...
               'Hp.Network.LossRate','Hp.Network.AccumLossVar','Hp.Network.AccumLossClipVar'};

% Volume of water stored by the dam.
Esc_ArcID   = Hp.ArcID( logical(Hp.Scenario) );
[id, ~]     = ismember(Hp.ArcID, Esc_ArcID);
[~, posi]   = ismember(Hp.ArcID, Hp.Network.ArcID);

% Ignore Rpject that not find in the topological Hp.Network
Tmp         = posi(id);
Esc_ArcID   = Hp.Network.ArcID(Tmp(Tmp > 0));
[id, ~]     = ismember(Hp.ArcID, Esc_ArcID);
[~, posi]   = ismember(Hp.ArcID, Hp.Network.ArcID);

% Contribution of Sediments (Ton/Years) - Scenario basic 
Hp.Network.AccumVar            = zeros( length(Hp.Network.ArcID), 1);
Hp.Network.AccumVar(:,1)       = eval(['Hp.Network.Variables.',NameVarQs]);

Hp.Network.AccumLossVar        = zeros( length(Hp.Network.ArcID), 1);
Hp.Network.AccumLossVar(:,1)   = eval(['Hp.Network.Variables.',NameVarQs]);

% Loss rate
Hp.Network.LossRate            = zeros( length(Hp.Network.ArcID), 1);
Hp.Network.LossRate(posi(id))  = Hp.LossRate(id);

%             Tmp = log10(Hp.TotalVolumen(id)./(Hp.Qmed(id).*86400.*365));
%             Hp.Network.LossRate(posi(id)) = 100.*((0.97.^(0.19.^Tmp)));

% Barrier
Hp.Network.ArcBarrier              = zeros( length(Hp.Network.ArcID), 1);
Hp.Network.ArcBarrier(posi(id),1)  = Hp.ID(id);

if nargin > 5
    NumVar      = length(varargin);

    % Operation Mode of the AnalysisHp.Network
    Hp.Network.Mode    = 1;
    % ID of the of the AnalysisHp.Network
    Hp.Network.CurrID  = 0;

    % Configuration input data 
    if (NumVar > 0)
        for i = 1:NumVar
            if ~isempty( varargin{i} )
                Tmp = NameInput{i};
                for j = 1:length( varargin{i} )
                    Tmp = [Tmp,',', ['Hp.Network.Variables.',varargin{i}{j}] ];
                end
                eval( [NameInput{i},' = [', Tmp, '];'] )
            end
        end
    end
end

% Analysis Hp.Network
[FuncHp.Network,ProVarOut,AccumVarOut,...
 AccumClipVarOut,AccumLossVarOut,...
 AccumClipLossVarOut, PoNet] = Analysis_Network(Hp.Network);

%% Index for Sediment
Sed    = ( 1 - (AccumLossVarOut./AccumVarOut(:,1)) ).*100;

% OUTPUT DATA
% -------------------------------------------------------------
varargout{1} = FuncHp.Network;
% ProVarOut
varargout{2} = ProVarOut;
% AccumVarOut
varargout{3} = AccumVarOut;
% AccumClipVarOut
varargout{4} = AccumClipVarOut;
% AccumLossVarOut
varargout{5} = AccumLossVarOut;
% AccumClipLossVarOut
varargout{6} = AccumClipLossVarOut;   
% Position Hp.Network
varargout{7} = PoNet; 

end