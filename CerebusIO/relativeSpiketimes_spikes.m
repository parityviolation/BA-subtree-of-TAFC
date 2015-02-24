function [spikeTimeRelativeToEvent trials  spikeCountPerTrial spikes] = relativeSpiketimes_spikes(spikes,alignEvent,WOI,options)
% function [spikeTimeRelativeToEvent trials spikes spikeCountPerTrial] = relativeSpiketimes_spikes(spikes,alignEvent,WOI,options)

% BA
% crucial function for getting spiketimes relative to an event 

% WOI specifies the WOI relative to alignEvent to return the spikes

syncEvent = 'TrialAvail';
syncEventEphys = 'TrialAvailEphys';

if nargin>3
    if isfield(options,'syncEventEphys')
        syncEventEphys = options.syncEventEphys;
    end
    if isfield(options,'syncEvent')
        syncEvent = options.syncEvent;
    end
end


slabel = strrep(['spikeTimeRelativeTo' num2str(WOI,'_%d')  alignEvent],'-','n');
slabel(isspace(slabel)) = '';
slabeltrial = strrep(['trial_spikeTimeRelativeTo' num2str(WOI,'_%d') alignEvent],'-','n');
slabeltrial(isspace(slabeltrial)) = '';
slabelWOI = strrep(['WOIspikeTimeRelativeTo' num2str(WOI,'_%d')  alignEvent],'-','n');
slabelWOI(isspace(slabelWOI)) = '';
sweepsField = strrep(['spkCount_WOIspikeTimeRelativeTo' num2str(WOI,'_%d')  alignEvent],'-','n');
sweepsField(isspace(sweepsField)) = '';

% don't repeat this function if already exists in spikes
if isfield(spikes,slabel)
    if isequal(spikes.(slabelWOI),WOI)
        spikeTimeRelativeToEvent = spikes.(slabel);
        trials = spikes.(slabeltrial);
        spikeCountPerTrial = spikes.sweeps.(sweepsField);
        warning([slabel ' was not added it already exists']);
        return
    else
        spikes = rmfield(spikes,{slabel,slabeltrial});
        spikes.sweeps = rmfield(spikes.sweeps,{sweepsField});
    end
end
these_sweeps = spikes.sweeps;

spikeTimeRelativeToEvent = [];
trials = [];
spikeCountPerTrial = [];
ntrials = min(these_sweeps.nTrialsAvailEphysAndBehavior,these_sweeps.ntrials);

if nargout> 3, spikes.(slabel) = nan(size(spikes.spiketimes),'single'); spikes.(slabeltrial) = nan(size(spikes.spiketimes),'single'); ...
spikes.(slabelWOI) = WOI; spikes.sweeps.(sweepsField) = nan(size(spikes.sweeps.TrialAvail),'single'); end

for itrial = 1:ntrials
    eventTime = these_sweeps.(alignEvent)(itrial); % ms
    eventTimeEphys = these_sweeps.(syncEventEphys)(itrial) +...
        (eventTime - these_sweeps.(syncEvent)(itrial))*these_sweeps.ephysTimeScalar; %ms
    
    % get indices of spikes in the WOI
    spikeIndex = [(spikes.spiketimes >= (eventTimeEphys +WOI(1)) &...
        spikes.spiketimes <= (eventTimeEphys +WOI(2)))];
    if ~any(spikeIndex)
        spikeTimeRelativeToEvent(end+1) = NaN;
        trials(end+1) = itrial;
        spikeCountPerTrial(end+1) = 0;
    else
        spikeTimeRelativeToEvent = [spikeTimeRelativeToEvent spikes.spiketimes(spikeIndex) - eventTimeEphys];
        spikeCountPerTrial(end+1) = sum(spikeIndex);
        trials = [trials itrial*ones(1,spikeCountPerTrial(end))];
        if nargout> 3
            spikes.(slabel)(spikeIndex) = spikes.spiketimes(spikeIndex) - eventTimeEphys;
            spikes.(slabeltrial)(spikeIndex) = itrial;
            
        end
    end
   
end
if nargout> 3
spikes.sweeps.(sweepsField) = spikeCountPerTrial;
end
spikeTimeRelativeToEvent= spikeTimeRelativeToEvent';
trials = trials';
spikeCountPerTrial = spikeCountPerTrial';