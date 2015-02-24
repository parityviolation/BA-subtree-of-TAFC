function DataViewerSamplAcqCallback(obj, event, hDataViewer)
% BVA
benableSound =1;
soundChn =3;

% Get all plot vectors (stored in the struct, dv)
dv = dvCallbackHelper(hDataViewer);

dv.MaxPoints = 20000;
dv.Fs = obj.SampleRate;
Fs = dv.Fs;
soundDownSampleFactor = 6;
% SOUND
% asound = analogoutput('winsound', 0);
% addchannel(asound, [1 2]);
% set(asound, 'StandardSampleRates','Off')
% set(asound , 'SampleRate', Fs/soundDownSampleFactor);

% Get data
% WB - 8/6/10 - if n > 1 triggers elapsed before this callback ran, we must
% loop through them (fixing our TriggerNum index each time) since online analysis functions (e.g. PSTH) expect to
% be run every trigger
doOnce = 1; % BA was 0

% this forces the loop to run before a complete set of data exists! BA

TriggerNum = obj.TriggersExecuted;

nn = 0; %BA debugging variable
while (obj.SamplesAvailable >= obj.SamplesPerTrigger) || (~doOnce) && TriggerNum>0
    
    TriggerNum = obj.TriggersExecuted;
    %disp(['DataViewerSampleAcqCallback: TriggerNum = ', num2str(TriggerNum), ' .'])
    if(obj.SamplesAvailable > obj.SamplesPerTrigger)
        triggersMissed = ceil(obj.SamplesAvailable / obj.SamplesPerTrigger) - 1;
        TriggerNum = TriggerNum - triggersMissed;
        %disp(['Samples acquired callback missed ', num2str(triggersMissed) , ' triggers, & is now catching up: proc. trigger ', num2str(TriggerNum)]);
    end
    
    % BA count how much: PROBLEM loop runs multiple times with same triggerNum occurs!!!!
    % BA this code only catches multiple times within the while loop (not
    % if the function is recalled)
    if exist('TriggerNumOld','var')
        if TriggerNum==TriggerNumOld
            display(sprintf('%d,  TriggerNum %d',nn,TriggerNum));
        end
    end
    TriggerNumOld = TriggerNum;
    
    sizeData = min(obj.SamplesPerTrigger, obj.SamplesAvailable);
    gain = 200;
    data = getdata(obj,sizeData)/gain*1e6 ; % convert data to uV (assume comes in as mV)
    
    if benableSound
        sound(data(1:soundDownSampleFactor:end,soundChn),Fs/soundDownSampleFactor)
    end
    %     sounddata = [data(1:soundDownSampleFactor:end,soundChn)];
    %     stop(asound)
    %     putdata(asound, [sounddata sounddata]);
    %     start(asound)
    %
    % Process and display data
    spiketimes = dvProcessDisplay(dv,data,hDataViewer); % spiketimes is a cell array
    drawnow
    tic
    
    
    % --- Online analysis --- %
    % Determine whether LED being used, if so, get LED condition
    % full stimulus / led condition matrices containing data for all triggers
    stimconds = getappdata(hDataViewer, 'StimCondData');
    %     disp('stimulus condition = '); disp(stimconds(2,1:TriggerNum));
    % %     disp('Triggers stimulus condition is NAN= '); disp(sum(isnan(stimconds(2,1:TriggerNum))));
    
    
    % stimulus / led condition for this trigger
    thisStimCond = stimconds(:,TriggerNum);
    
    
    % BA update GUI with Stim values
    hvstim = getappdata(hDataViewer,'hvstim');
    set(hvstim,'String',num2str(thisStimCond(2),'%d'))
    try
        thisLEDCond = nan(2,1);
        if getappdata(hDataViewer,'bLED');
            ledconds = getappdata(hDataViewer, 'LEDCondData');
            %         if TriggerNum>1,
            %             temp = sum(diff(ledconds(2,1:TriggerNum)>1)==0);
            %             if temp
            %             disp(['Triggers led condition NOT switched= ' num2str(temp)]);
            %             end
            %         end
            
            for j = 2:size(ledconds,1)
                iled = j-1;
                thisLEDCond(iled) = ledconds(j,TriggerNum);
            end
            
        end
    catch
    end
    % BA update GUI with LED values
    hled1 = getappdata(hDataViewer,'hled1');
    set(hled1,'String',num2str(thisLEDCond(1),'%1.2g'))
    if thisLEDCond(1) > 0.5,  set(hled1,'ForegroundColor','r');
    else set(hled1,'ForegroundColor','k'); end
    hled2 = getappdata(hDataViewer,'hled2');
    set(hled2,'String',num2str(thisLEDCond(2),'%1.2g'))
    if thisLEDCond(2) > 0.5,  set(hled2,'ForegroundColor','g');
    else set(hled2,'ForegroundColor','k'); end
    
    % PSTHTuning
    try
        if getappdata(hDataViewer,'psthTuneON')
            
            % collapse 2nd variable
            vstim = getappdata(hDataViewer,'vstim') ;% this is
            if length(vstim.VarParam)>1
                thisStimCond(2) = (floor((thisStimCond(2)-1)/length(vstim.VarParam(2).Values))+1);
            end
            
            cond.stim = thisStimCond;
            cond.led = max(thisLEDCond); % BA hack so don't have to deal with multiple LEDs in online analysis yet
            %         disp(thisLEDCond)
            temp = guidata(hDataViewer);
            h = guidata(temp.psthTune.psthFigTuning);
            h = updateOnlinePSTHTuning(h,spiketimes,cond);
            guidata(h.psthFigTuning,h);
        end
    catch ME
        getReport(ME)
    end
    % PSTH
    try
        if getappdata(hDataViewer,'psthON')
            cond.stim = thisStimCond;
            cond.led = max(thisLEDCond); % BA hack so don't have to deal with multiple LEDs in online analysis yet
            %         disp(thisLEDCond)
            temp = guidata(hDataViewer);
            h = guidata(temp.psth.psthFig);
            h = updateOnlinePSTH(h,spiketimes,cond);
            guidata(h.psthFig,h);
        end
    catch ME
        getReport(ME)
    end
    try
        % Mean firing rate vs time
        if getappdata(hDataViewer,'frON')
            cond.stim = thisStimCond;
            cond.led = max(thisLEDCond); % BA hack so don't have to deal with multiple LEDs in online analysis yet
            
            temp = guidata(hDataViewer);
            h = guidata(temp.fr.frFig);
            h = updateOnlineFR(h,spiketimes,cond);
            guidata(h.frFig,h);
        end
    catch ME
        getReport(ME)
    end
    
    try% LFP analysis
        if getappdata(hDataViewer,'lfpON')
            cond.stim = thisStimCond;
            cond.led = max(thisLEDCond); % BA hack so don't have to deal with multiple LEDs in online analysis yet
            temp = guidata(hDataViewer);
            h = guidata(temp.lfp.lfpFig);
            h = updateOnlineLFP(h,data,cond);
            guidata(h.lfpFig,h);
        end
    end
    try
        % Spatial receptive field
        if getappdata(hDataViewer,'srfON')
            temp = guidata(hDataViewer);
            h = guidata(temp.srf.srfFig);
            h = updateOnlineSRF(h,spiketimes,stimcond);
            guidata(h.srfFig,h);
        end
    end
    
    %disp(['Finished processing TriggerNum = ', num2str(TriggerNum), ', samples remaining/samples per trigger = ', num2str(obj.SamplesAvailable/obj.SamplesPerTrigger)])
    doOnce = 1;
end

% Update GUI objects
hTriggerNum = getappdata(hDataViewer,'hTriggerNum');
TriggerNum = obj.TriggersExecuted-1;
set(hTriggerNum,'String',TriggerNum);

% now we draw / update GUI
drawnow
% stop(asound)
% delete(asound);
% --- End online analysis --- %



