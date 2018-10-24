function varargout = TableDemand_Dom(varargin)
% TABLEDEMAND_DOM MATLAB code for TableDemand_Dom.fig
%      TABLEDEMAND_DOM, by itself, creates a new TABLEDEMAND_DOM or raises the existing
%      singleton*.
%
%      H = TABLEDEMAND_DOM returns the handle to a new TABLEDEMAND_DOM or the handle to
%      the existing singleton*.
%
%      TABLEDEMAND_DOM('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TABLEDEMAND_DOM.M with the given input arguments.
%
%      TABLEDEMAND_DOM('Property','Value',...) creates a new TABLEDEMAND_DOM or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before TableDemand_Dom_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to TableDemand_Dom_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help TableDemand_Dom

% Last Modified by GUIDE v2.5 17-Feb-2018 07:52:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @TableDemand_Dom_OpeningFcn, ...
                   'gui_OutputFcn',  @TableDemand_Dom_OutputFcn, ...
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


% --- Executes just before TableDemand_Dom is made visible.
function TableDemand_Dom_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to TableDemand_Dom (see VARARGIN)

% Choose default command line output for TableDemand_Dom
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes TableDemand_Dom wait for user response (see UIRESUME)
% uiwait(handles.figure1);

if nargin > 3
    ExcelFile = varargin{1};
    [fil, col] = size(ExcelFile);
    Tmp = cell(fil,31);
    Tmp(1:fil,1:col) = ExcelFile;
    set(handles.TableDom,'Data',Tmp)
end


% --- Outputs from this function are returned to the command line.
function varargout = TableDemand_Dom_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
uiwait(gcf)
global ExcelFileDom
varargout{1} = ExcelFileDom;


% --- Executes on button press in Ok.
function Ok_Callback(hObject, eventdata, handles)
% hObject    handle to Ok (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ExcelFileDom
ExcelFileDom = get(handles.TableDom,'Data');
close(gcf)

% --- Executes on button press in Cancel.
function Cancel_Callback(hObject, eventdata, handles)
% hObject    handle to Cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)}
close(gcf)


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

Raw     = get(handles.TableDom,'Data');
[fil,Col] = size(Raw);
N       = str2num(get(handles.BasinNumber,'String'));
if N > fil
    o = cell(N,31);
    o(1:fil,1:Col) = Raw;
    set(handles.TableDom,'Data',o)
else
    o = cell(N,31);
    o = Raw(1:N,1:Col);
    set(handles.TableDom,'Data',o)
end
