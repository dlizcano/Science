function [Pi] = PrecipitationFields(X, Y, P, Xi, Yi)
% This function Performs the generation of precipitation fields through the
% interpolation methodology by Kriging.
%--------------------------------------------------------------------------
% BASE DATA 
%--------------------------------------------------------------------------
% Project               : Landscape planning for agro-industrial expansion 
%                         in a large, well-preserved savanna: how to plan 
%                         multifunctional landscapes at scale for nature 
%                         and people in the Orinoquia region, Colombia
% Author                : Jonathan Nogales Pimentel
% Email                 : nogales02@hotmail.com
% Hydrology Specialist  : Carlos Andrés Rogéliz
% Company               : The Nature Conservancy - TNC
%
%--------------------------------------------------------------------------
% Copyright (C) 2017 Apox Technologies
% This program is free software: you can redistribute it and/or modify it 
% under the terms of the GNU General Public License as published by the 
% Free Software Foundation, either version 3 of the License, or option) any 
% later version. This program is distributed in the hope that it will be 
% useful, but WITHOUT ANY WARRANTY; without even the implied warranty of 
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
% ee the GNU General Public License for more details. You should have 
% received a copy of the GNU General Public License along with this program
% 
%--------------------------------------------------------------------------
% INPUT DATA
%--------------------------------------------------------------------------
% Data required for the construction of the semivarigram.
%   X   -> Vector coordinates on the X axis of the base data [n, 1]
%   Y   -> Vector coordinates on the Y axis of the base data [n, 1]
%   P   -> Vector precipitation at each point X, Y [n, 1]
%
% Coordinates of the points to interpolate.
%   Xi  -> Vector coordinates on the Xi axis of the data to interpolate [n, 1]
%   Yi  -> Vector coordinates on the Yi axis of the data to interpolate [n, 1]
%
%--------------------------------------------------------------------------
% OUTPUT DATA
%--------------------------------------------------------------------------
%   Zi  -> Precipitation interpolate in the points of coordinates Xi & Yi [n, 1]

%%
% Verication of input data.
if nargin < 5, error('Not enough input arguments'), end 

%% PARAMETERS 
% Semivariograms models to evaluate
Models      = {'circular','spherical','pentaspherical','exponential','gaussian'};

%% Construction of the emperic semivariogram 
id          = isnan(P) == 0;
v           = variogram([X(id) Y(id)], P(id),'plotit',false, 'nrbins',length(P(id)));
Distance    = v.distance;
Value       = v.val;

%% Select best Models 
Error       = NaN(length(Models),1);
parfor i    = 1:length(Models)
    % Contruction Teoric Semivariogram
    Error(i) = variogramfit(Distance,Value,[],[],[],'model',Models{i}); 
end

%% Best model
[~,vstruct] = variogramfit(Distance,Value,[],[],[],'model',...
                  Models{find(Error == nanmax(Error))});
              

%% Interpolation
if length(X(id)) > 500000
    Chunksize   =  500000;
    [Pi,~]      = kriging(vstruct, X(id), Y(id), P(id), Xi, Yi, Chunksize);
else
    Chunksize   = length(X(id));
    [Pi,~]      = kriging(vstruct, X(id), Y(id), P(id), Xi, Yi, Chunksize);
end

end
