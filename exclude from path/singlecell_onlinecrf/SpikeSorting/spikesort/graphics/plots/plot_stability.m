function [ax1,ax2] = plot_stability( spikes, clus)

   if ~isfield(spikes,'waveforms'), error('No waveforms found in spikes object.'); end
   if nargin < 2, clus = 'all'; end
    cla
   
    select = get_spike_indices(spikes, clus );
        
    memberwaves = spikes.waveforms(select,:);
    spiketimes  = sort( spikes.unwrapped_times( select ) );
    ax1 = gca;
     
    % first pass is firing rate observed in 10 second chunks
    tlims = [0 sum(spikes.info.detect.dur)];  
    num_bins  = round( diff(tlims) /  spikes.params.display.stability_bin_size);
    edges = linspace(tlims(1),tlims(2),num_bins+1);
    n = histc(spiketimes,edges);  
    n(end) = [];    
    vals = n/mean(diff(edges));
    hold on
    bar(edges(1:end-1) + mean(edges(1:2)),vals,1.0);  shading flat;
    hold off
    set(gca, 'XLim', tlims,'YLim',[0 2*max(get(gca,'YLim'))])
    yticks = get(gca,'YTick'); set(gca,'YTick',yticks( yticks<=max(yticks)/2))
    xlabel('Time (sec)')
    ylabel('Firing rate (Hz)')
    
    % second pass is scatter plot of amplitude versus time
       
    % get amplitudes over time
    amp = range(    memberwaves' );
    
    % only plot subset
    if isequal( spikes.params.display.max_scatter, 'all')
        ind = 1:length(amp);
    else
        choice = randperm( length(amp) );
        max_pos = min( length(amp), spikes.params.display.max_scatter );
        ind = choice(1:max_pos );
    end
    ax2 = axes('Parent',get(ax1,'Parent'),'Unit',get(ax1,'Unit'),'Position',get(ax1,'Position'));
    hold on
    l = scatter(spiketimes(ind),amp(ind));
    hold off
    l1 = line( get(ax2,'XLim'), [ 0 0] );
    set(l1,'Color',[ 0 0 0])
    hold off
    set(l,'Marker','.','MarkerEdgeColor',[.3 .5 .3])
    set(ax2,'Xlim',tlims,'YLim',max( get(ax2,'YLim') ) *[-1 1],'XTickLabel',{},'YAxisLocation','right');
    yticks = get(ax2,'YTick'); set(ax2,'YTick',yticks(yticks>=0))
    ylabel('Amplitude')
    set(ax2,'Color','none')
    linkaxes([ax1 ax2],'x');
    linkprop([ax1 ax2],'Position');
    linkprop([ax1 ax2],'Unit');
    
