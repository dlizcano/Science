function varargout = Load_Gauges(varargin)
% LOAD_GAUGES MATLAB code for Load_Gauges.fig
%      LOAD_GAUGES, by itself, creates a new LOAD_GAUGES or raises the existing
%      singleton*.
%
%      H = LOAD_GAUGES returns the handle to a new LOAD_GAUGES or the handle to
%      the existing singleton*.
%
%      LOAD_GAUGES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LOAD_GAUGES.M with the given input arguments.
%
%      LOAD_GAUGES('Property','Value',...) creates a new LOAD_GAUGES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Load_Gauges_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Load_Gauges_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Load_Gauges

% Last Modified by GUIDE v2.5 08-Sep-2018 14:33:09

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Load_Gauges_OpeningFcn, ...
                   'gui_OutputFcn',  @Load_Gauges_OutputFcn, ...
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


% --- Executes just before Load_Gauges is made visible.
function Load_Gauges_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Load_Gauges (see VARARGIN)

% Choose default command line output for Load_Gauges
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Load_Gauges wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Load_Gauges_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
