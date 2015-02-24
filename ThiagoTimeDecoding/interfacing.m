function [counts, meanFr] = interfacing(spikes)
meanFr = [];

bounds = [1000 3000];
bin = 500;
nstep = 50;
stepsize = bin/nstep;
nbins = (bounds(2)+bounds(1))/(bin/nstep)+1;
alignEvent = 'TrialInit';
edges = [-bounds(1)-bin : stepsize : bounds(2)];
% nTrials = max(unique(spikes.TrialNumber));
nTrials = length(spikes.sweeps.ChoiceCorrect);

M = zeros(nbins+nstep,nbins);
ndx = [ones(nstep,1); zeros(nbins+1,1)];
ndx2 = repmat(ndx,nbins,1);
ndx3 = logical(ndx2(1:end-nbins));
M(ndx3) = 1;

counts = nan(nTrials,nbins,0);
E = unique(spikes.Electrode);
for e = E
    U = unique(spikes.Unit(spikes.Electrode==e));
    for u = U
        these_spikes = filtspikes(spikes,0,{'Electrode',e,'Unit',u});
        meanFr(end+1) = mean(histc(these_spikes.spiketimes,[these_spikes.spiketimes(1):bin:these_spikes.spiketimes(end)]))*1000/bin;
        
        [spikeTimeRelativeToEvent, trials] = relativeSpiketimes_spikes(these_spikes,alignEvent,bounds);
        fineCount = nan(nTrials,nbins+nstep);
        T = unique(trials);
        for t = T'
            fineCount(t,:) = histc(spikeTimeRelativeToEvent(trials==t),edges);
        end
        counts(:,:,end+1) = fineCount*M;        
    end
end
end