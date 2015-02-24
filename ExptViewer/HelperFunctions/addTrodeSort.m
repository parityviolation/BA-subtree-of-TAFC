function expt = addTrodeSort(expt,trode,trodeInd)
%
%   Add .sort.trode to expt
% trode.name and trode.channels must be included
if length(trode)>1
    error('can only add one trode at a time')
end
if nargin<3
    trodeInd = length(expt.sort.trode)+1;
end
% Add new TrodeSort

    expt.sort.trode(trodeInd).channels = trode.channels;
    expt.sort.trode(trodeInd).name = trode.name;
    expt.sort.trode(trodeInd).fileInds = [];
    expt.sort.trode(trodeInd).threshtype = [];
    expt.sort.trode(trodeInd).thresh = [];          % Update at end of Detect
    expt.sort.trode(trodeInd).detected = 'no';
    expt.sort.trode(trodeInd).clustered = 'no';
    expt.sort.trode(trodeInd).sorted = 'no';
    expt.sort.trode(trodeInd).numclusters = [];     % = unique(spikes.assigns)
    expt.sort.trode(trodeInd).numunits = [];        % User defines a unit
    expt.sort.trode(trodeInd).spikespersec = [];
    expt.sort.trode(trodeInd).spikesfile = [];
    % Set sort.trode(m).units(n) fields
     expt.sort.trode(trodeInd).unit = [];
    expt.sort.trode(trodeInd).unit.trode = [];
    expt.sort.trode(trodeInd).unit.channels = [];
    expt.sort.trode(trodeInd).unit.assign = [];
    expt.sort.trode(trodeInd).unit.label = [];
    expt.sort.trode(trodeInd).unit.rpv = [];
    expt.sort.trode(trodeInd).unit.spikespersec = [];
    expt.sort.trode(trodeInd).unit.peakrate = [];
    expt.sort.trode(trodeInd).unit.spontaneousrate = [];       
    expt.sort.trode(trodeInd).unit.numspikes = [];
    expt.sort.trode(trodeInd).unit.bursting = [];
    expt.sort.trode(trodeInd).unit.waveform.amplitude = [];             % Need function that computes these paramters from raw data
    expt.sort.trode(trodeInd).unit.waveform.width = [];
    expt.sort.trode(trodeInd).unit.waveform.peak = [];
    expt.sort.trode(trodeInd).unit.waveform.trough = [];
    expt.sort.trode(trodeInd).unit.waveform.troughpeakratio = [];
    expt.sort.trode(trodeInd).unit.waveform.maxampchannel = [];
    expt.sort.trode(trodeInd).unit.waveform.waveformtype = [];
    expt.sort.trode(trodeInd).unit.waveform.avgwave = [];
end


