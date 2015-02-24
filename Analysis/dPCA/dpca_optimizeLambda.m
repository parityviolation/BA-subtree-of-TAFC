function [optimalLambda, optimalLambdas] = dpca_optimizeLambda(Xfull, numComps, combinedParams, firingRatesPerTrial, numOfTrials, numRep, filename)

%lambdas = [1e-07 1e-6:1e-6:1e-05 2e-05:1e-05:1e-04 1e-03];
lambdas = 1e-07 * 1.5.^[0:25];
%numCompsToCheck = [0:10 100 500];% 15:5:50];

tic
Xsum = bsxfun(@times, Xfull, numOfTrials);

X = Xfull(:,:);
X = bsxfun(@minus, X, mean(X,2));

for rep = 1:numRep
    fprintf(['Repetition # ' num2str(rep)])
    
    Xtest = dpca_getTestTrials(firingRatesPerTrial, numOfTrials);
    Xtrain = bsxfun(@times, Xsum - Xtest, 1./(numOfTrials-1));
    
    X = Xtest(:,:);
    X = bsxfun(@minus, X, mean(X,2));
    XfullCen = reshape(X, size(Xfull));
    Xmargs = marginalize(XfullCen, combinedParams);
    totalVar = sum(X(:).^2);

    for l = 1:length(lambdas)
        fprintf('.')
        
        [W,V,whichMarg] = dpca(Xtrain, numComps, combinedParams, lambdas(l));
        
        cumError = 0;
        for i=1:length(Xmargs)
            Xmargs{i} = bsxfun(@times, Xmargs{i}, ones(size(XfullCen)));
            Xmarg = Xmargs{i}(:,:);
            margVar = sum(Xmarg(:).^2);
            
%             cm = find(whichMarg==i);
%             for c=1:length(numCompsToCheck)
%                 error = sum(sum((Xmarg - V(:,cm(1:numCompsToCheck(c)))*W(:,cm(1:numCompsToCheck(c)))'*X).^2));
%                 errorsMargNum(i, l, c, rep) = error/margVar;                
%             end
                
            error = sum(sum((Xmarg - V(:,whichMarg==i)*W(:,whichMarg==i)'*X).^2));
            cumError = cumError + error;
            
            errorsMarg(i, l, rep) = error/margVar;
        end
        
        errors(l,rep) = cumError/totalVar;
    end
    fprintf('\n')
end

timeTaken = toc;

meanError = mean(errors,2);
[~, ind] = min(meanError);
optimalLambda = lambdas(ind);

meanErrorMarg = mean(errorsMarg(:, :,:), 3);
[~, indm] = min(meanErrorMarg, [], 2);
optimalLambdas = lambdas(indm);

if ~isempty(filename)
    save(filename, 'lambdas', 'errors', 'errorsMarg', 'optimalLambda', 'optimalLambdas', 'numComps', 'timeTaken')
end

figure
set(gca, 'XTick', 1:length(lambdas))
set(gca, 'XTickLabel', lambdas)
hold on
plot(meanError, 'k', 'LineWidth', 2)
%plot(errors, 'b')
plot(ind, meanError(ind), '.b', 'MarkerSize', 30)
plot(meanErrorMarg', 'LineWidth', 1)
plot(xlim, [1 1], 'k')

