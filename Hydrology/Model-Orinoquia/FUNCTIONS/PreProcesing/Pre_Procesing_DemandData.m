function Pre_Procesing_DemandData(UserData)
%/usr/bin/Matlab-R2016b
% -------------------------------------------------------------------------
% DEMAND DATA PRE-PROCESING
% -------------------------------------------------------------------------
% BASE DATA 
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
% INPUTS
% OUTPUTS

% Borrame
CodeC = xlsread(fullfile(UserData.PathProject,'Cravo_Sur.xlsx'));

warning off

% Progres Process
% --------------
ProgressBar     = waitbar(0, 'Processing Demand Data...');
        
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

% Create Demand Folder
mkdir( fullfile(UserData.PathProject,'RESULTS','Demand') )

Contbar = 0;
% Demand Type
for i = [1, 3:5]%1:length(UserData.DemandVar)
    
    % True or False - Include Demand
    if eval(['UserData.Inc_',UserData.DemandVar{i}]) == 1
        
        % Number Excel File by Demand - i
        for Nexc = 1:length(eval(['UserData.Data',UserData.DemandVar{i},'(:,2)']))
            
            % Scenarios by Demand
            Scenarios = cell2mat(eval(['{UserData.Data',UserData.DemandVar{i},'{Nexc,2:end}}']));
            
            for NSce = 1:length(Scenarios)
                
                % Waitbar Accumulate
                nB = length(UserData.DemandVar)*length(eval(['UserData.Data',UserData.DemandVar{i},'(:,2)']))*length(Scenarios);
                
                % Creation of folder of the type of demand.
                mkdir(fullfile(UserData.PathProject,'RESULTS','Demand', UserData.DemandVar{i}, ['Scenario-',num2str(Scenarios(NSce))],'Demand'))

                % Returns
                mkdir(fullfile(UserData.PathProject,'RESULTS','Demand', UserData.DemandVar{i}, ['Scenario-',num2str(Scenarios(NSce))],'Return'))
                
                disp(eval(['UserData.Data',UserData.DemandVar{i},'{Nexc,1}']))
                % Value [2] or Module [3] Processing
                try
                    % load Excel File
                    [TmpN, TmpS] = xlsread( fullfile(UserData.PathProject,'DATA','Demand', [UserData.DemandVar{i},'-Demand'],'Value', ['Value_',eval(['UserData.Data',UserData.DemandVar{i},'{Nexc,1}']), '.xlsx' ]),...
                                   ['Scenario-',num2str(Scenarios(NSce))]);
                catch
                    errordlg(['The File "',eval(['UserData.Data',UserData.DemandVar{i},'{Nexc,1}']),'" not found'],'!! Error !!')
                    return
                end

                %% Load Data of Excel File - Value
                if i == 1
                    % Type Crop
                    TypeCrop     = TmpS{6,5};
                    % Phenological Time
                    TimeCrop     = TmpN(1,5);
                end
                
                % Porcentage Returns
                PorReturns   = TmpN(2,5);
                
                if i > 1
                    % Losses Domestic
                    Loss         = TmpN(3,5);
                end

                % Distribution
                TypeInfo      = TmpS{5,15};
                
                % Shapefile of Spatial Unit 
                ShpSU        = fullfile(UserData.PathProject,'DATA','Geografic','SU',TmpS{10,5},[TmpS{10,5},'.shp']);
                
                % Raster of Spatial Unit
                RasterSU     = fullfile(UserData.PathProject,'DATA','Geografic','SU',TmpS{10,5},[TmpS{10,5},'.tif']);
                
                % Code Spatial Unit
                CodeSU       = TmpN(7:end,1);
                CodeSU       = CodeSU(isnan(CodeSU(:,1)) == 0);
                
                % Data type 
                DataType     = TmpS(13:end,3);
                DataType     = DataType(1:length(CodeSU));
                
                % Serie Data
                DataTmp      = TmpN(7:end,4:end);
                DataTmp      = DataTmp(1:length(CodeSU),:);
                
                if strcmp(TypeInfo, 'True' )
                    
                    % Calculation Distribution Data
                    DistCal      = TmpS(8,16);
                    
                    % Code Distribution
                    DistCode     = TmpN(3,16);
                    
                    % Name Folder Spatial Unit Distribution
                    NameFolder   = TmpS{10,16};
                    RasterSUD    = TmpS{11,16};
                    
                    % Date Series of the data 
%                     Date         = datenum( datetime(x2mdate(TmpN(1,15)),'ConvertFrom', 'datenum'):calmonths:datetime(x2mdate(TmpN(2,15)),'ConvertFrom', 'datenum') );
                    load('Date.mat')
                else

                    % Code Distribution 
                    DistCode     = TmpN(3,17:end);
                    DistCode     = DistCode(isnan(DistCode) == 0);
                    
                    % Calculation Distribution Data
                    DistCal      = TmpS(8,17:end);
                    DistCal      = DistCal(1:length(DistCode));
                    
                    % Name Folder Spatial Unit Distribution
                    NameFolder   = TmpS(10,17:length(DistCal)+16);
                    RasterSUD    = TmpS(11,17:length(DistCal)+16);
                    
                    % Date Series of the data 
                    Date         = x2mdate(TmpN(7,17:end));
                end
                
                DataV   = zeros(length(DataType),length(Date));
                nm      = length(Date);
                nn      = month(datetime(datestr(Date(1)))); 
                
                for j = 1:length(CodeSU)
                    if strcmp(DataType(j),'Annual Multi-Year Average')
                        % Data Annual Multi-Year Average
                        DataV(j,:) = DataTmp(j,1);

                    elseif strcmp(DataType(j),'Multi-Year Monthly Average')
                        % Data Multi-Year Monthly Average
                        Tmp         = repmat(DataTmp(j,2:13),1,length(unique(year(datetime(datestr(Date))))));
                        DataV(j,:)  = Tmp(:,nn:(nm + nn - 1));

                    elseif strcmp(DataType(j),'Temporal Serie')
                        % Data Temporal Serie
                        DataV(j,:) = DataTmp(j,14:end);
                    end
                end
                
                DataV(isnan(DataV)) = 0;
                IDValue = sum(DataV,2) > 0;
                DataV   = DataV(IDValue,:);
                
                %% Load Data of Excel File - Module
                try
                    % load Excel File
                    [TmpN, TmpS ] = xlsread( fullfile(UserData.PathProject,'DATA','Demand', [UserData.DemandVar{i},'-Demand'],'Module', ['Module_',eval(['UserData.Data',UserData.DemandVar{i},'{Nexc,1}']) , '.xlsx']),...
                                   ['Scenario-',num2str(Scenarios(NSce))]);
                catch
                    errordlg(['The File "',eval(['UserData.Data',UserData.DemandVar{i},'{Nexc,1}']),'" not found'],'!! Error !!')
                    return
                end

                % Data type 
                DataType     = TmpS(13:end,3);
                DataType     = DataType(1:length(CodeSU));
                
                % Serie Data
                DataTmp      = TmpN(7:end,4:end);
                DataTmp      = DataTmp(1:length(CodeSU),:);
                
                DataM        = zeros(length(DataType),length(Date)); 
                
                for j = 1:length(CodeSU)
                    if strcmp(DataType(j),'Annual Multi-Year Average')
                        % Data Annual Multi-Year Average
                        DataM(j,:)  = DataTmp(j,1);
                    elseif strcmp(DataType(j),'Multi-Year Monthly Average')
                        % Data Multi-Year Monthly Average
                        Tmp         = repmat(DataTmp(j,2:13),1,length(unique(year(datetime(datestr(Date))))));
                        DataM(j,:)  = Tmp(:,nn:(nm + nn - 1));

                    elseif strcmp(DataType(j),'Temporal Serie')
                        % Data Temporal Serie
                        DataM(j,:) = DataTmp(j,14:end);
                    end
                end
                
                DataM   = DataM(IDValue,:);
                CodeSU  = CodeSU(IDValue);
                
                clearvars TmpN TmpS
                
                %% Calculate Demand
                % !!! Demand in Cubic Meters (m3) !!!
                % 1) => Agricultural    
                % 2) => Domestic
                % 3) => Livestock
                % 4) => Hydrocarbons
                % 5) => Mining
                
                DayMonths = [31 28 31 30 31 30 31 31 30 31 30 31];
                nm      = length(Date);
                nn      = month(datetime(datestr(Date(1))));
                
                if i == 1
                    % -------------------------------------------------------------------------
                    % Precipitation 
                    % -------------------------------------------------------------------------
                    try
                        P = dlmread(fullfile(UserData.PathProject,'RESULTS','P',['Pcp_Scenario-',num2str(NSce),'.dat']),',',1,1);
                        P       = P(:,2:end);
                    catch
                        errordlg('The Precipitation Data Not Found','!! Error !!')
                        return
                    end

                    % -------------------------------------------------------------------------
                    % Evapotranspiration
                    % -------------------------------------------------------------------------
                    try
                        ET      = dlmread(fullfile(UserData.PathProject,'RESULTS','ETP',['ETP_Scenario-',num2str(NSce),'.dat']),',',1,1);
                        ET      = ET(:,2:end);
                    catch
                        errordlg('The Evapotranspiration Data Not Found','!! Error !!')
                        return
                    end
                    
                    BalanceH = (ET - P);
                    BalanceH(BalanceH<0) = 0;
                    
                    % Area in Hec to Squart Meter
                    FactorArea = 10000;
                    
                    if strcmp(TypeCrop, 'Trasients')
                        
%                         DataV(DataV == 0) = NaN;
                        DataVV = DataV;
                        DataVV(:,1:TimeCrop) = cumsum(DataV(:,1:TimeCrop), 2, 'omitnan');
                        for r = (TimeCrop + 1):length(DataV(1,:))                            
                            DataVV(:,r) = sum(DataV(:,(r-TimeCrop+1):r), 2, 'omitnan');
                        end
                        
                        % Area in m2
                        DataDemand = DataVV * FactorArea;
                    else
                        
                        % Area in m2
                        DataDemand = DataV * FactorArea;
                        
                    end
                    
                elseif i == 2 
                    % !!! Demand in Cubic Meters (m^3) !!!
                    % Liters to Cubic Meter
                    Factor_lts_M3   = (1/1000);
                    Tmp             = repmat(DayMonths,length(CodeSU),length(unique(year(datetime(datestr(Date))))));
                    DataDemand      = (Factor_lts_M3 .* DataV .* DataM .* Tmp(:,nn:(nm + nn - 1)))./(1 - Loss);
                    
                elseif i == 3 || i == 4
                    % !!! Demand in Cubic Meters (m^3) !!!
                     % Liters to Cubic Meter
                    Factor_lts_M3   = (1/1000);
                    Tmp             = repmat(DayMonths,length(CodeSU),length(year(datetime(datestr(Date)))));
                    DataDemand      = (Factor_lts_M3 .* DataV .* DataM .* Tmp(:,nn:(nm + nn - 1)))./(1 - Loss);
                    
                elseif i == 5
                    % !!! Demand in Cubic Meters (m^3) !!!
                    DataDemand = DataV .* DataM;
                    DataDemand = DataDemand./(1 - Loss);
                    
                end
                
                %% Distribution Demand Data by Basin                
                % Load Shapefile of Spatial Unit 
                if ~isempty(DistCal)
                    try
                        [SU, CodeSU_shp]    = shaperead(ShpSU);
                        
                        if isfield(CodeSU_shp,'Code') 
                            CodeSU_shp = [CodeSU_shp.Code]';
                        else
                            errordlg('There is no attribute called "Code" in the Shapefile of UAH','!! Error !!')
                            return
                        end
                    
                    catch
%                         errordlg(['The Shapefile "',ShpSU,'" not found'],'!! Error !!')
%                         return
                        load('Munic.mat')
                    end
                    
                end
                 
                % Load Shapefile of Hydrological Analisys Unit
                try
                    [Basin, CodeBasin]      = shaperead( fullfile(UserData.PathProject,'DATA','Geografic','HUA',UserData.ShapeFileHUA) );
                    
                    if isfield(CodeBasin,'Code') 
                        CodeBasin = [CodeBasin.Code]';
                    else
                        errordlg('There is no attribute called "Code" in the Shapefile of UAH','!! Error !!')
                        return
                    end
                
                catch
%                     errordlg(['The Shapefile "',UserData.ShapeFileHUA,'" not found'],'!! Error !!')
%                     return
                    load('HUA.mat')
                end
                
                % Agriculturdal Demand
                % -------------------------------------------------------------------------------------------
                if i == 1
                    KcCrop    = zeros(length(Date),length(CodeBasin));
                end
                
                % Storage Values
                Values          = zeros(length(Date),length(CodeBasin));
                
                %% Information Type
                if strcmp(TypeInfo, 'True' )
                    
                    % True or Flase Distribution Demand 
                    if strcmp(DistCal, 'False') % False Distribution
                        
                        % Load Raster Spatial Unit
                        % -------------------------------------------------------------------------------------------
                        try
                            [SUD, Tmp]      = geotiffread(RasterSU);
                            ExtentRaster    = [ Tmp.YWorldLimits, Tmp.XWorldLimits ];
                        catch
%                             errordlg(['The Raster "',RasterSU,'" not found'],'!! Error !!')
%                             return
                            load([RasterSU,'.mat'])
                        end
                        
                        [fil, col]  = size(SUD);
                        x           = linspace(ExtentRaster(3), ExtentRaster(4),col);
                        y           = linspace(ExtentRaster(2), ExtentRaster(1),fil);
                        [x, y]      = meshgrid(x,y);
                        x           = reshape(x,[],1);
                        y           = reshape(y,[],1);
                        SUD         = reshape(SUD,[],1);
                        Carajo      = unique(SUD);
                        [idd,~]     = ismember(Carajo, CodeSU);
                        Chanfle     = Carajo(idd == 0);
                        
                        for ff = 1:length(Chanfle)
                            x           = x(SUD ~= Chanfle(ff));
                            y           = y(SUD ~= Chanfle(ff));
                            SUD         = SUD(SUD ~= Chanfle(ff));
                        end
                        
                        SUD         = double(SUD);
                        SUDD        = zeros(length(SUD), length(Date));
                        
                        % Distribution Demand by point number 
                        % -------------------------------------------------------------------------------------------
                        CodeSUD     = unique(SUD);
                        
                        for k = 1:length(CodeSUD)
                            Temp    = SUD == CodeSUD(k);
                            IIDD    = CodeSU == CodeSUD(k);
                            if sum(IIDD) ~= 0
                                for we = 1:length(Date)
                                    SUDD(Temp,we)   = DataDemand(IIDD,we) / sum(Temp);
                                end
                            end
                        end
                        
                        % Sort Basin
                        % -------------------------------------------------------------------------------------------
                        CodeBasin_Sort  = sort(CodeBasin);
                        [~,Poo]         = ismember(CodeBasin_Sort,CodeBasin);
                        
                        % Demand by Basin
                        % -------------------------------------------------------------------------------------------
                        for k = 1:length(CodeBasin)
                            
                            IPO = inpolygon(x, y, Basin(Poo(k)).X, Basin(Poo(k)).Y);
                            
                            for we = 1:length(Date)
                                Values(we,k) = nansum(SUDD(IPO, we));
                            end
                        end
                                                
                    elseif strcmp(DistCal, 'True')
                        
                        %% True Distribution 
                        % Load Raster Spatial Unit Distribution
                        % -------------------------------------------------------------------------------------------
                        try
                            [SUD, Tmp]      = geotiffread( fullfile(UserData.PathProject,'DATA','Geografic','SUD', NameFolder, [RasterSUD, '.tif']) );
                            ExtentRaster    = [ Tmp.YWorldLimits, Tmp.XWorldLimits ];
                        catch
%                             errordlg(['The Raster "',[RasterSUD, '.tif'],'" not found'],'!! Error !!')
%                             return
                            load([RasterSUD,'.mat'])
                        end
                        
                        % Coordinates
                        [fil, col]      = size(SUD);
                        x               = linspace(ExtentRaster(3), ExtentRaster(4),col);
                        y               = linspace(ExtentRaster(2), ExtentRaster(1),fil);
                        [x, y]          = meshgrid(x,y);
                        x               = reshape(x,[],1);
                        y               = reshape(y,[],1);
                        SUD             = reshape(SUD,[],1);
                        x               = x(SUD == DistCode);
                        y               = y(SUD == DistCode);

                        CodeSU_shp_Sort = sort(CodeSU_shp);
                        [~,Poo]         = ismember(CodeSU_shp_Sort,CodeSU_shp);
                        CodeSU_shp      = CodeSU_shp_Sort;
                        SUD             = zeros(length(x), length(Date));
                        
                        id      = Poo > 0;
                        Poo     = Poo(id);
                        
                        [~, Poo2]       = ismember(CodeSU, CodeSU_shp);
                        
                        id      = Poo2 > 0;
                        Poo2    = Poo2(id);
                        
                        % Kc Crop
                        % -------------------------------------------------------------------------------------------
                        if i == 1
                            Kc = SUD;
                        end
                        
                        % Distribution Demand whit Spatial Unit 
                        % -------------------------------------------------------------------------------------------
                        tic
                        for k = 1:length(Poo2)
                            
%                             Temp = inpolygon(x, y, SU(Poo(Poo2(k))).X, SU(Poo(Poo2(k))).Y);
                            Temp = inpolygonFast([x, y], [SU(Poo(Poo2(k))).X', SU(Poo(Poo2(k))).Y']);
                            IIDD = find(CodeSU == CodeSU_shp(Poo2(k)));
                            
                            if sum(Temp) > 0
                                if sum(IIDD) ~= 0
                                    for we = 1:length(Date)
                                        SUD(Temp,we) = DataDemand(IIDD,we) ./ sum(Temp);
                                    end
                                end
                                JoJoPo          = 0;
                            else
                                
                                JoJoPo          = 1;
                                
                                ExtentBasin     = SU(Poo(Poo2(k))).BoundingBox;                                
                                xtmp            = linspace(ExtentBasin(1,1), ExtentBasin(2,1),10);
                                ytmp            = linspace(ExtentBasin(2,2), ExtentBasin(1,2),10);
                                [xtmp, ytmp]    = meshgrid(xtmp, ytmp);
                                xtmp            = reshape(xtmp,[],1);
                                ytmp            = reshape(ytmp,[],1);
                                
                                Temp1           = inpolygon(xtmp, ytmp, SU(Poo(Poo2(k))).X, SU(Poo(Poo2(k))).Y);
%                                 Temp1           = inpolygonFast([xtmp, ytmp], [SU(Poo(Poo2(k))).X, SU(Poo(Poo2(k))).Y]);
                                
                                x               = [x; xtmp(Temp1)];
                                y               = [y; ytmp(Temp1)];
                                
                                SUD             = [SUD; zeros(length(xtmp(Temp)),length(Date))]; 
                                
                                Temp            = inpolygon(x, y, SU(Poo(Poo2(k))).X, SU(Poo(Poo2(k))).Y);
                                
                                for we = 1:length(Date)
                                    SUD(Temp,we) = DataDemand(IIDD ,we) ./ sum(Temp);
                                end

                            end
                            
                            if i == 1 % Agricultural Demand
                                if JoJoPo == 1
                                    Kc        = [Kc; zeros(length(xtmp(Temp1)),length(Date))];
                                    clearvars JoJoPo
                                end
   
                                for we = 1:length(Date)
                                    Kc(Temp,we)  = DataM(IIDD ,we);
                                end

                            end
                            
                        end
                        toc 
                        
                        % Sort Basin
                        % -------------------------------------------------------------------------------------------
                        CodeBasin_Sort  = sort(CodeBasin);
                        [~,Poo]         = ismember(CodeBasin_Sort,CodeBasin);
                        
                        % Borrame porfis
%                         [~,PooSur]         = ismember(CodeC, CodeBasin_Sort);
                        
                        % Assignation of Demand in Basin
                        % -------------------------------------------------------------------------------------------
                        tic
                        for k = 1:length(CodeBasin)
%                         for kk = 1:length(PooSur)
                            
%                             [~,k] = ismember(CodeBasin(Poo(PooSur(kk))), CodeBasin_Sort);
%                             id  = inpolygon(x, y, Basin(Poo(k)).X, Basin(Poo(k)).Y);
                              id  = inpolygonFast([x, y], [Basin(Poo(k)).X', Basin(Poo(k)).Y']);
%                             id  = inpolygonFast([x, y], [Basin(Poo(PooSur(kk))).X', Basin(Poo(PooSur(kk))).Y']);
                            
                            if i == 1
                                [fil,~] = size(SUD(id,:));
                                if fil == 1
                                    Values(:,k) = SUD(id,:)';
                                    % Area  (m2)
                                    KcCrop(:,k) = Kc(id,:)';
                                    SUD(id,:)   = 0;
                                    Kc(id,:)    = 0;
                                else
                                    Values(:,k) = sum( SUD(id,:) , 'omitnan')';
                                    % Area  (m2)
                                    KcCrop(:,k) = mean( Kc(id,:), 'omitnan' )';
                                    SUD(id,:)   = 0;
                                    Kc(id,:)    = 0;
                                end
                            else
                                [fil,~] = size(SUD(id,:));
                                if fil == 1
                                    Values(:,k) = SUD(id,:)';
                                    SUD(id,:)   = 0;
                                else
                                    Values(:,k) = sum( SUD(id,:),'omitnan' )';
                                    SUD(id,:)   = 0;
                                end
                            end
                            
                        end
                        
                        if i == 1
                            Values = Values .* (BalanceH./1000);
                        end
                        
                    end
                    toc
                else
                    
%% ----------------------------------------------------------------------------------------------------------------------------------------------------
                    for j = 1:length(Date)
                    
                        % True or Flase Distribution Demand 
                        if strcmp(DistCal{j}, 'False') % False Distribution

                            % Load Raster Spatial Unit
                            % -------------------------------------------------------------------------------------------
                            try
                                [SUD, Tmp]      = geotiffread(RasterSU);
                                ExtentRaster    = [ Tmp.YWorldLimits, Tmp.XWorldLimits ];
                            catch
                                errordlg(['The Raster "',RasterSU,'" not found'],'!! Error !!')
                                return
                            end

                            [fil, col]  = size(SUD);
                            x           = linspace(ExtentRaster(3), ExtentRaster(4),col);
                            y           = linspace(ExtentRaster(2), ExtentRaster(1),fil);
                            [x, y]      = meshgrid(x,y);
                            x           = reshape(x,[],1);
                            y           = reshape(y,[],1);
                            SUD         = reshape(SUD,[],1);
                            Carajo      = unique(SUD);
                            [idd,~]     = ismember(Carajo, CodeSUD);
                            Chanfle     = Carajo(idd == 0);
                            
                            for ff = 1:length(Chanfle)
                                x           = x(SUD ~= Chanfle(ff));
                                y           = y(SUD ~= Chanfle(ff));
                                SUD         = SUD(SUD ~= Chanfle(ff));
                            end
                            
                            SUD         = double(SUD);

                            % Distribution Demand by point number 
                            % -------------------------------------------------------------------------------------------
                            CodeSUD     = unique(SUD);
                            
                            for k = 1:length(CodeSUD)
                                Temp        = find(SUD == CodeSUD(k));
                                SUD(Temp)   = DataDemand(CodeSU == CodeSUD(k),j) / sum(Temp);
                            end

                            % Sort Basin
                            % -------------------------------------------------------------------------------------------
                            CodeBasin_Sort  = sort(CodeBasin);
                            [~,Poo]         = ismember(CodeBasin_Sort,CodeBasin);

                            % Demand by Basin
                            % -------------------------------------------------------------------------------------------
                            if UserData.Parallel == 1
                                parfor k = 1:length(CodeBasin)             
                                    Values(j,k) = sum(SUD(inpolygon(x, y, Basin(Poo(k)).X, Basin(Poo(k)).Y)),'omitnan');
                                end
                            else
                                for k = 1:length(CodeBasin)             
                                    Values(j,k) = sum(SUD(inpolygon(x, y, Basin(Poo(k)).X, Basin(Poo(k)).Y)), 'omitnan');
                                end
                            end

                        elseif strcmp(DistCal{j}, 'True')
                            
                            %% True Distribution 
                            % Load Raster Spatial Unit Distribution
                            % -------------------------------------------------------------------------------------------
                            try
                                [SUD, Tmp]      = geotiffread(PathRaster_SUD{j});
                                ExtentRaster    = [ Tmp.YWorldLimits, Tmp.XWorldLimits ];
                            catch
                                errordlg(['The Raster "',PathRaster_SUD{j},'" not found'],'!! Error !!')
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
                            Carajo          = unique(SUD);
                            [idd,~]         = ismember(Carajo, CodeSUD);
                            Chanfle         = Carajo(idd == 0);
                            
                            for ff = 1:length(Chanfle)
                                x           = x(SUD ~= Chanfle(ff));
                                y           = y(SUD ~= Chanfle(ff));
                                SUD         = SUD(SUD ~= Chanfle(ff));
                            end
                            
                            SUD             = double(SUD);
                            CodeSU_shp_Sort = sort(CodeSU_shp);
                            [~,Poo]         = ismember(CodeSU_shp_Sort,CodeSU_shp);
                            CodeSU_shp      = CodeSU_shp_Sort;
                            x               = x(SUD == DistCode(j));
                            y               = y(SUD == DistCode(j));
                            SUD             = zeros(size(x));

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
                                    SUD(Temp) = DataDemand(CodeSU == CodeSU_shp(k),j) / sum(Temp);
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
                                    SUD             = [SUD; zeros(length(xtmp),1)]; 

                                    Temp            = inpolygon(x, y, SU(Poo(k)).X, SU(Poo(k)).Y);
                                    SUD(Temp)       = DataDemand(CodeSU == CodeSU_shp(k),j) / sum(Temp);
                                end

                                if i == 1 % Agricultural Demand
                                    try
                                        Kc        = [Kc; zeros(length(xtmp),1)];
                                    catch
                                    end
                                    Kc(Temp)  = DataM(CodeSU == CodeSU_shp(k),j);
                                end

                            end
                            
                            % Sort Basin
                            % -------------------------------------------------------------------------------------------
                            CodeBasin_Sort  = sort(CodeBasin);
                            [~,Poo]         = ismember(CodeBasin_Sort,CodeBasin);

                            % Assignation of Demand in Basin
                            % -------------------------------------------------------------------------------------------
                            if UserData.Parallel == 1
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
                            else
                                for k = 1:length(CodeBasin)
                                    if i == 1

                                        id              = inpolygon(x, y, Basin(Poo(k)).X, Basin(Poo(k)).Y);
                                        Values(j,k)     = nanmean( Kc(id) );
                                        % Area  (m2)
                                        AreaCrop(j,k)   = nansum( SUD(id) );
                                    else
                                        Values(j,k) = nansum(SUD(inpolygon(x, y, Basin(Poo(k)).X, Basin(Poo(k)).Y)));
                                    end
                                end
                            end
                        end
                    
                    end
                    
                end
                
                CodeBasin    = CodeBasin_Sort;
                
                load('Date')
                Date =Date';
                
                %% Save Data
                NameBasin    = cell(1,length(CodeBasin) + 1);
                NameBasin{1} = 'Date_Matlab';   
                
                for k = 2:length(CodeBasin) + 1
                    NameBasin{k} = ['Basin_',num2str(CodeBasin(k - 1))];
                end

                NameDate    = cell(1,length(Date));
                for k = 1:length(Date)
                    NameDate{k} = datestr(Date(k),'dd-mm-yyyy');
                end
                
                ResultsRetur = [Date' (Values.*PorReturns)];
                ResultsRetur = array2table(ResultsRetur,'VariableNames',NameBasin,'RowNames',NameDate);

                writetable(ResultsRetur,...
                    fullfile(UserData.PathProject,'RESULTS','Demand', UserData.DemandVar{i},['Scenario-',num2str(Scenarios(NSce))],'Return',[eval(['UserData.Data',UserData.DemandVar{i},'{Nexc,1}']),'.dat']),...
                    'WriteRowNames',true)

                Results = [Date' Values];
                Results = array2table(Results,'VariableNames',NameBasin,'RowNames',NameDate);

                writetable(Results,...
                    fullfile(UserData.PathProject,'RESULTS','Demand', UserData.DemandVar{i},['Scenario-',num2str(Scenarios(NSce))],'Demand',[eval(['UserData.Data',UserData.DemandVar{i},'{Nexc,1}']),'.dat']),...
                    'WriteRowNames',true)
                
                waitbar( Contbar/nB , ProgressBar)

            end
            
        end
    end 
end

%% TOTAL DEMAND
DeRe = {'Demand','Return'};
% Demand Type
for i = 1:length(UserData.DemandVar) 
    
    % True or False - Include Demand
    if eval(['UserData.Inc_',UserData.DemandVar{i}]) == 1
        
        for NSce = 1:length(Scenarios)
            try
                for dr = 1:2

                    % Store Total Demand
                    NameFile = dir(fullfile(UserData.PathProject,'RESULTS','Demand',UserData.DemandVar{i},['Scenario-',num2str(Scenarios(NSce))],DeRe{dr},'*.dat'));
                    NameFile = {NameFile.name}';

                    if isempty(NameFile)
                        NameFile    = dir(fullfile(UserData.PathProject,'RESULTS','Demand',UserData.DemandVar{i},['Scenario-',num2str(Scenarios(NSce))],DeRe{1},'*.dat'));
                        NameFile    = {NameFile.name}';
                        Tmp         = dlmread(fullfile(UserData.PathProject,'RESULTS','Demand',UserData.DemandVar{i},['Scenario-',num2str(Scenarios(NSce))],DeRe{1},NameFile{1}),',',1,1);
                        Data        = Tmp(:,2:end)*0;

                    else
                        for k = 1:length(NameFile)
                            Tmp     = dlmread(fullfile(UserData.PathProject,'RESULTS','Demand',UserData.DemandVar{i},['Scenario-',num2str(Scenarios(NSce))],DeRe{dr},NameFile{k}),',',1,1);
                            DateD   = Tmp(:,1);
                            Tmp     = Tmp(:,2:end);
                            if k == 1
                                Data = Tmp;
                            else 
                                Data = Data + Tmp;
                            end

                        end
                    end

                    %% Save Demand - Sector
                    NameDate    = cell(1,length(DateD));
                    parfor k = 1:length(DateD)
                        NameDate{k} = datestr(DateD(k),'dd-mm-yyyy');
                    end

                    Results = [DateD Data];
                    Results = array2table(Results,'VariableNames',NameBasin,'RowNames',NameDate);

                    writetable(Results, fullfile(UserData.PathProject,'RESULTS','Demand',UserData.DemandVar{i},['Scenario-',num2str(NSce)],['Total_',DeRe{dr},'.dat']), 'WriteRowNames',true)
                end
            catch
            end
        end
    end
end

 % Progres Process
% --------------
close(ProgressBar);
% --------------

%% Operation Completed
[Icon,~] = imread('Completed.jpg'); 
msgbox('Operation Completed','Success','custom',Icon);