function hl = plotScatterSig(data,significant,options)
% [x y]
mycolor = 'k';
hAx = gca;
bplotmean = 1; % of significant!
meanfunction = @nanmedian;
if nargin>2
    if isfield(options,'hAx')
        hAx = option.hAx;
    end
    if isfield(options,'color')
        mycolor = option.color;
    end
    if isfield(options,'bplotmean')
        bplotmean = option.bplotmean;
    end
    if isfield(options,'meanfunction')
        meanfunction = option.meanfunction;
    end
    
end

nobservations = size(data,1);

for idata = 1:nobservations
    
    h.hl(idata) = line(data(idata,1), data(idata,2),'Marker','o','color',mycolor,...
        'Parent',hAx);
    if significant(idata)
        set(h.hl(idata),'MarkerFaceColor',mycolor)
    end
    
end

if bplotmean % of significant!
    h.hlmean = line(meanfunction(data(significant,1)), meanfunction(data(significant,2)),'Marker','+'...
        ,'markersize',20,'color',mycolor,'Parent',hAx,'linewidth',3);
end
    