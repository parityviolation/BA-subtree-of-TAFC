function unit = populateUnit_contRates(unit, curExpt, curTrodeSpikes,varargin)


expt = curExpt;
spikes = curTrodeSpikes;

% Set stimulus time window
w = expt.analysis.contrast.windows;

% Get fileInd for orientation files
fileInd = expt.analysis.contrast.fileInd;
if isempty(fileInd)
    fr = NaN;
    frsem = NaN;
else
    % Filter spikes on files and assign
    spikes = filtspikes(spikes,0,'fileInd',fileInd,'assigns',unit.assign);
    
    % Make stimulus struct for orientation
    % ** collapse 2nd variable
     stim = getStimCode(expt,fileInd,2);

     % Make condition struct
    cond = expt.analysis.contrast.cond;
    
    % If using all trials
    if strcmp(cond.type,'all')
        spikes.all = ones(size(spikes.spiketimes));
        cond.values = {1};
    end
    % BA kluge condition LED
    spikes = fixLEDcond_helper(expt,spikes,cond.values);
    
    % Compute evoked firing rate
    [fr ,~ ,frsem]  = computeResponseVsStimulus(spikes,stim,cond,w,0);
    
    if all(isnan(fr.stim))
        keyboard % debugging
    end
end
% Assign rate to unit struct
unit.contRates.mn = fr;
unit.contRates.sem = frsem;

