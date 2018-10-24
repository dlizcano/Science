function Index = Q95(Date, Qbase)
% /usr/bin/Matlab-R2016b
% -------------------------------------------------------------------------
% 
% -------------------------------------------------------------------------
% BASE DATA 
% -------------------------------------------------------------------------
% Project               : Landscape planning for agro-industrial expansion 
%                         in a large, well-preserved savanna: how to plan 
%                         multifunctional landscapes at scale for nature and 
%                         people in the Orinoquia region, Colombia
% Author                : Jonathan Nogales Pimentel
% Email                 : nogales02@hotmail.com
% Supervisor            : Carlos Andrés Rogéliz
% Company               : The Nature Conservancy - TNC
% 
% This program is free software: you can redistribute it and/or modify it 
% under the terms of the GNU General Public License as published by the 
% Free Software Foundation, either version 3 of the License, or option) any 
% later version. This program is distributed in the hope that it will be 
% useful, but WITHOUT ANY WARRANTY; without even the implied warranty of 
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
% ee the GNU General Public License for more details. You should have 
% received a copy of the GNU General Public License along with this program.  
% If not, see http://www.gnu.org/licenses/.
%

%%
Porcentaje = 95;

Date    = datetime(datestr(Date));
Mes     = month(Date);
Index = NaN(length(Qbase(1,:)), 13);

for i = 1:length(Qbase(1,:))

    for j = 1:12
        [Por_Q,Qd]          = hist(Qbase(Mes==j,i),length(unique(Qbase(Mes==j,i))));
        [Qsort_base, id ]   = sort(Qd, 'descend');
        PQ_base             = (cumsum(Por_Q(id))/sum(Por_Q(id)))*100;
        [~, id]             = unique(PQ_base);
        
%         try
        Index(i,j+1)        = interp1(PQ_base(id), Qsort_base(id), Porcentaje);
%         catch 
%         end
    end
    
    [Por_Q,Qd]          = hist(Qbase(:,i),length(unique(Qbase(:,i))));
    [Qsort_base, id ]   = sort(Qd, 'descend');
    PQ_base             = (cumsum(Por_Q(id))/sum(Por_Q(id)))*100;
    [~, id]             = unique(PQ_base);
    
%     try
    Index(i,1)          = interp1(PQ_base(id), Qsort_base(id), Porcentaje);
%     catch 
%     end
end
