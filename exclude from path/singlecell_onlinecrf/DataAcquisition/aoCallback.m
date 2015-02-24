function aoCallback(aoobj,event)
%
%
%
%   Created: 3/24/10 - SRO
%   Modified: 4/3/10 - SRO
% BA Problem with this implementation: cannot have less than 500ms to
% putdata of next sweep before sweep starts
tic

global AIOBJ
if isrunning(AIOBJ) % this is for the case where ao is triggered by an external trigger (not AIOBJ)
    % and you only want an output when aiobj is running data
    aoWavObj = get(aoobj,'UserData');
    aiTrigger = AIOBJ.TriggersExecuted;
    TriggerFrequency = aoWavObj.TriggerFrequency;
    
    TriggerState = mod(aiTrigger,TriggerFrequency);    % Will be zero when trigger is multiple of aiTrigger
    if ~TriggerState
        for i = 1:length(aoWavObj)
            aoWavObj(i).Output = 'on';
        end
    else
        for i = 1:length(aoWavObj)
            aoWavObj(i).Output = 'off';
        end
    end
%     aoWavObj(1).Output % for debugging... 
    % Generate output waveform
    allWaveforms = [];
    engagedChn = getengagedChn(aoWavObj);
    for i = 1:length(engagedChn)
        if engagedChn(i)
                aoWavObj(i).Waveform = MakeOutputWaveform(aoWavObj(i));
            allWaveforms = [allWaveforms aoWavObj(i).Waveform];
        end
    end
    set(aoobj,'UserData',aoWavObj);
    putdata(aoobj,allWaveforms);
   
    start(aoobj);
end
%
% %
% disp('Time to put data in analog out engine');
% disp(toc);

function engagedChn = getengagedChn(aoWavObj)

for i = 1:length(aoWavObj)
    engagedChn(i) = strcmp(aoWavObj(i).Engaged,'yes');
end
engagedChn = logical(engagedChn);

