% function Pre_Procesing_DemandData(UserData)
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
%% PARALLEL POOL ON CLUSTER
% try
%     delete(gcp('nocreate'))
% catch
% end

try
   myCluster                = parcluster('local');
   myCluster.NumWorkers     = 2;%UserData.CoresNumber;
   saveProfile(myCluster);
   parpool;
catch
end

% Create Demand Folder
mkdir(UserData.PathResults_Demand)

% Demand Type
for i = 1:length(UserData.DemandVar)
    
    % True or False - Calculate Demand
    if eval(['UserData.Inc_',UserData.DemandVar{i}]) == 1
        
        % Number Excel File by Demand - i
        for Nexc = 1:length(eval(['UserData.Data',UserData.DemandVar{i},'(:,2)']))
            
            % Scenarios by Demand
            Scenarios = cell2mat(eval(['{UserData.Data',UserData.DemandVar{i},'{Nexc,4:end}}']));
            
            for NSce = 1:length(Scenarios)
                
                if strcmp(UserData.DemandVar{i},'Agricultural')
                    mkdir(fullfile(UserData.PathResults_Demand, UserData.DemandVar{i}, ['Scenario-',num2str(Scenarios(NSce))],'Area'))
                    mkdir(fullfile(UserData.PathResults_Demand, UserData.DemandVar{i}, ['Scenario-',num2str(Scenarios(NSce))],'Kc'))
                else
                    % Creation of folder of the type of demand.
                    mkdir(fullfile(UserData.PathResults_Demand, UserData.DemandVar{i}, ['Scenario-',num2str(Scenarios(NSce))],'Demand'))

                    % Returns
                    mkdir(fullfile(UserData.PathResults_Demand, UserData.DemandVar{i}, ['Scenario-',num2str(Scenarios(NSce))],'Return'))
                end
                
                % Value [2] or Module [3] Processing
                for VM = 2:3
                    try
                        % load Excel File
                        [TmpN, TmpS] = xlsread( eval(['UserData.Data',UserData.DemandVar{i},'{Nexc,VM}']),...
                                       ['Scenario-',num2str(Scenarios(NSce))]);
                    catch
                        errordlg(['The File "',eval(['UserData.Data',UserData.DemandVar{i},'{Nexc,VM}']),'" not found'],'!! Error !!')
                        return
                    end
                    
                    %% Obtaining Data From Excel Files
                    if VM == 2
                        % Distribution
                        TypeSUD      = TmpN(4,14);
                        % TypeCrop
                        TypeCrop     = TmpS{1,4};
                        % Estimate Returns
                        EstReturns   = TmpS{1,6};
                        % Porcentage Returns
                        PorReturns   = TmpN(1,8);
                        % Losses Domestic
                        LossDom      = TmpN(1,10);
                        % Shapefile of Spatial Unit 
                        ShpSU        = fullfile(UserData.PathsSU,TmpS{4,6},[TmpS{4,7},'.shp']);
                        % Raster of Spatial Unit
                        RasterSU     = fullfile(UserData.PathsSUD,TmpS{4,6},[TmpS{4,7},'.tif']);
                        % Code Spatial Unit
                        CodeSU       = TmpN(10:end,1);
                        CodeSU       = CodeSU(isnan(CodeSU(:,1)) == 0);
                        % Date Series of the data 
                        Date         = datenum(datetime(TmpN(7,6),TmpN(7,7),1):calmonths:datetime(TmpN(8,6),TmpN(8,7),1));
                        % Data type 
                        DataType     = TmpN(10:end,3);
                        DataType     = DataType(1:length(CodeSU));
                        % Serie Data
                        DataTmp      = TmpN(10:end,4:end);
                        DataTmp      = DataTmp(1:length(CodeSU),:);
                        % Calculation Distribution Data 
                        if TypeSUD == 1
                            DistCal      = TmpS(5,14);
                        else
                            DistCal      = TmpS(5,17:end);
                        end
                        % Code Distribution 
                        if TypeSUD == 1
                            DistCode     = TmpN(6,14);
                        else
                            DistCode     = TmpN(6,17:end);
                            DistCode     = DistCode(isnan(DistCode) == 0);
                        end
                        % Name Folder Spatial Unit Distribution
                        if TypeSUD == 1
                            NameFolder   = TmpS(7,14);
                            RasterSUD    = TmpS(8,14);
                        else
                            try
                                NameFolder   = TmpS(7,17:length(DistCode)+16);
                                RasterSUD    = TmpS(8,17:length(DistCode)+16);
                            catch
                                NameFolder   = cell(1,length(DistCode));
                                RasterSUD    = cell(1,length(DistCode));
                            end
                        end
                        DataV  = NaN(length(DataType),length(Date));
                        
                        clearvars TmpN TmpS
                        
                        parfor j = 1:length(CodeSU)
                            if DataType(j) == 1
                                % Data Annual Multi-Year Average
                                DataV(j,:) = DataTmp(j,1);
                                
                            elseif DataType(j) == 2
                                % Data Multi-Year Monthly Average
                                DataV(j,:) = repmat(DataTmp(j,2:13),1,length(Date)/12);
                                
                            elseif DataType(j) == 3
                                % Data Temporal Serie
                                DataV(j,:) = DataTmp(j,14:end);
                            end
                        end
                        DataV = DataV(:,isnan(DataV(1,:))  == 0);

                    elseif VM == 3

                        DataType     = TmpN(10:end,3);
                        DataTmp      = TmpN(10:end,4:end);
                        DataM        = NaN(length(DataType),length(Date)); 
                        
                        parfor j = 1:length(CodeSU)
                            if DataType(j) == 1
                                % Data Annual Multi-Year Average
                                DataM(j,:) = DataTmp(j,1);
                                
                            elseif DataType(j) == 2
                                % Data Multi-Year Monthly Average
                                DataM(j,:) = repmat(DataTmp(j,2:13),1,length(Date)/12);
                                
                            elseif DataType(j) == 3
                                % Data Temporal Serie
                                DataM(j,:) = DataTmp(j,14:end);
                                
                            end
                        end
                        DataV = DataV(:,isnan(DataV(1,:))  == 0);
                        DataM = DataM(isnan(DataM(:,1))  == 0,:);
                    end
                    
                end 
                
                
                %% Calculate Demand
                % !!! Demand in Cubic Meters (m3) !!!
                % 1) => Agricultural    
                % 2) => Domestic
                % 3) => Livestock
                % 4) => Hydrocarbons
                % 5) => Mining
                
                if i == 1
                    % Area in Hec to Squart Meter
                    FactorArea = 10000;
                    % Area in m2
                    DataDemand = DataV * FactorArea;
                    
                elseif i == 2 
                    % !!! Demand in Cubic Meters (m^3) !!!
                    DataDemand = ((1/1000) .* DataV .* DataM .* repmat([31 28 31 30 31 30 31 31 30 31 30 31],length(CodeSU),length(Date)/12))./(1-LossDom);
                    
                elseif i == 3 || i == 4
                    % !!! Demand in Cubic Meters (m^3) !!!
                    DataDemand = (1/1000) .* DataV .* DataM .* repmat([31 28 31 30 31 30 31 31 30 31 30 31],length(CodeSU),length(Date)/12);
                    
                elseif i == 5
                    % !!! Demand in Cubic Meters (m^3) !!!
                    DataDemand = DataV .* DataM;
                    
                end
                
                
                %% Distribution Demand Data by Basin
                PathRaster_SUD   = fullfile(UserData.PathsSUD,NameFolder{1},[RasterSUD{1},'.tif']);
                
                % Load Shapefile of Spatial Unit 
                % -------------------------------------------------------------------------------------------
                if length(DistCal) > 0
                    try
                        [SU, CodeSU_shp]    = shaperead(ShpSU);
                    catch
                        errordlg(['The Shapefile "',ShpSU,'" not found'],'!! Error !!')
                        return
                    end
                    
                    if isfield(CodeSU_shp,'Code') 
                        CodeSU_shp = [CodeSU_shp.Code]';
                    else
                        errordlg('There is no attribute called "Code" in the Shapefile of UAH','!! Error !!')
                        return
                    end
                end
                 
                % Load Shapefile of Hydrological Analisys Unit
                % -------------------------------------------------------------------------------------------
                try
                    [Basin, CodeBasin]      = shaperead(UserData.ShapeFileHUA);
                catch
                    errordlg(['The Shapefile "',UserData.PathGridDEM,'" not found'],'!! Error !!')
                    return
                end

                if isfield(CodeBasin,'Code') 
                     CodeBasin = [CodeBasin.Code]';
                else
                    errordlg('There is no attribute called "Code" in the Shapefile of UAH','!! Error !!')
                    return
                end
                
                % Agriculturdal Demand
                % -------------------------------------------------------------------------------------------
                if i == 1
                    AreaCrop    = zeros(length(Date),length(CodeBasin));
                end
                
                ProgressBar = waitbar(0,'Please wait...');
                
                % Storage Values
                Values          = zeros(length(Date),length(CodeBasin));
                
                %%
                % True or Flase Distribution Demand 
                if strcmp(DistCal, 'False') % False Distribution

                    % Load Raster Spatial Unit
                    % -------------------------------------------------------------------------------------------
                    try
                        [SUD, Tmp]      = geotiffread(RasterSU);
                        ExtentRaster    = [ Tmp.YWorldLimits, Tmp.XWorldLimits ];
                    catch
                        errordlg(['The Raster "',PathRaster_SUD,'" not found'],'!! Error !!')
                        return
                    end

                    [fil, col]  = size(SUD);
                    x           = linspace(ExtentRaster(3), ExtentRaster(4),col);
                    y           = linspace(ExtentRaster(2), ExtentRaster(1),fil);
                    [x, y]      = meshgrid(x,y);
                    x           = reshape(x,[],1);
                    y           = reshape(y,[],1);
                    SUD         = reshape(SUD,[],1);
                    x           = x(SUD ~= UserData.ValueNaNRaster);
                    y           = y(SUD ~= UserData.ValueNaNRaster);
                    SUD         = SUD(SUD ~= UserData.ValueNaNRaster);
                    SUD         = double(SUD);

                    % Distribution Demand by point number 
                    % -------------------------------------------------------------------------------------------
                    CodeSUD     = unique(SUD);
                    for k = 1:length(CodeSUD)
                        Temp        = find(SUD == CodeSUD(k));
                        SUD(Temp)   = DataDemand(CodeSU == CodeSUD(k),j) / length(Temp);
                    end

                    % Sort Basin
                    % -------------------------------------------------------------------------------------------
                    CodeBasin_Sort  = sort(CodeBasin);
                    [~,Poo]         = ismember(CodeBasin_Sort,CodeBasin);

                    % Demand by Basin
                    % -------------------------------------------------------------------------------------------
                    parfor k = 1:length(CodeBasin)             
                        Values(j,k) = nansum(SUD(inpolygon(x, y, Basin(Poo(k)).X, Basin(Poo(k)).Y)));
                    end

                elseif strcmp(DistCal, 'True')
                    %% True Distribution 

                    % Load Raster Spatial Unit Distribution
                    % -------------------------------------------------------------------------------------------
                    try
                        [SUD, Tmp]      = geotiffread(PathRaster_SUD);
                        ExtentRaster    = [ Tmp.YWorldLimits, Tmp.XWorldLimits ];
                    catch
                        errordlg(['The Raster "',PathRaster_SUD,'" not found'],'!! Error !!')
                        return
                    end

                    % Coordinates
                    [fil, col]      = size(SUD);
                    x               = linspace(ExtentRaster(3), ExtentRaster(4),col);
                    y               = linspace(ExtentRaster(2), ExtentRaster(1),fil);
                    [x, y]          = meshgrid(x,y);
                    x               = reshape(x,[],1);
                    y               = reshape(y,[],1);
                    SUD             = reshape(SUD,[],1);
                    x               = x(SUD ~= UserData.ValueNaNRaster);
                    y               = y(SUD ~= UserData.ValueNaNRaster);
                    SUD             = SUD(SUD ~= UserData.ValueNaNRaster);
                    SUD             = double(SUD);

                    CodeSU_shp_Sort = sort(CodeSU_shp);
                    [~,Poo]         = ismember(CodeSU_shp_Sort,CodeSU_shp);
                    CodeSU_shp      = CodeSU_shp_Sort;
                    x               = x(SUD == DistCode);
                    y               = y(SUD == DistCode);
                    SUD             = zeros(length(x), length(Date));

                    % Kc Crop
                    % -------------------------------------------------------------------------------------------
                    if i == 1
                        Kc = SUD;
                    end

                    % Distribution Demand whit Spatial Unit
                    % -------------------------------------------------------------------------------------------
                    for k = 1:length(CodeSU_shp)
                        Temp      = inpolygon(x, y, SU(Poo(k)).X, SU(Poo(k)).Y);
                        if sum(Temp) > 0
                            parfor t = 1:length(Date)
                                SUD(Temp,t)     = DataDemand(CodeSU == CodeSU_shp(k),t) ./ length(Temp);
                            end
                        else

                            ExtentBasin     = SU(Poo(k)).BoundingBox;
                            Fil             = ones(1,2);
                            Col             = ones(1,2);

                            xtmp            = linspace(ExtentBasin(1,1), ExtentBasin(2,1),10);
                            ytmp            = linspace(ExtentBasin(2,2), ExtentBasin(1,2),10);
                            [xtmp, ytmp]    = meshgrid(xtmp, ytmp);
                            xtmp            = reshape(xtmp,[],1);
                            ytmp            = reshape(ytmp,[],1);

                            x               = [x; xtmp];
                            y               = [y; ytmp];
                            SUD             = [SUD; zeros(length(xtmp),length(Date))]; 

                            Temp            = inpolygon(x, y, SU(Poo(k)).X, SU(Poo(k)).Y);
                            SUD(Temp)       = DataDemand(CodeSU == CodeSU_shp(k),j) / length(Temp);
                        end

                        if i == 1 % Agricultural Demand
                            try
                                Kc        = [Kc; zeros(length(xtmp),length(Date))];
                            catch
                            end
                            Kc(Temp,:)  = DataM(CodeSU == CodeSU_shp(k),:);
                        end

                    end



                    % Sort Basin
                    % -------------------------------------------------------------------------------------------
                    CodeBasin_Sort  = sort(CodeBasin);
                    [~,Poo]         = ismember(CodeBasin_Sort,CodeBasin);

                    % Assignation of Demand in Basin
                    % -------------------------------------------------------------------------------------------
                    parfor k = 1:length(CodeBasin)
                        if i == 1

                            id              = inpolygon(x, y, Basin(Poo(k)).X, Basin(Poo(k)).Y);
                            Values(j,k)     = nanmean( Kc(id) );
                            % Area  (m2)
                            AreaCrop(j,k)   = nansum( SUD(id) );
                        else
                            Values(j,k) = nansum(SUD(inpolygon(x, y, Basin(Poo(k)).X, Basin(Poo(k)).Y)));
                        end
                    end

%                         for k = 1:5, plot(Basin(Poo(k)).X, Basin(Poo(k)).Y), hold on, end, plot(x,y,'.k')
                end
                waitbar(j / length(Date))
                    
                
                CodeBasin    = CodeBasin_Sort;
                
                %% Save Data
                NameBasin    = cell(1,length(CodeBasin) + 1);
                NameBasin{1} = 'Date_Matlab';
                
                parfor k = 2:length(CodeBasin) + 1
                    NameBasin{k} = ['Basin_',num2str(CodeBasin(k - 1))];
                end

                NameDate    = cell(1,length(Date));
                parfor k = 1:length(Date)
                    NameDate{k} = datestr(Date(k),'dd-mm-yyyy');
                end
                
                if i == 1 
                    Results = [Date' Values];
                    Results = array2table(Results,'VariableNames',NameBasin,'RowNames',NameDate);
                    
                    Results1 = [Date' AreaCrop];
                    Results1 = array2table(Results1,'VariableNames',NameBasin,'RowNames',NameDate);
                    
                    % Area
                    writetable(Results1,...
                        fullfile(UserData.PathResults_Demand, UserData.DemandVar{i},['Scenario-',num2str(Scenarios(NSce))],'Area',[eval(['UserData.Data',UserData.DemandVar{i},'{Nexc,1}']),'.dat']),...
                        'WriteRowNames',true)
                    
                    % Kc
                    writetable(Results,...
                        fullfile(UserData.PathResults_Demand, UserData.DemandVar{i},['Scenario-',num2str(Scenarios(NSce))],'Kc',[eval(['UserData.Data',UserData.DemandVar{i},'{Nexc,1}']),'.dat']),...
                        'WriteRowNames',true)
                
                else
                    if strcmp(EstReturns,'True')
                        
                        ResultsRetur = [Date' (Values.*PorReturns)];
                        ResultsRetur = array2table(ResultsRetur,'VariableNames',NameBasin,'RowNames',NameDate);

                        writetable(ResultsRetur,...
                            fullfile(UserData.PathResults_Demand, UserData.DemandVar{i},['Scenario-',num2str(Scenarios(NSce))],'Return',[eval(['UserData.Data',UserData.DemandVar{i},'{Nexc,1}']),'.dat']),...
                            'WriteRowNames',true)
                    end
                    
                    Results = [Date' Values];
                    Results = array2table(Results,'VariableNames',NameBasin,'RowNames',NameDate);
                    
                    writetable(Results,...
                        fullfile(UserData.PathResults_Demand, UserData.DemandVar{i},['Scenario-',num2str(Scenarios(NSce))],'Demand',[eval(['UserData.Data',UserData.DemandVar{i},'{Nexc,1}']),'.dat']),...
                        'WriteRowNames',true)
                end
                
                
                close(ProgressBar);


            end
        end 
    end
end

