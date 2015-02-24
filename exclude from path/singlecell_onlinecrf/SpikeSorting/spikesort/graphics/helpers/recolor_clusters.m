function spikes = recolor_clusters( spikes )

   if ~isfield(spikes,'assigns'), error('No assignments found in spikes object.'); end
 
    clust_list = sort(unique( spikes.assigns ) );
    max_subclust = max(spikes.info.kmeans.assigns );
  
    cmap = jetm(max_subclust);
    
    % fill in colors for clusters
    indices = round( linspace( 1,max_subclust, length(clust_list) + 1 ) );
    indices = indices(1:end-1);
    for j = 1:length(clust_list)
        newcmap( clust_list(j), :) = cmap(indices(j),:);
    end
    
    % fill in colors for subclusters
    cmap(indices,:) = [];
    others = setdiff( 1:max_subclust, clust_list );
    for j = 1:length(others)
        newcmap(others(j),:) = cmap(j,:);
    end
    spikes.info.kmeans.colors = newcmap;
    