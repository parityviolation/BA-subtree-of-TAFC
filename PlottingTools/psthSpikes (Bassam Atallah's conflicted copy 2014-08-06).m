function [varargout] = psthSpikes(spikes,binsize,hAxes,NSMOOTH,busebootstrap,WOI,plotparam)
% function [varargout] = psth(spikes,binsize,hAxes,bsmooth)
% NOTE
%     spikes can be struct OR
%          [spiktimes sweeps]
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
%   varargout{3} = yout;
%   varargout{4} = centers;
%   varargout{5} = edges;
%   varargout{6} = hPsthncipatch;
%   varargout{7} = nci;

%
%           10/1/10 - BA added boostrapping

bverbose = 0;
alpha = 0.05;

if nargin < 2
    binsize = 50; % ms
end

% Use current axes if hAxes not supplied
if nargin < 3
    hAxes = gca;
end

bplot = 1;
if hAxes ==-1
    bplot = 0;
end

if nargin < 4
    NSMOOTH = 0; % number of bins to include in smoothing
end


extraWOI = 0;
if NSMOOTH % make WOI larger for smoothing
    extraWOI = NSMOOTH*2;
    filttype = 'flat';
end

if ~exist('busebootstrap','var')|| isempty(busebootstrap), busebootstrap = 0; end

if nargin < 6
    WOI = [0 max(spikes.spiketimes)];
end
if nargin < 7
    plotparam.endline = [];
end

% Convert binsize from ms to s
binsize = binsize/1000;
edges = -(WOI(1)+binsize*extraWOI):binsize:(WOI(2) +binsize*extraWOI);
centers = edges + diff(edges(1:2))/2;   % Compute center of bins
n = zeros(size(edges)); numtrials = 0;
y = n;
nci = nan(2,length(n));

if ~isempty(spikes)
    if ~isstruct(spikes)
        %     instead of spikes you can put in
        %     a vector of spiketimes and a vector of trials
        temp.spiketimes = spikes(:,1)';
        temp.sweeps.TrialNumber = unique(spikes(:,2))';
        temp.TrialNumber = spikes(:,2)';
        spikes = temp;
    end

    % Set spiketimes
    spiketimes = spikes.spiketimes;
  
    if ~isempty(spiketimes)
        
        numtrials = length(spikes.sweeps.TrialNumber);
        
        % % Get counts
        n = histc(spiketimes,edges);
        n = n/numtrials/binsize;
        
    end
    % -- bootstrap psth
    if busebootstrap & numtrials>=3 &  ~isempty(spiketimes)
        
        % first get the binned psth for each trail
        % then bootstrap the mean of the binned psth
        t = unique(spikes.sweeps.TrialNumber);
        for itrial = 1:numtrials
            ind  = ismember(spikes.TrialNumber,t(itrial)); % ind of spikes in trial
            spiketimes = spikes.spiketimes(ind);
            temp = histc(spiketimes,edges);
            if ~isempty(temp), n_trial(itrial,:) = temp;
            else  n_trial(itrial,:) = zeros(1,length(edges)); end
        end
        
        nbootstraps = max(1000,numtrials*20);
        meanfunc = @(x) (nanmean(x));
        nci = bootci(nbootstraps,{meanfunc,n_trial},'alpha',alpha);
        nci = nci/binsize; % already devided by trials when mean was taken
    end
    
    
    if all(isnan(n))
        n = zeros(size(edges));
    end
    
    
    % Last point of n contains values falling on edge(end) -- usually zero
    if NSMOOTH  % BA bootstrap doesn't work with smoothing for now
        % TODO  to have nan support use nanconv: see addMovingAvg_dp
        %     y = smooth(n(1:end-1),3);
        %     kernel = ones(1,NSMOOTH)/NSMOOTH;
        %
        %     y = filter(kernel,1,n);
        %     nci(1,:) = filter(kernel,1,nci(1,:));
        %     nci(2,:) = filter(kernel,1,nci(2,:));
        
        kernel = getFilterFun(NSMOOTH,filttype);
        y = nanconv(n,kernel,'edge','1d') ;
        nci(1,:) = nanconv(nci(1,:),kernel,'edge','1d') ;
        nci(2,:) = nanconv(nci(2,:),kernel,'edge','1d') ;
        
        if bverbose
            s = sprintf('Smoothed over %d, %d ms Bins',NSMOOTH, binsize);
            disp(s);
        end
    else
        y = n(1:end);
    end
end
y = y(extraWOI+1:end-extraWOI); % remove extraWOI for smoothing
centers = centers(extraWOI+1:end-extraWOI);
nci = nci(:,extraWOI+1:end-extraWOI);
edges = edges(extraWOI+1:end-extraWOI);

yout = y;
if isfield(plotparam,'endline')
    if ~isempty(plotparam.endline ) % remove plot after endline
        ind = find(centers>=plotparam.endline,1,'first');
        dotted_y = y;
        dotted_nci = nci;
        dotted_y(1:ind-1) = NaN;
        dotted_nci(:,1:ind-1) = NaN;
        
        y(ind:end)= NaN;
        nci(:,ind:end)= NaN;
        
        if isfield(plotparam,'endlinedotted')
            if ~isempty(plotparam.endlinedotted ) % remove plot after endline
                ind = find(centers>=plotparam.endlinedotted,1,'first');
                
                dotted_y(ind:end)= NaN;
                dotted_nci(:,ind:end)= NaN;
            end
        end
        
        if bplot
            % plot line and boostrapped confidence
            [hPsthDot, hPsthpatchDot] = boundedline(centers(1:end)',dotted_y',zeros(size(dotted_y)),hAxes,'alpha','transparency',0.2);
            set(hPsthDot,'LineWidth',1.5,'Linestyle',':');
            % prepare vectors that loop around the patch
            tempx =  [centers(1:end-1) centers(end-1:-1:1)];
            tempy = [dotted_nci(1,1:end-1) dotted_nci(2,end-1:-1:1)];
            set(hPsthpatchDot,'YData',tempy,'Xdata',tempx)
            if isfield(plotparam,'scolor')
                setColor(hPsthDot,plotparam.scolor);
                setColor(hPsthpatchDot,plotparam.scolor);
            end
            
        end
    end
    
    
end

hPsth = [];hPsthpatch = [];
if bplot
    % plot line and boostrapped confidence
    [hPsth, hPsthpatch] = boundedline(centers(1:end)',y',zeros(size(y)),hAxes,'alpha','transparency',0.2);
    set(hPsth,'LineWidth',1.5);
    % prepare vectors that loop around the patch
    tempx =  [centers(1:end-1) centers(end-1:-1:1)];
    tempy = [nci(1,1:end-1) nci(2,end-1:-1:1)];
    set(hPsthpatch,'YData',tempy,'Xdata',tempx)
    
    % Set default axes properties
    if sum(n) == 0
        maxN = 0.1;
    else
        maxN = max([y nci(2,:)]);
    end
    
    if ~isempty(spiketimes), axis(hAxes,[-WOI(1) WOI(2) 0 maxN]);  end
    
    set(hAxes,'TickDir','out','FontSize',9)
    xlabel(hAxes,'seconds')
    ylabel(hAxes,'spikes/s')
end

if isfield(plotparam,'scolor')
    setColor(hPsth,plotparam.scolor);
    setColor(hPsthpatch,plotparam.scolor);
end
% Outputs
varargout{1} = hPsth;
varargout{2} = hAxes;
varargout{3} = yout;
varargout{4} = centers;
varargout{5} = edges;
varargout{6} = hPsthpatch;
varargout{7} = nci;