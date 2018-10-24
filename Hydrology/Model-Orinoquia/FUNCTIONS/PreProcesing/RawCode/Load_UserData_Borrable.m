function UserData = Load_UserData(NameExcelMain, PathModelData, NameProject)
%/usr/bin/Matlab-R2016b
%% Load User Data
%% BASE DATA 
% Project               : Landscape planning for agro-industrial expansion 
%                         in a large, well-preserved savanna: how to plan 
%                         multifunctional landscapes at scale for nature
%                         and people in the Orinoquia region, Colombia
% Author                : Jonathan Nogales Pimentel
% Email                 : nogales02@hotmail.com
% Hydrology Specialist  : Carlos Andrés Rogéliz
% Company               : The Nature Conservancy - TNC
% 
% Copyright (C) 2017 Apox Technologies
% This program is free software: you can redistribute it and/or modify it 
% under the terms of the GNU General Public License as published by the 
% Free Software Foundation, either version 3 of the License, or option) any 
% later version. This program is distributed in the hope that it will be 
% useful, but WITHOUT ANY WARRANTY; without even the implied warranty of 
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
% ee the GNU General Public License for more details. You should have 
% received a copy of the GNU General Public License along with this program
% If not, see http://www.gnu.org/licenses/.
%
% INPUTS
% OUTPUTS
%% 

ProgressBar = waitbar(0,'Please wait...');

%% SHEETS EXCEL MAIN
UserData.NameProject        = NameProject;
% Excel Main
UserData.PathExcelMain      = NameExcelMain; 
% Main
UserData.SheetMain          = 'Main';
% Topological Network Data
UserData.SheetParams        = 'Params';
% Topological Network Data
UserData.SheetNetwork       = 'Topological-Network';
% Gauges Catalog
UserData.SheetGaugesCatalog = 'Gauges-Catalog';
% Interpolation Points
UserData.SheetClimate       = 'Climate';
% Climate Varibles
UserData.ClimateVar         = {'Precipitation', 'Temperature', 'Evapotranspiration'};
% Demand Variables
UserData.DemandVar          = {'Agricultural','Domestic','Livestock','Hydrocarbons','Mining'};

%% LOAD EXCEL
try
    % Load Excel - Sheet = Main
    [TmpN,Tmp]       = xlsread(NameExcelMain, UserData.SheetMain ,'A15:H40');
    % Load Excel - Sheet = Gauges Catalog
    TopoNetwork     = xlsread(NameExcelMain, UserData.SheetNetwork);
catch
    errordlg(['The File "',NameExcelMain,'" not found','!! Error !!'])
    return
end

waitbar(1 / 5)

%% INPUT USER
% % Cores Number
% UserData.CoresNumber                = Tmp{1,2};
% % Model Mode
% UserData.ModeModel                  = Tmp{2,2};
% % Calculation of Evapotranspiration
% UserData.Cal_ETP                    = Tmp{3,2};
% % Data Type Evapotranspiration or Temperature
% if strcmp(UserData.Cal_ETP,'None')
%     UserData.TypeDataEvapotranspiration = Tmp{4,2};
% else
%     UserData.TypeDataTemperature    = Tmp{6,2};
% end
% % Data Type Precipitation
% UserData.TypeDataPrecipitation      = Tmp{5,2};
% % Calculation of Agricultural Demand
% UserData.Cal_Agricultural           = Tmp{7,2};
% % Calculation of Domestic Demand
% UserData.Cal_Domestic               = Tmp{8,2};
% % Calculation of Livestock Demand
% UserData.Cal_Livestock              = Tmp{9,2};
% % Calculation of Hydrocarbons Demand
% UserData.Cal_Hydrocarbons           = Tmp{10,2};
% % Calculation of Mining Demand
% UserData.Cal_Mining                 = Tmp{11,2};
% Data Path
UserData.PathsData                  = fullfile(PathModelData,Tmp{14,2});
% % Figures Path
% UserData.PathsFigures               = fullfile(PathModelData,'FIGURES');
% % Parameters Path
% UserData.PathsParameters            = fullfile(PathModelData,'PARAMETERS');
% % Results Path
% UserData.PathsResults               = fullfile(PathModelData,'RESULTS');
% % Temporal Path
% UserData.PathsTmp                   = fullfile(PathModelData,'TMP');
% Demand Data Path
UserData.PathsDemand                = fullfile(UserData.PathsData,Tmp{17,2});
% climate Data Path
UserData.PathsClimate               = fullfile(UserData.PathsData,Tmp{18,2});
% Hydrological Data Path
UserData.PathsHydrological          = fullfile(UserData.PathsData,Tmp{19,2});
% Geographic Data Path
UserData.PathsGeographic            = fullfile(UserData.PathsData,Tmp{20,2});
% % Agricultural Demand Data Path
% UserData.PathsDemand_Agricultural   = fullfile(UserData.PathsDemand,Tmp{14,5});
% Domestic Demand Data Path
% UserData.PathsDemand_Domestic       = fullfile(UserData.PathsDemand,Tmp{15,5});
% Livestock Demand Data Path
% UserData.PathsDemand_Livestock      = fullfile(UserData.PathsDemand,Tmp{16,5});
% Hydrocarbons Demand Data Path
% UserData.PathsDemand_Hydrocarbons   = fullfile(UserData.PathsDemand,Tmp{17,5});
% Mining Demand Data Path
% UserData.PathsDemand_Mining         = fullfile(UserData.PathsDemand,Tmp{18,5});
% Spatial Unit Path
% UserData.PathsSU                    = fullfile(UserData.PathsGeographic,Tmp{21,5});
% Spatial Unit of Distribution Path
% UserData.PathsSUD                   = fullfile(UserData.PathsGeographic,Tmp{22,5});
% Hydrological Unit of Analisis Path
UserData.PathsHUA                   = fullfile(UserData.PathsGeographic,Tmp{23,5});
% Precipitation Data
UserData.PathPrecipitation          = fullfile(UserData.PathsClimate,Tmp{14,8});

waitbar(2 / 5)

% Evapotranspiration Data
if ~strcmp(UserData.Cal_ETP,'None')
    UserData.PathEvapotranspiration = fullfile(UserData.PathsClimate,Tmp{15,8});
end
% Temperature Data
if strcmp(UserData.Cal_ETP,'None')
    UserData.PathTemperature    = fullfile(UserData.PathsClimate,Tmp{16,8});
end

% Extent Rasters DEM
% UserData.ExtentDEM              = [Tmp{11,5}; Tmp{12,5}; Tmp{13,5}; Tmp{14,5}];

% Precipitation Excel
if strcmp(UserData.TypeDataPrecipitation,'Point')
    [tn,tt] = xlsread(NameExcelMain, UserData.SheetClimate ,'B2:XFD2');
    UserData.ExcelPrecipitation     = fullfile(UserData.PathPrecipitation,tt{1,1});
    UserData.ScenarioPrecipitation  = tn;
end

% Temperature Excel
if ~strcmp(UserData.Cal_ETP,'None')
    if strcmp(UserData.TypeDataTemperature,'Point')
        [tn,tt] = xlsread(NameExcelMain, UserData.SheetClimate ,'B3:XFD3');
        UserData.ExcelTemperature       = fullfile(UserData.PathTemperature,tt{1,1});
        UserData.ScenarioTemperature    = tn;
    end
else
    if strcmp(UserData.TypeDataEvapotranspiration,'Point')
        [tn,tt] = xlsread(NameExcelMain, UserData.SheetClimate ,'B4:XFD4');
        UserData.ExcelEvapotranspiration    = fullfile(UserData.PathEvapotranspiration,tt{1,1});
        UserData.ScenarioEvapotranspiration = tn;
    end
end

waitbar(3 / 5)

% Stremflow Data
% UserData.ExcelStreamFlow    = fullfile(UserData.PathsHydrological,Tmp{19,8});
% % Grid DEM
% UserData.PathGridDEM        = fullfile(UserData.PathsGeographic,Tmp{24,5}, Tmp{21,8});
% % Value NAN DEM
UserData.ValueNaNRaster     = Tmp{22,8};
% % Shapefile HUA
% UserData.ShapeFileHUA       = fullfile(UserData.PathsHUA,Tmp{20,8});

% Data Demand
id  = {Tmp{7,2}; Tmp{8,2}; Tmp{9,2}; Tmp{10,2}; Tmp{11,2}};
for j = 1:length(id)
    if strcmp(id{j},'Calculation')
        [Tmp,~,Tmpp]    = xlsread(NameExcelMain, ['Demand_',UserData.DemandVar{j}]);
        Tmp1            = Tmpp(2:end,[1 2]);
        Data            = {};
        Tmp(isnan(Tmp)) = 0;
        for i = 1:length(Tmp1(:,1))
            tt = Tmp1{i,1};
            if isnan(tt)
            else
                Value       = ['Value_',Tmp1{i,2}];
                Module      = ['Module_',Tmp1{i,2}];
                Data{i,1}   = Tmp1{i,1};     
                Data{i,2}   = eval(['fullfile(UserData.PathsDemand_',UserData.DemandVar{j},',Value)']);
                Data{i,3}   = eval(['fullfile(UserData.PathsDemand_',UserData.DemandVar{j},',Module)']);
                Data{i,4}   = Tmp(i,:);
            end
        end        
        eval(['UserData.Data',UserData.DemandVar{j},' = Data;'])
    end
end

waitbar(4 / 5)

UserData.PathResults_Precipitation      = fullfile(UserData.PathsResults,'P');
UserData.PathResults_Evapotranspiration = fullfile(UserData.PathsResults,'ETP');

if strcmp(UserData.TypeDataPrecipitation,'Point') || strcmp(UserData.TypeDataTemperature,'Point') || strcmp(UserData.TypeDataEvapotranspiration,'Point')
    % Load Excel - Sheet = Gauges Catalog
    [Tmp2, TmpC]            = xlsread(NameExcelMain, UserData.SheetGaugesCatalog );
    % Gauges Catalog
%     UserData.GaugesCatalog  = Tmp2(:,[1 4 5 6]);
    % Gauges Catalog
%     UserData.NameGauges     = TmpC(2:1 + length(Tmp2(:,1)),2);
end

% save Topological Network
save(fullfile(UserData.PathsParameters,['Topological_Network',NameProject,'.mat']),'TopoNetwork')
% Save User Data 
save(fullfile(UserData.PathsParameters,['UserData_',NameProject,'.mat']),'UserData')

waitbar(5 / 5)

close(ProgressBar);

%% Operation Completed
[Icon,~] = imread('Completed.jpg'); 
msgbox('Operation Completed','Success','custom',Icon);
