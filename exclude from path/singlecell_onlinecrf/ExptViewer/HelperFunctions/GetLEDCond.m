function ledSwCond = GetLEDCond(Trigger,TriggerRepeat,LoggingMode,LogFileName)
%
%
%   Created: 3/10 - SRO
%   Modified: 4/5/10 - SRO

global ao
persistent LEDCond SaveName
led = get(ao,'UserData');

if strcmp(LoggingMode,'Disk&Memory')
    if Trigger == 1;
        LEDCond = [];
        SaveName = LogFileName;
        SaveName = SaveName(1:end-4);
        LEDCond = nan(2,TriggerRepeat+1); 
    end
    if strcmp(led(1).Output,'on') % BA could this ever by the wrong trial?
        LEDCond(:,Trigger) = [now led(1).Amplitude];
    elseif strcmp(led(1).Output,'off')
        LEDCond(:,Trigger) = [now 0];
    end
    save([SaveName '_LEDCond'],'LEDCond');
    ledSwCond = round(LEDCond(2,Trigger));
else
    if strcmp(led(1).Output,'on')
        ledSwCond = led(1).Amplitude;
    elseif strcmp(led(1).Output,'off')
        ledSwCond = 0;
    end
end


