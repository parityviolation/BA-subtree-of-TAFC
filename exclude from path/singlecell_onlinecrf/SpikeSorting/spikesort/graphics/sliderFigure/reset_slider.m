function reset_slider(h)

if nargin<1, h =gcf; end

xslider = findobj( h,'Tag','xslider');
yslider = findobj( h,'Tag','yslider');

if ~isempty(xslider)

    %
    % get handles and variables
    %
    axes_pos = get( findobj(h,'Type','axes'),'Position' );
    if iscell(axes_pos), axes_pos = cell2mat(axes_pos); end
    panel_pos = get( findobj(h,'Type','uipanel'),'Position');
    if iscell(panel_pos), panel_pos = cell2mat(panel_pos); end
    pos = [axes_pos; panel_pos];
    fig_pos = get(h,'Position');
    xmargin = get(xslider,'UserData');
    ymargin = get(yslider,'UserData');
    
    
    % find extrema
    height = 2*ymargin + max(pos(:,2) + pos(:,4)) + -min(pos(:,2)) + 20;
    width  = 2*xmargin + max(pos(:,1)+pos(:,3)) - min(pos(:,1)) + 20;
 
    % find current position
    curx  = xmargin - min(pos(:,1) );
    cury  = max(pos(:,2)+pos(:,4)) + ymargin - fig_pos(4) ;

    % update slider position
    set(xslider, 'Value',  max(0, curx / ( width - fig_pos(3) ) ) );
    set(yslider, 'Value',  min( max(0, 1-(cury / ( height - fig_pos(4) ) )), 1));

    % update slider width
    a = get(xslider,'SliderStep');
    set(xslider,'SliderStep',[a(1) max( fig_pos(3)/( width - fig_pos(3)), .01 )])
    set(yslider,'SliderStep',[a(1) max( fig_pos(4)/( height - fig_pos(4)),.01 )])
    
        
end

