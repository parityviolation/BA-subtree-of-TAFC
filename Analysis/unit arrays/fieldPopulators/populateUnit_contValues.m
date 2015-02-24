function unit = populateUnit_contValues(unit, curExpt, curTrodeSpikes,varargin)



% Get fileInd for orientation files
fileInd = curExpt.analysis.contrast.fileInd;

% Make stimulus struct for orientation
stim = makeStimStruct(curExpt,fileInd);

unit.contValues = stim.values;

