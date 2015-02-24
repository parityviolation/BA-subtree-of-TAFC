function aoWavObj = MakeAnalogOut(aoWavObj)
%
% INPUT:
%   aoWavObj:
%
% OUTPUT:
%   aoWavObj:
%
%
%   Created: 2/10 - SRO
%   Modified: 7/5/10 - BA

global AIOBJ        % Analog input object
global ao           % Analog output object

% Determine engaged LEDs
for i = 1:length(aoWavObj)
    engagedChn(i) = strcmp(aoWavObj(i).Engaged,'yes');
end
engagedChn = find(engagedChn == 1);

% Define AO object

ao = analogoutput('nidaq','Dev1');
ao.SampleRate = AIOBJ.SampleRate;
ActualRate = get(ao,'SampleRate');
for i = 1:length(engagedChn)
    chnInd = engagedChn(i);
    OutputRange = aoWavObj(chnInd).OutputRange;
    aochans(i) = addchannel(ao,aoWavObj(chnInd).HwChannel);
    aochans(i).OutputRange = [-1 1].*OutputRange;                       % V
    aochans(i).UnitsRange =  [-1 1].*aoWavObj(chnInd).UnitsRange;         % V

    aoWavObj(chnInd).SampleRate = ActualRate;
end

TriggerSource = aoWavObj(chnInd).TriggerSource;
% Define Trigger
TriggerType = 'HwDigital';
% TriggerType = 'Manual';

switch TriggerType
    case 'Manual'
        duration = 10;
        ao.RepeatOutput = 0;
        ao.TriggerType = 'Manual';
    case 'HwDigital'
        ao.RepeatOutput = 0;
        switch upper(TriggerSource)
            
            case 'AIOBJ'
                AIOBJ.ExternalTriggerDriveLine = 'RTSI0';       % RTSI bus line 0 is pulsed when data acquisition begins
                ao.TriggerType = 'HwDigital';
                ao.HwDigitalTriggerSource = 'RTSI0';            % RTSIO triggers analog out
                ao.TriggerCondition = 'PositiveEdge';
            otherwise
                ao.TriggerType = 'HwDigital';
                ao.HwDigitalTriggerSource = TriggerSource;% e.g. 'PFI0'
                ao.TriggerCondition = 'PositiveEdge';
                % to syncronize to AIOBJ 
                AIOBJ.StartFcn = {@helperStartAO,ao};
        end
end

% Define callback functions
ao.TriggerFcn = '';
ao.SamplesOutputFcn = '';
ao.StopFcn = @aoCallback;
% ao.StartFcn = @tempFunct;
% 

% Generate output waveform
allWaveforms = [];
for i = 1:length(engagedChn)
    chnInd = engagedChn(i);
    if aoWavObj(i).bchanged || isempty(aoWavObj(i).Waveform)
        aoWavObj(i).Waveform = MakeOutputWaveform(aoWavObj(i));
    end
    allWaveforms = [allWaveforms aoWavObj(i).Waveform];

end

% Put waveform in ao
putdata(ao,allWaveforms)
start(ao)

for i = 1:length(aoWavObj) % update bchanged after putdata as occured
aoWavObj(i).bchanged =  0; % this flag is set to 1 when aoWavObj is changed but MakeAnalogOut hasn't been updated
end
% Store aoWavObj in UserData in analog output object
set(ao,'UserData',aoWavObj);



function helperStartAO(obj,event,ao)
% function start
if ~isrunning(ao)
    aoWavObj = get(ao,'UserData');
    % Determine engaged LEDs
    for i = 1:length(aoWavObj)
        engagedChn(i) = strcmp(aoWavObj(i).Engaged,'yes');
    end
    engagedChn = find(engagedChn == 1);
    
    
    allWaveforms = [];
    for i = 1:length(engagedChn)
        chnInd = engagedChn(i);
        if aoWavObj(i).bchanged
            aoWavObj(i).Waveform = MakeOutputWaveform(aoWavObj(i));
        end
        allWaveforms = [allWaveforms aoWavObj(i).Waveform];
    end
    
    putdata(ao,allWaveforms);
    start(ao);
end

