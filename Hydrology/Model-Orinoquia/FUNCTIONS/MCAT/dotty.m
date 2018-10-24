% function dotty

% function dotty
%
% dotty plots objective functions
%
% Matthew Lees & Thorsten Wagener, Imperial College London, May 2000

gvs=get(0,'userdata');
ff=gvs.ff;
id=gvs.id;
pars=gvs.pars;
lhoods=gvs.lhoods;
vars=gvs.vars;
dat=gvs.dat;
PS=gvs.PS;

%Eliminate data that is below the slider threshold
dat = sortrows(dat,ff(1)+PS);
numdat = floor((slider_value / 100) * size(dat));
dat(numdat+1:size(dat),:) = [];

perfs=str2mat(lhoods,vars);
lp=PS;

% READ PARETO RANKING
if ~isempty(gvs.pareto)
   pranks = gvs.pareto;
end

if ff(1)<=4
  subp='2,2,';
elseif ff(1)>4&ff(1)<=9
   subp='3,3,';
elseif ff(1)>9&ff(1)<=12
   subp='4,3,';
else %ff(1)>12&ff(1)<=16
   subp='4,4,';
end

for i=1:ff(1)
    if ff(1)>1
        eval(['subplot(' subp num2str(i) ')'])
    end
    
    nn=find(dat(:,ff(1)+lp)==min(dat(:,ff(1)+lp)));
    nn=nn(1);
    
    scatter (dat(:,i), dat(:,ff(1)+lp), 40, 'MarkerEdgeColor' , [0 .5 .5], ... 
              'MarkerFaceColor' , [0 .7 .7], ... 
              'LineWidth' , 1.5)
          
%     plot(dat(:,i),dat(:,ff(1)+lp),'o','markersize',3,'MarkerEdgeColor','k','MarkerFaceColor','b'); 
    
    hold on, 
    plot(dat(nn,i),dat(nn,ff(1)+lp),'s','markersize',15,'MarkerEdgeColor','k','MarkerFaceColor','m'); % best parameter
    
    if ~isempty(gvs.pareto)
       hold on;
       plot(pranks(:,1+i),pranks(:,1+ff(1)+lp),'d','MarkerEdgeColor','k','MarkerFaceColor','c','MarkerSize',20); %pareto set
    end
    
    hold off;
    yaxmin=min(dat(:,ff(1)+lp))-0.1*(max(dat(:,ff(1)+lp))-min(dat(:,ff(1)+lp)));
    yaxmax=max(dat(:,ff(1)+lp))+0.1*(max(dat(:,ff(1)+lp))-min(dat(:,ff(1)+lp)));
    axis([min(dat(:,i)) max(dat(:,i)) yaxmin yaxmax]);
    temp=deblank(perfs(lp,:));

    ylabel(temp,   'interpreter','latex','FontSize',25, 'FontWeight','bold')
    xlabel(pars(i,:),   'interpreter','latex','FontSize',25, 'FontWeight','bold');
    
    box on 
    %% EDIT 
    set(gca, 'TickLabelInterpreter','latex','FontSize',28, 'FontWeight','bold')

end

