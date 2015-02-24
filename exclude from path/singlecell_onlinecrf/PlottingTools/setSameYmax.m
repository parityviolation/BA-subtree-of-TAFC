function ymax = setSameYmax(hAxes,percent)
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
end


h = findobj(hAxes,'Type','line');

for i = 1:length(h)
    temp = get(h(i),'YData');
    ymax(i) = max(temp);
end

ymax = max(ymax) + max(ymax)*percent/100;
if ~isnan(ymax) && ~(ymax == 0)
    set(hAxes,'YLim',[0 ymax]);
else
    set(hAxes,'YLim',[0 1]);
end