function [spikeCount spikes bin_end] = addSpikeCountMatrix_spikes(spikes,WOI,options)

if nargin<3
    options = [];
end

if ~isfield(options,'AlignEvent')
    options.AlignEvent = 'TrialInit';
end
if ~isfield(options,'binsize')
    options.binsize = [500 100];
end
% helper create trials x timebin x unit

WOIbin_end = WOI; % this is the WOI defining the ENDs of the bins

bin_end = WOIbin_end(1);
nsteps = (WOIbin_end(2)-WOIbin_end(1))/options.binsize(2);

bin_end = linspace(bin_end,WOIbin_end(2),nsteps+1);
bin_start = bin_end-options.binsize(1);

[~, ~, tempspikes] = relativeSpiketimes_spikes(spikes,options.AlignEvent,[bin_start(1) bin_end(end)]);



nUnits = size(tempspikes.Analysis.EUPlusLabel,1);
EUPlus = tempspikes.Analysis.EUPlusLabel;
EU = cell2mat(EUPlus(:,1:2));
spikeCount= zeros(tempspikes.sweeps.ntrials,length(bin_end),nUnits);

for itrial = 1:tempspikes.sweeps.ntrials
%     tic
        for iunit = 1:nUnits
            Electrode = EU(iunit,1);
            UnitID =  EU(iunit,2);
%             thisUnit = filtspikes(tempspikes,0,{'Electrode',Electrode,'Unit',UnitID,'spikeTimeRelativeToEvent_trial',itrial});
            ind = tempspikes.Electrode== Electrode & tempspikes.Unit== UnitID  & tempspikes.spikeTimeRelativeToEvent_trial == itrial;
            theseSpikeTimes = tempspikes.spikeTimeRelativeToEvent(ind);
            if ~isempty(theseSpikeTimes)
                for ibin = 1:length(bin_end)
%                     temp = histc(theseSpikeTimes,[bin_start(ibin) bin_end(ibin)]);
%                     spikeCount(itrial,ibin,iunit) = temp(1);
                    spikeCount(itrial,ibin,iunit) = sum(theseSpikeTimes > bin_start(ibin) & theseSpikeTimes <=bin_end(ibin));
                end
            end
        end
%         toc
end

if nargout >1
spikes.sweeps.spikeCount = spikeCount;
end