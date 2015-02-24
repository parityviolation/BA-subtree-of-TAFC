function ymax = setSameYmax(hAxes,percent,setmin)
% function setSameYmax(hAxes)
% Finds max y-value of lines across a group of axes, and sets all axes to
% the same max.
%
% INPUT
%   hAxes: Vector of axes handles
%   percent: Percent of axis above max point

% Created: 5/13/10 - SRO

if nargin < 2
    percent = 0;
    setmin = 0;
end

if nargin < 3
    setmin = 0;
end

h = findobj(hAxes,'Type','line');


for i = 1:length(h)
    temp = get(h(i),'YData');
    if ~isempty(temp)
        ymax(i) = max(temp);
        ymin(i) = min(temp);
    end
end

if exist('ymax','var')
    ymax = max(ymax) + max(ymax)*percent/100;
    ymin = min(ymin) + min(ymin)*percent/100;
    if ~setmin
        ymin = 0;
    end
    if ~isnan(ymax) && ~(ymax == 0)
        set(hAxes,'YLim',[ymin ymax]);
    else
        set(hAxes,'YLim',[0 1]);
    end
    
else % if there is not ydata in plot
    try y = get(hAxes{1},'YLim');
    catch y = get(hAxes(1),'YLim'); end
    ymin = y(1); ymax = y(2);
end