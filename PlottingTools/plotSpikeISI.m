function [hAx ] = plotSpikeISI(spikes,Electrode,Unit,hAx)

if exist('Electrode','var')
    if ~isempty(Electrode)
        if isfield(spikes,'waveforms')
            spikes = rmfield(spikes,'waveforms'); % to save time;
        end
        spikes = filtspikes(spikes,0,{'Electrode',Electrode,'Unit',Unit});
    end
end

spikes.unwrapped_times = spikes.spiketimes/1000;
spikes.params.display.show_isi = 1;
spikes.params.display.max_isi_to_display = 0.0500;

hAx = plot_isi(spikes,[],[],hAx);