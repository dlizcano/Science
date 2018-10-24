function Pcom = ProporcionNormal(P)
% OBJETIVO
% Complemntacion de datos faltantes por Proporcion Normal con datos de la misma estacion
% a resolucion Mensual 
%
%% DATOS BASICOS
% Nombre: Jonathan Nogales Pimentel
% 
%% DATOS DE ENTRADA 
% P 	: Precipitacion pivot (mm/mes)
%
%% DATOS DE SALIDA
% Pcom 	: Precipitacion Complementada (mm/mes)
%
%% PROPORCION NORMAL
Pcom = P;
[fil,~] = find(isnan(P));
fil = unique(sort(fil));
for i = 1:length(fil)
    [~,col] = find(isnan(P(fil(i),:)));
    n = length(col);
    k = 1;
    B = -1*ones(n,n);
    Xj = nansum(P(fil(i),:),2);
    Pa = nanmean(sum(P,2));
    for j = 1:length(col)
        Ni = nanmean(P(:,col(j)));
        % Matriz
        B(k,k) = ((Pa/Ni) - 1);
        k = k + 1;
    end
    X = inv(B)*repmat(Xj,[n,1]);
    Pcom(fil(i),col) = X;
end
