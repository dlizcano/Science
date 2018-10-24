function varargout = Guide_Atmosphere(varargin)
% GUIDE_ATMOSPHERE MATLAB code for Guide_Atmosphere.fig
%      GUIDE_ATMOSPHERE, by itself, creates a new GUIDE_ATMOSPHERE or raises the existing
%      singleton*.
%
%      H = GUIDE_ATMOSPHERE returns the handle to a new GUIDE_ATMOSPHERE or the handle to
%      the existing singleton*.
%
%      GUIDE_ATMOSPHERE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUIDE_ATMOSPHERE.M with the given input arguments.
%
%      GUIDE_ATMOSPHERE('Property','Value',...) creates a new GUIDE_ATMOSPHERE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Guide_Atmosphere_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Guide_Atmosphere_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Guide_Atmosphere

% Last Modified by GUIDE v2.5 08-Sep-2018 10:51:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Guide_Atmosphere_OpeningFcn, ...
                   'gui_OutputFcn',  @Guide_Atmosphere_OutputFcn, ...
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


% --- Executes just before Guide_Atmosphere is made visible.
function Guide_Atmosphere_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Guide_Atmosphere (see VARARGIN)

% Choose default command line output for Guide_Atmosphere
handles.output = hObject;

% -------------------------------------------------------------------------
% Precipitation
axes(handles.Axes_Pcp)
Logo = imread('Pcp.png');
image(Logo);
axis off

% Temperature 
axes(handles.Axes_T)
Logo = imread('T.png');
image(Logo);
axis off

% Evapotranspiration 
axes(handles.Axes_ETP)
Logo = imread('ET.jpg');
image(Logo);
axis off

% -------------------------------------------------------------------------

% Update handles structure
guidata(hObject, handles);

global UserData
global Data

Data = struct;
Data.Pcp    = 0;
Data.T      = 0;
Data.ETP    = 0;

if nargin > 3
    % Project Path
    UserData = varargin{1};
else
    
end

% UIWAIT makes Guide_Atmosphere wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Guide_Atmosphere_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
% varargout{1} = handles.output;


% --- Executes on button press in Button_Pcp.
function Button_Pcp_Callback(hObject, eventdata, handles)

global Data

[FileName,PathName] = uigetfile('*.csv');

if PathName ~= 0
    
    Tmp = dlmread(fullfile(PathName,FileName),',',1);
    if (length(Tmp(1,:)) < 2) || (length(Tmp(1,:)) > 2)
        errordlg('The File has more than two columns or only one','!! Error !!')
    else
        Data.Pcp = Tmp;
    end
    
    %% Operation Completed
    [Icon,~] = imread('Completed.jpg'); 
    msgbox('Operation Completed','Success','custom',Icon);

else
    
    %% Operation Completed
    errordlg('The File not load','!! Error !!')

end


% --- Executes on button press in Button_T.
function Button_T_Callback(hObject, eventdata, handles)

global Data

[FileName,PathName] = uigetfile('*.csv');

if PathName ~= 0
    
    Tmp = dlmread(fullfile(PathName,FileName),',',1);
    if (length(Tmp(1,:)) < 2) || (length(Tmp(1,:)) > 2)
        errordlg('The File has more than two columns or only one','!! Error !!')
    else
        Data.T = Tmp;
    end
    
    %% Operation Completed
    [Icon,~] = imread('Completed.jpg'); 
    msgbox('Operation Completed','Success','custom',Icon);
     
    %% Operation Completed
    [Icon,~] = imread('Completed.jpg'); 
    msgbox('Operation Completed','Success','custom',Icon);

else
    
    %% Operation Completed
    errordlg('The File not load','!! Error !!')

end

% --- Executes on button press in Button_ETP.
function Button_ETP_Callback(hObject, eventdata, handles)

global Data

[FileName,PathName] = uigetfile('*.csv');

if PathName ~= 0
    
    Tmp = dlmread(fullfile(PathName,FileName),',',1);
    if (length(Tmp(1,:)) < 2) || (length(Tmp(1,:)) > 2)
        errordlg('The File has more than two columns or only one','!! Error !!')
    else
        Data.ETP = Tmp;
    end
     
    %% Operation Completed
    [Icon,~] = imread('Completed.jpg'); 
    msgbox('Operation Completed','Success','custom',Icon);

else
    
    %% Operation Completed
    errordlg('The File not load','!! Error !!')

end

% --- Executes on button press in Button_Save.
function Button_Save_Callback(hObject, eventdata, handles)
global UserData
global Data

Results = [Date Values];
Results = array2table(Results,'VariableNames',NameBasin,'RowNames',NameDate);

writetable(Results, fullfile(UserData.PathProject,'RESULTS','P',['Pcp_Scenario-',num2str(i),'.dat']), 'WriteRowNames',true)
                

close(gcf)

% --- Executes on button press in Button_Cancel.
function Button_Cancel_Callback(hObject, eventdata, handles)

close(gcf)
