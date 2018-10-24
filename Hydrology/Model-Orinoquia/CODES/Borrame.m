clear 
clc
Code = [85001,85225,85325,85230,85400,15755,...
        15533,15550,15377,15464,15296,15790];
%
PP = 'D:\TNC\Project\Project-CravoSur-Thomas\DATA\Demand\Agricultural-Demand\Value';

Tmp = dir(fullfile(PP,'Value_Permanentes*'));
Name = {Tmp.name};


Summary = 0;
for i = 1:length(Name)
    Tmp = xlsread(fullfile(PP,Name{i}));
    Tmp = Tmp(7:end,[1 4]);
    [id, posi] = ismember(Code,Tmp(:,1));
    try
        Summary = Summary + sum(Tmp(posi(posi>0),2), 'omitnan');
    catch
    end
end

Tmp = dir(fullfile(PP,'Value_Transitorios*'));
Name = {Tmp.name};

for i = 1:length(Name)
    Tmp = xlsread(fullfile(PP,Name{i}));
    Tmp = Tmp(7:end,[1 4:16]);
    Tmp = [Tmp(:,1), sum(Tmp(:,2:end),2,'omitnan')];
    [id, posi] = ismember(Code,Tmp(:,1));
    try
        Summary = Summary + sum(Tmp(posi(posi>0),2), 'omitnan');
    catch
    end
end
