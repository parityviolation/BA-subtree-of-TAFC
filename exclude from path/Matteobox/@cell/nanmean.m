function avg = nanmean( cellarray )
% NANMEAN
%
% Overloaded method to do a nanmean of cell arrays
%
% LB 04-15-08
% Part of Matteobox

ncells = length(cellarray);

failed = 0;

if isnumeric(cellarray{1})
    sz = size(cellarray{1});
else
    failed = 1;
end

% now should check that all entries have size sz...

if failed
    error('Not a cell array of numeric values');
end

if ~failed
    ns = zeros(sz);
    avg = zeros(sz);
    for icell = 1:ncells
        [i,j] = find(~isnan(cellarray{icell}));
        avg(i,j) = avg(i,j) + cellarray{icell}(i,j);
        ns(i,j) = ns(i,j) + 1;
    end
    
    avg = avg ./ ns;
end
