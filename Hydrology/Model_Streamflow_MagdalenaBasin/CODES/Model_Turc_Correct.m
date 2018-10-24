% -------------------------------------------------------------------------
% /usr/bin/Matlab-R2016b
% -------------------------------------------------------------------------
% P-Q Model
% -------------------------------------------------------------------------
% BASE DATA 
% -------------------------------------------------------------------------
% Author            : Jonathan Nogales Pimentel - Jonathan.nogales@tnc.org
%                     Carlos Andres Rogéliz - carlos.rogeliz@tnc.org
% Company           : The Nature Conservancy - TNC
% 
% Please do not share without permision of the autor
% -------------------------------------------------------------------------
% Description 
% -------------------------------------------------------------------------
%
% -------------------------------------------------------------------------
% License
% -------------------------------------------------------------------------
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
% INPUTS DATA
% -------------------------------------------------------------------------
%  Network [Struct]
% -------------------------------------------------------------------------
% OUTPUTS DATA
% -------------------------------------------------------------------------
clear, clc

%% Add Functions 
addpath(genpath(fullfile('..','FUNCTIONS')))

%% Add Repository
PathRepository = '/media/nogales/NogalesBackup/TNC/TNC-Tools/Tools/Matlab';
addpath(genpath(PathRepository))

%% PARALLEL POOL ON CLUSTER
Network.parRuns            = 1; %true;
try
   myCluster                = parcluster('local');
   myCluster.NumWorkers     = 2;
   saveProfile(myCluster);
   parpool;
catch
end

%% LOAD DATA
% Gauges IDEAM
Tmp = xlsread(fullfile('..','DATA','Model_Streamflow_MagdalenaBasin.xlsx'),'GaugesModel_Final_2');

% Code Gauges 
Gauges.Code                 = Tmp(:,1);
% ArciD of the Gauges IDEAM
Gauges.ArcID                = Tmp(:,2);
% type Gauges 
Gauges.Type                 = Tmp(:,3);
% Streamflow measurement by Gauges 
Gauges.Qobs                 = Tmp(:,7);

% Information in topological network
Tmp = xlsread(fullfile('..','DATA','Model_Streamflow_MagdalenaBasin.xlsx'),'RawData');

% Mode
Network.Mode        = 0;
% AcrID
Network.ArcID       = Tmp(:,1);
% From Node 
Network.FromNode    = Tmp(:,2);
% To Node
Network.ToNode      = Tmp(:,3);
% Area (m2)
Network.Area        = Tmp(:,4)*(1000000);
% Precipitation (mm)
Network.PT          = Tmp(:,5);
% Elevation (msnm)
Network.Elev        = Tmp(:,8);

%% Calculate Temperature (°C)
% Regional equation
Network.T       = 28.3079 - (0.0056517*Network.Elev);

%% Calculate Evapotranspiration (mm)
Network.ETR     = zeros(length(Network.ArcID),1);
Network.L       = 300 + (25*Network.T) + (0.05*(Network.T.^3));

id              = ((Network.PT./Network.L) > 0.316);
Network.ETR(id) = (Network.PT(id))./sqrt( 0.9 + ((Network.PT(id).^2)./(Network.L(id).^2)) );
id              = ((Network.PT(id)./Network.L(id)) <= 0.316);
Network.ETR(id) = Network.PT(id);

%% Analysis Network
NumType         = unique(Gauges.Type);
Network.Factor  = Network.L*0;
Network.Factor1 = Network.L*0;
Network.PoNet   = Network.L*0;
PoNet           = Network.L*0;

Cont = 1;
for i = 1:length(NumType)
    
    Posi = find(Gauges.Type == NumType(i));
    
    for j = 1:length(Posi)
        
        Network.ArcID_RM        = Gauges.ArcID(Posi(j));
        Network.Qobs            = Gauges.Qobs(Posi(j));
        [PoNet_Tmp, PoNet_i]    = AnalysisNetwork( Network );
        Network.ID              = logical(PoNet_i);
        PoNet                   = PoNet + PoNet_Tmp;
        Network.PoNet           = PoNet_Tmp;
        
        % Select Parameters Range to calibrated
        Ra      = Network.PT(Network.ID)./Network.ETR(Network.ID);
        Rmin    = floor(min(Ra)*100)/100;
        
        % Opti
        [Params,bestf,allbest,allEvals] = sce('FunObj',[],[0.01, 0.001],[Rmin, 0.002],10, Network);   
        
        disp([num2str(Cont),' - [',num2str(i),'-',num2str(j),'] ->  ',num2str(bestf)])
        
        Network.Factor(PoNet == 1)      = Params(1);   
        Cont = Cont + 1;
    end
    
end

%% Asignation Parameters in ArcID not Calibrated
Network.Factor(PoNet == 0)  = 1;

%% Calculate Streamflow (m3/seg)
Network.ETRc    = Network.ETR .* Network.Factor;
Network.Qsim    = Network.Area.*(((Network.PT - Network.ETRc))./(1000*3600*24*365));

% Re      = Network.ETR./Network.PT;
% Alfa    = (1 + (Re.^(-Network.Factor))).^(-1./Network.Factor);
% % ETR Correct (mm) 
% % ETR     = UserData.ETR(UserData.ID).* UserData.Factor(UserData.ID);
% % Runoff (mm) 
% Esc     = Network.PT - ( Alfa .* Network.PT);
% % Streamflow (m3/seg)
% Network.Qsim  = ((Esc/1000).*Network.Area)/(3600*24*365);

%% Acumulated Streanflow (m3/seg)
Network.ArcID_RM        = 11;
Network.Mode            = 1;
Network.AccumVar(:,1)   = Network.Qsim;
[~,~,AccumVarOut]       = AnalysisNetwork( Network);
Network.QsimAccum       = AccumVarOut;

%% Selection of ArcID with Gauges
[id, posi]              = ismember(Gauges.ArcID, Network.ArcID);
Gauges.Qsim             = AccumVarOut(posi,1);

%% Nash
Nash = 1 - ( mean((Gauges.Qobs - Gauges.Qsim).^2) )./var(Gauges.Qobs);

%% Save Results
save(fullfile('..','RESULTS','Results_Correct.mat'),'Gauges','Network','PoNet','Nash')

%% Plotting
Fig     = figure('color',[1 1 1]);
T       = [12, 8];
set(Fig, 'Units', 'Inches', 'PaperPosition', [0, 0, T],'Position',...
[0, 0, T],'PaperUnits', 'Inches','PaperSize', T,'PaperType','e', 'Visible','off')

plot([0 max(Gauges.Qobs)], [0 max(Gauges.Qobs)],'--r','linewidth',1.3)
hold on, box on
scatter(Gauges.Qobs, Gauges.Qsim,25,'k','MarkerEdgeColor',[0 .5 .5],'MarkerFaceColor',[0 .7 .7],'LineWidth',1.5)

axis([min(Gauges.Qobs) max(Gauges.Qobs) min(Gauges.Qsim) max(Gauges.Qsim)])
xlabel('\bf Streanflow Obs ${(m^3)/Seg}$','Fontsize',24,'interpreter','latex')
ylabel('\bf Streanflow Sim ${(m^3)/Seg}$','Fontsize',24,'interpreter','latex')
title(['\bf [Nash = ',num2str(Nash,'%0.3f'),']'],'interpreter','latex')
set(gca,'XScale','log','YScale','log','fontsize',20,'TickLabelInterpreter','latex')

% save Figure
saveas(Fig, fullfile('..','FIGURES','Scatter-Plot-Calibration.png'))

%% clearvars 
delete(gcp('nocreate'))
clear

