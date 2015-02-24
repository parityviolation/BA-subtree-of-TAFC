function spikes = ss_instead_of_detect_Cerebus(spikes)

params = spikes.params;
cross_time_sample = params.cross_time*params.Fs/1000;
num_trials      = 10; % FIX THIS
num_channels    = size( spikes.waveforms, 1);
window_samples  = round( params.Fs * params.window_size / 1000);
shadow          = round( params.Fs * params.shadow /1000);
samples_before  = round( params.Fs * params.cross_time /1000);
samples_after   = round( params.Fs * params.max_jitter / 1000)+ window_samples - (1+samples_before);
jitter_range    = samples_before - 1 + [1:round(spikes.params.max_jitter * spikes.params.Fs/1000)];


nevents = size(spikes.waveforms,1);
spikes.unwrapped_times=spikes.spiketimes;
spikes.trials=ones(1,nevents,'single');

spikes.info.detect.stds = 1; % THIS IS FAKE
spikes.info.detect.thresh = mean(squeeze(spikes.waveforms(:,cross_time_sample,:)));
spikes.info.detect.dur = max(spikes.unwrapped_times);
spikes.info.detect.event_channel = nan(1,nevents,'single');

for ievent = 1:nevents
    [junk spikes.info.detect.event_channel(ievent)]  = max(squeeze(spikes.waveforms(ievent,cross_time_sample,:)));
%     spikes.cleanwaveform.range(spikes.info.detect.event_channel(ievent),ievent) = range(squeeze(spikes.waveforms(ievent,:,spikes.info.detect.event_channel(ievent))));
end



% BELOW FROM  D.H code
% save some more data that will be useful later
spikes.info.detect.align_sample = samples_before + 1;
[pca.u,pca.s,pca.v] = svd(detrend(spikes.waveforms(:,:),'constant'), 0);             % SVD the data matrix
spikes.info.pca = pca;

% report detection rate
detect_rate = length(spikes.spiketimes) / sum(spikes.info.detect.dur);
disp( ['Detected on average ' num2str( detect_rate ) ' events per second of data '] );

% DO I NEED 
  spikes.info.detect.cov = NaN;
