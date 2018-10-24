classdef ClassNetwork 
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
        % ID of the River Sections (Ad)
        ArcID(:,1) double
        % Initial Node of the River Sections (Ad)
        FromNode(:,1) double
        % End Node of the River Sections (Ad)
        ToNode(:,1) double
        % ArcID of the River Sections corresponding to the River Mouth (Ad)
        ArcID_RM(:,1) double
        % ArcID of the River Sections with Barriers (Ad)
        ArcBarrier(:,1) double
        % Variable Table
        Variables table  
        
%         % Basin Area 
%         Catchment_Area
%         
%         % Hydrological Params 
%         HydroParams
%         
%         % Cover 
%         Cover
%         
%         % ArcID with floodplains 
%         ArcFloodplains
        
        
        
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
        %% Analysis Network
        [FuncNetwork, varargout]    = AnalysisNetwork(obj, Mode, CurrID, varargin); 
        
    end

end