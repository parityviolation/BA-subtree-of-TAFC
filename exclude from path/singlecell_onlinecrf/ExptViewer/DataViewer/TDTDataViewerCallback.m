function TDTDataViewerCallback(obj,event,hDataViewer,tdtparams)
% hDataViewer is the handle to the DataViewer GUI. This handle is used to
% access appdata stored in the DataViewer.
%
%
%   Created: 5/31/10 - BA (Modified DataViewerCAllback to make TDT
%   compatible)

% get last Epoc (Trigger executed)
chns = [1:2:16]; % TO DO read this of TDT (or pass in)

userdata =obj.UserData;

% Read Update current Tank and Block
tank = tdtparams.DA.GetTankName;
if invoke(tdtparams.TT,'OpenTank',tank,'R')~=1; sprintf('Failed Opening %s',tank); end
recblock = tdtparams.TT.GetHotBlock;
blkPATH = fullfile(tank,recblock);

try
    allEpocs = loadTDThelper_getEpocVal(blkPATH,[],1)   ;                           % Returns the Epoc events for Trigger returns a NaN event in this case
    thisTrigger = size(allEpocs ,2)-1;                           % Number Current Epoc/Trigger
    
    % Note, will only plot the last fully completed Sweep,
    % an Epoc may be complete, but at this time the Epoc marks the duration of
    % the stimulus so a sweep is longer than an Epoc.
    % Here the sweep/Trigger is considered complete when the next Epoc begins
    if thisTrigger>userdata.lastTriggerPlotted % check that there is a new trigger and it has finished
        userdata.lastTriggerPlotted = thisTrigger;
        TriggersExecuted = thisTrigger;
        % get current epoc
        
        % Get information about AIOBJ (aka obj) % BA commned out
        TriggerRepeat = tdtparams.TriggerRepeat;
        LoggingMode = NaN;
        LogFileName = recblock; % tank,block name
        SamplesPerTrigger = tdtparams.SamplesPerTrigger;
        if isnan(SamplesPerTrigger), disp('nan samples per'); end
        %
        % Get stimulus information
        stimcond = allEpocs(1,thisTrigger);
        % GetStimFileName(Trigger,LoggingMode,LogFileName);
        
        % Determine whether LED being used, if so, get LED condition
        bLED = 1; % getappdata(hDataViewer,'bLED'); % BA commented out
        if bLED
            ledcond = loadTDThelper_getTTL(blkPATH,[],[],0,1);
            ledcond = ledcond(1,thisTrigger);
        else
            ledcond = NaN;
        end
        
        % Get all plot vectors (stored in the struct, dv)
        dv = dvCallbackHelper(hDataViewer);
        
        dv.MaxPoints = 20000;
        dv.Fs = tdtparams.SampleRate;
        Fs = dv.Fs;
        
        % If samples per trigger is longer than 5 seconds, then 2 seconds of data
        % are shown at a time. This should be replaced with "scope mode",
        if SamplesPerTrigger > Fs*5
            SamplesRequested = Fs*2;
        else
            SamplesRequested = SamplesPerTrigger;
        end
         chns = dv.PlotVectorOn'; % get only channels that will be plotted
        [data] = loadTDTData(blkPATH,chns,thisTrigger,[],0);
        
        % Process and display data
        spiketimes = dvProcessDisplay(dv,data,hDataViewer);
        drawnow
        
        % --- Online analysis --- %
        
        % PSTH
        if getappdata(hDataViewer,'psthON')
            cond.stim = stimcond;
            cond.led = ledcond;
            temp = guidata(hDataViewer);
            h = guidata(temp.psth.psthFig);
            h = updateOnlinePSTH(h,spiketimes,cond);
            guidata(h.psthFig,h);
        end
        
        % Mean firing rate vs time
        if getappdata(hDataViewer,'frON')
            temp = guidata(hDataViewer);
            h = guidata(temp.fr.frFig);
            h = updateOnlineFR(h,spiketimes);
            guidata(h.frFig,h);
        end
        
        % LFP analysis
        if getappdata(hDataViewer,'lfpON')
            cond.stim = stimcond;
            cond.led = ledcond;
            temp = guidata(hDataViewer);
            h = guidata(temp.lfp.lfpFig);
            h = updateOnlineLFP(h,data,cond);
            guidata(h.lfpFig,h);
        end
        
        drawnow
        
        % --- End online analysis --- %
        
        % Update GUI objects
        hTriggerNum = getappdata(hDataViewer,'hTriggerNum');
        TriggerNum = TriggersExecuted;
        set(hTriggerNum,'String',TriggerNum);
        drawnow
        
        %     end
        
        obj.UserData = userdata;
        
    end
    
catch ME
    obj.UserData = userdata;
    
    getReport(ME)
end


