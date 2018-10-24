function varargout = ConfigPath(varargin)
% CONFIGPATH MATLAB code for ConfigPath.fig
%      CONFIGPATH, by itself, creates a new CONFIGPATH or raises the existing
%      singleton*.
%
%      H = CONFIGPATH returns the handle to a new CONFIGPATH or the handle to
%      the existing singleton*.
%
%      CONFIGPATH('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CONFIGPATH.M with the given input arguments.
%
%      CONFIGPATH('Property','Value',...) creates a new CONFIGPATH or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ConfigPath_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ConfigPath_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ConfigPath

% Last Modified by GUIDE v2.5 21-Jul-2018 13:34:23

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ConfigPath_OpeningFcn, ...
                   'gui_OutputFcn',  @ConfigPath_OutputFcn, ...
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


% --- Executes just before ConfigPath is made visible.
function ConfigPath_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ConfigPath (see VARARGIN)

% Choose default command line output for ConfigPath
handles.output = hObject;

set(handles.figure1,'Color',[1 1 1])

% set(handles.Panel_Geo,'Visible', 'off')

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ConfigPath wait for user response (see UIRESUME)
% uiwait(handles.figure1);

global UserData
if nargin > 3
    % Project Path
    UserData = varargin{1};

    % Demand Variables
    UserData.DemandVar                      = {'Agricultural','Domestic','Livestock','Hydrocarbons','Mining'};
    % Climate Varibles
    UserData.ClimateVar                     = {'Precipitation', 'Temperature', 'Evapotranspiration'};

    % Name Project
    if isfield(UserData, 'ShapeFileHUA')
        set(handles.NameProject,'String',UserData.NameProject)
        set(handles.HUA,'String', UserData.ShapeFileHUA)
        set(handles.DEM,'String', UserData.GridDEM)
        set(handles.Pcp,'String', UserData.DataPrecipitation)
        set(handles.Gauges,'String', UserData.ShapeFileNetwork)
        set(handles.StreamFlow,'String', UserData.DataStreamFlow)
        set(handles.ModeModel,'Value',UserData.ModeModel)        
        set(handles.Cal_ETP,'Value',UserData.Cal_ETP)
        set(handles.ParamsM,'String',UserData.DataParams)

        if UserData.Cal_ETP == 1
            set(handles.Type_T_ETP,'Value',UserData.TypeDataEvapotranspiration)
            set(handles.T,'String', UserData.DataEvapotranspiration);
        else
            set(handles.Type_T_ETP,'Value',UserData.TypeDataTemperature)
            set(handles.T,'String', UserData.DataTemperature);
            
        end

        % Data Type Precipitation
        set(handles.Type_P,'Value',UserData.TypeDataPrecipitation)
        % Calculation of Domestic Demand
        set(handles.Est_Agri,'Value',UserData.Cal_Domestic)
        % Calculation of Domestic Demand
        set(handles.Est_Dom,'Value',UserData.Cal_Domestic)
        % Calculation of Livestock Demand
        set(handles.Est_Liv,'Value',UserData.Cal_Livestock)
        % Calculation of Hydrocarbons Demand
        set(handles.Est_Hy,'Value',UserData.Cal_Hydrocarbons)
        % Calculation of Mining Demand
        set(handles.Est_Min,'Value',UserData.Cal_Mining)

        % Inc of Agricultural Demand
        set(handles.Agri_checkbox,'Value',UserData.Inc_Agricultural)
        % Inc of Domestic Demand
        set(handles.Dom_checkbox,'Value',UserData.Inc_Domestic)
        % Inc of Livestock Demand
        set(handles.Liv_checkbox,'Value',UserData.Inc_Livestock)
        % Inc of Hydrocarbons Demand
        set(handles.Hy_checkbox,'Value',UserData.Inc_Hydrocarbons)
        % Inc of Mining Demand
        set(handles.Min_checkbox,'Value',UserData.Inc_Mining)
    end
end



% --- Outputs from this function are returned to the command line.
function varargout = ConfigPath_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
uiwait(gcf)
global UserData
varargout{1} = UserData;



function CoresNumber_Callback(hObject, eventdata, handles)
% hObject    handle to CoresNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CoresNumber as text
%        str2double(get(hObject,'String')) returns contents of CoresNumber as a double


% --- Executes during object creation, after setting all properties.
function CoresNumber_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CoresNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in ModeModel.
function ModeModel_Callback(hObject, eventdata, handles)
% hObject    handle to ModeModel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ModeModel contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ModeModel


% --- Executes during object creation, after setting all properties.
function ModeModel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ModeModel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Cal_ETP.
function Cal_ETP_Callback(hObject, eventdata, handles)
% hObject    handle to Cal_ETP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Cal_ETP contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Cal_ETP


% --- Executes during object creation, after setting all properties.
function Cal_ETP_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Cal_ETP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Type_T_ETP.
function Type_T_ETP_Callback(hObject, eventdata, handles)
% hObject    handle to Type_T_ETP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Type_T_ETP contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Type_T_ETP


% --- Executes during object creation, after setting all properties.
function Type_T_ETP_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Type_T_ETP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu5.
function popupmenu5_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu5 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu5


% --- Executes during object creation, after setting all properties.
function popupmenu5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Est_Agri.
function Est_Agri_Callback(hObject, eventdata, handles)
% hObject    handle to Est_Agri (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Est_Agri contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Est_Agri


% --- Executes during object creation, after setting all properties.
function Est_Agri_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Est_Agri (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Est_Dom.
function Est_Dom_Callback(hObject, eventdata, handles)
% hObject    handle to Est_Dom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Est_Dom contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Est_Dom


% --- Executes during object creation, after setting all properties.
function Est_Dom_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Est_Dom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Est_Liv.
function Est_Liv_Callback(hObject, eventdata, handles)
% hObject    handle to Est_Liv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Est_Liv contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Est_Liv


% --- Executes during object creation, after setting all properties.
function Est_Liv_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Est_Liv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Est_Hy.
function Est_Hy_Callback(hObject, eventdata, handles)
% hObject    handle to Est_Hy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Est_Hy contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Est_Hy


% --- Executes during object creation, after setting all properties.
function Est_Hy_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Est_Hy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Est_Min.
function Est_Min_Callback(hObject, eventdata, handles)
% hObject    handle to Est_Min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Est_Min contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Est_Min


% --- Executes during object creation, after setting all properties.
function Est_Min_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Est_Min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Show_Data_D_Agri_Callback(hObject, eventdata, handles)
% hObject    handle to Show_Data_D_Agri (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Show_Data_D_Agri as text
%        str2double(get(hObject,'String')) returns contents of Show_Data_D_Agri as a double


% --- Executes during object creation, after setting all properties.
function Show_Data_D_Agri_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Show_Data_D_Agri (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Show_Data_D_Dom_Callback(hObject, eventdata, handles)
% hObject    handle to Show_Data_D_Dom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Show_Data_D_Dom as text
%        str2double(get(hObject,'String')) returns contents of Show_Data_D_Dom as a double


% --- Executes during object creation, after setting all properties.
function Show_Data_D_Dom_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Show_Data_D_Dom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Show_Data_D_Liv_Callback(hObject, eventdata, handles)
% hObject    handle to Show_Data_D_Liv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Show_Data_D_Liv as text
%        str2double(get(hObject,'String')) returns contents of Show_Data_D_Liv as a double


% --- Executes during object creation, after setting all properties.
function Show_Data_D_Liv_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Show_Data_D_Liv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Show_Data_D_Hy_Callback(hObject, eventdata, handles)
% hObject    handle to Show_Data_D_Hy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Show_Data_D_Hy as text
%        str2double(get(hObject,'String')) returns contents of Show_Data_D_Hy as a double


% --- Executes during object creation, after setting all properties.
function Show_Data_D_Hy_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Show_Data_D_Hy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Show_Data_D_Min_Callback(hObject, eventdata, handles)
% hObject    handle to Show_Data_D_Min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Show_Data_D_Min as text
%        str2double(get(hObject,'String')) returns contents of Show_Data_D_Min as a double


% --- Executes during object creation, after setting all properties.
function Show_Data_D_Min_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Show_Data_D_Min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Show_Data_P_Callback(hObject, eventdata, handles)
% hObject    handle to Show_Data_P (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Show_Data_P as text
%        str2double(get(hObject,'String')) returns contents of Show_Data_P as a double


% --- Executes during object creation, after setting all properties.
function Show_Data_P_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Show_Data_P (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Show_Data_T_ETP_Callback(hObject, eventdata, handles)
% hObject    handle to Show_Data_T_ETP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Show_Data_T_ETP as text
%        str2double(get(hObject,'String')) returns contents of Show_Data_T_ETP as a double


% --- Executes during object creation, after setting all properties.
function Show_Data_T_ETP_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Show_Data_T_ETP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit20_Callback(hObject, eventdata, handles)
% hObject    handle to edit20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit20 as text
%        str2double(get(hObject,'String')) returns contents of edit20 as a double


% --- Executes during object creation, after setting all properties.
function edit20_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Show_Excel_Q_Callback(hObject, eventdata, handles)
% hObject    handle to Show_Excel_Q (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Show_Excel_Q as text
%        str2double(get(hObject,'String')) returns contents of Show_Excel_Q as a double


% --- Executes during object creation, after setting all properties.
function Show_Excel_Q_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Show_Excel_Q (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Path_SU_Callback(hObject, eventdata, handles)
% hObject    handle to Path_SU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Path_SU as text
%        str2double(get(hObject,'String')) returns contents of Path_SU as a double


% --- Executes during object creation, after setting all properties.
function Path_SU_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Path_SU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Path_SUD_Callback(hObject, eventdata, handles)
% hObject    handle to Path_SUD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Path_SUD as text
%        str2double(get(hObject,'String')) returns contents of Path_SUD as a double


% --- Executes during object creation, after setting all properties.
function Path_SUD_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Path_SUD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Show_Shp_HUA_Callback(hObject, eventdata, handles)
% hObject    handle to Show_Shp_HUA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Show_Shp_HUA as text
%        str2double(get(hObject,'String')) returns contents of Show_Shp_HUA as a double


% --- Executes during object creation, after setting all properties.
function Show_Shp_HUA_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Show_Shp_HUA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit25_Callback(hObject, eventdata, handles)
% hObject    handle to edit25 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit25 as text
%        str2double(get(hObject,'String')) returns contents of edit25 as a double


% --- Executes during object creation, after setting all properties.
function edit25_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit25 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in SaveMC.
function SaveMC_Callback(hObject, eventdata, handles)
% hObject    handle to SaveMC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global UserData

% Name Project
UserData.NameProject                = get(handles.NameProject,'String');
% Cores Number
UserData.CoresNumber                = 1;
UserData.Parallel                   = 0;
% Run under code
UserData.VerboseCal                 = 0;
UserData.ShapeFileHUA               = get(handles.HUA,'String');
UserData.GridDEM                    = get(handles.DEM,'String');
UserData.DataPrecipitation          = get(handles.Pcp,'String');
UserData.ShapeFileNetwork           = get(handles.Gauges,'String');
UserData.DataStreamFlow             = get(handles.StreamFlow,'String');
UserData.DataParams                 = get(handles.ParamsM,'String');

% Model Mode
Va = get(handles.ModeModel,'Value');
UserData.ModeModel                  = Va;
% Calculation of Evapotranspiration
Va = get(handles.Cal_ETP,'Value');
UserData.Cal_ETP                    = Va;
% Data Type Precipitation
Va = get(handles.Type_P,'Value');
UserData.TypeDataPrecipitation      = Va;
% Data Type Evapotranspiration or Temperature
if UserData.Cal_ETP == 1
    try
        UserData = rmfield(UserData,'TypeDataTemperature');
        UserData = rmfield(UserData,'DataTemperature');
    catch
    end
    Va = get(handles.Type_T_ETP,'Value');
    UserData.TypeDataEvapotranspiration = Va;
    UserData.DataEvapotranspiration     = get(handles.T,'String');
else
    try
        UserData = rmfield(UserData,'TypeDataEvapotranspiration');
        UserData = rmfield(UserData,'DataEvapotranspiration');
    catch
    end
    Va = get(handles.Type_T_ETP,'Value');
    UserData.TypeDataTemperature    = Va;
    UserData.DataTemperature        = get(handles.T,'String');
end

% Calculation of Agricultural Demand
Va = get(handles.Est_Agri,'Value');
UserData.Cal_Agricultural           = Va;
% Calculation of Domestic Demand
Va = get(handles.Est_Dom,'Value');
UserData.Cal_Domestic               = Va;
% Calculation of Livestock Demand
Va = get(handles.Est_Liv,'Value');
UserData.Cal_Livestock              = Va;
% Calculation of Hydrocarbons Demand
Va = get(handles.Est_Hy,'Value');
UserData.Cal_Hydrocarbons           = Va;
% Calculation of Mining Demand
Va = get(handles.Est_Min,'Value');
UserData.Cal_Mining                 = Va;

% ---------------------------------------
% Calculation of Agricultural Demand
Va = get(handles.Agri_checkbox,'Value');
UserData.Inc_Agricultural           = Va;
% Calculation of Domestic Demand
Va = get(handles.Dom_checkbox,'Value');
UserData.Inc_Domestic               = Va;
% Calculation of Livestock Demand
Va = get(handles.Liv_checkbox,'Value');
UserData.Inc_Livestock              = Va;
% Calculation of Hydrocarbons Demand
Va = get(handles.Hy_checkbox,'Value');
UserData.Inc_Hydrocarbons           = Va;
% Calculation of Mining Demand
Va = get(handles.Min_checkbox,'Value');
UserData.Inc_Mining                 = Va;

save(fullfile(UserData.PathProject,[UserData.NameProject,'.mat']), 'UserData')
close(gcf)

function NameExcel_Q_Callback(hObject, eventdata, handles)
% hObject    handle to NameExcel_Q (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NameExcel_Q as text
%        str2double(get(hObject,'String')) returns contents of NameExcel_Q as a double


% --- Executes during object creation, after setting all properties.
function NameExcel_Q_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NameExcel_Q (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function NameShp_HUA_Callback(hObject, eventdata, handles)
% hObject    handle to NameShp_HUA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NameShp_HUA as text
%        str2double(get(hObject,'String')) returns contents of NameShp_HUA as a double


% --- Executes during object creation, after setting all properties.
function NameShp_HUA_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NameShp_HUA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Name_DEM_Callback(hObject, eventdata, handles)
% hObject    handle to Name_DEM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Name_DEM as text
%        str2double(get(hObject,'String')) returns contents of Name_DEM as a double


% --- Executes during object creation, after setting all properties.
function Name_DEM_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Name_DEM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function NAN_Value_Callback(hObject, eventdata, handles)
% hObject    handle to NAN_Value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NAN_Value as text
%        str2double(get(hObject,'String')) returns contents of NAN_Value as a double


% --- Executes during object creation, after setting all properties.
function NAN_Value_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NAN_Value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Load_D_Liv.
function Load_D_Liv_Callback(hObject, eventdata, handles)
% hObject    handle to Load_D_Liv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in Load_D_Min.
function Load_D_Min_Callback(hObject, eventdata, handles)
% hObject    handle to Load_D_Min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in Load_D_Hy.
function Load_D_Hy_Callback(hObject, eventdata, handles)
% hObject    handle to Load_D_Hy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in Load_D_Dom.
function Load_D_Dom_Callback(hObject, eventdata, handles)
% hObject    handle to Load_D_Dom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in Load_D_Agri.
function Load_D_Agri_Callback(hObject, eventdata, handles)
% hObject    handle to Load_D_Agri (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[FileName,PathName] = uigetfile({'Value*.xlsx','*Value.xls'},'MultiSelect','on');
% Agricultural Demand Data Path
global UserData
UserData.PathsDemand_Agricultural   = FileName;


% --- Executes on button press in OkMC.
function OkMC_Callback(hObject, eventdata, handles)
% hObject    handle to OkMC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in CancelMC.
function CancelMC_Callback(hObject, eventdata, handles)
% hObject    handle to CancelMC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

close(gcf)

function Show_Tif_DEM_Callback(hObject, eventdata, handles)
% hObject    handle to Show_Tif_DEM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Show_Tif_DEM as text
%        str2double(get(hObject,'String')) returns contents of Show_Tif_DEM as a double


% --- Executes during object creation, after setting all properties.
function Show_Tif_DEM_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Show_Tif_DEM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Load_Gauges.
function Load_Gauges_Callback(hObject, eventdata, handles)
% hObject    handle to Load_Gauges (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global UserData
if isfield(UserData,'GaugesCatalog')
    UserData.GaugesCatalog = TableGauges(UserData.GaugesCatalog);
else
    UserData.GaugesCatalog = TableGauges;
end

% --- Executes on button press in Load_Network.
function Load_Network_Callback(hObject, eventdata, handles)
% hObject    handle to Load_Network (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton20.
function pushbutton20_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton21.
function pushbutton21_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton22.
function pushbutton22_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton23.
function pushbutton23_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton24.
function pushbutton24_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in LoadData_Agri.
function LoadData_Agri_Callback(hObject, eventdata, handles)
% hObject    handle to LoadData_Agri (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Agricultural Demand Data Path
global UserData 
Tmp = get(handles.Agri_checkbox,'Value');

if Tmp == 1
    if isfield(UserData,'DataAgricultural')
        Data = {};
        DataTmp = TableDemand_Agri(UserData.DataAgricultural);
        if ~isempty(DataTmp)
            for i = 1:length(DataTmp(:,1))
                for j = 1:length(DataTmp(1,:))
                    T = DataTmp{i,j};
                    if ~isempty(T)
                        Data{i,j} = T;
                    end
                end
            end
            UserData.DataAgricultural = Data;
        end
    else
        Data = {};
        DataTmp = TableDemand_Agri;
        if ~isempty(DataTmp)
            for i = 1:length(DataTmp(:,1))
                for j = 1:length(DataTmp(1,:))
                    T = DataTmp{i,j};
                    if ~isempty(T)
                        Data{i,j} = T;
                    end
                end
            end
            UserData.DataAgricultural = Data;
        end
    end
else
    errordlg('Estimate Agricultural Demand - False!!','!! Error !!')
end

% --- Executes on button press in LoadData_Dom.
function LoadData_Dom_Callback(hObject, eventdata, handles)
% hObject    handle to LoadData_Dom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Domestic Demand Data Path
global UserData
Tmp = get(handles.Dom_checkbox,'Value');
Tmp2 = get(handles.Est_Dom,'Value');

if Tmp == 1
    if isfield(UserData,'DataDomestic')
        Data = {};
        if Tmp2 == 1
            DataTmp = TableDemand_Dom(UserData.DataDomestic);
        else
            DataTmp = TableDemandTotal(UserData.DataDomestic);
        end
        
        if ~isempty(DataTmp)
            for i = 1:length(DataTmp(:,1))
                for j = 1:length(DataTmp(1,:))
                    T = DataTmp{i,j};
                    if ~isempty(T)
                        Data{i,j} = T;
                    end
                end
            end
            UserData.DataDomestic = Data;
        end
    else
        Data = {};
        if Tmp2 == 1
            DataTmp = TableDemand_Dom;
        else
            DataTmp = TableDemandTotal;
        end
        if ~isempty(DataTmp)
            for i = 1:length(DataTmp(:,1))
                for j = 1:length(DataTmp(1,:))
                    T = DataTmp{i,j};
                    if ~isempty(T)
                        Data{i,j} = T;
                    end
                end
            end
            UserData.DataDomestic = Data;
        end
    end
else
    errordlg('Estimate Domestic Demand - False!!','!! Error !!')
end

% --- Executes on button press in LoadData_Liv.
function LoadData_Liv_Callback(hObject, eventdata, handles)
% hObject    handle to LoadData_Liv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Livestock Demand Data Path
global UserData
Tmp = get(handles.Liv_checkbox,'Value');
Tmp2 = get(handles.Est_Liv,'Value');
if Tmp == 1
    if isfield(UserData,'DataLivestock')
        Data = {};
        if Tmp2 == 1
            DataTmp = TableDemand_Liv(UserData.DataLivestock);
        else
            DataTmp = TableDemandTotal(UserData.DataLivestock);
        end
        if ~isempty(DataTmp)
            for i = 1:length(DataTmp(:,1))
                for j = 1:length(DataTmp(1,:))
                    T = DataTmp{i,j};
                    if ~isempty(T)
                        Data{i,j} = T;
                    end
                end
            end
            UserData.DataLivestock = Data;
        end
    else
        Data = {};
        if Tmp2 == 1
            DataTmp = TableDemand_Liv;
        else
            DataTmp = TableDemandTotal;
        end
        if ~isempty(DataTmp)
            for i = 1:length(DataTmp(:,1))
                for j = 1:length(DataTmp(1,:))
                    T = DataTmp{i,j};
                    if ~isempty(T)
                        Data{i,j} = T;
                    end
                end
            end
            UserData.DataLivestock = Data;
        end
    end
else
    errordlg('Estimate Livestock Demand - False!!','!! Error !!')
end

% --- Executes on button press in LoadData_Hy.
function LoadData_Hy_Callback(hObject, eventdata, handles)
% hObject    handle to LoadData_Hy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hydrocarbons Demand Data Path
global UserData
Tmp = get(handles.Hy_checkbox,'Value');
Tmp2 = get(handles.Est_Hy,'Value');

if Tmp == 1
    if isfield(UserData,'DataHydrocarbons')
        Data = {};
        if Tmp2 == 1
            DataTmp = TableDemand_Hy(UserData.DataHydrocarbons);
        else
            DataTmp = TableDemandTotal(UserData.DataHydrocarbons);
        end
        if ~isempty(DataTmp)
            for i = 1:length(DataTmp(:,1))
                for j = 1:length(DataTmp(1,:))
                    T = DataTmp{i,j};
                    if ~isempty(T)
                        Data{i,j} = T;
                    end
                end
            end
            UserData.DataHydrocarbons = Data;
        end
    else
        Data = {};
        if Tmp2 == 1
            DataTmp = TableDemand_Hy;
        else
            DataTmp = TableDemandTotal;
        end
        if ~isempty(DataTmp)
            for i = 1:length(DataTmp(:,1))
                for j = 1:length(DataTmp(1,:))
                    T = DataTmp{i,j};
                    if ~isempty(T)
                        Data{i,j} = T;
                    end
                end
            end
            UserData.DataHydrocarbons = Data;
        end
    end
else
    errordlg('Estimate Hydrocarbons Demand - False!!','!! Error !!')
end

% --- Executes on button press in LoadData_Min.
function LoadData_Min_Callback(hObject, eventdata, handles)
% hObject    handle to LoadData_Min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Mining Demand Data Path
global UserData
Tmp = get(handles.Min_checkbox,'Value');
Tmp2 = get(handles.Est_Min,'Value');

if Tmp == 1
    if isfield(UserData,'DataMining')
        Data = {};
        if Tmp2 == 1
            DataTmp = TableDemand_Min(UserData.DataMining);
        else
            DataTmp = TableDemandTotal(UserData.DataMining);
        end
        if ~isempty(DataTmp)
            for i = 1:length(DataTmp(:,1))
                for j = 1:length(DataTmp(1,:))
                    T = DataTmp{i,j};
                    if ~isempty(T)
                        Data{i,j} = T;
                    end
                end
            end
            UserData.DataMining = Data;
        end
    else
        Data = {};
        if Tmp2 == 1
            DataTmp = TableDemand_Min;
        else
            DataTmp = TableDemandTotal;
        end
        if ~isempty(DataTmp)
            for i = 1:length(DataTmp(:,1))
                for j = 1:length(DataTmp(1,:))
                    T = DataTmp{i,j};
                    if ~isempty(T)
                        Data{i,j} = T;
                    end
                end
            end
            UserData.DataMining = Data;
        end
    end
else
    errordlg('Estimate Mining Demand - False!!','!! Error !!')
end

function NameProject_Callback(hObject, eventdata, handles)
% hObject    handle to NameProject (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NameProject as text
%        str2double(get(hObject,'String')) returns contents of NameProject as a double


% --- Executes during object creation, after setting all properties.
function NameProject_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NameProject (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on selection change in Type_P.
function Type_P_Callback(hObject, eventdata, handles)
% hObject    handle to Type_P (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Type_P contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Type_P


% --- Executes during object creation, after setting all properties.
function Type_P_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Type_P (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ScenariosRun.
function ScenariosRun_Callback(hObject, eventdata, handles)
% hObject    handle to ScenariosRun (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global UserData
if isfield(UserData,'Scenarios')
    Data    = {};
    [DataTmp, Tmp]= TableScenarios(UserData.Scenarios, num2str(UserData.SceRef));
    for i = 1:length(DataTmp(:,1))
        for j = 1:length(DataTmp(1,:))
            T = DataTmp{i,j};
            if ~isempty(T)
                Data{i,j} = T;
            end
        end
    end
    UserData.Scenarios  = Data;
    UserData.SceRef     = str2num(Tmp);
else
    Data    = {};
    [DataTmp, Tmp] = TableScenarios;
    for i = 1:length(DataTmp(:,1))
        for j = 1:length(DataTmp(1,:))
            T = DataTmp{i,j};
            if ~isempty(T)
                Data{i,j} = T;
            end
        end
    end
    UserData.Scenarios  = Data;
    UserData.SceRef     = str2num(Tmp);
end


% --- Executes on button press in Agri_checkbox.
function Agri_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to Agri_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Agri_checkbox


% --- Executes on button press in Dom_checkbox.
function Dom_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to Dom_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Dom_checkbox


% --- Executes on button press in Liv_checkbox.
function Liv_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to Liv_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Liv_checkbox


% --- Executes on button press in Hy_checkbox.
function Hy_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to Hy_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Hy_checkbox


% --- Executes on button press in Min_checkbox.
function Min_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to Min_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Min_checkbox


% --- Executes on button press in Returns_checkbox.
function Returns_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to Returns_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Returns_checkbox


% --- Executes on button press in LoadData_Returns.
function LoadData_Returns_Callback(hObject, eventdata, handles)
% hObject    handle to LoadData_Returns (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in Est_Return.
function Est_Return_Callback(hObject, eventdata, handles)
% hObject    handle to Est_Return (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Est_Return contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Est_Return


% --- Executes during object creation, after setting all properties.
function Est_Return_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Est_Return (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function HUA_Callback(hObject, eventdata, handles)
% hObject    handle to HUA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of HUA as text
%        str2double(get(hObject,'String')) returns contents of HUA as a double


% --- Executes during object creation, after setting all properties.
function HUA_CreateFcn(hObject, eventdata, handles)
% hObject    handle to HUA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function DEM_Callback(hObject, eventdata, handles)
% hObject    handle to DEM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DEM as text
%        str2double(get(hObject,'String')) returns contents of DEM as a double


% --- Executes during object creation, after setting all properties.
function DEM_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DEM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function StreamFlow_Callback(hObject, eventdata, handles)
% hObject    handle to StreamFlow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of StreamFlow as text
%        str2double(get(hObject,'String')) returns contents of StreamFlow as a double


% --- Executes during object creation, after setting all properties.
function StreamFlow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to StreamFlow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Gauges_Callback(hObject, eventdata, handles)
% hObject    handle to Gauges (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Gauges as text
%        str2double(get(hObject,'String')) returns contents of Gauges as a double


% --- Executes during object creation, after setting all properties.
function Gauges_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Gauges (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Pcp_Callback(hObject, eventdata, handles)
% hObject    handle to Pcp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Pcp as text
%        str2double(get(hObject,'String')) returns contents of Pcp as a double


% --- Executes during object creation, after setting all properties.
function Pcp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Pcp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function T_Callback(hObject, eventdata, handles)
% hObject    handle to T (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of T as text
%        str2double(get(hObject,'String')) returns contents of T as a double


% --- Executes during object creation, after setting all properties.
function T_CreateFcn(hObject, eventdata, handles)
% hObject    handle to T (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ParamsM_Callback(hObject, eventdata, handles)
% hObject    handle to ParamsM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ParamsM as text
%        str2double(get(hObject,'String')) returns contents of ParamsM as a double


% --- Executes during object creation, after setting all properties.
function ParamsM_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ParamsM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Est_Agri.
function Agri_Est_Callback(hObject, eventdata, handles)
% hObject    handle to Est_Agri (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Est_Agri contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Est_Agri


% --- Executes during object creation, after setting all properties.
function Agri_Est_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Est_Agri (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
