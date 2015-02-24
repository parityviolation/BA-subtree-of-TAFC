function [varargout] = raster(spikes,hAxes,bAppend,bUseTrialsInFilter)
% function [varargout] = raster(spikes,hAxes,bAppend,bUseTrialsInFilter))
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
if nargin < 2 || isempty(hAxes),    hAxes = axes;end
if nargin < 3 || isempty(bAppend),bAppend = 0;end
useTrials =0;
if ~exist('bUseTrialsInFilter','var'), useTrials = 1; 
elseif ~bUseTrialsInFilter, useTrials = 1;  end

% Set trial duration
duration = spikes.info.detect.dur(1);

% Set spiketimes
spiketimes = spikes.spiketimes;

% Set trial numbers
if isfield(spikes,'trialsInFilter') && ~useTrials
    trials = spikes.trialsInFilter;
else
    trials = spikes.trials;
end

if ~isempty(trials)
    % Get previous trial information
    t = get(hAxes,'UserData');
    if isempty(t)
        t.min = min(trials);
        t.max = max(trials);
    else
        if bAppend == 1
            % Offset by max trial number already on plot
            trials = trials + max(t.max);
        end
        t.min(end+1) = min(trials);
        t.max(end+1) = max(trials);
    end
else
    t.min = 0;
    t.max = 1;
    spiketimes = NaN;
    trials = NaN;
end

% Store trial information as UserData in hAxes
set(hAxes,'UserData',t)

% Make raster on hAxes
% set(gcf,'CurrentAxes',hAxes)
hRaster = linecustommarker(spiketimes,trials,[],[],hAxes);

% Set default raster properties
numtrials = length(spikes.sweeps.trials);
offset = numtrials*0.03;
ymin = (min(t.min)-offset);
ymax = (max(t.max)+offset);
set(hAxes,'TickDir','out','YDir','reverse','FontSize',9, ... 
    'YLim',[ymin ymax],'XLim',[0 duration])
xlabel(hAxes,'seconds')
ylabel(hAxes,'trials')

% Outputs
varargout{1} = hRaster;
varargout{2} = hAxes;




