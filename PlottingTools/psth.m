function [varargout] = psth(spikes,binsize,hAxes,bsmooth,busebootstrap)
% function [varargout] = psth(spikes,binsize,hAxes,bsmooth)
%
% INPUTS
%   spiketimes:
%   binsize:
%   hAxes:
%   bsmooth:
%   busebootstrap
%
% OUTPUTS
%   varargout{1} = hPsth;
%   varargout{2} = hAxes;
%   varargout{3} = n;
%   varargout{4} = centers;
%   varargout{5} = edges;
%   varargout{6} = hPsthncipatch;
%   varargout{7} = nci;

% Created:  3/14/10 - SRO
% Modified: 5/14/10 - SRO
%           6/8/10 - SRO
%           10/1/10 - BA added boostrapping

if nargin < 2
    binsize = 50;
end

% Use current axes if hAxes not supplied
if nargin < 3
    hAxes = gca;
end

if nargin < 4
    bsmooth = 0;
end

if ~exist('busebootstrap','var')|| isempty(busebootstrap), busebootstrap = 0; end

% Set duration and number of trials
if isfield(spikes.sweeps,'duration')
    duration = max(spikes.sweeps.duration);     % Maybe add checking for equal sweep durations?
else % backward compatible 
    duration =  max(spikes.info.detect.dur);
end

numtrials = length(spikes.sweeps.trials);

% Set spiketimes
spiketimes = spikes.spiketimes;


if ~isempty(spiketimes)
    
    % Set duration and number of trials
    if isfield(spikes.sweeps,'duration')
        duration = max(spikes.sweeps.duration);     % Maybe add checking for equal sweep durations?
    else % backward compatibility
        duration = max(spikes.info.detect.dur);     % Maybe add checking for equal sweep durations?
    end
    numtrials = length(spikes.sweeps.trials);
    
    % Convert binsize from s to ms
    binsize = binsize/1000;
    
    % Get counts
    edges = 0:binsize:duration;
    
    % Compute center of bins
    centers = edges + diff(edges(1:2))/2;
    
    
    n = histc(spiketimes,edges);
    n = n/numtrials/binsize;
    
else % no spikes set everything to some values that will avoid crasshing
     duration = 1; n = [0 0]; edges = [0 duration];centers = [0 duration]; numtrials = 0;
end
% -- bootstrap psth
if busebootstrap & numtrials>=3 &  ~isempty(spiketimes)
    
    % first get the binned psth for each trail
    % then bootstrap the mean of the binned psth
    t = unique(spikes.sweeps.trials);
    for itrial = 1:numtrials
        ind  = ismember(spikes.trials,t(itrial)); % ind of spikes in trial
        spiketimes = spikes.spiketimes(ind);
        temp = histc(spiketimes,edges);
        if ~isempty(temp), n_trial(itrial,:) = temp;
        else  n_trial(itrial,:) = zeros(1,length(edges)); end
    end
    
    nbootstraps = max(100,numtrials*20);
    meanfunc = @(x) (nanmean(x));
    alpha = 0.33;
    nci = bootci(nbootstraps,{meanfunc,n_trial},'alpha',alpha);
    nci = nci/binsize; % already devided by trials when mean was taken
else
    nci = nan(2,length(n));
end


if all(isnan(n))
    n = zeros(size(edges));
end


% Last point of n contains values falling on edge(end) -- usually zero
if bsmooth & ~busebootstrap % BA bootstrap doesn't work with smoothing for now
    y = smooth(n(1:end-1),3);
else
    y = n(1:end-1);
end

% plot line and boostrapped confidence
[hPsth, hPsthpatch] = boundedline(centers(1:end-1)',y',zeros(size(y)),hAxes,'alpha','transparency',0.2);
set(hPsth,'LineWidth',1.5);
% prepare vectors that loop around the patch
tempx =  [centers(1:end-1) centers(end-1:-1:1)];
tempy = [nci(1,1:end-1) nci(2,end-1:-1:1)];
set(hPsthpatch,'YData',tempy,'Xdata',tempx)

% Set default axes properties
if sum(n) == 0
    maxN = 0.1;
else
    maxN = max([n nci(2,:)]);
end

if ~isempty(spiketimes), axis([0 duration 0 maxN]);  end

set(hAxes,'TickDir','out','FontSize',9)
xlabel(hAxes,'seconds')
ylabel(hAxes,'spikes/s')

% Outputs
varargout{1} = hPsth;
varargout{2} = hAxes;
varargout{3} = n;
varargout{4} = centers;
varargout{5} = edges;
varargout{6} = hPsthpatch;
varargout{7} = nci;