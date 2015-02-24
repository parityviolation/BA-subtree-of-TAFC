function compare_clusters( spikes, show, alt_assigns )

if nargin == 3, spikes.assigns = alt_assigns; end

if ~isfield(spikes,'assigns'), error('No assignments found in spikes object.'); end


if (nargin < 2),     show = sort( unique(spikes.assigns) );  show = setdiff(show,0); end
show = sort(show);

% which figure
h = findobj(0,'Name','Separation Analysis');

if isempty(h), h = figure('Units','Normalized','Position',spikes.params.display.default_figure_size); end
clf(h)
drawnow
set(h,'Pointer','watch'),pause(.01)

set(h,'defaultaxesfontsize',spikes.params.display.figure_font_size);

sliderFigure(h,spikes.params.display.outer_margin)

for row = 1:length(show)
    for col = 1:length(show)

       pos = get_pos_on_grid( [row col 1 1], spikes.params.display, h, 1 );
       ax(row,col) = axes('Visible','off','Units','pixel','Position',pos);

%       make_axes_on_grid([row col 1 1], spikes.params.display, h);

       if row < col
        plot_fld( spikes, show(row), show(col) );
        legend off;
           set(gca,'Color', [1 .9 .9] )
       elseif row > col
        plot_xcorr( spikes, show(row), show(col) );          
           set(gca,'Color', [.9 .9 1] )
       elseif row == col
           plot_isi( spikes, show(row) )
           
       end


       if row == 1, 
           current_title = get(get(gca,'Title'),'String');
           title( {clust_string( spikes, show(col) ), current_title} ); 
       end

       if col == 1 
           ystr = get(  get(ax(row,col),'YLabel'), 'String');
           if ~iscell(ystr), ystr = {ystr}; end
           ystr = [ clust_string( spikes, show(row) );  ystr];
           set( get(ax(row,col),'YLabel'), 'String', ystr )
       end
       

    end
end
set(ax,'Visible','on')
set(gcf,'Name','Separation Analysis','NumberTitle','off')
set(h,'Pointer','arrow'),pause(.01)

figure(gcf)


function str = clust_string( spikes, clus )

num_spikes = sum( spikes.assigns == clus );
if clus == 0
    str = 'Outliers';
else
    str = ['Cluster #' num2str(clus )];
end

str = [str '  (N = ' num2str(num_spikes) ')'];


