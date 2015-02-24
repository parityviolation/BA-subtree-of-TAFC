function h = rasterplot(data,trial,plotparam)
% function h = rasterplot(data,trial,plotparam)
% creates rasterplot of spiketime data
%
% INPUT:
%        data - Vector of relative spike times ( time in samples within each trial)
%        trial  -if vector must be same length as data (i.e. a trial for each spiketime)
%        the ydirection. length of each line is 1/maxTrial
%       % plotparam.
%               fid - figure handle <new figure>
%               scolor - default 'k' character of 1x3 vector with color
% BA 04.09.10

%%
xymark(1,:)=[0 0];	% a baton
xymark(2,:)=[-1 1];

if  nargin < 3 || isempty(plotparam) ,
    plotparam.scolor = [];
    plotparam.hAx = gca;
    plotparam.bAppend = 1;
else
    if ~isfield(plotparam,'scolor'), plotparam.scolor = []; end
    if ~isfield(plotparam,'hAx'), plotparam.hAx = gca; end
    if ~isfield(plotparam,'bAppend'), plotparam.bAppend = 1; end
end

%% plot defaults
if  isempty(plotparam.scolor), scolor = [ 0 0 0]; else scolor =plotparam.scolor; end

if plotparam.bAppend
    mydata = guidata(plotparam.hAx);
    if isempty(mydata)
        currentMaxTrial = 0;
    else
        currentMaxTrial = mydata.nTrials; %round(max( get(plotparam.hAx,'Ylim')));
    end
    trial = trial +currentMaxTrial;
else
    trial = trial +1; % because currentMaxTrial can't be less than 1
end
mydata.nTrials = max(trial); % save to axis handle for later use
guidata(plotparam.hAx,mydata);

[min(trial) max(trial)]
if ~isempty(data)
    h = linecustommarker(data,trial,xymark,[],plotparam.hAx);
    set(h,'linewidth',1,'color',scolor,'Tag','rasterline');
    set(gca,'YDir','reverse'); % so that first trial is at the top
    set(gca,'TickDir','out','FontSize',9);
    axis tight;
else h = []; end

if isempty(h), h = NaN; end % this can happen if spiketimes fed in is empty

