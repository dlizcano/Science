function Pre_Procesing_ClimateData(UserData)
% -------------------------------------------------------------------------
% Matlab Version - R2016b 
% -------------------------------------------------------------------------
%                              BASE DATA 
%--------------------------------------------------------------------------
%
% Project       : Landscape planning for agro-industrial expansion 
%                 in a large, well-preserved savanna: how to plan 
%                 multifunctional landscapes at scale for nature 
%                 and people in the Orinoquia region, Colombia
% Author        : Jonathan Nogales Pimentel
% Email         : jonathannogales02@gmail.com
% Occupation    : Hydrology Specialist
% Company       : The Nature Conservancy - TNC
% Date          : November, 2017
%
%--------------------------------------------------------------------------
% This program is free software: you can redistribute it and/or modify it 
% under the terms of the GNU General Public License as published by the 
% Free Software Foundation, either version 3 of the License, or option) any 
% later version. This program is distributed in the hope that it will be 
% useful, but WITHOUT ANY WARRANTY; without even the implied warranty of 
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
% ee the GNU General Public License for more details. You should have 
% received a copy of the GNU General Public License along with this program
% If not, see http://www.gnu.org/licenses/.
%--------------------------------------------------------------------------
%                               DESCRIPTION 
%--------------------------------------------------------------------------
%


%% Folder Resulst
warning off
mkdir(fullfile(UserData.PathProject,'RESULTS','P'))
mkdir(fullfile(UserData.PathProject,'RESULTS','ETP'))

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

%% Load ShapeFile HUA
try
    [Basin, CodeBasin]      = shaperead(fullfile(UserData.PathProject,'DATA','Geografic','HUA',UserData.ShapeFileHUA));
    XBasin                  = {Basin.X}';
    YBasin                  = {Basin.Y}';
    BoundingBox             = {Basin.BoundingBox}';
    
    clearvars Basin
    
    if isfield(CodeBasin,'Code') 
        CodeBasin_Tmp = [CodeBasin.Code];
    else
        errordlg(['There is no attribute called "Code" in the Shapefile "',UserData.ShapeFileHUA,'"'], '!! Error !!')
        return
    end

    [CodeBasin,PosiBasin]   = sort(CodeBasin_Tmp);
    CodeBasin               = CodeBasin';
    XBasin                  = XBasin(PosiBasin');
    YBasin                  = YBasin(PosiBasin');
    BoundingBox             = BoundingBox(PosiBasin');
    
    clearvars CodeBasin_Tmp
catch
    errordlg(['The Shapefile "',UserData.ShapeFileHUA,'" not found'],'!! Error !!')
    return
end

%% Calculation Evapotranspiration
if UserData.Mode == 3
    if UserData.Cal_ETP == 1
        % False
        Vvar = [1 3];
    else
        % True
        Vvar = [1 2];
    end
elseif UserData.Mode == 1
    Vvar = 1;
elseif UserData.Mode == 2
    if UserData.Cal_ETP == 1
        % False
        Vvar = 3;
    else
        % True
        Vvar = 2;
    end
end

% Variables Procesing
for v = Vvar
    %% Data Type - Points
    if eval(['UserData.TypeData',UserData.ClimateVar{v}]) == 2
        
        % Progres Process
        % --------------
        ProgressBar     = waitbar(0, 'Please wait...');
        
        % Sheet in Excel 
        [~,Scenarios]   = xlsfinfo( fullfile(UserData.PathProject,'DATA','Climate',UserData.ClimateVar{v}, eval(['UserData.Data',UserData.ClimateVar{v}])) );
        Cont = 1;
        
        for i = 1:length(Scenarios)
            % Load Data
            try
                [Data, DateTmp] = xlsread( fullfile(UserData.PathProject,'DATA','Climate',UserData.ClimateVar{v}, eval(['UserData.Data',UserData.ClimateVar{v}])), Scenarios{i});
            catch
                errordlg(['The File "',eval(['UserData.Data',UserData.ClimateVar{v}]),'" not found'],'!! Error !!')
                return
            end
            
            % Load Data
            try
                Tmp     = xlsread( fullfile(UserData.PathProject,'DATA','Params',UserData.DataParams), 'Gauges_Catalog');
                Catalog = Tmp(:,[1 4 5 6 ]); 
            catch
                errordlg(['The File "',UserData.GaugesCatalog,'" not found'],'!! Error !!')
                return
            end
            
            CodeGauges  = Data(1,:)';
            Data        = Data(2:end,:);
            DateTmp     = DateTmp(2:length(Data(:,1))+1,1);
            [~, posi]   = ismember(CodeGauges, Catalog(:,1));
            
            XCatalog    = Catalog(posi,2);
            YCatalog    = Catalog(posi,3);
            ZCatalog    = Catalog(posi,4);
            
            % Date
            Date        = NaN(length(Data(:,1)),1);
            for w = 1:length(Data(:,1))
                Date(w) = datenum(DateTmp{w},'yyyy-mm-dd');
            end
            
            Values      = NaN(length(Data(:,1)),length(CodeBasin));
            %% PRECIPITATION
            if v == 1
                
                Xp = cell(length(CodeBasin),1);
                Yp = cell(length(CodeBasin),1);
                
                if UserData.Parallel == 1
                    parfor k = 1:length(CodeBasin) 
                        ExtentBasin = BoundingBox{k};
                        x           = linspace(ExtentBasin(1,1), ExtentBasin(2,1),10);
                        y           = linspace(ExtentBasin(2,2), ExtentBasin(1,2),10);
                        [x, y]      = meshgrid(x, y);
                        x           = reshape(x,[],1);
                        y           = reshape(y,[],1);
                        id          = inpolygon(x, y, XBasin{k}, YBasin{k});

                        Xp{k}       = x(id);
                        Yp{k}       = y(id);

                    end
                else 
                    for k = 1:length(CodeBasin) 
                        ExtentBasin = BoundingBox{k};
                        x           = linspace(ExtentBasin(1,1), ExtentBasin(2,1),10);
                        y           = linspace(ExtentBasin(2,2), ExtentBasin(1,2),10);
                        [x, y]      = meshgrid(x, y);
                        x           = reshape(x,[],1);
                        y           = reshape(y,[],1);
                        id          = inpolygon(x, y, XBasin{k}, YBasin{k});

                        Xp{k}       = x(id);
                        Yp{k}       = y(id);

                    end
                end
                    
                clearvars x y id
                
                if UserData.Parallel == 1
                    for w = 1:length(Data(:,1))

                        vstruct = SemivariogramSetting(XCatalog, YCatalog, Data(w,:)',UserData.Parallel);
                        DataTmp = Data(w,:)';

                        parfor k = 1:length(CodeBasin) 
                            Values(w,k) = nanmean(PrecipitationFields(XCatalog, YCatalog, DataTmp, Xp{k}, Yp{k}, vstruct));
                        end

                        % Progres Process
                        % --------------
                        waitbar(Cont / ((length(Data(:,1)) * length(Scenarios))))
                        Cont = Cont + 1;
                    end
                else
                    for w = 1:length(Data(:,1))
                    
                        vstruct = SemivariogramSetting(XCatalog, YCatalog, Data(w,:)',UserData.Parallel);
                        DataTmp = Data(w,:)';

                        for k = 1:length(CodeBasin) 
                            Values(w,k) = nanmean(PrecipitationFields(XCatalog, YCatalog, DataTmp, Xp{k}, Yp{k}, vstruct));
                        end

                        % Progres Process
                        % --------------
                        waitbar(Cont / ((length(Data(:,1)) * length(Scenarios))))
                        Cont = Cont + 1;
                    end
                end
                
                % ---------------------------------------------------------
                % Filter
                % ---------------------------------------------------------
                NumYear = length(unique(year(Date)));
                DataTmp = NaN((NumYear*12),1);
                nm      = length(Date);
                nn      = month(Date(1));

                for k = 1:length(CodeBasin)
                    DataTmp(nn:(nm + nn - 1)) = Values(:,k);

                    Tmp = reshape(DataTmp,12,[])';

                    for f = 1:12
                        RI = quantile(Tmp(:,f),0.75) - quantile(Tmp(:,f),0.25);
                        id = Tmp(:,f) > (quantile(Tmp(:,f),0.75) + (1.5*RI));

                        Tmp(id,f) = NaN;
                        if sum(id) ~= 0
                            Tmp(id,f) = unique(max(Tmp(:,f)));
                        end

                        id = Tmp(:,f) < (quantile(Tmp(:,f),0.25) - (1.5*RI));

                        Tmp(id,f) = NaN;
                        if sum(id) ~= 0
                            Tmp(id,f) = unique(min(Tmp(:,f)));
                        end

                    end
                    Values(:,k) = reshape(Tmp',[],1);
                end
                
            end
            
            %% EVAPOTRANSPIRATION 
            if v > 1
                % Load Raster DEM
                try
                    [Z,~,~,ExtentRaster]      = geotiffread( fullfile(UserData.PathProject,'DATA','Geografic','DEM',UserData.GridDEM) );
                catch
                    errordlg(['The Raster "',UserData.GridDEM ,'" not found'],'!! Error !!')
                    return
                end
                Z(Z<0) = NaN;
                [RowDEM, ColDEM] = size(Z);
                XDEM            = linspace(ExtentRaster(1,1), ExtentRaster(2,1),ColDEM);
                YDEM            = linspace(ExtentRaster(2,2), ExtentRaster(1,2),RowDEM);
                [XDEM, YDEM]    = meshgrid(XDEM, YDEM);
                
                Zetp = cell(length(CodeBasin),1);
                
                if UserData.Parallel == 1
                    parfor k = 1:length(CodeBasin) 
                        ExtentBasin = BoundingBox{k};
                        x           = linspace(ExtentBasin(1,1), ExtentBasin(2,1),10);
                        y           = linspace(ExtentBasin(2,2), ExtentBasin(1,2),10);
                        [x, y]      = meshgrid(x, y);
                        x           = reshape(x,[],1);
                        y           = reshape(y,[],1);
                        id          = inpolygon(x, y, XBasin{k}, YBasin{k});

                        Zetp{k}     = interp2(XDEM, YDEM, Z, x(id), y(id), 'nearest');
                    end
                    
                    for w = 1:length(Data(:,1))
                        % Setting Parameters Temperature
                        ParamT = TemperatureSetting(ZCatalog, Data(w,:)');

                        parfor k = 1:length(CodeBasin)    
                            if v == 2
                                try
                                    % Temperature to Evapotranspiration
                                    Values(w,k) = nanmean(ETP_Thornthwaite(polyval(ParamT,double(Zetp{k}))));
                                catch
                                    Values(w,k) = nanmean(ETP_Thornthwaite(polyval(ParamT,double(Zetp{k}))));
                                end
                            else
                                try
                                    Values(w,k) = nanmean(polyval(ParamT,double(Zetp{k})));
                                catch
                                    Values(w,k) = nanmean(polyval(ParamT,double(Zetp{k})));
                                end
                            end

                        end
                        % Progres Process
                        % --------------
                        waitbar(Cont / ((length(Data(:,1)) * length(Scenarios))))
                        Cont = Cont + 1;
                    end
                
                else
                    
                    for k = 1:length(CodeBasin) 
                        ExtentBasin = BoundingBox{k};
                        x           = linspace(ExtentBasin(1,1), ExtentBasin(2,1),10);
                        y           = linspace(ExtentBasin(2,2), ExtentBasin(1,2),10);
                        [x, y]      = meshgrid(x, y);
                        x           = reshape(x,[],1);
                        y           = reshape(y,[],1);
                        id          = inpolygon(x, y, XBasin{k}, YBasin{k});

                        Zetp{k}     = interp2(XDEM, YDEM, Z, x(id), y(id), 'nearest');
                    end
                    
                    for w = 1:length(Data(:,1))
                        % Setting Parameters Temperature
                        ParamT = TemperatureSetting(ZCatalog, Data(w,:)');

                        for k = 1:length(CodeBasin)    
                            if v == 2
                                try
                                    % Temperature to Evapotranspiration
                                    Values(w,k) = nanmean(ETP_Thornthwaite(polyval(ParamT,double(Zetp{k}))));
                                catch
                                    Values(w,k) = nanmean(ETP_Thornthwaite(polyval(ParamT,double(Zetp{k}))));
                                end
                            else
                                try
                                    Values(w,k) = nanmean(polyval(ParamT,double(Zetp{k})));
                                catch
                                    Values(w,k) = nanmean(polyval(ParamT,double(Zetp{k})));
                                end
                            end

                        end
                        % Progres Process
                        % --------------
                        waitbar(Cont / ((length(Data(:,1)) * length(Scenarios))))
                        Cont = Cont + 1;
                    end
                end
                
            end
            
            %% Save Data Table
            NameBasin       = cell(1,length(CodeBasin) + 1);
            NameBasin{1}    = 'Date_Matlab';
            for k = 2:length(CodeBasin) + 1
                NameBasin{k} = ['Basin_',num2str(CodeBasin(k - 1))];
            end

            NameDate    = cell(1,length(Date));
            for k = 1:length(Date)
                NameDate{k} = datestr(Date(k),'dd-mm-yyyy');
            end

            Results = [Date Values];
            Results = array2table(Results,'VariableNames',NameBasin,'RowNames',NameDate);

            if strcmp(UserData.ClimateVar{v},'Precipitation')
                writetable(Results, fullfile(UserData.PathProject,'RESULTS','P',['Pcp_Scenario-',num2str(i),'.dat']), 'WriteRowNames',true)
                
            elseif strcmp(UserData.ClimateVar{v},'Temperature')
                writetable(Results, fullfile(UserData.PathProject,'RESULTS','ETP',['ETP_Scenario-',num2str(i),'.dat']), 'WriteRowNames',true)
                
            else
                writetable(Results, fullfile(UserData.PathProject,'RESULTS','ETP',['ETP_Scenario-',num2str(i),'.dat']), 'WriteRowNames',true)
            end
            
        end
        
        % Progres Process
        % --------------
        close(ProgressBar);
        % --------------
        
    else
        % ---------------------------------------------------------------------------------------------------------------------------------------------------
        %% Data Type - Raster
        NameFolder  = dir( fullfile(UserData.PathProject,'DATA','Climate',UserData.ClimateVar{v}, '*tif') );
        Id          = [NameFolder.isdir]';
        NameFolder  = {NameFolder.name}';
        NameFolder  = NameFolder(Id);
        Scenario    = NameFolder(3:end);
        
        % Progres Process
        % --------------
        ProgressBar     = waitbar(0, 'Please wait...');
        
        Cont = 1;
        for w = 1:length(Scenario)
            
            Data = dir(fullfile(eval(['UserData.Data',UserData.ClimateVar{v}]),Scenario{w},'Raster_*'));
            Data = {Data.name};
            Date = NaN(length(Data),1);
            
            for i = 1:length(Date)
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

                    Id_Basin    = cell(length(CodeBasin),1);
                    
                    if UserData.Parallel == 1
                        parfor k = 1:length(CodeBasin)
                            Id_Basin{k} = inpolygon(x, y, XBasin{k}, YBasin{k});
                        end
                    else
                        for k = 1:length(CodeBasin)
                            Id_Basin{k} = inpolygon(x, y, XBasin{k}, YBasin{k});
                        end
                    end
                    
                    % save values 
                    Values          = NaN(length(Data(:,i)),length(CodeBasin));
                
                end

                RawData         = reshape(RawData,[],1);
                
                if strcmp(UserData.ClimateVar{v},'Temperature')
                    RawData = ETP_Thornthwaite(RawData);
                end
                
                for k = 1:length(CodeBasin) 
                    Values(i,k) = nanmean( RawData(Id_Basin{k}) );
                end
                
                % Progres Process
                % --------------
                waitbar(Cont / ((length(Data) * length(Scenario))))
                Cont = Cont + 1;
            end  
            
            %% Save Data Table
            NameBasin       = cell(1,length(CodeBasin) + 1);
            NameBasin{1}    = 'Date_Matlab';
            for k = 2:length(CodeBasin) + 1
                NameBasin{k} = ['Basin_',num2str(CodeBasin(k - 1))];
            end

            NameDate    = cell(1,length(Date));
            for k = 1:length(Date)
                NameDate{k} = datestr(Date(k),'dd-mm-yyyy');
            end

            Results = [Date Values];
            Results = array2table(Results,'VariableNames',NameBasin,'RowNames',NameDate);

            if strcmp(UserData.ClimateVar{v},'Precipitation')
                writetable(Results, fullfile(UserData.PathProject,'RESULTS','P',['Pcp_Scenario-',num2str(i),'.dat']), 'WriteRowNames',true)
                
            elseif strcmp(UserData.ClimateVar{v},'Temperature')
                writetable(Results, fullfile(UserData.PathProject,'RESULTS','ETP',['ETP_Scenario-',num2str(i),'.dat']), 'WriteRowNames',true)
                
            else
                writetable(Results, fullfile(UserData.PathProject,'RESULTS','ETP',['ETP_Scenario-',num2str(i),'.dat']), 'WriteRowNames',true)
            end
            
        end
         % Progres Process
        % --------------
        close(ProgressBar);
        % --------------
    end
end
    
%% Operation Completed
[Icon,~] = imread('Completed.jpg'); 
msgbox('Operation Completed','Success','custom',Icon);