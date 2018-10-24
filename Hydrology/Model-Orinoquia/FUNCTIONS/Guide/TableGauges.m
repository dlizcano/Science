function varargout = TableGauges(varargin)
% TABLEGAUGES MATLAB code for TableGauges.fig
%      TABLEGAUGES, by itself, creates a new TABLEGAUGES or raises the existing
%      singleton*.
%
%      H = TABLEGAUGES returns the handle to a new TABLEGAUGES or the handle to
%      the existing singleton*.
%
%      TABLEGAUGES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TABLEGAUGES.M with the given input arguments.
%
%      TABLEGAUGES('Property','Value',...) creates a new TABLEGAUGES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before TableGauges_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to TableGauges_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help TableGauges

% Last Modified by GUIDE v2.5 24-Jan-2018 14:52:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @TableGauges_OpeningFcn, ...
                   'gui_OutputFcn',  @TableGauges_OutputFcn, ...
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


% --- Executes just before TableGauges is made visible.
function TableGauges_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to TableGauges (see VARARGIN)

% Choose default command line output for TableGauges
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes TableGauges wait for user response (see UIRESUME)
% uiwait(handles.figure1);

if nargin > 3
    GaugesCatalog = varargin{1};
    set(handles.Table,'Data',GaugesCatalog)
end


% --- Outputs from this function are returned to the command line.
function varargout = TableGauges_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
uiwait(gcf)
global GaugesCatalog
varargout{1}  = GaugesCatalog;



function BasinNumber_Callback(hObject, eventdata, handles)
% hObject    handle to text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of text as text
%        str2double(get(hObject,'String')) returns contents of text as a double



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
    o = cell(N,4);
    o(1:fil,:) = Raw;
    set(handles.Table,'Data',o)
else
    o = cell(N,4);
    o = Raw(1:N,:);
    set(handles.Table,'Data',o)
end

% --- Executes on button press in Save.
function Save_Callback(hObject, eventdata, handles)
% hObject    handle to Save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global GaugesCatalog
GaugesCatalog = get(handles.Table,'Data');
close(gcf)

% --- Executes on button press in Cancel.
function Cancel_Callback(hObject, eventdata, handles)
% hObject    handle to Cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(gcf)

% --- Executes on button press in Load.
function Load_Callback(hObject, eventdata, handles)
% hObject    handle to Load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[FileName,PathName] = uigetfile({'*.xlsx','*.xls'});
[DataNum,~,Data]  = xlsread(fullfile(PathName, FileName));
Data        = Data(2:length(DataNum(:,1))+1,1:6);

set(handles.Table,'Data',Data)
