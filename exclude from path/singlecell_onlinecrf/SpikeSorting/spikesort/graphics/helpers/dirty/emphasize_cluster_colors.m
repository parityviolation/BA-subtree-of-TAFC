function colors = emphasize_cluster_colors(spikes) 

    clust_list = sort(unique(spikes.assigns));
    num_subclusters = max([spikes.info.kmeans.assigns clust_list]);
    cmap       = jetm(  num_subclusters );
    colors     = zeros(size(cmap) );
    
    % choose cluster indices to be well spread out
    cluster_indices = round( linspace(1,num_subclusters,length(clust_list) ) );
    colors(clust_list,:) = cmap(cluster_indices,:);
    
    % randomly assign the rest from the latter
    remaining_indices = setdiff(1:num_subclusters, cluster_indices );
    remaining_list    = setdiff(1:num_subclusters, clust_list );
    colors( remaining_list,: ) = cmap( randperm(length(remaining_indices)), : );
