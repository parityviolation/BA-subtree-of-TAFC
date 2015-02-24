function [expected, lb, ub, RPV ] = poisson_contamination( spikes, cluster  )

    if length(cluster) == 1
        members = find( spikes.assigns == cluster ); 
    else
        members = cluster;
    end
     
    spiketimes =  sort( spikes.unwrapped_times(members) );
  
    N = length( members );
    T = sum( spikes.info.detect.dur );
    RP = (spikes.params.refractory_period - spikes.params.shadow) * .001; 
    RPV  = sum( diff(spiketimes)  <= (spikes.params.refractory_period * .001) );
    
    [lb,ub,expected] = get_rpv_range(N, T, RP, RPV );
    
    
