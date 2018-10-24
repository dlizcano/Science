function [ETP] = Hydroquebec(Tmax,Tmin)
% Formulation Hydro-Québec, insérée dans HSAMI et Hydrotel
ETP = 0.029718.*(max(0,Tmax)-max(0,Tmin)).*exp(0.019*((9/5).*(max(0,Tmax)+max(0,Tmin))+64)); % en mm/j
end