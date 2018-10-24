function [P]  = PR(YO,WO,S,TCHL)

if TCHL == 1,   	% Rectangular channel
  P= 2.*YO+WO;
elseif TCHL ==2,	% Trapezoidal channel
  P= WO+ 2.*YO.*sqrt(S.^2.+1);
else			% Natural channel
  [N M]= size(WO);
  Y= WO(:,1);
  W= WO(:,2:M);
  J= 1;
  sump = (W(1,:));
  T = TOP(YO,WO,S,TCHL);
  while J<= M-1,
   I= 1;
   while I< N & YO(J) > Y(I),
    if Y(I+1) < YO(J),
      sump(1,J) = sump(1,J) + 2*sqrt((Y(I+1)-Y(I))^2+((W(I+1,J)-W(I,J))/2)^2);
     else
      sump(1,J) = sump(1,J) + 2*sqrt((YO(J)-Y(I))^2+((T(J)-W(I,J))/2)^2);
    end;
    I= I+1;
   end; 
   % Note sth. has to be done for I=N & YO(J)> Y(I) Seccion transversal overtoped 
   J= J+1;
  end; 
  P= sump;
end


%NOTE: For Natural channel the computation is only an aproximation...
%      Symetric cross-sections are assumed in which the slopes of the trapezoids
%      are identical at both sides... Actual Perimeters are different for non-
%      symtrical areas.