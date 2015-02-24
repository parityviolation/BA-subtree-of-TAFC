function h = STABrowser(STAresult)
% function h = STABrowser(STAresult)

% BA 110710
% to DO
% MAKE VERTICLA LINE DASKED AND BLACK
% MAKE HORIZONTAL LINES THICKER
% REMOVE TICKS FROM COLORBARS
% REMOTE AXES FROM IMAGES
% PUT XLABEL ON TOP

% movie browser
r = RigDefs;
h.fig = figure;
sFigName = sprintf('%s STA Browser',STAresult.unitTag);

set(h.fig,'Name',sFigName,'Position',r.Analysis.STABrowser.Position);
orient(h.fig,'tall');

h.STAmovie = STAresult.movie;
h.tbin = STAresult.STAparams.tbin;
h.WOI = STAresult.STAparams.WOI;
h.totalspikes = STAresult.nspikes;
[h.dx h.dy h.dWOI] =size(STAresult.movie{1});


% create axes for max and min intensity plot
positionhax(1,:) = [ 0.12    0.75 0.8    0.2];
h.hax(1) = axes('Parent',h.fig,'Visible','off','Position',positionhax(1,:));
h.mycolors = [0 0 1; 1 0 0; 1 1 1];

h.dl_x = [1:h.dWOI]*h.tbin*1e3-h.WOI(1)*1e3;
for imov = 1: length(h.STAmovie)
    m = h.STAmovie{imov}/std(h.STAmovie{imov}(:)); %zscore STA
    m = reshape(m,[h.dx*h.dy h.dWOI]); 
    h.hl_max(imov) = line(h.dl_x, max(m),'color',h.mycolors(imov,:)*0.8);
    h.hl_min(imov) = line(h.dl_x, min(m),'color',h.mycolors(imov,:)*0.4);
end
axis on; set(h.hax(1),'xlim',[min(h.dl_x),max(h.dl_x)]);
DefaultAxes(h.hax(1));
setTitle(h.hax(1),['nspks: ' num2str(STAresult.nspikes)]) ;   xlabel(h.hax(1),'msec before spike');ylabel(h.hax(1),'zscore');
% ADD draggable vertical bar
h.hcursor = addAxesCursor(h.hax(1) ,1);
set(h.hcursor,'ButtonDownFcn',@localstartDragFcn)  % over ride the WindowsButtonUpFunction

% get the current frame of the vertical cursor
h = helper_getcurrentFrame(h);

% create and plot STAs image axes
movie_axPOS(1,:) = [0.1    0.39   0.8 0.8*0.4];
movie_axPOS(2,:) = [0.1    0.02   0.8 0.8*0.4];
init_threshold   = [3 -3];
for imov = 1: length(h.STAmovie)
    % create axes
    h.hmovie_ax(imov) = axes('Parent',h.fig,'Visible','off','Position', movie_axPOS(imov,:));
    % calculate clims
    temp = double(h.STAmovie{imov}/std(h.STAmovie{imov}(:)));
    cmin = min(temp(:));    cmax = max(temp(:));
    h.clims(imov,:) = [cmin cmax];
    
    % plot initial STA frame
    frm = h.STAmovie{imov}(:,:,h.currentFrame);
    [hax_temp h.him(imov)]= plotSTA(frm, h.hmovie_ax(imov),h.clims(imov,:));
    h.hcb(imov) = colorbar;
    % fix colorbar position
    p = get(h.hcb(imov),'position');
    set(h.hcb(imov),'position',p.*[1.13 1 .6 1])
    

    % add draggable threshold
    h.thresCursor(imov)  = addAxesCursor(h.hcb(imov) ,0,init_threshold(imov));
    set(h.thresCursor(imov),'color',h.mycolors(imov,:));
    % over ride the WindowsButtonUpFunction
    set(h.thresCursor(imov),'ButtonDownFcn',@localstartDragFcn)
    
end


helper_updateSTAframe(h)
guidata(h.fig,h);


% find cursor location in frames
function h = helper_getcurrentFrame(h)
cursor_x = unique(get(h.hcursor,'Xdata'));
x = abs(h.dl_x-cursor_x);
h.currentFrame = find(x == min(x),1);

guidata(h.fig,h);


function h = helper_updateSTAframe(h)
h = helper_getcurrentFrame(h);
for imov = 1: length(h.STAmovie)
    frm = h.STAmovie{imov}(:,:,h.currentFrame);
    
    % apply threshold (gray everything below threshold)
    thres = abs(unique(get(h.thresCursor(imov),'Ydata')));
    frm(abs(frm(:)) < thres) = 0;
    set(h.him(imov),'CData',rot90(frm));
end
guidata(h.fig,h);


function localstartDragFcn(varargin)
hObject = varargin{1};
h = guidata(hObject);
set(h.fig,'WindowButtonMotionFcn',{@localdraggingFcn,hObject})



function localdraggingFcn(varargin)
lh = varargin{3};
h = guidata(lh);
hAxes = get(lh,'Parent');

bvertical = getappdata(hAxes,'bvertical');

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
CursorValue(ind) =curVal;
setappdata(hAxes,'CursorValue',CursorValue)


% update STA movie;
helper_updateSTAframe(h);




