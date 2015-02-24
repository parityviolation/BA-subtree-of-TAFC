function [YY, paramsubsets] = marginalize(X, combinedParams, ifFull)

% YY = marginalize(X) computes data marginalized over all combinations
% of parameters. X is a multi-dimensional array of dimensionality D+1, where
% first dimension corresponds to neurons and the rest D dimensions --
% to various parameters. YY is a cell array of marginalized datasets,
% containing 2^D-1 arrays, marginalized over all combinations of D
% parameters, excluding empty set. For each i size(YY{i}) equals size(X).
%
% Dmitry Kobak, 4 June 2013
%
% update 9 January 2014
% combinedParams is a cell array specifying which marginalizations should be
% added up together

% demean
X = bsxfun(@minus, X, mean(X(:,:),2));

params = 2:length(size(X));
paramsubsets = subsets(params);

alreadyProcessed = containers.Map;
for subs = 1:length(paramsubsets)
    indRest = paramsubsets{subs};
    indMarg = setdiff(params, indRest);
    YY{subs} = nanmmean(X, indMarg);
    alreadyProcessed(num2str(sort(indMarg))) = subs;
    
    paramsubsubsets = subsets(indRest);
    for s = 1:length(paramsubsubsets)-1
        indM = [paramsubsubsets{s} indMarg];
        sign = -1;%(-1)^length(paramsubsubsets{s});
        YY{subs} = bsxfun(@plus, YY{subs}, sign*YY{alreadyProcessed(num2str(sort(indM)))});
    end
end

paramsubsets = subsets(params-1);

if nargin>=2 && ~isempty(combinedParams)
    for i=1:length(combinedParams)
        margsToAdd = [];
        for j=1:length(combinedParams{i})
            for k=1:length(paramsubsets)
                if length(paramsubsets{k})==length(combinedParams{i}{j}) && all(sort(paramsubsets{k})==sort(combinedParams{i}{j}))
                    margsToAdd = [margsToAdd k];
                    continue
                end
            end
        end
        
        YYY{i} = YY{margsToAdd(1)};
        for j=2:length(margsToAdd)
            YYY{i} = bsxfun(@plus, YYY{i}, YY{margsToAdd(j)});
        end
    end
    
    YY = YYY;
    paramsubsets = combinedParams;
end

if nargin==3 && strcmp(ifFull, 'full')
    for i=1:length(YY)
        YY{i} = bsxfun(@times, YY{i}, ones(size(X)));
    end
end
