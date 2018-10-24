function varargout = ModelProject(varargin)
% MODELPROJECT MATLAB code for ModelProject.fig
%      MODELPROJECT, by itself, creates a new MODELPROJECT or raises the existing
%      singleton*.
%
%      H = MODELPROJECT returns the handle to a new MODELPROJECT or the handle to
%      the existing singleton*.
%
%      MODELPROJECT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MODELPROJECT.M with the given input arguments.
%
%      MODELPROJECT('Property','Value',...) creates a new MODELPROJECT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ModelProject_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ModelProject_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ModelProject

% Last Modified by GUIDE v2.5 24-Jan-2018 15:16:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ModelProject_OpeningFcn, ...
                   'gui_OutputFcn',  @ModelProject_OutputFcn, ...
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


% --- Executes just before ModelProject is made visible.
function ModelProject_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ModelProject (see VARARGIN)

% Choose default command line output for ModelProject
handles.output = hObject;

% Color white Figure 
set(handles.figure1,'Color',[1 1 1])

%% Logos 
% Logo de TNC
axes(handles.axes2)
Logo = imread('Logo_TNC.jpg');
image(Logo);
axis off

% Logo de WCS 
axes(handles.axes3)
Logo = imread('Logo_WCS.jpg');
image(Logo);
axis off

% Logo de SNAPP
axes(handles.axes4)
Logo = imread('Logo_SNAPP.jpg');
image(Logo);
axis off

% Logo de NCEAS
axes(handles.axes5)
Logo = imread('Logo_NCEAS.png');
image(Logo);
axis off

% Logo de NCEAS
axes(handles.axes6)
Logo = imread('Model.png');
image(Logo);
axis off

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ModelProject wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ModelProject_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in OpenProject.
function OpenProject_Callback(hObject, eventdata, handles)
% hObject    handle to OpenProject (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global UserData
[FileName,PathName] = uigetfile('*.mat');
load(fullfile(PathName,FileName));
close(gcf)
Model(UserData)



% --- Executes on button press in NewProject.
function NewProject_Callback(hObject, eventdata, handles)
% hObject    handle to NewProject (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global UserData
UserData = struct;
UserData.PathProject = uigetdir;
UserData = ConfigPath(UserData);
close(gcf)
Model(UserData)
