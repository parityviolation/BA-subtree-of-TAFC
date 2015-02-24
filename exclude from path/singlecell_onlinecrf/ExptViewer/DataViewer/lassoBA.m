function [las_xy hl selx,sely,indexnr]=lassoBA(x,y)
% function [las_xy selx,sely,indexnr]=lassoBA(x,y)

% lasso -  enables the selection/encircling of (clusters of) events in a scatter plot by hand 
%          using the mouse
% 
% Input:    x,y                 - a set of points in 2 column vectors.
%           or x = handle of axis
% Output:   las_x las_y selx,sely,indexnr   - lasso polygon, and a set of selected points in 3 column vectors 
% 
% Note:   After the scatter plot is given, selection by mouse is started after any key press. 
%         This is done to be able to ZOOM or CHANGE AXES etc. in the representation before selection 
%         by mouse.
%         Encircling is done by pressing subsequently the LEFT button mouse at the requested positions 
%         in a scatter plot.
%         Closing the loop is done by a RIGHT button press.
%         
% T.Rutten V2.0/9/2003
% modified by BA 06102010

if nargin >1
    plot(x,y,'.')
elseif nargin ==1
    if isscalar(x) && ishandle(x) && strcmp('line', get(x,'type'));
        hln = x;
    else error ('if One input it must be a Line handle')
    end
else
    hln = gca;
end

if hln
    x = get(hln,'Xdata');
    y = get(hln,'Ydata');
end

las_x=[];
las_y=[];

c=1;

key=0;

disp('press a KEY to start selection by mouse, LEFT mouse button for selection, RIGHT button closes loop')
while key==0
key=waitforbuttonpress;
pause(0.2)
end

iter = 1;
while c==1 
[a,b,c]=ginput(1);
las_x=[las_x;a];las_y=[las_y;b];
htemp(iter) =line(las_x,las_y);
iter = iter+1;

end;

las_x(length(las_x)+1)=las_x(1);
las_y(length(las_y)+1)=las_y(1);

hl = line(las_x,las_y,'Color','k');
delete(htemp);

pause(.2)

in=inpolygon(x,y,las_x,las_y);

ev_in=find(in>0);

selx=x(ev_in);
sely=y(ev_in);

if nargout> 2 % shortcut to not getting plot if you just want the lasso
figure,plot(x,y,'b.',selx,sely,'g.');
legend(num2str([length(x)-length(selx);length(selx)]));
end
indexnr=ev_in;

las_xy = [las_x las_y];