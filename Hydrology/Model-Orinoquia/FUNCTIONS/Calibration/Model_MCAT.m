% function UserDataCal = CalibrationModel(UserData)
%% BASE DATA 
% Project               : Landscape planning for agro-industrial expansion 
%                         in a large, well-preserved savanna: how to plan 
%                         multifunctional landscapes at scale for nature and 
%                         people in the Orinoquia region, Colombia
% Author                : Jonathan Nogales Pimentel
% Email                 : nogales02@hotmail.comHydrology Specialist  : Carlos Andrés Rogéliz
% Company               : The Nature Conservancy - TNC
% 
%% MODEL OF THOMAS - (1981) - "abcd"
% Copyright (C) 2017 Apox Technologies
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
% INPUT DATA

%% INPUT DATA
clearvars -except UserData
% -------------------------------------------------------------------------
% Parameter Thomas Model
% -------------------------------------------------------------------------
try
    Tmp = xlsread( fullfile(UserData.PathProject,'DATA','Params',UserData.DataParams), 'Thomas');
catch
    errordlg(['The Excel "',UserData.DataParams,'" not found'],'!! Error !!')
    return
end

UserData.BasinCode          = Tmp(:,1);
UserData.BasinArea          = Tmp(:,2);
UserData.TypeBasinCal       = Tmp(:,3);
UserData.IDAq               = Tmp(:,4);
UserData.Arc_InitNode       = Tmp(:,5);
UserData.Arc_EndNode        = Tmp(:,6);
UserData.Sw                 = Tmp(:,7);
UserData.Sg                 = Tmp(:,8);

% -------------------------------------------------------------------------
% Parameter and States Variable Floodplains
% -------------------------------------------------------------------------
try
    Tmp = xlsread( fullfile(UserData.PathProject,'DATA','Params',UserData.DataParams), 'Floodplains');
catch
    errordlg(['The Excel "',UserData.DataParams,'" not found'],'!! Error !!')
    return
end

UserData.ArcIDFlood         = Tmp(:,1);
UserData.FloodArea          = Tmp(:,2);
UserData.Vh                 = Tmp(:,3);

% -------------------------------------------------------------------------
% River Downstream
% -------------------------------------------------------------------------
try
    Tmp = xlsread( fullfile(UserData.PathProject,'DATA','Params',UserData.DataParams), 'Downstream');
catch
    errordlg(['The Excel "',UserData.DataParams,'" not found'],'!! Error !!')
    return
end

UserData.ArcID_Downstream   = Tmp;

% -------------------------------------------------------------------------
% Calibration Streamflow
% -------------------------------------------------------------------------
try
    Tmp = xlsread( fullfile(UserData.PathProject,'DATA','Params',UserData.DataParams), 'Control_Point');
catch
    errordlg(['The Excel "',UserData.DataParams,'" not found'],'!! Error !!')
    return
end

UserData.CodeGauges         = Tmp(:,1);
UserData.ArIDGauges         = Tmp(:,2);
UserData.CatGauges          = Tmp(:,3);

% -------------------------------------------------------------------------
% Demand and Returns Paremeters
% -------------------------------------------------------------------------
try
    Tmp = xlsread( fullfile(UserData.PathProject,'DATA','Params',UserData.DataParams), 'Demand');
    if isempty(Tmp)
        Tmp = NaN(1,9);
    end
catch
    errordlg(['The Excel "',UserData.DataParams,'" not found'],'!! Error !!')
    return
end

Tmp1 = Tmp(:,1);
UserData.IDExtAgri          = Tmp1(isnan(Tmp1) == 0);
Tmp1 = Tmp(:,2);
UserData.IDExtDom           = Tmp1(isnan(Tmp1) == 0);
Tmp1 = Tmp(:,3);
UserData.IDExtLiv           = Tmp1(isnan(Tmp1) == 0);
Tmp1 = Tmp(:,4);
UserData.IDExtHy            = Tmp1(isnan(Tmp1) == 0);
Tmp1 = Tmp(:,5);
UserData.IDExtMin           = Tmp1(isnan(Tmp1) == 0);
Tmp1 = Tmp(:,6);
UserData.IDRetDom           = Tmp1(isnan(Tmp1) == 0);
Tmp1 = Tmp(:,7);
UserData.IDRetLiv           = Tmp1(isnan(Tmp1) == 0);
Tmp1 = Tmp(:,8);
UserData.IDRetHy            = Tmp1(isnan(Tmp1) == 0);
Tmp1 = Tmp(:,9);
UserData.IDRetMin           = Tmp1(isnan(Tmp1) == 0);

% -------------------------------------------------------------------------
% SORT 
% -------------------------------------------------------------------------
[UserData.BasinCode,id]     = sort(UserData.BasinCode);
UserData.BasinArea          = UserData.BasinArea(id);
UserData.IDAq               = UserData.IDAq(id);
UserData.Arc_InitNode       = UserData.Arc_InitNode(id);
UserData.Arc_EndNode        = UserData.Arc_EndNode(id);
UserData.Sw                 = UserData.Sw(id);
UserData.Sg                 = UserData.Sg(id);


%% PARAMETERS
Tmp = NaN(length(UserData.BasinCode), 1);
UserData.a                  = Tmp;
UserData.b                  = Tmp;
UserData.c                  = Tmp;
UserData.d                  = Tmp;
UserData.ParamExtSup        = Tmp;

Tmp = NaN(length(UserData.ArcIDFlood), 1);
UserData.Tpr                = Tmp;
UserData.Trp                = Tmp;
UserData.Q_Umb              = Tmp;
UserData.V_Umb              = Tmp;

clearvars Tmp Tmp1

%% PARALLEL POOL ON CLUSTER
try
   myCluster                = parcluster('local');
   myCluster.NumWorkers     = UserData.CoresNumber;
   saveProfile(myCluster);
   parpool;
catch
end


%% Crate Folder 
mkdir(fullfile(UserData.PathProject, 'RESULTS','Parameters_Model','Eval_MCAT'))

%% LOAD SCENARIOS
Scenario        = cell2mat(UserData.Scenarios(:,2));

%% Save Data
NameBasin       = cell(1,length(UserData.BasinCode) + 1);
NameBasin{1}    = 'Date_Matlab';

BasinCode = UserData.BasinCode;
for k = 2:length(UserData.BasinCode) + 1
    NameBasin{k} = ['Basin_',num2str(BasinCode(k - 1))];
end

clearvars BasinCode

for Sce = 1:length(Scenario)    
    %% LOAD CLIMATE DATA
    % -------------------------------------------------------------------------
    % Precipitation 
    % -------------------------------------------------------------------------
    try
        P = dlmread(fullfile(UserData.PathProject,'RESULTS','P',['Pcp_Scenario-',num2str(Sce),'.dat']),',',1,1);
        DateP   = P(:,1);
        P       = P(:,2:end);
    catch
        errordlg('The Precipitation Data Not Found','!! Error !!')
        return
    end
    
    % -------------------------------------------------------------------------
    % Evapotranspiration
    % -------------------------------------------------------------------------
    try
        ET      = dlmread(fullfile(UserData.PathProject,'RESULTS','ETP',['ETP_Scenario-',num2str(Sce),'.dat']),',',1,1);
        DateET  = ET(:,1);
        ET      = ET(:,2:end);
    catch
        errordlg('The Evapotranspiration Data Not Found','!! Error !!')
        return
    end
    
    %% LOAD STRAMFLOW DATA
    try
        [Qobs,TmpDate]  = xlsread( fullfile(UserData.PathProject,'DATA','Hydrological',UserData.DataStreamFlow) );
        CodeGaugesQ     = Qobs(1,:)';
        Qobs            = Qobs(2:end,:);
        DateQ           = datenum( TmpDate(2:(length(Qobs(:,1)) + 1),1) );
    catch
        errordlg(['The Excel "',UserData.DataStreamFlow,'" not found'],'!! Error !!')
        return
    end
    
    try
        [CodeQ_CV,TmpDate]  = xlsread( fullfile(UserData.PathProject,'DATA','Params',UserData.DataParams), 'Calibration_Validation');
        TmpDate             = TmpDate(3:(length(CodeQ_CV) + 2),2:end);
        DateCal             = [datenum(TmpDate(:,1)) datenum(TmpDate(:,2))];
        DateVal             = NaN(length(CodeQ_CV),2);
        
        for dt = 1:length(CodeQ_CV)
            try
                DateVal(dt,:) = [datenum(TmpDate(dt,3)) datenum(TmpDate(dt,4))];
            catch
                DateVal(dt,:) = NaN(1,2);
            end
        end
        
    catch
        errordlg(['The Excel "',UserData.DataStreamFlow,'" not found'],'!! Error !!')
        return
    end
    
    %% LOAD DEMAND DATA  
    % TOTAL DEMAND 
    for dr = 1:2
        for i = 1:length(UserData.DemandVar)
            DeRe = {'Demand','Return'};
            try
                Tmp     = dlmread(fullfile(UserData.PathProject,'RESULTS','Demand',UserData.DemandVar{i},['Scenario-',num2str(Sce)],['Total_',DeRe{dr},'.dat']),',',1,1);
                eval([DeRe{dr},'(:,:,',num2str(i),') = Tmp(:,2:end);']);
            catch
                eval([DeRe{dr},'(:,:,',num2str(i),') = Tmp(:,2:end)*0;']);
            end
        end
    end
    DateD = Tmp(:,1);
    
    Demand(isnan(Demand))       = 0;
    Return(isnan(Return))       = 0;
    
    % groundwater Demand
    UserData.DemandSub = zeros(size(Demand(:,:,1)));
    
    %% CALIBRACION
    clc
    % Id Basin by Arcid Downstream
    PoPo        = zeros(length(UserData.BasinCode),1); 
    
    % Id Basin with Floodplains
    PoPoFlood   = zeros(length(UserData.ArcIDFlood),1);
    
    PoPoID      = PoPo;
    PoPoFloodID = PoPoFlood;
    
    NumberCat   = unique(UserData.CatGauges);
    
    for i = 5%:length(NumberCat)
        
        id = find(UserData.CatGauges == NumberCat(i) );
        
        for j = 2%:length(id)
            
            UserData.DownGauges = UserData.ArIDGauges(id(j));
            %  
            [PoPo, PoPoFlood]   = GetNetwork( UserData.BasinCode,...
                                              UserData.Arc_InitNode,...
                                              UserData.Arc_EndNode,...
                                              UserData.ArIDGauges(id(j)),...
                                              PoPo,...
                                              PoPoFlood,...
                                              UserData.ArcIDFlood);
              
            PoPoID                  = (PoPoID + PoPo);
            PoPoFloodID             = (PoPoFloodID + PoPoFlood);

            UserData.IDPoPo         = (PoPoID  == 1);
            UserData.IDPoPoFlood    = (PoPoFloodID  == 1);
            
            UserData.PoPo           = logical(PoPo);
            UserData.PoPoFlood      = logical(PoPoFlood);
            
            [~,PosiQ]               = ismember(UserData.CodeGauges(id(j)), CodeGaugesQ);
            UserData.Qobs           = Qobs(: ,PosiQ);
            Q_Obs                   = Qobs(: ,PosiQ);
            
            UserData.GaugesStreamFlowQ   = UserData.CodeGauges(id(j));
            
            UserData.P              = P;
            UserData.ET             = ET;
            UserData.DemandSup      = Demand;
            UserData.Returns        = Return;
            UserData.Date           = DateD;
            
            %%
            disp(['[i = ',num2str(i),' - j = ',num2str(j), ']  Gauges = ',num2str(UserData.ArIDGauges(id(j)))])
            disp('-------------------------------------------')  
            
            if (i > 1)
                load(fullfile(UserData.PathProject, 'RESULTS','Parameters_Model','SCE',...
                        [num2str(UserData.CodeGauges(id(j))),'-',num2str(UserData.DownGauges),'_SCE.mat']))

                UserData.CalMode = CalMode;

                %% Parameter Asignation
                Q_sim   = NaN(length(allEvals(:,1)), length(DateD));
                Fuc     = NaN(length(allEvals(:,1)), 21);

                parfor ii = 1:length(allEvals(:,1))

                    Param = allEvals(ii,1:end-1);

                    [Q_sim(ii,:), Fuc(ii,:)] = Function_MCAT(Param, UserData);

                end

                save(fullfile(UserData.PathProject, 'RESULTS','Parameters_Model','Eval_MCAT',...
                    [num2str(UserData.CodeGauges(id(j))),'-',num2str(UserData.DownGauges),'_MCAT.mat']),...
                    'allEvals','Fuc','Q_sim','Q_Obs','CalMode')
            end

        end
    end   
end

run('/media/nelsonobregon/93f6134e-6f19-47a5-bd1a-a4567bcdd61c/InfoNogales/ORINOQUIA/PRODUCTOS/4-MODELACION/PROGRAMS/CODES/Scritpt_MCAT.m')
system('shutdown now')
