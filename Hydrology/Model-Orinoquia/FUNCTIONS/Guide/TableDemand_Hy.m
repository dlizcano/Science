function varargout = TableDemand_Hy(varargin)
% TABLEDEMAND_HY MATLAB code for TableDemand_Hy.fig
%      TABLEDEMAND_HY, by itself, creates a new TABLEDEMAND_HY or raises the existing
%      singleton*.
%
%      H = TABLEDEMAND_HY returns the handle to a new TABLEDEMAND_HY or the handle to
%      the existing singleton*.
%
%      TABLEDEMAND_HY('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TABLEDEMAND_HY.M with the given input arguments.
%
%      TABLEDEMAND_HY('Property','Value',...) creates a new TABLEDEMAND_HY or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before TableDemand_Hy_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to TableDemand_Hy_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help TableDemand_Hy

% Last Modified by GUIDE v2.5 17-Feb-2018 07:53:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @TableDemand_Hy_OpeningFcn, ...
                   'gui_OutputFcn',  @TableDemand_Hy_OutputFcn, ...
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


% --- Executes just before TableDemand_Hy is made visible.
function TableDemand_Hy_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to TableDemand_Hy (see VARARGIN)

% Choose default command line output for TableDemand_Hy
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes TableDemand_Hy wait for user response (see UIRESUME)
% uiwait(handles.figure1);

if nargin > 3
    ExcelFile = varargin{1};
    [fil, col] = size(ExcelFile);
    Tmp = cell(fil,31);
    Tmp(1:fil,1:col) = ExcelFile;
    set(handles.TableHy,'Data',Tmp)
end


% --- Outputs from this function are returned to the command line.
function varargout = TableDemand_Hy_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
uiwait(gcf)
global ExcelFileHy
varargout{1} = ExcelFileHy;


% --- Executes on button press in Ok.
function Ok_Callback(hObject, eventdata, handles)
% hObject    handle to Ok (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ExcelFileHy
ExcelFileHy = get(handles.TableHy,'Data');
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

Raw     = get(handles.TableHy,'Data');
[fil,Col] = size(Raw);
N       = str2num(get(handles.BasinNumber,'String'));
if N > fil
    o = cell(N,31);
    o(1:fil,1:Col) = Raw;
    set(handles.TableHy,'Data',o)
else
    o = cell(N,31);
    o = Raw(1:N,1:Col);
    set(handles.TableHy,'Data',o)
end
