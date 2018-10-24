% Calculation of model efficiency
% Nash-Sutcliffe J.Hydrol. Vol 10: 282-290. 1970
%
%Luis Camacho 06/04/98
%
% function [R2, iflag] = efficien(qobs, qcalc);

function [R2, iflag] = efficien(qobs, qcalc);

M= length (qobs);
N= length (qcalc);
if N-M ~=0 
 iflag = 1;
 R2 = 0;
 disp('Error: use same length of observed and calculated data');
else
 om = mean(qobs);
 Fo2 = 0;
 F2  = 0;
 for J= 1:M
  Fo2 = Fo2+ (qobs(J)-om).^2;
  F2  = F2+  (qcalc(J)-qobs(J)).^2;
 end
 R2 = (Fo2-F2)/Fo2;
end