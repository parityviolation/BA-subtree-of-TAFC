function stat = isolation_distance(spikes,cluster)

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

     if num_members > length(nonmembers)
        warning( 'Isolation distance is not defined if cluster is greater than half the data set.');
        stat = [];
     else
         mahaldists = sort( mahal( waves, waves ) );
         stat = mahaldists( min( num_members, length(nonmembers ) ) );
     end
     

     
     
     