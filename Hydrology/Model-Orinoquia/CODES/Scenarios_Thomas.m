%% Scenario Thomas - Cravo Sur
clear
clc
close all 

load('D:\TNC\Project\Project-CravoSur-Thomas\Orinoquia_SNAPP.mat')

UserData.PathProject = 'D:\TNC\Project\Project-CravoSur-Thomas';

%% Loas HUA Cravo Sur 
CodeC = xlsread(fullfile(UserData.PathProject,'Cravo_Sur.xlsx'));

PorReturns = [0.8, 0, 0, 0.5, 0];
DeRe = {'Demand','Return'};

CodeBasin   = UserData.ArcID;
[id ,posi]  = ismember(CodeC, CodeBasin );

UserData.DataLivestock = UserData.DataLivestock(1:(end-1),:);
%% Population
for wi = 1:2
    for ii = 1:length(UserData.DemandVar)

        % Number Excel File by Demand - i
        for Nexc = 1:length(eval(['UserData.Data',UserData.DemandVar{ii},'(:,2)']))

            for NSce = 2

                % UserData.ArcID
                Tmp         = dlmread(fullfile(UserData.PathProject,'RESULTS','Demand', UserData.DemandVar{ii},'Scenario-1',DeRe{wi},[eval(['UserData.Data',UserData.DemandVar{ii},'{Nexc,1}']),'.dat']),',',1,1);
                Date        = Tmp(:,1);
                Values      = Tmp(:,2:end);

                
                Tmp         = Values(:, posi);
                Tmp1        = Tmp;

                for i = 1:length(Tmp(1,:))
                    a   = reshape(Tmp(:,i),12,[]);
                    Res = zeros(size(a));
                    for j = 1:12
                        a1          = mean(abs(diff(a(j,:))));
                        Res(j,:)    = linspace( (a(j,end) + a1),(a(j,end) + a1)*29, 29); 
                    end
                    Tmp1(:,i) = reshape(Res,1,[]);

                end
                
                subplot(1,2,1), plot(Tmp), subplot(1,2,2), plot(Tmp1)
                title(eval(['UserData.Data',UserData.DemandVar{ii},'{Nexc,1}']))
                pause
              
                
                Values(:,posi) = Tmp1;

                % Save Data
                NameBasin    = cell(1,length(CodeBasin) + 1);
                NameBasin{1} = 'Date_Matlab';   
                
                for k = 2:length(CodeBasin) + 1
                    NameBasin{k} = ['Basin_',num2str(CodeBasin(k - 1))];
                end

                NameDate    = cell(1,length(Date));
                for k = 1:length(Date)
                    NameDate{k} = datestr(Date(k),'dd-mm-yyyy');
                end

                Results = [Date Values];
                Results = array2table(Results,'VariableNames',NameBasin,'RowNames',NameDate);

                writetable(Results,...
                    fullfile(UserData.PathProject,'RESULTS','Demand', UserData.DemandVar{ii},['Scenario-',num2str(2)],DeRe{wi},[eval(['UserData.Data',UserData.DemandVar{ii},'{Nexc,1}']),'.dat']),...
                    'WriteRowNames',true)
                
                writetable(Results,...
                    fullfile(UserData.PathProject,'RESULTS','Demand', UserData.DemandVar{ii},['Scenario-',num2str(3)],DeRe{wi},[eval(['UserData.Data',UserData.DemandVar{ii},'{Nexc,1}']),'.dat']),...
                    'WriteRowNames',true)


            end
        end
    end
end              

%% LOAD DEMAND DATA  
% TOTAL DEMAND 
Scenario = 3;
DeRe = {'Demand','Return'};
for Sce = 1:length(Scenario)
    for dr = 1:2
        for i = 1:length(UserData.DemandVar)
            
            try
                Tmp     = dlmread(fullfile(UserData.PathProject,'RESULTS','Demand',UserData.DemandVar{i},['Scenario-',num2str(Scenario(Sce))],['Total_',DeRe{dr},'.dat']),',',1,1);
                Tmp(isnan(Tmp)) = 0;
                eval([DeRe{dr},'(:,:,',num2str(i),') = Tmp(:,2:end);']);
            catch
                eval([DeRe{dr},'(:,:,',num2str(i),') = Tmp(:,2:end)*0;']);
            end
        end
    end
end
DateD = Tmp(:,1);

Demand(isnan(Demand))       = 0;
Return(isnan(Return))       = 0;
    
Demand_Sce1 = sum(sum(Demand(:, posi,:),3),2);
Demand_Sce2 = sum(sum(Demand(:, posi,:),3),2);
Demand_Sce3 = sum(sum(Demand(:, posi,:),3),2);

%% LOAD CLIMATE DATA
% -------------------------------------------------------------------------
% Precipitation 
% -------------------------------------------------------------------------
P       = dlmread(fullfile(UserData.PathProject,'RESULTS','P','Pcp_Scenario-1.dat'),',',1,1);
Date    = P(:,1);
P       = P(:,2:end);

Values  = P*0.9;
Values(Values < 0) = 0;

Results = [Date Values];
Results = array2table(Results,'VariableNames',NameBasin,'RowNames',NameDate);
writetable(Results, fullfile(UserData.PathProject,'RESULTS','P','Pcp_Scenario-3.dat'), 'WriteRowNames',true)                

% -------------------------------------------------------------------------
% Evapotranspiration
% -------------------------------------------------------------------------
ETP     = dlmread(fullfile(UserData.PathProject,'RESULTS','ETP','ETP_Scenario-1.dat'),',',1,1);
DateET  = ETP(:,1);
ETP     = ETP(:,2:end);

Values  = ETP*1.1;

Results = [Date Values];
Results = array2table(Results,'VariableNames',NameBasin,'RowNames',NameDate);
writetable(Results, fullfile(UserData.PathProject,'RESULTS','ETP','ETP_Scenario-3.dat'), 'WriteRowNames',true) 
