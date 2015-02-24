lastFrame = size(dpC2.tempallTrajTheta,2);
stepFrame = 20;

clear avgTheta; i =0
for iframe = stepFrame:stepFrame: lastFrame 
    i = i+1;
    thisTime = double(iframe)/dp.video.info.medianFrameRate
    
    intervalFilter = {'Interval',@(x) x>= thisTime/(dp.Scaling/1000)};
    for icond = 1 : length(cond)
        thisfilter ={cond(icond).filter{:} intervalFilter{:}}; % add the interval filter
    end
    dpTemp= filtbdata(dpC2,0,thisfilter);
    
    
    
    theta = dpTemp.tempallTrajTheta(:,iframe,1);
   
    theta(isnan(theta)) = [];
    avgTheta(i,icond) = avgfun(theta); 
    tim(i) = thisTime;
end
