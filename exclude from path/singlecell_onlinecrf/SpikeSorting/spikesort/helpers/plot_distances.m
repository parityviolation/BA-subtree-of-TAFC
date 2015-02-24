function [z,dof] = plot_distances( spikes, show, method )

    if ~isfield(spikes,'waveforms'), error('No waveforms found in spikes object.'); end

    if nargin < 2, show = 1:size(spikes.waveforms,1); end
    if nargin< 3, method = spikes.params.display.default_outlier_method; end
        
    % which spikes are we showing?
    show = get_spike_indices(spikes, show );
   
    data.waveforms = spikes.waveforms(show,:);
    data.data_cov  = cov( data.waveforms );
    data.noise_cov = spikes.info.detect.cov;
    num_dims = size(data.waveforms(:,:),2);
    
    set(gca,'UserData', data.waveforms );

    xlabel( 'Z-score');
    ylabel('Count');
    
    % plot z-scores
    if method == 1
        [z,dof] = get_zvalues( data.waveforms, data.data_cov );
    elseif method == 2
        [z,dof] = get_zvalues( data.waveforms, data.noise_cov );
    end
        
    [n1,x1] = hist(z,100);
    hold on;  hist(z,100); hold off;
    hndl = findobj(gca,'Type','patch'); 
    set(hndl,'FaceColor',[ 0 0 1] )
        

    % plot theoretical values
    y =  chi2pdf(x1,dof);
    y = y * length(z) * ( x1(2)-x1(1));

    l = line(x1,y);
    set(l,'Color',[0 1 0],'LineWidth',1)

        % legend
%         cmenu = uicontextmenu;
        
        % menu item for method
  %      uimenu(cmenu, 'Label', 'Estimate z-scores from background noise', 'Callback',@toggle_method ,'Checked',bool2word(figdata.zvalue_method),'Tag','zvalue_option');
   %     set(ax,'UIContextMenu',cmenu)
        
        %        place menu to switch method
        %        make vertical line dynamic
    %    set(ax,'ButtonDownFcn',{@axes_clicked,h,ax,l})
        
    end
