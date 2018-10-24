function varargout = TableParams(varargin)
% TABLEPARAMS1 MATLAB code for TableParams1.fig
%      TABLEPARAMS1, by itself, creates a new TABLEPARAMS1 or raises the existing
%      singleton*.
%
%      H = TABLEPARAMS1 returns the handle to a new TABLEPARAMS1 or the handle to
%      the existing singleton*.
%
%      TABLEPARAMS1('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TABLEPARAMS1.M with the given input arguments.
%
%      TABLEPARAMS1('Property','Value',...) creates a new TABLEPARAMS1 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before TableParams_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to TableParams_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help TableParams1

% Last Modified by GUIDE v2.5 17-Feb-2018 09:01:13

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @TableParams_OpeningFcn, ...
                   'gui_OutputFcn',  @TableParams_OutputFcn, ...
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


% --- Executes just before TableParams1 is made visible.
function TableParams_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to TableParams1 (see VARARGIN)

% Choose default command line output for TableParams1
handles.output = hObject;

% Update1 handles structure
guidata(hObject, handles);

% UIWAIT makes TableParams1 wait for user response (see UIRESUME)
% uiwait(handles.figure1);

global UserData
if nargin > 3
    UserData    = varargin{1};
    try
        load(fullfile(UserData.PathProject,'PARAMETERS','Params.mat'))
        set(handles.TableParams1,'Data',[BasinCode,BasinArea,TypeBasinCal,IDAq,Arc_InitNode,Arc_EndNode,Sw,Sg,a,b,c,d,ParamExtSup,ParamExtSub]);

        % Floodplains
        set(handles.TableParams2,'Data',BranchDownstream);

        % Floodplains
        set(handles.TableParams3,'Data',[ArcIDFlood, FloodArea, Vh,Trp,Tpr, Q_Umb, V_Umb]);

        % Streamflow Calibration
        set(handles.TableParams4,'Data',StreamflowCal);
        
        % Demand and Reurns
        set(handles.TableParams5,'Data', [IDExtAgri,IDExtDom,IDExtLiv, IDExtMin,IDExtHy, IDRetDom,IDRetLiv,IDRetMin,IDRetHy ]);

    catch
    end


end

% --- Outputs from this function are returned to the command line.
function varargout = TableParams_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
uiwait(gcf)



function BasinNumber1_Callback(hObject, eventdata, handles)
% hObject    handle to text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of text as text
%        str2double(get(hObject,'String')) returns contents of text as a double



% --- Executes during object creation, after setting all properties.
function BasinNumber1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BasinNumber1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function BasinNumber2_Callback(hObject, eventdata, handles)
% hObject    handle to text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of text as text
%        str2double(get(hObject,'String')) returns contents of text as a double



% --- Executes during object creation, after setting all properties.
function BasinNumber2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BasinNumber1 (see GCBO)
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


% --- Executes on button press in Update1.
function Update1_Callback(hObject, eventdata, handles)
% hObject    handle to Update1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Raw     = get(handles.TableParams1,'Data');
[fil,~] = size(Raw);
N       = str2num(get(handles.BasinNumber1,'String'));
if N > fil
    o = cell(N,14);
    o(1:fil,:) = Raw;
    set(handles.TableParams1,'Data',o)
else
    o = cell(N,14);
    o = Raw(1:N,:);
    set(handles.TableParams1,'Data',o)
end


% --- Executes on button press in Update1.
function Update2_Callback(hObject, eventdata, handles)
% hObject    handle to Update1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Raw     = get(handles.TableParams2,'Data');
[fil,~] = size(Raw);
N       = str2num(get(handles.BasinNumber2,'String'));
if N > fil
    o = cell(N,2);
    o(1:fil,:) = Raw;
    set(handles.TableParams2,'Data',o)
else
    o = cell(N,2);
    o = Raw(1:N,:);
    set(handles.TableParams2,'Data',o)
end


% --- Executes on button press in Update5.
function Update3_Callback(hObject, eventdata, handles)
% hObject    handle to Update5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Raw     = get(handles.TableParams3,'Data');
[fil,~] = size(Raw);
N       = str2num(get(handles.BasinNumber3,'String'));
if N > fil
    o = cell(N,7);
    o(1:fil,:) = Raw;
    set(handles.TableParams3,'Data',o)
else
    o = cell(N,7);
    o = Raw(1:N,:);
    set(handles.TableParams3,'Data',o)
end



% --- Executes on button press in Update4.
function Update4_Callback(hObject, eventdata, handles)
% hObject    handle to Update4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Raw     = get(handles.TableParams4,'Data');
[fil,~] = size(Raw);
N       = str2num(get(handles.BasinNumber4,'String'));
if N > fil
    o = cell(N,3);
    o(1:fil,:) = Raw;
    set(handles.TableParams4,'Data',o)
else
    o = cell(N,3);
    o = Raw(1:N,:);
    set(handles.TableParams4,'Data',o)
end


% --- Executes on button press in Update5.
function Update5_Callback(hObject, eventdata, handles)
% hObject    handle to Update5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Raw     = get(handles.TableParams5,'Data');
[fil,~] = size(Raw);
N       = str2num(get(handles.BasinNumber5,'String'));
if N > fil
    o = cell(N,9);
    o(1:fil,:) = Raw;
    set(handles.TableParams5,'Data',o)
else
    o = cell(N,9);
    o = Raw(1:N,:);
    set(handles.TableParams5,'Data',o)
end


% --- Executes on button press in Save.
function Save_Callback(hObject, eventdata, handles)
% hObject    handle to Save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global UserData
% Thomas Model
Tmp             = get(handles.TableParams1,'Data');
BasinCode       = Tmp(:,1);
BasinArea       = Tmp(:,2);
TypeBasinCal    = Tmp(:,3);   
IDAq            = Tmp(:,4);
Arc_InitNode    = Tmp(:,5);
Arc_EndNode     = Tmp(:,6);
Sw              = Tmp(:,7);
Sg              = Tmp(:,8);
a               = Tmp(:,9);
b               = Tmp(:,10);
c               = Tmp(:,11);
d               = Tmp(:,12);
ParamExtSup     = Tmp(:,13);
ParamExtSub     = Tmp(:,14);


% Floodplains
BranchDownstream    = get(handles.TableParams2,'Data');

% Floodplains
Tmp             = get(handles.TableParams3,'Data');
ArcIDFlood      = Tmp(:,1);
FloodArea       = Tmp(:,2);
Vh              = Tmp(:,3);
Trp             = Tmp(:,4);
Tpr             = Tmp(:,5);
Q_Umb           = Tmp(:,6);
V_Umb           = Tmp(:,6);

% Streamflow Calibration
StreamflowCal   = get(handles.TableParams4,'Data');

% Demand and Reurns
Tmp         = get(handles.TableParams5,'Data');
IDExtAgri   = Tmp(:,1);
IDExtDom    = Tmp(:,2);
IDExtLiv    = Tmp(:,3);
IDExtMin    = Tmp(:,4);
IDExtHy     = Tmp(:,5);

IDRetDom    = Tmp(:,6);
IDRetLiv    = Tmp(:,7);
IDRetMin    = Tmp(:,8);
IDRetHy     = Tmp(:,9);

save(fullfile(UserData.PathProject,'PARAMETERS','Params.mat'),...
    'BasinCode','BasinArea','IDAq','Sw','Sg','a','b','c','d','ParamExtSup', 'ParamExtSub',...
    'TypeBasinCal','BranchDownstream',...
    'ArcIDFlood','FloodArea','Vh','Trp','Tpr', 'Q_Umb', 'V_Umb',...
    'StreamflowCal',...
    'IDExtAgri','IDExtDom','IDExtLiv', 'IDExtMin','IDExtHy',...
    'IDRetDom','IDRetLiv','IDRetMin','IDRetHy',...
    'Arc_InitNode','Arc_EndNode');

close(gcf)

% --- Executes on button press in Cancel.
function Cancel_Callback(hObject, eventdata, handles)
% hObject    handle to Cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(gcf)

% --- Executes on button press in Load1.
function Load1_Callback(hObject, eventdata, handles)
% hObject    handle to Load1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[FileName,PathName] = uigetfile({'*.xlsx','*.xls'});
if FileName ~= 0
    [DataNum,~,Data]    = xlsread(fullfile(PathName, FileName));
    Data                = Data(2:length(DataNum(:,1))+1,1:14);

    set(handles.TableParams1,'Data',Data)
end


% --- Executes on button press in Load1.
function Load2_Callback(hObject, eventdata, handles)
% hObject    handle to Load1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[FileName,PathName] = uigetfile({'*.xlsx','*.xls'});
if FileName ~= 0
    [DataNum,~,Data]    = xlsread(fullfile(PathName, FileName));
    Data                = Data(2:length(DataNum(:,1))+1,1:2);

    set(handles.TableParams2,'Data',Data)
end


% --- Executes on button press in Load5.
function Load3_Callback(hObject, eventdata, handles)
% hObject    handle to Load5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[FileName,PathName] = uigetfile({'*.xlsx','*.xls'});
if FileName ~= 0
    [DataNum,~,Data]    = xlsread(fullfile(PathName, FileName));
    Data                = Data(2:length(DataNum(:,1))+1,1:7);

    set(handles.TableParams3,'Data',Data)
end


function BasinNumber3_Callback(hObject, eventdata, handles)
% hObject    handle to BasinNumber5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of BasinNumber5 as text
%        str2double(get(hObject,'String')) returns contents of BasinNumber5 as a double


% --- Executes during object creation, after setting all properties.
function BasinNumber3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BasinNumber5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function BasinNumber4_Callback(hObject, eventdata, handles)
% hObject    handle to BasinNumber4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of BasinNumber4 as text
%        str2double(get(hObject,'String')) returns contents of BasinNumber4 as a double


% --- Executes during object creation, after setting all properties.
function BasinNumber4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BasinNumber4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in Load4.
function Load4_Callback(hObject, eventdata, handles)
% hObject    handle to Load4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[FileName,PathName] = uigetfile({'*.xlsx','*.xls'});
if FileName ~= 0
    [DataNum,~,Data]    = xlsread(fullfile(PathName, FileName));
    Data                = Data(2:length(DataNum(:,1))+1,1:3);

    set(handles.TableParams4,'Data',Data)
end



function BasinNumber5_Callback(hObject, eventdata, handles)
% hObject    handle to BasinNumber5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of BasinNumber5 as text
%        str2double(get(hObject,'String')) returns contents of BasinNumber5 as a double


% --- Executes during object creation, after setting all properties.
function BasinNumber5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BasinNumber5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in Load5.
function Load5_Callback(hObject, eventdata, handles)
% hObject    handle to Load5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[FileName,PathName] = uigetfile({'*.xlsx','*.xls'});
if FileName ~= 0
    [DataNum,~,Data]    = xlsread(fullfile(PathName, FileName));
    Data                = Data(2:length(DataNum(:,1))+1,1:9);

    set(handles.TableParams5,'Data',Data)
end



function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to BasinNumber5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of BasinNumber5 as text
%        str2double(get(hObject,'String')) returns contents of BasinNumber5 as a double


% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BasinNumber5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% % --- Executes on button press in Update5.
% function pushbutton16_Callback(hObject, eventdata, handles)
% % hObject    handle to Update5 (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% 
% % --- Executes on button press in Load5.
% function pushbutton17_Callback(hObject, eventdata, handles)
% % hObject    handle to Load5 (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)



function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double


% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% % --- Executes on button press in pushbutton14.
% function pushbutton14_Callback(hObject, eventdata, handles)
% % hObject    handle to pushbutton14 (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% 
% % --- Executes on button press in pushbutton15.
% function pushbutton15_Callback(hObject, eventdata, handles)
% % hObject    handle to pushbutton15 (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)



function BasinNumber6_Callback(hObject, eventdata, handles)
% hObject    handle to BasinNumber6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of BasinNumber6 as text
%        str2double(get(hObject,'String')) returns contents of BasinNumber6 as a double


% --- Executes during object creation, after setting all properties.
function BasinNumber6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BasinNumber6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Update6.
function Update6_Callback(hObject, eventdata, handles)
% hObject    handle to Update6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Raw     = get(handles.TableParams6,'Data');
[fil,~] = size(Raw);
N       = str2num(get(handles.BasinNumber6,'String'));
if N > fil
    o = cell(N,3);
    o(1:fil,:) = Raw;
    set(handles.TableParams6,'Data',o)
else
    o = cell(N,3);
    o = Raw(1:N,:);
    set(handles.TableParams6,'Data',o)
end


% --- Executes on button press in Load6.
function Load6_Callback(hObject, eventdata, handles)
% hObject    handle to Load6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[FileName,PathName] = uigetfile({'*.xlsx','*.xls'});
if FileName ~= 0
    [DataNum,~,Data]    = xlsread(fullfile(PathName, FileName));
    Data                = Data(2:length(DataNum(:,1))+1,1:3);

    set(handles.TableParams6,'Data',Data)
end
