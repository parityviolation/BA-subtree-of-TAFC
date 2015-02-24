function which = get_spike_indices(spikes, show )

    num_spikes = size(spikes.waveforms,1);
    if isequal(show,'all')
        show = ones( [1 num_spikes ] );
    elseif length(show) < num_spikes
            if isfield( spikes,'assigns')
                show = ismember( spikes.assigns, show );
            elseif isfield(spikes.info,'kmeans')
                show = ismember( spikes.info.kmeans.assigns, show );
            else
                show = ones( [1 num_spikes ] );
            end
    end

    which = find(show);

