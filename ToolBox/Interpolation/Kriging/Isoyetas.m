%% ISOYETAS KRIGING
% Autor     :   Jonathan Nogales Pimentel
% Profesor  :	Miguel Angel Valenzuela  
% 
clear; clc
%% 
mes = {'Enero','Febrero','Marzo','Abril','Mayo','Junio','Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre'};
ENSO = {'neutro','Nino', 'Nina', 'Total'};
model = {'blinear','circular','spherical','pentaspherical','exponential', 'gaussian', 'whittle', 'stable', 'matern'};
%% ISOYETAS

%% datos de Entrada
dir = pwd;
load('Datos.mat'); load('coor.mat');
% muestreo del campo 
n = 57672;
x = Datos(:,2);
y = Datos(:,1);
j = 1;
for i = 3:4:50
    error = 1E-12;
    cd(dir)
    z = Datos(:,i);
    % calculate the sample variogram
    v = variogram([x y],z,'plotit',false,'maxdist',600000);
    for jj = 1:9
        [dum,dum,dum,vstruct] = variogramfit(v.distance,v.val,[],[],[],'model',model{jj},'plotit',false);
        if vstruct.Rs > error
            error = vstruct.Rs;
            ii = jj;
        end
    end
    [dum,dum,dum,vstruct] = variogramfit(v.distance,v.val,[],[],[],'model',model{ii});
    title(['Modelo: ',vstruct.model,'- Rs: ',num2str(vstruct.Rs)])
    cd([dir,'/','SEMI_VARIOGRAMA'])
    saveas(gcf,['SEMIVARIOGRAMA','-',mes{j},'-',ENSO{3},'.jpg'])
    close(gcf)
    cd(dir)
    % now use the sampled locations in a kriging
    [Zhat,Zvar] = kriging(vstruct,x,y,z,X,Y);
    cd([dir,'/','ISOYETAS'])
    contourf(X,Y,Zhat)
    colorbar
    %hold on 
    %scatter(x,y);
    saveas(gcf,['ISOYETAS','-',mes{j},'-',ENSO{3},'.jpg'])
    close(gcf)
    j = j + 1;
end
