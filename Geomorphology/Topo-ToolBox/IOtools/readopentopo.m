function DEM = readopentopo(varargin)

%READOPENTOPO read DEM using the opentopography.org API
%
% Syntax
%
%     DEM = readopentopo(pn,pv,...)
%
% Description
%
%     readopentopo reads DEMs from opentopography.org using the API
%     described on:
%     http://www.opentopography.org/developers
%     The DEM comes in geographic coordinates (WGS84) and should be
%     projected to a projected coordinate system (use reproject2utm) before
%     analysis in TopoToolbox.
%
% Input arguments
%
%     Parameter name values
%     'filename'       provide filename. By default, the function will save
%                      the DEM to a temporary file in the system's temporary 
%                      folder.
%     'north'          northern boundary in geographic coordinates (WGS84)
%     'south'          southern boundary
%     'west'           western boundary
%     'east'           eastern boundary
%     'demtype'        The global raster dataset - SRTM GL3 (90m) is 
%                      'SRTMGL3' (default), SRTM GL1 (30m) is 'SRTMGL1',  
%                      SRTM GL1 (Ellipsoidal) is 'SRTMGL1_E', ALOS World 3D 
%                      30m is 'AW3D30', and ALOS World 3D (Ellipsoidal) is 
%                      'AW3D30_E'.
%     'verbose'        {true} or false. If true, then some information on
%                      the process is shown in the command window
%     'deletefile'     {true} or false. True, if file should be deleted
%                      after it was downloaded and added to the workspace.
% 
% Output arguments
%
%     DEM            Digital elevation model in geographic coordinates
%                    (GRIDobj)
%
% See also: GRIDobj, websave
%
% Reference: http://www.opentopography.org/developers
%
% Author: Wolfgang Schwanghart (w.schwanghart[at]geo.uni-potsdam.de)
% Date: 19. June, 2017


p = inputParser;
addParameter(p,'filename',[tempname '.tif']);
addParameter(p,'interactive',false);
addParameter(p,'north',37.091337);
addParameter(p,'south',36.738884);
addParameter(p,'west',-120.168457);
addParameter(p,'east',-119.465576);
addParameter(p,'demtype','SRTMGL3');
addParameter(p,'deletefile',true);
addParameter(p,'verbose',true);
parse(p,varargin{:});

demtype = validatestring(p.Results.demtype,{'SRTMGL3','SRTMGL1','SRTMGL1_E','AW3D30','AW3D30_E'},'readopentopo');

url = 'http://opentopo.sdsc.edu/otr/getdem';

% create output file
f = fullfile(p.Results.filename);
    

% save to drive
options = weboptions('Timeout',100000);

west = p.Results.west;
east = p.Results.east;
south = p.Results.south;
north = p.Results.north;

if any([isempty(west) isempty(east) isempty(south) isempty(north)]) || p.Results.interactive
    wm = webmap;
    % get dialog box
    messagetext = ['Zoom and resize the webmap window to choose DEM extent. ' ...
                         'Click the close button when you''re done.'];
    d = waitdialog(messagetext);
    uiwait(d);    
    [latlim,lonlim] = wmlimits(wm);
    west = lonlim(1);
    east = lonlim(2);
    south = latlim(1);
    north = latlim(2);
end
    
if p.Results.verbose
    a = areaint([south south north north],...
                [west east east west],almanac('earth','radius','kilometers'));
    disp('-------------------------------------')
    disp('readopentopo process:')
    disp(['DEM type: ' demtype])
    disp(['API url: ' url])
    disp(['Local file name: ' f])
    disp(['Area: ' num2str(a,2) ' sqkm'])
    disp('-------------------------------------')
    disp(['Starting download: ' datestr(now)])
end

% Download with websave
outfile = websave(f,url,'west',west,...
              'east',east,...
              'north',north,...
              'south',south,...
              'outputFormat', 'GTiff', ...
              'demtype', demtype, ...
              options);

if p.Results.verbose
    disp(['Download finished: ' datestr(now)])
    disp(['Reading DEM: ' datestr(now)])
end

try
    warning off
    DEM      = GRIDobj(f);
    warning on
    
    msg = lastwarn;
    if ~isempty(msg)
        disp(' ')
        disp(msg)
        disp(' ')
    end
    
    DEM.name = demtype;
    if p.Results.verbose
        disp(['DEM read: ' datestr(now)])
    end
    
catch
    % Something went wrong. See whether we can derive some information.
    fid = fopen(outfile);
    in = textscan(fid,'%c');
    disp('Could not retrieve DEM. This is the message returned by opentopography API:')
    disp([in{1}]')
    disp('readopentopo returns empty array')
    fclose(fid);
    DEM = [];
end
    

if p.Results.deletefile
    delete(f);
    if p.Results.verbose
        disp('Temporary file deleted')
    end
end

if p.Results.verbose
    disp(['Done: ' datestr(now)])
    disp('-------------------------------------')
end
end

function d = waitdialog(messagetext)
    d = dialog('Position',[300 300 250 150],'Name','Choose rectangle region',...
        'WindowStyle','normal');

    txt = uicontrol('Parent',d,...
               'Style','text',...
               'Position',[20 80 210 40],...
               'String',messagetext);

    btn = uicontrol('Parent',d,...
               'Position',[85 20 70 25],...
               'String','Close',...
               'Callback','delete(gcf)');
end


