function plot_waveforms( spikes, show, colormode,issubtree)

   if ~isfield(spikes,'waveforms'), error('No waveforms found in spikes object.'); end

    if nargin < 2, show = 1:size(spikes.waveforms,1); end
    if nargin< 4, issubtree = 0; end
    
    
    
    data.ylims = [min(spikes.waveforms(:)) max(spikes.waveforms(:))];
        
    % which spikes are we showing?
    show = get_spike_indices(spikes, show );
    
    
    % what are the possible colormodes and which one are we in?
    data.valid_modes = [1 isfield(spikes.info,'kmeans') isfield(spikes,'assigns')];
    if nargin < 3, 
        data.colormode = 1 + find(data.valid_modes,1,'last' );
    else
        data.colormode = colormode;
    end
    
    spiketimes =  sort( spikes.unwrapped_times(show) );
     
     data.rpv  = sum( diff(spiketimes)  <= (spikes.params.refractory_period * .001) );

    data.waveforms = spikes.waveforms(show,:,:);
    data.cmap = spikes.params.display.cmap;
    if any(data.valid_modes(2:3))
        data.colors = spikes.info.kmeans.colors;
        if data.valid_modes(3), data.assigns   = spikes.assigns(show); end
        if data.valid_modes(2), data.subassigns   = spikes.info.kmeans.assigns(show); end
    end
     data.time_scalebar =  spikes.params.display.time_scalebar;
    data.displaymode = spikes.params.display.default_waveformmode;
    data.defaultcolor = [0.5 0 0];
    data.Fs = spikes.params.Fs;

    % set up title and bar color
    if data.colormode == 4 & length(unique(spikes.assigns(show))) == 1
        data.title = ['Cluster # ' num2str( spikes.assigns(show(1)) ) ];
        data.barcolor = data.colors(  spikes.assigns(show(1)),: );
      
    elseif issubtree
        % this is a bit of a hack:  if we are plotting a subtree, want to make color
        % and name same as subtree tope node. 
        subclusterlist = unique( spikes.info.kmeans.assigns(show) )';
        idx = find( ismember( spikes.info.tree(:,1), subclusterlist ), 1,'last');
        if isempty(idx)
            subclus =  spikes.info.kmeans.assigns(show(1));
        else
            subclus = spikes.info.tree(idx,1);
        end
        data.title = ['Subcluster # ' num2str(subclus) ];
        data.barcolor = data.colors( subclus,: );
    elseif data.colormode == 3 & length(unique(spikes.info.kmeans.assigns(show))) == 1
        data.title = ['Subcluster # ' num2str( spikes.info.kmeans.assigns(show(1)) ) ];
        data.barcolor = data.colors( spikes.info.kmeans.assigns(show(1)),: );
    elseif data.valid_modes(3) 
        data.title = [num2str( length(unique(spikes.assigns(show))) ) ' clusters'];
        data.barcolor = [1 0 0];
    elseif  data.valid_modes(2) 
        data.title = [num2str( length(unique(spikes.info.kmeans.assigns(show))) ) ' subclusters'];
        data.barcolor = [1 0 0];
    else
        data.title = 'Unclustered data';
        data.barcolor = [1 0 0];
    end
        
     
    data.subcluster = data.colormode - 3;


    % save user data
    set(gca,'UserData', data,'Tag','waveforms' )

    % update display
    update_waveforms( [], [], data.colormode, data.displaymode, gca);


function update_waveforms( hObject, event, colormode, displaymode, ax)
   
    if displaymode == 2, colormode = max(colormode,2); end
    if displaymode == 3, colormode = 2; end
    
    data = get( ax,'UserData');
    data.colormode = colormode;
    data.displaymode = displaymode;
    set(ax,'UserData',data)
    set(gcf,'CurrentAxes',ax )
    make_waveforms(ax, data);

    set(ax,'UIContextMenu', get_menu(colormode,displaymode,data.valid_modes, ax) )


function impose_all( hObject, event, colormode, displaymode, ax)
   
       [o,h] = gcbo;     
   
        my_axes = findobj( h,'Tag','waveforms');
        my_axes = setdiff( my_axes, ax );
        for j = 1:length(my_axes)
                update_waveforms( [], [], colormode, displaymode, my_axes(j));
        end

    
function cmenu = get_menu( colormode, displaymode,valid_modes,ax )

    cmenu = uicontextmenu;

    % COLORMODES
    colormodes = {'All different','All same','By subcluster', 'By cluster'};
    if ~valid_modes(3), colormodes(4) = []; end
    if ~valid_modes(2), colormodes(3) = []; end
        
    for j = 1:length(colormodes)
        c(j) = uimenu(cmenu, 'Label', colormodes{j}, 'Callback', {@update_waveforms, j, displaymode,ax} );
    end
    set(c(colormode),'Checked','on');
    if displaymode == 2, set( c(1),'Enable','off'); end
    if displaymode == 3, set( c,'Enable','off'); end
    
    %DISPLAYMODES
    d(1) = uimenu(cmenu, 'Label', 'Raw', 'Callback', {@update_waveforms, colormode, 1,ax},'Separator','on');
    d(2) = uimenu(cmenu, 'Label', 'Bands', 'Callback',{@update_waveforms, colormode, 2,ax});
    d(3) = uimenu(cmenu, 'Label', '2D histogram', 'Callback',{@update_waveforms, colormode, 3,ax});
    set(d(displaymode),'Checked','on');

    %IMPOSE ON ALL
    uimenu(cmenu, 'Label', 'Use this style on all waveforms in figure', 'Callback', {@impose_all, colormode, displaymode,ax},'Separator','on');

    %LEGEND
    if colormode >= 3 & displaymode < 3
      uimenu(cmenu, 'Label', 'Show legend', 'Callback',@toggle_legend,'Separator','on','Checked',get(legend,'Visible'),'Tag','legend_option');
    end
    
function toggle_legend(varargin)
     
    item = findobj( get(gca,'UIContextMenu'),'Tag', 'legend_option');
    
    if isequal( get(legend,'Visible'),'on')
       legend('hide'); set(item,'Checked','off');
   else
       legend('show'); set(item,'Checked','on');
   end
   


    
function make_waveforms(ax,data)

% unpack
displaymode = data.displaymode;
colormode = data.colormode;
waveforms = data.waveforms;
defaultcolor = data.defaultcolor;
time_scalebar = data.time_scalebar;
Fs           = data.Fs;

if data.colormode == 2
    colors = defaultcolor;
    assigns = ones([1 size(waveforms,1)]);
 elseif data.colormode == 3
    colors = data.colors;
    assigns = data.subassigns;
elseif data.colormode == 4
    colors = data.colors;
    assigns = data.assigns;
end

cla; 
legend off
set(gca,'Color',[ 1 1 1])
hold on

%
% DISPLAY WAVEFORMS
%
num_samples = size(waveforms(:,:),2);

if displaymode == 1 & colormode == 1
       plot( 1:size(waveforms(:,:),2), waveforms(:,:) );
elseif displaymode == 3
     cmap = data.cmap;
     [n,x,y] = histxt(waveforms(:,:));  
     h = imagesc(x,y,n);  
     colormap(cmap);
     set( gca,'Color', cmap(1,:) );    

else
    clusts = sort(unique(assigns));
    for j = 1:length(clusts)
      
        color = colors( clusts(j),:);
        mine = find( assigns == clusts(j) );
        if displaymode == 1
            lh(j) = mplot(1:num_samples, waveforms(mine,:), 'Color', color);
            set(lh(j), 'ButtonDownFcn', {@raise_me, lh(j)});

        elseif displaymode == 2
            
             % group traces and show +/- 2 standard deviations            
              [lh(j) ,ph(j)] = error_area(mean(waveforms(mine,:),1), 2*std(waveforms(mine,:),1,1));
              set(lh(j), 'Color', brighten(color, -0.6), 'ZData', clusts(j)* ones( size(get(lh(j),'XData')))  );
              set(ph(j), 'FaceColor', color, 'ZData', clusts(j)* ones( size(get(ph(j),'XData'))), 'FaceAlpha', 0.8);  
              set([lh(j) ph(j)], 'ButtonDownFcn', {@raise_band, [lh(j) ph(j)] });        
           
        else
              error(['Invalid plot_waveforms display mode (' num2str(displaymode) ') or color mode (' num2str(colormode) ').' ] );
        end
    end
end
hold off

set(gca,'Tag','waveforms','XLim',[1 num_samples],'YLim',data.ylims)


%
% VERTICAL LINE
%
num_channels = size(waveforms,3);
num_samples = size(waveforms,2);
ylims = get(gca,'YLim');
if num_channels > 1
    if displaymode == 2
       for j = 1:num_channels-1
            l(j) = line( 1 + num_samples * j * [1 1], ylims, max(clusts)*[1 1] + 1);           
       end
        set(l,'ButtonDownFcn', {@raise_band, l})
    else
       for j = 1:num_channels-1
            l(j) = line( 1 + num_samples * j * [1 1], ylims);
       end
           set(l,'ButtonDownFcn', {@raise_me, l})
    end
      set( l, 'Color',[1 0 0],'LineWidth',1.5 ) % electrode dividers
end
%
% SCALE BAR
%
ms =  time_scalebar*Fs/1000;
maxX = num_channels*num_samples;
lineY = ylims(1) + (ylims(2)-ylims(1)) * .075;
l = line(  maxX - 5 - [0 ms], lineY*[1 1] );

if displaymode == 2,
    set(l,'ButtonDownFcn', {@raise_band, l})
else
       set(l,'ButtonDownFcn', {@raise_me, l})
end
set(l,'Color',data.barcolor,'LineWidth', 3)

% %
% % LEGEND
% %
if colormode >= 3 & displaymode < 3 % make legend
   leg = cell(length(clusts),1);
   for k = 1:length(clusts),  leg{k} = num2str(clusts(k));  end;
   l = legend(lh,leg,'Location','Best');
   set(l,'FontSize',7);
end
legend hide

%
% LABEL AXES
%
xlabel('Sample')
ystr = { data.title, ['N = ' num2str(size(waveforms,1)) '  (' num2str(data.rpv) ' RPVs)'] };
ylabel(ystr)
