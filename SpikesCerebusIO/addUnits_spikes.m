function [spikes ind]= addUnits_spikes(spikes, ElectrodeUnitID )

ind = [];

if iscell(ElectrodeUnitID)
    labels = ElectrodeUnitID(:,3);
    ElectrodeUnitID = cell2mat(ElectrodeUnitID(:,1:2));
end

for iunit = 1:size(ElectrodeUnitID,1)
    this_spikes = filtspikes(spikes,0,{'Electrode',ElectrodeUnitID(iunit,1),'Unit',ElectrodeUnitID(iunit,2)});
    if ~isfield(spikes,'units')
        spikes.units.Electrode = [];
        spikes.units.UnitID = [];
        spikes.units.wv = [];
        spikes.units.wvstd =[];
    end
    nUnits = length(spikes.units.Electrode);
    spikes.units.Electrode(nUnits+1) = ElectrodeUnitID(iunit,1);
     spikes.units.UnitID(nUnits+1) = ElectrodeUnitID(iunit,2);
    spikes.units.wv(nUnits+1,:) = mean(this_spikes.waveforms);
    spikes.units.wvstd(nUnits+1,:) = std(double(this_spikes.waveforms));
    if exist('labels','var') ,spikes.units.label(nUnits+1,:) = labels(iunit); end
ind(end+1) = nUnits+1;

end