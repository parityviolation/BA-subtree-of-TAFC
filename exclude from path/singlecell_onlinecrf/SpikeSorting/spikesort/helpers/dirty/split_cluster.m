function [spikes, new_clust] = split_cluster(spikes, clustnum)
% SPLIT_CLUSTERS  Split a cluster after automatic hierarchical aggregation.
%    SPIKES = SPLIT_CLUSTERS(SPIKES, CLUSTER_NUMBER) takes and returns a spike-
%    sorting object SPIKES.  SPIKES must have gone through a hierarchical
%    clustering aggregation (e.g., SS_AGGREGATE) previous to this function call.
%   
%    The spikes belonging to the cluster whose label number is given by
%    CLUSTER_NUMBER are split into the two clusters by undoing the last step
%    in the aggregation tree involving the cluster with label CLUSTER_NUMBER.
%    The hierarchical cluster assignments and aggregation tree is modified to
%    reflect this change.
%
 
%%%%%%%%%% ARGUMENT CHECKING
if (~isfield(spikes.info, 'tree'))
	error('SS:hierarchical_information_unavailable', 'Hierarchical clustering must be performed before attempting to merge clusters.');
end
tree = spikes.info.tree;

if isstruct( clustnum )  
    orig_clust = spikes.assigns( find( spikes.info.kmeans.assigns == clustnum.to, 1) );
    
    % find line in tree structure that represents the completed sub-tree
    a = find( tree(:,1) == clustnum.to & ismember( tree(:,2), clustnum.from), 1, 'last');
    if isempty(a), a = 0; end
    
    % find the next thing that gets added to me
    b = find( tree(:,1) == clustnum.to );
    
    if ~isempty( find( b > a ) )
        
        idx = b( find( b > a, 1 ) );
        alt_clus = tree(idx,2);
        
        % remove this line
        tree(idx,:) = [];
        
        % replace anything else with me
        alt_tree = tree;
      
        alt_tree( alt_tree == clustnum.to ) = alt_clus;
        tree(idx:end,1:2) = alt_tree(idx:end,1:2);  
    else
        
       idx = [find(tree(a+1:end,1) == clustnum.to ) find(tree(a+1:end,2) == clustnum.to )];
       tree( a + idx,:) = [];
       
    end    
    
   % renumber from tree
   spikes.assigns = spikes.info.kmeans.assigns;
   for j = 1:size(tree,1)
            spikes.assigns(  spikes.assigns == tree(j,2)) = tree(j,1);
   end
   
   spikes.info.tree =tree;    
    
   new_clust = setdiff( unique(spikes.assigns), spikes.labels(:,1)');
   
else
    
        % assumes you want to split a microcluster
        
        a = find( spikes.info.kmeans.assigns == clustnum );
        orig_clust = spikes.assigns(a(1));
        
        new_clust = max(spikes.info.kmeans.assigns) + 1;
        % how to decide    
        proj = pcasvd(spikes.waveforms(a,:));
        
        switching = a( find( proj(:,1) < median(proj(:,1)) ) );  
        spikes.info.kmeans.assigns( switching ) = new_clust;
        spikes.assigns( switching ) = new_clust;
        
end

if ~isempty(new_clust)
  pos = find( spikes.labels(:,1) == new_clust); 
  if isempty(pos), pos = size(spikes.labels,1) + 1; end
  spikes.labels(pos,:) = [new_clust 1];
end
if ~isempty(orig_clust)
 orig = find(spikes.labels(:,1) == orig_clust);
 spikes.labels( orig,2) = 1; 
end 
[junk,a] = sort(spikes.labels(:,1)); spikes.labels = spikes.labels(a,:);
spikes.info.kmeans.colors = emphasize_cluster_colors(spikes);



      
   