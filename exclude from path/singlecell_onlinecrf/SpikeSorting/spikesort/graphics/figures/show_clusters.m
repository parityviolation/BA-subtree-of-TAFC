function showclust(spikes, show, alt_assigns);

if nargin == 3, spikes.assigns = alt_assigns; end
    
if ~isfield(spikes,'assigns'), error('No assignments found in spikes object.'); end
if (nargin < 2),     show = sort( unique(spikes.assigns) );  end
show = sort(show);

% which figure
h = findobj(0,'Name','Show Clusters');
if isempty(h), h = figure('Units','Normalized','Position',spikes.params.display.default_figure_size); end
clf(h)
drawnow
set(h,'Pointer','watch'),pause(.01)

set(h,'defaultaxesfontsize',spikes.params.display.figure_font_size);


for row = 1:length(show)

    clus = show(row);

    pos = get_pos_on_grid( [row 1 1 1], spikes.params.display, h, 1 );
    ax(row,1) = axes('Visible','off','Units','pixel','Position',pos);
    plot_waveforms(spikes,clus);
    
    pos = get_pos_on_grid( [row 2 1 1], spikes.params.display, h, 1 );
    ax(row,2) = axes('Visible','off','Units','pixel','Position',pos);
    plot_residuals(spikes,clus);

    pos = get_pos_on_grid( [row 3 1 1], spikes.params.display, h, 1 );
    ax(row,3) = axes('Visible','off','Units','pixel','Position',pos);
    plot_detection_criterion(spikes,clus);

    pos = get_pos_on_grid( [row 4 1 1], spikes.params.display, h, 1 );
    ax(row,4) = axes('Visible','off','Units','pixel','Position',pos);
    plot_isi(spikes,clus);
    
    pos = get_pos_on_grid( [row 5 1 1], spikes.params.display, h, 1 );
    ax(row,5) = axes('Visible','off','Units','pixel','Position',pos);
    [ax(row,5) ax(row,6)] = plot_stability(spikes,clus);
   
     
end
set(ax,'Visible','on')
sliderFigure(h,spikes.params.display.outer_margin)

set(h,'Name','Show Clusters','NumberTitle','off','Pointer','arrow')
figure(h)

    