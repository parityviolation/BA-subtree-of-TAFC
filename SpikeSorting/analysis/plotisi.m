function lh = plotisi(spikes,assign)

% BA 

tempspikes = filtspikes(spikes,0,'assigns',assign)
spikes.unwrapped_times = tempspikes.spiketimes;

isi1 = diff(spiketimes(1:end-1))*1e3;
isi2 = diff(spiketimes(2:end))*1e3;


lh = line(isi1,isi2,'Linestyle','o');

set(gca,'XScale','log','YScale','log');
set(gca,'xlim',[0 max([isi1(:);isi2(:)])], 'ylim',[0 max([isi1(:);isi2(:)])])
