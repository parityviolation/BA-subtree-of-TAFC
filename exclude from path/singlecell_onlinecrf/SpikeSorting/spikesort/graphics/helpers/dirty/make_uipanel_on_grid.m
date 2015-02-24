%whenever we add new axes to the plot, we'll assume that the figure has
%been moved back to the top-left corner

function panel = make_uipanel_on_grid( panel_pos, my_title, params, h,visibility)

    if nargin < 4, h = gcf; end
    if nargin < 5, visibility = 'on'; end
    % build as if bottom left is our top corner
    pos = get_pos_on_grid( panel_pos, params, h );

    % make panel
    set(0,'CurrentFigure',h)
    panel = uipanel('Title',my_title,'Units','pixels','Position',pos,'Visible',visibility);
    %uistack(panel, 'bottom');
    reset_slider(h);
    
    % my panels will keep track of their axes
    data.my_axes = [];
    set(panel,'UserData',data)
    
    
    