function varargout = addStimulusBox(hAxes, XW,str,color)
% 
% INPUTS
%   hAxes:
%   XW: [xpos width] in axes coordinates
%   str: String to be displayed above bar
%
% OUTPUTS
%   hRect: Handle to line object.


if nargin < 3
    str = '';
    color = [0.7 0.7 0.7];
end

if nargin < 4
    color = [0.7 0.7 0.7];
end


for iax = 1:length(hAxes)
    YH(1) = min(get(hAxes(iax),'ylim'));
    YH(2) = max(get(hAxes(iax),'ylim'));
    hRect(iax) = rectangle('Position',[XW(1),YH(1), XW(2),YH(2)],'parent',hAxes(iax),...
        'FaceColor',color,'LineStyle','none');
    
%     hText(iax)  = text(mean(XW),sum(YH)*0.08,str,'FontSize',8,'Color',color,...
%         'HorizontalAlignment','center','Parent',hAxes(iax));
end

uistack(hRect,'bottom')



% Outputs
varargout{1} = hRect;
% varargout{2} = hText;

