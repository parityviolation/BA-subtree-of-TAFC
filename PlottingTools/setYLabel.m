function hYlabel = setYLabel(hAxes,string)
%
% INPUT
%   hAxes:
%   string:
%

% Created: 9.10.13 BA

if ~exist('mycolor','var'),    mycolor = [0 0 0]; end


if nargin < 3 || isempty(fontsize)
    fontsize = 12;
end

if nargin < 4 || isempty(yoffset)
    yoffset = 0;
end

for iax = 1: length(hAxes)
    % Get handles
    hYlabel(iax) = get(hAxes(iax),'Ylabel');
    
    
    % Set properties
    set(hYlabel(iax),'String',string,...
        'Color',mycolor,'FontName','Calibri')
end

