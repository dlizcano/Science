% function UserDataCal = CalibrationModel(UserData)
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
% INPUT DATA
clearvars -except UserData

addpath(genpath(fullfile('..','FUNCTIONS')))


load('/media/nelsonobregon/93f6134e-6f19-47a5-bd1a-a4567bcdd61c/InfoNogales/ORINOQUIA/PRODUCTOS/4-MODELACION/PROJECT/OrinoquiaModel/Orinoquia_SNAPP.mat')


mkdir(fullfile(UserData.PathProject, 'FIGURES','MCAT','Dotty'))
mkdir(fullfile(UserData.PathProject, 'FIGURES','MCAT','sensitivity'))
mkdir(fullfile(UserData.PathProject, 'FIGURES','MCAT','GLUE'))

%Nombre de las funciones objetivo que se han calculado
Title_Cal   = 'Calibraci�n';
cstr        = str2mat( '1 - Nash', 'AME', 'PDIFF', 'MAE', 'MSE', 'RMSE', 'R4MS4E', 'RAE','PEP', 'MARE', 'MRE', 'MSRE', 'RVE', 'R', 'CE', 'PBE','AARE', 'TS1', 'TS25', 'TS50', 'TS100');

% -------------------------------------------------------------------------
% River Downstream
% -------------------------------------------------------------------------
try
    Tmp = xlsread( fullfile(UserData.PathProject,'DATA','Params',UserData.DataParams), 'Downstream');
catch
    errordlg(['The Excel "',UserData.DataParams,'" not found'],'!! Error !!')
    return
end

UserData.ArcID_Downstream   = Tmp;

% -------------------------------------------------------------------------
% Calibration Streamflow
% -------------------------------------------------------------------------
try
    Tmp = xlsread( fullfile(UserData.PathProject,'DATA','Params',UserData.DataParams), 'Control_Point');
catch
    errordlg(['The Excel "',UserData.DataParams,'" not found'],'!! Error !!')
    return
end

UserData.CodeGauges         = Tmp(:,1);
UserData.ArIDGauges         = Tmp(:,2);
UserData.CatGauges          = Tmp(:,3);

try
    P = dlmread(fullfile(UserData.PathProject,'RESULTS','P',['Pcp_Scenario-',num2str(1),'.dat']),',',1,1);
    Date   = P(:,1);
catch
    errordlg('The Precipitation Data Not Found','!! Error !!')
    return
end

clearvars P
NumberCat   = unique(UserData.CatGauges);

for i = 5%:length(NumberCat)
        
    id = find(UserData.CatGauges == NumberCat(i) );

    for j = 2%:length(id)

        UserData.DownGauges = UserData.ArIDGauges(id(j));

        load(fullfile(UserData.PathProject, 'RESULTS','Parameters_Model','Eval_MCAT',...
                        [num2str(UserData.CodeGauges(id(j))),'-',num2str(UserData.DownGauges),'_MCAT.mat']))
                    
        disp(['[i = ',num2str(i),' - j = ',num2str(j), ']  Gauges = ',num2str(UserData.ArIDGauges(id(j)))])
        disp('-------------------------------------------') 
        
        % Nash            
        Fuc(:,1) = 1 - Fuc(:,1);
        
        if CalMode == 1
            pstr        = str2mat('a', 'b', 'c', 'd', 'ExtSup'); 
        else
            pstr        = str2mat('a','b','c','d','QUmb', 'VUmb', 'Tpr', 'Trp', 'ExtSup');
        end
        
        JoJo = {'new','sensi', 'ouncert' };
        %mcat(VECTOR DE PARAMETROS,FUNCIONES OBJETIVO,[],SIMULACIONES,[],OBSERVADOS,id,pstr,cstr,[],[],[]);
        for ii = 1:3
%             try
                mcat(allEvals(:,1:end-1),Fuc,[],Q_sim,[],Q_Obs, Title_Cal,pstr,cstr,[],40001,Date, JoJo{ii});

%                 set(gcf,  'Visible','off')
%             catch
%             end
            
            if ii == 1
                saveas(gcf, fullfile(UserData.PathProject, 'FIGURES','MCAT','Dotty',...
                        [num2str(UserData.CodeGauges(id(j))),'-',num2str(UserData.DownGauges),'.jpg']))
            elseif ii == 2
                saveas(gcf, fullfile(UserData.PathProject, 'FIGURES','MCAT','sensitivity',...
                        [num2str(UserData.CodeGauges(id(j))),'-',num2str(UserData.DownGauges),'.jpg']))
            else 
                saveas(gcf, fullfile(UserData.PathProject, 'FIGURES','MCAT','GLUE',...
                        [num2str(UserData.CodeGauges(id(j))),'-',num2str(UserData.DownGauges),'.jpg']))
            end
            
                
            close all 
        end
        
        
    end
end
