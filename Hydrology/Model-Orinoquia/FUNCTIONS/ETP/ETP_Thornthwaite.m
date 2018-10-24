function ETP = ETP_Thornthwaite(T)
% -------------------------------------------------------------------------
% Matlab Version - R2016b 
% -------------------------------------------------------------------------
%                              BASE DATA 
%--------------------------------------------------------------------------
%
% Project       : Landscape planning for agro-industrial expansion 
%                 in a large, well-preserved savanna: how to plan 
%                 multifunctional landscapes at scale for nature 
%                 and people in the Orinoquia region, Colombia
% Author        : Jonathan Nogales Pimentel
% Email         : jonathannogales02@gmail.com
% Occupation    : Hydrology Specialist
% Company       : The Nature Conservancy - TNC
% Date          : November, 2017
%
%--------------------------------------------------------------------------
% This program is free software: you can redistribute it and/or modify it 
% under the terms of the GNU General Public License as published by the 
% Free Software Foundation, either version 3 of the License, or option) any 
% later version. This program is distributed in the hope that it will be 
% useful, but WITHOUT ANY WARRANTY; without even the implied warranty of 
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
% ee the GNU General Public License for more details. You should have 
% received a copy of the GNU General Public License along with this program
% If not, see http://www.gnu.org/licenses/.
%--------------------------------------------------------------------------
%                               DESCRIPTION 
%--------------------------------------------------------------------------
%
% This function estimates of the potential evapotranspiration through the 
% Thornthwaite equation.
%
%--------------------------------------------------------------------------
%                               INPUT DATA 
%--------------------------------------------------------------------------
%
%   T   [n,1] = Vector of the Monthly Average Temperature [Celsius Degrees]
%
%--------------------------------------------------------------------------
%                               OUTPUT DATA 
%--------------------------------------------------------------------------
%
%   ETP [n,1] = Potential Evapotrasnpiration [mm]
% 
%--------------------------------------------------------------------------
%                               REFERENCES 
%--------------------------------------------------------------------------
%
% Thornthwaite, C.W., and J.R. Mather. Instructions and Tables for Computing 
% Potential Evapotranspiration and the Water Balance. Drexel Institute of
% Technology, Laboratory of Climatology, Publications in Climatology 
% 10(3), 311 pp. (1957).
%

%% Estimate of the Potential Evapotranspiration
T(T<0.1)    = 0.1;
I           = 12*((T/5).^1.514);
a           = ((675E-9).*(I.^3)) - ((771E-7).*(I.^2)) + ((179.2E-4).*I) + 0.49239;
ETP         = 16*(((10*T)./I).^a);
end