function [varargout] = RNA(Tp, userdata)
%        [W, FO, My, Graf] = RNA(Tp, userdata)
%% CALIBRACION DE UNA RED NEURONAL SIN CAPA OCULTA 
% Autor     :   Jonathan Nogales Pimentel
%               Andres Mauricio Salazar Andrade
% Email     :	nogales02@hotmail.com
%
%% OBJETIVO
% Este programa calibra una red neuronal sin capa oculta mediante la
% metodologia de reduccion del error cuadrado promedio 
%
%% DATOS DE ENTRADA
% Tp        :   Matriz de una columna por n+m filas que es la cantidad de patrones de
%               entrada y salida con los cuales se quiere calibrar la red  mas el
%               termino independiente 
% nepoch    :   Numero de epocas con la cual se quiere calibrar 
% alfa      :   Tasa de aprendizaje con la cual quiero que actualice los
%               parametros la red neuronal 
% n0        :   Numero de parametros de entrada
% Norm      :   Normalizar variables True = 1; False = 0;
%
%% DATOS DE SALIDA
% W         :   matriz de pesos de dimenciones m*n 
% FO        :   Matriz de errores determinados segun la funcion objetivo definida
% My        :   Matriz de salida de la red Neuronal 

%% Default
[tmp,~] = size(Tp);
if isfield(userdata, 'nepoch')  == 1,   nepoch  = userdata.nepoch;  else nepoch = 1;        end
if isfield(userdata, 'alfa')    == 1,   alfa    = userdata.alfa;    else alfa   = 0.4;      end
if isfield(userdata, 'alfa')    == 1,   n0      = userdata.n0;      else n0     = tmp - 1;  end

%% Determinamos la cantidad de patrones de entrada tanto de salida como de entrada
[fil,npat] = size(Tp);
% n1 representa la cantidad de variables de salida que queremos predecir 
n1 = fil-n0;      
% definimos una matriz de pesos iniciales o semilla para actualizarlos
W = ones(n1,n0+1);   % pesos iniciales 
% j es un contador inicializado en cero, el cual define la posicion de
% los errores en la matriz FO
j = 0;
FO = [0,0];
% este primer ciclo me difine la cantidad de veces que los datos van a
% entrar en la red neuronal definido por la cantidad de epocas 

%% MAPEO DE DATOS DE ENTRDA Y SALIDA 
mii = min(Tp,[],2); 
maa = max(Tp,[],2);
ma = zeros(fil,npat);
mi = ma;
for i = 1:npat      
    ma(:,i) = maa; 
    mi(:,i) = mii;
end
m = (ma - mi); 
Tpm = zeros(fil+1,npat);
% Entradas
Tpm(2:n0+1,:) = ((Tp(1:n0,:) - mi(1:n0,:)) .* ((1 ./ m(1:n0,:)) .* 6)) - 3;
% Salidas
Tpm(n0+2:end,:) = ((Tp(n0+1:end,:) - mi(n0+1:end,:)) .* ((1 ./ m(n0+1:end,:)) .* 0.9)) + 0.05;
Tpm(1,:) = 1;
    
% Tpm = [ones(1,length(Tp(1,:))); Tp];

for iep = 1:nepoch
    % este segundo ciclo me recorre la matriz de la tabla de patrones y
    % actualiza los pesos W
    for ip = 1:npat
        %% TOTAL DE PATRONES
        % j se acumula para actualizar la posicion en la matriz FO
        j = j+1;
        % para realizar un estimativo si depronto de pura chiripa le
        % pegamos a los pesos, determinamos la sinapsis de todos los
        % patrone, luego esta se sigue actualizando de no ser asi.
        Ms = W * Tpm(1:n0+1,1:npat); 
        % Con la matriz de sinapsis definida anteriormente, la pasamos por
        % la funcion de activacion, cuya caracter es de tipo sigmoidal
        My = 1./(1+exp(-Ms)); 
        % Estimamos el error de calibracion con los patametros definidos 
        Me = My - Tpm(n0+2:end,1:npat);  
        % calculamos el errore cuadrado promedio 
        Me2 = sqrt(sum((Me.*Me),1)) / n1;   
        FO(j) = sum(Me2,2) / npat;  
        
        %% PADRONES IP
        % en esta seccion empezamos a tomar patron por patron y en la 
        % matriz columna (y) almacenamos los valores encontrados por la
        % red, en la matriz (d) los patrones de salida reguistrados y por
        % ultimo en l matriz (x) los patrones de entrada a la red
        y = My(1:n1,ip);   
        d = Tpm(n0+2:fil+1,ip);               
        x = Tpm(1:n0+1,ip);   
        % actualizamos los pesos segun la tasa de aprendizaje definida y
        % implementando la reduccion del gradiente de la funcion objetivo
        % definida
        W = W - ((alfa) * (y .* (1-y) .* (y-d)) * x');
    end 
end 

%% GRAFICA DE LOS ERRORES 
% Almacenamiento Figuras

% graficamos el comportamiento de los errores totales para los pesos estimados 
fig = figure('color',[1 1 1]);
set(fig, 'Units', 'Inches', 'PaperPosition', [0, 0, 20, 10],'Position', [0, 0, 20, 10],'PaperUnits', 'Inches','PaperSize', [20, 10],'PaperType','e')
plot(1:npat*nepoch,FO,'k')
xlabel('Evaluaciones de la Función Objetivo')
ylabel('Error Promedio')
title('Optimización del Error')
set(gca,'FontSize',15)
axis([0 max(1:npat*nepoch) 0 (max(FO) + (0.05*max(FO)))])

Graf.Optm = fig; 
k = 2;
for i = 1:n1
    Obs = Tp(n0+i,:)';
    Sim = (((((My(i,:) - 0.05) ./ 0.9) .* m(n0+1:end,:))) + mi(n0+1:end,:))';
    
    %% PLOT
    fig = figure('color',[1 1 1]);
    set(fig, 'Units', 'Inches', 'PaperPosition', [0, 0, 20, 10],'Position', [0, 0, 20, 10],'PaperUnits', 'Inches','PaperSize', [20, 10],'PaperType','e')
    plot(Obs,'k'), hold on, plot(Sim,'r')
    xlabel('Datos'), ylabel('Temperatura (ºC)')
    ln = legend('Observado','Simulado');
    set(gca,'FontSize',15), set(ln, 'FontSize',15)
    mmin = nanmin([Obs Sim])';
    mmax = nanmax([Obs Sim])';
    axis([0 length(Obs) (min(mmin)-(0.05*min(mmin))) (max(mmax)+(0.05*max(mmax)))])
    
    Graf.Plott = fig;
    %% ERROR
    MSE = nanmean((Obs-Sim).^2);
    fig = figure('color',[1 1 1]);
    set(fig, 'Units', 'Inches', 'PaperPosition', [0, 0, 20, 10],'Position', [0, 0, 20, 10],'PaperUnits', 'Inches','PaperSize', [20, 10],'PaperType','e')
    hold on 
    box on
    mmax = max([Obs Sim])';
    scatter(Obs,Sim,10,'k')
    plot(0:max(mmax),0:max(mmax),'k')
    xlabel('Observado')
    ylabel('Simulado')
    title(['Optimización - ',num2str(i),' - MSE = ',num2str(MSE)])
    set(gca,'FontSize',15)
    axis([(min(mmin)-(0.05*min(mmin))) (max(mmax)+(0.05*max(mmax))) (min(mmin)-(0.05*min(mmin))) (max(mmax)+(0.05*max(mmax)))])
    Graf.Error = fig;
end 
varargout(1) = {W};
varargout(2) = {FO};
varargout(3) = {My};
varargout(4) = {Graf};















