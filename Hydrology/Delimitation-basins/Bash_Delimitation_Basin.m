% -------------------------------------------------------------------------
% /usr/bin/Matlab-R2017b
% -------------------------------------------------------------------------
% TIR-1
% -------------------------------------------------------------------------
% BASE DATA 
% -------------------------------------------------------------------------
% Author            : Jonathan Nogales Pimentel
% Email             : Jonathan.nogales@tnc.org
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
% UserData [Struct]
% -------------------------------------------------------------------------
% OUTPUTS DATA
% -------------------------------------------------------------------------

clear, clc 
close all
warning off

%% INPUT DATA
UserData.Master             = 'Master-Delimitation-Basin.xlsx';
UserData.Path_Project       = '/media/nogales/NogalesBackup/TNC/Project/HbD-Cornare/Delimitation-Basin';
UserData.Path_Repository    = '/media/nogales/NogalesBackup/TNC/Tools/Tools/Matlab';
UserData.Path_BaseDataSIG   = '/media/nogales/NogalesBackup/TNC/BaseDataSIG/Magdalena-Cauca-Basin';

%% Add Repository
addpath(genpath(UserData.Path_Repository))

%% LOAD MASTER
[Coor, Name] = xlsread( fullfile(UserData.Path_Project,'DATA',UserData.Master));
Name = Name(2:end,:);

%% LOAD DATA
load( fullfile(UserData.Path_BaseDataSIG, 'Matlab','DEM', 'DEM-90m.mat'))
load( fullfile(UserData.Path_BaseDataSIG, 'Matlab','FlowDir', 'FlowDir-90m.mat'))
% load( fullfile(UserData.Path_BaseDataSIG, 'Matlab','FlowAccum', 'FlowAccum-90m.mat'))
load( fullfile(UserData.Path_BaseDataSIG, 'Matlab','Stream', 'Stream-90m.mat'))

%%
[IX,~]  = coord2ind(DEM, Coor(:,1), Coor(:,2));
[IXc,~] = snap2stream(Stream,IX);

%% Delimitation Basin 
Basin   = drainagebasins(FlowDir, IXc);

%% Raster to Shapefile
ShpBasin = GRIDobj2polygon(Basin);

%% Save 
shapewrite(ShpBasin,fullfile(UserData.Path_Project, 'RESULTS','Basin.shp'))

