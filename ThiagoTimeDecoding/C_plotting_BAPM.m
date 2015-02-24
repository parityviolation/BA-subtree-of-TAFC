% clear all
% close all
% clc

% neurTAFCm_SharedVariables
% common.lwid = common.lwid/2;

% load myTAFC
% load MLE-PRE
%%
% cor = load('myTAFC_sudopop8_Correct');
% incor = load('myTAFC_sudopop8_Incorrect');
bounds = [-1 3]*1000;
bin = 500;
step = 50;
stepsize = bin/step;
nBins = diff(bounds)/stepsize+1;

% Intervals = common.intSet;
Intervals = [.35 .65];

alpha = 1;
scale = 1;
imticks = round((pvar.time_xtick-bounds(1))/diff(bounds)*(nBins-1)+1); % for step==20ms

hf(1) = figure('name','Decoding time - Big Rat','units','centimeters','position',[2 5 12 12]*scale,'DefaultAxesunits','centimeters');
set(hf(1),'DefaultAxestickdir','out','DefaultAxesfontname','Liberation Sans',...
    'DefaultAxesfontsize',8, 'DefaultAxesBox','off','DefaultAxesTickLength',pvar.tick_length);

T = linspace(min(bounds),max(bounds),nBins);

% lim = [min(T) max(T(T <= Intervals(7)*3000))];
% lim_amp = diff(lim);
% lim(1) = lim(1)-lim_amp*.05;
% lim(2) = lim(2)+lim_amp*.05;

% i = find(cv==max(cv));
i = Intervals(2);
C = pvar.colorc;
a = 1; % Only 1 animal

tNdx = find(T <= i*3000);
%     tNdx = find(T >=0 & T <= i*3000);
nBinsI = length(tNdx);

%lim = [min(T(tNdx)) max(T(tNdx))];
lim = [min(T(tNdx)) max(T(tNdx))];
lim_amp = diff(lim);
lim(1) = lim(1)-lim_amp*.05;
lim(2) = lim(2)+lim_amp*.05;

%     cmC = nan(size(cor.MLE,3),length(cor.MLE{a,1}.cm));
%     maxS = nan(size(cor.MLE,3),length(cor.MLE{a,1}.max));
%     cmE = nan(size(cor.MLE,3),length(cor.MLE{a,1}.cm));
%     maxL = nan(size(cor.MLE,3),length(cor.MLE{a,1}.max));
%     for n = 1:size(cor.MLE,3)
%         cmC(n,:) = cor.MLE{a,n}.cm;
%         maxS(n,:) = cor.MLE{a,n}.max;
%         cmE(n,:) = incor.MLE{a,n}.cm;
%         maxL(n,:) = incor.MLE{a,n}.max;
%     end

if i > 0.5
    cmL = MLE{a,Intervals==i}.choiceP.cm(:,tNdx);
    cmS = MLE{a,Intervals==i}.choiceE.cm(:,tNdx);
    maxL = MLE{a,Intervals==i}.choiceP.max(:,tNdx);
    maxS = MLE{a,Intervals==i}.choiceE.max(:,tNdx);
    matL = MLE{a,Intervals==i}.choiceP.mat(tNdx,tNdx,:);
    matS = MLE{a,Intervals==i}.choiceE.mat(tNdx,tNdx,:);
else
    cmL = MLE{a,Intervals==i}.choiceE.cm(:,tNdx);
    cmS = MLE{a,Intervals==i}.choiceP.cm(:,tNdx);
    maxL = MLE{a,Intervals==i}.choiceE.max(:,tNdx);
    maxS = MLE{a,Intervals==i}.choiceP.max(:,tNdx);
    matL = MLE{a,Intervals==i}.choiceE.mat(tNdx,tNdx,:);
    matS = MLE{a,Intervals==i}.choiceP.mat(tNdx,tNdx,:);
end

%% Maximum
ha(1) = axes('tickdir','out','position',[1 6 4 4]*scale,'xtick',pvar.time_xtick,...
    'ytick',pvar.time_xtick,'xticklabel',pvar.time_xticklabel,'xlim',lim,'ylim',lim,'box','off','tickdir','out');
hold on
%         patch([0 [i i]*3000 0],[0 0 [i i]*3000],[1 1 1]*.75,'edgecolor','none')

xS = (maxS-1)/(nBinsI-1)*(i*3000-bounds(1)) + bounds(1);
xL = (maxL-1)/(nBinsI-1)*(i*3000-bounds(1)) + bounds(1);

patch([T(tNdx) fliplr(T(tNdx))],[nanmean(xL)-nanstd(xL) fliplr(nanmean(xL)+nanstd(xL))],...
    pvar.colorc_patch(1,:),'edgecolor','none','facealpha',alpha)
patch([T(tNdx) fliplr(T(tNdx))],[nanmean(xS)-nanstd(xS) fliplr(nanmean(xS)+nanstd(xS))],...
    pvar.colorc_patch(3,:),'edgecolor','none','facealpha',alpha)

plot(T(tNdx),nanmean(xL),'linewidth',common.lwid*scale,'color',pvar.colorc(1,:),'linewidth',common.lwid)
plot(T(tNdx),nanmean(xS),'linewidth',common.lwid*scale,'color',pvar.colorc(3,:),'linewidth',common.lwid)

set(ha(1),'xtick',pvar.time_xtick,'ytick',pvar.time_xtick,'xticklabel',pvar.time_xticklabel,...
    'xlim',lim,'ylim',lim,'box','off','tickdir','out')

set(gca,'xticklabel',pvar.time_xticklabel,'yticklabel',pvar.time_xticklabel)
ylabel 'Decoded time (s)'
title Max
xlabel 'Real time (s)'
axis square

%% Mean
ha(2) = axes('tickdir','out',...
    'position',[6 6 4 4]*scale);
hold on
%patch([0 [i i]*3000 0],[0 0 [i i]*3000],[1 1 1]*.75,'edgecolor','none')

xS = (cmS-1)/(nBinsI-1)*(i*3000-bounds(1)) + bounds(1);
xL = (cmL-1)/(nBinsI-1)*(i*3000-bounds(1)) + bounds(1);

patch([T(tNdx) fliplr(T(tNdx))],[nanmean(xL)-nanstd(xL) fliplr(nanmean(xL)+nanstd(xL))],...
    pvar.colorc_patch(1,:),'edgecolor','none','facealpha',alpha)
patch([T(tNdx) fliplr(T(tNdx))],[nanmean(xS)-nanstd(xS) fliplr(nanmean(xS)+nanstd(xS))],...
    pvar.colorc_patch(3,:),'edgecolor','none','facealpha',alpha)

plot(T(tNdx),nanmean(xL),'linewidth',common.lwid*scale,'color',pvar.colorc(1,:),'linewidth',common.lwid)
plot(T(tNdx),nanmean(xS),'linewidth',common.lwid*scale,'color',pvar.colorc(3,:),'linewidth',common.lwid)

set(ha(2),'xtick',pvar.time_xtick,'ytick',pvar.time_xtick,'xticklabel',pvar.time_xticklabel,...
    'xlim',lim,'ylim',lim,'box','off','tickdir','out')

set(gca,'xticklabel',pvar.time_xticklabel,'yticklabel',[])
title Mean
xlabel 'Real time (s)'
axis square

%% Posteriors
C = [0 .05];
ha(3) = axes('tickdir','out','position',[1 1 4 4]*scale);
imagesc(mean(matL,3)',C);
set(ha(3),'xtick',imticks,'ytick',imticks,'xticklabel',pvar.time_xticklabel,'yticklabel',pvar.time_xticklabel,...
    'box','off','tickdir','out')
title Long
xlabel 'Real time (s)'
axis square tight xy

ha(4) = axes('tickdir','out','position',[6 1 4 4]*scale);
imagesc(mean(matS,3)',C);
set(ha(4),'xtick',imticks,'ytick',imticks,'xticklabel',pvar.time_xticklabel,'yticklabel',[],...
    'box','off','tickdir','out')
title Short
xlabel 'Real time (s)'
axis square tight xy