function [hAx ind_violators] = plotViolationSpikes(spikes,assign)
% function [hAx ind_violators] = plotViolationSpikes(spikes,assign)

% BA quick and dirty view of violating spikes

% get assign spikes
tempspikes = filtspikes(spikes,0,'assigns',assign);
isi = diff(tempspikes.unwrapped_times)*1e3;

% get violations
temp = isi <= spikes.params.refractory_period;
ind_violators = find(temp);
ind_violators  = [ind_violators ind_violators+1];
 ind_nonviolators = find(~ismember([1:length(tempspikes.unwrapped_times)],ind_violators));

viospikes = filtspikes(tempspikes,0,'unwrapped_times',tempspikes.unwrapped_times(ind_violators));
mainspikes = filtspikes(tempspikes,0,'unwrapped_times',tempspikes.unwrapped_times(ind_nonviolators));
%% plot violation waveforms and mean waveform
figure('Name',sprintf('%d Volation Waveform',assign))
waveforms = viospikes.waveforms;
[nspk nsample nsites] = size(waveforms);
xtime = [1:nsample*nsites]*1/spikes.params.Fs*1e3;

[avgwv] = computeAvgWaveform(mainspikes.waveforms);
line(xtime,avgwv(:),'linewidth',2,'color','k')
title('violating spikes')
DefaultAxes(gca)

    hl = line(xtime,reshape(squeeze(spikes.waveforms(1,:,:)),[1,nsample*nsites]));
mark = [];
for i = 2: nspk
  set(hl,'Ydata',reshape(squeeze(spikes.waveforms(i,:,:)),[1,nsample*nsites]))
    k = input('space to mark');
    if strcmp(k,' '), mark(end+1) = i; end
    title(num2str(i))
end

hAx = gca;