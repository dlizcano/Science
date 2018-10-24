function VariablesResults(Sce, VAc, Esc, P, ETP, ETR, StatesMT, StatesMF, UserData, varargin)
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

%% ADD VALUE TO SHAPEFILE HUA
if nargin > 9, Qref = varargin{1}; Inc_Index = 1; else, Inc_Index = 0; end
    
mkdir(fullfile(UserData.PathProject,'RESULTS','Models'))
mkdir(fullfile(UserData.PathProject,'RESULTS','Models',['Scenario-', num2str(Sce)]))


Months          = {'ENE','FEB','MAR','ABR','MAY','JUN','JUL','AGO','SEP','OCT','NOV','DEC','YEAR'};

%% Format file
CodeBasin       = UserData.ArcID;
Date            = UserData.Date;
%{
M               = month(Date);

NameBasin       = cell(1,length(CodeBasin) + 1);
NameBasin{1}    = 'Date_Matlab';
for k = 2:length(CodeBasin) + 1
    NameBasin{k} = ['Basin_',num2str(CodeBasin(k - 1))];
end

NameDate    = cell(1,length(Date));
for k = 1:length(Date)
    NameDate{k} = datestr(Date(k),'dd-mm-yyyy');
end

PosiVAc         = []; 
PosiSta         = []; 
NameVarAccum    = {}; 
Co              = 1;
ResultsMMM      = NaN(length(CodeBasin),1);
NameMMM         = {'Code'};


%% Streamflow
if UserData.Inc_R_Q         == 1
    Results = reshape(VAc(:,1,:), length(CodeBasin), length(Date));
    
    for i = 1:12
        ResultsMMM(:,Co) = nanmean(Results(:,M == i),2);
        NameMMM{Co+1} = ['Q_',Months{i}];
        Co = Co + 1; 
    end
    
    ResultsMMM(:,Co)    = nanmean(Results,2);
    NameMMM{Co+1}         = 'Q_Year';
    Co = Co + 1;
    
    Results = array2table([Date Results'],'VariableNames',NameBasin,'RowNames',NameDate);

    writetable(Results,...
        fullfile(UserData.PathProject,'RESULTS','Models',['Scenario-', num2str(Sce)],'Q.dat'), 'WriteRowNames',true) 
end 


%% Demand or Returns
Name    = {'Dm','R'};
Name1   = {'Agri_','Dom_','Liv_','Hy_','Mn_'};
Cu      = 3;
for j = 1:length(Name)
    for k = 1:length(Name1)
        
        if eval(['UserData.Inc_R_',Name1{k},Name{j}])   == 1
            Results = reshape(VAc(:,Cu,:), length(CodeBasin), length(Date));
            for i = 1:12
                ResultsMMM(:,Co)    = nanmean(Results(:,M == i),2);
                NameMMM{Co+1}       = [Name1{k},Name{j},'_',Months{i}];
                Co = Co + 1; 
            end

            ResultsMMM(:,Co)    = nansum(Results,2);
            NameMMM{Co+1}       = [Name1{k},Name{j},'_Year'];
            Co = Co + 1;
        end 
        Cu = Cu + 1;
    end
end

%% Runoff
if UserData.Inc_R_Esc      == 1    
    for i = 1:12
        ResultsMMM(:,Co) = nanmean(Esc(M == i,:)',2);
        NameMMM{Co+1} = ['Esc_',Months{i}];
        Co = Co + 1; 
    end
    
    ResultsMMM(:,Co)    = nansum(Esc',2);
    NameMMM{Co+1}         = 'Esc_Year';
    Co = Co + 1;
    
%     Results = array2table([Date [Results']],'VariableNames',NameBasin,'RowNames',NameDate);
% 
%     writetable(Results,...
%         fullfile(UserData.PathProject,'RESULTS','Models',['Scenario-', num2str(Sce)],'Esc.dat'), 'WriteRowNames',true) 
end

%%  Precipitation
if UserData.Inc_R_P        == 1
    for i = 1:12
        ResultsMMM(:,Co) = nanmean(P(M == i,:)',2);
        NameMMM{Co+1} = ['P_',Months{i}];
        Co = Co + 1; 
    end
    
    ResultsMMM(:,Co)    = nansum(P',2);
    NameMMM{Co+1}         = 'P_Year';
    Co = Co + 1;

end 

%% Potential Evapotranspiration
if UserData.Inc_R_ETP      == 1
    for i = 1:12
        ResultsMMM(:,Co) = nanmean(ETP(M == i,:)',2);
        NameMMM{Co+1} = ['ETP_',Months{i}];
        Co = Co + 1; 
    end
    
    ResultsMMM(:,Co)    = nansum(ETP',2);
    NameMMM{Co+1}         = 'ETP_Year';
    Co = Co + 1;
end 

%% Actual Evapotranspiration
if UserData.Inc_R_ETR      == 1 
    for i = 1:12
        ResultsMMM(:,Co) = nanmean(ETR(M == i,:)',2);
        NameMMM{Co+1} = ['ETR_',Months{i}];
        Co = Co + 1; 
    end
    
    ResultsMMM(:,Co)    = nansum(ETR',2);
    NameMMM{Co+1}         = 'ETR_Year';
    Co = Co + 1;
    
    Results = array2table([Date ETR],'VariableNames',NameBasin,'RowNames',NameDate);

    writetable(Results,...
        fullfile(UserData.PathProject,'RESULTS','Models',['Scenario-', num2str(Sce)],'ETR.dat'), 'WriteRowNames',true) 
end 

%% States Variables Thomas Model
Name = {'Sw','Sg','Y','Ro','Rg','Qg'};
for j = 1:length(Name)
    if eval(['UserData.Inc_R_',Name{j}]) == 1
        Results = StatesMT(:,:,j);

        for i = 1:12
            ResultsMMM(:,Co)    = nanmean(Results(M == i,:)',2);
            NameMMM{Co+1}       = [Name{j},'_',Months{i}];
            Co = Co + 1; 
        end

        ResultsMMM(:,Co)    = nansum(Results',2);
        NameMMM{Co+1}       = [Name{j},'_Year'];
        Co = Co + 1;

        Results = array2table([Date Results],'VariableNames',NameBasin,'RowNames',NameDate);

        writetable(Results,...
            fullfile(UserData.PathProject,'RESULTS','Models',['Scenario-', num2str(Sce)],[Name{j},'.dat']), 'WriteRowNames',true)
    end
end



%% States Variables Floodplains Model
[~, Po] = ismember(UserData.ArcIDFlood, CodeBasin);

Name = {'Vh','Ql','Rl'};
for j = 1:length(Name)
    if eval(['UserData.Inc_R_',Name{j}])       == 1
        Results = StatesMF(:,:,1);

        for i = 1:12
            ResultsMMM(Po,Co)   = nanmean(Results(M == i,:)',2);
            NameMMM{Co+1}       = [Name{j},'_',Months{i}];
            Co = Co + 1; 
        end

        ResultsMMM(Po,Co)       = nansum(Results',2);
        NameMMM{Co+1}           = [Name{j},'_Year'];
        Co = Co + 1;

        Tmp         = zeros(length(Date),length(CodeBasin));
        Tmp(:,Po)   = Results;
        Results     = array2table([Date Tmp],'VariableNames',NameBasin,'RowNames',NameDate);

        writetable(Results,...
            fullfile(UserData.PathProject,'RESULTS','Models',['Scenario-', num2str(Sce)],[Name{j},'.dat']), 'WriteRowNames',true)
    end
end



%% Save Summary
NameBasin       = cell(1,length(CodeBasin));
for k = 1:length(CodeBasin)
    NameBasin{k} = ['Basin_',num2str(CodeBasin(k))];
end

Results     = array2table([CodeBasin ResultsMMM],'VariableNames',NameMMM,'RowNames',NameBasin);

writetable(Results,...
    fullfile(UserData.PathProject,'RESULTS','Models',['Scenario-', num2str(Sce)],'Summary.dat'), 'WriteRowNames',true)

%}

NameBasin       = cell(1,length(CodeBasin));
for k = 1:length(CodeBasin)
    NameBasin{k} = ['Basin_',num2str(CodeBasin(k))];
end

if UserData.Inc_R_Index    == 1
    Results     = reshape(VAc(:,1,:), length(CodeBasin), length(Date))';

    Index       = Q95(Date, Results);
    NameCol     = {'ArcID', 'ENE','FEB','MAR','ABR','MAY','JUN','JUL','AGO','SEP','OCT','NOV','DEC','YEAR'};
    Results1    = array2table([CodeBasin Index],'VariableNames',NameCol,'RowNames',NameBasin);

    writetable(Results1,...
    fullfile(UserData.PathProject,'RESULTS','Models',['Scenario-', num2str(Sce)],'Q95.dat'), 'WriteRowNames',true)
end

% if UserData.Inc_R_Index    == 1
%     if Inc_Index == 1
%         mkdir( fullfile(UserData.PathProject,'FIGURES','Index') )
%         mkdir( fullfile(UserData.PathProject,'FIGURES','Index',['Scenario-', num2str(Sce)]) )
% 
%         Results = reshape(VAc(:,1,:), length(CodeBasin), length(Date))';
% 
%         Index    = IndexQ95(Qref,Results);
%         NameCol  = {'ArcID','Q5', 'Q10', 'Q25', 'Q75', 'Q99'};
%         Results1 = array2table([CodeBasin Index],'VariableNames',NameCol,'RowNames',NameBasin);
% 
%         writetable(Results1,...
%         fullfile(UserData.PathProject,'RESULTS','Models',['Scenario-', num2str(Sce)],'Index.dat'), 'WriteRowNames',true)
%     end
% end

%{
if UserData.Inc_R_TS       == 1
    mkdir( fullfile(UserData.PathProject,'FIGURES','TimeSeries') )
    mkdir( fullfile(UserData.PathProject,'FIGURES','TimeSeries',['Scenario-', num2str(Sce)]) )
    Results = reshape(VAc(:,1,:), length(CodeBasin), length(Date))';
    Data    = Results(:,UserData.Interest_Points_Code);
    TypeVar = 0;
    
    for i = 1:length(UserData.Interest_Points_Code)
        Num = num2str(UserData.Interest_Points_Code(i));
        Fig = PlotTimeSeries(Date, Data(:,Num), TypeVar);
        saveas(Fig, fullfile(UserData.PathProject,'FIGURES','TimeSeries',['Scenario-', num2str(Sce)],[Num,'.jpg']) )
        close(gcf)
    end
end

if UserData.Inc_R_Box      == 1
    mkdir( fullfile(UserData.PathProject,'FIGURES','Boxplots') )
    mkdir( fullfile(UserData.PathProject,'FIGURES','Boxplots',['Scenario-', num2str(Sce)]) )
    Results = reshape(VAc(:,1,:), length(CodeBasin), length(Date))';
    Data    = Results(:,UserData.Interest_Points_Code);
    TypeDate = 0;
    
    for i = 1:length(UserData.Interest_Points_Code)
        Num = num2str(UserData.Interest_Points_Code(i));
        Fig = PlotBoxplot(Date, Data(:,Num), TypeVar, TypeDate);
        saveas(Fig, fullfile(UserData.PathProject,'FIGURES','Boxplots',['Scenario-', num2str(Sce)],[Num,'.jpg']) )
        close(gcf)
    end
end

if UserData.Inc_R_Fur      == 1
    mkdir( fullfile(UserData.PathProject,'FIGURES','Periodogram') )
    mkdir( fullfile(UserData.PathProject,'FIGURES','Periodogram',['Scenario-', num2str(Sce)]) )
    Results = reshape(VAc(:,1,:), length(CodeBasin), length(Date))';
    Data    = Results(:,UserData.Interest_Points_Code);
    
    for i = 1:length(UserData.Interest_Points_Code)
        Num = num2str(UserData.Interest_Points_Code(i));
        Fig = PlotPeriodogram(Date, Data(:,Num));
        saveas(Fig, fullfile(UserData.PathProject,'FIGURES','Periodogram',['Scenario-', num2str(Sce)],[Num,'.jpg']) )
        close(gcf)
    end
    
end

if UserData.Inc_R_DC       == 1
    mkdir( fullfile(UserData.PathProject,'FIGURES','DurationCurve') )
    mkdir( fullfile(UserData.PathProject,'FIGURES','DurationCurve',['Scenario-', num2str(Sce)]) )
    Results = reshape(VAc(:,1,:), length(CodeBasin), length(Date))';
    Data    = Results(:,UserData.Interest_Points_Code);
    
    for i = 1:length(UserData.Interest_Points_Code)
        Num = num2str(UserData.Interest_Points_Code(i));
        Fig = PlotDurationCurve(Data(:,Num));
        saveas(Fig, fullfile(UserData.PathProject,'FIGURES','DurationCurve',['Scenario-', num2str(Sce)],[Num,'.jpg']) )
        close(gcf)
    end
    
end

if UserData.Inc_R_MMM      == 1
    mkdir( fullfile(UserData.PathProject,'FIGURES','Monthly_Multiyear_Averages') )
    mkdir( fullfile(UserData.PathProject,'FIGURES','Monthly_Multiyear_Averages',['Scenario-', num2str(Sce)]) )
    Results = reshape(VAc(:,1,:), length(CodeBasin), length(Date))';
    Data    = Results(:,UserData.Interest_Points_Code);
    TypeVar = 0;
    
    for i = 1:length(UserData.Interest_Points_Code)
        Num = num2str(UserData.Interest_Points_Code(i));
        Fig = PlotClimateMMM(Date, Data(:,Num), TypeVar);
        saveas(Fig, fullfile(UserData.PathProject,'FIGURES','Monthly_Multiyear_Averages',['Scenario-', num2str(Sce)],[Num,'.jpg']) )
        close(gcf)
    end
    
end
%}
