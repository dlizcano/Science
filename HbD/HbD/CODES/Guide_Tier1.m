function varargout = Guide_Tier1(varargin)
% GUIDE_TIER1 MATLAB code for Guide_Tier1.fig
%      GUIDE_TIER1, by itself, creates a new GUIDE_TIER1 or raises the existing
%      singleton*.
%
%      H = GUIDE_TIER1 returns the handle to a new GUIDE_TIER1 or the handle to
%      the existing singleton*.
%
%      GUIDE_TIER1('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUIDE_TIER1.M with the given input arguments.
%
%      GUIDE_TIER1('Property','Value',...) creates a new GUIDE_TIER1 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Guide_Tier1_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Guide_Tier1_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Guide_Tier1

% Last Modified by GUIDE v2.5 08-Sep-2018 15:04:09

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Guide_Tier1_OpeningFcn, ...
                   'gui_OutputFcn',  @Guide_Tier1_OutputFcn, ...
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


% --- Executes just before Guide_Tier1 is made visible.
function Guide_Tier1_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Guide_Tier1 (see VARARGIN)

% Choose default command line output for Guide_Tier1
handles.output = hObject;

% -------------------------------------------------------------------------
% Logo de TNC
axes(handles.axes1)
Logo = imread('Sima.png');
image(Logo);
axis off

% HbD
axes(handles.axes2)
Logo = imread('HbD.jpg');
image(Logo);
axis off

% Atmosphere
axes(handles.axes3)
Logo = imread('Atm.jpg');
image(Logo);
axis off

% Basin
axes(handles.axes4)
Logo = imread('Basin.jpg');
image(Logo);
axis off

% Run
axes(handles.axes5)
Logo = imread('Run.png');
image(Logo);
axis off
% -------------------------------------------------------------------------


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Guide_Tier1 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Guide_Tier1_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;



function BasinName_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function BasinName_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in CreHbD.
function CreHbD_Callback(hObject, eventdata, handles)

set(handles.TF_HbD,'String','Ok','ForegroundColor','green')

% --- Executes on button press in CreAtm.
function CreAtm_Callback(hObject, eventdata, handles)


% --- Executes on button press in CreHUA.
function CreHUA_Callback(hObject, eventdata, handles)


function SceName_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function SceName_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function FlashNew_ClickedCallback(hObject, eventdata, handles)

global UserData

UserData    = ClassUserData;
Tmp         = uigetdir;

if Tmp ~= 0 
    UserData.PathProject    = Tmp;
    
    UserData                = ConfigPath(UserData);

end

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


% --------------------------------------------------------------------
function FlashSave_ClickedCallback(hObject, eventdata, handles)

global UserData
try
    uisave('UserData',fullfile(UserData.PathProject, UserData.NameProject))
catch
    errordlg('There is no project','!! Error !!')
end
