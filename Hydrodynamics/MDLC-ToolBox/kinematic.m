% Kinematic wave celerety computation Any shape and friction law
% Central Finite difference approximation for dQ/dA|Ao
%
% Dic. /1998
%
% QO:	Discharge;
% NO: Manning n. For Chezy friction law NO is the Chezy coefficient
% SO: Channel slope
% WO: Channel width
% S : 
% TYPECHL: Type of channel 1-Rect, 2-Trap, 3-Nat
% TYPEFRL: Type of friction law 1- Manning, 2-Chezy
%
%
function [co] = kinematic(QO, NO, SO, WO, S, TYPECHL, TYPEFRL);
% 
if TYPEFRL == 1
   [YO iflag]= yuniform(QO, NO, SO, WO, S, TYPECHL);
else
   [YO iflag]= yuniform2(QO, NO, SO, WO, S, TYPECHL);
end
dy=YO*0.0000001;
[A2] =ar(YO+dy, WO, S, TYPECHL);
[P2] =pr(YO+dy, WO, S, TYPECHL);
[A1] =ar(YO-dy, WO, S, TYPECHL);
[P1] =pr(YO-dy, WO, S, TYPECHL);
if TYPEFRL == 2
   Q2=A2.*NO.*(A2./P2).^(1/2).*SO.^(1/2);
   Q1=A1.*NO.*(A1./P1).^(1/2).*SO.^(1/2);
else
   Q2=A2./NO.*(A2./P2).^(2/3).*SO.^(1/2);
   Q1=A1./NO.*(A1./P1).^(2/3).*SO.^(1/2);
end
co=(Q2-Q1)./((A2-A1));



