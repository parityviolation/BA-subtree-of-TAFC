function plot_residuals( spikes, clus )

    cla
    % calculate standar deviations
    if nargin < 2, clus = 'all'; end
    clus = get_spike_indices(spikes, clus );
    memberwaves = spikes.waveforms(clus,:);
     
    num_channels = size(spikes.waveforms,3);
    num_samples  = size(spikes.waveforms,2);
    s = std( memberwaves );  
    
    set( line(1:length(s),s) ,'Color', [.3 .5 .3],'LineWidth',1.5)
    
   
   % plot true standard deviations
    for j = 1:num_channels
        x = [1 num_samples+1] + (j-1)*num_samples;
        stdev = abs( spikes.info.detect.stds(j) );
        [lb,ub] = std_bounds(stdev, length(clus), .95);
       l(j) =  line( x, [1 1] * stdev );
       
       p(j)  = patch( [ x fliplr(x)], [lb lb ub ub],[1 .8 .8]);
    end
  
    axis tight;          
    set(gca,'YLim',[0  max( max(get(gca,'YLim'),2*max(spikes.info.detect.stds)))]);
    
    % draw dividers
    for j = 1:num_channels-1
        set( line( 1 + num_samples * j * [1 1], get(gca,'YLim')), 'Color',[1 0 0] ) % electrode dividers
    end
    
    set( l, 'Color',[ 0 0 0],'LineStyle',':','LineWidth',2)
    xlabel('Sample')
    ylabel('Residuals')
    uistack(p,'bottom')
  
    
function [lb,ub] = std_bounds( stdev, N, p )

    if nargin < 3, p = .95; end

    bounds = (1 + p*[-1 1]) / 2;
     
    x = chi2inv( bounds,N-1);
    x = (stdev^2) * x / (N-1);

    lb = x(1)^.5; ub = x(2)^.5;
    
    