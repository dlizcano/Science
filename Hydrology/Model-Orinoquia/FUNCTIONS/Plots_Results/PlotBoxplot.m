function Fig = PlotBoxplot(Date, Data, TypeVar, TypeDate)
% /usr/bin/Matlab-R2016b
% -------------------------------------------------------------------------
% 
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

if nargin < 4, error('No Data'), end

switch TypeVar
    case 0 % Streamflow
        NameLabel   = '\bf Streamflow \bf{${(m^3/Seg)}$}';
        
    case 1 % Precipitation
        NameLabel   = '\bf Precipitation (mm)';
        
    case 2 % Temperature 
        NameLabel   = '\bf Temperature (C)';
        
    case 3 % Potential Evapotranspiration
        NameLabel   = '\bf Potential Evapotranspiration (mm)';
        
    case 4 % Actual Evapotransoiration
        NameLabel   = '\bf Actual Evapotranspiration (mm)';
        
    case 5 % Sunshine
        NameLabel   = '\bf Sunshine (hr)';
        
    case 6 % Relative Humidity
        NameLabel   = '\bf Relative Humidity (Porc)';
end

%% Plot 
Fig     = figure('color',[1 1 1]);
T       = [25, 12];
set(Fig, 'Units', 'Inches', 'PaperPosition', [0, 0, T],'Position',...
[0, 0, T],'PaperUnits', 'Inches','PaperSize', T,'PaperType','e', 'Visible','off')

%% Precipitation
Y = unique(year(Date));
if TypeDate == 0
    DataTmp = NaN(length(Y),12);
else
    DataTmp = NaN(length(Y)*31,12);
end

M = month(Date);
for i = 1:12
    Tmp = Data(M == i);
    DataTmp(1:length(Tmp),i) = Tmp; 
end

NameMonth = {'\bf ENE','\bf FEB','\bf MAR','\bf ABR','\bf MAY','\bf JUN','\bf JUL','\bf AGO','\bf SEP','\bf OCT','\bf NOV','\bf DIC'};

Ax1 = subplot(1,20,1:17);
boxplot(DataTmp, 'Notch','on','Labels',NameMonth,'Whisker',1)
xlabel('\bf Months','interpreter','latex','FontSize',30, 'FontWeight','bold');
ylabel(NameLabel,'interpreter','latex','FontSize',30, 'FontWeight','bold');
set(Ax1, 'TickLabelInterpreter','latex','FontSize',28, 'FontWeight','bold')

Ax2 = subplot(1,20,18:20);
boxplot(Data, 'Notch','on','Labels','\bf YEAR','Whisker',1)
set(Ax2, 'TickLabelInterpreter','latex','FontSize',28, 'FontWeight','bold')
