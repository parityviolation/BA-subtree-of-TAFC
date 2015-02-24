function unit = populateUnit_orispontrate(unit, curExpt, curTrodeSpikes,varargin)

expt = curExpt;
spikes = curTrodeSpikes;

% Set spontaneous time window
w = expt.analysis.orientation.windows.spont;

% Compute spontaneous rate for orientation stimuli files
fileInd = expt.analysis.orientation.fileInd;

if ~isempty(fileInd)
% Filter spikes
spikes = filtspikes(spikes,0,'fileInd',fileInd,'assigns',unit.assign);

% Compute spontaneous firing rate
[fr fr_sem] = computeFR(spikes,w);

else
    fr = NaN; fr_sem = NaN;
end
% Assign rate to unit struct
unit.orispontrate = [fr; fr_sem];