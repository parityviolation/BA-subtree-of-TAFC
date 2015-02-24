function expt = addFiles(expt)
%
%
%
%

% Created: SRO - 7/15/10


% Set rig defaults
rigdef = RigDefs;

% Define files fields
expt.files.names = [];
expt.files.triggers = [];
expt.files.duration = [];
expt.files.Fs = [];

% Get file names
if ~isempty(expt.name)
    %%% TO DO switch on experiment type BA
    if ~isTDTexpt(expt)
        FileList = GetFileNames(expt,rigdef.Dir.Data);
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
            [Fs,duration,triggers] = GetFsDurationTrig_TDThelper(fullfile(rigdef.Dir.Data,expt.files.names{i})); 
            daqinfo = NaN;
        else
            [Fs,duration,triggers,daqinfo] = GetFsDurationTrig_NIDAQhelper([rigdef.Dir.Data expt.files.names{i}]);
        end
        if triggers == 0 % BA this can happen sometimes with a partially corrupted daq file
            keyboard % can enter triggers by hand
        end
        expt.files.triggers(i) = triggers;
        expt.files.duration(i) = duration;
        expt.files.Fs(i) = Fs;
        expt.files.daqinfo(i) = daqinfo;
    end
    
else
    expt.files.triggers = [];
    expt.files.duration = [];
    expt.files.Fs = [];
    expt.files.daqinfo = [];
end


% --- Subfunctions --- %
function FileList = GetFileNames(expt,DataDir)

% Get list of daq files for experiment in raw data directory
dirResult = dirc([DataDir expt.name '_' '*.daq'],'f');
FileList = dirResult(:,1);

if isempty(FileList)
    disp('No daq files found for this experiment name')
else  
    % only include files that are greater than X bytes (to avoid DAQ files that are empty
    filebytes   = cell2mat({dirResult{:,5}});
    ind = find(filebytes>7*2^10);
    FileList = FileList(ind);
    
      % order the files by creation date (the dir only orders by modification date)
    for i = 1:length(FileList) 
        temp = GetFileTime(fullfile(DataDir,FileList{i}));
        creationdate(i) =  datenum(temp.Creation);
    end
    [junk ind] = sort(creationdate);
    FileList = FileList(ind);

    disp('The following daq files were found:')
    disp(FileList)
end
