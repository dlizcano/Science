function varargout = TableDemand(varargin)
% TABLEDEMAND MATLAB code for TableDemand.fig
%      TABLEDEMAND, by itself, creates a new TABLEDEMAND or raises the existing
%      singleton*.
%
%      H = TABLEDEMAND returns the handle to a new TABLEDEMAND or the handle to
%      the existing singleton*.
%
%      TABLEDEMAND('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TABLEDEMAND.M with the given input arguments.
%
%      TABLEDEMAND('Property','Value',...) creates a new TABLEDEMAND or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before TableDemand_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to TableDemand_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help TableDemand

% Last Modified by GUIDE v2.5 24-Jan-2018 13:28:43

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @TableDemand_OpeningFcn, ...
                   'gui_OutputFcn',  @TableDemand_OutputFcn, ...
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


% --- Executes just before TableDemand is made visible.
function TableDemand_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to TableDemand (see VARARGIN)

% Choose default command line output for TableDemand
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes TableDemand wait for user response (see UIRESUME)
% uiwait(handles.figure1);

if nargin > 3
    ExcelFile = varargin{1};
    set(handles.Table,'Data',ExcelFile)
end


% --- Outputs from this function are returned to the command line.
function varargout = TableDemand_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
uiwait(gcf)
global ExcelFile
varargout{1} = ExcelFile;


% --- Executes on button press in Ok.
function Ok_Callback(hObject, eventdata, handles)
% hObject    handle to Ok (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ExcelFile
ExcelFile = get(handles.Table,'Data');
close(gcf)

% --- Executes on button press in Cancel.
function Cancel_Callback(hObject, eventdata, handles)
% hObject    handle to Cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)}
close(gcf)

% --- Executes on button press in LoadValue.
function LoadValue_Callback(hObject, eventdata, handles)
% hObject    handle to LoadValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ExcelFile
ExcelFile = get(handles.Table,'Data');
[FileName,PathName] = uigetfile({'*.xlsx','*.xls'},'MultiSelect','on');
if iscell(FileName) == 0
    ExcelFile{1,2} = fullfile(PathName,FileName);
else
    for i = 1:length(FileName)
        ExcelFile{i,2} = fullfile(PathName,FileName{i});
    end
end
set(handles.Table,'Data',ExcelFile)

% --- Executes on button press in LoadModule.
function LoadModule_Callback(hObject, eventdata, handles)
% hObject    handle to LoadModule (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global ExcelFile
ExcelFile = get(handles.Table,'Data');
[FileName,PathName] = uigetfile({'*.xlsx','*.xls'},'MultiSelect','on');
if iscell(FileName) == 0
    ExcelFile{1,3} = fullfile(PathName,FileName);
else
    for i = 1:length(FileName)
        ExcelFile{i,3} = fullfile(PathName,FileName{i});
    end
end
set(handles.Table,'Data',ExcelFile)

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


% --- Executes on button press in Update.
function Update_Callback(hObject, eventdata, handles)
% hObject    handle to Update (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Raw     = get(handles.Table,'Data');
[fil,~] = size(Raw);
N       = str2num(get(handles.BasinNumber,'String'));
if N > fil
    o = cell(N,33);
    o(1:fil,:) = Raw;
    set(handles.Table,'Data',o)
else
    o = cell(N,33);
    o = Raw(1:N,:);
    set(handles.Table,'Data',o)
end
