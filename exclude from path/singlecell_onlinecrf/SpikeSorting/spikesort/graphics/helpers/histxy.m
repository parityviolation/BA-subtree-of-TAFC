function [counts,x_inds,y_inds] = histxy(x, y, D, filt)

    if nargin < 3, D = [25 25];end
    if nargin < 4, filt = []; end
    if length(D) == 1, D = [D D]; end

    % convert values to (x,y) coordinates and then indices
    [x,oldminx,oldmaxx] = rescale(x,1,D(1));  x = round(x);
    [y,oldminy,oldmaxy] = rescale(y,1,D(2));  y = round(y);
    inds = x + (y-1)* D(1);
 
    % fill in the counts
    counts = zeros( D );
    for j = 1:length(inds)
        counts(inds(j)) = counts(inds(j))+1;
    end
    
    x_inds = [oldminx oldmaxx];
    y_inds = [oldminy oldmaxy];
    
    if ~isempty(filt)
       counts = conv2( counts, ones(filt), 'same'); 
    end
    
end
        
