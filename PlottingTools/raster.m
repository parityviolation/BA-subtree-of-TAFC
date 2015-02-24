function [varargout] = raster(spikes,hAxes,bAppend)
% function [varargout] = raster(spikes,hAxes,bAppend)
% INPUTS
%   spikes: The spikes struct. This function requires that spikes contain
%   only the following fields:
%       - .spiketimes: Vector of spike times
%       - .trials: Vector indicating trial in which each spike occurred
%   varargin{1} = hAxes
%
% OUTPUTS
%   varargout(1) = hRaster, handle to raster
%   varargout(2) = hAxes, handle to axes

% Created: 5/11/10 - SRO

if nargin < 2
    hAxes = axes;
    bAppend = 0;
end

if bAppend == 0
    useTrials = 1;
else
    useTrials = 0;
end

% Set trial duration
if isfield(spikes.sweeps,'duration')
    duration = max(spikes.sweeps.duration);     % Maybe add checking for equal sweep durations?
else % backward compatible 
    duration = max(spikes.info.detect.dur);
end

% Set spiketimes
spiketimes = spikes.spiketimes;

% Set trial numbers
if isfield(spikes,'trialsInFilter') && ~useTrials
    trials = spikes.trialsInFilter;
else
    trials = spikes.trials;
end

% Get previous trial information
t = get(hAxes,'UserData');
if ~isempty(trials) & ~isnan(trials)
    
    if isempty(t)
        if isfield(spikes.sweeps,'trialsInFilter')
            t.min = min(spikes.sweeps.trialsInFilter);
            t.max = max(spikes.sweeps.trialsInFilter);
        else
            t.min = min(spikes.sweeps.trials);
            t.max = max(spikes.sweeps.trials);
        end
    else
        if bAppend == 1
            % Offset by max trial number already on plot
            trials = trials + max(t.max);
        end
        t.min(end+1) = min(trials);
        t.max(end+1) = max(trials);
    end
else
    if ~isempty(t)
        if bAppend == 1
            % Offset by max trial number already on plot
            trials = 0;
            trials = trials + max(t.max);
        end
        t.min(end+1) = min(trials);
        t.max(end+1) = max(trials);
        spiketimes = NaN;
        trials = NaN;
    else
            t.min = 0;
            t.max = 1;
            spiketimes = NaN;
            trials = NaN;
    end
end

% Store trial information as UserData in hAxes
set(hAxes,'UserData',t)

% Make raster on hAxes
hRaster = linecustommarker(spiketimes,trials,[],[],hAxes);

% Set default raster properties
if ~isempty(trials) & ~isnan(trials)
    numtrials = length(spikes.sweeps.trials);
    offset = numtrials*0.03;
    if offset==0, offset=eps; end % in case numtrials is zero
    ymin = (min(t.min)-offset);
    ymax = (max(t.max)+offset);
    set(hAxes,'TickDir','out','YDir','reverse','FontSize',9, ...
        'YLim',[ymin ymax],'XLim',[0 duration])
    xlabel(hAxes,'seconds')
    ylabel(hAxes,'trials')
end
% Outputs
varargout{1} = hRaster;
varargout{2} = hAxes;




