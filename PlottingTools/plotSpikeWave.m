function [hAx hline] = plotSpikeWave(spikes,Electrode,Unit,bplotISI,hAx)
removeBEGEND = [0.2 0.4]; % remove from waveform

if ~exist('bplotISI','var')
    bplotISI = 0;
end

if ~exist('hAx','var') 
    
    %     % create axes at the top left corner
    %     H = 0.05;
    %     W = H*1.5;
    %     hAx = axes('Position',[0.001 1-H-0.01 W H] );
    H = 0.05;
    W = H*1.5;
    hAx = axes('Position',[1-W-0.01 1-H-0.01 W H] );
    
    if bplotISI 
        hAx(2) = hAx;
        hAx(1) = axes('Position',[1-2*W-0.015 1-H-0.01 W H] );
        
        
    end
end

ind = [];
if isfield(spikes,'units')
    ind = find(spikes.units.Electrode==Electrode & spikes.units.UnitID==Unit);
end

if nargin > 2 & ~isempty(Electrode)
    spikes = filtspikes(spikes,0,{'Electrode',Electrode,'Unit',Unit});
end
if isempty(ind) % calculate mean
    wv = mean(spikes.waveforms);
else
    wv  = spikes.units.wv(ind,:);
end

wv = wv(round(removeBEGEND(1)*spikes.params.Fs/1000) : end-round(removeBEGEND(2)*spikes.params.Fs/1000) );
xtime = [1:length(wv)]*1/spikes.params.Fs*1000;
hline = line(xtime,wv,'linewidth',2,'parent',hAx(1),'color','k');

%  set(hAx,'xticklabel','','yticklabel','','box','off','color','none');
set(hAx,'ylim',[min(wv) max(wv)]*1.1,'xlim',[xtime(1) xtime(end)]);

% hscalebar = 0;
% % scalebar
% yl = get(hAx,'ylim');
% hscalebar = line([0 0.5],[1.03 1.03].*yl(1),'linewidth',1,'color','k');

set(gca,'Visible','off')

if bplotISI
    hAx(2) = plotSpikeISI(spikes,[],[],hAx(2));
    defaultAxes(hAx(2),[],[],6)
    set(hAx(2),'YTickLabel','','Color','none');
    setXLabel(hAx,'');
    setYLabel(hAx,'');
end
