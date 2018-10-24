function Pre_Procesing_ClimateData_Opti(UserData)
%/usr/bin/Matlab-R2016b
%% DATA PRE-PROCESING
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
% try
%     delete(gcp('nocreate'))
% catch
%     matlabpool close force
% end

%% Precision factor to save memory
% For DEM
PFSM_D = 1000;
% For Climate Data 
PFSM_C = 10;

%% Folder Resulst
mkdir(UserData.PathResults_Precipitation)
mkdir(UserData.PathResults_Evapotranspiration)

%% Load GridDEM
% Load Raster DEM
try
    [z,~,~,ExtentRaster]      = geotiffread(UserData.GridDEM);
catch
    errordlg(['The Raster "',UserData.GridDEM ,'" not found'],'!! Error !!')
    return
end

[fil, col]  = size(z);
x           = int32(linspace(ExtentRaster(1,1), ExtentRaster(2,1),col)*PFSM_D);
y           = int32(linspace(ExtentRaster(2,2), ExtentRaster(1,2),fil)*PFSM_D);
[x, y]      = meshgrid(x,y);
x           = reshape(x,[],1);
y           = reshape(y,[],1);
z           = reshape(z,[],1);
x           = x(z ~= UserData.ValueNaNRaster);
y           = y(z ~= UserData.ValueNaNRaster);
z           = z(z ~= UserData.ValueNaNRaster);

% Progres Process
% --------------
waitbar(1 / 5)
% --------------
%% Load ShapeFile UAH
try
    [Basin, CodeBasin]      = shaperead(UserData.ShapeFileHUA);
catch
    errordlg(['The Shapefile "',UserData.GridDEM,'" not found'],'!! Error !!')
    return
end

if isfield(CodeBasin,'Code') 
    CodeBasin = [CodeBasin.Code]';
else
    errordlg('There is no attribute called "Code" in the Shapefile of UAH','!! Error !!')
    return
end

% Progres Process
% --------------
waitbar(2 / 5)
% --------------
%% PARALLEL POOL ON CLUSTER
try
   myCluster                = parcluster('local');
   myCluster.NumWorkers     = UserData.CoresNumber;
   saveProfile(myCluster);
   parpool;
catch
end

[fil,~] = size(Basin);
parfor i = 1:fil
    Basin(i).X = int32((Basin(i).X)*PFSM_D);
    Basin(i).Y = int32((Basin(i).Y)*PFSM_D);
end
% Progres Process
% --------------
waitbar(3 / 5)
% --------------
%% Calculation ID Basin 
CodeBasin_Sort  = sort(CodeBasin);
[~,Poo]         = ismember(CodeBasin_Sort,CodeBasin);
CodeBasin       = CodeBasin_Sort;
Id_Basin        = cell(length(CodeBasin),1);
Posi            = [1:length(x)]';
parfor i = 1:length(CodeBasin)
    Tmp = Posi(inpolygon(x, y, Basin(Poo(i)).X, Basin(Poo(i)).Y));
    % Integer 8 bits
    if int8(max(Tmp)) < 127
        Id_Basin{i} = int8(Tmp);
    % Integer 16 bits
    elseif int16(max(Tmp)) < 32767
        Id_Basin{i} = int16(Tmp);
    % Integer 32 bits
    elseif int32(max(Tmp)) < 2147483647
        Id_Basin{i} = int32(Tmp);
    % Integer 64 bits
    elseif int64(max(Tmp)) < 9223372036854775807
        Id_Basin{i} = int64(Tmp);
    end
end

clearvars -except x y z CodeBasin Id_Basin UserData ProgressBar

% Progres Process
% --------------
waitbar(4 / 5)
% --------------
%% Calculation Evapotranspiration
if strcmp(UserData.Cal_ETP,'None')
    % False
    Vvar = [1 3];
else
    % True
    Vvar = [1 2];
end

% Progres Process
% --------------
waitbar(5 / 5)
close(ProgressBar);
% --------------
            
% Variables Procesing
for v = Vvar
    if eval(['UserData.TypeData',UserData.ClimateVar{v}]) == 2
        %% Data Type - Points
        
        %% Load GridDEM
        % Load Raster DEM
        try
            [z,~,~,ExtentRaster]      = geotiffread(UserData.GridDEM);
        catch
            errordlg(['The Raster "',UserData.GridDEM ,'" not found'],'!! Error !!')
            return
        end

        [fil, col]  = size(z);
        x           = int32(linspace(ExtentRaster(1,1), ExtentRaster(2,1),col)*PFSM_D);
        y           = int32(linspace(ExtentRaster(2,2), ExtentRaster(1,2),fil)*PFSM_D);
        [x, y]      = meshgrid(x,y);
        x           = reshape(x,[],1);
        y           = reshape(y,[],1);
        z           = reshape(z,[],1);
        x           = x(z ~= UserData.ValueNaNRaster);
        y           = y(z ~= UserData.ValueNaNRaster);
        z           = z(z ~= UserData.ValueNaNRaster);

        % Sheet in Excel 
        [~,Scenarios] = xlsfinfo(eval(['UserData.Data',UserData.ClimateVar{v}]));
        Cont = 1;
        
        % Progres Process
        % --------------
        ProgressBar = waitbar(0,'Please wait...');
        
        for i = 1:length(Scenarios)
            % Load Data
            try
                [Data, DateTmp] = xlsread(eval(['UserData.Data',UserData.ClimateVar{v}]), Scenarios{i});
            catch
                errordlg(['The File "',eval(['UserData.Data',UserData.ClimateVar{v}]),'" not found'],'!! Error !!')
                return
            end

            CodeGauges      = Data(1,:)';
            Data            = int32(Data*PFSM_C);
            Data            = Data(2:end,:);
            DateTmp         = DateTmp(2:length(Data(:,1))+1,1);
            [~, posi]       = ismember(CodeGauges, cell2mat(UserData.GaugesCatalog(:,1)));
            Values          = NaN(length(Data(:,1)),length(CodeBasin));
            Date            = NaN(length(Data(:,1)),1);
            
            % Date
            parfor w = 1:length(Data(:,1))
                Date(w) = int32(datenum(DateTmp{w},'yyyy-mm-dd'));
            end
            
            for w = 1:length(Data(:,1))
                for k = 1:length(CodeBasin) 
                    if strcmp(UserData.ClimateVar{v},'Precipitation')
                        Values(w,k) = nanmean(PrecipitationFields(int32(cell2mat(UserData.GaugesCatalog(posi,4))), int32(cell2mat(UserData.GaugesCatalog(posi,5))), Data(w,:)', x(Id_Basin{k}), y(Id_Basin{k})));
                    elseif strcmp(UserData.ClimateVar{v},'Temperature')
                        Values(w,k) = nanmean(ETP_Thornthwaite(TemperatureFields(int32(cell2mat(UserData.GaugesCatalog(posi,6))), Data(w,:)',z(Id_Basin{k}))));
                    elseif strcmp(UserData.ClimateVar{v},'Evapotranspiration')
                        Values(w,k) = nanmean(TemperatureFields(int32(cell2mat(UserData.GaugesCatalog(posi,6))), Data(w,:)',z(Id_Basin{k})));
                    end
                end
                waitbar(Cont / ((length(Data(:,1)) * length(Scenarios))))
                Cont = Cont + 1;
            end
            
            
            %% Save Data Table
            NameBasin       = cell(1,length(CodeBasin) + 1);
            NameBasin{1}    = 'Date_Matlab';
            parfor k = 2:length(CodeBasin) + 1
                NameBasin{k} = ['Basin_',num2str(CodeBasin(k - 1))];
            end

            NameDate    = cell(1,length(Date));
            parfor k = 1:length(Date)
                NameDate{k} = datestr(Date(k),'dd-mm-yyyy');
            end

            Results = [Date single(Values)/PFSM_C];
            Results = array2table(Results,'VariableNames',NameBasin,'RowNames',NameDate);

            if strcmp(UserData.ClimateVar{v},'Precipitation')
                writetable(Results, fullfile(eval(['UserData.PathResults_',UserData.ClimateVar{v}]),['Pcp_Scenario-',num2str(i),'.dat']), 'WriteRowNames',true)
            elseif strcmp(UserData.ClimateVar{v},'Temperature')
                writetable(Results, fullfile(eval(['UserData.PathResults_',UserData.ClimateVar{3}]),['ETP_Scenario-',num2str(i),'.dat']), 'WriteRowNames',true)
            else
                writetable(Results, fullfile(eval(['UserData.PathResults_',UserData.ClimateVar{3}]),['ETP_Scenario-',num2str(i),'.dat']), 'WriteRowNames',true)
            end
            
        end 
        % Progres Process
        % --------------
        close(ProgressBar);
        % --------------
    else
        %% Data Type - Raster
        NameFolder  = dir(eval(['UserData.Data',UserData.ClimateVar{v}]));
        Id          = [NameFolder.isdir]';
        NameFolder  = {NameFolder.name}';
        NameFolder  = NameFolder(Id);
        Scenario    = NameFolder(3:end);
        
        % Progres Process
        % --------------
        ProgressBar = waitbar(0,'Please wait...');
        
        Cont = 1;
        for w = 1:length(Scenario)
            Data = dir(fullfile(eval(['UserData.Data',UserData.ClimateVar{v}]),Scenario{w},'Raster_*'));
            Data = {Data.name};
            Date = NaN(length(Data),1);
            
            parfor i = 1:length(Date)
                Tmp     = strsplit(Data{i},'_');
                Date(i) = datenum(Tmp{2},'yyyy-mm-dd'); 
            end
            
            for i = 1:length(Data)

                try
                    [RawData,~,~,ExtentRaster] = geotiffread(fullfile(eval(['UserData.Data',UserData.ClimateVar{v}]),Scenario{w},Data{i}));
                catch
                    errordlg(['The Raster "',fullfile(eval(['UserData.Path',UserData.ClimateVar{v}]),Data{i,w + 1},['Raster_',Data{i,1}]),'" not found'],'!! Error !!')
                    return
                end
                
                if i == 1 && w == 1
                    [fil, col]  = size(RawData);
                    x           = linspace(ExtentRaster(1,1), ExtentRaster(2,1),col);
                    y           = linspace(ExtentRaster(2,2), ExtentRaster(1,2),fil);
                    [x, y]      = meshgrid(x,y);
                    x           = reshape(x,[],1);
                    y           = reshape(y,[],1);

                    try
                        [Basin, CodeBasin]      = shaperead(UserData.ShapeFileHUA);
                    catch
                        errordlg(['The Shapefile "',UserData.ShapeFileHUA,'" not found'],'!! Error !!')
                        return
                    end

                    if isfield(CodeBasin,'Code') 
                        CodeBasin = [CodeBasin.Code]';
                    else
                        errordlg('There is no attribute called "Code" in the Shapefile of UAH','!! Error !!')
                        return
                    end

                    % Calculation ID Basin 
                    CodeBasin_Sort  = sort(CodeBasin);
                    [~,Poo]         = ismember(CodeBasin_Sort,CodeBasin);
                    CodeBasin       = CodeBasin_Sort;
                    Id_Basin        = cell(length(CodeBasin),1);
                    Posi            = [1:length(x)]';
                    parfor k = 1:length(CodeBasin)
                        Id_Basin{k} = Posi(inpolygon(x, y, Basin(Poo(k)).X, Basin(Poo(k)).Y));
                    end
                    % save values 
                    Values          = NaN(length(Data(:,i)),length(CodeBasin));
                
                end

                RawData         = reshape(RawData,[],1);
                
                if strcmp(UserData.ClimateVar{v},'Temperature')
                    RawData = ETP_Thornthwaite(RawData);
                end
                
                parfor k = 1:length(CodeBasin)             
                    Values(i,k) = nanmean(RawData(Id_Basin{k}));
                end
                
                % Progres Process
                % --------------
                waitbar(Cont / ((length(Data) * length(Scenario))))
                Cont = Cont + 1;
            end  
            
            %% Save Data
            NameBasin   = cell(1,length(CodeBasin) + 1);
            NameBasin{1} = 'Date_Matlab';
            parfor k = 2:length(CodeBasin) + 1
                NameBasin{k} = ['Basin_',num2str(CodeBasin(k - 1))];
            end

            NameDate    = cell(1,length(Date));
            parfor k = 1:length(Date)
                NameDate{k} = datestr(Date(k),'dd-mm-yyyy');
            end

            Results = [Date Values];
            Results = array2table(Results,'VariableNames',NameBasin,'RowNames',NameDate);

            if strcmp(UserData.ClimateVar{v},'Precipitation')
                writetable(Results, fullfile(eval(['UserData.PathResults_',UserData.ClimateVar{v}]),['Pcp_Scenario-',num2str(w),'.dat']), 'WriteRowNames',true)
            elseif strcmp(UserData.ClimateVar{v},'Temperature')
                writetable(Results, fullfile(eval(['UserData.PathResults_',UserData.ClimateVar{3}]),['ETP_Scenario-',num2str(w),'.dat']), 'WriteRowNames',true)
            else
                writetable(Results, fullfile(eval(['UserData.PathResults_',UserData.ClimateVar{3}]),['ETP_Scenario-',num2str(w),'.dat']), 'WriteRowNames',true)
            end
            
        end
         % Progres Process
        % --------------
        close(ProgressBar);
        % --------------
    end
end

%% Finish
clear, clc, close all
try
    delete(gcp('nocreate'))
catch
end

%% Operation Completed
[Icon,~] = imread('Completed.jpg'); 
msgbox('Operation Completed','Success','custom',Icon);