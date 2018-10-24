function [ETP] = Thornthwaite(A,M,J,Tmean,DL)
% Thornthwaite (1948) - T (Thornthwaite.pdf)

AMJT(:,1) = A;
AMJT(:,2) = M;
AMJT(:,3) = J;
AMJT(:,4) = Tmean;
AMJT(:,5) = find (AMJT(:,1)); % index

% Calcul de Tk, puis I
for k = 1 : 12
    [rowk,colk] = find (M == k);
    Tk(k,1) = max(0,mean(AMJT(rowk,4)));
    I = sum((Tk/5).^(1.514));
end

K = 0.49239+1.792*(10^-2)*I-0.771*(10^-4)*(I^2)+0.675*(10^-6)*(I^3);

% ETP journalière
ETP = (16.*(DL/360).*((10*max(0,Tmean)/I).^K));
ETP = max(0,ETP); % en mm/j

end

% Camargo et al (1999) use an effective temeprature Tef instead of average temperature
%k = 0.69;
%Tef = (0.5*k.*(3.*Tmax-Tmin)).*(DL./(24-DL));
%AMJT(:,1) = A;
%AMJT(:,2) = M;
%AMJT(:,3) = J;
%AMJT(:,4) = Ta;
%AMJT(:,5) = find (AMJT(:,1)); % index
% Calcul de Tk, puis I
%for k = 1 : 12
%    [rowk,colk] = find (M == k);
%    Tk(k,1) = max(0,mean(AMJT(rowk,4)));
%    I = sum((Tk/5).^(1.514));
%end
%K = 0.49239+1.792*(10^-2)*I-0.771*(10^-4)*(I^2)+0.675*(10^-6)*(I^3);
% ETP journalière
%ETP = (16.*(DL/360).*((10*max(0,Tef)/I).^K));
%ETP = max(0,ETP); % en mm/j

% CEMAGREF
% Pour le mois m
%Im = (Tm/5)^1.51;
%I = sum(Im);
%K = 0.49+1.8*(I/100)-0.77*((1/100)^2)+0.67*((I/100)^3);
%ETP = (4/3)*DL*((10*Tm/I)^K);

% Thorthwaite 1948 (journalier)
%Im = (0.2*Tm)^1.514;
%I = sum(Im);
%a = 0.49239+1.7912*(10^-2)*I-7.71*(10^-5)*(I^2)+6.75*(10^-7)*(I^3);
%ETP = 16*((10*Tm/I)^a)*(DL/360);

% Détail
%AMJT(:,1) = A;
%AMJT(:,2) = M;
%AMJT(:,3) = J;
%AMJT(:,4) = Ta;
%AMJT(:,5) = find (AMJT(:,1)); % index
% Calcul de Tk, puis I
%for k = 1 : 12
%    [rowk,colk] = find (M == k);
%    Tk(k,1) = max(0,mean(AMJT(rowk,4)));
%    I = sum((Tk/5).^(1.514));
%end
% Calcul de Tm - Seulement pour calcul ETP mensuelle
%for a = min(AMJT(:,1)) : max(AMJT(:,1))
%    [rowa,cola] = find (A == a);
%    AM = AMJT(rowa,:);
%    for m = 1 : 12
%        [rowm,colm] = find (AM(:,2) == m);
%        MM = AM(rowm,:);
%        MM(:,6) = max(0,mean(MM(:,4)));
%        Tm(MM(:,5),1)=MM(:,6);
%    end
%end
%K = 0.49239+1.792*(10^-2)*I-0.771*(10^-4)*(I^2)+0.675*(10^-6)*(I^3);
% Mensuelle
%ETP = 16.*(DL/12).*(eomday(AMJT(:,1),AMJT(:,2))/30).*((10*Tm/I).^K);
% Journalière
%ETP = (16.*(DL/360).*((10*max(0,Ta)/I).^K));
%ETP = max(0,ETP); % en mm/j