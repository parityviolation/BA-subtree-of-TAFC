function [wv outspikes sortvector] = spikeTrigLFP(expt,spikes,lfp_range,ch,sw_window,LP_cutoff, datadir)
% function avgwv = spikeTrigLFP(expt,spikes,lfp_range,sw_window,LP_cutoff) 
%
% INPUT
%   expt: The expt struct
%   spikes: The spikes struct
%   lfp_range: Window before and after LFP data to extract in seconds. E.g.
%   lfp_range = 0.1 will extract 100 ms before and after spike.
%   sw_window: Window within the sweep from which spikes will be drawn
%   LP_cutoff: Frequency cutoff for low-pass filtering of LFP

% Created: 6/19/10 - SRO
% Modified: 6/29/10 - SRO
% Heavily modified - WB 06-11/2010


% If sweep window not supplied, use shortest sweep duration
if nargin < 6
    LP_cutoff = 100;
elseif nargin < 5
    sw_window = [0 min(expt.files.duration)];
    LP_cutoff = 100;
end
% Set rig defaults
rigdef = RigDefs;
if(nargin < 7)
    datadir = rigdef.Dir.Data;
end

% Set sweep duration
duration = min(expt.files.duration);

% Set sample rate
Fs = expt.files.Fs(1);

% Abbreviate spikes
s = spikes;

% Set channels to extract data from
chns = sort(expt.info.probe.channelorder) + 1; % Add 1 because trigger channel offset

% Spikes must occur at time > lfp_range after beginning of trial, and time
% < t_range before ending of trial. Make temp field in spikes that can be
% used for filtering spiketimes using filtspikes.
s.temp = zeros(size(s.spiketimes));
s.temp((s.spiketimes > lfp_range) & (s.spiketimes < (duration-lfp_range))) = 1;
[s sortvector_logical] = filtspikes(s,0,'temp',1);

% Extract spikes falling in sw_window
s.temp = zeros(size(s.spiketimes));
s.temp((s.spiketimes >= sw_window(1)) & (s.spiketimes <= sw_window(2))) = 1;
[s sortvector2_logical] = filtspikes(s,0,'temp',1);
sortvector = find(sortvector_logical);
sortvector = sortvector(sortvector2_logical);

% Number of spikes
nspikes = length(s.spiketimes);

% Convert lfp_range to samples
lfp_range = floor(lfp_range*Fs); % must floor or samples - lfp_range can be < 0 in some fringe cases

% Preallocate matrix
wv = nan(2*lfp_range+1,nspikes,length(chns));

fileIndices = unique(s.fileInd);
nspikes_file = nan([length(fileIndices), 1]);
outspikes = [];
for n = 1:length(fileIndices)
    c_fileInd = fileIndices(n);
    s_curfile = filtspikes(s, 0, 'fileInd', c_fileInd);
    nspikes_file(n) = length(s_curfile.spiketimes); 

     
    % load daq file
    fname = [datadir expt.files.names{c_fileInd}];
    if(~exist(fname, 'file'))
        warning(['Missing a daq file: ', fname]);
        disp('Leaving the waveforms as NaNs!');        
        continue;
    else
        disp(['Loading daq file: ', fname]);
    end
    daqdata = daqread(fname,'Channels',chns);

    duration = expt.files.duration(c_fileInd);
    Fs = expt.files.Fs(c_fileInd);
    ptsPerTrigger = duration*Fs;
    % because of the spacers length(daqdata) =
    % ptsPerTrigger*numTriggers+numTriggers = numTriggers*(ptsPerTrigger+1)
    numTriggersEmpirical = ceil(length(daqdata)/(ptsPerTrigger+1));
    if(numTriggersEmpirical ~= expt.files.triggers(c_fileInd))
        disp('spikeTrigLFP.m: number of triggers found empirically does not match the number reported by expt.files.triggers(c_fileInd)');
    end
    daqdata = MakeDataMat(daqdata,expt.files.triggers(c_fileInd), ...
        expt.files.Fs(c_fileInd),expt.files.duration(c_fileInd));
    %daqdata = MakeDataMat(daqdata,numTriggersEmpirical, ...
%        Fs,duration);
    
    for idx = 1:nspikes_file(n)
        % Convert spike time to sample number
         sample = round(s_curfile.spiketimes(idx)*Fs);         
         trigger = s_curfile.trigger(idx);

         % Extract data in window +/- lfp_range
         startPt = sample - lfp_range;
         endPt = sample + lfp_range;
         spikeidx_global = idx + sum( nspikes_file(1:(n-1) ) );
         if(startPt <= 0)
             warning('A spike too close to the edges made it past the filter (this shouldn''t happen). Setting to NaN.');
             continue;
         end
         wv(:,spikeidx_global,:) = daqdata(startPt:endPt,trigger,:); 
         % Need to consider down-sampling
    end
    if(isempty(outspikes))
        outspikes = s_curfile;
    else % replace this later with dynamic updating of all fields of spiketimes length as in filtspikes
        outspikes.waveforms = reshape([outspikes.waveforms(:); s_curfile.waveforms(:)], size(outspikes.waveforms,1)+size(s_curfile.waveforms, 1), size(outspikes.waveforms, 2), size(outspikes.waveforms, 3));
        outspikes.spiketimes = [outspikes.spiketimes s_curfile.spiketimes];
        outspikes.trials = [outspikes.trials s_curfile.trials];
        outspikes.fileInd = [outspikes.fileInd s_curfile.fileInd];
        outspikes.trigger = [outspikes.trigger s_curfile.trigger];
        outspikes.stimcond = [outspikes.stimcond s_curfile.stimcond];
        outspikes.led = [outspikes.led s_curfile.led];
        outspikes.unwrapped_times = [outspikes.unwrapped_times s_curfile.unwrapped_times];
        outspikes.assigns = [outspikes.assigns s_curfile.assigns]; 
        outspikes.sweeps.fileInd = [outspikes.sweeps.fileInd , s_curfile.sweeps.fileInd];
        outspikes.sweeps.trials = [outspikes.sweeps.trials , s_curfile.sweeps.trials];
        outspikes.sweeps.trigger = [outspikes.sweeps.trigger , s_curfile.sweeps.trigger];
        outspikes.sweeps.stimcond = [outspikes.sweeps.stimcond , s_curfile.sweeps.stimcond];
        outspikes.sweeps.led = [outspikes.sweeps.led , s_curfile.sweeps.led];
        outspikes = UpdateTrials(outspikes);
    end
end

% temporary
doFiltData = 0;
if(doFiltData)
    % band-pass filter data
    for n = 1:size(wv,3)
        wv(:,:,n) = filtdata(wv(:,:,n),Fs,100,'low');
        wv(:,:,n) = filtdata(wv(:,:,n),Fs,20,'high');
    end
end

% Average across spikes
wv = squeeze(mean( wv , 3));



