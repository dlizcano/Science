function [VAc, ETR, StatesMT, StatesMF] = HMO_Validation(Date,P, ETP, DemandSup,Returns, CropArea,...
                                    CropKc, BasinArea, FloodArea, BasinCode, Arc_InitNode, Arc_EndNode,...
                                    ArcID_Downstream, a, b, c, d,Tpr,Trp, Q_Umb, V_Umb, IDExtAgri,...
                                    IDExtDom, IDExtLiv, IDExtMin, IDExtHy, IDRetDom, IDRetLiv, IDRetMin,...
                                    IDRetHy,ArcIDFlood,ParamExtSup, ParamExtSub,IDAq, Sw, Sg,Vh)
                                    
%% BASE DATA 
% Project               : Landscape planning for agro-industrial expansion 
%                         in a large, well-preserved savanna: how to plan 
%                         multifunctional landscapes at scale for nature and 
%                         people in the Orinoquia region, Colombia
% Author                : Jonathan Nogales Pimentel
% Email                 : nogales02@hotmail.comHydrology Specialist  : Carlos Andrés Rogéliz
% Company               : The Nature Conservancy - TNC
% 
%% MODEL OF THOMAS - (1981) - "abcd"
% Copyright (C) 2017 Apox Technologies
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
%% INPUT DATA
% t         = Month Number 
% Cat       = Basin Number 
% CatExt    = 
% CatRet    = 
% CatFlood  = Basin Number Whit Floodplains
% NCrop     = Crop Number
%
% -------------------------------------------------------------------------
% - Date 
% -------------------------------------------------------------------------
%   Date        [t,1]       = Date                          [Datenum]
%
% -------------------------------------------------------------------------
% - Climate Data 
% -------------------------------------------------------------------------
%   P           [t,Cat]     = Precipitation                 [mm]
%   ETP         [t,Cat]     = Potential Evapotranspiration  [mm]
%
% -------------------------------------------------------------------------
% - Demand and Returns Data
% -------------------------------------------------------------------------
%   DemandSup   [t,Cat]     = Demand                        [m^3]
%   DemandSub   [t,Cat]     = Groundwater Demand            [m^3]
%   Returns     [t,Cat]     = Returns                       [m^3]
%
% -------------------------------------------------------------------------
% - Crop Data
% -------------------------------------------------------------------------
%   CropArea    [Cat,NCrop] = Crop Area                     [m^2]
%   CropKc      [Cat,NCrop] = Crop Coeffient                [Ad]
%
% -------------------------------------------------------------------------
% - Basin Data 
% -------------------------------------------------------------------------
%   BasinArea   [Cat,1]     = Basin Area                    [m^2]
%
% -------------------------------------------------------------------------
% - Floodplain Data
% -------------------------------------------------------------------------
%   FloodArea   [t,Cat]     = Floodplain Area               [m^2]
%
% -------------------------------------------------------------------------
% - Topologial Network
% -------------------------------------------------------------------------
%   ArcID               [t,Cat]   = ID of each section of the network               [Ad]
%   Arc_InitNode        [t,Cat]   = Initial node of each section of the network     [Ad]
%   Arc_EndNode         [t,Cat]   = End node of each section of the network         [Ad] 
%   ArcID_Downstream    [t,Cat]   = ID of the end node of accumulation              [Ad]
% 
% -------------------------------------------------------------------------
% - Parameters of the Thomas Model
% -------------------------------------------------------------------------
% ParamThomas ->
%   [Cat,1]  - a       = Soil Retention Capacity                                    [Ad]
%   [Cat,2]  - b       = Maximum Capacity of Soil Storage                           [Ad]
%   [Cat,3]  - c       = Flow Fraction Soil - Aquifer                               [Ad]
%   [Cat,4]  - d       = Flow Fraction Aquifer - Soil                               [Ad]
%
% -------------------------------------------------------------------------
% - Parameters of the Floodplains Model
% -------------------------------------------------------------------------
% ParamFloodplain ->
%   [CatFlood,1]  - Trp     = Percentage lateral flow between river and floodplain  [Ad]
%   [CatFlood,2]  - Tpr     = Percentage return flow from floodplain to river       [Ad]
%   [CatFlood,3]  - Q_Umb   = Threshold lateral flow between river and floodplain   [mm]
%   [CatFlood,4]  - V_Umb   = Threshold return flow from floodplain to river        [mm]
%
% -------------------------------------------------------------------------
% - Parameters of the Crop
% -------------------------------------------------------------------------
% ParamCrop ->
%   [NCrop,1]  - Psub   = Percentage of Groundwater Extraction         [Ad]
%   [NCrop,2]  - Psup   = Porcentage of Superficial Water Extraction   [Ad]
%
% -------------------------------------------------------------------------
% - Parameters Basin
% -------------------------------------------------------------------------
%   ArcIDFlood  [CatFlood,12]   = ID basins with floodplain            [Ad]
%   ArcIDExt    [CatExt,13]     = ID basin with water extraction       [Ad]
%   ArcIDRet    [CatRet,14]     = ID basin with water returns          [Ad]
%   IDAq        [Cat,14]        = ID Aquifer                           [Ad]
%
% -------------------------------------------------------------------------
% - State Variables of the Models
% -------------------------------------------------------------------------
% StateThomas
%   [Cat,1]  - Sgo     = Aquifer Storage                               [mm]
%   [Cat,2]  - Swo     = Soil Moinsture                                [mm]
%
% StateFloodplain
%   [Cat,1]  - Vh      = Volume of the floodplain Initial              [mm]
%

%% PARAMETERS 
% Normal Year
DayMothNormal   = [31 28 31 30 31 30 31 31 30 31 30 31];

% Leap-Year
DayMothBis      = [31 29 31 30 31 30 31 31 30 31 30 31];

% Factor mm -> m
Factor          = 1/1000;

% States Variables Floodplains Models
Ql              = zeros(length(Vh),1);
Rl              = zeros(length(Vh),1);

% [Vh] mm -> m3
Vh              = (Vh.*Factor).*FloodArea;

% [V_Umb] mm -> m3
V_Umb           = (V_Umb.*Factor).*FloodArea;

%% MODEL PARAMETERS
nTime       = length(Date);
nBasin      = length(BasinCode);
nBasinFlood = length(ArcIDFlood);
nDemand     = length(DemandSup(1,1,:));
nReturn     = length(Returns(1,1,:));

% streamflo Storage 
Qsim        = zeros(nTime,nBasin);

% Actual Evapotranspiration Storage
ETR         = zeros(nTime,nBasin);

% States Varibles Thomas Model 
StatesMT    = zeros(nTime,nBasin,6);

% States Varibles Floodplains Model 
StatesMF    = zeros(nTime,nBasinFlood,3);

% Floodplain value b -thomas
[~, posif]  = ismember(ArcIDFlood, BasinCode);
b_i         = b(posif);

% 2 = Streamflow + Basin Area
VAc         = zeros(nBasin,(2 + nDemand + nReturn), nTime);

for i = 1:nTime
   
    % Precipitation 
    P_i      = P(i,:)';
    
    % Evapotranspiration
    ETP_i    = ETP(i,:)';
    
    %% Thomas Model
    % Qsim [mm];  ETR [mm];  States [mm]
    [Qsim(i,:), ETR(i,:), StatesMT(i,:,:)] = Thomas(P_i, ETP_i, a, b, c, d, Sw, Sg);
    
    % Volumen Basin mm -> [m^3] 
    Vsim        = (Qsim(i,:)'.*Factor) .* (BasinArea);
    
    %% Demand
    % Total Superficial Demand [m^3]
    DemandSup_i = bsxfun(@times, reshape(DemandSup(i,:,:), nBasin, nDemand) , ParamExtSup);
    
    % Total Superficial Returns [m^3]
    Returns_i   = reshape(Returns(i,:,:), nBasin, nReturn);
    
    %% Model FloodPlains
    % Water avelable [mm]
    Y           = StatesMT(i,posif,3)';

     % Id Basin by Arcid Downstream
    PoPo        = zeros(length(BasinCode),1);
    
    % Id Basin with Floodplains
    PoPoFlood   = zeros(length(BasinCode),1);
    
    [VAcc, Vh_i,Ql_i,Rl_i, ~, PoPoFlood] =   Network(    BasinCode,...      % Code Basin - ArcID
                                                         Arc_InitNode,...   % From node
                                                         Arc_EndNode,...    % To Node
                                                         ArcID_Downstream,...
                                                         [Vsim BasinArea DemandSup_i Returns_i ],... % AccumVar
                                                         [Vsim BasinArea DemandSup_i Returns_i ],... % AccumVar
                                                         ArcIDFlood,... % Id Basin with Floodplains
                                                         FloodArea,...  % Area Floodplains
                                                         IDExtAgri,...  % id Extract Agricultural
                                                         IDExtDom,...   % id Extract Domestic
                                                         IDExtLiv,...   % id Extract Livestock
                                                         IDExtMin,...   % id Extract Mining
                                                         IDExtHy,...    % id Extract Hydrocarbons
                                                         IDRetDom,...   % id Returns Domestic
                                                         IDRetLiv,...   % id Returns Livestock
                                                         IDRetMin,...   % id Returns Mining
                                                         IDRetHy,...    % id Returns Hydrocarbons
                                                         P_i,...        % Precipitation
                                                         ETP_i,...      % Evapotranspiration
                                                         Vh,...         % Volume of the floodplain Initial
                                                         Ql,...
                                                         Rl,...
                                                         Trp,...        % Percentage lateral flow between river and floodplain   
                                                         Tpr,...        % Percentage return flow from floodplain to river
                                                         Q_Umb,...      % Threshold lateral flow between river and floodplain
                                                         V_Umb,...      % Threshold return flow from floodplain to river
                                                         b_i,...        % Maximum Capacity of Soil Storage
                                                         Y,...          % State Variable Thomas Model
                                                         PoPo,...       % ID Basin
                                                         PoPoFlood,...  % ID Basin - Floodplains
                                                         ArcID_Downstream);    


    [~, idPo]          = ismember(BasinCode(PoPoFlood == 1 ), ArcIDFlood);
    
    if ~isempty(idPo)
        idPo                = unique(idPo(idPo>0));
        StatesMF(i,idPo,:)  = [Vh_i(idPo), Ql_i(idPo), Rl_i(idPo)];
    end

    % streamflow m^3/seg;
    YearTmp = yeardays( Date(i) );
    if YearTmp == 365
        FactorQ = (DayMothNormal(month( Date(i) ))*24*3600);
    else 
        FactorQ = (DayMothBis(month( Date(i) ))*24*3600);
    end 
    
    % Streamflow m3 -> m3/seg
    VAc(:,:,i)   = VAcc(:,:);
    VAc(:,1,i)   = VAcc(:,1)/FactorQ;
    
    DemandSub_i  = bsxfun(@times, reshape(DemandSup(i,:,:), nBasin, nDemand) , 1 - ParamExtSup);
    
    % Subtract Demands Underground
    id = unique( IDAq );
    for j = 1:length(id)
        Tmp                 = find((IDAq  == id(j))) ;
        % Verificar las unidades del area que sean en [m^2]
        BasinAreaTmp        = BasinArea( Tmp );
        Rg                  = StatesMT(i,Tmp,5)';
        % Demand Underground
        VolDemSub           = nansum(DemandSub_i( Tmp  ));
        % Volumen Aquifer [m^3]
        Vol_Sub             = nansum((Rg / 1000) .* BasinAreaTmp)';
        % Distribution Basin
        Porc                = Rg /sum(Rg);
        % Update State Variable [mm]
        StatesMT(i,Tmp,5)   = ((( Vol_Sub - VolDemSub ) .* Porc)./BasinAreaTmp)*1000;
    end
    
    Sw  = reshape(StatesMT(i,:,1), nBasin, 1);
    Sg  = reshape(StatesMT(i,:,2), nBasin, 1);
    Vh  = Vh_i;
end
