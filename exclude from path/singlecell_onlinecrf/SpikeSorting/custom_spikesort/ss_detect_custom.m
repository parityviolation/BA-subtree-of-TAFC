
% SS_DETECT  Detection of spikes in multi-channel data over multiple trials
%     SPIKES = SS_DETECT_SPIKES(data, params) takes a matrix of data
%     and returns a spikes object containing the waveforms and spike times 
%     embedded in that signal.     
%
%     Inputs:
%     
%     data  -- matrix of data {trials}[ samples X channels ]
%
%     spikes -- should contain 1 field "params"
%
%
%     "params" is a parameter structure that should contain the following
%        fields:
%           params.Fs       -- sampling rate of signal in Hz
% 
%           params.thresh   -- threshold for spike detectiong as 
%                             number  of standard deviations above
%                             background
% 
%           params.window_size -- length of data to extract for   
%                           each spike (ms)
% 
%           params.shadow   -- minimum spacing between spikes (ms)
% 
%           params.cross_time  -- time of threshold crossing to use in 
%                               each spike window (ms)
% 
% 
%   OUTPUT:
%           spikes --  a spike data structure containing time and data
%                   window for each spike
%   
%           thresh    -- the actual threshold value used
%

function spikes = ss_detect_custom( data, spikes )

if ~iscell(data)
    data = num2cell( data, [2 3] );
    data = cellfun(@squeeze,data,'UniformOutput',false);
end

append = isfield( spikes, 'waveforms' );
if append, disp( 'Appending spikes in data using previous threshold.');end
    
params = spikes.params;

% set some constants
num_trials      = length(data); 
num_channels    = size( data{1}, 2);
window_samples  = round( params.Fs * params.window_size / 1000);
shadow          = round( params.Fs * params.shadow /1000);
samples_before  = round( params.Fs * params.cross_time /1000);
samples_after   = round( params.Fs * params.max_jitter / 1000)+ window_samples - (1+samples_before);
jitter_range    = samples_before - 1 + [1:round(spikes.params.max_jitter * spikes.params.Fs/1000)];
 

if append
    pre_trials = max( spikes.trials );
else
    pre_trials = 0;
end


% determine threshold
if append
    thresh = spikes.info.detect.thresh;
else
    spikes.info.detect.cov = get_covs( data, window_samples );
    stds = zeros([1 num_channels]);
    for j = 1:num_trials
      stds = stds + std(data{j});
    end
  
    spikes.info.detect.stds = stds / num_trials;
    
      if isequal( spikes.params.detect_method, 'auto' )
        thresh =  stds/num_trials * -params.thresh;
      elseif isequal( spikes.params.detect_method, 'manual' )
        thresh = params.thresh;
      else
          error( 'Unknown spike detection method.')
      end
     spikes.info.detect.thresh = thresh;
   
end

% find all threshold crossings
if ~append
    spikes.waveforms  = [];
    spikes.spiketimes = [];
    spikes.trials     = [];
    spikes.info.detect.event_channel = [];
end
progress_bar(0, max(floor(num_trials/100),1), sprintf('Extracting Spikes . . . Thresh: %s', num2str(thresh,'%1.2g ')))
for j = 1:num_trials
    
    progress_bar(j/num_trials); % BA
    % get crossings on all channels for this trial
    crossings = [];
    channel = [];
%     -- SRO commented original spike detection
%     for k = 1:num_channels
%         crossings = [crossings find( data{j}(1:end-1,k) > thresh(k) &  data{j}(2:end,k) <= thresh(k) )' ];
%         channel( end+1:length(crossings) ) =  k;
%     end
% % -- End original spike detection

% -- SRO replacement spike detection

    for k = 1:num_channels
        crossings = [crossings (peakfinder(data{j}(:,k),2*abs(thresh(k)),-1))'];
        channel( end+1:length(crossings) ) =  k;
    end
    
    [crossings, i] = sort(crossings);
    channel = channel(i);
    
    % remove  bad crossings, but remove them from channel first
    channel( 1+ find( diff(crossings) <= shadow )) = [];    crossings( 1+ find( diff(crossings) <= shadow ) ) = [];
    channel( crossings < samples_before  ) = [];    crossings(  crossings <= samples_before ) = [];
    channel(  crossings > size(data{j},1) - samples_after   ) = [];    crossings(  crossings > size(data{j},1) - samples_after ) = [];

    % update spiketimes, trials, and waveforms
    spikes.spiketimes   =  [spikes.spiketimes crossings / params.Fs];
    spikes.trials       =  [spikes.trials pre_trials + (j * ones( [1 length(crossings)] ))];
    w = zeros( [length(crossings) samples_before+1+samples_after num_channels] ,'single'); % BA made single
    for k = 1:length(crossings)
        indices = crossings(k) + [-samples_before:samples_after];
        w(k,:,:) = data{j}(indices, :) ;
    end
    spikes.waveforms    =  [spikes.waveforms; w ];

    spikes.info.detect.dur( j + pre_trials ) = size( data{j}, 1) / params.Fs;
end

% SRO -- Clear data array and convert waveforms to single to free memory
clear data
spikes.waveforms = single(spikes.waveforms);
spikes.spiketimes = single(spikes.spiketimes);
spikes.trials = single(spikes.trials);

% SRO -- end of modification

% we will call the threshold channel whichever channel runs most negative
      
[junk,  spikes.info.detect.event_channel] = min( squeeze( min( spikes.waveforms(:,jitter_range,:), [], 2 ) ), [], 2 );

spikes.info.detect.align_sample = samples_before + 1;

tic % BA  - this pca step seems unnecessary if you are gonna allign because it is redone after alignment
[pca.u,pca.s,pca.v] = svd(detrend(spikes.waveforms(:,:),'constant'), 0);             % SVD the data matrix
spikes.info.pca = pca;
toc 

detect_rate = length(spikes.spiketimes) / sum(spikes.info.detect.dur);
disp( ['Detected on average ' num2str( detect_rate ) ' events per second of data '] );


function c = get_covs( data, samples )

    num_trials = length(data);
    num_channels = size(data{1},2);
    for j = 1:num_trials, num_samples(j) = size(data{j},1); end

    max_samples = 10000;
    waves = zeros( [max_samples samples num_channels] );
    tr_index = ceil( num_trials * rand([1 max_samples]) );
    data_index = ceil( (num_samples(tr_index)-samples) .* rand([1 max_samples]) );
    for j = 1:max_samples
       waves(j,:,:) = data{tr_index(j)}(data_index(j)+[0:samples-1],:);  
    end
        
  
   c = cov( waves(:,:) );


