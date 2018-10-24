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

warning off

%% Add Repository
Path_System     = '/media/nogales/DATA';
Path_Repository = fullfile(Path_System,'TNC','Tools','Tools','Matlab');
Path_DEM        = fullfile(Path_System,'TNC','BaseDataSIG','Magdalena-Cauca-Basin','Matlab');

addpath(genpath(Path_Repository))
addpath(genpath(Path_DEM))

%% Instantiation
UserData    = ClassUserData;
Hp          = ClassHydroelectricProject;
Hp.Network  = ClassNetwork;

%% INPUT DATA
% Name Project
UserData.NameProject                            = 'Cornare';
% Path Project
% UserData.Path_Project                           = '/media/nogales/NogalesBackup/TNC/Project/HbD-Cornare/Analysis_HbD';
UserData.Path_Project                           = '/media/nogales/DATA/TNC/Project/Project-HbD-Cornare/PROJECT-PROGRAMMING/Analysis_HbD';
% Main 
UserData.NameFile_Excel_MasterHbD               = 'Master_HbD_SIMA.xlsx';
% Basic Data 
UserData.NameFile_CSV_DataHbD                   = 'Network_8916_SIMA.csv';%'Network_8916_Cornare.csv';
% Mode Network
UserData.Params_HbD_Cal_ModeNetwork             = 1;
% CurrID AnalysisNetwork
UserData.Params_HbD_Cal_CurrIDNetwork           = 0;
% % Drenage Order Threshold
UserData.Params_HbD_Cal_DrenageOrderThreshold   = 0;
% Scenarios Random - Threshold
UserData.Params_HbD_Cal_ThresholdComb           = 1000;
% Create Paths of the Folder
UserData = UserData.CreateFolder;

%% LOAD DATA Hydro-Project
% -------------------------------------------------------------------------
% Regional analysis
% -------------------------------------------------------------------------
Tmp = xlsread(fullfile(UserData.PathFolder_D_ExcelMaster,UserData.NameFile_Excel_MasterHbD),'ArcInterest');
% River Mouth - Magdalena-Cauca
UserData.Params_HbD_Cal_ArcID_RM = Tmp(1);
% ArcInterest
Hp.ArcInter = Tmp(2:end);

% -------------------------------------------------------------------------
% Topological Network
% -------------------------------------------------------------------------
Tmp = dlmread(fullfile(UserData.PathFolder_D_HbD,UserData.NameFile_CSV_DataHbD),',',1,0);
[~, id] = sort(Tmp(:,1)); Tmp = Tmp(id,:);

% ArcID
Hp.Network.ArcID       = Tmp(:,1);
% From Node 
Hp.Network.FromNode    = Tmp(:,2);
% To Node
Hp.Network.ToNode      = Tmp(:,3);
% ArcBarrier
Hp.Network.ArcBarrier  = Tmp(:,3)*0;
% Variables
NameVariables       = {'BasinElevAve', 'DrenageOrder', 'LenDrenage', 'Ql_Year', 'Qs_Year'};
Hp.Network.Variables   =  array2table(Tmp(:,4:8), 'VariableNames', NameVariables);

% -------------------------------------------------------------------------
% Hydroelectric Projects
% -------------------------------------------------------------------------
[Tmp, TmpT] = xlsread(fullfile(UserData.PathFolder_D_ExcelMaster,UserData.NameFile_Excel_MasterHbD),'Config-Project');
Tmp1        = Tmp(16:end,1:12);

Hp.ID           = Tmp1(:,1);
Hp.Name         = TmpT(16:15+length(Tmp1(:,1)),2);
Hp.Coor_X       = Tmp1(:,5);
Hp.Coor_Y       = Tmp1(:,6);
Hp.ArcID        = Tmp1(:,7);
Hp.TotalVolumen = Tmp1(:,8);
Hp.InstallPower = Tmp1(:,9);
Hp.HigthDam     = Tmp1(:,10);
Hp.Qmed         = Tmp1(:,11);
Hp.LossRate     = Tmp1(:,12);
Hp.Scenario     = logical((Hp.ID * 0) + 1);

SceTmp          = TmpT(13,14:end);
Sce_Random      = zeros(1, length(SceTmp) + 1);

for i = 1:length(SceTmp)
    if strcmp(SceTmp{i},'True')
        Sce_Random(i+1) = 1;
    end
end

Sce_NumRan      = [0 Tmp(14,14:end)];
Sce_BaseLine    = Tmp(16:end,13);
Sce             = Tmp(16:end,14:end);

SceTmp          = TmpT(12,14:end);
Sce_Status      = zeros(1, length(SceTmp) + 1);
Sce_Status(1)   = 1;

for i = 1:length(SceTmp)
    if strcmp(SceTmp{i},'On')
        Sce_Status(i+1) = 1;
    end
end

Sce_Name        = TmpT(15,13:12 + length(Sce_Status));

EvalTotal =  sum(Sce_Status(Sce_Random == 0)) + sum(Sce_NumRan .* Sce_Random .* Sce_Status);

%% Scenarios Random
Scenarios       = cell(sum(Sce_Status), 2);
Scenarios(:,2)  = Sce_Name(Sce_Status ==1)';
% Scenarios{1,1}  = Sce_BaseLine;

Cont = 1;
for i = 1:length(Sce_Status)
    if Sce_Status(i) == 1
        if Sce_Random(i) == 1
            
            Sce(Sce_BaseLine == 1,i - 1) = 0;
            ProjectID   = Hp.ID(Sce(:,i -1) == 1);
            
            Tmp         = Hp.RandomScenarios(ProjectID, Sce_NumRan(i));
            Tmp1        = repmat( Sce_BaseLine, 1, Sce_NumRan(i));
            for j = 1:Sce_NumRan(i)
                id = ismember(Hp.ID, ProjectID(Tmp(:,j)));
                Tmp1(id, j) = 1; 
            end
            Scenarios{Cont,1} = Tmp1;
            Cont = Cont + 1;
        else
            if i == 1
                Scenarios{Cont,1} = Sce_BaseLine;
            else
                Scenarios{Cont,1} = Sce(:,i -1);
            end
            Cont = Cont + 1;
        end
    end
end 

%% Complementation of the Volumens and Sediment Loss Rate
if sum(isnan(Hp.TotalVolumen)) > 0 
    load('DEM-90m.mat')
    load('FlowDir-90m.mat')
    load('FlowAccum-90m.mat')
    Vol = Hp.CompleVolumen(DEM, FlowDir, FlowAccum);
    Hp.TotalVolumen(isnan(Hp.TotalVolumen)) = Vol(isnan(Hp.TotalVolumen));
    clearvars DEM FlowDir FlowAccum
end

%% Complementation of the Regulation Streamflow by reservoir
if sum(isnan(Hp.Qmed)) > 0
    [id, id1] = ismember(Hp.ArcID(isnan(Hp.Qmed)), Hp.Network.ArcID);
    id1 = id1(id1 > 0);
    Hp.Qmed(isnan(Hp.Qmed)) = Hp.Network.Variables.Ql_Year(id1);
end

%% Complementation of the Sediment Loss Rate
if sum(isnan(Hp.LossRate)) > 0
    Rate    = Hp.SedimentDendy;
    Hp.LossRate(isnan(Hp.LossRate)) = Rate(isnan(Hp.LossRate));
end

%% Create Folder
mkdir(fullfile(UserData.PathFolder_R_HbDSummary))

for j = 1:length(Scenarios(:,1))
    mkdir(fullfile(UserData.PathFolder_R_HbDProject,['ArcID_',num2str(UserData.Params_HbD_Cal_ArcID_RM)], Scenarios{j,2}))
    mkdir(fullfile(UserData.PathFolder_R_HbDNetwork,['ArcID_',num2str(UserData.Params_HbD_Cal_ArcID_RM)], Scenarios{j,2}))
%     mkdir(fullfile(UserData.PathFolder_R_HbDSummary,['ArcID_',num2str(UserData.Params_HbD_Cal_ArcID_RM)], Scenarios{j,2}))
end
    
for i = 1:length(Hp.ArcInter)     
    
    for j = 1:length(Scenarios(:,1))
        mkdir(fullfile(UserData.PathFolder_R_HbDProject,['ArcID_',num2str(Hp.ArcInter(i))], Scenarios{j,2}))
        mkdir(fullfile(UserData.PathFolder_R_HbDNetwork,['ArcID_',num2str(Hp.ArcInter(i))], Scenarios{j,2}))
%         mkdir(fullfile(UserData.PathFolder_R_HbDSummary,['ArcID_',num2str(Hp.ArcInter(i))], Scenarios{j,2}))
        
    end
end

%% Name Results
        
% Name Network 
NameIndex_Network   = {'ArcID','Functional','DOR','DORw','Index_Sed'};

% Name Summary 
NameSummary = {'Scenario','InstallPower','DOR','DORw','Sediment_alteration','Total_Fragmentation','Threshold_Fragmentation'}; 
Cont = 8;
for k = 1:(length(UserData.Params_HbD_Cal_ThresholdDOR) - 1)
    NameSummary{Cont}   = ['LenDre_DOR_',num2str(UserData.Params_HbD_Cal_ThresholdDOR(k)),'_',num2str(UserData.Params_HbD_Cal_ThresholdDOR(k+1))];   
    Cont = Cont + 1;
    NameSummary{Cont}   = ['LenDre_DORw_',num2str(UserData.Params_HbD_Cal_ThresholdDOR(k)),'_',num2str(UserData.Params_HbD_Cal_ThresholdDOR(k+1))];
    Cont = Cont + 1;
end

for k = 1:(length(UserData.Params_HbD_Cal_ThresholdSed) - 1)
    NameSummary{Cont}   = ['LenDre_Sed_',num2str(UserData.Params_HbD_Cal_ThresholdSed(k)),'_',num2str(UserData.Params_HbD_Cal_ThresholdSed(k+1))];
    Cont = Cont + 1;
end

for k = 1:(length(UserData.Params_HbD_Cal_ThresholdElev) - 1) 
    NameSummary{Cont}   = ['LenDre_Elev_',num2str(UserData.Params_HbD_Cal_ThresholdElev(k)),'_',num2str(UserData.Params_HbD_Cal_ThresholdElev(k+1))];
    Cont = Cont + 1;
end

%% Regional Analysis
% Store ArcId of Interest Points
ArcID_Inter = cell(length(Hp.ArcInter),1);

for i = 1:length(Hp.ArcInter) 
    Hp.Network.ArcID_RM    = Hp.ArcInter(i);
    ArcID_Inter{i}      = logical(Hp.Network.AnalysisNetwork(0,UserData.Params_HbD_Cal_CurrIDNetwork));
end

% River Mouth
Hp.Network.ArcID_RM   = UserData.Params_HbD_Cal_ArcID_RM;
    
%% Storage Summary
NameRawSce = {};
Cont_T = 1;
Chanfle = 1;

% n =  3 + length(UserData.Params_HbD_Cal_ThresholdDOR) + length(UserData.Params_HbD_Cal_ThresholdDOR) + length(UserData.Params_HbD_Cal_ThresholdElev);
Summary  = zeros(EvalTotal, length(NameSummary), 1 + length(Hp.ArcInter));
    
for ii = 1 : length(Scenarios(:,1))
    
    Nsce = Scenarios{ii, 1};
    
    for i = 1:length(Nsce(1,:))
    
        Hp.Scenario = Nsce(:,i);

        NameVar     = {'Ql_Year', 'Qs_Year', 'DrenageOrder', 'LenDrenage'};
        [DOR, DORw, IndexSed, LenFrag, FuncNetwork] = Hp.Impact_Tier1(UserData.Params_HbD_Cal_DrenageOrderThreshold, NameVar);

        LenDrenage_Umb = Hp.Network.Variables.LenDrenage;        
        LenDrenage_Umb(Hp.Network.Variables.DrenageOrder < UserData.Params_HbD_Cal_DrenageOrderThreshold) = 0;

        %% Threshold DOR and DORw
        Tmp = Hp.InstallPower(Hp.Scenario);
        Summary(Cont_T,1:7,1)  = [  ii,...
                                    sum( Tmp(isnan(Tmp) == 0)  ),....
                                    mean(DOR(isnan(DOR) == 0)),...
                                    mean(DORw(isnan(DORw) == 0))...
                                    mean(IndexSed(isnan(IndexSed) == 0)),...
                                    LenFrag.Total(1),...
                                    LenFrag.Threshold(1)];
        Cont = 7;
        for k = 1:(length(UserData.Params_HbD_Cal_ThresholdDOR) - 1)
            id = ((DOR >= UserData.Params_HbD_Cal_ThresholdDOR(k)) & (DOR < UserData.Params_HbD_Cal_ThresholdDOR(k+1)));
            Tmp = Hp.Network.Variables.LenDrenage(id);
            Summary(Cont_T,Cont,1) = sum( Tmp(isnan(Tmp) == 0)  );   
            Cont = Cont + 1;
            id = ((DORw >= UserData.Params_HbD_Cal_ThresholdDOR(k)) & (DORw < UserData.Params_HbD_Cal_ThresholdDOR(k+1)));
            Tmp = Hp.Network.Variables.LenDrenage(id);
            Summary(Cont_T,Cont,1) = sum( Tmp(isnan(Tmp) == 0)  );  
            Cont = Cont + 1;
        end

        %% Threshold Sediment
        for k = 1:(length(UserData.Params_HbD_Cal_ThresholdSed) - 1)
            id = ((IndexSed >= UserData.Params_HbD_Cal_ThresholdSed(k)) & (IndexSed < UserData.Params_HbD_Cal_ThresholdSed(k+1)));
            Tmp = Hp.Network.Variables.LenDrenage(id);
            Summary(Cont_T,Cont,1) = sum( Tmp(isnan(Tmp) == 0)  );
            Cont = Cont + 1;
        end

        %% Threshold Elevation
        for k = 1:(length(UserData.Params_HbD_Cal_ThresholdElev) - 1)
            id = ((Hp.Network.Variables.BasinElevAve >= UserData.Params_HbD_Cal_ThresholdElev(k)) & (Hp.Network.Variables.BasinElevAve < UserData.Params_HbD_Cal_ThresholdElev(k+1)));
            Tmp = Hp.Network.Variables.LenDrenage(id);
            Summary(Cont_T,Cont,1) = sum( Tmp(isnan(Tmp) == 0)  );
            Cont = Cont + 1;
        end

        %% Save Results
        % Results by Project in each Scenario
        writetable(LenFrag, fullfile(UserData.PathFolder_R_HbDProject,['ArcID_',num2str(Hp.Network.ArcID_RM)],Scenarios{ii,2},['Scenario-',num2str(i),'.csv']), 'WriteRowNames',true)

        % Results by Network in each Scenario
        Results    = array2table([Hp.Network.ArcID FuncNetwork DOR DORw IndexSed],'VariableNames',NameIndex_Network);
        writetable(Results, fullfile(UserData.PathFolder_R_HbDNetwork,['ArcID_',num2str(Hp.Network.ArcID_RM)],Scenarios{ii,2},['Scenario-',num2str(i),'.csv']))

        %% Regional Analysis
        %----------------------------------------------------------------------
        for w = 1:length(Hp.ArcInter)
            
            % DOR (Degree Of Regulation)
            DOR_Region              = DOR(ArcID_Inter{w});

            % DORw (Weighted Degree Of Regulation)
            DORw_Region             = DORw(ArcID_Inter{w});

            %% Index for Sediment
            IndexSed_Region         = IndexSed(ArcID_Inter{w});

            %% Fragmentation
            FuncNetwork_Region      = FuncNetwork(ArcID_Inter{w});
            LenDrenage_Region       = Hp.Network.Variables.LenDrenage(ArcID_Inter{w});
            LenDrenage_Umb_Region   = LenDrenage_Umb(ArcID_Inter{w});
            DrenageOrder_Region     = Hp.Network.Variables.DrenageOrder(ArcID_Inter{w});
            BasinElevAve_Region     = Hp.Network.Variables.BasinElevAve(ArcID_Inter{w});

            [~, posi]              = ismember( unique(FuncNetwork_Region), LenFrag.ID_Project );

            LenFrag_Region          = LenFrag(posi,:);

            Value = FuncNetwork(Hp.Network.ArcID == Hp.ArcInter(w));
            FuncNetwork_Region(FuncNetwork_Region == Value) = 0;

            LenFrag_Region.ID_Project( LenFrag_Region.ID_Project == Value) = 0;
            [~, id] = sort(LenFrag_Region.ID_Project);
            LenFrag_Region = LenFrag_Region(id,:);

            ID_FN                       = find(FuncNetwork_Region == 0); 
            Tmp = LenDrenage_Region( ID_FN );
            LenFrag_Region.Total(1)     = sum( Tmp(isnan(Tmp) == 0)  );
            Tmp = LenDrenage_Umb_Region( ID_FN );
            LenFrag_Region.Threshold(1) = sum( Tmp(isnan(Tmp) == 0)  ); 

            Order       = DrenageOrder_Region( ID_FN ); 
            NumOrder    = sort(unique( DrenageOrder_Region ));
            for k = 1:length(NumOrder)
                eval( ['Tmp = LenDrenage_Region( ID_FN( Order == NumOrder(k) ) ); LenFrag_Region.Order_',num2str(NumOrder(k)),'(1) = sum( Tmp(isnan(Tmp) == 0)  );']);
            end

            %% Threshold DOR and DORw
            [~, id] = ismember(LenFrag_Region.ID_Project(2:end), Hp.ID);
            Tmp = Hp.InstallPower(id);
            Summary(Cont_T,1:7,w + 1)  = [ii  sum( Tmp(isnan(Tmp) == 0)  ),....
                                    mean(DOR_Region(isnan(DOR_Region) == 0)),...
                                    mean(DORw_Region(isnan(DORw_Region) == 0))...
                                    mean(IndexSed_Region(isnan(IndexSed_Region) == 0)),...
                                    LenFrag_Region.Total(1),...
                                    LenFrag_Region.Threshold(1)];
            Cont = 7;
            for k = 1:(length(UserData.Params_HbD_Cal_ThresholdDOR) - 1)
                id = ((DOR_Region >= UserData.Params_HbD_Cal_ThresholdDOR(k)) & (DOR_Region < UserData.Params_HbD_Cal_ThresholdDOR(k+1)));
                Tmp = LenDrenage_Region(id); 
                Summary(Cont_T,Cont,w + 1) = sum( Tmp(isnan(Tmp) == 0)  );  
                Cont = Cont + 1;
                id = ((DORw_Region >= UserData.Params_HbD_Cal_ThresholdDOR(k)) & (DORw_Region < UserData.Params_HbD_Cal_ThresholdDOR(k+1)));
                Tmp = LenDrenage_Region(id); 
                Summary(Cont_T,Cont,w + 1) = sum( Tmp(isnan(Tmp) == 0)  ); 
                Cont = Cont + 1;
            end

            %% Threshold Sediment
            for k = 1:(length(UserData.Params_HbD_Cal_ThresholdSed) - 1)
                id = ((IndexSed_Region >= UserData.Params_HbD_Cal_ThresholdSed(k)) & (IndexSed_Region < UserData.Params_HbD_Cal_ThresholdSed(k+1)));
                Tmp = LenDrenage_Region(id);
                Summary(Cont_T,Cont,w + 1) = sum( Tmp(isnan(Tmp) == 0)  ); 
                Cont = Cont + 1;
            end

            %% Threshold Elevation
            for k = 1:(length(UserData.Params_HbD_Cal_ThresholdElev) - 1)
                id = ((BasinElevAve_Region >= UserData.Params_HbD_Cal_ThresholdElev(k)) & (BasinElevAve_Region < UserData.Params_HbD_Cal_ThresholdElev(k+1)));
                Tmp = LenDrenage_Region(id);
                Summary(Cont_T,Cont,w + 1) = sum( Tmp(isnan(Tmp) == 0)  ); 
                Cont = Cont + 1;
            end

            %% Save Results
            % Results by Project in each Scenario
            writetable(LenFrag_Region, fullfile(UserData.PathFolder_R_HbDProject,['ArcID_',num2str(Hp.ArcInter(w))],Scenarios{ii,2},['Scenario-',num2str(i),'.csv']), 'WriteRowNames',true)

            % Results by Network in each Scenario
            Results    = array2table([Hp.Network.ArcID(ArcID_Inter{w}) FuncNetwork_Region DOR_Region DORw_Region IndexSed_Region],'VariableNames',NameIndex_Network);
            writetable(Results, fullfile(UserData.PathFolder_R_HbDNetwork,['ArcID_',num2str(Hp.ArcInter(w))],Scenarios{ii,2},['Scenario-',num2str(i),'.csv']), 'WriteRowNames',true)
        end                        
         
        if Chanfle > 9
            
            Results    = array2table(Summary(1:length(NameRawSce),:,1),'VariableNames',NameSummary, 'RowNames', NameRawSce);
            writetable(Results, fullfile(UserData.PathFolder_R_HbDSummary,['Summary_ArcID_',num2str(UserData.Params_HbD_Cal_ArcID_RM),'.csv']), 'WriteRowNames',true)

            % Save summary 
            for w = 2:length(Hp.ArcInter) + 1
                Results    = array2table(Summary(1:length(NameRawSce),:,w),'VariableNames',NameSummary, 'RowNames', NameRawSce);
                writetable(Results, fullfile(UserData.PathFolder_R_HbDSummary,['Summary_ArcID_',num2str(Hp.ArcInter(w-1)),'.csv']), 'WriteRowNames',true)
            end
            
            Chanfle = 1;
        end
        
        NameRawSce{Cont_T, 1} = [Scenarios{ii,2},'_Sce-',num2str(i)];
        disp(NameRawSce{Cont_T, 1})
        Cont_T = Cont_T + 1;
        
        Chanfle = Chanfle + 1;
    end
    
end

Results    = array2table(Summary(:,:,1),'VariableNames',NameSummary, 'RowNames', NameRawSce);
writetable(Results, fullfile(UserData.PathFolder_R_HbDSummary,['Summary_ArcID_',num2str(UserData.Params_HbD_Cal_ArcID_RM),'.csv']), 'WriteRowNames',true)

% Save summary 
for w = 2:length(Hp.ArcInter) + 1
    Results    = array2table(Summary(1:length(NameSummary),:,w),'VariableNames',NameSummary);
    writetable(Results, fullfile(UserData.PathFolder_R_HbDSummary,['Summary_ArcID_',num2str(Hp.ArcInter(w-1)),'.csv']), 'WriteRowNames',true)
end

    

