function unit = populateUnit_spfPref(unit, curExpt, curTrodeSpikes,varargin)

% NOTE ASSUMES THAT spf is varparam2
[fileInd stimulusstruct]= spffileIndHelper(curExpt);

if ~isempty(fileInd)
    % kluge becuase not all units have the same spf stimuli
    % in some cases there was not variation in spf
    if  length(stimulusstruct.varparam)>1
        colVar = 1; % assume spf is var 2
    else colVar = 0; end % if only 1 var assume that spf is changing
    
    stimCond = getStimCode(curExpt,fileInd,colVar);
    
    fr.stim =  unit.spfRates.stim(:,1); % for first condition (assume first condition is ctrl)
    % find index of spf that evokes the highest average psth in stim window
    indopt = find(fr.stim == max(fr.stim),1,'first');
   
    spfPref = stimCond.values(indopt);
else % spf didn't vary us the one value as the prefered value
    fileInd = curExpt.analysis.orientation.fileInd;
    
    if isempty(fileInd)
        spfPref = NaN;
    else
        stimulusstruct = curExpt.stimulus(fileInd(1));        
        spfPref = stimulusstruct.params.spfreq;
    end
end

if spfPref==0 || spfPref>2 % debug
    keyboard
end

unit.spfPref = spfPref;
