function raise_me (hObject, event, me)
% Pulls the clicked object to the top of the ui stack; useful
% for raising partially masked objects to the front of a plot.
% GUI-shortcut for 'uistack':  Left-clicking brings to the top,
% right-clicking sends to bottom.

switch(get(gcf, 'SelectionType')),
    case ('normal'),
        uistack(me, 'top');
    case ('alt'),
        uistack(me, 'bottom');
end

drawnow;
