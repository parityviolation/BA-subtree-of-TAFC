function expt = addTrodeSortfromProbe(expt)
%
%   Add .sort.trode to expt

% Created: 4/9/10 - SRO
% Modified: 5/22/10 - SRO: Changed .fileInds to .fileInd. Removed .label.
% In .unit, removed .priority, .clustertype as these are superseded by
% unit.label.
% 9/27/10 seperated addTrodeSort out from addTrodeSortfromProbe so that fucntion can be used
% to add other sorts BA

% Add new TrodeSort
for trodeInd = 1:expt.probe.numtrodes
    trode.channels = expt.probe.trode.sites{trodeInd};
    trode.name =  expt.probe.trode.names{trodeInd};
    expt = addTrodeSort(expt,trode,trodeInd);
end


