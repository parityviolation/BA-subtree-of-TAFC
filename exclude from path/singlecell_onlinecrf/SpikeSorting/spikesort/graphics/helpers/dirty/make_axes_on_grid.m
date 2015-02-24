%whenever we add new axes to the plot, we'll assume that the figure has
%been moved back to the top-left corner

function ax = make_axes_on_grid( axes_pos, params, h,visibility)


    if nargin < 3, h = gcf; end
    if nargin < 4, visibility = 'on'; end
    % get grid position
    pos = get_pos_on_grid( axes_pos, params, h,1 );
        
    % build axes
    set(0,'CurrentFigure',h);
    ax = axes('Units','pixels','Position',pos,'Visible',visibility);
    uistack(ax, 'top');
    set(gcf,'CurrentAxes',ax)
    reset_slider(h);