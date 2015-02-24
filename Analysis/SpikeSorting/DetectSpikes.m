function [expt spikes trodeInd] = DetectSpikes(expt,detectFiles,trodeInd)
% function [expt spikes trodeInd] = DetectSpikes(expt,detectFiles,trodeInd)
%
% INPUTS:
%   expt: expt struct
%   detectFiles: A row vector containing indices of files to be sorted together
%   trodeInd (opt): Index trode to be detected.
%
% OUTPUTS:
%   expt: expt struct
%   spikes: spikes struct
%   trodeInd: Index of the trode chosen for detection
%
%   3/16/10 - SRO
%   3/23/10 - BA ADD TDT compatibility
%   4/6/10  - SRO and BA
%   4/12/10 - SRO 
%   6/30/10 - SRO
%
% TO DO: Try-catch with email
bremoveLEDartifact = 0
binvert =1;

if nargin < 3
    chooseTrode = 1; % Flag for opening dialog to chose trode to sort
else
    chooseTrode = 0;
    ok = 1;
    expt.sort.trode(trodeInd).detected = 'no';
end

% Set rig defaults
RigDef = RigDefs;

if chooseTrode
    % Choose which channels to use
    for i = 1:length(expt.sort.trode)
        trodeName = expt.sort.trode(i).name;
        channels = expt.sort.trode(i).channels;
        ListString{i} = [trodeName ':' ' ' '[' num2str(channels) ']'];
    end
    [trodeInd,ok] = listdlg('ListString',ListString,'ListSize',[200 80],...
        'SelectionMode','single','Name','Select channels'); pause(0.05)
end

if ok
    if strcmp('yes',expt.sort.trode(trodeInd).detected)
        % Do you want to replace or append to previous detection?
        bAppend = questdlg(sprintf('Append or replace previous detection on Trode %s?',expt.sort.trode(trodeInd).name),'','Append','Replace','Append');
        pause(0.05)
    else
        % Update detection flag
        bAppend = 'New';
    end
    
     channels = expt.sort.trode(trodeInd).channels;
    
    % Save name for spikes struct
    fName = getFilename(expt.name);           % BA (TDT has whole path here get only filename)
    trodeName = expt.sort.trode(trodeInd).name;
    chStr = [];
    for i = 1:length(channels)
        temp = num2str(channels(i));
        chStr = [chStr '_' temp]; 
    end
    fName = [fName '_' trodeName '_Ch' chStr '_S1' '_spikes'];        % TO DO: Note S1 needs to be dependent on expt in order to allow additional spike sorts -- SRO
end

switch bAppend
    case {'Replace','New'}
        % Initialize trode
        trode.name = trodeName;
        trode.channels = channels;
        expt = addTrodeSort(expt,trode,trodeInd); % reset trode
        expt.sort.trode(trodeInd).detected = 'yes';
 
        % Create default spikes struct
        Fs = expt.files.Fs(1);              % Use sampling frequency from first file. This assumes Fs is the same across files.
        
        % Make new default spikes struct
        spikes = ss_default_params_custom(Fs);
        
        % Set default labels
        spikes.params.display.label_categories = RigDef.SS.label_categories ;
        spikes.params.display.label_colors = RigDef.SS.label_colors; 
        
        % Get thresholds or set to default threshold ('auto')
        expt.sort.manualThresh =[];
        if isempty(expt.sort.manualThresh)                             % sort.manualThresh can be set in DataViewer
            expt.sort.trode(trodeInd).threshtype = 'auto';
            spikes.params.detect_method = 'auto';
        else
            expt.sort.trode(trodeInd).threshtype = 'manual';
            if ~isTDTexpt(expt) % nidaq
                expt.sort.trode(trodeInd).thresh = expt.sort.manualThresh(channels+1);      % Offset by index of 1 because Trigger if Ch1 using nidaq
            else % tdt
                expt.sort.trode(trodeInd).thresh = expt.sort.manualThresh(channels);
            end
            disp('Manually set thresholds will be used for spike detection')
            spikes.params.detect_method = 'manual';
            spikes.params.thresh = expt.sort.trode(trodeInd).thresh';
        end
        
        % Save spikes and expt struct ** Think about why this is here **
        expt.sort.trode(trodeInd).spikesfile = fName;
        spikes.info.spikesfile = expt.sort.trode(trodeInd).spikesfile;
        SaveAssignStructs(expt,spikes,RigDef);

    case 'Append'
        % Load spikes file
        spikesDir = RigDef.Dir.Spikes;
        load(fullfile(spikesDir,fName))
        % Remove previously detected files from detectFiles list
        prevDetectFiles = expt.sort.trode(trodeInd).fileInds;
        allDetectFiles = union(prevDetectFiles,detectFiles);
        detectFiles = setdiff(allDetectFiles,prevDetectFiles);
end

% Get list of files (Note: This list includes all files in experiment. The
% file indices are used to identify specific files for spike detection.)
FileList = expt.files.names;

% Loop on detectFiles vector to perform detection (the values in
% detectFiles are indices into the expt.files struct)

% hp = progress_bar(0, 1, sprintf('Extracting Spikes from . . . %d Files for Trode %d ', length(detectFiles),trodeInd))
% can't have 2 progress bars at the sam time...
try
for fileInd = detectFiles
    
%     progress_bar(find(detectFiles==fileInd)/length(detectFiles)); % BA
    
    Fs = expt.files.Fs(fileInd);
    Triggers = expt.files.triggers(fileInd);
    duration = expt.files.duration(fileInd);
    
    if isTDTexpt(expt)
        disp('Reading TDT file')
        disp(FileList{fileInd})
        ind = strfind(FileList{fileInd},'\');ind = ind(end);
        if isempty(ind); error('TDT tank and block must both be included'); end
        [STF.tdt.tank STF.tdt.blk] =  loadTDThelper_getTankBlk(FileList{fileInd});
        %             STF.filename = loadTDThelper_makefilename(FileList{fileInd});
        filtparam.dfilter = [NaN,NaN,60 0]; % for other filters (none)
        filtparam.maxlevel =  5;                                        % for wavelet filter
        bNoLoad = 0;                                                    % reload of you can
        
        % Predefine data
        blkpath = [RigDef.Dir.Data  STF.tdt.tank '\' STF.tdt.blk];
        [triggers sweeplength Fs] = loadTDTInfo(blkpath);
        data = nan((sweeplength*Fs+1),triggers,length(channels),'single');
        % Get data
        for i =1 :length(channels) % this is more memory efficient I Think, and if run out of memory in later channels early channesl don't have to recomputed
            data(:,:,i) = preprocessDAQ([],STF,channels(i),filtparam,bNoLoad);
        end
        spikes.preprocess.filter.param = filtparam;
        spikes.preprocess.filter.name = 'wavelet';
        
    else % NIDAQ
        
        if isequal(expt.sort.trode(trodeInd).threshtype, 'auto')
        % Estimate noise SD using median absolute deviation derived from a
        % random subset of files to sort
        filtparam = RigDef.SS.spike_filtparam;
        
        if fileInd == detectFiles(1)
            disp('Computing noise SD...')
            nFiles = min(3,length(detectFiles));
            temp = randperm(length(detectFiles));
            sampFiles = detectFiles(temp(1:nFiles));
            dataTemp = [];
            for i = 1:length(sampFiles)
                STF.filename = FileList{ sampFiles(i)};
                data = preprocessDAQ([],STF,channels+1,filtparam,0);
                try dataTemp = [dataTemp data]; catch ME, getReport(ME); end % BA FIX for daqs of different lengths
            end
            k = find(isnan(dataTemp(:,1)));            dataTemp(k,:) = [];
            [ns nsw nchn] = size(dataTemp);
            stds = 1.4785*mad(reshape(dataTemp,ns*nsw,nchn),1,1);
            clear dataTemp
            
            spikes.info.detect.stds = stds;
        end
        end        
        %  BA Load daq file and filter
        STF.filename = FileList{fileInd};
        display(sprintf('\t\t\t\t  Loading %s',STF.filename));
        [data dt]= preprocessDAQ([],STF,channels+1,filtparam,0);
        
        spikes.preprocess.filter.param = filtparam;
        spikes.preprocess.filter.name = filtparam.name ;
        
    end
    if binvert % BA
        factor = -1;
        display(sprintf('\t\t******************************'));
        display(sprintf('\t\t\tInverting channel'));
        display(sprintf('\t\t******************************'));
        data = data*factor;
        spikes.preprocess.inverted = factor;
    end
    
    if bremoveLEDartifact % sutract LED artifact
        data = helper_removeLEDartifact(expt,fileInd,data);
        spikes.preprocess.LEDartifactRemoved = 1;       
    else
        spikes.preprocess.LEDartifactRemoved = 0;
    end
    
    data = convertDataForSpikes(data);
    
    
    % Detect. Spikes are appended on each loop
    spikes = ss_detect_custom(data,spikes);                             % Triggers x Samples x Channels
    clear data
    % Add detected file index fileInds
    expt.sort.trode(trodeInd).fileInds(end+1) = fileInd;
    % Set information about detetction
    expt.sort.trode(trodeInd).spikespersec = length(spikes.spiketimes)/sum(spikes.info.detect.dur);
    expt.sort.trode(trodeInd).thresh = spikes.params.thresh;     % Get thresholds actually used
    % Set additional information in spikes struct
    spikes.info.exptfile = expt.info.exptfile;
    spikes.info.trodeInd = trodeInd;
    
     
end
catch ME % save spikes if there is an error so nothing is lost
   getReport(ME)
   keyboard
    if exist('spikes','var'), SaveAssignStructs(expt,spikes,RigDef); end
end

  % Save
    SaveAssignStructs(expt,spikes,RigDef);
 

% --- Subfunction --- %
function SaveAssignStructs(expt,spikes,RigDef)

% Save spikes and expt
save(fullfile(RigDef.Dir.Spikes,getFilename(spikes.info.spikesfile)),'spikes');
save(fullfile(RigDef.Dir.Expt,getFilename(expt.info.exptfile)),'expt');
% Assign in base
assignin('base','expt',expt);
assignin('base','spikes',spikes);


    function data =  helper_removeLEDartifact(expt,fileInd,data,bremoveLEDartifact)
        
        % data in form samples x triggers x channels
        
        % try and remove LED artifact by subtract mean LED trials from each LED trial
        if bremoveLEDartifact % LED trials only
            thisfile_sweeps = filtsweeps(expt.sweeps,0,'fileInd',fileInd);
            if        length(thisfile_sweeps.trigger )> 1 % don't do it if there is only 1 sweep
                disp('******* LEDartifact subtracted *******')
                
                nLEDtrials = sum(thisfile_sweeps.bled);
                mLEDtrials = repmat(mean(data(:,thisfile_sweeps.bled,:),2),[1,nLEDtrials,1]);
                data(:,thisfile_sweeps.bled,:) = data(:,thisfile_sweeps.bled,:)- mLEDtrials;
                %         else % all trials
                %             mLEDtrials = repmat(mean(data,2),[1,size(data,2),1]);
                %             data = data- mLEDtrials;
            end
        end
        
        
