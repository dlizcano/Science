function Error = FunObj(Params, UserData)
% -------------------------------------------------------------------------
% /usr/bin/Matlab-R2016b
% -------------------------------------------------------------------------
% P-Q Model
% -------------------------------------------------------------------------
% BASE DATA 
% -------------------------------------------------------------------------
% Author            : Jonathan Nogales Pimentel - Jonathan.nogales@tnc.org
%                     Carlos Andres Rogéliz - carlos.rogeliz@tnc.org
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
% Params 
% UserData
% -------------------------------------------------------------------------
% OUTPUTS DATA
% -------------------------------------------------------------------------
% Error 

% Assignation of Factor for ETR
% n       = Params(1);
% Parameter
% Re      = UserData.ETR(UserData.ID)./UserData.PT(UserData.ID);
% Alfa    = (1 + (Re.^(-n))).^(-1/n);
% Runoff (mm) 
% Esc     = UserData.PT(UserData.ID) - ( Alfa .* UserData.PT(UserData.ID));
Esc     = UserData.PT(UserData.ID) - ( UserData.ETR(UserData.ID).* Params(1) );
% Streamflow (m3/seg)
Q       = ((Esc/1000).*UserData.Area(UserData.ID))/(3600*24*365);
% Absolut Error (m3/seg) 
Error   = abs(UserData.Qobs - sum(Q));