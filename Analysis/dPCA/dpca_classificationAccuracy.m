function [accuracy, brier] = dpca_classificationAccuracy(Xfull, numComps, combinedParams, lambda, firingRatesPerTrial, numOfTrials, numRep, classesMarg, verbosity)

Xsum = bsxfun(@times, Xfull, numOfTrials);

timeComp = [];
for k = 1:length(combinedParams)
    if combinedParams{k}{1} == length(size(Xfull))-1
        timeComp = k;
        break
    end
end

numCompsToUse = repmat(numComps, [1 length(combinedParams)]);
numCompsToUse(timeComp) = 0;

dim = size(Xfull);
cln = {};
for i=1:length(dim)-2
    cln{i} = ':';
end

% compute dPCA on the full data
[~, Vfull, ~] = dpca(Xfull, numCompsToUse, combinedParams, lambda);

for rep = 1:numRep
    if strcmp(verbosity, 'verbose')
        display(['Repetition #' num2str(rep)])
    elseif strcmp(verbosity, 'dots')
        fprintf('.')
    end
    
    Xtest = dpca_getTestTrials(firingRatesPerTrial, numOfTrials);
    Xtrain = bsxfun(@times, Xsum - Xtest, 1./(numOfTrials-1));
    
    [W,V,whichMarg] = dpca(Xtrain, numCompsToUse, combinedParams, lambda);
    
    crosscorr = corr([V Vfull]);
    crosscorr = abs(crosscorr(size(V,2)+1:end, 1:size(V,2)));
    %figure;imagesc(crosscorr); hold on
    for marg = setdiff(1:length(combinedParams), timeComp)
        d = find(whichMarg==marg);
        crc = crosscorr(d, d);
        order = [];
        for i=1:length(d)
            leftOver = setdiff(1:length(d), order);
            [~, num] = max(crc(leftOver,i));
            order(i) = leftOver(num);
        end
        %plot(d, d(order), 'k*', 'MarkerSize', 20)
        [~, order] = max(crc);
        W(:,d) = W(:, d(order));
        V(:,d) = V(:, d(order));
    end
    
    Xtrain2D = Xtrain(:,:);
    centeringTrain = mean(Xtrain2D,2);
    Xtrain2D = bsxfun(@minus, Xtrain2D, centeringTrain);
    Xtest2D  = Xtest(:,:);
    Xtest2D  = bsxfun(@minus, Xtest2D,  centeringTrain);
    
    % skip time marginalization
    for marg = setdiff(1:length(combinedParams), timeComp)
        for d = find(whichMarg==marg)
            % now we want to test linear decoder W(:,d) at each time point
            % t and see if it decodes classes in this marginalization
            % correctly, on the test pseudo-ensemble
            
            XtrainComp = reshape(W(:,d)'*Xtrain2D, dim(2:end));
            XtestComp  = reshape(W(:,d)'*Xtest2D,  dim(2:end));
            
            % for debugging
            if false
                figure
                subplot(121)
                plot(squeeze(XtrainComp(:,1,:))','b')
                hold on
                plot(squeeze(XtrainComp(:,2,:))','r')
                subplot(122)
                plot(squeeze(XtestComp(:,1,:))','b')
                hold on
                plot(squeeze(XtestComp(:,2,:))','r')
            end
            
            for t=1:dim(end)
                c = {cln{:}, t};
                trainClasses = XtrainComp(c{:});
                trainClasses = trainClasses(:);
                trainClassMeans = accumarray(classesMarg{marg}(:), trainClasses, [], @mean);
            
                testValues = XtestComp(c{:});
                testValues = testValues(:);
                
                dist = bsxfun(@minus, testValues, trainClassMeans');
                [~, classification] = min(abs(dist), [], 2);
                
                correctClassifications(d, t, rep) = length(find(classification == classesMarg{marg}(:)));
                
                prob = 1./abs(dist);
                prob = bsxfun(@times, prob, 1./sum(prob,2));
                actual = zeros(size(prob));
                actual(sub2ind(size(actual), (1:size(actual,1))', classesMarg{marg}(:))) = 1;
                
                brier(d, t, rep) = sum(sum((prob-actual).^2)) / length(unique(classesMarg{marg}));
            end
        end
    end
end

for i=1:length(classesMarg)
    numClasses(i) = length(unique(classesMarg{i}));
end
numConditions = prod(dim(2:end-1));

accuracy = bsxfun(@times, sum(correctClassifications, 3), 1./(numRep*numConditions));
brier = bsxfun(@times, sum(brier,3), 1./(numRep*numConditions));

if strcmp(verbosity, 'verbose')
    figure
    for i=1:size(accuracy,1)
        subplot(size(accuracy,1)/3,3,i)
        axis([1 size(accuracy,2) 0 1])
        hold on
        plot(xlim, 1/numClasses(whichMarg(i))*[1 1], 'k')
        plot(accuracy(i,:))
        
        plot(brier(i,:), 'r')
    end
end

