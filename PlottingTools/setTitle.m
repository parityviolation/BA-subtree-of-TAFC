function hTitle = setTitle(hAxes,string,fontsize,yoffset,mycolor)
%
% INPUT
%   hAxes:
%   string:
%   fontsize:
%   position:
%

% Created: 5/17/10 - SRO
% Modified 9.10.10 BA

if ~exist('mycolor','var'),    mycolor = [0 0 0]; end


if nargin < 3 || isempty(fontsize)
    fontsize = 7;
end

if nargin < 4 || isempty(yoffset)
    yoffset = 0;
end

for iax = 1: length(hAxes)
    % Get handles
    hTitle(iax) = get(hAxes(iax),'Title');
    
    % Get current position
    pos = get(hTitle(iax),'Position');
    xpos = get(hAxes(iax),'XLim');
    pos(1) = mean(xpos,2);
    ymax = max(get(hAxes(iax),'YLim'));
    pos(2) = ymax*(1 + yoffset);
    
    % Set properties
    set(hTitle(iax),'String',string,'Fontsize',fontsize,'Position',pos,...
        'Color',mycolor)
end

