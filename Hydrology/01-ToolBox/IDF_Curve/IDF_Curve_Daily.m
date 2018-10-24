function [varargout] = IDF_Curve_Daily(Date, P, Cores)
% [Fig, Imax, IDF, Params] = IDF_Curve(Date, P, Cores)
%/usr/bin/Matlab-R2016a
%% BASE DATA 
% Author        : Jonathan Nogales Pimentel
% email         : nogales02@hotmail.com
% Professor     : Andres Vargas Luna
% University    : Pontificia University Javeriana 
% 
% Copyright (C) 2017 Apox Technologies
% This program is free software: you can redistribute it and/or modify it 
% under the terms of the GNU General Public License as published by the 
% Free Software Foundation, either version 3 of the License, or 
% (at your option) any later version. This program is distributed in the 
% hope that it will be useful, but WITHOUT ANY WARRANTY; without even the 
% implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.   
% ee the GNU General Public License for more details.
%
%%
try
   myCluster = parcluster('local');
   myCluster.NumWorkers = Cores;
   saveProfile(myCluster)
   parpool;
catch
end

%% Parameters 
% Peridos de retorno
T       = [2; 5; 10; 25; 50; 100; 150; 200];

% Funciones de densidad de probabilidad
CDF     = {'Normal','Lognormal','Gamma', 'ExtremeValue', 'Weibull','Nakagami', 'Exponential', 'Poisson','kernel'};
Factor  = [0;0.011;0.023;0.035;0.048;0.064;0.08;0.1;0.12;0.147;0.181;0.236;0.663;0.776;0.825;0.856;0.881;0.903;0.922;0.938;0.953;0.965;0.977;0.989;1];

% Duraciones
D       = [1:24]';

% años a analizar 
Years   = unique(year(Date));

% Matriz de años 
Data    = NaN(length(Years), 366);

% Almacen de años
for i = 1:length(Years)
    Tmp = year(Date);
    id  = Tmp == Years(i);   
    Data(i,1:length(P(id))) = P(id);
end

% Almacenamiento de precipitaciones maximas
L       = nanmax(Data,[],2);

% Ajuste de funciones de desnidad de probalidad 
Error = 1E12;
for i = 1:length(CDF)
   try 
       Q                = L;
       [Fe,x_values]    = ecdf(Q);
       test_cdf         = fitdist(Q,CDF{i});
       [h, p]           = kstest(Q,'CDF',test_cdf,'Alpha',0.05);
       Ft               = cdf(test_cdf, x_values);
       MSE              = sum((Fe - Ft).^2);

       if MSE < Error 
           pdf      = test_cdf;
           Error    = MSE;
       end
   catch
   end
end

% Valores de intensidad de los peridos de retorno evaluados
eval    = 1 - (1./T);
DFtmp   = icdf(pdf,eval);

DF = NaN(length(T), 24);

for i = 1:length(DFtmp)
    Ac      = DFtmp(i).*Factor;
    dc      = diff(Ac);
    Itmp    =  NaN(24,24);
    parfor j = 1:24
        Itmp(:,j) = dc/D(j);
    end
    DF(i,:) = nanmax(Itmp);
end
%% Ajustar curva IDF

[X,Y]   = meshgrid(D,T);
% duracion
X       = reshape(X,numel(X),1);
% Frecuencia 
Y       = reshape(Y,numel(Y),1);
% Intencidad
Z       = reshape(DF,numel(X),1);

%Establecer forma de la ecuaci�n deseada
eq1 ='(K*y^m)/(x+t0)^n';
K0  = 11000;
m0  = 0.08;
n0  = 5;
t0  = 1;
%Ajustar curva
sf      = fit([X Y],Z,eq1,'StartPoint',[K0,m0,n0,t0]);

%Crear funci�n con par�metros obtenidos
curva   = @(x,y,sf) (sf.K*y^sf.m)./(x+sf.t0).^sf.n;

% Parametros 
Params.k = sf.K;
Params.m = sf.m;
Params.n = sf.n;
Params.c = sf.t0;
Params.Function = curva;

%Crear ecuacion con par�metros hallados
eq1t    = strcat('$$i=\frac{',num2str(sf.K,5),'*T^{',num2str(sf.m,2),'}}{(d+(',num2str(sf.t0,3),'))^{',num2str(sf.n,3),'}}$$');

%% Graficas 
Tmp2     = ['T = ',num2str(T(1)),'-'];  

parfor i = 2:length(T)
    Tmp  = ['T = ',num2str(T(i)),'-'];
    Tmp2 = [Tmp2,Tmp];
end
NameT = Tmp2;

Fig     = figure('color',[1 1 1],'visible','on');
Tsize   = [12, 8];
set(Fig, 'Units', 'Inches', 'PaperPosition', [0, 0, Tsize],'Position',...
    [0, 0, Tsize],'PaperUnits', 'Inches','PaperSize', Tsize,'PaperType','e')

for i = 1:length(T)
    plot(D,curva(D,T(i),sf),'LineWidth',1.2)
    hold on
end
   
Pstr        = strsplit(Tmp2,'-');
Pstr(end)   = [];
legend(Pstr, 'Interpreter','latex','Fontsize',12)
text(mean(D),max(max(DF)) - (max(max(DF))*0.2),eq1t,'Interpreter','latex', 'Fontsize',14)
ylabel('Intensidad (mm/hr)', 'Interpreter','latex','Fontsize',16)
xlabel('Duracion (hr)', 'Interpreter','latex','Fontsize',16)
set(gca,'FontSize',14,'TickLabelinterpreter','latex')
grid on
grid minor

axis([0 24 0 max(max(DF))])

Tmp  = {};
parfor i = 1:length(T)
    Tmp{i}  = ['T_',num2str(T(i))];
end
NameT = Tmp;

Tmp  = {};
parfor i = 1:length(D)
    Tmp{i}  = ['D_',num2str(D(i)*60),'_min'];
end
NameD = Tmp;

Tmp  = {};
parfor i = 1:length(Years)
    Tmp{i}  = ['Year_',num2str(Years(i))];
end
NameY = Tmp;

varargout{1} = Fig;
varargout{2} = array2table(I,'VariableNames',NameD ,'RowNames',NameY);
varargout{3} = array2table(DF,'VariableNames',NameD ,'RowNames',NameT);
varargout{4} = Params;
