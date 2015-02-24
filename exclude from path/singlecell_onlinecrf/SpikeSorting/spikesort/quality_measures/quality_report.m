function report = quality_report( spikes, cluster, display )

    % error checking
    if nargin < 3, display = 0; end
    if ~isfield(spikes,'assigns'), error( 'Spikes structure must have assignments' );end
    if length(cluster) ~= 1, error('Must specify a single cluster ID'); end

    %
    % missing due to threshold 
    %
    [blah,bluh,bleh,report.below_thresh] = plot_detection_criterion(spikes,cluster,0);
   
    % refractory period violation range
    [expected, lb, ub, RPV ] = poisson_contamination( spikes, cluster );
    report.RPV.lb = lb;
    report.RPV.ub = ub;
    report.RPV.num = RPV;
    report.RPV.expected = expected;
    
    
    % collisions with entire data set  
    N1 = sum( spikes.assigns == cluster );
    TOTAL = length(spikes.assigns);
    if isfield( spikes.info,'outliers')
        if isfield( spikes.info.outliers, 'waveforms')
        TOTAL = length(spikes.info.outliers.waveforms ) + TOTAL;
    end
    report.expected_collisions = poissinv([.025 .975],  2*(spikes.params.window_size/1000)*N1*TOTAL/sum(spikes.info.detect.dur)) / N1;
   
    % multivariate gaussian overlap
    other_clusters = setdiff( unique(spikes.assigns), cluster );

    w1 = spikes.waveforms( spikes.assigns == cluster ,: );

    for j = 1:length( other_clusters )
        w2 = spikes.waveforms( spikes.assigns == other_clusters(j), : );
       report.confusion.matrix{j} = gmm_overlap( w1,w2 );
       report.confusion.cluster(j) = other_clusters(j);
    end

end
