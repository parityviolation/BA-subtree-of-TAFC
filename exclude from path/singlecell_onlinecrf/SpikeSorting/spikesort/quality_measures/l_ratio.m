function stat = l_ratio( spikes, cluster )

    if length(cluster) == 1
        nonmembers = find( spikes.assigns ~= cluster );
        members = find( spikes.assigns == cluster ); 
    else
        members = cluster;
        nonmembers = setdiff( 1:length(spikes.assigns), members );
    end

    d = diag(spikes.info.pca.s);
    r = find( cumsum(d)/sum(d) >.95,1);
    waves = spikes.waveforms(:,:) * spikes.info.pca.v(:,1:r);
    num_members = length(members);
        
      mahaldists = sort( mahal(waves, waves) );
      stat = ( length(nonmembers) - sum( chi2cdf( mahaldists, r ) ) ) / num_members;
     
     