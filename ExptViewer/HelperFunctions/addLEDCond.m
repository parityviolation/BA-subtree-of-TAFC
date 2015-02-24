function expt = addLEDCond(expt,LEDchn,bNoLoadLEDCond)
% function expt = addLEDCond(expt,LEDchn,bNoLoadLEDCond))
% %
% % LEDchn (optional) daq channel with LED condition supports multiple LEDchns
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
       LEDCond = LEDCond(2,:);
        if triggers>length(LEDCond), LEDCond = [ LEDCond nan(1,triggers-length(LEDCond))]; end        
        if length(LEDCond)>triggers, disp('WARNING more LEDCond then triggers.. data may be corrupt'); LEDCond = LEDCond(1:triggers); end
        expt.sweeps.led(startInd:startInd+triggers-1) = single(LEDCond);
    elseif nargin>1 % try and create _LEDCond from channel in daq
         fn = seperateFileExtension(getFilename(expt.files.names{i}));
       LEDfileName = [fn '_LEDCond'];
        disp(sprintf('****\t\t LEDCond file NOT Found \t\t****\n\t\tCreating %s', LEDfileName));

        LEDCond = zeros(1+length(LEDchn),triggers);
        for iledchn = 1:length(LEDchn) % for each LEDchn
            [bTTL ledamp] = getLEDCondfromDAQ(fn,LEDchn(iledchn),RigDef.Dir.Data);
            if 0 % old way do TTL here
                LEDCond(1+iledchn,1:size(bTTL{1},2)) = bTTL{1};
            else
                LEDCond(1+iledchn,1:size(ledamp{1},2)) = ledamp{1};
            end
            
            % BA it can happen that there are more TriggersExecuted ( than
            % there is data
            % (not sure why maybe if daq is terminated after trigger but before
            % sweep is complete?
            if iledchn==1 % special case cause led1 doesn't exist historically
                expt.sweeps.led(startInd:startInd+triggers-1) =  LEDCond(iledchn+1,:);
            else
                if isfield(expt.sweeps,sprintf('led%d',iledchn))
                    eval(sprintf('expt.sweeps.led%d(startInd:startInd+triggers-1) =  LEDCond(iledchn+1,:)',iledchn));
                else
                    expt.sweeps.(sprintf('led%d',iledchn)) =  LEDCond(iledchn+1,:);
                end
                
            end
        end
        save(fullfile(RigDef.Dir.Data,LEDfileName),'LEDCond');
    else
        expt.sweeps.led(startInd:startInd+triggers-1) = nan;
    end
    
    startInd = startInd + triggers;
    
end
