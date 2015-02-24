function removeAxesLabels(hAxes,indRmX,indRmY)
% function removeAxesLabels(hAxes,indRmX,indRmY)
% INPUT: hAxes - axes handles
%        indRmX - (optional) if not specified or isempty all X axis will be removed
%                 otherwise, only hAxes(indRmX) will be removed.
%                 set to NaN to remove none;
%        indRmY - (optional) if not specified or isempty all Y axis will be removed
%                 otherwise, only hAxes(indRmY) will be removed.
%                 set to NaN to remove none;
%   Created: SRO 5/3/10
%   Modified: BA 6/05/10


if nargin<2 || isempty(indRmX), indRmX = [1:length(hAxes)]; end
if nargin<3 || isempty(indRmY), indRmY = [1:length(hAxes)]; end

% xaxis
if ~isnan(indRmX)
for i = indRmX
    xlabel(hAxes(i),'');                % No axis labels
    set(hAxes(i),'XTickLabel',{});      % No tick labels
end
end
% yaxis
if ~isnan(indRmY)

for i = indRmY
    ylabel(hAxes(i),'')               % No axis labels
    set(hAxes(i),'YTickLabel',{});      % No tick labels
end
end