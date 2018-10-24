% Initialization for MDLC
   % Array Initialization is important to produce solutions where mass is conserved
   % RH : matrix with solution. Table time-hydrograph at L location 
   %
%
function [h, NM, iter, RH]= init(DT,IH,TYCHL,TYFRL,NO,WO,S,SO,L,a)

IB= abs(IH(1)+a*(min(IH)-IH(1)));
%IB=min(IH);

[K,n,td, mc] = par_3g2(L,WO,IB,NO,SO,S,TYCHL,TYFRL);
%Transformation by Mutiah Perumal (1994)
if K > DT & n*K > DT
   n = (n*K - DT)/(K-DT);
   K = K - DT;
end
if td > DT
   td = td - DT;
end

MM	 = ceil(td/DT);
notf= 0;
J   = 2;
h(1)  = (DT/(DT+K))^(n);
while notf== 0
   h(J)     = ((J+n-2)/(J-1))*(K/(DT+K)).*h(J-1);
   if h(J) < 1e-08
      NM  = J;
      notf=1;
   else
      J=J+1;
   end
end

IB= IH(1)+a*(max(IH)-IH(1));
%IB=max(IH);
[K,n,td, mc] = par_3g2(L,WO,IB,NO,SO,S,TYCHL,TYFRL);
%Transformation by Mutiah Perumal (1994)
if K > DT & n*K > DT
   n = (n*K - DT)/(K-DT);
   K = K - DT;
end
if td > DT
   td = td - DT;
end
MM2  = ceil(td/DT);
notf = 0;
J    =2;
h2(1)  = (DT/(DT+K))^(n);
while notf== 0
   h2(J)     = ((J+n-2)/(J-1))*(K/(DT+K)).*h2(J-1);
   if h2(J) < 1e-08
      NM2  =J;
      notf =1;
   else
      J=J+1;
   end
end
if NM>NM2
   M     = length(IH)+NM-1;
   iter  = M-NM+1;
else
   h     = h2;
   M     = length(IH)+NM2-1;
   iter  = M-NM2+1;
end
if MM>MM2
   RH	   = zeros(M+MM,1);
else
   RH	   = zeros(M+MM2,1);
end

