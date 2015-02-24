function expt = MakeExptStruct(ExptDetailsFile,expt)
% function expt = MakeExptStruct(ExptDetailsFile,expt)

% Set rig defaults
RigDef = RigDefs;

% Define fields
fields = {'name','info','files','sort','analysis','stimulus'};
for i = 1:length(fields)
    if ~isfield(expt,fields{i})
    expt.(fields{i}) = [];
    end
end


% Set experiment name
ind = regexp(ExptDetailsFile,'_');
expt.name = ExptDetailsFile(1:ind(end)-1);                          % BA check with SRO that this works for him

% Define info fields
expt.info.exptfile = [getFilename(expt.name) '_expt'];             % BA removed Path (it defeats purpose of  having RigDefaults)
expt.info.table = [];
expt.info.probe.tipdepth = [];
expt.info.probe.angle = [];
expt.info.probe.sitedepth = [];
expt.info.probe.layer = [];
expt.info.probe.type = [];
expt.info.probe.numchannels = [];
expt.info.probe.configuration = [];
expt.info.probe.channelorder = [];
expt.info.probe.ID = [];
expt.info.probe.usenum = [];
expt.info.probe.tetrode.channels = [];



% Set table information
load(ExptDetailsFile);
expt.info.table = Data;

% Set info
expt.info.depth = expt.info.table{2,2};
expt.info.probe.type = '16 channel';

% Hard coding this info now, but in future will get this info at time of
% experiment
expt.info.probe.ID =  '11902 - a2x2-tet-3mm-150-121';

expt.info.probe.numchannels = 16;
expt.info.probe.configuration = '2x2';  


switch expt.info.probe.configuration
    case '2x2'
        if ~isTDTexpt(expt)
        expt.info.probe.channelorder = [2 3 7 5 12 10 14 15 1 6 8 4 13 9 11 16];
        else         % for TST same but they are flipped in order already so 
                expt.info.probe.channelorder = [1:16];
        end
    case '1x16'
        expt.info.probe.channelorder = [9 8 10 7 13 4 12 5 15 2 16 1 14 3 11 6];
    case '4x1'
        expt.info.probe.channelorder = [3 6 2 1 4 5 8 7 10 9 12 13 16 15 11 14];
    otherwise
        expt.info.probe.channelorder = [];
end

if strcmp(expt.info.probe.type,'16 channel');
    for i = 1:4
        ind = (i-1)*4 + 1;
        expt.info.probe.tetrode(i).channels = expt.info.probe.channelorder(ind:ind+3);
    end
end

% Define files fields
expt.files.names = [];
expt.files.index = [];
expt.files.triggers = [];
expt.files.duration = [];
expt.files.Fs = [];

% Get files names
if ~isTDTexpt(expt)
    FileList = GetFileNames(expt);
else % if TDT select the names of the blocks manually  % BA
    
end
expt.files.names = FileList;

% Get acquisition parameters
for i = 1:length(expt.files.names)
    if isTDTexpt(expt)
        [Fs,duration,triggers] = GetFsDurationTrig_TDThelper(fullfile(RigDef.Dir.Data,expt.files.names{i}));                  % BA
        daqinfo = NaN;

    else
        [Fs,duration,triggers,daqinfo] = GetFsDurationTrig_NIDAQhelper(expt.files.names{i});
    end
    expt.files.triggers(i) = triggers;
    expt.files.duration(i) = duration;
    expt.files.Fs(i) = Fs;
    expt.files.daqinfo(i) = daqinfo;
end

% Set sort fields
expt.sort.status = 'Incomplete';
expt.sort.totalunits = [];
expt.sort.allthresh = [];

% Set sort.tetrode(m,n) fields. n is the number of tetrodes and m stores
% sort sessions with different paramters, e.g. different threshold, or
% files.
for i = 1:4
    expt.sort.tetrode(i).channels = [];
    expt.sort.tetrode(i).files = [];
    expt.sort.tetrode(i).threshtype = [];
    expt.sort.tetrode(i).thresh = [];
    expt.sort.tetrode(i).detected = 'no';
    expt.sort.tetrode(i).sorted = 'no';
    expt.sort.tetrode(i).numunits = [];
    expt.sort.tetrode(i).spikespersec = [];
    expt.sort.tetrode(i).spikesfile = [];
    % Set sort.tetrode(M).units(N) fields
    expt.sort.tetrode(i).unit.tetrode = [];
    expt.sort.tetrode(i).unit.channels = [];
    expt.sort.tetrode(i).unit.index = [];
    expt.sort.tetrode(i).unit.rpv = [];
    expt.sort.tetrode(i).unit.spikespersec = [];
    expt.sort.tetrode(i).unit.peakrate = [];
    expt.sort.tetrode(i).unit.amplitude = [];
    expt.sort.tetrode(i).unit.width = [];
    expt.sort.tetrode(i).unit.peak = [];
    expt.sort.tetrode(i).unit.trough = [];
    expt.sort.tetrode(i).unit.troughpeakratio = [];
    expt.sort.tetrode(i).unit.maxchannel = [];
    expt.sort.tetrode(i).unit.waveformtype = [];
    expt.sort.tetrode(i).unit.avgwave = [];
    expt.sort.tetrode(i).unit.numspikes = [];
    expt.sort.tetrode(i).unit.clustertype = [];
end

% Set sort.sites(m,n) fields. Use sites for non-tetrode recordings or for
% sorting based on subsets of tetrode sites.
expt.sort.sites.channels = [];
expt.sort.sites.files = [];
expt.sort.sites.threshtype = [];
expt.sort.sites.thresh = [];
expt.sort.sites.detected = 'no';
expt.sort.sites.sorted = 'no';
expt.sort.sites.numunits = [];
expt.sort.sites.spikepersec = [];
expt.sort.sites.spikesfile = [];

% Set stimuli fields
expt = AddSweepsField(expt);                                %BA this function changed                         
expt = AddStimParams(expt); 
nameTTL = 'Ligh';
expt = AddTTLCond(expt,nameTTL);                           %BA


path = RigDef.Dir.Expt;                                 %BA
save([path expt.info.exptfile],'expt');                     % BA


% Set analysis fields


% --- Subfunctions --- %

function FileList = GetFileNames(expt)

% Get list of daq files for experiment

files = dir([expt.name '*.daq']);
FileList = {files.name}';
if isempty(FileList)
    error('No daq files for this experiment were found')
end
% Need to reorder FileList (what's the best way to do this?)
FilesFound = 0;
i = 1;
while(FilesFound < length(FileList))
    file = dir([expt.name '_' num2str(i) '.daq']);
    if ~isempty(file)
        FilesFound = FilesFound + 1;
        FileList(FilesFound) = {file.name}';
    end
    i = i+1;
    if i == 200
        error('The daq files could not be found. Check experiment name');
    end
end
disp('The following daq files were found:')
disp(FileList)

