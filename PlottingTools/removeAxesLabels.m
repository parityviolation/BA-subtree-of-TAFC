function removeAxesLabels(hAxes)

for i = 1:length(hAxes)
    xlabel(hAxes(i),''); ylabel(hAxes(i),'')               % No axis labels
    set(hAxes(i),'XTickLabel',{},'YTickLabel',{});      % No tick labels
end
