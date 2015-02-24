function S = subsets(X)

% S = subsets(X) returns a cell array of all subsets of vector X apart
% from the empty set. Subsets are ordered by the number of elements in
% ascending order.
%
% subset([1 2 3]) == {[1], [2], [3], [1 2], [1 3], [2 3], [1 2 3]}
%
% Dmitry Kobak, 4 June 2013

d = length(X);
pc = dec2bin(1:2^d-1) - '0';
[~, ind] = sort(sum(pc, 2));
pc = fliplr(pc(ind,:));
for i=1:length(pc)
    S{i} = X(find(pc(i,:)));
end

