% This section creates artificial random data.
%
% It should be replaced by actual experimental data. The data should be
% joined in three arrays of the following sizes (for the Romo-like task):
%
% trialNum: N x S x D
% firingRates: N x S x D x T x maxTrialNum
% firingRatesAverage: N x S x D x T
%
% N is the number of neurons
% S is the number of stimuli conditions (F1 frequencies in Romo's task)
% D is the number of decisions (D=2)
% T is the number of time-points (note that all the trials should have the
% same length in time!)
%
% trialNum -- number of trials for each neuron in each S,D condition (is
% usually different for different conditions and different sessions)
%
% firingRates -- all single-trial data together, massive array. Here
% maxTrialNum is the maximum value in trialNum. E.g. if the number of
% trials per condition varied between 1 and 20, then maxTrialNum = 20. For
% the neurons and conditions with less trials, fill remaining entries in
% firingRates with zeros or nans.
%
% firingRatesAverage -- average of firingRates over trials (5th dimension).
% If the firingRates is filled up with nans, then it's simply
% nanmean(firingRates,5). If it's filled up with zeros (as is convenient if
% it's stored on hard drive as a sparse matrix), then one needs loops to
% compute the average.



%% Select neurons and time interval, define parameter grouping

% selecting neurons that have at least 5 trials in each condition
D = size(trialNum,1);
minN = min(reshape(trialNum(:,:,:), D, []), [], 2);
n = find(minN >= 2);

% selecting time interval (the whole trial)
t = 1:length(time);

% parameter groupings
% 1 - stimulus
% 2 - decision
% 3 - time
% [1 3] - stimulus/time interaction
% [2 3] - decision/time interaction
% [1 2] - stimulus/decision interaction
% [1 2 3] - rest
% Here we group stimulus with stimulus/time interaction etc. Don't change
% that if you don't know what you are doing :)
combinedParams = {{1, [1 3]}, {2, [2 3]}, {3}, {[1 2], [1 2 3]}};
margNames = {'Stimulus', 'Decision', 'Time', 'S/D Interaction'};



%% Compute optimal reguralization parameters with cross-validation

% Check the optimalLambdas that you get. If they are close to each other,
% try using the single optimalLambda (one value for all marginaliations).
%
% The function takes some minutes to run. It will save the computations 
% in a mat file with a given name. Once computed, you can simply load 
% lambdas out of this file:
%
% load('tmp_optimalLambdas.mat', 'optimalLambda')

[optimalLambda, optimalLambdas] = dpca_optimizeLambda(firingRatesAverage(n,:,:,t), [10 10 10 10], ...
        combinedParams, firingRates(n,:,:,t,:), trialNum(n,:,:), ...
        10, 'tmp_optimalLambdas.mat');

%% First without classification

% It takes a lot of time to run the classification analysis (see below), so
% first we will do without it.

componentsSignif = [];

%%Compute the dPCA projection

% This is the core function.
%
% W is the decoder, V is the encoder (ordered by explained variance),
% whichMarg is an array that tells you which component comes from which
% marginalization
[W,V,whichMarg] = dpca(firingRatesAverage(n,:,:,t), 50, combinedParams, optimalLambda);

%% Plot

% Plots the data
%
% dpca_plot_SDT is used to plot each single component, and can be edited
% to adjust colors, lines etc.
%
% [30 40 140 60] input provides span of y-axis for components in each
% marginalization, should be adjusted to the data
%
% 10 - subplot number that specifies the position of the legend

dpca_plot(firingRatesAverage(n,:,:,t), W, V, combinedParams, whichMarg, ...
    time(t), timeEvents, [12 30 40 20], componentsSignif, 10, [], margNames, @dpca_plot_SDT)

% %% Decoding
% 
% % Classification accuracy for each dPCA component. Performs 100
% % cross-validation iterations. Can take ~10 minutes to compute. Reduce 100
% % to some small number (like 5) for a quicker sanity test.
% 
% [accuracy, brier] = dpca_classificationAccuracy(firingRatesAverage(n,:,:,t), 3, combinedParams, ...
%     optimalLambda, firingRates(n,:,:,t,:), trialNum(n,:,:), 100, ...
%     {[1 1; 2 2], [1 2; 1 2], [], [1 2; 3 4]}, 'verbose');
% save('tmp_classification.mat', 'accuracy', 'brier')
% 
% % Classification accuracy once the data is shuffled. Performs 100 shuffles
% % of 100 CV iterations each. Takes A LOT of time, hours.
% 
% [accuracyShuffle, brierShuffle] = dpca_classificationShuffled(combinedParams, ...
%     optimalLambda, firingRates(n,:,:,t,:), trialNum(n,:,:), 100, ...
%     {[1 1; 2 2], [1 2; 1 2], [], [1 2; 3 4]}, 100, 'tmp_classification.mat');
% 
% % Once the above calculations are done, replace them by
% % load 'tmp_classification.mat'
% 
% % Plots the decoding accuracies for each tested component
% dpca_accuracyPlot(time(t), accuracy, brier, accuracyShuffle, brierShuffle, [2 2 2 2 2 2 4 4 4], 99, 4)
% 
% % Finds significant components
% componentsSignif = dpca_signifComponents(accuracy, accuracyShuffle, whichMarg, combinedParams, 3, 10);
% 
% %% Once the decoding analysis is done
% 
% % Exactly the same line as above
% 
% dpca_plot(firingRatesAverage(n,:,:,t), W, V, combinedParams, whichMarg, ...
%     time(t), timeEvents, [30 40 140 60], componentsSignif, 10, [], margNames, @dpca_plot_SDT)
% 
% 
