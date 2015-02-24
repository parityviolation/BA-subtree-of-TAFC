function raise_band (varargin)
% Pulls the clicked object to the top of the ui stack; useful
% for raising partially masked objects to the front of a plot.
% GUI-shortcut for 'uistack':  Left-clicking brings to the top,
% right-clicking sends to bottom.

hndls = varargin{end};
% get top z position
pos = get( findobj(gcf,'Type','patch'), 'ZData' );

if iscell(pos)
    
  minny = inf;  maxxy = -inf;
  for j = 1:length(pos)
    if ~isempty(pos{j})
        minny = min( minny, min(pos{j}(:)) );
        maxxy = max( maxxy, max(pos{j}(:)) );
    end
  end
  
    switch(get(gcf, 'SelectionType')),
        case ('normal'),
            uistack(hndls, 'top');
            for j = 1:length(hndls)
              set( hndls(j),'Zdata', (maxxy+1)*get_z_ones( hndls(j) )  );
            end

        case ('alt'),            
            uistack(hndls, 'bottom');
            for j = 1:length(hndls)
              set( hndls(j),'Zdata', (minny-1)*get_z_ones( hndls(j) )  );
            end


    end

    drawnow;
end

function b = get_z_ones( hndl )
            b = ones( size( get(hndl,'ZData') ) );
    