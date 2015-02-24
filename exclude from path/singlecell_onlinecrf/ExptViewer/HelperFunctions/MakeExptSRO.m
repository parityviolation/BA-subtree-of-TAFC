function expt = MakeExptSRO(ExptTable,expt)
% expt = MakeExpt(ExptTable,expt)
% 
% INPUT:
%   ExptTable(optional): Table with details of experiment. This table is
%   used to fill in specific fields in the expt struct.
%   expt: Can input previously generated expt struct in order to add new
%   fields.
%
% OUTPUT:
%   expt: expt struct


% Created: 3/25/10 - SRO
% Modified: 4/9/10 - SRO
% Modified: 4/19/10 - BA support TDT too
% Modified: 5/22/10 - SRO: Updated structversion to 2.0. Added fields
% info.location, info.time, info.anesthesia, info.stimulus.stimcode, and
% expt.unit (for completed units). Modified info.transgene. Added fields to
% .probe for storing site depths. Removed field info.recording.
% Condsider making expt.files a multidimensional array.

% Change this expt struct is changed
expt.info.structversion = 2.0 ;

% Set rig defaults
RigDef = RigDefs;

% If expt is not supplied, generate new one
if nargin < 2
    expt = [];
end

% If experiment table is not supplied then use dialog to get one
if nargin < 1 || isempty(ExptTable)
    
    % Load experiment table
    [FileName,PathName,FilterIndex] = uigetfile([RigDef.Dir.Data '*_ExptTable*']);
    if FileName ~= 0
        temp = load(fullfile(PathName,FileName));
        ExptTable = temp.Data;
    else
        error('Must supply an experiment table.')
    end
    
end

% Define fields
expt.name = [];         % Experiment name
expt.info = [];         % Information about the experiment
expt.files = [];        % 
expt.sort = [];         %
expt.stimulus = [];     %
expt.sweeps = [];       % 
expt.analysis = [];     % Info for running analysis and also outputed results
expt.unit = [];         % Completed units

% Set experiment name
expt.name = getFromExptTable(ExptTable,'Experiment name');

% Define some info fields
expt.info.exptfile = [expt.name '_expt'];
expt.info.table = ExptTable;

% info.mouse
expt.info.mouse.genotype = getFromExptTable(ExptTable,'Genotype');
expt.info.mouse.age = getFromExptTable(ExptTable,'Age');
expt.info.mouse.sex = getFromExptTable(ExptTable,'Sex');
expt.info.mouse.mass = getFromExptTable(ExptTable,'Mass');

% info.location
expt.info.location.region = getFromExptTable(ExptTable,'Brain region');
expt.info.location.coordinates = getFromExptTable(ExptTable,'Coordinates');
expt.info.location.bregma_lambda = getFromExptTable(ExptTable,'Bregma_lambda');

% info.transgene (seperate entry for each construct)
expt.info.transgene.type = [];
expt.info.transgene.agetransfect = [];
expt.info.transgene.construct = [];
expt.info.transgene.cre = [];
expt.info.transgene.region = [];

% ** TO DO ** Write getAnestheticFromTable function
% info.anesthesia (each anesthetic has fields .dose and .time)
% expt.info.anesthesia.cpt = getAnestheticFromTable(ExptTable,'CPT');
% expt.info.anesthesia.isoflurane = getAnestheticFromTable(ExptTable,'iso');
% expt.info.anesthesia.urethane = getAnestheticFromTable(ExptTable,'urethane');
% Temporary
expt.info.anesthesia = getFromExptTable(ExptTable,'Anesthesia');

% info.time
expt.info.time.begin = getFromExptTable(ExptTable,'Begin @');
expt.info.time.anesthesia = getFromExptTable(ExptTable,'Anesthesia @');
expt.info.time.craniotomy = getFromExptTable(ExptTable,'Craniotomy @');
expt.info.time.insertprobe = getFromExptTable(ExptTable,'Inserted probe @');
expt.info.time.startrecording = getFromExptTable(ExptTable,'Start recording @');
expt.info.time.end = getFromExptTable(ExptTable,'End @');
if ~isempty(expt.info.time.begin) && ~isempty(expt.info.time.end)
    begin = expt.info.time.begin;
    endtime = expt.info.time.end;
    duration = etime(datevec(begin),datevec(endtime))/3600; % In hours
    expt.info.time.duration = duration;
end

% info.equipment
expt.info.equipment.amp = RigDef.equipment.amp;
expt.info.equipment.daqboard = RigDef.equipment.daqboard;

% info.probe
expt.info.probe.type = getFromExptTable(ExptTable,'Probe type');                        % 16 Channel, Glass, etc.
expt.info.probe.ID = getFromExptTable(ExptTable,'Probe ID');
expt.info.probe.usenum = str2num(getFromExptTable(ExptTable,'Probe use number'));
expt.info.probe.configuration = getFromExptTable(ExptTable,'Probe configuration');      % 1x16, 2x2, 4x1, 1x1 (glass,tungsten)
expt.info.probe.xdistance = str2num(getFromExptTable(ExptTable,'Probe xdistance'));              % Read off of LN keypad
expt.info.probe.angle = str2num(getFromExptTable(ExptTable,'Probe angle'));                      % Measured
expt.info.probe.tipdepth = [];              % Derived
expt.info.probe.sitedepth = [];             % Derived
probe = expt.info.probe;

% Temporary for old files
if isnan(expt.info.probe.type)
    expt.info.probe.type = '16 Channel';
    expt.info.probe.configuration = '2x2';
%     expt.info.probe.configuration = '1x16';
%     expt.info.probe.configuration = '4x1';
end

if strcmp(expt.info.probe.type,'16 Channel')
    expt.info.probe.trode.names = {'T1','T2','T3','T4'};           % Defined by user
    expt.info.probe.numchannels = 16;
    expt.info.probe.numtrodes = 4;
    expt.info.probe.sitesPerTrode = 4;
elseif strcmp(expt.info.probe.type,'Glass electrode')
    expt.info.probe.trode.names = {'E1'};           % Defined by user
    expt.info.probe.numchannels = 1;
    expt.info.probe.numtrodes = 1;
    expt.info.probe.sitesPerTrode = 1;
end
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
    case '1x1' % Glass electrode
        expt.info.probe.channelorder = 1;
end

% Adds .tipdepth and .sitedepth
expt = computeSiteDepth(expt);              

% Define sites on each trode using channelorder.
sitesPerTrode = expt.info.probe.sitesPerTrode;
for i = 1:expt.info.probe.numtrodes
    channelorder = expt.info.probe.channelorder;
    channelInd = 1 + (i-1)*4;
    expt.info.probe.trode.sites{i} = channelorder(channelInd:channelInd+(sitesPerTrode-1));          
end

% Define files fields
expt.files.names = [];
expt.files.triggers = [];
expt.files.duration = [];
expt.files.Fs = [];

% Get file names
if ~isempty(expt.name)
    if ~isTDTexpt(expt)
        FileList = GetFileNames(expt,RigDef.Dir.Data);
    else % get blocks if it is a TDT expt
        
        dirResult = dirc(PathName,'de','d');
        FileList = dirResult(:,1);
        for i = 1:length(FileList) % order the files by creation date (the dir only orders by modification date)
            temp = getFileTime(fullfile(PathName,FileList{i}));
            creationdate(i) =  datenum(temp.Creation);
        end
        [junk ind] = sort(creationdate);
        FileList = FileList(ind);
        
        [Selection,ok] = listdlg('ListString',FileList); pause(0.05)
        FileList = FileList(Selection);
        % get tankname
        ind = strfind(PathName,'\'); ind2 = ind(end-1)+1; ind = ind(end);
        tankname = PathName(ind2:ind);
        % included the tank folder
        FileList = cellfun(@(x) [tankname,x],FileList,'UniformOutput',0);
        
    end
    
    expt.files.names = FileList;

else
    expt.files.names = [];
end

% Get acquisition parameters
if ~isempty(expt.files.names)
    for i = 1:length(expt.files.names)
        disp('Processing ...')
        disp(expt.files.names{i})
        if isTDTexpt(expt)
            [Fs,duration,triggers] = GetFsDurationTrig_TDThelper(fullfile(RigDef.Dir.Data,expt.files.names{i}));                  % BA
            daqinfo = NaN;
            
        else
            [Fs,duration,triggers,daqinfo] = GetFsDurationTrig_NIDAQhelper([RigDef.Dir.Data expt.files.names{i}]);
        end
        expt.files.triggers(i) = triggers;
        expt.files.duration(i) = duration;
        expt.files.Fs(i) = Fs;
        expt.files.daqinfo(i) = daqinfo;
    end
    
    expt = AddSweepsField(expt);
else
    expt.files.triggers = [];
    expt.files.duration = [];
    expt.files.Fs = [];
    expt.files.daqinfo = [];
end

% Set sort fields       
expt.sort.totalunits = [];
expt.sort.manualThresh = [];
expt.sort.defaults = [];

% Set sort.trode(m) fields where m is the number of trodes
expt = addTrodeSort(expt);

% Set stimulus fields (expt.stimulus)
expt = AddStimParams(expt);

% Add stimulus conditions to sweeps struct (expt.sweeps.stimcond)
expt = exptAddStimCond(expt);

% Add LED conditions to sweeps struct (expt.sweeps.led)
if ~isTDTexpt(expt)
    expt = AddLEDCond(expt);
else
    nameTTL = 'Light';
    expt = AddTTLCond(expt,nameTTL);                           %BA
end

% Set analysis fields (Should be tailored to individual)
expt.analysis.orientation = [];
expt.analysis.spatial = [];
expt.analysis.contrast = [];

expt = analysis_def(expt);

% Save expt struct
FileName = [RigDef.Dir.Expt expt.name '_expt'];

% Prevent overwriting existing expt by accident
if isempty(dir([FileName '.*']))    
    save(FileName,'expt');
else
    [f p] = getFilename(FileName);
    sprintf('Expt NOT created:\n\tExpt: %s already exists in %s',f,p);
end

% Assign in base workspace
assignin('base','expt',expt);

% --- Subfunctions --- %
function FileList = GetFileNames(expt,DataDir)

% Get list of daq files for experiment in raw data directory
files = dir([DataDir expt.name '*.daq']);
FileList = {files.name}';
if isempty(FileList)
    disp('No daq files found for this experiment name')
else
    % Need to reorder FileList (what's the best way to do this?)
    FilesFound = 0;
    i = 1;
    while(FilesFound < length(FileList))
        file = dir([DataDir expt.name '_' num2str(i) '.daq']);
        if ~isempty(file)
            FilesFound = FilesFound + 1;
            FileList(FilesFound) = {file.name}';
        end
        i = i+1;
        if i == 200
            disp('No daq files found for this experiment name');
        end
    end
    disp('The following daq files were found:')
    disp(FileList)
end

