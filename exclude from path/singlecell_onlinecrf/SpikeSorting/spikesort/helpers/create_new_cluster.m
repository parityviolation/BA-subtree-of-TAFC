function spikes = create_new_cluster( spikes, spikelist )

    if ~isfield( spikes.info, 'kmeans' ), error( 'Spikes object must have kmeans cluster'); end

    num_clusts = size( spikes.info.kmeans.colors, 1 );
    
    % change kmeans assigns
    spikes.info.kmeans.assigns( spikelist ) = num_clusts + 1;
   
    
    if isfield( spikes,'assigns')
        spikes.assigns(spikelist) = num_clusts + 1;
    end
    
    spikes = recolor_clusters(spikes);
    
    