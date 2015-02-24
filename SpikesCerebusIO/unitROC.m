function [roc,Area,H] = unitROC(spikes,WOI,cond,options)
% function h = plotAlignedByIntervalOverLay_spikes(spikes,alignEvent,ElectUnit,options)
%
% plots Raster and PSTH for each stimulus interval aligned on alignEvents
r = brigdefs;
syncEvent = 'TrialAvail';
syncEventEphys = 'TrialAvailEphys';

tempoptions.syncEventEphys = syncEventEphys;
tempoptions.syncEvent = syncEvent;
myColor = copper(length(cond));

if ~exist('options','var')
    options = [];
end

bgetSignif = 0;
if nargout >= 3
    bgetSignif = 1;
end


if ~isfield(options,'bplot')
    bplot =0;
else
    bplot =options.bplot;
end



%%


if ~all(arrayfun(@(x) (isequal(x.spikesf,cond(1).spikesf)),cond))
    error(' cond(i).spikef must be equal for all i') % otherwise  relativeSpiketimes_spikes may cause errors
end

alignEvent = cond(1).alignEvent; % save time if all the align events are the same, and same unit
if all(arrayfun(@(x) (isequal(x.alignEvent,alignEvent)),cond)) &   all(arrayfun(@(x) (isequal(x.spikesf,cond(1).spikesf)),cond))
    spikes = filtspikes(spikes,0,cond(1).spikesf);
    [~, ~, ~, spikes]  = relativeSpiketimes_spikes(spikes,alignEvent,[WOI(1) WOI(2)],tempoptions);
end

for icond = 1:length(cond)
    filt_spikes = filtspikes(spikes,1,cond(icond).spikesf,cond(icond).sweepsf);
    [spikeTimeRelativeToEvent trials, spikeCountPerTrial] = relativeSpiketimes_spikes(filt_spikes,cond(icond).alignEvent,[WOI(1) WOI(2)],tempoptions);
    trialsUnique = unique(trials);
    cond(icond).trials = trialsUnique;
    nTrials(icond) = length(spikeCountPerTrial);  %number of trials
    
    if ~isempty (nTrials(icond))
        cond(icond).spikeCounts = spikeCountPerTrial;
        
        cond(icond).bins = [0:max(cond(icond).spikeCounts)];
        [cond(icond).his] = hist(cond(icond).spikeCounts,cond(icond).bins);
        bins(icond) = length(cond(icond).bins);
        
    else
        nTrials(icond)  = NaN;
        cond(icond).his = NaN;
        bins(icond) = [];
    end
    
end




%%
if ~any(isnan(nTrials(icond)))
    criteria = [0:max(bins)];
    
    for icrit = 1:length(criteria)
        pHit(icrit) = sum(cond(1).his(criteria(icrit)+1:end))/nTrials(1);
        
        % The proportion of false alarms will be the proportion of spike counts
        % from the non-preferred data that exceeds the criterion:
        
        pFA(icrit) = sum(cond(2).his(criteria(icrit)+1:end))/nTrials(2);
        
    end
    
    Area = -trapz(pFA,pHit)-0.5;
    
    
    roc = [pFA; pHit];
    
    %%
    if bplot
        figure
        plot(pFA,pHit,'.-');
        hold on;
        plot([0,1],[0,1],'k-');
        axis square
    end
    
    
    % % shuffle labels and compute signifigances
    if bgetSignif
        alpha = 0.05*100;
        shufflecriteria = criteria;
        nshuffle = 200;%
        shuffle_bins = max(bins);
        dist = [cond(1).spikeCounts cond(2).spikeCounts];
        shuffledLabels= [zeros(nTrials(1),1);ones(nTrials(2),1)];
        
        for ishuffle = 1: nshuffle
            shuffledLabels  = shuffledLabels(randperm(length(shuffledLabels)));
            shufflecond(1).spikeCounts = dist(shuffledLabels==0);
            shufflecond(2).spikeCounts = dist(shuffledLabels==1);
            for icond = 1:2
                shufflecond(icond).bins = [0:max(shufflecond(icond).spikeCounts)];
                [shufflecond(icond).his] = hist(shufflecond(icond).spikeCounts,shufflecond(icond).bins);
            end
            for icrit = 1:length(shufflecriteria)
                pHit(icrit) = sum(shufflecond(1).his(shufflecriteria(icrit)+1:end))/nTrials(1);
                
                % The proportion of false alarms will be the proportion of spike counts
                % from the non-preferred data that exceeds the criterion:
                
                pFA(icrit) = sum(shufflecond(2).his(shufflecriteria(icrit)+1:end))/nTrials(2);
                
            end
            shuffleArea(ishuffle) = -trapz(pFA,pHit)-0.5;
            
        end
        
        percentTiles = prctile(shuffleArea,[alpha 100-alpha]);
        
        if Area < percentTiles (1) | Area >percentTiles (2)
            H = 1;
        else
            H = 0;
        end
    end
    
    %%
    if bplot
        
        figure
        
        for icond = 1:length(cond)
            
            stairs([0:length(cond(icond).his)-1],cond(icond).his);
            hold all;
        end
        %     a = findobj(gca,'Type','patch');
        %     f(icond) = a(1);
        %     set(f(icond),'FaceColor',myColor(icond,:),'EdgeColor','w');
        
    end
    
    
else
    roc = [NaN NaN];
    Area = NaN;
    H = NaN;
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
