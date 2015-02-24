function setAxEq(h,whichax)

if nargin <1
    h = gca;
end
if nargin <2
    whichax = 'xy';
end
switch (whichax)
    
    case 'xy'
        helper(h,'xlim');
        helper(h,'ylim');
    case 'x'
        helper(h,'xlim');
    case 'y'
        helper(h,'ylim');
        
end

function lim = helper(h,str)

m = get(h,str);
if iscell(m)
    lim(1) = min(cellfun(@min,m));
    lim(2) = max(cellfun(@max,m));
else
    lim = m;
end
set(h,str,lim);
