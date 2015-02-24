% plot average session time course




nmax = 3000;
nSessions = length(thisAnimal);
for isession = 1 : nSessions
    thisSession = thisAnimal(isession);
    thisSession = addMovingAvg_dp(thisSession,options);
    ntrials(isession) = thisSession.ntrials;
    
    fldnames = fieldnames(thisSession.movingAvg);
    for ifld = 1:length(fldnames)
        if length(thisSession.movingAvg.(fldnames{ifld})) == ntrials(isession)
            trialInterp = [1:(ntrials(isession)-1)/(nmax-1):ntrials(isession)];
            allSession.(fldnames{ifld})(isession,:) = interp1(1:ntrials(isession),thisSession.movingAvg.(fldnames{ifld}),trialInterp);
        end
    end
end

%%
hfig = figure
fld = {'ChoiceCorrectNaN','PrematureNaN','timeToTrialInit','ChoiceLeftIncludingPM','stimulationOnCond'};
mycolor = {'b','k','g','r','c'};
norm = [0 0 1 0 0];
mfun = @nanmean;
clear sleg hPsth;
for ifldplot = 1:length(fld)
    % plot line and boostrapped confidence
    y = mfun(allSession.(fld{ifldplot}));
    nfactor = 1;
    if norm(ifldplot), nfactor = max(y);  end
    y = y/nfactor;
    ye = nansem(allSession.(fld{ifldplot}))/nfactor;
[hPsth(ifldplot), hPsthpatch] = boundedline(1:nmax,y,ye,'alpha','transparency',0.2);
setColor([hPsth(ifldplot), hPsthpatch],mycolor{ifldplot})
set(hPsth,'LineWidth',1.5);

    sleg{ifldplot} = fld{ifldplot};
end
title(['Average '  num2str(nSessions) ' sessions'])

legend(hPsth,sleg)
% interpolate so that all sessions are as long as the longest

sAnnot =  thisAnimal(isession).Animal ;
plotAnn(sAnnot);

% 
%  
sAnnot =  thisSession.Animal ;
plotAnn(sAnnot);
savefiledesc = [sAnnot 'PerformancePrematureEtc'];

if bsave
    patht = fullfile(r.Dir.SummaryFig,'AcrossSessions',thisSession.Animal);
    parentfolder(patht,1)
    plot2svg( fullfile(patht,[savefiledesc '.svg']),hfig);
    saveas(hfig, fullfile(patht,[savefiledesc '.fig']));
end