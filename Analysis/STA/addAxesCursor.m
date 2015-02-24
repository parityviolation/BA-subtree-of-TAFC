function lh = addAxesCursor(hAxes,bvertical,initialvalue)

% cursor will span current axis

if nargin < 1 || isempty(hAxes)
    hAxes = gca;
end

if nargin<2
    bvertical = 1;
end
setappdata(hAxes,'bvertical',bvertical);

y = get(hAxes,'YLIM');
x = get(hAxes,'XLIM');

if nargin<3 % set initial value of the cursor to the mean if it isn't specified
    if bvertical,    initialvalue = mean(x);
    else  initialvalue = mean(y); end
end


if bvertical
    lh = line(initialvalue.*[1 1],y,'Parent',hAxes);
    sdata = 'Xdata';
else
    lh = line(x,initialvalue.*[1 1],'Parent',hAxes);
    sdata = 'Ydata';
end

% find out number of existing cursors
existingCursors = getappdata(hAxes,'Cursors');
if isempty(existingCursors), existingCursors = 1;
else existingCursors(1,end+1) = max(existingCursors(1,:))+1; end
existingCursors(2,end) = lh;
setappdata(hAxes,'Cursors',existingCursors);

% TODO add text label, move it
CursorValue(size(existingCursors,2)) = unique(get(lh,sdata)); % vertical specific
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
            curVal = pt(1);
            set(lh,'Xdata',curVal*[1 1]);
        else
            curVal = pt(3);
            set(lh,'Ydata',curVal*[1 1]);
        end
        eC = getappdata(hAxes,'Cursors');
        
        ind = find(eC(2,:) == lh);% lh may need to be pased in part of varargin
        CursorValue = getappdata(hAxes,'CursorValue');
        CursorValue(ind) = curVal;
        setappdata(hAxes,'CursorValue',CursorValue)
        
        % HOW ARE THRESHIKD VALUES SAVED?
        % DOES THIS WORK ON MULTIPLE AXES?
    end
    function stopDragFcn(varargin)
        set(get(hAxes,'Parent'),'WindowButtonMotionFcn','');
    end

end