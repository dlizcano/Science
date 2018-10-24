function varargout = Model(varargin)
% MODEL MATLAB code for Model.fig
%      MODEL, by itself, creates a new MODEL or raises the existing
%      singleton*.
%
%      H = MODEL returns the handle to a new MODEL or the handle to
%      the existing singleton*.
%
%      MODEL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MODEL.M with the given input arguments.
%
%      MODEL('Property','Value',...) creates a new MODEL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Model_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Model_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Model

% Last Modified by GUIDE v2.5 24-Oct-2018 09:48:58

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Model_OpeningFcn, ...
                   'gui_OutputFcn',  @Model_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before Model is made visible.
function Model_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Model (see VARARGIN)

% Choose default command line output for Model
handles.output = hObject;

%% Color white Figure 
set(handles.figure1,'Color',[1 1 1])

%% Logos 
% Logo de TNC
axes(handles.Icons_TNC)
Logo = imread('Logo_TNC.png');
image(Logo);
axis off
 
% Logo de SNAPP
axes(handles.Icons_SNAPP)
Logo = imread('Logo_SNAPP.jpg');
image(Logo);
axis off

% Logo Model
axes(handles.Icons_Models)
Logo = imread('Model.png');
image(Logo);
axis off

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Model wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = Model_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


%% New Project
% --------------------------------------------------------------------
function FlashNew_ClickedCallback(hObject, eventdata, handles)

global UserData
UserData    = struct;
Tmp         = uigetdir;

if Tmp ~= 0 
    UserData.PathProject    = Tmp;
    
    %% Create Folders 
    mkdir(fullfile(UserData.PathProject,'FIGURES'))
    mkdir(fullfile(UserData.PathProject,'PARAMETERS'))
    mkdir(fullfile(UserData.PathProject,'RESULTS'))
    mkdir(fullfile(UserData.PathProject,'DATA'))
    mkdir(fullfile(UserData.PathProject,'DATA','ExcelFormat'))
    mkdir(fullfile(UserData.PathProject,'DATA','Climate'))
    mkdir(fullfile(UserData.PathProject,'DATA','Climate','Precipitation'))
    mkdir(fullfile(UserData.PathProject,'DATA','Climate','Temperature'))
    mkdir(fullfile(UserData.PathProject,'DATA','Climate','Evapotranspiration'))
    mkdir(fullfile(UserData.PathProject,'DATA','Hydrological'))
    mkdir(fullfile(UserData.PathProject,'DATA','Params'))
    mkdir(fullfile(UserData.PathProject,'DATA','Demand'))
    mkdir(fullfile(UserData.PathProject,'DATA','Demand','Mining-Demand'))
    mkdir(fullfile(UserData.PathProject,'DATA','Demand','Mining-Demand','Value'))
    mkdir(fullfile(UserData.PathProject,'DATA','Demand','Mining-Demand','Module'))
    mkdir(fullfile(UserData.PathProject,'DATA','Demand','Livestock-Demand'))
    mkdir(fullfile(UserData.PathProject,'DATA','Demand','Livestock-Demand','Value'))
    mkdir(fullfile(UserData.PathProject,'DATA','Demand','Livestock-Demand','Module'))
    mkdir(fullfile(UserData.PathProject,'DATA','Demand','Hydrocarbons-Demand'))
    mkdir(fullfile(UserData.PathProject,'DATA','Demand','Hydrocarbons-Demand','Value'))
    mkdir(fullfile(UserData.PathProject,'DATA','Demand','Hydrocarbons-Demand','Module'))
    mkdir(fullfile(UserData.PathProject,'DATA','Demand','Domestic-Demand'))
    mkdir(fullfile(UserData.PathProject,'DATA','Demand','Domestic-Demand','Value'))
    mkdir(fullfile(UserData.PathProject,'DATA','Demand','Domestic-Demand','Module'))
    mkdir(fullfile(UserData.PathProject,'DATA','Demand','Agricultural-Demand'))
    mkdir(fullfile(UserData.PathProject,'DATA','Demand','Agricultural-Demand','Value'))
    mkdir(fullfile(UserData.PathProject,'DATA','Demand','Agricultural-Demand','Module'))
    mkdir(fullfile(UserData.PathProject,'DATA','Geografic'))
    mkdir(fullfile(UserData.PathProject,'DATA','Geografic','DEM'))
    mkdir(fullfile(UserData.PathProject,'DATA','Geografic','HUA'))
    mkdir(fullfile(UserData.PathProject,'DATA','Geografic','Network'))
    mkdir(fullfile(UserData.PathProject,'DATA','Geografic','SU'))
    mkdir(fullfile(UserData.PathProject,'DATA','Geografic','SUD'))
    mkdir(fullfile(UserData.PathProject,'DATA','Geografic','Other'))    
    
%     %% Copy Excel Format 
%     try
%         copyfile('Format-Climate.xlsx', fullfile(UserData.PathProject,'DATA','ExcelFormat','Format-Climate.xlsx'))
%         copyfile('Format-Demand.xlsx', fullfile(UserData.PathProject,'DATA','ExcelFormat','Format-Demand.xlsx'))
%         copyfile('Format-Hydrological.xlsx', fullfile(UserData.PathProject,'DATA','ExcelFormat','Format-Hydrological.xlsx'))
%         copyfile('Format-Parameters.xlsx', fullfile(UserData.PathProject,'DATA','ExcelFormat','Format-Parameters.xlsx'))
%     catch
%         copyfile(fullfile('..','..','DATA','ExcelFormat','Format-Climate.xlsx'), fullfile(UserData.PathProject,'DATA','ExcelFormat','Format-Climate.xlsx'))
%         copyfile(fullfile('..','..','DATA','ExcelFormat','Format-Demand.xlsx'), fullfile(UserData.PathProject,'DATA','ExcelFormat','Format-Demand.xlsx'))
%         copyfile(fullfile('..','..','DATA','ExcelFormat','Format-Hydrological.xlsx'), fullfile(UserData.PathProject,'DATA','ExcelFormat','Format-Hydrological.xlsx'))
%         copyfile(fullfile('..','..','DATA','ExcelFormat','Format-Parameters.xlsx'), fullfile(UserData.PathProject,'DATA','ExcelFormat','Format-Parameters.xlsx'))
%     end
   
    UserData                = ConfigPath(UserData);
end

%% OPEN PROJECT
% --------------------------------------------------------------------
function FlashOpen_ClickedCallback(hObject, eventdata, handles)

global UserData
[FileName,PathName] = uigetfile('*.mat');
if PathName ~= 0
    Tmp                  = load(fullfile(PathName,FileName));
    UserData             = Tmp.UserData;
    UserData.PathProject = PathName;
    UserData             = ConfigPath(UserData);
end

%% SAVE PROJECT
% --------------------------------------------------------------------
function FlashSave_ClickedCallback(hObject, eventdata, handles)
global UserData
try
    uisave('UserData',fullfile(UserData.PathProject, UserData.NameProject))
catch
    errordlg('There is no record of any project','!! Error !!')
end


%% RUN MODEL
function FlashRunModel_ClickedCallback(hObject, eventdata, handles)
global UserData
UserData    = ListResults(UserData);
save(fullfile(UserData.PathProject, UserData.NameProject),'UserData')
UserData    = RunModel(UserData);
save(fullfile(UserData.PathProject, UserData.NameProject),'UserData')

% --------------------------------------------------------------------
function FlashProcessing_ClickedCallback(hObject, eventdata, handles)
global UserData
UserData.Mode = 3;
Pre_Procesing_ClimateData(UserData)
Pre_Procesing_DemandData(UserData)

% --------------------------------------------------------------------
function FlashHelp_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to FlashHelp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%% Calibration Model
% --------------------------------------------------------------------
function Flash_Calibration_OnCallback(hObject, eventdata, handles)
% hObject    handle to Flash_Calibration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global UserData
UserData = CalibrationModel(UserData);
save(fullfile(UserData.PathProject, UserData.NameProject),'UserData')

%% MENU PROCESSING
function MenuProcessing_Callback(hObject, eventdata, handles)
function MenuProClimate_Callback(hObject, eventdata, handles)
function MenuProDemand_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function MenuProDemandAll_Callback(hObject, eventdata, handles)
global UserData
UserData.DemandVar = {'Agricultural','Domestic','Livestock','Hydrocarbons','Mining'};
Pre_Procesing_DemandData(UserData)

% --------------------------------------------------------------------
function MenuPro_Agri_Callback(hObject, eventdata, handles)
global UserData
UserData.DemandVar = {'Agricultural'};
Pre_Procesing_DemandData(UserData)
UserData.DemandVar = {'Agricultural','Domestic','Livestock','Hydrocarbons','Mining'};

% --------------------------------------------------------------------
function MenuPro_Dom_Callback(hObject, eventdata, handles)
global UserData
UserData.DemandVar = {'Domestic'};
Pre_Procesing_DemandData(UserData)
UserData.DemandVar = {'Agricultural','Domestic','Livestock','Hydrocarbons','Mining'};

% --------------------------------------------------------------------
function MenuPro_Liv_Callback(hObject, eventdata, handles)
global UserData
UserData.DemandVar = {'Livestock'};
Pre_Procesing_DemandData(UserData)
UserData.DemandVar = {'Agricultural','Domestic','Livestock','Hydrocarbons','Mining'};

% --------------------------------------------------------------------
function MenuPro_Hy_Callback(hObject, eventdata, handles)
global UserData
UserData.DemandVar = {'Hydrocarbons'};
Pre_Procesing_DemandData(UserData)
UserData.DemandVar = {'Agricultural','Domestic','Livestock','Hydrocarbons','Mining'};

% --------------------------------------------------------------------
function MenuPro_Min_Callback(hObject, eventdata, handles)
global UserData
UserData.DemandVar = {'Mining'};
Pre_Procesing_DemandData(UserData)
UserData.DemandVar = {'Agricultural','Domestic','Livestock','Hydrocarbons','Mining'};

% --------------------------------------------------------------------
function MenuProClimateAll_Callback(hObject, eventdata, handles)
global UserData
UserData.Mode = 3;
Pre_Procesing_ClimateData(UserData)

% --------------------------------------------------------------------
function MenuPro_P_Callback(hObject, eventdata, handles)
global UserData
UserData.Mode = 1;
Pre_Procesing_ClimateData(UserData)

% --------------------------------------------------------------------
function MenuPro_T_ETP_Callback(hObject, eventdata, handles)
global UserData
UserData.Mode = 2;
Pre_Procesing_ClimateData(UserData)


%% MENU EDIT 
% --------------------------------------------------------------------
function FlashEdit_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to FlashEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global UserData
UserData = ConfigPath(UserData);
save(fullfile(UserData.PathProject, UserData.NameProject),'UserData')

% --------------------------------------------------------------------
function FlashPlot_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to FlashPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global UserData
UserData    = ListResults(UserData);
save(fullfile(UserData.PathProject, UserData.NameProject),'UserData')
