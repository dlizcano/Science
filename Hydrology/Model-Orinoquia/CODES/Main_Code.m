% /usr/bin/Matlab-R2016b
% -------------------------------------------------------------------------
% Main Model - HMO
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

%% Parameters
% Name Project
UserData.PathProject            = '/media/nogales/NogalesBackup/Orinoquia/PROJECT/OrinoquiaModel/';
UserData.NameProject            = 'Orinoquia_SNAPP';
UserData.Parallel               = 0;
UserData.VerboseCal             = 0;
UserData.CoresNumber            = 1;
UserData.ModeModel              = 2;

% --------------------------------------------------------------------
% Climate or Hydrological Data 
% --------------------------------------------------------------------
UserData.ClimateVar             = {'Precipitation'  'Temperature'  'Evapotranspiration'};
UserData.Inc_Climate            = 1;
UserData.Cal_ETP                = 2;
UserData.TypeDataPrecipitation  = 2;
UserData.TypeDataTemperature    = 2;
UserData.Mode                   = 3;
UserData.DataPrecipitation      = 'Precipitation.xlsx';
UserData.DataTemperature        = 'Temperature.xlsx';
UserData.DataStreamFlow         = 'Hydrological.xlsx';

% --------------------------------------------------------------------
% Demand Data
% --------------------------------------------------------------------
UserData.DemandVar              = {'Agricultural','Domestic','Livestock','Hydrocarbons','Mining'};
UserData.Inc_Demand             = 1; 
UserData.Inc_Agricultural       = 1;
UserData.Inc_Domestic           = 1;
UserData.Inc_Livestock          = 1;
UserData.Inc_Hydrocarbons       = 1;
UserData.Inc_Mining             = 1;

% True or False Calculated Demand
UserData.Cal_Agricultural       = 1;
UserData.Cal_Domestic           = 1;
UserData.Cal_Livestock          = 1;
UserData.Cal_Hydrocarbons       = 1;
UserData.Cal_Mining             = 1;

% Load Data
UserData.DataAgricultural       = 1;
UserData.DataDomestic           = 2;
UserData.DataLivestock          = 3;
UserData.DataHydrocarbons       = 3;
UserData.DataMining             = 3;

% --------------------------------------------------------------------
% Geografic Data 
% --------------------------------------------------------------------
UserData.ShapeFileHUA           = 'HUA.shp';
UserData.GridDEM                = 'DEM.tif';
UserData.ShapeFileNetwork       = 'Network.xlsx';
UserData.DataParams             = 'Parameters.xlsx';

% --------------------------------------------------------------------
% Run Scenarios 
% --------------------------------------------------------------------
UserData.Scenarios              = {'Calibracion', 1};

%% Crete Folders
mkdir(fullfile(UserData.PathProject,'FIGURES'))
mkdir(fullfile(UserData.PathProject,'PARAMETERS'))
mkdir(fullfile(UserData.PathProject,'RESULTS'))
mkdir(fullfile(UserData.PathProject,'DATA'))
mkdir(fullfile(UserData.PathProject,'DATA','Climate'))
mkdir(fullfile(UserData.PathProject,'DATA','Climate','Precipitation'))
mkdir(fullfile(UserData.PathProject,'DATA','Climate','Temperature'))
mkdir(fullfile(UserData.PathProject,'DATA','Climate','Evapotranspiration'))
mkdir(fullfile(UserData.PathProject,'DATA','Hydrological'))
mkdir(fullfile(UserData.PathProject,'DATA','Params'))
mkdir(fullfile(UserData.PathProject,'DATA','Demand'))
mkdir(fullfile(UserData.PathProject,'DATA','Demand','Mining-Demand'))
mkdir(fullfile(UserData.PathProject,'DATA','Demand','Mining-Demand','Value'))
mkdir(fullfile(UserData.PathProject,'DATA','Demand','Mining-Demand','Module'))
mkdir(fullfile(UserData.PathProject,'DATA','Demand','Livestock-Demand'))
mkdir(fullfile(UserData.PathProject,'DATA','Demand','Livestock-Demand','Value'))
mkdir(fullfile(UserData.PathProject,'DATA','Demand','Livestock-Demand','Module'))
mkdir(fullfile(UserData.PathProject,'DATA','Demand','Hydrocarbons-Demand'))
mkdir(fullfile(UserData.PathProject,'DATA','Demand','Hydrocarbons-Demand','Value'))
mkdir(fullfile(UserData.PathProject,'DATA','Demand','Hydrocarbons-Demand','Module'))
mkdir(fullfile(UserData.PathProject,'DATA','Demand','Domestic-Demand'))
mkdir(fullfile(UserData.PathProject,'DATA','Demand','Domestic-Demand','Value'))
mkdir(fullfile(UserData.PathProject,'DATA','Demand','Domestic-Demand','Module'))
mkdir(fullfile(UserData.PathProject,'DATA','Demand','Agricultural-Demand'))
mkdir(fullfile(UserData.PathProject,'DATA','Demand','Agricultural-Demand','Value'))
mkdir(fullfile(UserData.PathProject,'DATA','Demand','Agricultural-Demand','Module'))
mkdir(fullfile(UserData.PathProject,'DATA','Geografic'))
mkdir(fullfile(UserData.PathProject,'DATA','Geografic','DEM'))
mkdir(fullfile(UserData.PathProject,'DATA','Geografic','HUA'))
mkdir(fullfile(UserData.PathProject,'DATA','Geografic','Network'))
mkdir(fullfile(UserData.PathProject,'DATA','Geografic','SU'))
mkdir(fullfile(UserData.PathProject,'DATA','Geografic','SUD'))
mkdir(fullfile(UserData.PathProject,'DATA','Geografic','Other'))  

%% Data PreProcessing
% --------------------------------------------------------------------
% Demand Data
% --------------------------------------------------------------------
if UserData.Inc_Demand == 1
    Pre_Procesing_DemandData(UserData)
end

% --------------------------------------------------------------------
% Climate Data
% --------------------------------------------------------------------
if UserData.Inc_Climate == 1
    Pre_Procesing_ClimateData(UserData)
end

%% Calibration or Run Model 
if UserData.ModeModel == 1
    UserData = RunModel(UserData);
elseif UserData.ModeModel == 2
    UserData = CalibrationModel(UserData);
end 

%% Data PostProcessing
