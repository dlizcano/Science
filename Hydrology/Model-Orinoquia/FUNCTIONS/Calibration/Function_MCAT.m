function [sim, Fuc]   = Function_MCAT(Param, UserData)
%/usr/bin/Matlab-R2016b
% -------------------------------------------------------------------------
% Summary MCAT
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
% -------------------------------------------------------------------------
% INPUT DATA
% -------------------------------------------------------------------------
% Param         [1, 9]      = Parameters of the Models
% UserData      [Struct]
%   .CalMode        [1 or 9]        = 1 for the Thomas Model Parameters 
%                                     0 for the Floodplains Model Parameters
%   .Date           [t,1]           = Date                                                                      [Datenum]
%   .ArcID          [Cat,1]         = ArcID                                                                     [Ad]
%   .BasinArea      [Cat,1]         = Basin Area                                                                [m^2]
%   .P              [t,Cat]         = Precipitation                                                             [mm]
%   .ET             [t,Cat]         = Potential Evapotranspiration                                              [mm]
%   .DemandSup      [t,Cat]         = Demand                                                                    [m^3]
%   .Returns        [t,Cat]         = Returns                                                                   [m^3]
%   .IDExtAgri      [Cat,1]         = ID of the HUA where to extraction Agricultural Demand                     [Ad]
%   .IDExtDom       [Cat,1]         = ID of the HUA where to extraction Domestic Demand                         [Ad]
%   .IDExtLiv       [Cat,1]         = ID of the HUA where to extraction Livestock Demand                        [Ad]
%   .IDExtMin       [Cat,1]         = ID of the HUA where to extraction Mining Demand                           [Ad]
%   .IDExtHy        [Cat,1]         = ID of the HUA where to extraction Hydrocarbons Demand                     [Ad]
%   .IDRetDom       [Cat,1]         = ID of the HUA where to return Domestic Demand                             [Ad]
%   .IDRetLiv       [Cat,1]         = ID of the HUA where to return Livestock Demand                            [Ad]
%   .IDRetMin       [Cat,1]         = ID of the HUA where to return Mining Demand                               [Ad]
%   .IDRetHy        [Cat,1]         = ID of the HUA where to return Hydrocarbons Demand                         [Ad]
%   .FloodArea      [t,Cat]         = Floodplain Area                                                           [m^2]
%   .Arc_InitNode   [t,Cat]         = Initial node of each section of the network                               [Ad]
%   .Arc_EndNode    [t,Cat]         = End node of each section of the network                                   [Ad] 
%   .DownGauges     [t,Cat]         = ID of the end node of accumulation                                        [Ad]
%   .PoPo           [n,1]           = ID of the HUA to calibrate                                                [Ad]
%   .PoPoFlood      [n,1]           = ID of the HUA to calibrate with floodplains                               [Ad]
%   .IDPoPo         [n,1]           = ID of the HUA where signate the model parameters to calibrate             [Ad]
%   .IDPoPoFlood    [n,1]           = ID of the HUA where signate the model parameters to calibrate floodplains [Ad]
%   .a              [Cat,1]         = Soil Retention Capacity                                                   [Ad]
%   .b              [Cat,1]         = Maximum Capacity of Soil Storage                                          [Ad]
%   .c              [Cat,1]         = Flow Fraction Soil - Aquifer                                              [Ad]
%   .d              [Cat,1]         = Flow Fraction Aquifer - Soil                                              [Ad]
%   .Trp            [CatFlood,1]    = Percentage lateral flow between river and floodplain                      [Ad]
%   .Tpr            [CatFlood,1]    = Percentage return flow from floodplain to river                           [Ad]
%   .Q_Umb          [CatFlood,1]    = Threshold lateral flow between river and floodplain                       [mm]
%   .V_Umb          [CatFlood,1]    = Threshold return flow from floodplain to river                            [mm]
%   .ParamExtSup    [t,Cat]         = Porcentage of Superficial Water Extraction                                [Ad]
%   .ArcIDFlood     [CatFlood,1]    = ID basins with floodplain                                                 [Ad]
%   .Sg             [Cat,1]         = Aquifer Storage                                                           [mm]
%   .Sw             [Cat,1]         = Soil Moinsture                                                            [mm]
%   .Vh             [Cat,1]         = Volume of the floodplain Initial                                          [mm]
%
% -------------------------------------------------------------------------
% OUTPUT DATA
% -------------------------------------------------------------------------
%   sim            [Obj Matlab]     = streamflow Simulated
%   SummaryCal     [1, 21]          = Summary of the Functions Target

%%
IDPoPo              = UserData.IDPoPo;
IDPoPoFlood         = UserData.IDPoPoFlood;

PoPo                = UserData.PoPo;
PoPoFlood           = UserData.PoPoFlood;

UserData.a(IDPoPo)  = Param(1);
UserData.b(IDPoPo)  = Param(2);
UserData.c(IDPoPo)  = Param(3);
UserData.d(IDPoPo)  = Param(4);

if UserData.CalMode == 1
    UserData.ParamExtSup(IDPoPo)    = Param(5);
else
    UserData.ParamExtSup(IDPoPo)    = Param(9);
    
    UserData.Q_Umb(IDPoPoFlood)     = Param(5);
    UserData.V_Umb(IDPoPoFlood)     = Param(6);
    UserData.Tpr(IDPoPoFlood)       = Param(7);
    UserData.Trp(IDPoPoFlood)       = Param(8);
end

[Qsim,~,~] = HMO_Calibration(   UserData.Date,...
                                UserData.P(:,PoPo),...
                                UserData.ET(:,PoPo),...
                                UserData.DemandSup(:,PoPo,:),...
                                UserData.Returns(:,PoPo,:),...
                                UserData.BasinArea(PoPo),...
                                UserData.FloodArea(PoPoFlood),... 
                                UserData.BasinCode(PoPo),...
                                UserData.Arc_InitNode(PoPo),...
                                UserData.Arc_EndNode(PoPo),...
                                UserData.DownGauges,...
                                UserData.a(PoPo),...
                                UserData.b(PoPo),...
                                UserData.c(PoPo),...
                                UserData.d(PoPo),...
                                UserData.Tpr(PoPoFlood),...
                                UserData.Trp(PoPoFlood),...
                                UserData.Q_Umb(PoPoFlood),...
                                UserData.V_Umb(PoPoFlood),...
                                UserData.IDExtAgri,...
                                UserData.IDExtDom,...
                                UserData.IDExtLiv,...
                                UserData.IDExtMin,...
                                UserData.IDExtHy,... 
                                UserData.IDRetDom,...
                                UserData.IDRetLiv,...
                                UserData.IDRetMin,...
                                UserData.IDRetHy,...
                                UserData.ArcIDFlood(PoPoFlood),...
                                UserData.ParamExtSup(PoPo),...
                                UserData.Sw(PoPo),...
                                UserData.Sg(PoPo),...
                                UserData.Vh(PoPoFlood));

BasinCode   = UserData.BasinCode(PoPo);
QArcID      = (BasinCode == UserData.DownGauges);
sim  = reshape(Qsim(QArcID,1,:),[],1);
obs  = UserData.Qobs;
sim(sim<0) = 0.1;

Fuc = NaN(21,1);

%% Nash-Sutcliffe Coefficient of Efficiency
Fuc(1)      = 1 - ((nanmean((obs-sim).^2))./var(obs(isnan(obs) == 0)));

%% Absolute Mean error 
Fuc(2)      = max(abs(obs-sim));
    
%% unlike peaks 
Fuc(3)      = max(obs)-max(sim);

%% Mean Absolute Error 
Fuc(4)      = nanmean(abs(obs-sim));

%% Mean Square Error 
Fuc(5)      = nanmean((obs-sim).^2);

%% Mean Error
Fuc_ME(6)   = nanmean(obs-sim);

%% Root Mean Square Error
Fuc(7)      = sqrt(Fuc(5));

%% Root Fourth Mean Square Fourth Error
Fuc(8)      = nthroot((nanmean((obs-sim).^4)),4);

%% Root Absolute Error 
Fuc(9)      = nansum(abs(obs-sim))/nansum(abs(obs-nanmean(obs)));

%% percent Error in peak 
Fuc(10)     = ((max(obs)-max(sim))/max(obs))*100;

%% Mean Absolute Relative Error
Fuc(11)     = nanmean(nansum((abs(obs-sim))/obs));

%% Mean Relative Error 
Fuc(12)     = nanmean(nansum((obs-sim)/obs));

%% Mean Square Relative Error 
Fuc(13)     = nanmean(nansum(((obs-sim)/obs).^2));

%% Relative Volume Error
Fuc(14)     = nansum(obs-sim)/nansum(obs);

%% Correlation Coefficient
Rnum        = nansum((obs-nanmean(obs)).*(sim-nanmean(sim)));
Rdenom      = sqrt(nansum((obs-nanmean(obs)).^2)*nansum((sim-nanmean(sim)).^2));
Fuc(15)     = Rnum/Rdenom;

%% Percentage Bias Error
Fuc(16)     = nansum(sim-obs)/nansum(obs)*100;

%% Average Absolute Relative Error
Fuc_ARE     = abs(((sim-obs)./obs)*100);
Fuc_ARE(isnan(Fuc_ARE)) = 0; Fuc_ARE(isinf(Fuc_ARE)) = 0;
Fuc(17)     = nanmean(Fuc_ARE);

%% Threshold Statistics
for l = 1:size(obs,1)
       if Fuc_ARE(l)<1;   p(l) = 1; else p(l) = 0; end
       if Fuc_ARE(l)<25;  q(l) = 1; else q(l) = 0; end
       if Fuc_ARE(l)<50;  r(l) = 1; else r(l) = 0; end
       if Fuc_ARE(l)<100; s(l) = 1; else s(l) = 0; end      
end

Fuc(18)  = nanmean(p)*100;
Fuc(19)  = nanmean(q)*100;
Fuc(20)  = nanmean(r)*100;
Fuc(21)  = nanmean(s)*100;