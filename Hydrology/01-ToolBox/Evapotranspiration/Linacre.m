function [ETP] = Linacre(z,Lat,Tmean,Td)
% Linacre (1977) - RH, T
Th = Tmean+0.006*z;
ETP = (((500*Th)./(100-Lat))+15.*(Tmean-Td))./(80-Tmean); % en mm/j
ETP = max(0,ETP);
end

% CEMAGREF
%Th = Ta+0.006*z;
%ETP = (((500*Th)./(100-Lat))+15.*(Ta-Td))./(80-Ta); % en mm/j
%ETP = max(0,ETP);

% Linacre (1977)
% For a wall watered vegetation with an albedo of 0.25
%Th = Ta+0.006*z;
%ETP = (((500*Th)./(100-Lat))+15.*(Ta-Td))./(80-Ta); % en mm/j
%ETP = max(0,ETP);
%
% For the case of water (albedo of 0.05)
%Th = Ta+0.006*z;
%ETP = (((700*Th)./(100-Lat))+15.*(Ta-Td))./(80-Ta); % en mm/j
%ETP = max(0,ETP);