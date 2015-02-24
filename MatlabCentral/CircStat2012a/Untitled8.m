bin = 20;
r = brigdefs;

% bIntervalGTX = 0;
%       savenameheader = 'CorrectVsError';  
%     cond(1).name = 'Correct' ;
%     cond(1).color = [0 1 0];
%     cond(1).filter = {'ChoiceCorrect',1};
%     cond(1).offset = 0 ;
%     cond(1).style = 'og';
%     cond(2).name = 'Error' ;
%     cond(2).color = [1 0 0];
%     cond(2).style = 'or';
%     cond(2).filter = {'ChoiceCorrect',0};
%     cond(2).offset = 0 ;
% 
% bIntervalGTX = 1;
% savenameheader = 'StimVsCtrl';
% cond(1).name = 'Ctrl' ;
% cond(1).color = [0 0 0];
%     cond(1).style = 'ok';
% cond(1).filter = {'stimulationOnCond',0};
% cond(1).offset = 0 ;
% cond(2).name = 'Stim' ;
% cond(2).color = [0 0 1];
%     cond(2).style = 'ob';
% cond(2).filter = {'stimulationOnCond',@(x) x~=0};
% cond(2).offset = 0 ;
% 
%     
    savenameheader = 'StimCorrectVsCtrlCorrect';
bIntervalGTX = 1;
        cond(1).name = 'Ctrl' ;
    cond(1).color = [0 0 0];
    cond(1).style = 'ok';
    cond(1).filter = {'stimulationOnCond',0,'ChoiceCorrect',1};
    cond(1).offset = 0 ;
    cond(2).name = 'Stim' ;
    cond(2).color = [0 0 1];
    cond(2).style = 'ob';
    cond(2).filter = {'stimulationOnCond',@(x) x~=0,'ChoiceCorrect',1};
    cond(2).offset = 0 ;

% savenameheader = 'StimErrorVsCtrlError';
% bIntervalGTX = 1;
% cond(1).name = 'Ctrl' ;
% cond(1).color = [0 0 0];
% cond(1).style = 'ok';
% cond(1).filter = {'stimulationOnCond',0,'ChoiceCorrect',0};
% cond(1).offset = 0 ;
% cond(2).name = 'Stim' ;
% cond(2).color = [0 0 1];
% cond(2).style = 'ob';
% cond(2).filter = {'stimulationOnCond',@(x) x~=0,'ChoiceCorrect',0};
% cond(2).offset = 0 ;

% 
    savename = ['_TrajTheta_ByInterval' source];

radOffset = 0; % just for visualization 
% dpC2.polarTrajTone2(1,:)  = dpC2.polarTrajTone2(1,:) - nanmean(dpC2.polarTrajTone2(1,:)  );
avgfun = @circ_median;
statfun = @circ_wwtest;
nboot = 1;

hfig.h = figure('Name',savenameheader,'NumberTitle','off');clf;
intervalSet = dpC2.IntervalSet;
nc = length(intervalSet)/2;
nr = 2;

for iIntv = 1:length(intervalSet)
    for icond = 1 : length(cond)
        thisInterval = intervalSet(iIntv);
        
        if bIntervalGTX
            intervalCond.filter = {'Interval', @(x) x>=thisInterval*0.99};
        else
            intervalCond.filter = {'Interval', thisInterval};
        end
        thisfilter ={cond(icond).filter{:} intervalCond.filter{:}}; % add the interval filter
        
        tempdp= filtbdata(dpC2,0,thisfilter);
        
        hfig.hsp(iIntv) = subplot(nr,nc,iIntv);
        
        thet{icond} = tempdp.polarTrajTone2(:,1)+radOffset;
        thet{icond}(isnan( thet{icond})) = [];
        
        if 0
        [a x] = hist( rad2deg(thet{icond}),bin);
        a = a/sum(a);
        h(iIntv,icond) = stairs(x,a,'color',cond(icond).color); hold on;
        else
          circ_plot(thet{icond},'pretty',cond(icond).style,true,'linewidth',2,'color',cond(icond).color); hold on
        end

%         avg = avgfun(thet{icond});
%         
%         hfig.hsp(iIntv) = subplot(nr,nc,length(intervalSet)+iIntv);
%         hpol = polar(thet{icond},ones(size(thet{icond}))); hold on;
%         set(hpol,'LineStyle','none','Marker','o','color',cond(icond).color);
%         
%         hpolavg = polar(avg,1); hold on;
%         set(hpolavg,'LineStyle','none','Marker','*','MarkerSize',30,'color',cond(icond).color);
% 

    end
    s = '';
    if bIntervalGTX, s = '>='; end
    
    pval = statfun( thet{1},thet{2});
            title([ 'Intv' s num2str(thisInterval*dpC2.Scaling/1000,'%1.1f') 's' ' p = ' num2str(pval,'%1.2g')])   
end

plotAnn([savenameheader ' ' savename ' ' dpC2.FileName],hfig.h,1)

try
    if ~isempty(hfig.h)
        patht = fullfile(r.Dir.SummaryFig,'TrajectoryTheta',dpC2.Animal,dpC2.Date);
        parentfolder(patht,1);
        export_fig(hfig.h, fullfile(patht, [savenameheader '_' dpC2.FileName '_' savename]),'-pdf','-transparent');
    end
catch ME
    getReport(ME)
end