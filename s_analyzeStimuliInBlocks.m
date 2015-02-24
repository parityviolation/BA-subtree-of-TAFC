% movement analysis (nothing obvious

 % ADD integral analysis
 % ADD annotation and save
 
% blocks analysis
% find first and last stimulus in stimulation block.
bsave = 1;
trialsBefAftBlock = [50 50];
nAnimal = 'sert864_since_retreat';

[exptnames trials] = getStimulatedExptnames(nAnimal);
dpArray = constructDataParsedArray(exptnames, trials);
dpconc = concdp(dpArray);

% TODO remove controlLoop trials by making NaN

nAnimal = [nAnimal '_Conc'];
savename = [nAnimal '_Stimulation_BlockAnalysis'];

r = brigdefs();


%%
[dpWOI skipped] = getTrialWOI(dpconc,startBlock(find(bstartstimBlock)),trialsBefAftBlock);
% fld = {'ChoiceCorrect','Premature','ChoiceLeft','stimulationOnCond'};
fld = {'ChoiceCorrect','Premature','ChoiceLeft','ReactionTime','timeToTrialInit','stimulationOnCond'};
mycolor = colormap(jet(length(fld)));
hf = figure('Position', [360    80   782   842]);clf;
set(hf,'Name',savename,'NumberTitle','off')
plotAnn(nAnimal)
hAx(1) = subplot(2,2,1);
title('StimBlock ON')
hAx(2) = subplot(2,2,3);

kernel_length = 10;
kernel = ones(1,kernel_length)/kernel_length;
clear val 
hl = [];
for ifld = 1:length(fld)
    val(ifld)= {structfld2mat(dpWOI,fld{ifld})};
    %     padded = [nan(size(kernel)),nanmean(val{ifld}),nan(size(kernel))];
    avg = conv(nanmean(val{ifld}),kernel,'valid');
    xtrials = [1:length(avg)]-length(avg)/2;
   hl(end +1) = line(xtrials,avg,'color',mycolor(ifld,:),'Parent',hAx(1));
    
    %     integral( x -<x>)
    temp = val{ifld};
    temp = temp- repmat(nanmean(temp')',1,size(temp,2));
    cum_avg = cumsum(nansum(temp));
    cum_avg = cum_avg/range(cum_avg);
    xtrials = [1:length(cum_avg)]-length(cum_avg)/2;
    if isempty(strfind(fld{ifld},'stimulationOnCond'));
        line(xtrials,cum_avg,'color',mycolor(ifld,:),'Parent',hAx(2));
    end
end

line([0 0], get(hAx(1),'ylim'),'color','k','linewidth',1,'Parent',hAx(1));
line([0 0], get(hAx(2),'ylim'),'color','k','linewidth',1,'Parent',hAx(2));
setXlabel(hAx(2),'trial')



[dpWOI skipped]= getTrialWOI(dpconc,startBlock(find(~bstartstimBlock)),trialsBefAftBlock);

hAx(3) = subplot(2,2,2);
title('StimBlock OFF')
hAx(4) = subplot(2,2,4);
kernel_length = 10;
kernel = ones(1,kernel_length)/kernel_length;

hl = [];
for ifld = 1:length(fld)
    val(ifld)= {structfld2mat(dpWOI,fld{ifld})};
%     padded = [nan(size(kernel)),nanmean(val{ifld}),nan(size(kernel))];
    avg = conv(nanmean(val{ifld}),kernel,'valid');
    xtrials = [1:length(avg)]-length(avg)/2;
    hl(end+1) = line(xtrials,avg,'color',mycolor(ifld,:),'Parent',hAx(3));
    
  %     integral( x -<x>)
    temp = val{ifld};
    temp = temp- repmat(nanmean(temp')',1,size(temp,2));
    cum_avg = cumsum(nansum(temp));
    cum_avg = cum_avg/range(cum_avg);
    xtrials = [1:length(cum_avg)]-length(cum_avg)/2;
     if isempty(strfind(fld{ifld},'stimulationOnCond'));
        line(xtrials,cum_avg,'color',mycolor(ifld,:),'Parent',hAx(4));
    end

end
line([0 0], get(hAx(3),'ylim'),'color','k','linewidth',1,'Parent',hAx(3));
line([0 0], get(hAx(4),'ylim'),'color','k','linewidth',1,'Parent',hAx(4));

hleg = legend(hl,fld,'Fontsize',7,'location','best');
legend boxoff;
setXLabel(hAx(4),'trial')
axis(hAx,'tight')
set(hAx([1,3]),'ylim',[0 1])
set(hAx([1,3]),'YTick',[0 1])
set(hAx,'TickDir','out')


if bsave
    orient tall
    saveas(hf, fullfile(r.Dir.SummaryFig, [savename '.pdf']));
end



