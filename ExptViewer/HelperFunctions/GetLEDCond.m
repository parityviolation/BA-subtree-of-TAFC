function LEDCondout = GetLEDCond(data)
%
%
%   Created: 8/2/10 - BA
buse_aoobject = 1;
persistent LEDCond SaveName
rigDef = RigDefs;
if buse_aoobject
    LEDchn = cell2mat(rigDef.ao.HwChannel);
else % get LED value from Analog in
    % REQUIRES data input
    LEDchn = cell2mat(rigDef.led.AIChan);
end
global AIOBJ
Trigger = AIOBJ.TriggersExecuted;
TriggerRepeat = AIOBJ.TriggerRepeat;
LoggingMode = AIOBJ.LoggingMode;
LogFileName = AIOBJ.LogFileName;


if strcmp(LoggingMode,'Disk&Memory')
    if Trigger == 1;
        LEDCond = [];
        SaveName = LogFileName;
        SaveName = SaveName(1:end-4);
        LEDCond = nan(length(LEDchn)+1,TriggerRepeat+1);
    end
    helperGetLEDcondtion;
    save([SaveName '_LEDCond'],'LEDCond');
else
    helperGetLEDcondtion;
end

% nested function
    function helperGetLEDcondtion
        
        if buse_aoobject
            % use ao object properties (SRO's version)
            ledSwCond = zeros(size(LEDchn)); % default to be zero
            global ao
            led = get(ao,'UserData');
            for ichn =1: length(led)
                if strcmp(led(ichn).Output,'on') &  strcmp(led(ichn).Engaged,'yes')
                    ledSwCond(ichn) = led(ichn).Amplitude(led(ichn).CurrentIndex.Amplitude);
                elseif strcmp(led(ichn).Output,'off') |  ~strcmp(led(ichn).Engaged,'yes')
                    ledSwCond(ichn)  =  0;
                end
            end
            LEDCond(:,Trigger) = [now ledSwCond]';
        else % use ai channel
            ledSwCond = zeros(size(LEDchn)); % default to be zero
            for ichn = LEDchn
                ind =  find(LEDchn==ichn);
                ledSwCond(ind)= max(data(:,ichn));
            end
            LEDCond(:,Trigger) = [now ledSwCond]';
        end
    end

LEDCondout  = LEDCond;
end
