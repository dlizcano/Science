classdef ClassABCDFPD_HSU
    properties(Hidden)
        % Operation Mode of the AnalysisNetwork
        Mode(1,1) logical               = 1;
        % ID of the of the AnalysisNetwork
        CurrID(1,1) double              = 0;
        % PoNet
        PoNet(:,1) double               = [];
        % Variables to Propagate of the AnalysisNetwork
        ProVar(:,:) double              = [];
        % Variables to Accumulate of the AnalysisNetwork
        AccumVar(:,:) double            = [];
        % Variables to Accumulate with Clipping of the AnalysisNetwork
        AccumClipVar(:,:) double        = [];
        % Variables to Accumulate with Losses of the AnalysisNetwork
        AccumLossVar(:,:) double        = [];
        % Variables to Accumulate with Losses and Clipping of the AnalysisNetwork
        AccumClipLossVar(:,:) double    = [];
        % Loss Rate (%) of the AnalysisNetwork
        LossRate(:,1) double {mustBeGreaterThanOrEqual(LossRate,0), mustBeLessThanOrEqual(LossRate,100)} = [];
    end
    
    properties
        % ID of the Hilldise Seccion Unit (Ad)
        ID(:,1) double
        % Initial Node of the Hilldise Seccion Unit (Ad)
        FromHSU(:,1) double
        % End Node of the Hilldise Seccion Unit (Ad)
        ToHSU(:,1) double
        % ID of the Hilldise Seccion Unit corresponding to the River Mouth (Ad)
        ID_RM(:,1) double
        % ArcID of the Hilldise Seccion Unit with Barriers (Ad)
        ArcBarrier(:,1) double
    end
    
    properties %ABCD
        % Parameters "a" of the Hilldise Seccion Unit
        a (:,1) double {mustBeGreaterThanOrEqual(a,0), mustBeLessThanOrEqual(a,1)}
        % Parameters - "b" of the Hilldise Seccion Unit
        b (:,1) double {mustBeGreaterThanOrEqual(b,0)}
        % Parameters - "c" of the Hilldise Seccion Unit
        c (:,1) double {mustBeGreaterThanOrEqual(c,0), mustBeLessThanOrEqual(c,1)}
        % Parameters - "d" of the 
        d (:,1) double {mustBeGreaterThanOrEqual(d,0), mustBeLessThanOrEqual(d,1)}
        
    end
    properties %Floodplains
        % Percentage lateral flow between river and floodplain  [dimensionless]
        Trp
        % Percentage return flow from floodplain to river       [dimensionless]
        Tpr
        % Threshold lateral flow between river and floodplain   [m^3]
        Q_Umb
        % Threshold return flow from floodplain to river        [mm]
        V_Umb
    end
    
    methods
        function HSU = ClassABCDFPD_HSU(Value)
            Tmp1 = sum(isnan(Value));
            Tmp2 = sum(Value < 0);
            Tmp3 = unique(Value); 
            if Tmp1 > 0
                error('There are NAN values')
            end
            if Tmp2 > 0
                error('There are negative values')
            end
            if length(Tmp3) ~= length(Value)
                error('There are equal values')
            end
            
            HSU.ID = Value;
        end
    end
    
    methods
        function obj = set.FromHSU(obj, Value)
            
            Tmp1 = sum(isnan(Value));
            Tmp2 = sum(Value < 0);
            Tmp3 = unique(Value);
            if Tmp1 > 0
                error('There are NAN values')
            end
            if Tmp2 > 0
                error('There are negative values')
            end
            if length(Tmp3) ~= length(Value)
                error('There are equal values')
            end
            if length(Value) ~= length(obj.ID)
                error('Tthe dimensions of the vector do not match the ID')
            end 
            
            obj.FromHSU = Value;
        end
        
        function obj = set.ToHSU(obj, Value)
            Tmp1 = sum(isnan(Value));
            Tmp2 = sum(Value < 0);
            if Tmp1 > 0
                error('There are NAN values')
            end
            if Tmp2 > 0
                error('There are negative values')
            end
            if length(Value) ~= length(obj.ID)
                error('Tthe dimensions of the vector do not match the ID')
            end 
            
            obj.ToHSU = Value;
        end
        
    end
    
    methods
        %% Analysis Network
        [FuncNetwork, varargout]    = AnalysisNetwork(obj, Mode, CurrID, varargin); 
        
    end

end