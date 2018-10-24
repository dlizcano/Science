function zi = kriging(vstruct,x,y,z,xi,yi,chunksize)
% INTERPOLACIÓN CON KRIGING ORDINARIO EN DOS DIMENSIONES 
%
% Syntax:
%
%     [zi,zivar] = kriging(vstruct,x,y,z,xi,yi)
%     [zi,zivar] = kriging(vstruct,x,y,z,xi,yi,chunksize)
%
% Descripción:
%
%	Kriging usa Kriging ordinario para interpolar una variable medida z con 
%	coordenadas 'x' y 'y' y en ubicaciones no muestreadas xi y yi. La función requiere
%	la función 'vstruct' que contiene toda la información necesaria del variograma, 
%	vstruct es sucesivamente el argumento de salida de la función variogramfit. 
%	
%	Es rudimentario, pero fácil para usar la función para realizar la interpolación. Es llamado 
%	rudimentario ya que siempre incluye todas las observaciones para estimar los valores 
%	en ubicaciones no muestreadas. 
%	
%	Los algoritmos funcionan mejor para número relativamente pequeños de observaciones (100-500)
%	Para un número grande de observaciones se recomienda el uso de GSTAT
%
%	Importante tener en cuenta que Kriging falla si hay dos o más observaiones cercanas, lo que 
%	puede causar que el sistema de ecuaciones se condicione erroneamente condicionada. 
%
%	Argumentos de entrada 
%
%	vstruct structure array with variogram information as returned
%               variogramfit (forth output argument)	// La estructura de arreglos con la información del variograma retorna como ajuste 
%		del variograma (cuarto argumento de salida)
%	
%	x,y	Coordenadas de las observaciones 
%	z	valores de las observaciones 
%	xi,yi	coordenadas de las predicciones 
%	chunksize número de elementos en zi que son procesados en el tiempo. Por defecto es 100, 
%		  pero esto depende de la memoria disponible y el número de (x)
%
%	
%	Argumentos de salida 
%
%	zi	Predicciones Kriging
%	zivar	Variaza Krgging
%
% see also: variogram, variogramfit, consolidator, pinv
%
% Date: 13. October, 2010
% Author: Wolfgang Schwanghart (w.schwanghart[at]unibas.ch)
%

%%
% size of input arguments // tamaño de los argumentos de entrada 
sizest = size(xi);
numest = numel(xi);
numobs = numel(x);

% force column vectors
xi = xi(:);
yi = yi(:);
x  = x(:);
y  = y(:);
z  = z(:);

if nargin == 6
    chunksize = 100;
elseif nargin == 7
else
    error('wrong number of input arguments')
end

% check if the latest version of variogramfit is used// Revisar si está en uso la última versión de 'variogramfit'
if ~isfield(vstruct, 'func')
    error('please download the latest version of variogramfit from the FEX')
end


% variogram function definitions /Definición de la función variograma 
switch lower(vstruct.model)    
    case {'whittle' 'matern'}
        error('whittle and matern are not supported yet');
    case 'stable'
        stablealpha = vstruct.stablealpha; %#ok<NASGU> % will be used in an anonymous function
end


% distance matrix of locations with known values// Distancia de las ubicaciones de la matriz con valores conocidos
Dx = hypot(bsxfun(@minus,x,x'),bsxfun(@minus,y,y'));


% // Si se tiene un modelo de variograma acotado, es conveniente definir las distancias que son superiores al rango.
% Desde acá será el mismo y no necesitará fuciones compuestas. 

% if we have a bounded variogram model, it is convenient to set distances
% that are longer than the range to the range since from here on the
% variogram value remains the same and we dont need composite functions.

switch vstruct.type
    case 'bounded'
        Dx = min(Dx,vstruct.range);
    otherwise
end

% now calculate the matrix with variogram values// Calcular la matriz con los valores del variograma 
A = vstruct.func([vstruct.range vstruct.sill],Dx);
if ~isempty(vstruct.nugget)
    A = A+vstruct.nugget;
end

%// La matriz debe ser expandida por una línea y una columna para tener en cuenta la condición.
%Todos los pesos deben sumar uno (Multiplicador de Lagrange)

% the matrix must be expanded by one line and one row to account for
% condition, that all weights must sum to one (lagrange multiplier)
A = [[A ones(numobs,1)];ones(1,numobs) 0];

% //'A' es frecuentemente mal condicionada. Por lo tanto se usará 
% el 'Pseudo-inverso para resolver la ecuación 

% A is often very badly conditioned. Hence we use the Pseudo-Inverse for
% solving the equations
A = pinv(A);

% we also need to expand z// Expansión de z
z  = [z;0];

% allocate the output zi// Asignar la salida de zi
zi = nan(numest,1);

% parametrize engine// Parametrización
nrloops   = ceil(numest/chunksize);

% now loop //BUCLE (Instrucciones de repetición hasta que la condición sea satisfecha)
for r = 1:nrloops

    % built chunks// Construcción de fragmentos 
    if r<nrloops
        IX = (r-1)*chunksize + 1 : r*chunksize;
    else
        IX = (r-1)*chunksize +1 : numest;
        chunksize = numel(IX);
    end
    
    % build b// Contruir b
    b = hypot(bsxfun(@minus,x,xi(IX)'),bsxfun(@minus,y,yi(IX)'));
    
    % again set maximum distances to the range
    switch vstruct.type
        case 'bounded'
            b = min(vstruct.range,b);
    end
    
    % expand b with ones// Expandir 'b'
    b = [vstruct.func([vstruct.range vstruct.sill],b);ones(1,chunksize)];
    if ~isempty(vstruct.nugget)
        b = b + vstruct.nugget;
    end
    
    % solve system
    lambda = A*b;
    
    % estimate zi
    zi(IX)  = lambda'*z;
    
end

% reshape zi// Reshape (reconfiguración de zi)
zi = reshape(zi,sizest);

