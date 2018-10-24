clear, close, clc

% Cargar Datos 
load('Pcp_2017_2018.mat')

%% ENTRADAS 
% Umbral para sepracion de eventos 
UmEvent     = 3;

% Periodos con lluvia 
Id          = P > 0 ;
IdComp      = NaN(length(Id),1);

TrueEvent   = 0;
FalseEvent  = 1;
StoreDate   = [];

for i = 2:length(P) - UmEvent
    if Id(i) == 0
        if ( sum(Id(i:i+UmEvent)) > 0 ) && ( IdComp(i-1) == 1 )
            IdComp(i) = 1;
        else
            IdComp(i) = 0;
        end
    else
        IdComp(i) = 1;
    end
end 

IdComp(isnan(IdComp)) = Id(isnan(IdComp));

DateEvent   = NaN(144,1);
Event       = NaN(144,1);
Cont        = 1;

Cont2 = 1;
for i = 1:length(P)
    if IdComp(i) == 1
        DateEvent(Cont, Cont2)  = Date(i);
        Event(Cont, Cont2)      = P(i);
        Cont                    = Cont + 1;
    else 
        Cont                    = 1;
        Cont2                   = length(Event(1,:)) + 1;
    end    
end

Event           = Event(:,2:end);
DateEvent       = DateEvent(:,2:end);

id              = find(sum(Event>0) > 1);
Event           = Event(:,id);
DateEvent       = DateEvent(:,id);

for i = 1:length(Event(1,:))
    id = find(DateEvent(:,i) == 0);
    DateEvent(id(1):id(end),i) = NaN;
    Event(id(1):id(end),i) = NaN;
end
InteEvent       = Event/(10/60);


%% 
InteSummary     = [sum(DateEvent>1)'*(10/60) nanmin(InteEvent)' nanmax(InteEvent)' nanmean(InteEvent)' nanstd(InteEvent)' nanvar(InteEvent)'];
EventSummary    = [sum(DateEvent>1)'*(10/60) nansum(Event)' nanmin(Event)' nanmax(Event)' nanstd(Event)' nanvar(Event)'];


Info = sprintf([' Event = Eventos de precipitaci�n (mm)\n DateEvent = Fechas de los eventos de precipitaci�n\n ',...
    'InteEvent = Intensidades de los eventos de precipitaci�n (mm/hr)\n',...
    ' InteSummary = Resumen de las intensidades de los eventos [Duraci�n Int_min Int_max Int_mean Int_std Int_var]\n',...
    ' EventSummary = Resumen de los eventos [Duraci�n P_total P_min P_max P_std P_var]']);

save('EventPcp.mat','DateEvent','Event','InteEvent','InteSummary','EventSummary','Info')

%% Curvas Acumulada
PcpAccum = cumsum(Event);

Fig     = figure('color',[1 1 1],'visible','off');
Tsize   = [10, 8];
set(Fig, 'Units', 'Inches', 'PaperPosition', [0, 0, Tsize],'Position',...
    [0, 0, Tsize],'PaperUnits', 'Inches','PaperSize', Tsize,'PaperType','e')

% plot total storm
x = (10:10:1440)'/60;
ax1 = plot(x,PcpAccum,'color',[0.5 0.5 0.5]);
hold on 
% 2017
ax2 = plot(x,PcpAccum(:,1056),'r','linewidth',2);
% 2018
ax3 = plot(x,PcpAccum(:,1084),'g','linewidth',2);

xlabel('\bf Duraci\''on (Horas)', 'Interpreter','latex','Fontsize',20)
ylabel('\bf Precipitaci\''on  Acumulada (mm)', 'Interpreter','latex','Fontsize',20)
set(gca,'FontSize',18,'TickLabelinterpreter','latex')
legend([ax2 ax3],{'\bf 31-Mar-2017','\bf 12-Ago-2018'},'interpreter','latex')

saveas(Fig,'Accum-Storm.png')