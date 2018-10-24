function varargout = Guide_Hp(varargin)
% GUIDE_HP MATLAB code for Guide_Hp.fig
%      GUIDE_HP, by itself, creates a new GUIDE_HP or raises the existing
%      singleton*.
%
%      H = GUIDE_HP returns the handle to a new GUIDE_HP or the handle to
%      the existing singleton*.
%
%      GUIDE_HP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUIDE_HP.M with the given input arguments.
%
%      GUIDE_HP('Property','Value',...) creates a new GUIDE_HP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Guide_Hp_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Guide_Hp_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Guide_Hp

% Last Modified by GUIDE v2.5 08-Sep-2018 16:28:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Guide_Hp_OpeningFcn, ...
                   'gui_OutputFcn',  @Guide_Hp_OutputFcn, ...
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


% --- Executes just before Guide_Hp is made visible.
function Guide_Hp_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Guide_Hp (see VARARGIN)

% Choose default command line output for Guide_Hp
handles.output = hObject;

% -------------------------------------------------------------------------
axes(handles.axes1)
Logo = imread('Dam.jpg');
image(Logo);
axis off
% -------------------------------------------------------------------------

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Guide_Hp wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Guide_Hp_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Button_Cancel.
function Button_Cancel_Callback(hObject, eventdata, handles)
% hObject    handle to Button_Cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in Button_Save.
function Button_Save_Callback(hObject, eventdata, handles)
% hObject    handle to Button_Save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
