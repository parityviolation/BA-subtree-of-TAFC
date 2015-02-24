function DataViewerCallback(obj,event,hDataViewer)
% hDataViewer is the handle to the DataViewer GUI. This handle is used to
% access appdata stored in the DataViewer.
%
%
%   Created: 1/10 - SRO
%   Modifed: 4/5/10 - SRO
bDebug = 0;
if bDebug
       persistent vstim % ba for debug mode
end
% Get information about AIOBJ (aka obj)
hTriggerNum = getappdata(hDataViewer,'hTriggerNum');
Trigger = obj.TriggersExecuted;
TriggerRepeat = obj.TriggerRepeat;
LoggingMode = obj.LoggingMode;
LogFileName = obj.LogFileName;
SamplesPerTrigger = obj.SamplesPerTrigger;

TriggerNum = obj.TriggersExecuted-1;
% % reinitialze h.spikes for each file
% persistent h.spikes;

% Get stimulus information
if ~bDebug
    global DIOBJ % should be replaced with a search for the right DIOBJ
    stimcond = readDigitalPorts(DIOBJ,Trigger,TriggerRepeat,LoggingMode,LogFileName);
    
    vstimParams = GetVStimFileName_Params(Trigger,LoggingMode,LogFileName,hDataViewer);
    
    % get visual stimulus parameters
    if ~isempty(vstimParams)
        [vstim.VarParam vstim.Param] = help_interpetPsychStimParam(vstimParams);
        setappdata(hDataViewer,'vstim',vstim);
        vstim.VarParam
    else
        %     display('Loading Existing Vstim Parameters')
        
        vstim = getappdata(hDataViewer,'vstim');
        if isempty(vstim)
            vstim.VarParam.Values = 1;
            vstim.VarParam.Name = '';
            vstim.Param.blankstim = 0;
            display('No Vstim Parameters Exist');
        end
    end
end


% Get all plot vectors (stored in the struct, dv)
dv = dvCallbackHelper(hDataViewer);

dv.MaxPoints = 20000;
dv.Fs = obj.SampleRate;
Fs = dv.Fs;

% If samples per trigger is longer than 5 seconds, then 2 seconds of data
% are shown at a time. This should be replaced with "scope mode",
if SamplesPerTrigger > Fs*5
    SamplesRequested = Fs*2;
else
    SamplesRequested = SamplesPerTrigger;
end

% This while loop is included to allow viewing of chunks of data, either in
% scope mode, or with temporary 5 second clause above.
% while (obj.SamplesAvailable < obj.SamplesPerTrigger) && obj.SamplesAvailable ~= 0
% this while loop seems to result in sweeps being missed if the length
% of the sweep is near 5

% Loop until requested data is available
tic
while ((obj.SamplesAvailable < SamplesRequested) && strcmp(obj.Running,'On'))
    pause(.05);
    if toc > (obj.SamplesPerTrigger/Fs);
        display('break');
        break;
    end
end

% Get data
sizeData = min(obj.SamplesPerTrigger,obj.SamplesAvailable);
if bDebug % BA for troubleshooting/testing load  recorded data
    persistent Nsw CondNum LEDCond datastore dt filen
    if isempty(Nsw)|| Trigger ==1,
        %%
        %         Nsw = 0;
        %         filen = 'f:\tank\BVA2010-07-14Cell3_6.daq';
        % tic
        %         datastore = []; [datastore dt] = loadDaqData(filen,loadchn,1);
        % toc
        %         Fs = 1/dt;
        %
        %         fileStimin = 'f:\tank\BVA2010-07-14Cell3_6_TrigCond.mat';
        %         load(fileStimin);
        %         fileStimin = 'f:\tank\BVA2010-07-14Cell3_6_LEdCond.mat';
        %         load(fileStimin);
        
        Nsw = 0;
%         filentemp = 'f:\tank\BVA2010-06-30_31.daq';
 %         filentemp = 'f:\tank\BVA2010-06-30_32.daq';
%         filentemp = 'f:\tank\BVA2010-07-06_24.daq';
%           filentemp = 'f:\tank\BVA2010-07-01_21.daq';
%        filentemp = 'f:\tank\BVA2010-07-14Cell3_6.daq';

%        filentemp = 'f:\tank\BVA2010-07-16_29.daq'; % cphase
%       filentemp = 'f:\tank\BVA2010-07-16_30.daq';

%       filentemp = 'f:\tank\BVA2010-07-20Cell12_22.daq'; % GOOD (matched)


%       filentemp = 'f:\tank\BVA2010-07-21Cell2_11.daq'; % 
      
%       filentemp = 'E:\BA 5400  data\VCData\BVA2010-07-23Cell1_10.daq'; % 
%       filentemp = 'E:\BA 5400  data\VCData\BVA2010-07-23Cell1_12.daq'; % 
%       filentemp = 'E:\BA 5400  data\VCData\BVA2010-07-23Cell1_18.daq'; % 
%       filentemp = 'E:\BA 5400  data\VCData\BVA2010-07-23Cell1_19.daq'; % 

%       filentemp = 'E:\BA 5400  data\VCData\BVA2010-07-23Cell1_11.daq'; % 

%       filentemp = 'E:\BA 5400  data\VCData\BVA2010-07-23Cell6_32.daq'; % 

filentemp = 'f:\tank\BVA2010-07-16_20.daq';
%              filentemp = 'f:\tank\BVA2010-07-16_26.daq'; % NOT DONE (same
%              cell as chpase but drifting)
%       filentemp = 'f:\tank\BVA2010-07-16_27.daq';

%        filentemp = 'f:\tank\BVA2010-07-16_41,42,43.daq'; %  NOT DONE

        
        TRIGRANGEtemp = [];
        sloadfile = sprintf('temp_%s',seperateFileExtension(getfilename(filentemp)));
        if ~isequal(filentemp,filen) % is already loaded
            if isempty(dir([sloadfile '*'])) % check loaded data is the right data
                display('Loading DAQ file');
        loadchn = [ 3 6];
                datastore = []; [datastore dt] = loadDaqData(filentemp,loadchn,TRIGRANGEtemp);
                datastore(:,:,6) = datastore(:,:,2);
                datastore(:,:,3) = datastore(:,:,1);
                filen = filentemp; TRIGRANGE = TRIGRANGEtemp;
                save(sloadfile,'datastore','dt','filen','TRIGRANGE','loadchn')
            else
                load(sloadfile); % load matfile with saved data
            end
        end
        
        Fs = 1/dt;
        
        fileStimin = sprintf('%s_TrigCond.mat',seperateFileExtension(filentemp));
        load(fileStimin);
        %         fileStimin = sprintf('%s_LEdCond.mat',seperateFileExtension(filentemp));
        %         load(fileStimin);
        
        if 0
            fileStimin = sprintf('%s_SFile.mat',seperateFileExtension(filentemp));
            load(fileStimin);
            [vstim.VarParam vstim.Param] = help_interpetPsychStimParam(params);
        else % manual enter
            % BA temp solution because communctation Vstim PC and DAQ PC not working
%             vstim.VarParam.Values = logspace(-2,0,8); % 0.01
%             vstim.VarParam.Values = real([-1.0000 - 0.0000i  -0.9010 + 0.4340i  -0.6230 + 0.7820i  -0.2230 + 0.9750i   0.2230 + 0.9750i 0.6230 + 0.7820i   0.9010 + 0.4340i   1.0000          ])
            %     vstim.VarParam.Values = linspace(0,360-360/8,8); % 0.01
            %     vstim.VarParam.Values = logspace(-.602,0,8); % 0.25
            %     vstim.VarParam.Values = logspace(-.8240,0,6); % 0.15
            vstim.VarParam.Name = 'Contrast';
            vstim.Param.blankstim = 0;
        end
        
    end
    Nsw = Nsw +1;
    if Nsw <=size(datastore,2)
    else, global AIOBJ; stop(AIOBJ);  end % hack for posthoc viewing of data
    data = datastore(:,Nsw,:);
    %     data =datastore;
    SamplesPerTrigger = size(data,1);
    
    stimcond = CondNum(2,Nsw);
%     ledcond = LEDCond(2,Nsw);
    TriggerNum = Nsw;
    
else % get data from daq
    data = single(getdata(obj,sizeData));
end

% setup conditions for online analysis % this really only needs to be
% done ONCE
cond.list_ledcond = [0 1];
cond.VarParam = vstim.VarParam;
if vstim.Param.blankstim
    cond.list_stimcond = [1:length(cond.VarParam.Values)+1];
else
    cond.list_stimcond = [1:length(cond.VarParam.Values)];
end

if getappdata(hDataViewer,'invertON')
    data(:,3) = data(:,3)*-1; % BA (TO DO make this a feature)
end
% Process and display data
[spiketimes ind_spike sdata] = dvProcessDisplay(dv,data,hDataViewer);
% if bDebug % trouble shooting
%     loadchn = 3;
%     load('f:\tank\spikestest','ts') % load spikes from disk
%     sp = filtspikes(ts,0,'trigger',Nsw);
%     spiketimes{loadchn} = sp.spiketimes;
%
%     if sp.sweeps.led ~=ledcond
%         disp('error'); keyboard; end
% end


drawnow
tic


%     % Determine whether LED being used, if so, get LED condition
% bLED = getappdata(hDataViewer,'bLED');
% if bLED
%
%     % BA this should be working but it isn't because forsome reason
%     % aoCAllback isn't being called on sweeps that shoudl have output
%     % ='off; this only happens when the putdata is the same length (or
%     % nearly the same i.e. within 500ms) as the time between triggers (there should be a way
%     % to make a buffer for analog in
%     ledcond = GetLEDCond(Trigger,TriggerRepeat,LoggingMode,LogFileName);
%     ledcond = ledcond>0;
% else
%     ledcond = 0; % nan is a pain to handle
% end
% BA temporary solution because code above doesn't work
if  1; % ~bDebug
    LEDchn =20;
    % ledcond = 0;
    % %       figure(99);
    if any(data(:,LEDchn)>0.9)
        ledcond = 1;
    else
        ledcond = 0;
    end
    LEDMAX = max(data(:,LEDchn));
end

% BA
if ledcond
set(getappdata(hDataViewer,'hLedNum'),'String',num2str(LEDMAX),'ForegroundColor',[1 0 0]);
else
    set(getappdata(hDataViewer,'hLedNum'),'String',num2str(LEDMAX),'ForegroundColor',[0 0 0]);
end
set(getappdata(hDataViewer,'hVstimNum'),'String',num2str(stimcond));
% Update GUI objects
set(hTriggerNum,'String',TriggerNum);



% %       plot(data(:,LEDchn)*-1);
% spiketimes(LEDchn)
%             if ~isempty(spiketimes{LEDchn})
%                 ledcond = 1;
%             end

% condition led condition to be 0 or 1
% ledcond

% --- Online analysis --- %



%       % BA get led condition
% %     add button for LEDconfiguration
% % ADD function to get LED condition based on threshold and
% % rigDef.led.AIChan
%     LEDinCHN = 6;highLevel = 1.5;
%     ledcond =0; if sum(data(:,LEDinCHN)>highLevel)>1000,
%         ledcond=1;
%     end

if getappdata(hDataViewer,'SpkSelectON')
    temp = guidata(hDataViewer);
    try
        h = guidata(temp.onlineSpkSel.hspkwavesFig);
    catch % handles don't exist reinitialize
        h = initOnlineSpkSelect;
        guidata(temp.onlineSpkSel.hspkwavesFig,h)
    end
    [h onlineassigns] = onlineSpkSelection(dv,h,sdata,Fs,ind_spike);
    guidata(h.hspkwavesFig,h);
    
end
% maintain h.spikes object with conditions
% to do make into function



% PSTH
if getappdata(hDataViewer,'psthON')
    cond.stim = stimcond;
    cond.led = ledcond;
    temp = guidata(hDataViewer);
    h = guidata(temp.psth.psthFig);
    
    if 1 % for updateOnlinePSTH_BA
        for ichn = 1:length(spiketimes)
            h.spikesCell{ichn}.info.detect.dur = SamplesPerTrigger/Fs; % need this for raster plot
            h.spikesCell{ichn}.sweeps.stimcond = [h.spikesCell{ichn}.sweeps.stimcond stimcond];
            h.spikesCell{ichn}.sweeps.led = [h.spikesCell{ichn}.sweeps.led ledcond];
            h.spikesCell{ichn}.sweeps.trigger = [h.spikesCell{ichn}.sweeps.trigger TriggerNum];
            h.spikesCell{ichn}.sweeps.trials = h.spikesCell{ichn}.sweeps.trigger;  %no trials for now
            
            if ~isempty(spiketimes{ichn})
                %             if ~bDebug
                h.spikesCell{ichn}.spiketimes = single([h.spikesCell{ichn}.spiketimes spiketimes{ichn}]);
                h.spikesCell{ichn}.trigger = single([h.spikesCell{ichn}.trigger TriggerNum*ones(size(spiketimes{ichn}))]);
                h.spikesCell{ichn}.trials = h.spikesCell{ichn}.trigger;  %  using trigger not trials accross files
                h.spikesCell{ichn}.stimcond = single([h.spikesCell{ichn}.stimcond stimcond*ones(size(spiketimes{ichn}))]);
                h.spikesCell{ichn}.led = single([h.spikesCell{ichn}.led ledcond*ones(size(spiketimes{ichn}))]);
                 %             else
                %                 temp = h.spikesCell{ichn}.analysis;
                %                 h.spikesCell{ichn} = sp;
                %                 h.spikesCell{ichn}.analysis = temp;
                %             end
            end
            if ~isempty(spiketimes{ichn})
                if ~exist('onlineassigns','var'), temp = zeros(size(spiketimes{ichn})); % deal with case where onlineassigns is ont defined
                else temp = onlineassigns{ichn}; end
            else temp =[];
            end
            h.spikesCell{ichn}.onlineassigns = [h.spikesCell{ichn}.onlineassigns temp];
            
            
        end
    end
        h = updateOnlinePSTH_BA(h,cond);
%     h = updateOnlinePSTH(h,spiketimes,cond);
    guidata(h.psthFig,h);
end
% TO DO BA make seperate plots for each stimcondition
% does it work


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


drawnow

% end


% --- Subfunctions --- %

function vstimParams = GetVStimFileName_Params(Trigger,LoggingMode,LogFileName,hDataViewer)
% Get name of stimulus and save to file

params = [];
if Trigger == 1 ;
    global UDP_OBJ_STIM_PC % UDP object connecting to stimulus PC
    try
        temp = fscanf(UDP_OBJ_STIM_PC); % NOTE: timeout is set when declaring UDP object
        if  ~isempty(temp)
            temp = strread(temp,'%s','delimiter','*'); % Stimulus filename
            
            
            S = fscanf(UDP_OBJ_STIM_PC);
            [splits, splits, splits, splits, splits, splits, splits]  = regexp(S,'\n'); %delimiter
            %parse to get COMMAND
            % cmd= splits{1,1}; % first line contains command
            
            params = rc_udprecieveParams(splits(2:end));
            
        end
    catch
        temp = []; params = [];
        warning('Failed to communicate with VSTIMPC via udp')
        
    end
    if ~isempty(temp)
        params.sfilename = temp{1};
        params.condName = temp{2};
        temp = LogFileName;
        if strcmp(LoggingMode,'Disk&Memory')
            save([temp(1:end-4) '_SFile'],'params');
        end
    end
    
    % save to DataViewer parameters
    vstimParams =params;
    
else
    vstimParams = [];
end


function params = rc_udprecieveParams(splits)
% recieves data from rc_udpsendParams in the form of a string and converts
% it back into a struct
try
    for i = 1:size(splits,2)-1
        % NOTE, right now can't send matrixes, or anything (e.g. substructs, cells) that is not a string
        % or a vector
        
        stemp= splits{1,i};
        ind = regexp(stemp,'\s'); ind = ind(1);
        params.(stemp(1:ind-1)) = stemp(ind+1:end);
        
        if ~any(isletter(params.(stemp(1:ind-1)))) % if not a string convert to vector
            params.(stemp(1:ind-1)) = str2num(params.(stemp(1:ind-1)));
        end
    end
    
catch
    i
end

