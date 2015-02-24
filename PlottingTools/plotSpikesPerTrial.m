function varargout = plotSpikesPerTrial(spikes,hAxes,smoothwin)
% function varargout = plotSpikesPerTrial(spikes,hAxes,smoothwin)
%
%
% INPUT
%   spikes: spikes struct
%   smoothwin: Assign value > 0 for smoothing with window of N points
%
% OUTPUT
%   varargout{1} = hLine
%   varargout{2} = hAxes
%   varargout{3} = spikesPerTrial
%   varargout{4} = xtime

% Created: 5/16/10 - SRO
% modifield 9/20/10 - fixed bug with trials if not plotting all trials in a
% an expt
if nargin < 2
    smoothwin = 0;
    hAxes = axes;
end

if nargin < 3
    smoothwin = 0;
end

if isempty(hAxes)
    hAxes = axes;
end

% Compute number of spikes per trial
ntrials = length(spikes.sweeps.trials);
spikesPerTrial = zeros(size(spikes.sweeps.trials));
i = 0;
for itrial = unique(spikes.sweeps.trials)
    i = i+1;
    spikesPerTrial(i) = length(find(spikes.trials == itrial));
end

% Compute time of each sweep
if isfield(spikes.sweeps,'time')
    starttime = spikes.sweeps.time(1);
    xtime = zeros(size(spikes.sweeps.time));
    for i = 1:length(spikes.sweeps.time)
        xtime(i) = etime(starttime,spikes.sweeps.time(i));
    end
else
    xtime =min(spikes.sweeps.trials):max(spikes.sweeps.trials);  
end

% Plot line
hLine = line('Parent',hAxes,'XData',xtime,'YData',spikesPerTrial, ...
    'Marker','none','Color',[0.15 0.15 0.15]);
maxspikes = max(spikesPerTrial);
if maxspikes == 0
    maxspikes = 1;
end
set(hAxes,'XLim',[min(xtime) max(xtime)],'YLim',[0 maxspikes]);

% Output
varargout{1} = hLine;
varargout{2} = hAxes;
varargout{3} = spikesPerTrial;
varargout{4} = xtime;