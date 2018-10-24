% -------------------------------------------------------------------------
% /usr/bin/Matlab-R2016b
% -------------------------------------------------------------------------
% TIR-1
% -------------------------------------------------------------------------
% BASE DATA 
% -------------------------------------------------------------------------
% Author            : Hector Angarita  
% Email             : flector@gmail.com
% Modified by       : Jonathan Nogales Pimentel - Jonathan.nogales@tnc.org
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

%% Add Repository
PathRepository = '/media/nogales/NogalesBackup/TNC/TNC-Tools/Tools/Matlab';
addpath(genpath(PathRepository))

%% LOAD DATA
% Gauges IDEAM
Tmp = xlsread(fullfile('..','DATA','Model_Streamflow_MagdalenaBasin.xlsx'),'GaugesModel');

% Code Gauges 
Gauges.Code                 = Tmp(:,1);
% ArciD of the Gauges IDEAM
Gauges.ArcID                = Tmp(:,2);
% Streamflow measurement by Gauges 
Gauges.Qobs                 = Tmp(:,6);

% Information in topological network
Tmp = xlsread(fullfile('..','DATA','Model_Streamflow_MagdalenaBasin.xlsx'),'RawData');

% River Mouth
Network.ArcID_RM           = 11;
% AcrID
Network.ArcID              = Tmp(:,1);
% From Node 
Network.FromNode           = Tmp(:,2);
% To Node
Network.ToNode             = Tmp(:,3);
% Area (Km2)
Network.AccumVar(:,1)      = Tmp(:,4);
% Precipitation (mm)
Network.AccumVar(:,2)      = Tmp(:,5);
% Drenage Length  (Km)
Network.AccumVar(:,3)      = Tmp(:,6);
% Drenage Order
Network.AccumVar(:,4)      = Tmp(:,7);

%% Analysis Network
[~,~,AccumVarOut] = AnalysisNetwork( Network);

% Acumulated Area in the branch
Network.AccumArea   = AccumVarOut(:,1);
% Acumulated Precipitation in the branch
Network.AccumPT     = AccumVarOut(:,2);
% Acumulated Area in the branch
Network.AccumLenDre = AccumVarOut(:,3);
% Acumulated Precipitation in the branch
Network.AccumOrDre  = AccumVarOut(:,4);
% Acumulated Runoff 
Network.AccumEsc    = (Network.AccumPT/1000).*(Network.AccumArea/(1000^2));

%% Acumulated Area and Precipitation in the Gauges 
[id, posi] = ismember(Gauges.ArcID, Network.ArcID);
% Acumulated Area in the gauges 
Gauges.AccumArea    = AccumVarOut(posi,1);
% Acumulated Precipitation in the gauges
Gauges.AccumPT      = AccumVarOut(posi,2);
% Acumulated length drenage in the gauges 
Gauges.AccumLenDre  = AccumVarOut(posi,3);
% Acumulated Dreange order in the gauges
Gauges.AccumOrDre   = AccumVarOut(posi,4);
% Acumulated Runoff 
Gauges.AccumEsc     = (Gauges.AccumPT/1000).*(Gauges.AccumArea/(1000^2));

%% Fitting Lineal Model [ y = a(x^b) ] ->> [ ln(y) = ln(a) + b*ln(x) ]
X           = [ones(length(Gauges.AccumEsc),1) log(Gauges.AccumEsc)];
Y           = log(Gauges.Qobs);
Param       = X\Y;
a           = Param(1);
b           = Param(2);
Gauges.Qsim = exp(a).*(Gauges.AccumEsc.^b);

%% Asignation 
Network.Qsim2  = exp(a).*(Network.AccumEsc.^b);

%% Fitting Lineal Model [ y = a(x^b) ] ->> [ ln(y) = ln(a) + b*ln(x) ]
X           = [ ones(length(Gauges.AccumEsc),1),...
                log(Gauges.AccumArea),...
                log(Gauges.AccumPT),...
                log(Gauges.AccumLenDre),...
                log(Gauges.AccumOrDre)];
            
Y           = log(Gauges.Qobs);
Param       = X\Y;

Gauges.Qsim2 = exp( X*Param );

%% Asignation 
X           = [ ones(length(Network.AccumEsc),1),...
                log(Network.AccumArea),...
                log(Network.AccumPT),...
                log(Network.AccumLenDre),...
                log(Network.AccumOrDre)];
            
Network.Qsim = exp( X*Param );

save(fullfile('..','RESULTS','Input.mat'),'Network','Gauges')

%% Filtro
Network.Q = Network.Qsim2 ;
Qcor_P = AnalysisNetwork_ModelQ(Network);
Network.Q = Network.Qsim ;
Qcor_ML = AnalysisNetwork_ModelQ(Network);


% R = [Network.ArcID Network.Qsim2 Network.Qsim Qcor];
%% Save Results
NameIndex   = {'ArcID','Area','PT','Length_Drenage','Order_Dreange','Q_Power', 'Q_MultiLineal', 'QCor_Power','Qcor_MultiLineal'};
ResultsQ    = array2table([ Network.ArcID,...
                            Network.AccumArea,...
                            Network.AccumPT,...
                            Network.AccumLenDre,...
                            Network.AccumOrDre,...
                            Network.Qsim2,...
                            Network.Qsim, Qcor_P, Qcor_ML],...
                            'VariableNames',NameIndex);

writetable(ResultsQ, fullfile('..','RESULTS',['Acumulated_Streamflow.csv']))

return
%% Plotting
Rsq2 = 1;
Fig     = figure('color',[1 1 1]);
T       = [12, 8];
set(Fig, 'Units', 'Inches', 'PaperPosition', [0, 0, T],'Position',...
[0, 0, T],'PaperUnits', 'Inches','PaperSize', T,'PaperType','e', 'Visible','on')

% plot(Gauges.AccumEsc, Gauges.Qsim2,'k','Linewidth',2')
scatter(Gauges.AccumEsc, Gauges.Qsim,15,'k','filled')
hold on
scatter(Gauges.AccumEsc, Gauges.Qobs,20,...
              'MarkerEdgeColor',[0 .5 .5],...
              'MarkerFaceColor',[0 .7 .7],...
              'LineWidth',1.5)
 

box on 
axis([min(Gauges.AccumEsc) max(Gauges.AccumEsc) min(Gauges.Qobs) max(Gauges.Qobs)])
xlabel('\bf Accumulated Runoff ${(m^3)}$ ','Fontsize',24,'interpreter','latex')
ylabel('\bf Streanflow  ${(m^3)/Seg}$','Fontsize',24,'interpreter','latex')
title(['\bf Lineal Model - [R2 = ',num2str(Rsq2,'%0.3f'),']'],'interpreter','latex')
set(gca,'XScale','log','YScale','log','fontsize',20,'TickLabelInterpreter','latex')





