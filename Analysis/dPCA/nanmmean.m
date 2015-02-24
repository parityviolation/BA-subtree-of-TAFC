function Y = nanmmean(X, dimlist)

% Y = nanmmean(X, DIMLIST) computes the average over pooled dimensions
% specified in DIMLIST ignoring NaN values. Y has the same dimensionality
% as X.
%
% Dmitry Kobak, 4 June 2013

if isempty(dimlist)
    Y = X;
    return
end

dims = size(X);
dimrest = setdiff(1:length(dims), dimlist);

X = permute(X, [dimrest dimlist]);
X = reshape(X, [dims(dimrest) prod(dims(dimlist))]);
X = nanmean(X, length(size(X)));
X = ipermute(X, [dimrest dimlist]);

Y = X;
