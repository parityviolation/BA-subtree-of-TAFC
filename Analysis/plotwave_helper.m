function [hwav hmetric] = plotwave_helper(ua_temp,ax)
hwav = []; hmetric = [];
for i =1 :length(ua_temp)
    % get waveform
    avgwv_maxch = ua_temp(i).spikeWaveformMetrics.avgwave_metrics;
    xtime = ua_temp(i).spikeWaveformMetrics.time;
    
    % normalize to trough
    x = avgwv_maxch;
    avgwv_maxch = x/min(x)*sign(min(x));
    
    % get metrics
    troughpeaktime = ua_temp(i).spikeWaveformMetrics.troughpeaktime;
    slope05 = ua_temp(i).spikeWaveformMetrics.slope05;  
    
    % plot    
    hwav(i) = line(xtime,avgwv_maxch,'Parent',ax.wav);
    set(hwav(i),'Tag',cell2mat(ua_unitDescription( ua_temp(i))))
    title(num2str(troughpeaktime))
    hmetric(i) = line(troughpeaktime,slope05,'MarkerSize',10,'Marker','.','Parent',ax.metric);
    set(hmetric(i),'Tag',cell2mat(ua_unitDescription( ua_temp(i))))    
end