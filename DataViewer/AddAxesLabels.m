function AddAxesLabels(hAxes,xLab,yLab)

if nargin < 2
    xLab = '';
    yLab = '';
end
if iscell(hAxes)
    hXlabel = cell2mat(get(hAxes(:),'XLabel'));
    hYlabel = cell2mat(get(hAxes(:),'YLabel'));
else
    hXlabel = get(hAxes(:),'XLabel');
    hYlabel = get(hAxes(:),'YLabel');
end
if iscell(hXlabel)
    hXlabel = cell2mat(hXlabel);
end
if iscell(hYlabel)
    hYlabel = cell2mat(hYlabel);
end
set(hXlabel,'String',xLab)
set(hYlabel,'String',yLab)
set(hAxes(:),'XTickLabelMode','auto','YTickLabelMode','auto',...
    'XTickMode','auto','YTickMode','auto');
