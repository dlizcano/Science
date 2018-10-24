function [Vol, varargout] = Footprint(Hp, DEM, varargin)
% -------------------------------------------------------------------------
% /usr/bin/Matlab-R2016b
% -------------------------------------------------------------------------
% TIR-1
% -------------------------------------------------------------------------
% BASE DATA 
% -------------------------------------------------------------------------
% Author            : Jonathan Nogales Pimentel
% Email             : Jonathan.nogales@tnc.org
% Company           : The Nature Conservancy - TNC
% 
% Please do not share without permision of the autor
% -------------------------------------------------------------------------
% Description 
% -------------------------------------------------------------------------
%
% -------------------------------------------------------------------------
% License
% -------------------------------------------------------------------------
% This program is free software: you can redistribute it and/or modify it 
% under the terms of the GNU General Public License as published by the 
% Free Software Foundation, either version 3 of the License, or option) any 
% later version. This program is distributed in the hope that it will be 
% useful, but WITHOUT ANY WARRANTY; without even the implied warranty of 
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
% ee the GNU General Public License for more details. You should have 
% received a copy of the GNU General Public License along with this program.  
% If not, see http://www.gnu.org/licenses/.
%
% -------------------------------------------------------------------------
% INPUTS DATA
% -------------------------------------------------------------------------
% UserData [Struct]
% -------------------------------------------------------------------------
% OUTPUTS DATA
% -------------------------------------------------------------------------

nargoutchk(1, 3)

if length(varargin{1}) > 1
    nargin = 2 + length(varargin{1});
    varargin = varargin{1};    
end

Cal_H = 0;
if ~isa(DEM, 'GRIDobj'), error('The DEM do not is one GRIDobj'), end

if nargin == 2
    % 
    FlowDir     = FLOWobj(DEM);
    %
    FlowAccum   = FlowDir.flowacc;
    
    
elseif (nargin == 3) && ~isempty(varargin{1})
    
    FlowDir = varargin{1};
    %
    if ~isa(FlowDir, 'FLOWobj'), error('The DEM do not is one GRIDobj'), end
    %
    FlowAccum   = FlowDir.flowacc;
    
elseif nargin == 4 && (~isempty(varargin{1}))  && (~isempty(varargin{2}))
    
    FlowDir     = varargin{1};
    FlowAccum   = varargin{2};
    
    if ~isa(FlowDir, 'FLOWobj'), error('The DEM do not is one GRIDobj'), end
    if ~isa(FlowAccum, 'GRIDobj'), error('The DEM do not is one GRIDobj'), end

elseif nargin > 4 
    
    FlowDir     = varargin{1};
    FlowAccum   = varargin{2};
    
    if ~isa(FlowDir, 'FLOWobj'), error('The DEM do not is one GRIDobj'), end
    if ~isa(FlowAccum, 'GRIDobj'), error('The DEM do not is one GRIDobj'), end
    
    Cal_H = 1;
    
    NameArea    = cell(1, 22) ;
    NameArea{1} = 'Id_Area';
    
    Vp          = [0, 5:5:100]';
    for i = 1:21
        NameArea{i + 1} = ['HigthDam_', num2str(Vp(i))];
    end
    
    for i = 5:nargin
        
        if ~isa(varargin{i - 2}, 'struct'), error('The DEM do not is one GRIDobj'), end
        eval(['Area_', num2str(i - 4),' = varargin{', num2str(i - 2),'};'])
    end
    
    TableH = array2table(repmat((0:nargin-5)', 1,22) ,'VariableNames',NameArea);
    
end

if ~exist('FlowDir')
    FlowDir     = FLOWobj(DEM);
end

if ~exist('FlowAccum')
    FlowAccum   = FlowDir.flowacc;
end

clearvars varargin

%%
if Cal_H == 1
    x           = linspace(DEM.georef.SpatialRef.XWorldLimits(1), DEM.georef.SpatialRef.XWorldLimits(2),DEM.size(2));
    y           = linspace(DEM.georef.SpatialRef.YWorldLimits(2), DEM.georef.SpatialRef.YWorldLimits(1),DEM.size(1));
    [x, y]      = meshgrid(x,y);
    x           = reshape(x,[],1);
    y           = reshape(y,[],1);
end

%% Parameters 
Vp          = [0, 0.05:0.05:1]';
TableC      = array2table(repmat(Vp,1,3),'VariableNames',{'Higth','Area','Volumen'});
Curve_H     = cell(length(Vp),1);

%%
[IX,~]  = coord2ind(DEM, Hp.Coor_X(Hp.Scenario), Hp.Coor_Y(Hp.Scenario));
W       = FlowAccum > 50;
[IXc,~] = snap2stream(W,IX);

%%
HigthPosi = zeros(length(IXc),1);
for i = 1:length(IXc)
    HigthPosi(i)   = DEM.Z(IXc(i));
end

cellsize = DEM.cellsize;

%%
Basin   = drainagebasins(FlowDir, IXc);

z       = DEM.Z( Basin.Z ~= 0 );
if Cal_H == 1
    x       = x( Basin.Z ~= 0 );
    y       = y( Basin.Z ~= 0 );
end

Basin.Z = Basin.Z( Basin.Z ~= 0 );

clearvars DEM FlowDir FlowAccum W

%%
PosiID  = find(Hp.Scenario);
Vol     = zeros(length(Hp.TotalVolumen),1);
for i = 1:length(IXc)

    %
    Zp          = z( Basin.Z == i );
    
    if Cal_H == 1
        %
        Xp          = x( Basin.Z == i ); 
        %
        Yp          = y( Basin.Z == i );
    end
    
    for j = 2:length(Vp)
        
        HigthDamVp = (Vp(j)*Hp.HigthDam(PosiID(i)));
        
        id           = Zp <= ( HigthPosi(i) + HigthDamVp);
        
        TableC.Higth(j)     =  HigthDamVp;
        TableC.Area(j)      =  sum(id)*(cellsize.^2);
        TableC.Volumen(j)   =  double(nansum( (( HigthPosi(i) + HigthDamVp) - Zp(id))*(cellsize.^2) ));
        
    end
    
    % Volumen
    Vol(i) = TableC.Volumen(length(Vp));
    
    if Cal_H == 1
        for k =  5:nargin
            eval(['ID_H = inpolygon(Xp(id), Yp(id), Area_', num2str(k - 4),'.X, Area_', num2str(k - 4),'.Y);'])

%                 TableH.Area     = sum(ID_H)*(cellsize.^2);
            eval(['TableH.HigthDam_', num2str(Vp(j)*100),'(',num2str(i),') = sum(ID_H)*(cellsize.^2);'])
        end
    end
           
    Curve_H{i} = TableC;
    
end

if Cal_H == 1
    if nargout >1
        varargout{1} = Curve_H;
    end
end

