function varargout = TableNetwork(varargin)
% TABLENETWORK MATLAB code for TableNetwork.fig
%      TABLENETWORK, by itself, creates a new TABLENETWORK or raises the existing
%      singleton*.
%
%      H = TABLENETWORK returns the handle to a new TABLENETWORK or the handle to
%      the existing singleton*.
%
%      TABLENETWORK('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TABLENETWORK.M with the given input arguments.
%
%      TABLENETWORK('Property','Value',...) creates a new TABLENETWORK or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before TableNetwork_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to TableNetwork_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help TableNetwork

% Last Modified by GUIDE v2.5 24-Jan-2018 15:13:04

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @TableNetwork_OpeningFcn, ...
                   'gui_OutputFcn',  @TableNetwork_OutputFcn, ...
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


% --- Executes just before TableNetwork is made visible.
function TableNetwork_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to TableNetwork (see VARARGIN)

% Choose default command line output for TableNetwork
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes TableNetwork wait for user response (see UIRESUME)
% uiwait(handles.figure1);

global TopoNetwork
TopoNetwork = get(handles.Table,'Data');
set(handles.Table,'Data',TopoNetwork)

if nargin > 3
    TopoNetwork = varargin{1};
    set(handles.Table,'Data',TopoNetwork)
end

% --- Outputs from this function are returned to the command line.
function varargout = TableNetwork_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
uiwait(gcf)
global TopoNetwork
varargout{1} = TopoNetwork;

% --- Executes during object creation, after setting all properties.
function text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Update.
function Update_Callback(hObject, eventdata, handles)
% hObject    handle to Update (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Raw     = get(handles.Table,'Data');
[fil,~] = size(Raw);
N       = str2num(get(handles.BasinNumber,'String'));
if N > fil
    o = cell(N,5);
    o(1:fil,:) = Raw;
    set(handles.Table,'Data',o)
else
    o = cell(N,5);
    o = Raw(1:N,:);
    set(handles.Table,'Data',o)
end

% --- Executes on button press in Save.
function Save_Callback(hObject, eventdata, handles)
% hObject    handle to Save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global TopoNetwork
TopoNetwork = get(handles.Table,'Data');
close(gcf)

% --- Executes on button press in Cancel.
function Cancel_Callback(hObject, eventdata, handles)
% hObject    handle to Cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global TopoNetwork
TopoNetwork = [];
close(gcf)

% --- Executes on button press in Load.
function Load_Callback(hObject, eventdata, handles)
% hObject    handle to Load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[FileName,PathName] = uigetfile({'*.xlsx','*.xls'});
Data                = xlsread(fullfile(PathName, FileName));
set(handles.Table,'Data',Data)



function BasinNumber_Callback(hObject, eventdata, handles)
% hObject    handle to BasinNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of BasinNumber as text
%        str2double(get(hObject,'String')) returns contents of BasinNumber as a double


% --- Executes during object creation, after setting all properties.
function BasinNumber_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BasinNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
