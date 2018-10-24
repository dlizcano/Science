% Identical to Yuniform but for Chezy friction law...
% Note parameter NO is now CO, Chezy coefficient.
% function [YO, IFLAG] = yuniform2(QO, NO, SO, WO, S, TYPECHL)
%
function [YO, IFLAG] = yuniform2(QO, NO, SO, WO, S, TYPECHL)

es =   1e-7;			% Tolerance
er =   1.0;			% Current error
imax = 50; 			% Max number of iterations

iter = 0; flag =0;
if TYPECHL == 1,		% Rectangular channel
  YO= (QO./(NO.*WO)).^(2/3)./(SO).^(1/3);
  while er > es & iter < imax,
   YOLD = YO;
   YO   = (QO./NO).^(2/3)./(WO.*(SO).^(1/3)).*(WO+2.*YOLD).^(1/3);
   iter = iter + 1;
   if all(YO)
     temp = abs((YO-YOLD)./YO);
     er = sum(temp);
   end
  end
elseif TYPECHL == 2,		% Trapezoidal channel
  YO= (QO./(WO.*NO)).^(2/3)./(SO).^(1/3);
  while er > es & iter < imax,
   YOLD = YO;
   YO   = (QO./NO).^(2/3).*(WO+2.*YOLD.*sqrt(1+S.^2)).^(1/3)./(SO.^(1/3).*(WO+S.*YOLD));
   iter = iter + 1;
   if all(YO)
     temp = abs((YO-YOLD)./YO);
     er = sum(temp);
   end
  end
else				% Natural channel
 const = (QO./NO)./sqrt(SO);
 [N M] = size(WO);
 y = WO(:,1);
 for J= 1: M-1,
  ymin(J) = y(1);
  ymax(J) = y(N);
 end
 while er > es & iter < imax,
  YO= (ymin+ymax)./2;
  A = ar(YO,WO,S,TYPECHL);
  P = pr(YO,WO,S,TYPECHL);
  temp = A.*(A./P).^(1/2);
  for J= 1: M-1,
   if temp(J) > const(J),
      ymax(J) = YO(J);
   else
      ymin(J) = YO(J);
   end;
  end;
  temp= abs(const-temp);
  iter = iter +1;
  er = sum(temp);
 end
end

if iter == imax,
   IFLAG = 1
else
   IFLAG = 0;
end

