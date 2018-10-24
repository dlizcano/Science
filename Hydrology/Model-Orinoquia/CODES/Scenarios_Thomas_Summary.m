%% Scenario Thomas - Cravo Sur
clear
clc

load('D:\TNC\Project\Project-CravoSur-Thomas\Orinoquia_SNAPP.mat')

UserData.PathProject = 'D:\TNC\Project\Project-CravoSur-Thomas';

%% Loas HUA Cravo Sur 
CodeC = xlsread(fullfile(UserData.PathProject,'Cravo_Sur.xlsx'));

UserData.PathProject = 'D:\TNC\Project\Project-SNAPP-Orinoquia\PROJECT\OrinoquiaModel';

PorReturns  = [0.8, 0, 0, 0.5, 0];
DeRe        = {'Demand','Return'};

CodeBasin   = UserData.ArcID;
[id ,posi]  = ismember(CodeC, CodeBasin );

UserData.DataLivestock = UserData.DataLivestock(1:(end-1),:);
%% Total
% wi = 1;
% SummaryRaw = zeros(75, 5);
% SummarySce = zeros(75, 5);
% for ii = 1:length(UserData.DemandVar)
%     
%     Jo  = zeros(1,75);
%     Joo = zeros(1,75);
%     % Number Excel File by Demand - i
%     for Nexc = 1:length(eval(['UserData.Data',UserData.DemandVar{ii},'(:,2)']))
% 
%          % UserData.ArcID
%         Tmp         = dlmread(fullfile(UserData.PathProject,'RESULTS','Demand', UserData.DemandVar{ii},'Scenario-1',DeRe{wi},[eval(['UserData.Data',UserData.DemandVar{ii},'{Nexc,1}']),'.dat']),',',1,1);
%         Date        = Tmp(:,1);
%         Values      = Tmp(:,2:end);
% 
% 
%         Tmp         = Values(:, posi);
%         Tmp1        = Tmp;
%         
%         Jo1         = mean(Tmp1);
%         Jo          = Jo + Jo1;
%         
%         for i = 1:length(Tmp(1,:))
%             a   = reshape(Tmp(:,i),12,[]);
%             Res = zeros(size(a));
%             for j = 1:12
%                 a1          = mean(abs(diff(a(j,:))));
%                 Res(j,:)    = linspace( (a(j,end) + a1),(a(j,end) + a1)*29, 29); 
%             end
%             Tmp1(:,i) = reshape(Res,1,[]);
% 
%         end
%         
%         subplot(1,2,1), plot(Tmp), subplot(1,2,2), plot(Tmp1)
%         title(eval(['UserData.Data',UserData.DemandVar{ii},'{Nexc,1}']))
%         pause 
%         
%         Joo1         = mean(Tmp1);
%         Joo          = Joo + Joo1;
% 
% 
%     end
%     SummaryRaw(:,ii) = Jo'; 
%     SummarySce(:,ii) = Joo'; 
% end
%             
 
% %% LOAD DEMAND DATA  
% % TOTAL DEMAND 
% Scenario = 3;
% DeRe = {'Demand','Return'};
% for Sce = 1:length(Scenario)
%     for dr = 1:2
%         for i = 1:length(UserData.DemandVar)
%             
%             try
%                 Tmp     = dlmread(fullfile(UserData.PathProject,'RESULTS','Demand',UserData.DemandVar{i},['Scenario-',num2str(Scenario(Sce))],['Total_',DeRe{dr},'.dat']),',',1,1);
%                 Tmp(isnan(Tmp)) = 0;
%                 eval([DeRe{dr},'(:,:,',num2str(i),') = Tmp(:,2:end);']);
%             catch
%                 eval([DeRe{dr},'(:,:,',num2str(i),') = Tmp(:,2:end)*0;']);
%             end
%         end
%     end
% end
% DateD = Tmp(:,1);
% 
% Demand(isnan(Demand))       = 0;
% Return(isnan(Return))       = 0;
%     
% Demand_Sce1 = sum(sum(Demand(:, posi,:),3),2);
% Demand_Sce2 = sum(sum(Demand(:, posi,:),3),2);
% Demand_Sce3 = sum(sum(Demand(:, posi,:),3),2);
% 

%% LOAD CLIMATE DATA
% -------------------------------------------------------------------------
% Precipitation 
% -------------------------------------------------------------------------
% P       = dlmread(fullfile(UserData.PathProject,'RESULTS','P','Pcp_Scenario-1.dat'),',',1,1);
% Date    = P(:,1);
% P       = P(:,2:end);
% 
% Values  = P*0.9;
% Values(Values < 0) = 0;

% Results = [Date Values];
% Results = array2table(Results,'VariableNames',NameBasin,'RowNames',NameDate);
% writetable(Results, fullfile(UserData.PathProject,'RESULTS','P','Pcp_Scenario-3.dat'), 'WriteRowNames',true)                

% -------------------------------------------------------------------------
% Evapotranspiration
% -------------------------------------------------------------------------
ETP     = dlmread(fullfile(UserData.PathProject,'RESULTS','ETP','ETP_Scenario-1.dat'),',',1,1);
DateET  = ETP(:,1);
ETP     = ETP(:,2:end);

Values  = ETP*1.1;

o = mean(Values);
oo = o(posi)';

Tv = NaN(length(oo),1);

for i= 1:length(oo)
    T = 5;
    Error = 10000;
    while Error > 1
        I           = 12*((T/5).^1.514);
        a           = ((675E-9).*(I.^3)) - ((771E-7).*(I.^2)) + ((179.2E-4).*I) + 0.49239;
        ETP         = 16*(((10*T)./I).^a);
        
        Error = abs(ETP - oo(i));
        T = T + 0.01;
    end
    Tv(i) = T; 
end



% Results = [Date Values];
% Results = array2table(Results,'VariableNames',NameBasin,'RowNames',NameDate);
% writetable(Results, fullfile(UserData.PathProject,'RESULTS','ETP','ETP_Scenario-3.dat'), 'WriteRowNames',true) 
