function varargout = Guide_HUA(varargin)
% GUIDE_HUA MATLAB code for Guide_HUA.fig
%      GUIDE_HUA, by itself, creates a new GUIDE_HUA or raises the existing
%      singleton*.
%
%      H = GUIDE_HUA returns the handle to a new GUIDE_HUA or the handle to
%      the existing singleton*.
%
%      GUIDE_HUA('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUIDE_HUA.M with the given input arguments.
%
%      GUIDE_HUA('Property','Value',...) creates a new GUIDE_HUA or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Guide_HUA_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Guide_HUA_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Guide_HUA

% Last Modified by GUIDE v2.5 10-Sep-2018 10:24:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Guide_HUA_OpeningFcn, ...
                   'gui_OutputFcn',  @Guide_HUA_OutputFcn, ...
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


% --- Executes just before Guide_HUA is made visible.
function Guide_HUA_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Guide_HUA (see VARARGIN)

% Choose default command line output for Guide_HUA
handles.output = hObject;

% -------------------------------------------------------------------------

% Evapotranspiration 
Logo = imread('DEM1.png');
set(handles.pushbutton2,'CData',Logo)

axes(handles.axes1)
Logo = imread('DEM1.png');
image(Logo);
axis off

axes(handles.axes2)
Logo = imread('Basin.png');
image(Logo);
axis off

axes(handles.axes3)
Logo = imread('Topo1.png');
image(Logo);
axis off

axes(handles.axes4)
Logo = imread('Sand.jpg');
image(Logo);
axis off

% Evapotranspiration 
axes(handles.axes5)
Logo = imread('Q.jpg');
image(Logo);
axis off

% Evapotranspiration 
axes(handles.axes6)
Logo = imread('Gauges.jpg');
image(Logo);
axis off

% Evapotranspiration 
axes(handles.axes10)
Logo = imread('ETR_2.png');
image(Logo);
axis off

axes(handles.axes9)
Logo = imread('Area.png');
image(Logo);
axis off
% -------------------------------------------------------------------------



% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Guide_HUA wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Guide_HUA_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2


% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in pushbutton11.
function pushbutton11_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton12.
function pushbutton12_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
