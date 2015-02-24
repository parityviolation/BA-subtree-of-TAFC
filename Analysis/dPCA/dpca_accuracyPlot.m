function dpca_accuracyPlot(time, accuracy, brier, accuracyShuffle, brierShuffle, numClasses, prct, row)

figure

for i=1:9 %21%9
    %subplot(5,9,9*(row-1)+i)
    %subplot(3,7,(mod(i-1,3))*7 + floor((i-1)/3)+1)
    
    subplot(3,3,i)
    
    axis([time(1) time(end) 0 1])
    hold on
 
    maxSh = max(accuracyShuffle(ceil(i/3),:,:),[],3);
    minSh = min(accuracyShuffle(ceil(i/3),:,:),[],3);
    h = patch([time fliplr(time)], [maxSh fliplr(minSh)], 'b');
    set(h, 'FaceAlpha', 0.5)
    set(h, 'EdgeColor', 'none')
    
    data = accuracyShuffle(ceil(i/3),:,:);
    flatMaxSh = prctile(data(:), prct);
    plot(xlim, flatMaxSh*[1 1], 'b')
    plot(xlim, 1/numClasses(i)*[1 1], 'k')
    plot(time, accuracy(i,:), 'LineWidth', 2)
    
%     maxSh = max(brierShuffle(ceil(i/3),:,:),[],3);
%     minSh = min(brierShuffle(ceil(i/3),:,:),[],3);
%     h = patch([time fliplr(time)], [maxSh fliplr(minSh)], 'r');
%     set(h, 'FaceAlpha', 0.5)
%     set(h, 'EdgeColor', 'none') 
%     
%     data = brierShuffle(ceil(i/3),:,:);
%     flatMinSh = prctile(data(:), 100-prct);
%     plot(xlim, flatMinSh*[1 1], 'r')
%     %plot(xlim, (numClasses(i)-1)/numClasses(i)^2*[1 1], 'k')
%     plot(time, brier(i,:), 'r', 'LineWidth', 2)
end
