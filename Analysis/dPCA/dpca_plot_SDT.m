function dpca_plot_SDT(time, data, yspan, explVar, compNum, events, signif, marg)

numOfStimuli = size(data,2);

% adjust the colours here

if numOfStimuli == 2
    colors = [1 0 0; 0 0 1];
else
    colors = jet(numOfStimuli);     
end

if strcmp(time, 'legend')
    hold on
    
    for f=1:numOfStimuli
        plot([0 1], [f f], 'color', colors(f,:), 'LineWidth', 2)
    end
    
    plot([0 1], [-2 -2], 'k', 'LineWidth', 2)
    plot([0 1], [-3 -3], 'k--', 'LineWidth', 2)
    
    text(1.2, -2, 'Decision 1')
    text(1.2, -3, 'Decision 2')
    for f=1:numOfStimuli
        text(1.2, f, ['Stimulus ' num2str(f)])
    end

    axis([-0.25 3 -4.5 numOfStimuli+1.5])
    set(gca, 'XTick', [])
    set(gca, 'YTick', [])
    set(gca,'Visible','off')
        
    return
end

axis([time(1) time(end) yspan])
hold on
   
for f=1:numOfStimuli
    plot(time, squeeze(data(1, f, 1, :)), 'color', colors(f,:), 'LineWidth', 2)
    plot(time, squeeze(data(1, f, 2, :)), '--', 'color', colors(f,:), 'LineWidth', 2)
end

title(['Component #' num2str(compNum) ' [' num2str(explVar,'%.1f') '%]'])

plot([events', events'], yspan, 'Color', [0.6 0.6 0.6])

if ~isempty(signif)
    signif(signif==0) = nan;
    plot(time, signif + yspan(1) + (yspan(2)-yspan(1))*0.05, 'k', 'LineWidth', 3)
end

