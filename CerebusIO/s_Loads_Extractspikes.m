filename =  'E:\Bass\ephys\copy\021514\datafile001-01.nev';
fileFooter = '';
dt = 1/30000;
ndx = dnev.Data.Spikes.Electrode==42 && dnev.Data.Spikes.Unit~=255;
spikes = ss_default_params_custom_Cerebus(1/dt);
%         spikes.params.display.label_categories = r.SS.label_categories ;
%         spikes.params.display.label_colors = r.SS.label_colors;
%         spikes.info.spikesfile = fullfile(LOADPATH,'spikes',['spikes_chn' num2str(ichn) fileFooter '.mat']);
%         parentfolder(fileparts(spikes.info.spikesfile) ,1)


spikes.spiketimes =  double(dnev.Data.Spikes.TimeStamp(ndx));
spikes.waveforms =  double( dnev.Data.Spikes.Waveform(:,ndx))';
spikes = ss_instead_of_detect_Cerebus(spikes);

spikes.info.recordinfo = d.spk.info.header;
[d.path d.filename] = fileparts(filename)
spikes.info.spikesfile = fullfile(d.path,'spikes',['spikes_' strrep(d.filename,'.','_') fileFooter '.mat']);
parentfolder(fileparts(spikes.info.spikesfile) ,1)


% Heuristic for picking size of clusters
spikes.params.kmeans_clustersize = round(max(500,length(spikes.spiketimes)/100));
spikes = ss_align(spikes);
spikes = ss_kmeans(spikes);
spikes = ss_energy(spikes);
spikes = ss_aggregate(spikes);
save(spikes.info.spikesfile,'spikes')