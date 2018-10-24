function Load_HUA(UserData)

%% Load ShapeFile HUA
try 
    [Basin, CodeBasin]      = shaperead(fullfile(UserData.PathProject,'DATA','Geografic','HUA',UserData.ShapeFileHUA));
    XBasin                  = {Basin.X}';
    YBasin                  = {Basin.Y}';
    BoundingBox             = {Basin.BoundingBox}';
    
    clearvars Basin
    
    if isfield(CodeBasin,'Code') 
        CodeBasin_Tmp = [CodeBasin.Code];
    else
        errordlg(['There is no attribute called "Code" in the Shapefile "',UserData.ShapeFileHUA,'"'], '!! Error !!')
        return
    end

    [CodeBasin,PosiBasin]   = sort(CodeBasin_Tmp);
    CodeBasin               = CodeBasin';
    XBasin                  = XBasin(PosiBasin');
    YBasin                  = YBasin(PosiBasin');
    BoundingBox             = BoundingBox(PosiBasin');
    
    clearvars CodeBasin_Tmp
catch
    errordlg(['The Shapefile "',UserData.ShapeFileHUA,'" not found'],'!! Error !!')
    return
end


