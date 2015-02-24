function [varargout] = lfpwaveformBA(lfps,hAxes,bappend)
% function [varargout] = lfpwaveformBA(lfps,hAxes,bappend)
%% FINISH COMMENTING
% INPUTS
%   spiketimes:
%   binsize:
%   duration:
%
% OUTPUTS
%   varargout{1} = hAxes:
%   varargout{2} = hl:

% 3/30/10 - BA
if nargin < 3 % if 1 then new axes will be created with same postion as hAxes
    % else data will be plotted on hAxes
    bappend = 0;
end

[nRowrast nColrast] = size(lfps);
% predefine
for iVar1 = 1:nRowrast % ROW
    for iVar2 = 1:nColrast % COL
        
        icond = (iVar1-1)*nColrast+iVar2;
    
    % create or find axes
    if exist('hAxes','var') && ~ isempty(hAxes)% will either overlay new axis with same position as hAxes, or use same plot
        if  ~bappend
            hAxes(icond) = axes('Position',get(findobj(hAxes(icond),'Type','axes'),'Position'),...
                'XAxisLocation','top',...
                'YAxisLocation','right',...
                'Color','none',...
                'XColor','k','YColor','k','Tag','psth');
        else hAxes(icond) = hAxes(icond); end
    else
        hAxes(icond) = axesmatrix(nRowrast,nColrast,icond);
    end
    set(gcf,'CurrentAxes',hAxes(icond));hold on;
    
    % create xvalues for plotting
    xtime = [1:size(lfps(iVar1,iVar2).waveforms,2)]/lfps(iVar1,iVar2).params.Fs;
    mwav = nanmean(lfps(iVar1,iVar2).waveforms,1);
    hl(icond) = line(xtime,mwav,'Parent',hAxes(icond) ,'LineWidth',1.5);
    end
end
if exist('hAxes','var') & length(hAxes)>1
    temp = ([min(cellfun(@min,get(hAxes,'YLIM'))) max(cellfun(@max,get(hAxes,'YLIM')))]);
    set(hAxes,'YLIM',temp,'box','off','FontSize',9);
    
    ind = nColrast; % index right most axis
    set(hAxes(hAxes~=hAxes(ind)),'YTickLabel',[],'YTick',[]) % hide all but 1 axis
    % hide y axes (by color)
    set(hAxes(hAxes~=hAxes(ind)),'YColor',get(gcf,'Color'))
    
end

% hide all x axis unless axparam are used
if exist('hAxes','var');
    if ~bappend,
        set(hAxes,'XTickLabel',[],'XTick',[]);
        set(hAxes,'XColor',get(gcf,'Color')); % hide x axes (by color)
        
    end
else
    ind = 2;
    set(hAxes(hAxes~=hAxes(ind)),'XTickLabel',[],'XTick',[]);
    set(hAxes(hAxes~=hAxes(ind)),'XColor',get(gcf,'Color')); % hide x axes (by color)
end

% Outputs
varargout{1} = hAxes;
varargout{2} = hl;