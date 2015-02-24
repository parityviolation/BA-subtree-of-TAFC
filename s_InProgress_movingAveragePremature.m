
% [dpArray]= dpArrayInputHelper(varargin{1:min(length(varargin),2)});
% sAnnot =  dpArray(1).collectiveDescriptor ;

% 
% sAnnot = [ savefileHeader '_' sAnnot];
% 
% 
bsave =1;

r = brigdefs;
options.filttype = 'flat';
options.filterlength = 30;
clear s p
% for each session correlate  premature with choices%
for isession = 1 : length(thisAnimal)
    thisSession =  thisAnimal(isession);
    thisSession = addMovingAvg_dp(thisSession,options);
    
    nonNaNIdx = ~isnan(thisSession.movingAvg.ChoiceLeft) & ~isnan(thisSession.movingAvg.Premature);
   [ temp tempp] = corrcoef(thisSession.movingAvg.ChoiceLeft(nonNaNIdx),thisSession.movingAvg.Premature(nonNaNIdx));
    s(isession) = temp(1,2);
        p(isession) = tempp(1,2);
end

significant = p'<=0.05;

hfig = figure;
% plotScatterSig([ones(size(s')) s' ],significant)

bins = 8;
[a x] =hist(s,bins);
bar(x,a,'FaceColor','none'); hold all
[a x] =hist(s(significant),x);
bar(x,a,'FaceColor',[1 1 1].*0.5,'LineStyle','none')
title('ChoiceLong Correlated Premature')
yl =ylim;
% line([1 1].*nanmedian(s(significant)),yl,'color','k','linewidth',3);
% line([1 1].*nanmedian(s),yl,'color','k');



sAnnot =  thisSession.Animal ;
plotAnn(sAnnot);
savefiledesc = [sAnnot 'CC_LeftAndPremature'];

% 
%  

if bsave
    patht = fullfile(r.Dir.SummaryFig,'PreMatureEtc',thisSession.Animal);
    parentfolder(patht,1)
    export_fig(hfig, fullfile(patht,[savefiledesc]),'-pdf','-transparent');
    saveas(hfig, fullfile(patht,[savefiledesc '.fig']));
end