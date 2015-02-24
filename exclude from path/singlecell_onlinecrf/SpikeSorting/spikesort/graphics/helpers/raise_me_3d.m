function raise_me_3d (hObject, event, me)
% Pulls the clicked object to the top of the ui stack and increase
% all of its z-values to one more than the highest object in the axes.
% Useful for raising partially masked objects to the front of a plot when
% all objects in the plot are flat in the z-dimension.

zdata = get( get(gca,'Children'), 'ZData');

% handle logic of left-clicking (raise) vs. right-clicking (lower)
mouseclick = get(gcf,'SelectionType');
if isequal( mouseclick, 'normal' )
    raising = 1;
    zval = -Inf;
    zfunc = @max;
    zchange = 1;
    zdir = 'top';
elseif isequal( mousclick,'alt')
    raising = 0;
    zval = Inf;
    zfunc = @min;
    zchange = -1;
    zdir = 'bottom';
else
    raising = -1;
end

if raising ~= -1
    
      % find the extreme z value
      for j = 1:length(zdata)
            if ~isempty( zdata{j} )
                 zval = zfunc( zval, zfunc( zdata{j}(:) ) );
            end
      end
 
      % set the extreme z value
      for j = 1:length(me)
            z = get(me(j), 'ZData');
            z = zval*ones(size(z)) + zchange;
            set( me(j), 'ZData',z)
      end
    
    uistack(me, zdir);
    drawnow;

end
