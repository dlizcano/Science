function [varargout] = IDF_Curve_LinearRegres(Date, P, Cores)
% [Fig, Imax, II, Params] = IDF_Curve_LinearRegres(Date, P, Cores)
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
% Delta de tiempo
dt      = round(1440/(1/(Date(2) - Date(1))));

% años a analizar 
Years   = unique(year(Date));

% duraciones
D       = [(dt:dt:1440)]' / 60;

% Matriz de años 
Data    = zeros(length(Years), round(366*(1/(Date(2) - Date(1)))));

% Almacen de años
for i = 1:length(Years)
    Tmp = year(Date);
    id  = Tmp == Years(i);
    
    Data(i,1:length(P(id))) = P(id);
end

% Almacenamiento de precipitaciones maximas
L = NaN(length(Years), length(D));
L(:,1) = nanmax(Data,[],2);

% Precipitaciones Maximas por duracion 
for i = 1:length(D)
    Tmp = NaN(length(Years),round(length(Data(1,:))/i) + 2);
    parfor j = 1:length(Data(1,:)) - i
        Tmp(:,j) = nansum(Data(:,j:j + i),2);
    end
    L(:,i) = nanmax(Tmp,[],2);
end

% Intencidades maximas 
I = zeros(size(L));
parfor i = 1:length(D)
    I(:,i) = L(:,i)/D(i);
end

parfor i = 1:length(I(1,:))
    I(:,i) = sort(I(:,i),'descend');
end

% Peridos de retorno
% Asignar Periodo de retorno
Fil = length(I(:,1));
T = NaN(Fil,1);
parfor i = 1 : Fil
    T(i) = (Fil + 1)/i;
end

%% Ajustar curva II

[X,Y]   = meshgrid(D,T);
% duracion
X       = reshape(X,numel(X),1);
% Frecuencia 
Y       = reshape(Y,numel(Y),1);
% Intencidad
Z       = reshape(I,numel(X),1);

%Establecer forma de la ecuaci?n deseada
eq1 ='(K*y^m)/(x+t0)^n';
K0  = 11000;
m0  = 0.08;
n0  = 5;
t0  = 1;
%Ajustar curva
sf      = fit([X Y],Z,eq1,'StartPoint',[K0,m0,n0,t0]);

%Crear funci?n con par?metros obtenidos
curva   = @(x,y,sf) (sf.K*y^sf.m)./(x+sf.t0).^sf.n;

% Parametros 
Params.k = sf.K;
Params.m = sf.m;
Params.n = sf.n;
Params.c = sf.t0;
Params.Function = curva;

%Crear ecuacion con par?metros hallados
eq1t    = strcat('$$i=\frac{',num2str(sf.K,5),'*T^{',num2str(sf.m,2),'}}{(d+(',num2str(sf.t0,3),'))^{',num2str(sf.n,3),'}}$$');

%% Graficas 
TT   = [2; 5; 10; 25; 50; 100];

Tmp2     = ['T = ',num2str(TT(1)),'-'];  

parfor i = 2:length(TT)
    Tmp  = ['T = ',num2str(TT(i)),'-'];
    Tmp2 = [Tmp2,Tmp];
end
NameT = Tmp2;

% Peridos de retorno para grafica 

Fig     = figure('color',[1 1 1],'visible','off');
Tsize   = [12, 8];
set(Fig, 'Units', 'Inches', 'PaperPosition', [0, 0, Tsize],'Position',...
    [0, 0, Tsize],'PaperUnits', 'Inches','PaperSize', Tsize,'PaperType','e')

for i = 1:length(TT)
    plot(D,curva(D,TT(i),sf),'LineWidth',1.2)
    hold on
end
   
Pstr        = strsplit(Tmp2,'-');
Pstr(end)   = [];
legend(Pstr, 'Interpreter','latex','Fontsize',12)
text(mean(D),max(max(I)) - (max(max(I))*0.2),eq1t,'Interpreter','latex', 'Fontsize',14)
ylabel('Intensidad (mm/hr)', 'Interpreter','latex','Fontsize',16)
xlabel('Duracion (hr)', 'Interpreter','latex','Fontsize',16)
set(gca,'FontSize',14,'TickLabelinterpreter','latex')
grid on
grid minor

axis([0 24 0 max(max(I))])

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
varargout{3} = array2table(I,'VariableNames',NameD ,'RowNames',NameT);
varargout{4} = Params;
