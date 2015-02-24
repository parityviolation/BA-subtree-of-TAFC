ichn=29;
Nspikes = 10000;
fileFooter = '';
d = loadoedata('',ichn,'s') ;% got huge number of events at 3.3 ms and 25 ms 
dt = d.spk.info.header.sampleRate;

d.path = 'C:\Bass\ephys\Sert179\2014-02-09_16-22-17'
spikes = ss_default_params_custom(1/dt);
spikes.params.cross_time = 9*dt*1000;   % this is actually the peak
spikes.waveforms = d.spk.data(1:Nspikes,:);
spikes.spiketimes = d.spk.timestamps(1:Nspikes)';
spikes.info.recordinfo = d.spk.info.header;
spikes.info.spikesfile = fullfile(d.path,'spikes',['spikes_' strrep(d.filename,'.','_') fileFooter '.mat']);
parentfolder(fileparts(spikes.info.spikesfile) ,1)
% clear d  

spikes = ss_instead_of_detect_OpenEphys(spikes);
spikes.params.kmeans_clustersize = round(max(500,length(spikes.spiketimes)/100));

spikes = ss_align(spikes);
spikes = ss_kmeans(spikes);
spikes = ss_energy(spikes);
spikes = ss_aggregate(spikes);


save(spikes.info.spikesfile,'spikes');

% main tool
splitmerge_tool(spikes)

