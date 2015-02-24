function [varargout] = psth(spikes,binsize,hAxes)
% function [varargout] = psth(spikes,binsize,hAxes))
%
% INPUTS
%   spiketimes:
%   binsize:
%   duration:
%
% OUTPUTS
%   varargout{1} = hPsth;
%   varargout{2} = hAxes;
%   varargout{3} = n;
%   varargout{4} = centers;
%   varargout{5} = edges;
%
% Created: 3/14/10 - SRO
% Modified: 5/14/10 - SRO

if nargin < 2
    binsize = 50; 
end

% Use current axes if hAxes not supplied
if nargin < 3
    hAxes = gca;   
end

% Set duration and number of trials
duration = max(spikes.info.detect.dur);     % Maybe add checking for equal sweep durations?
numtrials = length(spikes.sweeps.trials);

% Set spiketimes
spiketimes = spikes.spiketimes;

% Convert binsize from s to ms
binsize = binsize/1000;

% Get counts
edges = 0:binsize:duration;
n = histc(spiketimes,edges);
n = n/numtrials/binsize;

% Compute center of bins
centers = edges + diff(edges(1:2))/2;

% Last point of n contains values falling on edge(end) -- usually zero
hPsth = line('XData',centers(1:end-1),'YData',smooth(n(1:end-1),3),...
    'Parent',hAxes,'LineWidth',1.5);

% Set default axes properties
if sum(n) == 0
    maxN = 0.1;
else
    maxN = max(n);
end
axis([0 duration 0 maxN])
set(hAxes,'TickDir','out','FontSize',9)
xlabel(hAxes,'seconds')
ylabel(hAxes,'spikes/s')

% Outputs
varargout{1} = hPsth;
varargout{2} = hAxes;
varargout{3} = n;
varargout{4} = centers;
varargout{5} = edges;