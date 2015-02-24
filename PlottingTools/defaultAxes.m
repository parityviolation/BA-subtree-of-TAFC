function defaultAxes(hAxes,xdta,ydta,fontsize)
%
%
% INPUTS
%   hAxes:
%   xdta:
%   ydata:
%   fontsize:

% Created: 3/15/10 - SRO
% Modified: 5/16/14- BA

if nargin < 1
    hAxes = gca;
end

if nargin < 2 | isempty(xdta) |isempty(ydta)
    xdta = 0.15;    % Distance to axis
    ydta = 0.13;
%     xdta = 0.07;    % Distance to axis
%     ydta = 0.09;
end

if nargin < 4
    fontsize = 8;
end

% Set color of axes
% axesGray(hAxes)

% Set tick out
set(hAxes,'TickDir','out');
set(hAxes,'box','off');
% Set font size
set(hAxes,'FontSize',fontsize);
%set(hAxes,'Color','none');
% Remove box
% box off

% Set position of tick label

% Set position and font size of axis label
pta = 0.5;      % Parallel to axis
if length(hAxes) > 1
    set(cell2mat(get(hAxes,'XLabel')),'Units','normalized','Position',[pta -xdta 1],'FontSize',fontsize);
    set(cell2mat(get(hAxes,'YLabel')),'Units','normalized','Position',[-ydta pta 1],'FontSize',fontsize);
    set(cell2mat(get(hAxes,'title')),'FontSize',fontsize);
else
    set(get(hAxes,'XLabel'),'Units','normalized','Position',[pta -xdta 1],'FontSize',fontsize);
    set(get(hAxes,'YLabel'),'Units','normalized','Position',[-ydta pta 1],'FontSize',fontsize);
    set(get(hAxes,'Title'),'FontSize',fontsize);
end

