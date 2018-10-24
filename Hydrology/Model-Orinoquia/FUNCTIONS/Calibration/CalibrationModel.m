function UserData = CalibrationModel(UserData)
% /usr/bin/Matlab-R2016b
% -------------------------------------------------------------------------
% Calibration Model - HMO
% -------------------------------------------------------------------------
% BASE DATA 
% -------------------------------------------------------------------------
% Project               : Landscape planning for agro-industrial expansion 
%                         in a large, well-preserved savanna: how to plan 
%                         multifunctional landscapes at scale for nature and 
%                         people in the Orinoquia region, Colombia
% Author                : Jonathan Nogales Pimentel
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
% UserData [Struct]
%   .ArcID               [Cat,1]         = ID of each section of the network                     [Ad]
%   .Arc_InitNode        [Cat,1]         = Initial node of each section of the network           [Ad]
%   .Arc_EndNode         [Cat,1]         = End node of each section of the network               [Ad]
%   .ArcID_Downstream    [1,1]           = ID of the end node of accumulation                    [Ad]
%   .AccumVar            [Cat,Var]       = Variable to accumulate                                
%   .AccumStatus         [Cat,Var]       = Status of the accumulation variable == AccumVar       
%   .ArcIDFlood          [CatFlood,1]    = ID of the section of the network with floodplain      [Ad]
%   .FloodArea           [CatFlood,1]    = Floodplain Area                                       [m^2]
%   .IDExtAgri           [Cat,1]         = ID of the HUA where to extraction Agricultural Demand [Ad]
%   .IDExtDom            [Cat,1]         = ID of the HUA where to extraction Domestic Demand     [Ad]
%   .IDExtLiv            [Cat,1]         = ID of the HUA where to extraction Livestock Demand    [Ad]
%   .IDExtMin            [Cat,1]         = ID of the HUA where to extraction Mining Demand       [Ad]
%   .IDExtHy             [Cat,1]         = ID of the HUA where to extraction Hydrocarbons Demand [Ad]
%   .IDRetDom            [Cat,1]         = ID of the HUA where to return Domestic Demand         [Ad]
%   .IDRetLiv            [Cat,1]         = ID of the HUA where to return Livestock Demand        [Ad]
%   .IDRetMin            [Cat,1]         = ID of the HUA where to return Mining Demand           [Ad]
%   .IDRetHy             [Cat,1]         = ID of the HUA where to return Hydrocarbons Demand     [Ad]
%   .P                   [Cat,1]         = Precipitation                                         [mm]
%   .ETP                 [Cat,1]         = Actual Evapotrasnpiration                             [mm]
%   .Vh                  [CatFlood,1]    = Volume of the floodplain Initial                      [mm]
%   .Ql                  [CatFlood,1]    = Lateral flow between river and floodplain             [mm]
%   .Rl                  [CatFlood,1]    = Return flow from floodplain to river                  [mm]
%   .Trp                 [CatFlood,1]    = Percentage lateral flow between river and floodplain  [dimensionless]
%   .Tpr                 [CatFlood,1]    = Percentage return flow from floodplain to river       [dimensionless]
%   .Q_Umb               [CatFlood,1]    = Threshold lateral flow between river and floodplain   [mm]
%   .V_Umb               [CatFlood,1]    = Threshold return flow from floodplain to river        [mm]
%   .a                   [Cat,1]         = Soil Retention Capacity                               [dimensionless]
%   .b                   [Cat,1]         = Maximum Capacity of Soil Storage                      [dimensionless]
%   .Y                   [Cat,1]         = Evapotranspiration Potential                          [mm]
%   .PoPo                [Cat,1]         = ID of the HUA to calibrate                            [Ad]
%   .PoPoFlood           [Cat,1]         = ID of the HUA to calibrate with floodplains           [Ad]
%   .ArcID_Downstream2   [1,1]           = ID of the end node of accumulation                    [Ad]


ProgressBar     = waitbar(0, 'Load Data...');
wbch            = allchild(ProgressBar);
jp              = wbch(1).JavaPeer;
jp.setIndeterminate(1)

%% SCE or DDS main configuration
UserData.MethodOpti     = 'SCE';
% parallel version: false or 0, true or otherwise
if UserData.Parallel == 1
    UserData.parRuns    = 1; %true;
else
    UserData.parRuns    = 0; %true;
end
% Define pop_ini to force initial evaluation of this population. Values
% must be in real limits, otherwise pop_ini must be empty
UserData.pop_ini        = [];
% Maximum number of experiments or evaluations
UserData.maxIter        = 1000; 
% ncomp: number of complexes (sub-pop.)- between 2 and 20
UserData.ncomp          = 10;
% ComplexSize: number of members en each complex
UserData.complexSize    = 2;
% simplexSize: number of members en each simplex
UserData.simplexSize    = 2;
% evolutionSteps
UserData.evolSteps      = 2;
% Reflection step lengths in the Simplex method
UserData.alpha          = 0.8;
% Contraction step lengths in the Simplex method
UserData.beta           = 0.45;
% verbose mode: false or 0, true or otherwise
UserData.verbose        = 0;

%% Limit Parameters
a_min       = 0.01;     a_max       = 1;
b_min       = 1;        b_max       = 1000;
c_min       = 0.01;     c_max       = 1;
d_min       = 0.01;     d_max       = 1;
Q_Umb_min   = 1;        Q_Umb_max   = 3000;
V_Umb_min   = 1;        V_Umb_max   = 3000;
Trp_min     = 0.01;     Trp_max     = 1;
Tpr_min     = 0.01;     Tpr_max     = 1;
ExtSup_min  = 0.7;      ExtSup_max  = 1;

%% Crate Folder 
mkdir(fullfile(UserData.PathProject, 'FIGURES','Calibration'))
mkdir(fullfile(UserData.PathProject, 'FIGURES','Validation'))
mkdir(fullfile(UserData.PathProject, 'FIGURES','Validation','ValidationModel_ExtSub'))
mkdir(fullfile(UserData.PathProject, 'RESULTS','Parameters_Model'))
mkdir(fullfile(UserData.PathProject, 'RESULTS','Parameters_Model',UserData.MethodOpti))

%% PARALLEL POOL ON CLUSTER
if UserData.Parallel == 1
    try
       myCluster                = parcluster('local');
       myCluster.NumWorkers     = UserData.CoresNumber;
       saveProfile(myCluster);
       parpool;
    catch
    end
end

%% INPUT DATA
% -------------------------------------------------------------------------
% Parameter Thomas Model
% -------------------------------------------------------------------------
try
    Tmp = xlsread( fullfile(UserData.PathProject,'DATA','Params',UserData.DataParams), 'Thomas');
catch
    errordlg(['The Excel "',UserData.DataParams,'" not found'],'!! Error !!')
    return
end

UserData.ArcID              = Tmp(:,1);
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
[UserData.ArcID,id]         = sort(UserData.ArcID);
UserData.BasinArea          = UserData.BasinArea(id);
UserData.IDAq               = UserData.IDAq(id);
UserData.Arc_InitNode       = UserData.Arc_InitNode(id);
UserData.Arc_EndNode        = UserData.Arc_EndNode(id);
UserData.Sw                 = UserData.Sw(id);
UserData.Sg                 = UserData.Sg(id);


%% PARAMETERS
Tmp = NaN(length(UserData.ArcID), 1);
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

%% LOAD SCENARIOS
Scenario        = cell2mat(UserData.Scenarios(:,2));

%% Save Data
NameBasin       = cell(1,length(UserData.ArcID) + 1);
NameBasin{1}    = 'Date_Matlab';

ArcID = UserData.ArcID;
for k = 2:length(UserData.ArcID) + 1
    NameBasin{k} = ['Basin_',num2str(ArcID(k - 1))];
end

clearvars ArcID

%% Calibration Scenario
Sce = UserData.SceRef;

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
Demand = [];
Return = [];
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

% groundwater Demand
UserData.DemandSub = zeros(size(Demand(:,:,1)));

%% CALIBRACION
% Id Basin by Arcid Downstream
PoPo        = zeros(length(UserData.ArcID),1); 

% Id Basin with Floodplains
PoPoFlood   = zeros(length(UserData.ArcIDFlood),1);

PoPoID      = PoPo;
PoPoFloodID = PoPoFlood;

NumberCat   = unique(UserData.CatGauges);

SummaryCal  = [];
%%
close(ProgressBar)

Answer      = questdlg('Calibration Method', 'Calibration Model',...
            'Total','Sequential','Resume','');

% Handle response
switch Answer
    case 'Total'
        ControlCal = 0;
        ResumeCal   = 0;

    case 'Sequential'
        ControlCal = 1;
        ResumeCal   = 0;

    case 'Resume'
        ControlCal = 1;
        ResumeCal = 1;
end

TextResults = sprintf([ '------------------------------------------------------------------------------------------ \n',...
                        '                                    Results Calibration \n',...
                        '------------------------------------------------------------------------------------------']);
PrintResults(TextResults,0)

for i = 1:length(NumberCat)
    
    
    
    if i > 1
        TextResults = sprintf([TextResults, '\n------------------------------------------------------------------------------------------']);
        PrintResults(TextResults,0)
    end

    if ControlCal == 1
        Answer      = questdlg('Calibration HAU', 'Calibration Model',...
            ['Calibration HAU [Order ',num2str(i),']'],'Calibration Total','');

        % Handle response
        switch Answer
            case ['Calibration HAU [Order ',num2str(i),']']
                ControlCal = 1;
            case 'Calibration Total'
                ControlCal = 0;
        end

    end

    %%
    id = find(UserData.CatGauges == NumberCat(i) );

    SummaryCal_i    = NaN(length(id), 22);

    for j = 1:length(id)
                
        % time 
        tic
        
        UserData.DownGauges     = UserData.ArIDGauges(id(j));
        
                  
        [PoPo, PoPoFlood]       = GetNetwork( UserData.ArcID,...
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

        [~,PosiQ]               = ismember(UserData.CodeGauges(id(j)), CodeQ_CV);
        idC                     = (DateQ >= DateCal(PosiQ,1) & DateQ <= DateCal(PosiQ,2));

        [~,PosiQ]               = ismember(UserData.CodeGauges(id(j)), CodeGaugesQ);
        UserData.Qobs           = Qobs(idC ,PosiQ);

        [~,PosiQ]               = ismember(UserData.CodeGauges(id(j)), CodeQ_CV);
        idC                     = (DateP >= DateCal(PosiQ,1) & DateP <= DateCal(PosiQ,2));

        UserData.P              = P(idC,:);

        idC                     = (DateET >= DateCal(PosiQ,1) & DateET <= DateCal(PosiQ,2));
        UserData.ET             = ET(idC,:);

        idC                     = (DateD >= DateCal(PosiQ,1) & DateD <= DateCal(PosiQ,2));

        UserData.DemandSup      = Demand(idC,:,:);
        UserData.Returns        = Return(idC,:,:);
        UserData.Date           = DateD(idC);

        SummaryCal_i(j,1)       = UserData.CodeGauges(id(j));

        % Disp Results
        TextResults = sprintf([TextResults,'\n[Order = ',num2str(i),' - Control = ',num2str(j), ']  Gauges = ',num2str(UserData.ArIDGauges(id(j)))]);
        PrintResults(TextResults,0)

        if UserData.VerboseCal == 1
            disp(['[Order = ',num2str(i),' - Control = ',num2str(j), ']  Gauges = ',num2str(UserData.ArIDGauges(id(j)))])
            disp('-------------------------------------------')  
        end

        if ResumeCal == 1
            try
                load(fullfile(UserData.PathProject, 'RESULTS','Parameters_Model','SCE',...
                        [num2str(UserData.CodeGauges(id(j))),'-',num2str(UserData.DownGauges),'_SCE.mat']))

                if sum(PoPoFlood) == 0
                    CalMode = 1;
                    UserData.CalMode = CalMode;
                else
                    CalMode = 2;
                    UserData.CalMode = CalMode;
                end

            catch
            end

        else

            if sum(PoPoFlood) == 0
                CalMode = 1;
                UserData.CalMode = CalMode;

                [Param, Bestf, allbest, allEvals] = sce('Function_Obj',...
                                                        UserData.pop_ini,...
                                                        [a_min, b_min, c_min, d_min, ExtSup_min],...
                                                        [a_max, b_max, c_max, d_max, ExtSup_max],...
                                                        UserData.ncomp, UserData);

                save(fullfile(UserData.PathProject, 'RESULTS','Parameters_Model','SCE',...
                    [num2str(UserData.CodeGauges(id(j))),'-',num2str(UserData.DownGauges),'_SCE.mat']),...
                    'Param','Bestf','allbest','allEvals','CalMode')

            else
                CalMode = 2;
                UserData.CalMode = CalMode;
                [Param, Bestf, allbest, allEvals] = sce('Function_Obj',UserData.pop_ini,...
                                                        [a_min, b_min, c_min, d_min Q_Umb_min V_Umb_min Tpr_min Trp_min ExtSup_min],...
                                                        [a_max, b_max, c_max, d_max, Q_Umb_max V_Umb_max Tpr_max Trp_max ExtSup_max],...
                                                        UserData.ncomp, UserData);

                save(fullfile(UserData.PathProject, 'RESULTS','Parameters_Model','SCE',...
                    [num2str(UserData.CodeGauges(id(j))),'-',num2str(UserData.DownGauges),'_SCE.mat']),...
                    'Param','Bestf','allbest','allEvals','CalMode')
            end
        end

        % asignacion de parametros
        UserData.a(UserData.IDPoPo)  = Param(1);
        UserData.b(UserData.IDPoPo)  = Param(2);
        UserData.c(UserData.IDPoPo)  = Param(3);
        UserData.d(UserData.IDPoPo)  = Param(4);

        if UserData.CalMode == 1
            UserData.ParamExtSup(UserData.IDPoPo)    = Param(5);
        else
            UserData.ParamExtSup(UserData.IDPoPo)    = Param(9);

            UserData.Q_Umb(UserData.IDPoPoFlood)     = Param(5);
            UserData.V_Umb(UserData.IDPoPoFlood)     = Param(6);
            UserData.Tpr(UserData.IDPoPoFlood)       = Param(7);
            UserData.Trp(UserData.IDPoPoFlood)       = Param(8);
        end

        UserData.GaugesStreamFlowQ   = UserData.CodeGauges(id(j));

        % -------------------------------------------------------------------------
        % Plot Calibration Series
        % -------------------------------------------------------------------------
        [Fig, SummaryCal_i(j,2:end)] = PlotCalibrationModel(Param, UserData);

        saveas(Fig, fullfile(UserData.PathProject, 'FIGURES','Calibration',...
            [num2str(UserData.CodeGauges(id(j))),'-',num2str(UserData.DownGauges),'.jpg']))

        clearvars Fig

        Nash = 1 - Bestf;
        if Nash < 0.4
            TextResults = sprintf([TextResults,' ==>  #  Nash = ', num2str(Nash,'%0.3f'),'  Time = ',num2str(toc,'%0.1f'),' Seg']);
            PrintResults(TextResults,0)
        else
            TextResults = sprintf([TextResults,' ==>     Nash = ', num2str(Nash,'%0.3f'),'  Time = ',num2str(toc,'%0.1f'),' Seg']);
            PrintResults(TextResults,0)
        end

        if UserData.VerboseCal == 1
            disp(['  Nash = ', num2str(1 - Bestf,'%0.3f'),'  Time = ',num2str(toc,'%0.3f')])
            disp('-------------------------------------------') 
        end

    end

    if ResumeCal > 0
        TextResults = sprintf([TextResults,'\n Continue ......']);
        PrintResults(TextResults,1)
    end

    if ControlCal == 1

        Answer      = questdlg('Want recalibration some HUA?', 'Calibration Model',...
            'Yes','No','');

        % Handle response
        switch Answer
            case 'Yes'
                List = cell(1,length(id));

                for j = 1:length(id)
                    List{j} = ['HUA-',num2str(j),':     Order-',num2str(i)];
                end

                [i_ReCal,ReCal] = listdlg('ListString',List);
            case 'No'
                ReCal = 0;
        end

        if ReCal == 1
            for jj = 1:length(i_ReCal)

                j = i_ReCal(jj);

                UserData.DownGauges     = UserData.ArIDGauges(id(j));
                %  
                [PoPo, PoPoFlood]       = GetNetwork( UserData.ArcID,...
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

                [~,PosiQ]               = ismember(UserData.CodeGauges(id(j)), CodeQ_CV);
                idC                     = (DateQ >= DateCal(PosiQ,1) & DateQ <= DateCal(PosiQ,2));

                [~,PosiQ]               = ismember(UserData.CodeGauges(id(j)), CodeGaugesQ);
                UserData.Qobs           = Qobs(idC ,PosiQ);

                [~,PosiQ]               = ismember(UserData.CodeGauges(id(j)), CodeQ_CV);
                idC                     = (DateP >= DateCal(PosiQ,1) & DateP <= DateCal(PosiQ,2));

                UserData.P              = P(idC,:);

                idC                     = (DateET >= DateCal(PosiQ,1) & DateET <= DateCal(PosiQ,2));
                UserData.ET             = ET(idC,:);

                idC                     = (DateD >= DateCal(PosiQ,1) & DateD <= DateCal(PosiQ,2));

                UserData.DemandSup      = Demand(idC,:,:);
                UserData.Returns        = Return(idC,:,:);
                UserData.Date           = DateD(idC);

                SummaryCal_i(j,1)       = UserData.CodeGauges(id(j));

                TextResults = sprintf([TextResults,'\n[Order = ',num2str(i),' - Control = ',num2str(j), ']  Gauges = ',num2str(UserData.ArIDGauges(id(j)))]);
                PrintResults(TextResults,0)

                if UserData.VerboseCal == 1
                    disp(['[Order = ',num2str(i),' - HUA = ',num2str(j), ']  Gauges = ',num2str(UserData.ArIDGauges(id(j)))])
                    disp('-------------------------------------------')  
                end

                % SCE - Calibration
                if sum(PoPoFlood) == 0
                    CalMode = 1;
                    UserData.CalMode = CalMode;

                    [Param, Bestf, allbest, allEvals] = sce('Function_Obj',...
                                                            UserData.pop_ini,...
                                                            [a_min, b_min, c_min, d_min, ExtSup_min],...
                                                            [a_max, b_max, c_max, d_max, ExtSup_max],...
                                                            UserData.ncomp, UserData);

                    save(fullfile(UserData.PathProject, 'RESULTS','Parameters_Model','SCE',...
                        [num2str(UserData.CodeGauges(id(j))),'-',num2str(UserData.DownGauges),'_SCE.mat']),...
                        'Param','Bestf','allbest','allEvals','CalMode')

                else
                    CalMode = 2;
                    UserData.CalMode = CalMode;
                    [Param, Bestf, allbest, allEvals] = sce('Function_Obj',UserData.pop_ini,...
                                                            [a_min, b_min, c_min, d_min Q_Umb_min V_Umb_min Tpr_min Trp_min ExtSup_min],...
                                                            [a_max, b_max, c_max, d_max, Q_Umb_max V_Umb_max Tpr_max Trp_max ExtSup_max],...
                                                            UserData.ncomp, UserData);

                    save(fullfile(UserData.PathProject, 'RESULTS','Parameters_Model','SCE',...
                        [num2str(UserData.CodeGauges(id(j))),'-',num2str(UserData.DownGauges),'_SCE.mat']),...
                        'Param','Bestf','allbest','allEvals','CalMode')
                end

                % asignacion de parametros
                UserData.a(UserData.IDPoPo)  = Param(1);
                UserData.b(UserData.IDPoPo)  = Param(2);
                UserData.c(UserData.IDPoPo)  = Param(3);
                UserData.d(UserData.IDPoPo)  = Param(4);

                if UserData.CalMode == 1
                    UserData.ParamExtSup(UserData.IDPoPo)    = Param(5);
                else
                    UserData.ParamExtSup(UserData.IDPoPo)    = Param(9);

                    UserData.Q_Umb(UserData.IDPoPoFlood)     = Param(5);
                    UserData.V_Umb(UserData.IDPoPoFlood)     = Param(6);
                    UserData.Tpr(UserData.IDPoPoFlood)       = Param(7);
                    UserData.Trp(UserData.IDPoPoFlood)       = Param(8);
                end

                UserData.GaugesStreamFlowQ   = UserData.CodeGauges(id(j));

                % -------------------------------------------------------------------------
                % Plot Calibration Series
                % -------------------------------------------------------------------------
                [Fig, SummaryCal_i(j,2:end)] = PlotCalibrationModel(Param, UserData);

                saveas(Fig, fullfile(UserData.PathProject, 'FIGURES','Calibration',...
                    [num2str(UserData.CodeGauges(id(j))),'-',num2str(UserData.DownGauges),'.jpg']))

                clearvars Fig

                Nash = 1 - Bestf;
                if Nash < 0.4
                    TextResults = sprintf([TextResults,' ==>  #  Nash = ', num2str(Nash,'%0.3f'),'  Time = ',num2str(toc,'%0.1f'),' Seg']);
                    PrintResults(TextResults,0)
                else
                    TextResults = sprintf([TextResults,' ==>     Nash = ', num2str(Nash,'%0.3f'),'  Time = ',num2str(toc,'%0.1f'),' Seg']);
                    PrintResults(TextResults,0)
                end

                if UserData.VerboseCal == 1
                    disp(['  Nash = ', num2str(1 - Bestf,'%0.3f'),'  Time = ',num2str(toc,'%0.3f')])
                    disp('-------------------------------------------') 
                end
            end
        end
    end

    SummaryCal = [SummaryCal; SummaryCal_i];
    
end

close(gcf)

%% VALIDATION
% Id Basin by Arcid Downstream
PoPo        = zeros(length(UserData.ArcID),1); 
% Id Basin with Floodplains
PoPoFlood   = zeros(length(UserData.ArcIDFlood),1);

PoPoID      = PoPo;
PoPoFloodID = PoPoFlood;

NumberCat   = unique(UserData.CatGauges);

SummaryVal  = [];

TextResults = sprintf([ '------------------------------------------------------------------------------------------ \n',...
                        '                                    Results Validation \n',...
                        '------------------------------------------------------------------------------------------']);
PrintResults(TextResults,0)

for i = 1:length(NumberCat)

    id = find(UserData.CatGauges == NumberCat(i) );
    SummaryVal_i  = NaN(length(id), 22);

    for j = 1:length(id)

        UserData.DownGauges = UserData.ArIDGauges(id(j));
        
        [PoPo, PoPoFlood] = GetNetwork( UserData.ArcID,...
                      UserData.Arc_InitNode, UserData.Arc_EndNode,...
                      UserData.ArIDGauges(id(j)), PoPo, PoPoFlood, UserData.ArcIDFlood);

        PoPoID                  = (PoPoID + PoPo);
        PoPoFloodID             = (PoPoFloodID + PoPoFlood);

        UserData.IDPoPo         = (PoPoID  == 1);
        UserData.IDPoPoFlood    = (PoPoFloodID  == 1);

        UserData.PoPo           = logical(PoPo);
        UserData.PoPoFlood      = logical(PoPoFlood);

        % Streamflow
        [~,PosiQ]   = ismember(UserData.CodeGauges(id(j)), CodeQ_CV);
        idC = find(DateQ >= DateVal(PosiQ,1) & DateQ <= DateVal(PosiQ,2));

        if isnan(DateVal(PosiQ,2))
            continue
        end

        % Date
        UserData.DateQobs   = DateD(idC);

        [~,PosiQ]       = ismember(UserData.CodeGauges(id(j)), CodeGaugesQ);
        UserData.Qobs   = Qobs(idC ,PosiQ);

        UserData.P          = P;
        UserData.ET         = ET;
        UserData.DemandSup  = Demand;
        UserData.Returns    = Return;

        % Date
        UserData.Date       = DateD;

        UserData.GaugesStreamFlowQ   = UserData.CodeGauges(id(j));

        SummaryVal_i(j,1) = UserData.CodeGauges(id(j));

        disp(num2str(UserData.CodeGauges(id(j))))

        %% plot 1
        [Fig, SummaryVal_i(j,2:end)] = PlotValidationModel(UserData);

        saveas(Fig, fullfile(UserData.PathProject, 'FIGURES','Validation',...
            [num2str(UserData.CodeGauges(id(j))),'-',num2str(UserData.DownGauges),'.jpg']))

        close all 
        clearvars Fig

        Nash = SummaryVal_i(j,2);
        if Nash < 0.4
            TextResults = sprintf([TextResults,...
                '\n[Order = ',num2str(i),' - Control = ',num2str(j), ']  Gauges = ',num2str(UserData.ArIDGauges(id(j))),...
                ' ==>  #  Nash = ', num2str(Nash,'%0.3f'),'  Time = ',num2str(toc,'%0.1f'),' Seg']);
            PrintResults(TextResults,0)
        else
            TextResults = sprintf([TextResults,...
                '\n[Order = ',num2str(i),' - Control = ',num2str(j), ']  Gauges = ',num2str(UserData.ArIDGauges(id(j))),...
                ' ==>     Nash = ', num2str(Nash,'%0.3f'),'  Time = ',num2str(toc,'%0.1f'),' Seg']);
            PrintResults(TextResults,0)
        end

    end
    ik = isnan(SummaryVal_i(:,1)) == 0;
    SummaryVal_i = SummaryVal_i(ik,:);
    SummaryVal = [SummaryVal; SummaryVal_i];
    
end

close(gcf)

% save Metric get to calibration
save(fullfile(UserData.PathProject, 'RESULTS','Parameters_Model','Metric.mat'),'SummaryCal', 'SummaryVal')

ProgressBar     = waitbar(0, 'Parameters Assignation...');
wbch            = allchild(ProgressBar);
jp              = wbch(1).JavaPeer;
jp.setIndeterminate(1)

%% Parameters Assignation 
CBNC = unique(UserData.TypeBasinCal(logical(PoPoID ==  0)));
for i = 1:length(CBNC)
    id = UserData.TypeBasinCal == CBNC(i);

    UserData.a(id)  = UserData.a(UserData.ArcID== CBNC(i) );
    UserData.b(id)  = UserData.b(UserData.ArcID== CBNC(i) );
    UserData.c(id)  = UserData.c(UserData.ArcID== CBNC(i) );
    UserData.d(id)  = UserData.d(UserData.ArcID== CBNC(i) );
    UserData.ParamExtSup(id) = UserData.d(UserData.ArcID== CBNC(i) );
end

CodeType    = UserData.ArcIDFlood(logical(PoPoFloodID ==  0));
[~,id]      = ismember(CodeType, UserData.ArcID);

CBNC        = UserData.TypeBasinCal(id);
CCNC        = unique(CBNC);

for i = 1:length(CCNC)
    id                  = CBNC == CCNC(i);
    [~,id]              = ismember(CodeType(id), UserData.ArcIDFlood);
    id2                 = UserData.ArcIDFlood ==  CCNC(i);

    UserData.Q_Umb(id) = UserData.Q_Umb(id2);
    UserData.V_Umb(id) = UserData.V_Umb(id2);
    UserData.Tpr(id)   = UserData.Tpr(id2);
    UserData.Trp(id)   = UserData.Trp(id2);
end

% Thomas Parameters 
Params.a            = UserData.a;
Params.b            = UserData.b;
Params.c            = UserData.c;
Params.d            = UserData.d;

% Floodplains Parameters
Params.Q_Umb        = UserData.Q_Umb;
Params.V_Umb        = UserData.V_Umb;
Params.Tpr          = UserData.Tpr;
Params.Trp          = UserData.Trp;

% Extract Demand Parameter
Params.ParamExtSup  = UserData.ParamExtSup;

% Save Parameters model
save(fullfile(UserData.PathProject, 'RESULTS','Parameters_Model','ParamModel_Complet.mat'),'Params')

% Save project update
save(fullfile(UserData.PathProject, [UserData.NameProject,'.mat']),'UserData')

% Update Parameters table
Tam = length(Params.a);

xlswrite( fullfile(UserData.PathProject,'DATA','Params',UserData.DataParams),...
    [UserData.ArcID UserData.BasinArea UserData.TypeBasinCal UserData.IDAq UserData.Arc_InitNode UserData.Arc_EndNode,...
    UserData.Sw UserData.Sg Params.a Params.b Params.c Params.d Params.ParamExtSup (1-Params.ParamExtSup)] ,...
    'Thomas',['A2:N',num2str(Tam + 1)]);

Tam = length(Params.Trp);
xlswrite( fullfile(UserData.PathProject,'DATA','Params',UserData.DataParams),...
    [UserData.ArcIDFlood UserData.FloodArea UserData.Vh,...
    Params.Trp Params.Tpr Params.Q_Umb Params.V_Umb] ,...
    'Floodplains',['A2:G',num2str(Tam + 1)]);

close(ProgressBar)

%% Operation Completed
[Icon,~] = imread('Completed.jpg'); 
msgbox('Operation Completed','Success','custom',Icon);