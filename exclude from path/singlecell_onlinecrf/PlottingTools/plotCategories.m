function varargout = plotCategories(data,xTickLabel,yLabel,hAxes)
% function varargout = plotCategories(data,xTickLabel,yLabel,titlestr,hAxes)
%
% INPUT
%   data: Vector of data points
%   xLabel: A cell array where xLabel{n} is the string label for the nth point.
%   yLabel: Label for y-axis
%   hAxes: Handle to axes
%
% OUTPUT
%   varargout{1} = hLine;
%   varargout{2} = hAxes;
% 

% Created: 5/16/10 - SRO


if nargin < 4
    hAxes = axes;
end

axesGray(hAxes);
defaultAxes(hAxes);

xticks = 1:length(data);

% Plot line
hLine = line('Parent',hAxes,'XData',xticks,'YData',data);

% Set properties
set(hLine,'Marker','.','LineWidth',1.5,'Color',[0.2 0.2 0.2]);

% Set x-axis ticks
maxval = max(data);
if isnan(maxval) || (maxval == 0)
    maxval = 1;
end
set(hAxes,'XTickLabel',xTickLabel,'XTick',xticks,...
    'XLim',[min(xticks)-0.5 max(xticks)+0.5],...
    'YLim',[0 maxval*1.2]);

% Set y-axis label
set(get(hAxes,'YLabel'),'String',yLabel);


% Output
varargout{1} = hLine;
varargout{2} = hAxes;


