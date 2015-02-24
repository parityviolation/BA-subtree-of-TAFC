function [hax him]= plotSTA(data,hax,clims)

if ~exist('hax','var'); hax = gca; end
if ~exist('clims','var') || isempty(clims); clims = [min(data(:)) max(data(:))]; end

him = imagesc(rot90(data),clims);
    set(him,'Parent',hax)

colormap('gray');
axis manual;  axis off
