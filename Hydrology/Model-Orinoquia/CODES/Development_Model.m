clear
clc

addpath(fullfile('..','ICONS'))
addpath(genpath(fullfile('..','FUNCTIONS')))
addpath(genpath(fullfile('..','DATA','ExcelFormat')))

% load('D:\TNC\Project\SNAPP-Orinoquia-CravoSur-Thomas\Orinoquia_SNAPP.mat')

UserData.CoresNumber = 1;

% return
% try
%     P = dlmread(fullfile(UserData.PathProject,'RESULTS','P',['Pcp_Scenario-',num2str(1),'.dat']),',',1,1);
%     DateP   = P(:,1);
%     P       = P(:,2:end);
% catch
%     errordlg('The Precipitation Data Not Found','!! Error !!')
%     return
% end