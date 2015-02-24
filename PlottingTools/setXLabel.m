function hXlabel = setXLabel(hAxes,string)
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
    hXlabel(iax) = get(hAxes(iax),'Xlabel');
    
    
    % Set properties
    set(hXlabel(iax),'String',string,...
        'Color',mycolor,'FontName','Calibri')
end

