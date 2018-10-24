function Scenarios = RandomScenarios(obj, ProjectID, ThresholdComb)
% -------------------------------------------------------------------------
% /usr/bin/Matlab-R2016b
% -------------------------------------------------------------------------
% TIR-1
% -------------------------------------------------------------------------
% BASE DATA 
% -------------------------------------------------------------------------
% Author            : Hector Angarita  
% Email             : flector@gmail.com
% Modified by       : Jonathan Nogales Pimentel - Jonathan.nogales@tnc.org
%                     Carlos Andres Rogéliz - carlos.rogeliz@tnc.org
% Company           : The Nature Conservancy - TNC
% 
% Please do not share without permision of the autor
% -------------------------------------------------------------------------
% Description 
% -------------------------------------------------------------------------
%
% Funcion para Generacion de Combinaciones de Proyectos
% Realiza todas las combinaciones posibles de Proyectos si no se supera el
% parametro m�ximo definido, de lo contrario, selecciona los proyectos del
% escenario con seleccion aleatoria de manera uniforme en todos los rangos
% de combinacion
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
% - ProjectID: Vector de n filas con los proyectos a combinar
%   * Columna 1: ProjectID que hacen parte del escenario para combinacion
% - LB_Projects: Vector de n filas x 2 columnas con los proyectos que hacen parte de la Linea base
%   * Columna 1: ProjectID de la totalidad de proyectos considerados
%   * Columna 2: 0 para proyectos no considerados en l�nea base. 1 para
%   proyectos considerados en l�nea base
% - ThresholdComb: N�mero m�ximo de combinaciones a realizar
% UserData [Struct]
%
% -------------------------------------------------------------------------
% OUTPUTS DATA
% -------------------------------------------------------------------------

NumProj = length(ProjectID);
NumComb = zeros(NumProj,1);

for k = 1:length(ProjectID)
    NumComb(k) = factorial(NumProj) / (factorial(k)*factorial(NumProj-k));
end

TotalComb = sum(NumComb(isnan(NumComb)==0));
% Generacion de Combinacion de proyectos para Escenario

Cont = 1;
if (TotalComb < ThresholdComb)
    
    % Configura todas las combinaciones de proyectos posibles sin repetici�n
    Scenarios      = zeros(NumProj, TotalComb + 1);
    
    for i = 1:length(ProjectID)
        
        Selection = nchoosek(ProjectID, i);
        
        for w = 1:size(Selection,1)
            for z = 1:size(Selection,2)
                Scenarios( (ProjectID == Selection(w,z)) ,Cont) = 1;
            end
            Cont = Cont + 1;
        end
    end
    
else
    
    MissingComb     = ThresholdComb;
    Scenarios       = zeros(NumProj, ThresholdComb + 1);
    NumSceProj      = length(ProjectID); 
    Cont            = 1; 
    
    while (MissingComb > 0)
        % Generación aleatoria
        SeedRandom  = rand();
        PreRandom   = rand(NumSceProj,1);
        ProjRandom  = zeros(NumSceProj,1);
        
        for i = 1:length(PreRandom)
            if PreRandom(i) > SeedRandom
                ProjRandom(i) = 1;
            end
        end
        
        %verifica si la generaci�n aleatoria ya se encuentra
        %como escenario. Evita repetir Scenarios!
        check1  = 0;
        [~,Col] = size(Scenarios);
        
        for w = 1:Col
            if (length(find(Scenarios(:,w) == ProjRandom)) == NumSceProj)
                check1 = 1;
                break
            end
        end
        
        if (check1 == 0)
            Scenarios(:,Cont) = ProjRandom;
            Cont     = Cont + 1;
            MissingComb = MissingComb - 1;
        end
        
    end
end

Scenarios = logical( Scenarios);