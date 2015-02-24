function [cross,lags,collision_range] = plot_xcorr( spikes, c1, c2 )

   if ~isfield(spikes,'waveforms'), error('No waveforms found in spikes object.'); end

   select1 = get_spike_indices(spikes, c1 );
   select2 = get_spike_indices(spikes, c2 );

    cla   

    % get data
    data.st1 = spikes.unwrapped_times(select1);
    data.st2 = spikes.unwrapped_times(select2);
    
    data.show_xcorr = spikes.params.display.default_xcorr_mode;
    data.shadow             = spikes.params.shadow;
    data.refractory_period  = spikes.params.refractory_period;
    data.corr_bin_size           = spikes.params.display.correlations_bin_size;
    data.maxlag = spikes.params.display.max_autocorr_to_display;  % (msec);
    
    % RPV stats
    RPV1 = sum(diff(data.st1) < data.refractory_period / 1000 );
    RPV2 = sum(diff(data.st2) < data.refractory_period / 1000 );
    st12 = sort( [data.st1 data.st2] );
    data.tot_rpv = sum(diff(st12) < data.refractory_period / 1000 );
    data.new_rpv = data.tot_rpv - (RPV1+RPV2);
    data.exp_rpv = round( 2*((data.refractory_period - data.shadow)/1000)*length(data.st1)*length(data.st2)/sum(spikes.info.detect.dur) );

    set(gca,'UserData', data,'Tag','xcorr' )

    % write updating method
    update_xcorr( [], [], data.show_xcorr, gca);
end 
    

function update_xcorr( hObject, event, displaymode, ax)

        data = get( ax,'UserData');
        data.show_xcorr = displaymode;
        set(ax,'UserData',data)
        set(gcf,'CurrentAxes',ax )
        make_xcorr
    

    % set context menu
    cmenu = uicontextmenu;
    item(1) = uimenu(cmenu, 'Label', 'Show x-corr of spike trains', 'Callback', {@update_xcorr, 1,ax} );
    item(2) = uimenu(cmenu, 'Label', 'Show autocorr of merged spike trains', 'Callback',{@update_xcorr, 0,ax}  );
    item(3) = uimenu(cmenu, 'Label', 'Use this style on all ISIs in figure', 'Callback',{@impose_all,displaymode,ax},'Separator','on'  );
    
    set(item(2-displaymode), 'Checked', 'on');    
    set(ax,'UIContextMenu', cmenu )
end

function impose_all(hObject,event,displaymode,ax)
        [o,h] = gcbo;
        my_axes = findobj(h,'Tag','xcorr');
        my_axes = setdiff(my_axes,ax);
        for j = 1:length(my_axes), update_xcorr([],[],displaymode,my_axes(j)); end
end
    
function make_xcorr     

    data = get( gca,'UserData');
    shadow = data.shadow;
    rp     = data.refractory_period;
    maxlag = data.maxlag;

    cla
    
    if data.show_xcorr
        st1 = data.st1;
        st2 = data.st2;
        ystr{1} = 'Cross-corr (Hz)';
    else
        st1 = sort( [data.st1 data.st2] );
        st2 = st1;
        ystr{1} = 'Merged Autocorr (Hz)';
    end
        ystr{2} = ['N_1 = ' num2str(length(data.st1)) ', N_2 = ' num2str(length(data.st2))];
        
        if length(st1) > 1 & length(st2) > 1
          [cross,lags] = pxcorr(st1,st2, round(1000/data.corr_bin_size), maxlag);
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
        ylabel(ystr)
        title( [ 'RPVs: ' num2str(data.new_rpv) ' NEW, '  num2str(data.tot_rpv) ' TOT, ' num2str( data.exp_rpv ) ' EXP']);  
    set(gca,'Tag','xcorr','UserData',data)
    end