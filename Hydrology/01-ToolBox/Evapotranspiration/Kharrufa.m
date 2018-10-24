function [ETP] = Kharrufa(DL,Tmean)
% Kharrufa (1985) - T
p = 100*DL/(365*12); % en % journalier
k = 0.34; % Coeff empirique Kharrufa
ETP = k.*p.*(max(0,Tmean).^(1.3)) ;% en mm/j
ETP = max(0,ETP);
end