function unit = populateUnit_spfRates(unit, curExpt, curTrodeSpikes,varargin)


expt = curExpt;
spikes = curTrodeSpikes;

% Set stimulus time window
w = expt.analysis.orientation.windows; % FIX THIS
collapseVar = 1;
fileInd = spffileIndHelper(expt);
if isempty(fileInd)
    fr = NaN;
else
    % Filter spikes on files and assign
    spikes = filtspikes(spikes,0,'fileInd',fileInd,'assigns',unit.assign);
    
    % Make stimulus struct for spf
    stim = getStimCode(expt,fileInd,collapseVar);
    
    % Make condition struct
    cond = expt.analysis.orientation.cond;  % FIX THIS
    
    % If using all trials
    if strcmp(cond.type,'all')
        spikes.all = ones(size(spikes.spiketimes));
        cond.values = {1};
    end
    % BA kluge condition LED
    spikes = fixLEDcond_helper(expt,spikes,cond.values);
    
    % Compute evoked firing rate
    
    fr = computeResponseVsStimulus(spikes,stim,cond,w);
    
    if all(isnan(fr.stim))
        keyboard % debugging
    end
end
% Assign rate to unit struct
unit.spfRates = fr;


end