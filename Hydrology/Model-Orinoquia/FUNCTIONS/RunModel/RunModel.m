% function UserData = RunModel(UserData)
% /usr/bin/Matlab-R2016b
% -------------------------------------------------------------------------
% Run Model - HMO
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

%% INPUT DATA
% -------------------------------------------------------------------------
% Parameter Thomas Model
% -------------------------------------------------------------------------
wb = waitbar(0, 'Processing...');
wbch = allchild(wb);
jp = wbch(1).JavaPeer;
jp.setIndeterminate(1)

UserData.DataParams     = 'Parameters.xlsx';

try
    Tmp = xlsread( fullfile(UserData.PathProject,'DATA','Params',UserData.DataParams), 'Thomas');
catch
    errordlg(['The Excel "',UserData.DataParams,'" not found'],'!! Error !!')
    close(wb)
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
UserData.a                  = Tmp(:,9);
UserData.b                  = Tmp(:,10);
UserData.c                  = Tmp(:,11);
UserData.d                  = Tmp(:,12);
UserData.ParamExtSup        = Tmp(:,13);
UserData.ParamExtSub        = Tmp(:,14);

% -------------------------------------------------------------------------
% Parameter and States Variable Floodplains
% -------------------------------------------------------------------------
try
    Tmp = xlsread( fullfile(UserData.PathProject,'DATA','Params',UserData.DataParams), 'Floodplains');
catch
    errordlg(['The Excel "',UserData.DataParams,'" not found'],'!! Error !!')
    close(wb)
    return
end

UserData.ArcIDFlood         = Tmp(:,1);
UserData.FloodArea          = Tmp(:,2);
UserData.Vh                 = Tmp(:,3);
UserData.Trp                = Tmp(:,4);
UserData.Tpr                = Tmp(:,5);
UserData.Q_Umb              = Tmp(:,6);
UserData.V_Umb              = Tmp(:,7);
% -------------------------------------------------------------------------
% River Downstream
% -------------------------------------------------------------------------
try
    Tmp = xlsread( fullfile(UserData.PathProject,'DATA','Params',UserData.DataParams), 'Downstream');
catch
    errordlg(['The Excel "',UserData.DataParams,'" not found'],'!! Error !!')
    close(wb)
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
    close(wb)
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
    close(wb)
    return
end

Tmp1 = Tmp(:,1:5);
UserData.IDExt      = Tmp1(isnan(Tmp1) == 0);

Tmp1 = Tmp(:,6:9);
UserData.IDRetMin   = Tmp1(isnan(Tmp1) == 0);

% -------------------------------------------------------------------------
% Demand and Returns Paremeters
% -------------------------------------------------------------------------
try
    [Tmp, Tmp1] = xlsread( fullfile(UserData.PathProject,'DATA','Params',UserData.DataParams), 'Interest_Points');
    Tmp = Tmp(isnan(Tmp) == 0);
    UserData.Interest_Points_Code = Tmp;
    UserData.Interest_Points_Name = Tmp1(2:length(Tmp)+1);
    
catch
    errordlg(['The Excel "',UserData.DataParams,'" not found'],'!! Error !!')
    close(wb)
    return
end

%% SCENARIOS
Scenario        = cell2mat(UserData.Scenarios(:,2));

%% Save Data
NameBasin       = cell(1,length(UserData.ArcID) + 1);
NameBasin{1}    = 'Date_Matlab';

for k = 2:length(UserData.ArcID) + 1
    NameBasin{k} = num2str(UserData.ArcID(k - 1));
end

for Sce = 1:length(Scenario)
    
  %% LOAD CLIMATE DATA
    % -------------------------------------------------------------------------
    % Precipitation 
    % -------------------------------------------------------------------------
    try
        P = dlmread(fullfile(UserData.PathProject,'RESULTS','P',['Pcp_Scenario-',num2str(Scenario(Sce)),'.dat']),',',1,1);
        DateP   = P(:,1);
        P       = P(:,2:end);
    catch
        errordlg('The Precipitation Data Not Found','!! Error !!')
        close(wb)
        return
    end
    
    % -------------------------------------------------------------------------
    % Evapotranspiration
    % -------------------------------------------------------------------------
    try
        ETP     = dlmread(fullfile(UserData.PathProject,'RESULTS','ETP',['ETP_Scenario-',num2str(Scenario(Sce)),'.dat']),',',1,1);
        DateET  = ETP(:,1);
        ETP     = ETP(:,2:end);
    catch
        errordlg('The Evapotranspiration Data Not Found','!! Error !!')
        close(wb)
        return
    end
    
    %% LOAD DEMAND DATA  
    % TOTAL DEMAND 
    for dr = 1:2
        for i = 1:length(UserData.DemandVar)
            DeRe = {'Demand','Return'};
            try
                Tmp     = dlmread(fullfile(UserData.PathProject,'RESULTS','Demand',UserData.DemandVar{i},['Scenario-',num2str(Scenario(Sce))],['Total_',DeRe{dr},'.dat']),',',1,1);
                Tmp(isnan(Tmp)) = 0;
                eval([DeRe{dr},'(:,:,',num2str(i),') = Tmp(:,2:end);']);
            catch
                eval([DeRe{dr},'(:,:,',num2str(i),') = Tmp(:,2:end)*0;']);
            end
        end
    end
    DateD = Tmp(:,1);
    
    Demand(isnan(Demand))       = 0;
    Return(isnan(Return))       = 0;
                
    %% VALIDATION
    UserData.P          = P;
    UserData.ET         = ETP;
    UserData.DemandSup  = Demand;
    UserData.Returns    = Return;
    UserData.Date       = DateD;
    
    %%
    [VAc,Esc, ETR, StatesMT, StatesMF] = HMO(   UserData.Date,...
                                                UserData.P,...
                                                UserData.ET,...
                                                UserData.DemandSup,...
                                                UserData.ParamExtSub,...
                                                UserData.Returns,...
                                                UserData.BasinArea,...
                                                UserData.FloodArea,... 
                                                UserData.ArcID,...
                                                UserData.Arc_InitNode,...
                                                UserData.Arc_EndNode,...
                                                UserData.ArcID_Downstream,...
                                                UserData.a,...
                                                UserData.b,...
                                                UserData.c,...
                                                UserData.d,...
                                                UserData.Tpr,...
                                                UserData.Trp,...
                                                UserData.Q_Umb,...
                                                UserData.V_Umb,...
                                                UserData.IDExtAgri,...
                                                UserData.IDExtDom,...
                                                UserData.IDExtLiv,... 
                                                UserData.IDExtMin,...
                                                UserData.IDExtHy,... 
                                                UserData.IDRetDom,...
                                                UserData.IDRetLiv,...
                                                UserData.IDRetMin,...
                                                UserData.IDRetHy,...
                                                UserData.ArcIDFlood,...
                                                UserData.ParamExtSup,...
                                                UserData.Sw,...
                                                UserData.Sg,...
                                                UserData.Vh,...
                                                UserData.IDAq);
    
    %% Results
    if UserData.SceRef == Scenario(Sce)
        Qref = reshape(VAc(:,1,:),length(UserData.ArcID), length(UserData.Date))';
    end
    
    if UserData.SceRef == Scenario(Sce)
        VariablesResults(Scenario(Sce), VAc, Esc, P, ETP, ETR, StatesMT, StatesMF, UserData)
    else
        VariablesResults(Scenario(Sce), VAc, Esc, P, ETP, ETR, StatesMT, StatesMF, UserData, Qref)
    end
    
end
close(wb)


%% Operation Completed
[Icon,~] = imread('Completed.jpg'); 
msgbox('Operation Completed','Success','custom',Icon);
