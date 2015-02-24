function spikes = saveSpikes(spikes)
% BA 052014
r = brigdefs;
p = fullfile(r.Dir.spikesStruct,spikes.sweeps.Animal);
parentfolder(p,1);
spikes.info.savefile = fullfile(p, [spikes.sweeps.Animal '_D' spikes.sweeps.Date 'F' spikes.sweeps.FileNumber '_spikes']);
save(spikes.info.savefile,   'spikes','-v7.3');
