function [accuracyShuffle, brierShuffle] = dpca_classificationShuffled(combinedParams, lambda, firingRatesPerTrial, numOfTrials, numRep, classesMarg, numShuffles, filename)

tic

display('Preprocessing...')

D = size(numOfTrials,1);
dim = size(firingRatesPerTrial);
T = dim(end-1);
maxTrialN = size(firingRatesPerTrial, ndims(firingRatesPerTrial));
numCond = prod(dim(2:end-2));

% find missing trials
numOfTrialsCond = reshape(numOfTrials, D, []);
trialsMissing = zeros(D, maxTrialN*numCond);
for n=1:D
    this = zeros(numCond, maxTrialN);
    for c=1:numCond
        this(c,:) = [zeros(1,numOfTrialsCond(n,c)) ones(1,maxTrialN-numOfTrialsCond(n,c))];
    end
    trialsMissing(n,:) = this(:);
end

% collapsing conditions
orderDim = 1:ndims(firingRatesPerTrial);
orderDim(end-1:end) = orderDim([end end-1]);
firingRatesPerTrialCond = permute(firingRatesPerTrial, orderDim); % time shifted to the end
firingRatesPerTrialCond = reshape(firingRatesPerTrialCond, D, [], T);

for shuffle = 1:numShuffles
    fprintf(['Shuffle #' num2str(shuffle) ': shuffling... '])
        
    % shuffling PSTHs inside each neuron (preserving time and numOfTrials)
    firingRatesPerTrialCondShuffle = zeros(size(firingRatesPerTrialCond));
    for n = 1:D
        presentTrials = find(trialsMissing(n,:) == 0);
        shuffledOrder = presentTrials(randperm(length(presentTrials)));
        firingRatesPerTrialCondShuffle(n,presentTrials,:) = ...
            firingRatesPerTrialCond(n,shuffledOrder,:);
    end    
    firingRatesPerTrialShuffle = permute(reshape(firingRatesPerTrialCondShuffle, dim(orderDim)), ...
        orderDim);
    clear firingRatesPerTrialCondShuffle

    firingRatesAverageShuffle = sum(firingRatesPerTrialShuffle, ndims(firingRatesPerTrialShuffle));
    firingRatesAverageShuffle = bsxfun(@times, firingRatesAverageShuffle, 1./numOfTrials);
    
    fprintf('cross-validating')
    [accuracy, brier] = dpca_classificationAccuracy(firingRatesAverageShuffle, 1, combinedParams, lambda, firingRatesPerTrialShuffle, numOfTrials, numRep, classesMarg, 'dots');
    accuracyShuffle(:,:,shuffle) = accuracy;
    brierShuffle(:,:,shuffle) = brier;
    
    fprintf('\n')
    clear firingRatesPerTrialShuffle firingRatesAverageShuffle
    
    if ~isempty(filename)
        save(filename, 'accuracyShuffle', 'brierShuffle', '-append')
    end
end

timeTaken = toc;
if ~isempty(filename)
    save(filename, 'timeTaken', '-append')
end



