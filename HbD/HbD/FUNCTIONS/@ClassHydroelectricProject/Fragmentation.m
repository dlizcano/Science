function [Frag,varargout] = Fragmentation(Hp, DrenageOrderThreshold, NameVarDrenage, varargin)
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

% Barrier
Hp.Network.ArcBarrier = zeros( length(Hp.Network.ArcID), 1);
Hp.Network.ArcBarrier(posi(id),1)   = Hp.ID(id);

if nargin > 6
    NumVar      = length(varargin);

    % Operation Mode of the AnalysisHp.Network
    Hp.Network.Mode    = Mode;
    % ID of the of the AnalysisHp.Network
    Hp.Network.CurrID  = CurrID;

    % Configuration input data 
    if (NumVar > 0)
        for i = 1:NumVar
            if ~isempty( varargin{i} )
                Tmp = ['Hp.Network.Variables.',varargin{i}{1}];
                for j = 2:length( varargin{i} )
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

%% Fragmentation
% Name Project
NumOrder    = sort(unique( eval(['Hp.Network.Variables.',NameVarDrenage{2}]) ));
NameIndex_Project   = {'ID_Project','ArcID','Total','Threshold'};
for k = 1:length(NumOrder)
    NameIndex_Project{4 + k} = ['Order_',num2str(NumOrder(k))];
end

IDFun       = sort(unique(FuncHp.Network));
[id, posi]  = ismember(IDFun, Hp.ID);
Esc_ArcID   = Hp.ArcID(posi(id));
LenFrag     = zeros(length(IDFun), 2 + length(NumOrder));

LenDrenage_Umb = eval(['Hp.Network.Variables.',NameVarDrenage{1}]);
LenDrenage_Umb(eval(['Hp.Network.Variables.',NameVarDrenage{2}]) < DrenageOrderThreshold) = 0;

for j = 1:length(IDFun)

    ID_FN           = find(FuncHp.Network == IDFun(j)); 
    LenFrag(j,1)    = nansum( eval(['Hp.Network.Variables.',NameVarDrenage{1},'( ID_FN )']) );
    LenFrag(j,2)    = nansum( LenDrenage_Umb( ID_FN ) );

    Order = eval(['Hp.Network.Variables.',NameVarDrenage{2},'( ID_FN )']);
    for k = 1:length(NumOrder)
        LenFrag(j,2 + k) = nansum( eval(['Hp.Network.Variables.',NameVarDrenage{1},'( ID_FN( Order == NumOrder(k) ) )']) );
    end

end

Frag    = array2table([IDFun, [0; Esc_ArcID], LenFrag],'VariableNames',NameIndex_Project);
        
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