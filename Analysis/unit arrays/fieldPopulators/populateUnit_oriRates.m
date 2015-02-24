function unit = populateUnit_oriRates(unit, curExpt, curTrodeSpikes,varargin)


expt = curExpt;
spikes = curTrodeSpikes;

% Set stimulus time window
w = expt.analysis.orientation.windows;

% Get fileInd for orientation files
fileInd = expt.analysis.orientation.fileInd;
if isempty(fileInd)
    fr = NaN;
    frsem = NaN;
    frsub = NaN;
    frsemsub = NaN;
    rates_in_alltrials = NaN;
else
    % Filter spikes on files and assign
    spikes = filtspikes(spikes,0,'fileInd',fileInd,'assigns',unit.assign);
    
    % Make stimulus struct for orientation
    % ** collapse 2nd variable
     stim = getStimCode(expt,fileInd,2);

     % Make condition struct
    cond = expt.analysis.orientation.cond;
    
    % If using all trials
    if strcmp(cond.type,'all')
        spikes.all = ones(size(spikes.spiketimes));
        cond.values = {1};
    end
    % BA kluge condition LED
    spikes = fixLEDcond_helper(expt,spikes,cond.values);
    
    % Compute evoked firing rate   
    [fr, ~, frsem] = computeResponseVsStimulus(spikes,stim,cond,w,0);
    [frsub, ~, frsemsub] = computeResponseVsStimulus(spikes,stim,cond,w,1);
    
    % get all trials
    [rates_in_alltrials temp] = stimbytrialbycondMatrix(spikes,stim,cond,w,0);
    
    if all(isnan(fr.stim))
        keyboard % debugging
    end
end
% Assign rate to unit struct
unit.oriRates.mn = fr;
unit.oriRates.sem = frsem;
unit.oriRates.mnsubspont = frsub;
unit.oriRates.semsubspont = frsemsub;
unit.oriRates.alltrials = rates_in_alltrials;

