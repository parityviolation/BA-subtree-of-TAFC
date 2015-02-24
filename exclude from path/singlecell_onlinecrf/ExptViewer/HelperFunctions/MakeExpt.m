function expt = MakeExpt(ExptTable,expt,fileInd)
% function expt = MakeExpt(ExptTable,expt)
%
% INPUT:
%   ExptTable(optional): Table with details of experiment. This table is
%   used to fill in specific fields in the expt struct.
%               or is the filename (fullpath) with the ExptTable.
%   expt (optional) expt struct to append to
%   fileInd (optional) vector of indices of daq file
%           e.g.BA_2010-06-30_XX.daq, where XX is the index.
%           fileInd = [1 3 4];
% OUTPUT:
%   expt: expt struct
%
%
%   Created: 3/25/10 - SRO
%   Modified: 4/9/10 - SRO
%   Modified: 7/08/10 - BA support single channel
LEDchn = 6; % DAQ channel of LED
% expt.info.equipment.amp = 'tdt' % to set to TDT expt

expt.info.structversion = 1.0 ; % change this expt struct is changed
% Set rig defaults
RigDef = RigDefs;

% If experiment table is not supplied then use dialog to get one
if nargin < 1 || isempty(ExptTable)
    % Load experiment table
    [FileName,PathName,FilterIndex] = uigetfile(sprintf('%s\*_Expt*',RigDef.Dir.Data));
    temp = load(fullfile(PathName,FileName));
    % TO DO: handle cancel
elseif ischar(ExptTable) %
    temp = load(ExptTable);
   
end
fldn = fieldnames(temp);

if iscell(temp.(fldn{1}))
    ExptTable = temp.(fldn{1});
else
    error('unreconized expttable format')
end


% If expt is not supplied, generate new one
if nargin < 2
    expt = [];
end

% Define fields
expt.name = [];
expt.info = [];
expt.files = [];
expt.sort = [];
expt.stimulus = [];
expt.sweeps = [];
expt.analysis = [];

% Set experiment name
expt.name = getFromExptTable(ExptTable,'Experiment name');

FileName = [RigDef.Dir.Expt expt.name '_expt'];

% handle case where experiment already exists 
bmakeExpt = 1;
 if ~isempty(dir([FileName '.*']))    % prevent overwriting existing expt by accident
       suserresponse= questdlg('This Experiment Exists','','Replace','Cancel','Cancel');
    pause(0.05)
    if isequal(suserresponse,'Replace')
        bmakeExpt = 1;
    else
        bmakeExpt = 0;
    end
end


if bmakeExpt
 
    % Define some info fields
    expt.info.exptfile = [expt.name '_expt'];
    expt.info.table = ExptTable;
    expt.info.brainregion = getFromExptTable(ExptTable,'Brain region');
    
    % info.mouse
    expt.info.mouse.genotype = getFromExptTable(ExptTable,'Genotype');
    expt.info.mouse.age = getFromExptTable(ExptTable,'Age');
    expt.info.mouse.sex = getFromExptTable(ExptTable,'Sex');
    expt.info.mouse.mass = getFromExptTable(ExptTable,'Mass');
    
    % info.transgene
    expt.info.transgene.construct1 = getFromExptTable(ExptTable,'Transgene 1');
    expt.info.transgene.construct2 = getFromExptTable(ExptTable,'Transgene 2');
    expt.info.transgene.construct3 = [];
    expt.info.transgene.agetransfect = getFromExptTable(ExptTable,'Transfection age');
    
    % info.recording
    expt.info.recording.anesthesia = getFromExptTable(ExptTable,'Anesthesia');
    expt.info.recording.time.anesthesia = getFromExptTable(ExptTable,'Anesthesia @');
    expt.info.recording.time.insertprobe = getFromExptTable(ExptTable,'Inserted probe @');
    expt.info.recording.time.start = getFromExptTable(ExptTable,'Start recording @');
    expt.info.recording.time.end = [];
    
    
    % info.probe
    expt.info.probe.type = getFromExptTable(ExptTable,'Probe type');                        % 16 Channel, glass, etc.
    expt.info.probe.ID = getFromExptTable(ExptTable,'Probe ID');
    expt.info.probe.usenum = getFromExptTable(ExptTable,'Probe use number');
    expt.info.probe.configuration = getFromExptTable(ExptTable,'Probe configuration');      % 1x16, 2x2, 4x1, 1x1 (glass,tungsten)
    expt.info.probe.tipdepth = getFromExptTable(ExptTable,'Recording depth');               % Read off of LN keypad
    expt.info.probe.angle = getFromExptTable(ExptTable,'Probe angle');                      % Measured
    expt.info.probe.sitedepth = [];             % Derived
    expt.info.probe.layer = [];                 % Derived
    
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
    elseif regexp(expt.info.probe.type,'Glass')
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
            if ~isTDTexpt(expt)
                expt.info.probe.channelorder = [9 8 10 7 13 4 12 5 15 2 16 1 14 3 11 6];
            else         % for TST same but they are flipped in order already so
                expt.info.probe.channelorder = [14 11 6 3 13 12 5 4 8 1 16 9 7 2 15 10];% 1x16 BA (this converts tetrode order to linear probe order)
            end
        case '4x1'
            expt.info.probe.channelorder = [3 6 2 1 4 5 8 7 10 9 12 13 16 15 11 14];
        case '1x1' % Glass electrode
            expt.info.probe.channelorder = 1;
            
        otherwise % BA
            expt.info.probe.channelorder = 3;
            
    end
    
    % Define sites on each trode using channelorder.
    sitesPerTrode = expt.info.probe.sitesPerTrode;
    for i = 1:expt.info.probe.numtrodes
        channelorder = expt.info.probe.channelorder;
        channelInd = 1 + (i-1)*4;
        expt.info.probe.trode.sites{i} = channelorder(channelInd:channelInd+(sitesPerTrode-1));
    end
    
    % info.equipment
    if isempty(regexp(expt.info.probe.type,'Glass'))
        expt.info.equipment.amp = RigDef.equipment.amp;
        expt.info.equipment.daqboard = RigDef.equipment.daqboard;
    else
        expt.info.equipment.amp = '700B';
        expt.info.equipment.daqboard = 'nidaq-6259';
    end
    
    
    % Define files fields
    expt.files.names = [];
    expt.files.triggers = [];
    expt.files.duration = [];
    expt.files.Fs = [];
    
    % Get file names
    if ~isempty(expt.name)
        if ~isTDTexpt(expt)
            if ~exist('fileInd','var')
                
                FileList = GetFileNames(expt,RigDef.Dir.Data);
            else %
                fileheader = getfileheaderhelper(expt.name);

                for i = 1:length(fileInd)
                    FileList{i} = sprintf('%s_%d.daq',fileheader,fileInd(i));
                end
                
            end
        else % get blocks if it is a TDT expt
            PathName
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
        disp('Extacting Daq info ...')
        for i = 1:length(expt.files.names)
            disp(expt.files.names{i})
            if isTDTexpt(expt)
                [Fs,duration,triggers] = GetFsDurationTrig_TDThelper(fullfile(RigDef.Dir.Data,expt.files.names{i}));
                daqinfo = NaN;
            else
                % BA this step is terribly slow! 10-20s per file should be sped up!
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
    expt.sort.nTrodesComplete = [];
    expt.sort.totalunits = [];
    expt.sort.manualThresh = [];
    expt.sort.defaults = [];
    
    % Set sort.trode(m,n) fields. m is the number of tetrodes and n stores
    % sort sessions with different paramters, e.g. different threshold, or
    % source files.
    expt = addTrodeSort(expt);
    
    % Set stimulus fields (expt.stimulus)
    expt = AddStimParams(expt);
    
    % Add stimulus conditions to sweeps struct (expt.sweeps.stimcond)
    expt = exptAddStimCond(expt);
    
    % Add LED conditions to sweeps struct (expt.sweeps.led)
    if ~isTDTexpt(expt)
        bNoloadLEDCond = 1;
        expt = AddLEDCond(expt,LEDchn,bNoloadLEDCond);        
    else
%         nameTTL = 'LED';
        nameTTL = 'Ligh';
        expt = AddTTLCond(expt,nameTTL);                           %BA
    end
    
    % Assign in base workspace
    assignin('base','expt',expt);
    
    % Set analysis fields
    
    
    % Save expt struct
    save(FileName,'expt');
else
    [f p] = getFilename(FileName);
    display(sprintf('Expt NOT created:\n\tExpt: %s already exists in %s',f,p))
end



% --- Subfunctions --- %
function FileList = GetFileNames(expt,DataDir)

% Get list of daq files for experiment in raw data directory
files = dir([DataDir expt.name '*.daq']);
FileList = {files.name}';
if isempty(FileList)
    disp('No daq files found for this experiment name')
else
%     get header from expt.name which is everything until the first underscore.
%     use that is to find the list of pontential files 
fileheader = getfileheaderhelper(expt.name);


    PathName = fullfile(DataDir,[fileheader '*.daq']);
    dirResult = dirc(PathName,'f','d');
    FileList = dirResult(:,1);
    for i = 1:length(FileList) % order the files by creation date (the dir only orders by modification date)
        temp = getFileTime(fullfile(DataDir,FileList{i}));
        creationdate(i) =  datenum(temp.Creation);
    end
    [junk ind] = sort(creationdate);
    FileList = FileList(ind);
    
    [Selection,ok] = listdlg('ListString',FileList); pause(0.05)
    FileList = FileList(Selection);
    
    disp('The following daq files were found:')
    disp(FileList)
end


