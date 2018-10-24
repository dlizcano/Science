function [] = Impact_Tier2(Hp, DEM, varargin)

nargoutchk(1, 3)

if ~isa(DEM, 'GRIDobj'), error('The DEM do not is one GRIDobj'), end

if nargin == 2 
    % 
    FlowDir     = FLOWobj(DEM);
    %
    FlowAccum   = FlowDir.flowacc;
    %
    Tmp         = FlowAccum > 50;
    % create an instance of STREAMobj
    Stream      = STREAMobj(FlowDir, Tmp);
    
elseif nargin == 3
    FlowDir = varargin{1};
    %
    if ~isa(DEM, 'FLOWobj'), error('The DEM do not is one GRIDobj'), end
    %
    FlowAccum   = FlowDir.flowacc;
    %
    Tmp         = FlowAccum > 50;
    % create an instance of STREAMobj
    Stream      = STREAMobj(FlowDir, Tmp);
    
elseif nargin == 4
    
    FlowDir     = varargin{1};
    FlowAccum   = varargin{2};
    
    if ~isa(FlowDir, 'FLOWobj'), error('The DEM do not is one GRIDobj'), end
    if ~isa(FlowAccum, 'GRIDobj'), error('The DEM do not is one GRIDobj'), end
    
end

%% Parameters 
Vp          = [0, 0.05:0.05:1]';
TableC      = array2table(repmat(Vp,1,3),'VariableNames',{'Higth','Area','Volumen'});
CurveDam    = cell(length(Vp),1);

%%
[IX,~]  = coord2ind(DEM, Hp.Coor_X(Hp.Scenario), Hp.Coor_Y(Hp.Scenario));
W       = FlowAccum>50;
[IXc,~] = snap2stream(W,IX);

Basin   = drainagebasins(FlowDir, IXc);

% DEM.cellsize
PosiID  = find(Hp.Scenario);
for i = 1:length(IXc)
    HigthPosi   = DEM.Z(IXc(i));
    Zp          = DEM.Z( Basin.Z == i );
    
    for j = 2:length(Vp)
        
        HigthDamVp = (Vp(j)*Hp.HigthDam(PosiID(i)));
        id         = Zp <= ( HigthPosi + HigthDamVp);
        
        TableC.Higth(j)     =  HigthDamVp;
        TableC.Area(j)      =  sum(id)*(DEM.cellsize.^2);
        TableC.Volumen(j)   =  double(nansum( (( HigthPosi + HigthDamVp) -Zp(id))*(DEM.cellsize.^2) ));
        
    end
    
    CurveDam{i} = TableC;
    
end

a = 1;

