function spikes = remove_outliers(spikes, bad  )

    if ~isfield(spikes,'assigns'), error( 'Outlier removal must be performed after cluster aggregation.'); end
    
    subcluster_list = unique(spikes.info.kmeans.assigns);
    cluster_list    = unique(spikes.assigns);
    
    bad = get_spike_indices(spikes, bad );

    if ~isfield(spikes.info,'outliers')
        spikes.info.outliers.waveforms = [];
        spikes.info.outliers.subassigns = [];
        spikes.info.outliers.trials = [];
        spikes.info.outliers.spiketimes = [];
        spikes.info.outliers.pca.u = [];
        spikes.info.outliers.unwrapped_times = [];
        
    end
       
       % apply the change  
       spikes.info.outliers.waveforms = [spikes.info.outliers.waveforms; spikes.waveforms(bad,:,:) ];
       spikes.info.outliers.trials = [spikes.info.outliers.trials spikes.trials(bad) ];
       spikes.info.outliers.spiketimes = [spikes.info.outliers.spiketimes spikes.spiketimes(bad) ];
       spikes.info.outliers.subassigns = [spikes.info.outliers.subassigns spikes.info.kmeans.assigns(bad) ];
       spikes.info.outliers.pca.u = [spikes.info.outliers.pca.u; spikes.info.pca.u(bad,:) ];
      spikes.info.outliers.unwrapped_times = [spikes.info.outliers.unwrapped_times spikes.unwrapped_times(bad) ];
       
       % remove from original
       spikes.waveforms(bad,:,:) = [];
       spikes.trials(bad) = [];
       spikes.spiketimes(bad) = [];
       spikes.unwrapped_times(bad) = [];
       spikes.info.kmeans.assigns(bad) = [];
       spikes.assigns(bad)=[];
       spikes.info.pca.u(bad,:) = [];
       
       % update tree if whole subclusters have been removed
       subcluster_list = setdiff(subcluster_list, unique(spikes.info.kmeans.assigns) );
       for j = subcluster_list
           c.to = j; c.from = j;
           spikes = split_cluster(spikes, c);           
       end
           
       cluster_list = setdiff(cluster_list, unique(spikes.assigns) );
       which = ismember( spikes.labels(:,1), cluster_list );
       spikes.labels(which,:) = [];
       
           
      
    