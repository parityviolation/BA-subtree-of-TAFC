function lh = addAxesCursor(hAxes,bvertical)

% cursor will span current axis

if nargin < 1 || isempty(hAxes)
    hAxes = gca;
end

if nargin<2
    bvertical = 1;
end

y = get(hAxes,'YLIM');
x = get(hAxes,'XLIM');

if bvertical
    lh = line(mean(x).*[1 1],y,'Parent',hAxes);
else
    %     lh = line(x,mean(y).*[1 1],'Parent',hAxes);
    error('not implemented')
end

% find out number of existing cursors
existingCursors = getappdata(hAxes,'Cursors');
if isempty(existingCursors), existingCursors = 1;
else existingCursors(1,end+1) = max(existingCursors(1,:))+1; end
existingCursors(2,end) = lh;
setappdata(hAxes,'Cursors',existingCursors);

% TODO add text label, move it
CursorValue(size(existingCursors,2)) = unique(get(lh,'Xdata')); % vertical specific
setappdata(hAxes,'CursorValue',CursorValue);

setappdata(lh,'bvertical',bvertical);
setappdata(lh,'bTag',['Cursor' num2str(existingCursors(end))]);
set(get(hAxes,'Parent'),'WindowButtonUpFcn',@stopDragFcn);
set(lh,'ButtonDownFcn',@startDragFcn)

    function startDragFcn(varargin)
        set(get(hAxes,'Parent'),'WindowButtonMotionFcn',@draggingFcn)
    end

    function draggingFcn(varargin)
        
        % put
        pt = get(hAxes,'CurrentPoint');
        if bvertical
            set(lh,'Xdata',pt(1)*[1 1]);
        else
            disp('not implemented')
        end
        eC = getappdata(hAxes,'Cursors');
        
        ind = find(eC(2,:) == lh);% lh may need to be pased in part of varargin
        CursorValue = getappdata(hAxes,'CursorValue');
        CursorValue(ind) = pt(1);
        setappdata(hAxes,'CursorValue',CursorValue)
        
        % HOW ARE THRESHIKD VALUES SAVED?
        % DOES THIS WORK ON MULTIPLE AXES?
    end
    function stopDragFcn(varargin)
        set(get(hAxes,'Parent'),'WindowButtonMotionFcn','');
    end

end