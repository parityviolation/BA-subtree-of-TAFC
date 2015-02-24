function [fileInd stimulusstruct] = spffileIndHelper(expt)
%kluge to deal with the fact that expt.analysis.spf. may not always be
%specified

% defualt
fileInd  = [];
stimulusstruct = [];
% Get fileInd for orientation files
bcheckorientation = 0;
if isfield(expt.analysis,'spf')
    fileInd = expt.analysis.spf.fileInd;
else bcheckorientation =1; end

if isempty(fileInd)||bcheckorientation
    %     check if spf is varied with orientation
    % is spf varied?
    orifileInd = expt.analysis.orientation.fileInd;
    if ~isempty(orifileInd)
        stimulusstruct = expt.stimulus(orifileInd(1));
        
        if length(stimulusstruct.varparam)>1
            if isequal( lower(stimulusstruct.varparam(2).Name),'spatial freq')
                fileInd = orifileInd(1);
            end
        end
    end
end

if ~isempty(fileInd)
        stimulusstruct = expt.stimulus(fileInd(1));
end