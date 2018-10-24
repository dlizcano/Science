% function [A] = ar(YO, WO, S, TCHL)
function [A] = ar(YO, WO, S, TCHL)

if TCHL == 1         % Rectangular channel
  A= YO.*WO;
elseif TCHL ==2      % Trapezoidal channel
  A= (WO+S.*YO).*YO; 
else                 % Natural channel
  [N M]= size(WO);
  Y= WO(:,1);
  W= WO(:,2:M);
  J= 1;
  suma = zeros(1,M-1);
  T = TOP(YO,WO,S,TCHL);
  while J<= M-1,
   I= 1;
   while I< N & YO(J) > Y(I),
    if Y(I+1) < YO(J),
      suma(1,J) = suma(1,J) + (W(I+1,J)+W(I,J))*(Y(I+1)-Y(I))/2;
     else
      suma(1,J) = suma(1,J) + (T(J)+W(I,J))*(YO(J)-Y(I))/2;
    end;
    I= I+1;
   end; 
   % Note sth. has to be done for I=N & YO(J)> Y(I) Seccion transversal overtoped 
   J= J+1;
  end; 
  A= suma;
end

