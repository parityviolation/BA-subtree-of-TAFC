clf
% lastFrame = size(dpC2.polarTraj,2);
% stepFrame = 40;
% frameSet = stepFrame:stepFrame: lastFrame ;
frameSet = round(dpC2.IntervalSet*dpC2.Scaling/1000*dpC2.video.info.medianFrameRate);
nr = 2;
nc = ceil(length(frameSet)/nr);

clear theta_all
i =0; tim = nan(lastFrame/stepFrame,1); avgTheta = nan(lastFrame/stepFrame,2);
for iframe = frameSet
    i = i+1;
    thisTime = double(iframe)/dp.video.info.medianFrameRate;
    
    intervalFilter = {'Interval',@(x) x>= thisTime/(dpC2.Scaling/1000)};
    for icond = 1 : length(cond)
        thisfilter ={cond(icond).filter{:} intervalFilter{:}}; % add the interval filter
        
        dpTemp= filtbdata(dpC2,0,thisfilter);
        theta = dpTemp.polarTraj(:,iframe,1);
        r = dpTemp.polarTraj(:,iframe,2);
        
        theta(isnan(theta)) = [];
        avgTheta(i,icond) = avgfun(theta);
        avgR(i,icond) = nanmean(r);
        
        subplot(nr,nc,i)
        if 0
            circ_plot(theta,'pretty',cond(icond).style,true,'linewidth',2,'color',cond(icond).color); hold on
        else
            t = unwrap(theta);
            [a x] = hist(t,bin);
            a = a/sum(a);
            stairs(x,a,'color',cond(icond).color);hold on;
            yl = ylim;
            line([1 1].*mean(t),yl,'color',cond(icond).color,'linewidth',3)
        end
        
        theta_all{icond,i} = theta;
        
    end
    if bIntervalGTX, s = '>='; end
    
    pval = statfun( theta_all{1,i},theta_all{2,i});
    title([ 'Intv' s num2str(thisInterval*dpC2.Scaling/1000,'%1.1f') 's' ' p = ' num2str(pval,'%1.2g')])
    
    tim(i) = thisTime;
end