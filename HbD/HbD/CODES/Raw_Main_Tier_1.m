% -------------------------------------------------------------------------
% /usr/bin/Matlab-R2016b
% -------------------------------------------------------------------------
% TIR-1
% -------------------------------------------------------------------------
% BASE DATA 
% -------------------------------------------------------------------------
% Author            : Hector Angarita  
% Email             : flector@gmail.com
% Modified by       : Jonathan Nogales Pimentel - Jonathan.nogales@tnc.org
%                     Carlos Andres Rogéliz - carlos.rogeliz@tnc.org
% Company           : The Nature Conservancy - TNC
% 
% Please do not share without permision of the autor
% -------------------------------------------------------------------------
% Description 
% -------------------------------------------------------------------------
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
% -------------------------------------------------------------------------
% OUTPUTS DATA
% -------------------------------------------------------------------------
clear, clc 

%% Add Repository
PathRepository = '/media/nogales/NogalesBackup/TNC/TNC-Tools/Tools/Matlab';
addpath(genpath(PathRepository))

%% INPUT DATA
% Name Project
UserData.NameProject                    = 'Cornare';
% Path Project
UserData.Path_Project                   = '/media/nogales/NogalesBackup/TNC/TNC-Tools/Project/HbD';
% Main 
UserData.Path_MasterHbD                 = 'Params_HbD.xlsx';
% Basic Data 
UserData.Path_DataHbD                   = 'Basic_HbD_8916_BC.csv';
% Random scenarios
UserData.Params_EscRandom               = '0';
% River Mouth - Magdalena-Cauca
UserData.Params_ArcID_RM                = 11;
% Drenage Order Threshold
UserData.Params_DrenageOrderThreshold   = 4;
% Scenarios Random - Threshold
UserData.Params_ThresholdComb           = 1000;

%% ADD FUNCTIONS
addpath(genpath(fullfile(UserData.Path_Project,'FUNCTIONS')))

%% Create Folder 
mkdir(fullfile(UserData.Path_Project,'RESULTS','HbD',['ArcID_',num2str(UserData.Params_ArcID_RM)],'HbD_TopologicalNetwork'))
mkdir(fullfile(UserData.Path_Project,'RESULTS','HbD',['ArcID_',num2str(UserData.Params_ArcID_RM)],'HbD_Project'))
mkdir(fullfile(UserData.Path_Project,'RESULTS','HbD','Summary'))

%% Parameters
Umb_DOR     = [0, 2,  5, 10, 15, 25, 50, 100];
Umb_Sed     = [0, 5, 15, 25, 50, 100];
Umb_Elev    = [(100:100:3100) 10000];

%% LOAD DATA
% -------------------------------------------------------------------------
% Hydroelectric Projects
% -------------------------------------------------------------------------
Tmp = xlsread(fullfile(UserData.Path_Project,'DATA','Params',UserData.Path_MasterHbD),'Hydro');
Tmp = Tmp(5:end,:);

Hp_Data.ID             = Tmp(:,1);
Hp_Data.CoorX          = Tmp(:,4);
Hp_Data.CoorY          = Tmp(:,5);
Hp_Data.ArcID          = Tmp(:,6);
Hp_Data.TotalVol       = Tmp(:,7);
Hp_Data.InstallPower   = Tmp(:,8);
Hp_Data.HigthDam       = Tmp(:,9);
Hp_Data.Qmed           = Tmp(:,10);
Hp_Data.LossRate       = Tmp(:,11);
Hp_Data.Esc_BaseLine   = Tmp(1:length(Hp_Data.ID),12);
Hp_Data.Esc_Random     = Tmp(1:length(Hp_Data.ID),13);
Hp_Data.Esc_Other      = Tmp(1:length(Hp_Data.ID),14:end);

% -------------------------------------------------------------------------
% Regional analysis
% -------------------------------------------------------------------------
[Tmp, TmpT] = xlsread(fullfile(UserData.Path_Project,'DATA','Params',UserData.Path_MasterHbD),'ArcInterest');
Hp_Data.ArcInter = Tmp;

% -------------------------------------------------------------------------
% Topological Network
% -------------------------------------------------------------------------
Tmp = dlmread(fullfile(UserData.Path_Project,'DATA','HbD',UserData.Path_DataHbD),',',1,0);
[~, id] = sort(Tmp(:,1)); Tmp = Tmp(id,:);

n = length(Tmp(:,1));
Network_Data.AccumClipVar       = zeros(n, 2);
Network_Data.ProVar             = zeros(n, 1);
Network_Data.ArcBarrier         = zeros(n, 1);
Network_Data.LossRate           = zeros(n, 1);

% Mode
Network_Data.Mode               = 1;
% ArcID
Network_Data.ArcID              = Tmp(:,1);
% From Node 
Network_Data.FromNode           = Tmp(:,2);
% To Node
Network_Data.ToNode             = Tmp(:,3);
% Average elevation (msnm)
Network_Data.BasinElevAve       = Tmp(:,4);
% Drenage Order 
Network_Data.DrenageOrder       = Tmp(:,5);
% Dreange Legenth (Km)
Network_Data.LenDrenage         = Tmp(:,6);
% Hydrological - Streamflow Annual(m3/seg)
Network_Data.QL_Year            = Tmp(:,7);
% Contribution of Sediments (Ton/Years) - Scenario basic 
Network_Data.AccumVar(:,1)      = Tmp(:,8);
% Contribution of Sediments (Ton/Years) - Scenario With dams
Network_Data.AccumLossVar(:,1)  = Tmp(:,8);

%% Name resuts 
% Name Project
NumOrder    = sort(unique( Network_Data.DrenageOrder ));
NameIndex_Project   = {'ID_Project','ArcID','Total','Threshold'};
for k = 1:length(NumOrder)
    NameIndex_Project{4 + k} = ['Order_',num2str(NumOrder(k))];
end

% Name Network 
NameIndex_Network   = {'ArcID','DOR','DORw','Index_Sed'};

% Name Summary 
NameSummary = {'Scenario','Total_Fragmentation', 'Threshold_Fragmentation'}; 
Cont = 4;
for k = 1:(length(Umb_DOR) - 1)
    NameSummary{Cont}   = ['LenDre_DOR_',num2str(Umb_DOR(k)),'_',num2str(Umb_DOR(k+1))];   
    Cont = Cont + 1;
    NameSummary{Cont}   = ['LenDre_DORw_',num2str(Umb_DOR(k)),'_',num2str(Umb_DOR(k+1))];
    Cont = Cont + 1;
end

for k = 1:(length(Umb_Sed) - 1)
    NameSummary{Cont}   = ['LenDre_Sed_',num2str(Umb_Sed(k)),'_',num2str(Umb_Sed(k+1))];
    Cont = Cont + 1;
end

for k = 1:(length(Umb_Elev) - 1) 
    NameSummary{Cont}   = ['LenDre_Elev_',num2str(Umb_Elev(k)),'_',num2str(Umb_Elev(k+1))];
    Cont = Cont + 1;
end

%% Regional Analisys
% Mode
Network_Data.Mode               = 0;
% Store ArcId of Interest Points
Hp_Data.ArcID_Inter = cell(length(Hp_Data.ArcInter),1);

for i = 1:length(Hp_Data.ArcInter) 
    
    Network_Data.ArcID_RM   = Hp_Data.ArcInter(i);
    Hp_Data.ArcID_Inter{i}  = logical(AnalysisNetwork(Network_Data));
    
    % Create Folder ArcID
    mkdir(fullfile(UserData.Path_Project,'RESULTS','HbD',['ArcID_',num2str(Hp_Data.ArcInter(i))],'HbD_TopologicalNetwork'))
    mkdir(fullfile(UserData.Path_Project,'RESULTS','HbD',['ArcID_',num2str(Hp_Data.ArcInter(i))],'HbD_Project'))
end

% Mode
Network_Data.Mode       = 1;
% River Mouth
Network_Data.ArcID_RM   = UserData.Params_ArcID_RM;

%% Scenarios Random
Hp_Data.Esc_Random(Hp_Data.Esc_BaseLine == 1) = 0;
Hp_Data.Esc_Other(Hp_Data.Esc_BaseLine == 1) = 0;

ProjectID       = find(Hp_Data.Esc_Random == 1); 
N               = UserData.Params_ThresholdComb;
Scenarios       = repmat(Hp_Data.Esc_BaseLine,1, N + 1);
Scenarios(:,1)  = Hp_Data.Esc_BaseLine;

Tmp = logical(RandomScenarios(ProjectID, UserData.Params_ThresholdComb));

for i = 2:N + 1
    Scenarios(ProjectID(Tmp(:,i)),i) = 1;
end 

Nsce = length(Scenarios(1,:));

%% Storage Summary
Summary = zeros(length(Nsce),3 + length(Umb_DOR) + length(Umb_DOR) + length(Umb_Elev), 1 + length(Hp_Data.ArcInter));

for i = 1:length(Nsce)
        
    % Volume of water stored by the dam.
    Esc_ArcID   = Hp_Data.ArcID( logical(Scenarios(:,i)) );
    [id, ~]     = ismember(Hp_Data.ArcID, Esc_ArcID);
    [~, posi]   = ismember(Hp_Data.ArcID, Network_Data.ArcID);
    
    % Ignore Rpject that not find in the topological Network
    Tmp         = posi(id);
    Esc_ArcID   = Network_Data.ArcID(Tmp(Tmp > 0));
    [id, ~]     = ismember(Hp_Data.ArcID, Esc_ArcID);
    [~, posi]   = ismember(Hp_Data.ArcID, Network_Data.ArcID);
    
    % Volumenes
    Network_Data.AccumVar(posi(id),2)   = Hp_Data.TotalVol(id);

    % Runoff of each River Seccion with dam
    % !!!! pilas aqui es el error !!!!
%     UserData.ProVar(posi(id))       = Hp.Qmed(id);
    Network_Data.ProVar(posi(id),1)       = Network_Data.QL_Year(posi(id));

    % Barrier
    Network_Data.ArcBarrier(posi(id),1)   = Hp_Data.ID(id);

    % Loss rate
    Network_Data.LossRate(posi(id))     = Hp_Data.LossRate(id);
    
    Tmp = log10(Hp_Data.TotalVol(id)./(Hp_Data.Qmed(id).*86400.*365));
    Network_Data.LossRate(posi(id)) = 100.*((0.97.^(0.19.^Tmp)));
    
    %% Analysis Network
    [FuncNetwork,ProVarOut,AccumVarOut,~,AccumLossVarOut] = AnalysisNetwork(Network_Data);
    
    %% DOR (Degree Of Regulation)
    % Factor : m3/(seg*year) -> m3
    Factor      = 86400 * 365;
    DOR         = ( AccumVarOut(:,2)./(UserData.QL_Year * Factor) ).* 100;

    %% DORw (Weighted Degree Of Regulation)
    DORw        = DOR .* (ProVarOut ./ UserData.QL_Year);
    
    %% Index for Sediment
    IndexSed    = ( 1 - (AccumLossVarOut./AccumVarOut(:,1)) ).*100;
    
    %% Fragmentation
    IDFun       = sort(unique(FuncNetwork));
    [id, posi]  = ismember(IDFun, Hp.ID);
    Esc_ArcID   = Hp.ArcID(posi(id));
    LenFrag     = zeros(length(IDFun), 2 + length(NumOrder));
     
    LenDrenage_Umb = UserData.LenDrenage;
    LenDrenage_Umb(UserData.DrenageOrder < UserData.DrenageOrderThreshold) = 0;
    
    for j = 1:length(IDFun)
        
        ID_FN           = find(FuncNetwork == IDFun(j)); 
        LenFrag(j,1)    = nansum( UserData.LenDrenage( ID_FN ) );
        LenFrag(j,2)    = nansum( LenDrenage_Umb( ID_FN ) );
        
        Order = UserData.DrenageOrder( ID_FN ); 
        for k = 1:length(NumOrder)
            LenFrag(j,2 + k) = nansum( UserData.LenDrenage( ID_FN( Order == NumOrder(k) ) ) );
        end
        
    end
    
    %% Threshold DOR and DORw
    Summary(i,1:3,1)  = [Nsce(i) LenFrag(1,1:2)];
    Cont = 4;
    for k = 1:(length(Umb_DOR) - 1)
        id = ((DOR >= Umb_DOR(k)) & (DOR < Umb_DOR(k+1)));
        Summary(i,Cont,1) = nansum( UserData.LenDrenage(id) );   
        Cont = Cont + 1;
        id = ((DORw >= Umb_DOR(k)) & (DORw < Umb_DOR(k+1)));
        Summary(i,Cont,1) = nansum( UserData.LenDrenage(id) );
        Cont = Cont + 1;
    end
    
    %% Threshold Sediment
    for k = 1:(length(Umb_Sed) - 1)
        id = ((IndexSed >= Umb_Sed(k)) & (IndexSed < Umb_Sed(k+1)));
        Summary(i,Cont,1) = nansum( UserData.LenDrenage(id) );
        Cont = Cont + 1;
    end
    
    %% Threshold Elevation
    for k = 1:(length(Umb_Elev) - 1)
        id = ((UserData.BasinElevAve >= Umb_Elev(k)) & (UserData.BasinElevAve < Umb_Elev(k+1)));
        Summary(i,Cont,1) = nansum( UserData.LenDrenage(id) );
        Cont = Cont + 1;
    end
    
    %% Save Results
    % Results by Project in each Scenario
    Results    = array2table([IDFun, [0; Esc_ArcID], LenFrag],'VariableNames',NameIndex_Project);
    writetable(Results, fullfile(UserData.PathProject,'RESULTS',['ArcID_',num2str(UserData.ArcID_RM)],'HbD_Project',['Scenario-',num2str(Nsce(i)),'.csv']))
    
    % Results by Network in each Scenario
    Results    = array2table([UserData.ArcID DOR DORw IndexSed],'VariableNames',NameIndex_Network);
    writetable(Results, fullfile(UserData.PathProject,'RESULTS',['ArcID_',num2str(UserData.ArcID_RM)],'HbD_TopologicalNetwork',['Scenario-',num2str(Nsce(i)),'.csv']))
    
    %% Regional Analysis
    %----------------------------------------------------------------------
    for w = 1:length(Hp.ArcInter)
        
        % DOR (Degree Of Regulation)
        DOR_Region      = DOR(Hp.ArcID_Inter{w});

        % DORw (Weighted Degree Of Regulation)
        DORw_Region     = DORw(Hp.ArcID_Inter{w});

        %% Index for Sediment
        IndexSed_Region = IndexSed(Hp.ArcID_Inter{w});

        %% Fragmentation
        FuncNetwork_Region      = FuncNetwork(Hp.ArcID_Inter{w});
        LenDrenage_Region       = UserData.LenDrenage(Hp.ArcID_Inter{w});
        LenDrenage_Umb_Region   = LenDrenage_Umb(Hp.ArcID_Inter{w});
        DrenageOrder_Region     = UserData.DrenageOrder(Hp.ArcID_Inter{w});
        BasinElevAve_Region     = UserData.BasinElevAve(Hp.ArcID_Inter{w});
        
        Value = FuncNetwork(UserData.ArcID == Hp.ArcInter(w));
        FuncNetwork_Region(FuncNetwork_Region == Value) = 0;
        
        LenFrag_Region      = LenFrag;
        
        ID_FN               = find(FuncNetwork_Region == 0); 
        LenFrag_Region(1,1) = nansum( LenDrenage_Region( ID_FN ) );
        LenFrag_Region(1,2) = nansum( LenDrenage_Umb_Region( ID_FN ) );

        Order = DrenageOrder_Region( ID_FN ); 
        for k = 1:length(NumOrder)
            LenFrag_Region(1,2 + k) = nansum( LenDrenage_Region( ID_FN( Order == NumOrder(k) ) ) );
        end
        
        New_IDFun       = unique(FuncNetwork_Region);
        [id, Posi]      = ismember(IDFun, New_IDFun);
        LenFrag_Region  = LenFrag_Region(id,:);
        New_Esc_ArcID   = [0; Esc_ArcID];
        New_Esc_ArcID   = New_Esc_ArcID(id);
        
        %% Threshold DOR and DORw
        Summary(i,1:3,w + 1)  = [Nsce(i) LenFrag_Region(1,1:2)];
        Cont = 4;
        for k = 1:(length(Umb_DOR) - 1)
            id = ((DOR_Region >= Umb_DOR(k)) & (DOR_Region < Umb_DOR(k+1)));
            Summary(i,Cont,w + 1) = nansum( LenDrenage_Region(id) );   
            Cont = Cont + 1;
            id = ((DORw_Region >= Umb_DOR(k)) & (DORw_Region < Umb_DOR(k+1)));
            Summary(i,Cont,w + 1) = nansum( LenDrenage_Region(id) );
            Cont = Cont + 1;
        end

        %% Threshold Sediment
        for k = 1:(length(Umb_Sed) - 1)
            id = ((IndexSed_Region >= Umb_Sed(k)) & (IndexSed_Region < Umb_Sed(k+1)));
            Summary(i,Cont,w + 1) = nansum( LenDrenage_Region(id) );
            Cont = Cont + 1;
        end

        %% Threshold Elevation
        for k = 1:(length(Umb_Elev) - 1)
            id = ((BasinElevAve_Region >= Umb_Elev(k)) & (BasinElevAve_Region < Umb_Elev(k+1)));
            Summary(i,Cont,w + 1) = nansum( LenDrenage_Region(id) );
            Cont = Cont + 1;
        end

        %% Save Results
        % Results by Project in each Scenario
        Results    = array2table([New_IDFun, New_Esc_ArcID, LenFrag_Region],'VariableNames',NameIndex_Project);
        writetable(Results, fullfile(UserData.PathProject,'RESULTS',['ArcID_',num2str(Hp.ArcInter(w))],'HbD_Project',['Scenario-',num2str(Nsce(i)),'.csv']))

        % Results by Network in each Scenario
        Results    = array2table([UserData.ArcID(Hp.ArcID_Inter{w}) DOR_Region DORw_Region IndexSed_Region],'VariableNames',NameIndex_Network);
        writetable(Results, fullfile(UserData.PathProject,'RESULTS',['ArcID_',num2str(Hp.ArcInter(w))],'HbD_TopologicalNetwork',['Scenario-',num2str(Nsce(i)),'.csv']))
    end
    
end

Results    = array2table(Summary(:,:,1),'VariableNames',NameSummary);
writetable(Results, fullfile(UserData.PathProject,'RESULTS','Summary',['Summary_ArcID_',num2str(UserData.ArcID_RM),'.csv']))

% Save summary 
for i = 2:length(Hp.ArcInter) + 1
    Results    = array2table(Summary(:,:,i),'VariableNames',NameSummary);
    writetable(Results, fullfile(UserData.PathProject,'RESULTS','Summary',['Summary_ArcID_',num2str(Hp.ArcInter(i-1)),'.csv']))
end

