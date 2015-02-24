% load and manuall threshold to check 
%
r = brigdefs;
basedir =  r.Dir.EphysData; %'F:\Bass\ephys\'
mdir = 'Sert_179\012014\';
fileheader = 'datafile008';
% mdir = 'Sert_179\012414';
% fileheader = 'datafile003';
mdir = 'Sert179\020614'
fileheader = 'datafile001';
f = [fileheader '.ns6'];
filename = fullfile(basedir,mdir,f);
THRESH_STD = 6;
fileFooter = ''

dnev = openNEV(fullfile(basedir,mdir,[fileheader '.nev']), 'report','t:0:600','nomat','overwrite')
%%
dt = 1/single(dnev.MetaTags.SampleRes);
chn = 46% 32+3;
% get all the spikes for one channel
ind = dnev.Data.Spikes.Electrode == chn;

spikes = ss_default_params_custom_Cerebus(1/dt);
spikes.waveforms = single(dnev.Data.Spikes.Waveform(:,ind)');
spikes.spiketimes = single(dnev.Data.Spikes.TimeStamp(:,ind))*dt;
spikes = ss_instead_of_detect_Cerebus(spikes)

% Heuristic for picking size of clusters
spikes.params.kmeans_clustersize = round(max(500,length(spikes.spiketimes)/100));

spikes = ss_align(spikes);
spikes = ss_kmeans(spikes);
spikes = ss_energy(spikes);
spikes = ss_aggregate(spikes);

% main tool
splitmerge_tool(spikes)

% stand alone outlier tool
outlier_tool(spikes)
