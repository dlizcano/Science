function [DOR, DORw, Sed, Frag, varargout] = Impact_Tier1(Hp, DrenageOrderThreshold, NameVar, varargin)

% Parameters 
NameInput   = {'Hp.Network.ProVar','Hp.Network.AccumVar','Hp.Network.AccumClipVar',...
               'Hp.Network.LossRate','Hp.Network.AccumLossVar','Hp.Network.AccumLossClipVar'};

% Volume of water stored by the dam.
Esc_ArcID   = Hp.ArcID( logical(Hp.Scenario) );
[id, ~]     = ismember(Hp.ArcID, Esc_ArcID);
[~, posi]   = ismember(Hp.ArcID, Hp.Network.ArcID);

% Ignore Rpject that not find in the topological Network
Tmp         = posi(id);
Esc_ArcID   = Hp.Network.ArcID(Tmp(Tmp > 0));
[id, ~]     = ismember(Hp.ArcID, Esc_ArcID);
[~, posi]   = ismember(Hp.ArcID, Hp.Network.ArcID);

% Volumenes
Hp.Network.AccumVar                = zeros( length(Hp.Network.ArcID), 2);
Hp.Network.AccumVar(posi(id),1)    = Hp.TotalVolumen(id);

% Runoff of each River Seccion with dam
Hp.Network.ProVar                  = zeros( length(Hp.Network.ArcID), 1);
Hp.Network.ProVar(posi(id))        = Hp.Qmed(id);

% Contribution of Sediments (Ton/Years) - Scenario basic 
Hp.Network.AccumVar(:,2)           = eval(['Hp.Network.Variables.',NameVar{2}]);

Hp.Network.AccumLossVar            = zeros( length(Hp.Network.ArcID), 1);
Hp.Network.AccumLossVar(:,1)       = eval(['Hp.Network.Variables.',NameVar{2}]);

% Loss rate
Hp.Network.LossRate                = zeros( length(Hp.Network.ArcID), 1);
Hp.Network.LossRate(posi(id))      = Hp.LossRate(id);

% Barrier
Hp.Network.ArcBarrier              = zeros( length(Hp.Network.ArcID), 1);
Hp.Network.ArcBarrier(posi(id),1)  = Hp.ID(id);

if nargin > 6
    NumVar      = length(varargin);

    % Operation Mode of the AnalysisNetwork
    Hp.Network.Mode    = Mode;
    % ID of the of the AnalysisNetwork
    Hp.Network.CurrID  = CurrID;

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

%% Analysis Network
[FuncNetwork,ProVarOut,AccumVarOut,...
AccumClipVarOut,AccumLossVarOut,...
AccumClipLossVarOut, PoNet] = Analysis_Network(Hp.Network);

%% DOR (Degree Of Regulation)
% Factor : m3/(seg*year) -> m3
Factor      = 86400 * 365;            
DOR         = ( AccumVarOut(:,1)./(eval(['Hp.Network.Variables.',NameVar{1}]) * Factor) ).* 100;

%% DORw (Weighted Degree Of Regulation)
DORw        = DOR .* (ProVarOut ./ eval(['Hp.Network.Variables.',NameVar{1}]));

%% Index for Sediment                        
Sed    = ( 1 - (AccumLossVarOut./AccumVarOut(:,2)) ).*100;

%% Fragmentation
% Name Project
NumOrder    = sort(unique( eval(['Hp.Network.Variables.',NameVar{3}]) ));
NameIndex_Project   = {'ID_Project','ArcID','Total','Threshold'};
for k = 1:length(NumOrder)
    NameIndex_Project{4 + k} = ['Order_',num2str(NumOrder(k))];
end

IDFun       = sort(unique(FuncNetwork));
[id, posi]  = ismember(IDFun, Hp.ID);
Esc_ArcID   = Hp.ArcID(posi(id));
LenFrag     = zeros(length(IDFun), 2 + length(NumOrder));

NNN     = Hp.Name(posi(id));
Namef   = cell( length(NNN) + 1,1);
Namef{1} = 'First_River';
for i = 2:length(Namef)
    Namef{i} = strrep(NNN{i-1},' ','_');
end

LenDrenage_Umb = eval(['Hp.Network.Variables.',NameVar{4}]);
LenDrenage_Umb(eval(['Hp.Network.Variables.',NameVar{3}]) < DrenageOrderThreshold) = 0;

for j = 1:length(IDFun)
    
    ID_FN           = find(FuncNetwork == IDFun(j));
    Tmp             = eval(['Hp.Network.Variables.',NameVar{4},'( ID_FN )']);
    LenFrag(j,1)    = sum(Tmp(isnan(Tmp) == 0));
    Tmp             = LenDrenage_Umb( ID_FN );
    LenFrag(j,2)    = sum( Tmp(isnan(Tmp) == 0) );

    Order = eval(['Hp.Network.Variables.',NameVar{3},'( ID_FN )']);
    for k = 1:length(NumOrder)
        Tmp = eval(['Hp.Network.Variables.',NameVar{4},'( ID_FN( Order == NumOrder(k) ) )']);
        LenFrag(j,2 + k) = sum( Tmp(isnan(Tmp) == 0) );
    end

end

Frag    = array2table([IDFun, [0; Esc_ArcID], LenFrag],'VariableNames',NameIndex_Project, 'RowNames', Namef);
% OUTPUT DATA
% -------------------------------------------------------------
varargout{1} = FuncNetwork;
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
% Position Network
varargout{7} = PoNet;

end