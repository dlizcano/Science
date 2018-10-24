function obj = CreateFolder(obj)

Pro = properties(obj);

for i = 1:length(Pro)
    Tmp = strfind(Pro{i},'PathFolder_');
    
    if ~isempty(Tmp)
        eval(['obj.',Pro{i},' = fullfile(obj.Path_Project,obj.',Pro{i},');']) 
    end
        
end


end