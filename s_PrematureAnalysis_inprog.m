% load  a sert
% plot distribution of valid trials over intervals
% distribution of weighting times

% hazard rate
% bias time of premature.

% TO DO
% Look session by session
% look at prematures correlation with left right bias
%
rd = brigdefs;
bsave =1;
reDrawfilter = [0 1]; % used

% plot distribution of valid trials over intervals
clear cset;
iset = 0;
iset = iset+1;
cset(iset).title = 'Choice';
cset(iset).IntervalField = 'Interval';
% cset(iset).cond(1).filter = {'stimulationOnCond',0,'controlLoop', @(x) isnan(x)|x==0,'ChoiceMiss', @(x) isnan(x)|x==0};
cset(iset).cond(1).filter = {'stimulationOnCond',0,'reDraw',reDrawfilter,'ChoiceMiss', @(x) isnan(x)|x==0};
cset(iset).cond(1).trialRelativeSweepfilter = {};
% cset(iset).cond(1).filterSurvival = {'stimulationOnCond',0,'controlLoop', @(x) isnan(x)|x==0,'ChoiceMiss', @(x) isnan(x)|x==0};
cset(iset).cond(1).filterSurvival = {'stimulationOnCond',0,'reDraw', reDrawfilter,'ChoiceMiss', @(x) isnan(x)|x==0};
cset(iset).cond(1).color = 'k';
cset(1).cond(1).desc =  'ctrl';

% cset(iset).cond(2).filter = {'stimulationOnCond',[1 2 3],'controlLoop', @(x) isnan(x)|x==0,'ChoiceMiss', @(x) isnan(x)|x==0};
cset(iset).cond(2).filter = {'stimulationOnCond',[1 2 3],'reDraw', reDrawfilter,'ChoiceMiss', @(x) isnan(x)|x==0};
cset(iset).cond(2).trialRelativeSweepfilter = {};
% cset(iset).cond(2).filterSurvival = {'stimulationOnCond',[1 2 3] ,'controlLoop', @(x) isnan(x)|x==0,'ChoiceMiss', @(x) isnan(x)|x==0};
cset(iset).cond(2).filterSurvival = {'stimulationOnCond',[1 2 3],'reDraw', reDrawfilter,'ChoiceMiss', @(x) isnan(x)|x==0};
cset(iset).cond(2).color = 'b';
cset(iset).cond(2).desc = 'stim';

iset = iset+1;
cset(iset).title = 'Premature';
cset(iset).IntervalField = 'IntervalwithPM';
cset(iset).cond(1).filter = {'Premature',1,'stimulationOnCond',0,'reDraw',reDrawfilter,'ChoiceMiss', @(x) isnan(x)|x==0,'controlLoop', @(x) isnan(x)|x==0};
cset(iset).cond(1).filterSurvival = {'stimulationOnCond',[0],'reDraw',reDrawfilter,'controlLoop', @(x) isnan(x)|x==0};
cset(iset).cond(1).trialRelativeSweepfilter = {};
cset(iset).cond(1).color = 'k';
cset(iset).cond(1).desc = ' ctrl';

cset(iset).cond(2).filter = {'Premature',1,'stimulationOnCond',[1 2 3],'reDraw',reDrawfilter,'ChoiceMiss', @(x) isnan(x)|x==0,'controlLoop', @(x) isnan(x)|x==0};
cset(iset).cond(2).filterSurvival = {'stimulationOnCond',[1 2 3],'reDraw',reDrawfilter,'controlLoop', @(x) isnan(x)|x==0};
cset(iset).cond(2).trialRelativeSweepfilter = {};
cset(iset).cond(2).color = 'c';
cset(iset).cond(2).desc = ' stim';

iset = iset+1;
cset(iset).title = 'PrematureShort';
cset(iset).IntervalField = 'IntervalwithPM';
cset(iset).cond(1).filter = {'PrematureShort',1,'stimulationOnCond',0,'reDraw',reDrawfilter,'ChoiceMiss', @(x) isnan(x)|x==0,'controlLoop', @(x) isnan(x)|x==0};
cset(iset).cond(1).filterSurvival = {'stimulationOnCond',[0],'reDraw',reDrawfilter,'controlLoop', @(x) isnan(x)|x==0};
cset(iset).cond(1).trialRelativeSweepfilter = {};
cset(iset).cond(1).color = 'k';
cset(iset).cond(1).desc = ' ctrl';

cset(iset).cond(2).filter = {'PrematureShort',1,'stimulationOnCond',[1 2 3],'reDraw',reDrawfilter,'ChoiceMiss', @(x) isnan(x)|x==0,'controlLoop', @(x) isnan(x)|x==0};
cset(iset).cond(2).filterSurvival = {'stimulationOnCond',[1 2 3],'reDraw',reDrawfilter,'controlLoop', @(x) isnan(x)|x==0};
cset(iset).cond(2).trialRelativeSweepfilter = {};
cset(iset).cond(2).color = 'c';
cset(iset).cond(2).desc = ' stim';


iset = iset+1;
cset(iset).title = 'PrematureLong';
cset(iset).IntervalField = 'IntervalwithPM';
cset(iset).cond(1).filter = {'PrematureLong',1,'stimulationOnCond',0,'reDraw',reDrawfilter,'ChoiceMiss', @(x) isnan(x)|x==0,'controlLoop', @(x) isnan(x)|x==0};
cset(iset).cond(1).filterSurvival = {'stimulationOnCond',[0],'reDraw',reDrawfilter,'controlLoop', @(x) isnan(x)|x==0};
cset(iset).cond(1).trialRelativeSweepfilter = {};
cset(iset).cond(1).color = 'k';
cset(iset).cond(1).desc = ' ctrl';

cset(iset).cond(2).filter = {'PrematureLong',1,'stimulationOnCond',[1 2 3],'reDraw',reDrawfilter,'ChoiceMiss', @(x) isnan(x)|x==0,'controlLoop', @(x) isnan(x)|x==0};
cset(iset).cond(2).filterSurvival = {'stimulationOnCond',[1 2 3],'reDraw',reDrawfilter,'controlLoop', @(x) isnan(x)|x==0};
cset(iset).cond(2).trialRelativeSweepfilter = {};
cset(iset).cond(2).color = 'c';
cset(iset).cond(2).desc = ' stim';



% 
% ACROSS SESSIONS
dp = concdp(thisAnimal);
dp= prematurePsycurvHelper(dp);


options.savefileHeader = 'DistributionOfIntervalsAcrossSessions';
sAnnot = dp.collectiveDescriptor;

savefiledesc = [options.savefileHeader dp.collectiveDescriptor];



nr = length(cset);
nc = length(cset(1).cond)*3;

h.hAx = [] ;
bins  = dp.IntervalSet*dp.Scaling(end)/1000;
hfig = figure('WindowStyle','Docked','Name', [dp.collectiveDescriptor ' Interval Dist'],'NumberTitle','off','Position',[    1     1   928   477]);
clf
for iset = 1:length(cset)
    savefiledesc = [savefiledesc '_' cset(iset).title];
    for icond = 1:length(cset(iset).cond)
        
        thisfilt = cset(iset).cond(icond).filter;
        thisdp = filtbdata(dp,0,thisfilt);
        
        if 1 % side poke time
            h.hAx(end+1)  = subplot(nr,nc,(iset-1)*nc + 1);
            stitle =  'Poke Times';
            
            bins = 100;
            sidePokeTimesInTrial = (thisdp.firstSidePokeTime-thisdp.TrialInit)/1000; % sec
            
            [a x] = hist(sidePokeTimesInTrial,bins);
            
            a = a/sum(a);
            h.hst(icond) = stairs(x,a,'color',cset(iset).cond(icond).color);hold on;
            title([cset(iset).title ' ' stitle]);
            axis tight
            yl = ylim;
            line([1 1].*thisdp.Scaling(end)/1000/2,yl,'Color','k','Linestyle',':');
            
            
            h.hAx(end+1) = subplot(nr,nc,(iset-1)*nc + 2);
             title( ['Cum ' stitle]);
           plot(x,cumsum(a),'color',cset(iset).cond(icond).color); hold on;
            axis tight
            ylim([0 1]);
            yl = ylim;
            xl = xlim;
            line([1 1].*thisdp.Scaling(end)/1000/2,yl,'Color','k','Linestyle',':');
            line(xl,[0.5 0.5],'Color','k','Linestyle',':');
            
        end
        
        if 1 % hazard rate
            bins = [0:1/(length(dp.IntervalSet)*4):1]*dp.Scaling(end)/1000;
            h.hAx(end+1)  = subplot(nr,nc,(iset-1)*nc + 3);
            
            
            % probablity POKEin time step/
            %probablity didn't POKE in yet
            
            [a x] = hist(sidePokeTimesInTrial,bins);
            pdf = a/sum(a);
            
            % survivalFunction is the probablity that mouse will not poke
            % in at time t or longer (no matter if premature or not)
            dptemp = filtbdata(dp,0, cset(iset).cond(icond).filterSurvival);
            ALL_sidePokeTimesInTrial = (dptemp.firstSidePokeTime-dptemp.TrialInit)/1000;
            indNonPM = dptemp.Premature==0;
            ALL_sidePokeTimesInTrial(indNonPM) =  dptemp.Interval(indNonPM) *dp.Scaling(end)/1000; % replace poke time with Interval time on non-premature trials
            [ALLpdf x] = hist(ALL_sidePokeTimesInTrial,x);
            ALLpdf = ALLpdf/sum(ALLpdf);
            survivalFunction = 1-cumsum(ALLpdf);
   
            stitle =  'PDF & Survival';
            stairs(x,survivalFunction,'color',cset(iset).cond(icond).color); hold on;
            stairs(x,pdf,'color',cset(iset).cond(icond).color); hold on;
            axis tight
            ylim([0 1]);
            title([cset(iset).title ' ' stitle]);
            yl = ylim;
            line([1 1].*thisdp.Scaling(end)/1000/2,yl,'Color','k','Linestyle',':');               

                       h.hAx(end+1)  = subplot(nr,nc,(iset-1)*nc + 4);

            stitle =  'Hazard Rate';
            stairs(x,pdf./survivalFunction,'color',cset(iset).cond(icond).color); hold on;
            axis tight
            ylim([0 1]);
            title([cset(iset).title ' ' stitle]);
            yl = ylim;
            line([1 1].*thisdp.Scaling(end)/1000/2,yl,'Color','k','Linestyle',':');               
        end
        
        if 1 % interval
            h.hAx(end+1)  = subplot(nr,nc,(iset-1)*nc + 5);
            
            stitle = 'Intervals';
            
            bins  = dp.IntervalSet*dp.Scaling(end)/1000;
            intv = (thisdp.(cset(iset).IntervalField)*thisdp.Scaling(end))/1000; % sec
            
            [a x] = hist(intv,bins);
            a = a/sum(a);
            h.hst(icond) = stairs(x,a,'color',cset(iset).cond(icond).color);hold on;
            title([cset(iset).title ' ' stitle]);
            axis tight
                        ylim([0 1]);
            yl = ylim;
            line([1 1].*thisdp.Scaling(end)/1000/2,yl,'Color','k','Linestyle',':');
            
            
            h.hAx(end+1)  = subplot(nr,nc,(iset-1)*nc + 6);
            stairs(x,cumsum(a),'color',cset(iset).cond(icond).color); hold on;
            axis tight
            ylim([0 1]);
            
            yl = ylim;
            line([1 1].*thisdp.Scaling(end)/1000/2,yl,'Color','k','Linestyle',':');            
        end
        
        
    end
end

h.hAx= unique(h.hAx);


plotAnn(sAnnot,hfig);

if bsave
    patht = fullfile(rd.Dir.SummaryFig,'DistributionInterval',dp.Animal);
    parentfolder(patht,1)
    orient tall
    export_fig(hfig, fullfile(patht,[savefiledesc]),'-pdf','-transparent');
    saveas(hfig, fullfile(patht,[savefiledesc '.fig']));
end
