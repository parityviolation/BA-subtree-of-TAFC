function [mn, mx] = matchy( axlist, keep )
% MATCHY fixes the y scale of a list of axes
%
%	[mn, mx] = matchy( axlist ) gives the same ylim (mn to mx) to all the axes.
%
%	sz = matchy( axlist, 'bottom' ) keeps the current ylim(1)s
%	fixed when rescaling.
%
%	sz = matchy( axlist, 'middle' ) changes the ylim of each axes object so 
% 	that the current midpoints between bottom and top are unchanged.
%
%	if a ylim value is set to non inf, that value is considered as the limit
%	for that ax, and data beyond it are ignored
%
% 1996,1997 Matteo Carandini
% 2001-10 VM - made it ignore NaN axes
% 2005-09 MC - updated so it works with Matlab 7
% 2008-01 SK - replaced FINITE with ISFINITE
% part of the Matteobox toolbox

if nargin<2, keep = ''; end
 
axlist = axlist(:)';

% if length(axlist)<=1, return; end

% Next 2 lines by VM (amended by MC by removing find 2010-03)
goodaxes = isfinite(axlist);
axlist = axlist(goodaxes);


% ---------- get the current limits, call them [ mn mx ] ------------

mn = zeros(length(axlist),1)*NaN;
mx = zeros(length(axlist),1)*NaN;

ylims = zeros(length(axlist),2);

for iax = 1:length(axlist)
    ax = axlist(iax);
    ylims(iax,:) = get(ax,'ylim');
    ydata = [];
    for child = get(ax,'children').'
        objtype = get(child,'type');
        if strcmp(objtype,'line') || strcmp(objtype,'patch') || strcmp(objtype,'hggroup')
            thesedata = get(child,'ydata');
            ydata = [ ydata; thesedata(:) ]; %#ok<AGROW>
        end
    end
    ydata = ydata(isfinite(ydata));
    if any(ydata)
        mn(iax) = nanmin(ydata(:));
        mx(iax) = nanmax(ydata(:));
    end
    if length(keep)>1
        if isfinite(ylims(iax,1)), mn(iax) = ylims(iax,1); end
        if isfinite(ylims(iax,2)), mx(iax) = ylims(iax,2); end
    end
end

if length(axlist)<=1, return; end

%---------------- the size all the axes must now have -----------------

sz = max(mx-mn);

if sz<=0
%	disp('Size is zero, so I did not match the y axes'); 
	return;
end

if isnan(sz)
    return;
end

%---------------- fix the ylims ---------------------------------------

for iax = 1:length(axlist)
	ax = axlist(iax);
	if strcmp(keep,'') 
		set(ax,'ylim',[ min(mn) max(mx) ]);
	elseif strcmp(keep,'middle')
		set(ax,'ylim',(mn(iax)+mx(iax))/2 + sz*[-1/2 1/2]);
	elseif strcmp(keep,'bottom')  
		set(ax,'ylim',mn(iax) + [0 sz]);
	else
		error('what is that?');
	end
end

%------------------ set the output variables ---------------------------

if isempty(keep)
	mx = max(mx);
	mn = min(mn);
else
	mn = sz; mx = sz; 
end
