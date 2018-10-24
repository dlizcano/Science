% Gamma function for generation of synthetic input hydrographs or pollutographs 
%
%Function [t,TS]= gengamma(TI,TL,DT,TSo,TSP,TP,SK,opcpl);
%t       time array
%TS      generated time series 
%TI      Initial Time
%TL      Last time
%DT      Delta time (same units as initial and last times)
%TSo 	   Initial base value
%TSP     Peak value
%TP 	   Time to peak
%SK 	   Skewness
%opcpl   0 no plot 1 plot

function [t,TS]= gengamma(TI,TL,DT,TSo,TSP,TP,SK,opcpl);

% Hydrograph Generation
% Hydrograph: qo(t)=IB+(IP-IB)*(t/TP)^(1/(SK-1))*exp((1-t/TP)/(SK-1))

t     = (TI: DT: TL)';
TS    = zeros(length(t),1);
TS    = TSo+(TSP-TSo).*(t/TP).^(1/(SK-1)).*exp((1-t./TP)/(SK-1));

if opcpl == 1
   fn=figure('pos',[50,50,700, 500]);
   plot(t,TS);
   legend('Generated time series');
   xlabel('Time');
%    pause;
%    close(fn)
end

