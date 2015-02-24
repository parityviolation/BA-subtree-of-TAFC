function [X Y] = makeEqual(X,Y)

len = max(length(X),length(Y));

if length(Y)<len
    Y(end+1:end+(len-end)) = NaN;
elseif length(X)<len
    X(end+1:end+(len-end)) = NaN;
end
