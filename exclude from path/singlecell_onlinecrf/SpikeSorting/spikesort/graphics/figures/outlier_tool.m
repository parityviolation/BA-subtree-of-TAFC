%%
%   initialize figure
%%
function outlier_tool( spikes, show_clusters, h, varname,target_fig)

    if ~isfield(spikes,'assigns'), error('No assignments found in spikes object.'); end
    if nargin < 2 | isequal( show_clusters,'all') 
        figdata.hidden_clusters = []; 
    else
        figdata.hidden_clusters = setdiff( unique(spikes.assigns), show_clusters );
    end
   
    if nargin < 3 | isempty(h), h = figure('Units','Normalized','Position',spikes.params.display.default_figure_size); end
    
    if nargin < 4, varname = 'spikes'; end
    figdata.mode = nargin<5;
    if ~figdata.mode,figdata.target_fig = target_fig; else, figdata.target_fig = []; end
    
    clf(h,'reset');
    set(h,'defaultaxesfontsize',spikes.params.display.figure_font_size);
    set(h,'Interruptible','off','BusyAction','cancel')
    set(h,'Color',spikes.params.display.outlier_fig_color);
    
    % make toolbar buttons
    th = uitoolbar(h);
    data.ims = load('icons_ims');
    if figdata.mode
        tip = 'Save to workspace'; icon = data.ims.im_save;
    else
       tip = 'Save to merge tool and close'; icon = data.ims.im_save_and_close;
    end
    uipushtool(th,'CData',icon,'ClickedCallBack',@saveSpikes,'Tag','saveButton','TooltipString',tip,'Separator','on');
    uipushtool(th,'CData',data.ims.im_savefile,'ClickedCallBack',@saveSpikesToFile,'Tag','saveFileButton','TooltipString','Save to file');
    uipushtool(th,'CData',data.ims.im_loadfile,'ClickedCallBack',@loadSpikesFromFile,'Tag','loadFileButton','TooltipString','Load from file'); 
    uipushtool(th,'CData',data.ims.im_go,'ClickedCallBack',{@execute_change,h},'Tag','executeButton','TooltipString','Remove outliers','Separator','on');
     
    % save spikes data
    figdata.savename = varname;
    figdata.spikes = spikes;
    figdata.selected  = [];
    figdata.clus_list = sort(unique(spikes.assigns));
    figdata.handles.panels = [];
    figdata.method = spikes.params.display.default_outlier_method;
    figdata.cutoff = [];
    figdata.z = [];
    figdata.cutoff_line = [];
  
    % initialize the panels
    figdata.handles.scatter_panel = make_uipanel_on_grid( [2 3 2 2], 'Cluster feature plot', spikes.params.display, h );
    figdata.handles.cutoff_panel = make_uipanel_on_grid( [1 1 2 1], 'Directions:  Select cluster and then click axes to choose cutoff', spikes.params.display, h );
    figdata.handles.waveform_panel = make_uipanel_on_grid( [2 1 2 1], 'Outlier waveforms', spikes.params.display, h );
    
    set(h,'UserData',figdata,'KeyPressFcn',@hot_keys)
    
    init_panels(h);
    figdata =get(h,'UserData');
    if ~figdata.mode
        click_panel( h,figdata.handles.panels )
    end
    
    % set up figure
    set(h,'Name','Outlier Tool','NumberTitle','off')
    sliderFigure( h, spikes.params.display.outer_margin, th, spikes.params.display.aspect_ratio )
    figure(h)
    
end

%%
%  callbacks for toolbar buttons
%
function saveSpikesToFile(varargin)

    [b,h] = gcbo;
    filename_default = get(b,'UserData');
    if isempty(filename_default)
        filename = 'spikes.mat';
    else
        filename = [filename_default.pathname filename_default.filename];
    end
    
    [FileName,PathName,FilterIndex] = uiputfile('*.mat','Save Spikes object',filename);
    if ~isequal(FileName,0)
        
        figdata =get(h,'UserData');
        spikes = figdata.spikes;
        save([PathName FileName],'spikes');

        a.pathname = PathName;
        a.filename = FileName;
        set(b,'UserData',a);
    end
end
     
function loadSpikesFromFile(varargin)
    [b,h] = gcbo;
    
    filename_default = get(findobj(h,'Tag','saveFileButton'),'UserData');
    
    if isempty(filename_default)
        filename = [pwd '\spikes.mat'];
    else
        filename = [filename_default.pathname filename_default.filename];
    end
    [filename,pathname] = uigetfile('*.mat','Load spikes object from file.',filename);
    
    if ~isequal(filename,0)
      
      
      a = load([pathname filename]);  
      names = fieldnames(a);
      figdata = get(h,'UserData');
      figdata.spikes = getfield(a,names{1});
      set(h,'UserData',figdata)
      
      d.pathname = pathname;  d.filename = filename;  set(findobj(h,'Tag','saveFileButton'),'UserData',d);
      
      draw_clusters_column(figdata.spikes,h);
      init_merge(h);
      selection_logic(varargin);
    
    end
end
     
function saveSpikes(varargin)
    
    [ax, h] = gcbo;
    figdata = get(h,'UserData');
    if figdata.mode
        varname = inputdlg('Save spike data in what variable?', 'Save to workspace', 1,{figdata.savename});
        if ~isempty(varname)
            assignin('base',varname{1},figdata.spikes)
            figdata.savename = varname;
            set(h,'UserData',figdata);
        end
    else
        clus = [];
        if ~isempty(figdata.handles.id), clus = figdata.handles.id; end
        figdata.savename( figdata.target_fig , figdata.spikes, clus );
        close( h ); 
    end
end

function hot_keys(varargin)

    h =varargin{end-1};
    event = varargin{end};
    switch(event.Key)
        case {'s'}, saveSpikes(h);
        case {'x'}, execute_change(h);
    end
end
   

%% 
%   tree functions
%

function init_panels( h )

    figdata = get(h,'UserData');
     set(h,'Pointer','watch')
     pause(.01)
    figdata.clus_list = setdiff( sort(unique(figdata.spikes.assigns)), figdata.hidden_clusters );
     
    for k = 1:length(figdata.clus_list)
        
        % create waveform panel
        p = uipanel('Title',num2str(figdata.clus_list(k)),'Units','pixels','Visible','off');
        set(p,'Title',num2str(figdata.clus_list(k)) );
        set(p,'ButtonDownFcn',{@click_panel,h, p} );
        idx = figdata.spikes.labels( figdata.spikes.labels(:,1) == figdata.clus_list(k), 2 );
        color = figdata.spikes.params.display.label_colors(idx,:);
        if ismember( figdata.clus_list(k), figdata.selected), color = [1 1 1]; end
        set(p,'BackgroundColor',color);
        set(p,'UIContextMenu',get_panel_menu( figdata.spikes.params.display.label_categories, idx, p ) );  
        
        % create waveform axes
        a = axes('Parent',p);   
        plot_waveforms( figdata.spikes, figdata.clus_list(k) );
        
        % save info
        figdata.handles.panels(k) = p;
        figdata.handles.axes(k) = a;
        figdata.handles.id(k) = figdata.clus_list(k);
      
    end
    
    set( h, 'UserData',figdata);
    rearrange_panels(h);
    set(h,'Pointer','arrow')
   
end


function rearrange_panels( h )

    % make all panels and axes invisible
    figdata = get(h,'UserData');
    set( figdata.handles.panels, 'Visible','off')
    
    % get list of clusters we are supposed to show
    show_list = sort( setdiff( unique(figdata.spikes.assigns), figdata.hidden_clusters ) );
    
    % move them to correct location
    num_cols = figdata.spikes.params.display.max_cols;
    for j = 1:length(show_list)
        % where would this one go?
        row = ceil(j/num_cols);
        col = rem(j,num_cols);  if col==0,col=num_cols;end
    
       % find which one
       a = find( figdata.handles.id == show_list(j) ); 
       
       % set new position
       set(figdata.handles.panels(a), 'Position', get_pos_on_grid([2+row col 1 1], figdata.spikes.params.display, h ) );
       
    end
    % make them visible
    indices = find( ismember( figdata.handles.id, show_list ) );
    set( figdata.handles.panels(indices),'Visible','on')
    
end


function click_panel( varargin )
    h = varargin{end-1};
        if ~isequal( get(h,'SelectionType'), 'alt' )

    
       set(h,'Pointer','watch'),pause(.01)
 
    p  = varargin{end};
    
    figdata = get(h,'UserData');
    clus = str2num(get(p,'Title'));
    if sum( figdata.spikes.assigns == clus ) == 0
          warndlg( 'Cannot select cluster.  All spikes were previously labeled outliers.','Empty cluster.');
    else
        delete( get( figdata.handles.scatter_panel,'Children') );
        delete( get( figdata.handles.cutoff_panel,'Children') );
        delete( get( figdata.handles.waveform_panel,'Children') );

        if figdata.selected == clus
            figdata.selected = [];
            which = find( figdata.spikes.labels(:,1) == clus );
            cat   = figdata.spikes.labels(which,2);
            set(p,'BackgroundColor', figdata.spikes.params.display.label_colors( cat, : ) );
            set(h,'UserData',figdata)
           

        else
            
                if ~isempty( figdata.selected )             
                    which = find( figdata.spikes.labels(:,1) == figdata.selected );
                     cat   = figdata.spikes.labels(which,2);
                    set(figdata.selectedp,'BackgroundColor',figdata.spikes.params.display.label_colors( cat, : ) ); 
                end
                figdata.selected = clus;
                figdata.selectedp = p;
                set(p,'BackgroundColor', [1 1 1] );

                figdata.show_axes(1) =   axes('Parent',figdata.handles.cutoff_panel );
                figdata.show_axes(2) =   axes('Parent',figdata.handles.waveform_panel);
                figdata.show_axes(3) =   axes('Parent',figdata.handles.scatter_panel);


                set(h,'UserData',figdata);
                make_zvalue_histogram( h )
                update_waveforms( h)
                update_scatter( h )
        end
     end
       set(h,'Pointer','arrow')
        end
end

function delete_panels( ps )
    for j = 1:length(ps)
       d = get(ps(j),'UserData');
       delete( d.my_axes );
       delete(ps(j));
    end
end

function word = bool2word( b )
    if b, word = 'on'; else, word = 'off'; end
end

function change_mode( varargin )

    h = varargin{ end - 1};
    figdata = get(h,'UserData');
    figdata.method =  varargin{ end };
    set(h,'UserData',figdata);
    make_zvalue_histogram( h )
   
end

%%
%   execution function
%
function execute_change(varargin)

    h = varargin{end};
    figdata = get(h,'UserData');
    set(h,'Pointer','watch'),pause(.01)
 
    if isempty(figdata.selected)
        warndlg( 'Select a cluster to remove outliers from.', 'No cluster selected');
    else
    
        indices = find( figdata.spikes.assigns == figdata.selected );
        baddies = find( figdata.z > figdata.cutoff );
        my_list = zeros( [1 length( figdata.spikes.assigns ) ] );
        my_list(indices(baddies) ) = 1;
        my_subclusters = unique( figdata.spikes.info.kmeans.assigns( indices ) );
        figdata.spikes = remove_outliers(figdata.spikes, my_list  );
        
        % was i destroyed?
        a = find( ismember( figdata.spikes.assigns, my_subclusters ), 1);
        old_selected = figdata.selected;
        figdata.selected = figdata.spikes.assigns(a);
        if isempty(figdata.selected), figdata.selected = NaN; end
        
       set(h,'UserData',figdata)
       if sum( figdata.spikes.assigns == figdata.selected ) == 0
            
            % clear everything
            which = find(figdata.selected == figdata.handles.id);
            figdata.selected = [];
            delete(figdata.handles.panels(which));
            figdata.handles.id(which) = [];
            figdata.handles.panels(which) = [];
            figdata.handles.axes(which) = [];
            
            % delete the other panels
            delete( get( figdata.handles.scatter_panel,'Children') );
            delete( get( figdata.handles.cutoff_panel,'Children') );
            delete( get( figdata.handles.waveform_panel,'Children') );

            rearrange_panels(h)
            set(h,'UserData',figdata)
        else
            
            % find axes to update
            which = figdata.handles.id == old_selected;
            ax = figdata.handles.axes(which);
            figdata.handles.id = figdata.selected;
            set(h,'UserData',figdata);
      
             set(figdata.handles.panels(which),'Title',num2str(figdata.selected) );
       
            
            % grab mode
            ud = get(ax,'UserData');
            
            colormode = ud.colormode;
            set(h,'CurrentAxes',ax)
            plot_waveforms( figdata.spikes, figdata.selected, colormode,0);
            
            make_zvalue_histogram(h)
            update_waveforms( h)
            update_scatter( h )
        end
        
    end
    set(h,'Pointer','arrow')
    
end      
            
function make_zvalue_histogram( h )

    figdata = get(h,'UserData');
    ax = figdata.show_axes(1);
    
     set(h,'CurrentAxes',ax)
     cla;
   
    [figdata.z,dof] = plot_distances( figdata.spikes, figdata.selected, figdata.method );
    cmenu = uicontextmenu;
    uimenu(cmenu, 'Label', 'Use cluster stats', 'Callback', {@change_mode, h, 1},'Checked',bool2word(figdata.method ==1) );
    uimenu(cmenu, 'Label', 'Use noise stats', 'Callback', {@change_mode, h, 2},'Checked',bool2word(figdata.method ==2) );
    set(figdata.show_axes,'UIContextMenu', cmenu )
 
    % place the vertical line
    temp = .5/length(figdata.z);
    figdata.cutoff =  min( chi2inv(1-temp, dof ), max( figdata.z) );
   
    % cutoff line
    l = line(figdata.cutoff*[1 1],get(ax,'YLim'));
    set(l,'Color',[1 0 0],'LineWidth',2,'LineStyle','--','Tag','cutoff')
    figdata.cutoff_line = l;
    set(ax,'ButtonDownFcn', {@update_cutoff, h} );
    set(h,'UserData',figdata);
 
    % get indices of RPVs
    select = get_spike_indices(figdata.spikes, figdata.selected );
    spiketimes =  sort( figdata.spikes.unwrapped_times(select) );

    which = find( diff(spiketimes) < figdata.spikes.params.refractory_period/1000 );
    which = unique( [which which+1 ] );
    hold on
    
    s = scatter( figdata.z(which), mean(get(gca,'YLim'))*ones(size(figdata.z(which))),'k' );
    set(s,'Marker','x')
end

function update_cutoff( varargin )

    h = varargin{end};
    set(h,'Pointer','watch')
     pause(.01)
   
    figdata = get(h,'UserData');
    ax = figdata.show_axes(1);
    cp = get(ax,'CurrentPoint');
    figdata.cutoff = cp(1);
    set(figdata.cutoff_line,'XData',figdata.cutoff*[1 1]);
    set(h,'UserData',figdata);
    update_waveforms( h)
    update_scatter(h)
    set(h,'Pointer','arrow')
    
end

function update_waveforms( h)

    figdata = get(h,'UserData');
    ax = figdata.show_axes(2);
    set(h,'CurrentAxes',ax);
    cla;
    indices = find( figdata.spikes.assigns == figdata.selected );
    baddies = find( figdata.z > figdata.cutoff );
    
    xlabel( 'Sample');
    ylabel('Value');
       
    % get the waveforms
    w = figdata.spikes.waveforms( indices(baddies), : );
    figdata.spikes.params.display.default_waveformmode = 1;
    which = ismember( 1:length(figdata.spikes.assigns), indices(baddies));
    if length(baddies) > 0
     plot_waveforms(figdata.spikes,which,1); 
     delete( get(ax,'UIContextMenu'))
    end
    
    % plot mean waveform
    which = find( figdata.spikes.assigns == figdata.selected );
    num_samples = size( figdata.spikes.waveforms(:,:),2);
    l = line( 1:num_samples, mean( figdata.spikes.waveforms( which ,:)));
    set(l,'Color',[ 0 0 0],'LineWidth',2.5)
    set(ax,'XLim',[1 num_samples])  
    title(['Outliers for cluster #' num2str(figdata.selected) ' (' num2str(length(baddies)) ' out of ' num2str( length(figdata.z) ) ')'])

end

function update_scatter( h )

    figdata = get(h,'UserData');
    ax = figdata.show_axes(3);
    set(h,'CurrentAxes',ax);
    
    axdata = get(ax,'UserData');
    if ~isempty(axdata)
   
    end
    cla;
    
    indices = find( figdata.spikes.assigns == figdata.selected );
    baddies = find( figdata.z > figdata.cutoff );
    s = figdata.spikes;
    c = max(s.info.kmeans.assigns) + 1;
    s.assigns( s.assigns ~= figdata.selected ) = 0;   
    s.assigns( indices(baddies) ) = c;
    s.info.kmeans.assigns( indices(baddies) ) = c;
    
    s.info.kmeans.colors(c,:) = 0;
   
    % update defaults if present already
     if ~isempty(axdata)
          s.params.display.xchoice = axdata.xchoice;
          s.params.display.xparam = axdata.xparam;
          s.params.display.ychoice = axdata.ychoice;
          s.params.display.yparam = axdata.yparam; 
    end
   
    
    plot_features(s, [c figdata.selected], 3, 0 );
    cmenu = get(ax,'UIContextMenu');
    kids  = get( cmenu, 'Children');
    delete( setdiff( kids, findobj(cmenu,'Tag','showdensityoption')))
       
end

function cmenu = get_panel_menu( categories, me,p)
        cmenu = uicontextmenu;
        clus = str2num( get(p,'Title' ) );
        
        for j = 1:length(categories)
            d(j) = uimenu(cmenu, 'Label', categories{j}, 'Callback', {@change_label, p, j});
            if j == me, set( d(j), 'Checked','on','Enable','off'); end
        end
end

function change_label(varargin)
    [p, h] = gcbo;
    p = varargin{end-1};
    which = varargin{end};  
    clus = str2num(get(p,'Title'));
    figdata = get(h,'UserData');
    
    % change labels in spikes object
    idx = find( figdata.spikes.labels(:,1) == clus );
 
    figdata.spikes.labels(idx,2) = which;
    set(h,'Userdata',figdata);
    
    % change color of current cluster if not selected
    if ~ismember( clus, figdata.selected )
     set(p,'BackgroundColor', figdata.spikes.params.display.label_colors(which,:) );
    end   
    % update context menu
    set(p,'UIContextMenu',get_panel_menu(figdata.spikes.params.display.label_categories,which,p) );
    
end
