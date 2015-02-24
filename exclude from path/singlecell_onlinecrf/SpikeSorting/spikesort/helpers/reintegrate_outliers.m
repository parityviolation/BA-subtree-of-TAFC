function spikes=  reintegrate_outliers( spikes, indices, subcluster )

    if ~isfield( spikes.info,'outliers'), error('No outliers present.');end
        
    num_outliers = length(indices);

    % need to create a new subcluster for these guys
    isnew = ~ismember( subcluster,spikes.info.kmeans.assigns);
    if ~isnew
        newassign =  spikes.assigns( find(spikes.info.kmeans.assigns,1) );
    else
        newassign =  subcluster; 
    end
    
    % add back in
    o = spikes.info.outliers;
    spikes.waveforms = [spikes.waveforms; o.waveforms(indices,:,:)];
    spikes.info.kmeans.assigns = [spikes.info.kmeans.assigns subcluster*ones([1 num_outliers]) ];
    spikes.trials = [spikes.trials o.trials(indices)];
    spikes.spiketimes = [spikes.spiketimes o.spiketimes(indices)];
    spikes.unwrapped_times = [spikes.unwrapped_times o.unwrapped_times(indices)];
    spikes.assigns = [spikes.assigns newassign*ones([num_outliers 1]) ];
    spikes.info.pca.u = [spikes.info.pca.u; o.pca.u(indices,:) ];
    
    % remove from outliers
    
    spikes.info.outliers.waveforms(indices,:,:)=[];
    spikes.info.outliers.subassigns(indices)=[];
    spikes.info.outliers.spiketimes(indices) = [];
    spikes.info.outliers.unwrapped_times(indices) = [];
    spikes.info.outliers.trials(indices) = [];
    spikes.info.outliers.pca.u(indices,:) = [];
    
    
    
    % recolor if adding new cluster
    if isnew
      spikes = recolor_clusters( spikes );
      spikes.labels(end+1,:) = [newassign 1];
    else
      which = find(spikes.labels(:,1) == newassign );
      spikes.labels(which,:) = [newassign 1];
        
    end

    
    
end