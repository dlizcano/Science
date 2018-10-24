% Discrete Multilinear - lag model for channel routing 
% 
% Luis Camacho last modified 23 Oct. 1999
%
%function [QQ, tt] = dmll(DT,TI,IH,TYCHL,TYFRL,NO,WO,S,SO,L,a);
% DT : delta time [hr]
% TI : initial time [hr]
% IH : input hydrograph. Array of discharges at DT time intervals [L/s^3]
% TYCHL : Type of channel 1-Rect 2-Trap 3-Irreg.
% TYFRL : Type of friction law 1-Manning 2-Chezy
% NO : Manning-n or Chezy-C
% WO : Channel base width (Rect, Trap.) For irregular channel table depth - top width
% S  : Lateral channel slope (0 for Rect. and Irreg.)
% SO : Bed slope
% L  : Channel length [L]
% a  : Multilinear coefficient to compute reference discharge as a function of input

function [QQ, tt] = dmll(DT,TI,IH,TYCHL,TYFRL,NO,WO,S,SO,L,a)

if a==0   % Linear method is much quicker...
   [QQ, tt] = dmllli(DT,TI,IH,TYCHL,TYFRL,NO,WO,S,SO,L,a);
else
   
   % Initialization
   % Array Initialization is important to produce solutions where mass is conserved 100%
   [h, NM, iter, RH]= init(DT,IH,TYCHL,TYFRL,NO,WO,S,SO,L,a);

   IB= IH(1,1);			% Base discharge
   for I = 1: iter,		% Main cycle routing operation 
      
      % Reference discharge for time step interval I. Multilinear approach
      if I<= length(IH)      
         QO = IB+a*(IH(I,1)-IB);
      else
         QO = IB;
      end        
      
      % Parameter estimation using Cumulant matching technique with linearised St. Venant
      [K, n, td, mc] = Par_3g2(L, WO, QO, NO, SO, S, TYCHL, TYFRL);
      
      %Parameter Transformation by Mutiah Perumal (1993)
      if K > DT & n*K > DT
         n = (n*K - DT)/(K-DT);
         K = K - DT;
      end
      if td > DT
         td = td - DT;
      end
      
      % Impulse response of the discrete cascade model + pulse response + lag !!!
      
      MM    = ceil(td/DT);
      h(1)  = (DT/(DT+K))^(n);
      if I<= length(IH) 
         RH(I+1+MM-1)= (IH(I,1)-IB).*h(1)+RH(I+1+MM-1);
         for J = 2: NM,
            h(J)     = ((J+n-2)/(J-1))*(K/(DT+K)).*h(J-1);
            RH(I+J+MM-1)= (IH(I,1)-IB).*h(J) + RH(I+J+MM-1);	
         end
      end
   end  % End Main cycle routing operation
   
   M=length(RH);
   tt=zeros(M,1);
   QQ=zeros(M,1);
   tt=(0:1:M-1)'.*DT;
   tt=tt+TI;
   QQ=RH(:,1)+IB;
   QQ=QQ(1:length(IH),:);
   tt=tt(1:length(IH),:)./DT;
end
