function spikes = UpdateTrials(spikes,sweeps)
% This function is used to update the number trials that correspond to the
% field that the spikes struct has been filtered on. 
%
% INPUTS
%   spikes:
%   sweeps: The sweeps struct is
%
% OUTPUTS
%   spikes:
%
%   3/15/10 - SRO
% 04.07.10 update BA 

if nargin < 2
    sweeps = spikes.sweeps;
end

if isempty(spikes.spiketimes)
    spikes.trialsInFilter = [];
    spikes.sweeps(1).trialsInFilter = []; % index of 1 is necessary else will crash when sweeps is empty
else
    spikes.sweeps.trialsInFilter = [1:length(sweeps.trials)];
    spikes.trialsInFilter = nan(size(spikes.trials));
    for i = 1:length(sweeps.trials)
        spikes.trialsInFilter(spikes.trials == sweeps.trials(i)) = i;
    end
end

% if any(isnan(spikes.trialsInFilter) )% error checking
%     error('not every spikes.trialsInFilter got a value something is wrong')
% end



