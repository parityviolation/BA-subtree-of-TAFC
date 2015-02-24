function [roc] = unitROC(spikes,WOI,options,bplot)
% function h = plotAlignedByIntervalOverLay_spikes(spikes,alignEvent,ElectUnit,options)
%
% plots Raster and PSTH for each stimulus interval aligned on alignEvents

r = brigdefs;
cond = options.cond;
syncEvent = 'TrialAvail';
syncEventEphys = 'TrialAvailEphys';

tempoptions.syncEventEphys = syncEventEphys;
tempoptions.syncEvent = syncEvent;
myColor = copper(length(cond));

spikes_unit = filtspikes(spikes,0,cond.spikesf);

if ~exist('bplot','var')
    bplot = 0;
end

%%

for icond = 1:length(cond)
    filt_spikes = filtspikes(spikes_unit,1,{},cond(icond).sweepsf);
    [spikeTimeRelativeToEvent trials] = relativeSpiketimes_spikes(filt_spikes,cond(icond).alignEvent,[WOI(1) WOI(2)],tempoptions);
    trialsUnique = unique(trials);
    cond(icond).trials = trialsUnique;
    nTrials(icond) = length(cond(icond).trials);  %number of trials
    
    for itrial = 1:length(trialsUnique)
        trial_ind = trials==trialsUnique(itrial);
        
        these_spikes = spikeTimeRelativeToEvent(trial_ind);
        cond(icond).spikeCounts(itrial) = sum(~isnan(these_spikes));
        
    end
    %[hist(icond).vect,hist(icond).bins] = hist(spikeCounts(icond,:));
    %if sum(cond(icond).spikeCounts==0)>0
        cond(icond).bins = [0:max(cond(icond).spikeCounts)];
    %else
       
    %end
    [cond(icond).his] = hist(cond(icond).spikeCounts,cond(icond).bins);
    bins(icond) = length(cond(icond).bins);
    

end


%%

figure

for icond = 1:length(cond)
    stairs([0:length(cond(icond).his)-1],cond(icond).his);
    hold all;
    
%     a = findobj(gca,'Type','patch');
%     f(icond) = a(1);
%     set(f(icond),'FaceColor',myColor(icond,:),'EdgeColor','w');
    
end


   %% 
criteria = [0:max(bins)];

for icrit = 1:length(criteria)
pHit(icrit) = sum(cond(1).his(criteria(icrit)+1:end))/nTrials(1);

% The proportion of false alarms will be the proportion of spike counts
% from the non-preferred data that exceeds the criterion:

pFA(icrit) = sum(cond(2).his(criteria(icrit)+1:end))/nTrials(2);

end

roc = [pFA; pHit];  
%%
if bplot
figure
plot(pFA,pHit,'.-');
hold on;
plot([0,1],[0,1],'k-');
axis square
end
  










%%
% [a,bins(] = hist(spikeCounts(1,:));
%  hold on;
%  hist(spikeCounts(2,:));
%  
%  
% h = findobj(gca,'Type','patch');
% display(h)
%  
% set(h(1),'FaceColor','r','EdgeColor','k');
% set(h(2),'FaceColor','g','EdgeColor','k');













% if bsave
%     %     export_fig(h.fig,fullfile(savepath,savefile),'-pdf')
%     plot2svg(fullfile(savepath,[savefile,'.svg']),h.fig)
%     saveas(h.fig,fullfile(savepath,savefile))
% end
