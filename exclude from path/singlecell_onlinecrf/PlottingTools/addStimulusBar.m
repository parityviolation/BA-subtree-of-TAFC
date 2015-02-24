function varargout = addStimulusBar(hAxes,position,str,color)
% 
% INPUTS
%   hAxes:
%   position: [left right ylevel] in axes coordinates
%   str: String to be displayed above bar
%
% OUTPUTS
%   hLine: Handle to line object.

%   Created: 3/16/10 - SRO

if nargin < 3
    str = '';
    color = [0.3 0.3 0.3];
end

if nargin < 4
    color = [0.3 0.3 0.3];
end

l = position(1);
r = position(2);
y = position(3)-position(3)*0.03;
hLine = line([l r],[y y],'Parent',hAxes,'LineWidth',2,'color',color);
hText = text(mean([l r]),y+0.08*y,str,'FontSize',8,'Color',color,...
    'HorizontalAlignment','center');


% Outputs
varargout{1} = hLine;
varargout{2} = hText;

