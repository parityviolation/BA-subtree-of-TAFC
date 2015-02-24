function expt = AddLEDCond(expt,LEDchn,bNoLoadLEDCond)
% function expt = AddLEDCond(expt,LEDchn,bNoLbNoLoadLEDCondoad))
% %
% % LEDchn (optional) daq channel with LED condition (doesn't support
% multiple currently)
% if LEDchn is specified and _LEDCond.mat file doesn't exist, DAQ data from
% LEDchn will be used to create _LEDCond
%
% if bNoLoadLEDCond, DAQ data from LEDchn will be used even if _LEDCond.mat
% already exists
%
%   Created: 3/10 - SRO
%   Modified: 7/6/10 - BA added ability to create LEDcond file denovo

if nargin <3,bNoLoadLEDCond=0; end

RigDef = RigDefs;

startInd = 1;
for i = 1:length(expt.files.names)
    triggers = expt.files.triggers(i);
    fileInd = GetFileInd(expt.files.names{i});
    
    if ~isempty(dir([RigDef.Dir.Data expt.name '_' num2str(fileInd) '_LEDCond.mat'])) && ~ bNoLoadLEDCond;
        LEDfileName = [expt.name '_' num2str(fileInd) '_LEDCond'];
        load(fullfile(RigDef.Dir.Data,LEDfileName))
        % Remove nans, if they exists (this occurs when DaqController is
        % stopped before completing specified triggers)
        LEDCond(:,any(isnan(LEDCond),1)) = [];
        expt.sweeps.led(startInd:startInd+triggers-1) = LEDCond(2,:);
    elseif nargin>1 % try and create _LEDCond from channel in daq
         fn = seperateFileExtension(getFilename(expt.files.names{i}));
       LEDfileName = [fn '_LEDCond'];
        disp(sprintf('\t\tCreating %s', LEDfileName));
        bTTL = getLEDCondfromDAQ(fn,LEDchn,RigDef.Dir.Data);
        % make 2 row for compatibility.
        LEDCond = zeros(2,triggers);
        LEDCond(2,1:size(bTTL{1},2)) = bTTL{1};
        % BA it can happen that there are more TriggersExecuted ( than there is data
        % (not sure why maybe if daq is terminated after trigger but before
        % sweep is complete?
        expt.sweeps.led(startInd:startInd+triggers-1) =  LEDCond(2,:);
        save(fullfile(RigDef.Dir.Data,LEDfileName),'LEDCond');
    else
        expt.sweeps.led(startInd:startInd+triggers-1) = nan;
    end
    
    startInd = startInd + triggers;
    
end
