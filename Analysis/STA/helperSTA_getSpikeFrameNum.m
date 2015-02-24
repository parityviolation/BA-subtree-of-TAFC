function ST_framesNum = helperSTA_getSpikeFrameNum(expt,unitTag,fileInd,STAparams,cond,spikes)
% function ST_framesNum = helperSTA_getSpikeFrameNum(expt,unitTag,fileInd,STAparams,cond,spikes)


% LCD latency
% The LCD doesn't display frames immediately but at a delay.
% So the frame that actually was displayed x ms before a spike. 
% is the frame from the flips that occured x-LCDdelay earlier
LCDdelay = 0.03; % sec ( the delay seems to vary between 20-40ms)

disp(['**  LCD delay is ' num2str(LCDdelay) ' ms']); 

% STA temporal params
tbin = STAparams.tbin;
WOI = STAparams.WOI;
WOIbin = round(WOI/tbin); % convert to bins

% Rig defaults
rigdef = RigDefs;

% -- Load Spikes
[trodeNum unitInd] = readUnitTag(unitTag); % Get tetrode number and unit index from unit tag
if ~exist('spikes','var')
    % Get spikes from trode number and unit index
    spikes = loadvar(fullfile(rigdef.Dir.Spikes,expt.sort.trode(trodeNum).spikesfile));
    % Get unit label
 try    label = getUnitLabel(expt,trodeNum,unitInd); catch, label = 'none'; end
else
    label = 'no label';
end

    % get unit spikes in desired files
spikes =  filtspikes(spikes,0,'assigns',unitInd,'fileInd',fileInd);

% -- get frames within WOI of each spike
totalspikes = length(spikes.spiketimes);
ST_framesNum = zeros(totalspikes,sum(WOIbin)+1,'int16');

for ifile = 1: length(fileInd) % for each file
    indfile  = fileInd(ifile);
    % for each file % assume that the frame times don't change
    frametime = expt.analysis.STA.files(indfile).trigger(1).frametimes;
    
%     % ** temporary solution ** make more general later
%     IN PROGRESS filter based on LED
%     mask = ismember(expt.analysis.STA.files(indfile).trigger(1).led,cond.led);
%     frametime
    [resample_frame_bin lstTime] = resampleFrameTimes(frametime,tbin,WOI);
    
    tempspikes =  filtspikes(spikes,0,'assigns',unitInd,'fileInd',indfile);
    spiketimes = tempspikes.spiketimes;
    
    stime_bin = round(spiketimes/tbin);%     round stimes to WOIstep bins
    % throw away spike times without window before or after
    stime_bin = stime_bin( (stime_bin>WOIbin(1)) & ((stime_bin + WOIbin(1))<lstTime/tbin));
    [insertrow junk] = find(ST_framesNum==0,1,'first');
    temp = getWOI(resample_frame_bin,stime_bin,WOIbin); %
    ST_framesNum(insertrow:insertrow+size(temp,1)-1,:)= temp; % get chunks of frames triggered on spike
end
ST_framesNum = ST_framesNum';

[r c] = find(ST_framesNum==0);
ST_framesNum(:,c)= []; % remove space reserved for spikes without WOI
totalspikesincluded = size(ST_framesNum,2);

disp(sprintf('******** %d / %d spikes with WOI [%1.1f %1.1f] ********', totalspikesincluded,totalspikes,WOI(1),WOI(2))); % spikes with no WOI were excluded
