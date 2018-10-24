classdef ClassHydroelectricProject
    
    properties
        % Id project 
        ID(:,1) double
        % Name Project
        Name(:,1) cell 
        % Coordinate in X
        Coor_X(:,1) double
        % Coordinate in Y
        Coor_Y(:,1) double
        % ArcID where the Hydroelectric Project is located
        ArcID(:,1) double
        % Total Volumen of the Hydroelectric Project 
        TotalVolumen(:,1) double %{mustBeGreaterThanOrEqual(TotalVolumen,0)}
        % Install Power of the Hydroelectric Project 
        InstallPower(:,1) double %{mustBeGreaterThanOrEqual(InstallPower,0)}
        % Higth Dam of the Hydroelectric Project 
        HigthDam(:,1) double %{mustBeGreaterThanOrEqual(HigthDam,0)}
        % Streamflow that regulate of the Hydroelectric Project 
        Qmed(:,1) %double {mustBeGreaterThanOrEqual(Qmed,0)}
        % Soil Streamflow that regulate of the Hydrolectric Project
        LossRate(:,1) double %{mustBeGreaterThanOrEqual(LossRate,0), mustBeLessThanOrEqual(LossRate,100)}
        % Scenario
        Scenario(:,1) logical
        % Regional ArcID
        ArcInter(:,1) double
        % Curves
        Curves(:,1) cell
        % Network
        Network
    end
    
    methods 
        function obj = set.TotalVolumen(obj,Value)
            if sum(Value < 0) ~= 0
                error('Values must be greater than or equal to 0')
            end            
            obj.TotalVolumen = Value;
        end
        
        function obj = set.InstallPower(obj,Value)
            if sum(Value < 0) ~= 0
                error('Values must be greater than or equal to 0')
            end            
            obj.InstallPower = Value;
        end
        
        function obj = set.HigthDam(obj,Value)
            if sum(Value < 0) ~= 0
                error('Values must be greater than or equal to 0')
            end            
            obj.HigthDam = Value;
        end
        
        function obj = set.Qmed(obj,Value)
            if sum(Value < 0) ~= 0
                error('Values must be greater than or equal to 0')
            end            
            obj.Qmed = Value;
        end
        
        function obj = set.LossRate(obj,Value)
            if sum((Value < 0) & (Value > 100)) ~= 0
                error('Values must be greater than or equal to 0 and Values must be less than or equal to 100')
            end            
            obj.LossRate = Value;
        end
        
    end
    
    methods (Access = private)
        
        function PropertiesCheck(obj)
            Name = properties(obj);
            for i = 1:length(Name)
                if eval( ['isempty(obj.',Name{i},')'] )
                    error(['The ',Name{i},' property is not defined'])
                end
            end
        end
    end
    
    methods
        %% Generation of Random Scenarios
        Scenarios = RandomScenarios(obj, ProjectID, ThresholdComb);
        
        %% DOR (Degree Of Regulation) and DORw (Weighted Degree Of Regulation)
        [DOR, DORw, varargout]  = DegreeRegulation_Ql(obj, NameVarQ, varargin);
        
        %% Index for Sediment
        [Sed, varargout]        = DegreeRegulation_Qs(obj, NameVarQs, varargin);
        
        %% Fragmentation
        [Frag,varargout]        = Fragmentation(obj, DrenageOrderThreshold, NameVarDrenage, varargin);
 
        %% Total Index 
        [DOR, DORw, Sed, Frag, varargout] = Impact_Tier1(obj, DrenageOrderThreshold, NameVar, varargin);
        
        %% Water Mirror Hydroelectric Project 
        [Vol, varargout]        = Footprint(obj, DEM, varargin)
        
        %% Complementation Volumenes
        function Vol = CompleVolumen(obj, DEM, varargin)
            Vol = Footprint(obj, DEM, varargin);
        end
        
        %% Complementation Sediment Loss Rate
        function LossR = SedimentDendy(obj)
            Tmp     = log10(obj.TotalVolumen./(obj.Qmed.*86400.*365));
            LossR   = 100.*((0.97.^(0.19.^Tmp)));
            LossR(LossR>100)    = 0;
            LossR(LossR<0)      = 0;
            LossR(isnan(LossR)) = 0;
        end
        
        %% FootPrint Basic Analysis
%         [] = FootPrintBasic(obj, ShpWM, ShpAI, PorcVar)
        
        %% FootPrint 
%         [] = FootPrintOpt(obj, ShpWM, ShpAI)
    end
    
end