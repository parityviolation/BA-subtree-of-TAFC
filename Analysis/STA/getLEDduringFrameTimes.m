function ledstatus = getLEDduringFrameTimes(daqFileName,frametime_sample,LEDchns)

WOI = []; % Window what LED value must be low to beconsidered OFF during frame
LED_threshold = 0.9; % Volts


[data] = loadDAQData(daqFileName,LEDchns);

ledstatus = nan(length(frametime_sample),length(LEDchns));
if isempty(WOI) %   just considerd the LED status at frametime  
    ledstatus = data(frametime_sample,:)>LED_threshold;

else % WOI NOT IMPLEMENTED

end
