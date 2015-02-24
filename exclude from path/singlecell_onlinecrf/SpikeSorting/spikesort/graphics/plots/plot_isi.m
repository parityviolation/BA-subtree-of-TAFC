function plot_isi( spikes, clus, show_isi )

   if ~isfield(spikes,'waveforms'), error('No waveforms found in spikes object.'); end

    % deal with parameters
    if nargin < 3, show_isi = spikes.params.display.show_isi;  end
    if nargin < 2, clus = 'all'; end

    % get the spiketimes
    select = get_spike_indices(spikes, clus );
    
      
    spiketimes = sort( spikes.unwrapped_times(select) );
    
    % save data in these axes
    data.spiketimes         = spiketimes;
    data.show_isi           = show_isi;
    data.isi_maxlag         = spikes.params.display.max_isi_to_display;
    data.autocorr_maxlag    = spikes.params.display.max_autocorr_to_display;
    data.shadow             = spikes.params.shadow;
    data.refractory_period  = spikes.params.refractory_period;
    data.corr_bin_size           = spikes.params.display.correlations_bin_size;
    data.isi_bin_size           = spikes.params.display.isi_bin_size;

    [expected, lb, ub, RPV ] = poisson_contamination( spikes, select );
    if isempty(lb)
        data.ystr = [num2str(RPV) ' RPVs (' num2str(round(expected*100)) '%)' ];
    else    
        data.ystr = [num2str(RPV) ' RPVs (' num2str(round(lb*100)) '-' num2str(round(expected*100)) '-' num2str(round(ub*100)) '%)' ];
    end
    
    set(gca,'UserData', data,'Tag','isi' )

    % write updating method
    update_isi( [], [], show_isi, gca);
    
    

function update_isi( hObject, event, displaymode, ax)

        data = get( ax,'UserData');
        data.show_isi = displaymode;
        set(ax,'UserData',data)
        set(gcf,'CurrentAxes',ax )
        make_isi
    

    % set context menu
    cmenu = uicontextmenu;
    item(1) = uimenu(cmenu, 'Label', 'Show ISI', 'Callback', {@update_isi, 1,ax} );
    item(2) = uimenu(cmenu, 'Label', 'Show autocorr', 'Callback',{@update_isi, 0,ax}  );
    item(3) = uimenu(cmenu, 'Label', 'Use this style on all ISIs in figure', 'Callback',{@impose_all,displaymode,ax},'Separator','on'  );
    
    set(item(2-displaymode), 'Checked', 'on');    
    set(ax,'UIContextMenu', cmenu )

function impose_all(hObject,event,displaymode,ax)
        [o,h] = gcbo;
        my_axes = findobj(h,'Tag','isi');
        my_axes = setdiff(my_axes,ax);
        for j = 1:length(my_axes), update_isi([],[],displaymode,my_axes(j)); end
        
    
function make_isi     

    data = get( gca,'UserData');
    spiketimes = data.spiketimes;
    shadow = data.shadow;
    rp     = data.refractory_period;
    cla
    
    if data.show_isi
        maxlag = data.isi_maxlag;
        bins = round(1000* maxlag/data.isi_bin_size );

        % make plot
        isis = diff(spiketimes);   
        isis = isis(isis <= maxlag); 
        [n,x] =hist(isis*1000,linspace(0,1000*maxlag,bins));
        ymax   = max(n)+1;

        patch([0 shadow shadow 0 ], [0 0 ymax ymax], [.5 .5 .5],'EdgeColor', 'none');
        patch([shadow [rp rp] shadow ], [0 0 ymax ymax], [1 0 0],'EdgeColor','none');
        hold on,    b2 = bar(x,n,1.0); hold off
        set(b2,'FaceColor',[0 0 0 ],'EdgeColor',[0 0 0 ])

        set(gca,'YLim',[0 ymax],'XLim',[0 1000*maxlag])
        xlabel('Interspike interval (msec)')
       ylabel({'No. of spikes',data.ystr})
 
    else
        maxlag = data.autocorr_maxlag;
        
        if length(spiketimes) > 1
          [cross,lags] = pxcorr(spiketimes,spiketimes, round(1000/data.corr_bin_size), maxlag);
        else
            cross = 0;  lags = 0;
        end
        
        cross(find(lags==0)) = 0;

        ymax = max(cross) + 1;
        patch(shadow*[-1 1 1 -1], [0 0 ymax ymax], [.5 .5 .5],'EdgeColor', 'none');
        patch([shadow [rp rp] shadow ], [0 0 ymax ymax], [1 0 0],'EdgeColor','none');
        patch(-[shadow [rp rp] shadow ], [0 0 ymax ymax], [1 0 0],'EdgeColor','none');
        hold on, bb = bar(lags*1000,cross,1.0); hold off;  
        set(bb,'FaceColor',[0 0 0 ],'EdgeColor',[0 0 0 ])

        set(gca, 'XLim', maxlag*1000*[-1 1]);
        set(gca,'YLim',[0 ymax])
        xlabel( 'Time lag (msec)')
        ylabel({'Autocorrelation (Hz)',data.ystr})
    end
    set(gca,'Tag','isi','UserData',data)
    