% Flood routing and solute transport integration method 
% LINEAR MODE of Multilinear discrete-lag-cascade model for channel routing (MDLC)
% For case a==0;
% Parameter computation form linearized St. Venant (Doodge 1973)
% Routing operation by means of the discrete pulse response of the discrete cascade model 
% (Multiah Perumal 1993 O'Connor 1976)
% 
% Luis Camacho last modified 18 Sept. 1999
%function [QQ, tt] = dmllli(DT,TI,IH,TYCHL,TYFRL,NO,WO,S,SO,L,a);

function [QQ, tt] = dmllli(DT,TI,IH,TYCHL,TYFRL,NO,WO,S,SO,L,a);

% Initialization
% Array Initialization is important to produce solutions where mass is conserved
% In the linear case h is computed only once (it is done during initialization).
[h, NM, iter, RH]= init(DT,IH,TYCHL,TYFRL,NO,WO,S,SO,L,a);
%

IB= IH(1,1);			% Base discharge
[K, n, td, mc] = par_3g2(L, WO, IB, NO, SO, S, TYCHL, TYFRL);
      
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

for I = 1: iter,		% Main cycle routing operation 
   
   % Reference discharge for time step interval I. Linear method.
   % QO = IB;
   
   % Impulse response of the discrete cascade model + pulse response + lag
   if I<= length(IH) 
      RH(I+1+MM-1)= (IH(I,1)-IB).*h(1)+RH(I+1+MM-1);
      for J = 2: NM,
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
tt=tt(1:length(IH),:);

