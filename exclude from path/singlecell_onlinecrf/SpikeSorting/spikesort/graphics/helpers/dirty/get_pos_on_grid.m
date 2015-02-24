function pos = get_pos_on_grid( grid_pos, params, h, impose_margins )

    if nargin < 3, h = gcf; end
    if nargin < 4, impose_margins = 0; end

    
    % build as if bottom left is our top corner
    set(h,'Units','pixels')
    
    pos(1) = (grid_pos(2)-1)*(params.width+params.margin);
    pos(2) =  -grid_pos(1)* params.aspect_ratio*(params.width+params.margin);
    pos(3) =   grid_pos(3) * (params.width+params.margin) ;
    pos(4) =   grid_pos(4) * (params.width+params.margin) *params.aspect_ratio;

    % zoom it and add offsets
    z = get_zoom(h);
     pos = pos * z;

    % impose offsets
    [xoffset yoffset ] = get_offsets( params,h,z );
    pos(1:2) = pos(1:2) + [xoffset yoffset];
 
    
    % impose margins
    if impose_margins  
      pos = pos + get_zoom(h) * params.margin * .5 * [ 1 params.aspect_ratio -2 -2*params.aspect_ratio ];
    end
    
end
    
function z = get_zoom(h)
   reset   = findobj(h,'Tag','reset');
   if ~isempty(reset)
       z = 1 / get( reset, 'UserData');
   else
       z = 1;
   end
end
     
 function [x, y] = get_offsets(params, h, z)

     fig_pos = get(h,'Position');
     my_axes = findobj(h,'-depth',1,'Type','Axes');
     my_panels = findobj(h,'-depth',1,'Type','uipanel');
     xmargin = params.outer_margin;
     ymargin = params.outer_margin*params.aspect_ratio;
     
     if isempty( findobj(h,'Tag','xslider') ) | (isempty(my_axes) & isempty(my_panels) )
         x = xmargin;
         y = fig_pos(4)-ymargin;
              
     else
            % get top left position based on axes
            [axes_left,axes_top] = get_top_left( my_axes, params );
            axes_left = axes_left - .5*params.margin*z;
            axes_top  = axes_top + .5*params.margin*params.aspect_ratio*z;              
           
             % get top left position based on panels
             [panel_left,panel_top] = get_top_left( my_panels, params );
            % get overall top left
            x = min(axes_left, panel_left);
            y = max(axes_top, panel_top);
           
     end
 end 
 
function [l,t] = get_top_left( handles, params )
      
        if ~isempty(handles )
          pos = get(handles,'Position');
          if iscell(pos), pos = cell2mat(pos); end
          l = min(pos(:,1));
          t  = max( pos(:,2) + pos(:,4 ) );              
        else
           l = inf;  t = -inf;
        end       
end