% Parameter estimation for the Multilinear lag model of flood routing
% Moment matching technique with linearized St. Venant.
% Luis Camacho March 25/ 1998
% Extension to generalised uniform channel response
%

function [K, n, td, m] = par_3g2(x, WO, QO, NO, SO, S, TYPECHL, TYPEFRL);

if TYPEFRL == 1 % Manning law
   [YO iflag]= yuniform(QO, NO, SO, WO, S, TYPECHL);
else  % Chezy law
   [YO iflag]= yuniform2(QO, NO, SO, WO, S, TYPECHL);
end
[AO] = ar(YO, WO, S, TYPECHL);
vo = QO./AO;
co = kinematic(QO, NO, SO, WO, S, TYPECHL, TYPEFRL);
m=co./vo;
fr = vo./sqrt(9.81.*AO./top(YO,WO,S,TYPECHL));
ndefr= 4/9.*m.*(1-(m-1).^2.*fr.^2)./((1+(m-1).*fr.^2).^2);
tddefr = 1-(2/3.*(1-(m-1).^2.*fr.^2))./(1+(m-1).*fr.^2);
yoSOx = YO./(SO.*x);
xvo   = x./(m.*vo);
K = 3./(2.*m).*(1+(m-1).*fr.^2).*yoSOx.*xvo./3600;
n = ndefr./yoSOx;
td= xvo.*(tddefr)./3600;
clear S YO iflag AO vo yoSOx fr ndefr tddefr tddefr xvo;

