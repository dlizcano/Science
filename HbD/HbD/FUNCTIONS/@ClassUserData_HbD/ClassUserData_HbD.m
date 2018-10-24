classdef ClassUserData_HbD
   properties
        %% Name Project
        NameProject(1,:) char   = 'Project';
        
       %% Paths
        % Path Project
        Path_Project(1,:) char  = pwd;  
        % Computing Parameters (Comp)
        % -----------------------------------------------------------------
        Parms_Comp_Verbose(1,1) logical                     = 1;
        
        % Parameters of the Hydroenergy by Design 
        % -----------------------------------------------------------------
        % River Mouth - Magdalena-Cauca
        Params_HbD_Cal_ArcID_RM(1,1) double
        % Mode AnalysisNetwork
        Params_HbD_Cal_ModeNetwork(1,1) logical
        % CurrID AnalysisNetwork
        Params_HbD_Cal_CurrIDNetwork(1,1) double
        % Drenage Order Threshold
        Params_HbD_Cal_DrenageOrderThreshold(1,1) double
        % Scenarios Random - Threshold
        Params_HbD_Cal_ThresholdComb(1,1) double
        % Random scenarios
        Params_HbD_Cal_EscBaseLine(:,1) logical
        %
        Params_HbD_Cal_EscRandom(:,1) logical
        %
        Params_HbD_Cal_EscOther logical
        %
        Params_HbD_Ope_EscRandom(1,1) logical
        %
        Params_HbD_Ope_EscOther(1,1) logical
        % 
        Params_HbD_Cal_ThresholdDOR(1,:) double     = [0, 2,  5, 10, 15, 25, 50, 100];
        %
        Params_HbD_Cal_ThresholdSed(1,:) double     = [0, 5, 15, 25, 50, 100];
        %
        Params_HbD_Cal_ThresholdElev(1,:) double    = [(100:100:3100) 10000];
        
        
        %% Name Files       
        % Name of the Master Excel for the Analysis HbD 
        NameFile_Excel_MasterHbD(1,:) char      = 'Master_HbD';
        % Basic Data 
        NameFile_CSV_DataHbD(1,:) char          = '';
        % Name of the HUA ShapeFile 
        NameFile_ShapeFile_HUA(1,:) char        = 'HUA';
        % Name of the Topologcila Network Shapefile
        NameFile_ShapeFile_Network(1,:) char    = 'Topological_Network';
        % Name of the Digital Elevation Model 
        NameFile_Raster_DEM(1,:) char           = 'DEM';
        % Name of the Flow Direction
        NameFile_Raster_FlowDir(1,:) char       = 'FlowDir';
        % Name of the Flow Accumulation
        NameFile_Raster_FlowAccum(1,:) char     = 'FlowAccum';        
        % % Path of the Precipitation
        NameFile_Rasters_DataPcp(1,:) cell
        % Path of the Temperature Excel 
        NameFile_Rasters_DataT(1,:) cell
        % Path of the Evapotranspiration Excel 
        NameFile_Rasters_DataET(1,:) cell
        % Path of the Precipitation Excel 
        NameFile_Excel_DataPcp(1,:) char        = 'Precipitation';
        % Path of the Temperature Excel 
        NameFile_Excel_DataT(1,:) char          = 'Temperature';
        % Path of the Evapotranspiration Excel 
        NameFile_Excel_DataET(1,:) char         = 'Evapotrasnpiration';
        % Path of the Streamflow Excel
        NameFile_Excel_DataQl(1,:) char         = 'Streamflow';
        % Path of the HOM Parameters Model Excel
        NameFile_Excel_ParamsHOM(1,:) char      = 'Master_HM';
        % Path of the Agricultural Demand Data Excel 
        NameFile_Excels_DataAgriDe(1,:) cell
        % Path of the Domestic Demand Data Excel 
        NameFile_Excels_DataDomDe(1,:) cell
        % Path of the Livestock Demand Data Excel 
        NameFile_Excels_DataLivDe(1,:) cell
        % Path of the Hydrocarbos Demand Data Excel 
        NameFile_Excels_DataHyDe(1,:) cell
        % Path of the Mining Demand Data Excel 
        NameFile_Excels_DataMinDe(1,:) cell
        
   end
   
   properties (SetAccess = private)
        %% Name Folders
        % Name o the Data Folder
        PathFolder_Data(1,:) char                       = 'DATA';
         % Name o the Figures Folder
        PathFolder_Figures(1,:) char                    = 'FIGURES';
        % Name o the Results Folder
        PathFolder_Results(1,:) char                    = 'RESULTS';
        % 
        PathFolder_D_HbD(1,:) char                      = fullfile('DATA', 'HbD');
        % Name Folder of the Geografic Data 
        PathFolder_D_GeograficData(1,:) char            = fullfile('DATA', 'Geografic');
        % Name Folder of the Digital Elevation Model 
        PathFolder_D_DEM(1,:) char                      = fullfile('DATA', 'Geografic', 'DEM');
        % Name Folder of the Hydrological Response Unit 
        PathFolder_D_HUA(1,:) char                      = fullfile('DATA', 'Geografic', 'HUA');
        % Name Folder of the Topological Network 
        PathFolder_D_TopolicalNetwork(1,:) char         = fullfile('DATA', 'Geografic', 'Network');
        % Name Folder of the Spatial Unit
        PathFolder_D_SpatialUnit(1,:) char              = fullfile('DATA', 'Geografic', 'SU');
        % Name Folder of the Spatial Unit Distribution 
        PathFolder_D_SpatialUnitDistribution(1,:) char  = fullfile('DATA', 'Geografic', 'SUD');
        % Name Folder with other Geografics files 
        PathFolder_D_OtherDataGeo(1,:) char             = fullfile('DATA', 'Geografic', 'Other');
        % Interest Area
        PathFolder_D_AreaInterest(1,:) char             = fullfile('DATA', 'Geografic', 'AreaInterest');
        % Area Water Project
        PathFolder_D_AreaWaterProject(1,:) char         = fullfile('DATA', 'Geografic', 'AreaWaterProject');
        % Name Folder of the Climate Data
        PathFolder_D_ClimateDate(1,:) char              = fullfile('DATA', 'Climate');
        % % Name Folder of the Hydrologcial Data 
        PathFolder_D_Hydrological(1,:) char             = fullfile('DATA', 'Hydrological');
        % Name Folder of the Master Excel
        PathFolder_D_ExcelMaster(1,:) char              = fullfile('DATA', 'Master_File');
        %
        PathFolder_R_HbD(1,:) char                      = fullfile('RESULTS', 'HbD');
        %
        PathFolder_R_HbD_Project(1,:) char               = fullfile('RESULTS', 'HbD', 'HbD_Project');
        %
        PathFolder_R_HbD_Network(1,:) char               = fullfile('RESULTS', 'HbD', 'HbD_TopologicalNetwork');
        %
        PathFolder_R_HbD_Summary(1,:) char               = fullfile('RESULTS', 'HbD', 'Summary');
        %
        PathFolder_R_HM_Demand(1,:) char                = fullfile('RESULTS', 'Demand');
        %
        PathFolder_R_HM_ETP(1,:) char                   = fullfile('RESULTS', 'ETP');
        %
        PathFolder_R_HM_Pcp(1,:) char                   = fullfile('RESULTS', 'P');
        %
        PathFolder_R_HM_Models(1,:) char                = fullfile('RESULTS','Models');
        
   end
   
   methods 
       obj = CreateFolder(obj)
   end

end