% filename =  'E:\Bass\ephys\copy\021514\datafile001-01.nev';
% filename =  'E:\Bass\ephys\copy\021514\datafile001.nev';
% filename =  'E:\Bass\ephys\Sert_179\test sorting sofia\022314\Sorted\datafile002-sorted-ch-39-42-60.nev';


%% plot correct and error for each stimulu
EU = [ 43 1 ;...
    39 1;...
    37 2];


filename =  'E:\Bass\ephys\copy\022514\datafile001-02.nev';
spikes  = buildSpikes2(filename,''); spikes = filtspikes(spikes,0,{'Unit',@(x) ~ismember(x,[0 255])});
filename =  'E:\Bass\ephys\copy\022614\datafile001-01.nev';
spikes = buildSpikes2(filename,'',spikes); spikes = filtspikes(spikes,0,{'Unit',@(x) ~ismember(x,[0 255])}); % concatenate
filename =  'E:\Bass\ephys\copy\022714\datafile002-01.nev';
spikes = buildSpikes2(filename,'',spikes); spikes = filtspikes(spikes,0,{'Unit',@(x) ~ismember(x,[0 255])}); % concatenate

savefile = 'E:\Bass\ephys\copy\Spikes0225-27.mat';
save(savefile,'spikes','-v7.3')
% make function that plots aligned on X all stimuli on the same plot
%% add average WAveforms
for iEU = 1:size(EU,1)
    [spikes]= addUnits_spikes(spikes, EU(iEU,:) );
end
spikesNoW = rmfield(spikes,'waveforms');



for iEU = 1:size(EU,1)
    Electrode = EU(iEU,1);
    UnitID =  EU(iEU,2);
    
    
    alignEvent = 'firstSidePokeTime';
    options.dpFieldsToPlot = {'tone2Time'};
    options.sortSweepsByARelativeToB= {'tone2Time',alignEvent};
    options.BOOTSTRAP = 1;
    options.bplotspikewave = 1;
    WOI  = [3 0.5]*1000;
    h = plotAlignedByInterval_spikes(spikesNoW,alignEvent,WOI,[Electrode UnitID],options);
    
    alignEvent = 'tone2Time';
    options.dpFieldsToPlot = {'firstSidePokeTime'};
    options.sortSweepsByARelativeToB= {'firstSidePokeTime',alignEvent};
    WOI  = [2.5 0.5]*1000;
    h = plotAlignedByInterval_spikes(spikesNoW,alignEvent,WOI,[Electrode UnitID],options);
    
    alignEvent = 'TrialInit';
    options.dpFieldsToPlot = {'firstSidePokeTime'};
    options.sortSweepsByARelativeToB= {'firstSidePokeTime',alignEvent};
    WOI  = [0.5 1]*1000;
    h = plotAlignedByInterval_spikes(spikesNoW,alignEvent,WOI,[Electrode UnitID],options);
    
    %% plot by Premature
    WOI  = [0.6 9]*1000;
    alignEvent = 'firstSidePokeTime';
    clear options cond;
    options.bsave = 0;
    options.BOOTSTRAP = 0;
    options.sDesc = 'CorrectBeforePremature';
    sAnimal = spikesNoW.sweeps.Animal;
    sDate = spikesNoW.sweeps.Date;
    options.savefile = sprintf('%s_AL%s_%sE%d_U%d%s%s',options.sDesc,alignEvent, sDate,Electrode,UnitID );
    options.dpFieldsToPlot = {};
    options.sortSweepsByARelativeToB= {'firstSidePokeTime',alignEvent};
    options.plottype = {'psth','rasterplot'};
    icond = 1;
    cond(icond).sleg = 'Cor t+1 Not PM';
    cond(icond).spikesf = {'Electrode',Electrode,'Unit',UnitID};
    cond(icond).sweepsf   = {};
     cond(icond).trialRelsweepsf   = {{0, 'ChoiceCorrect',1}};
   cond(icond).alignEvent= alignEvent; % NOTE Times must be relative to the beginning of the session
    cond(icond).plotparam.scolor = 'r';
icond = 2;
    cond(icond).sleg = 'Cor t+1 Not PM';
    cond(icond).spikesf = {'Electrode',Electrode,'Unit',UnitID};
    cond(icond).sweepsf   = {};
     cond(icond).trialRelsweepsf   = {{-1, 'ChoiceCorrect',1},{-2, 'ChoiceCorrect',1},{-3, 'ChoiceCorrect',1},{-4, 'ChoiceCorrect',1}};
   cond(icond).alignEvent= alignEvent; % NOTE Times must be relative to the beginning of the session
    cond(icond).plotparam.scolor = 'g';
%     icond = 2;
%     cond(icond).sleg = 'Cor t+1 PM';
%     cond(icond).spikesf = cond(1).spikesf;
%     cond(icond).sweepsf   = {'Premature',1};
%      cond(icond).trialRelsweepsf   = {-1, 'ChoiceCorrect',1};
%     cond(icond).alignEvent= alignEvent;
%     cond(icond).plotparam.scolor = 'k';
%     icond = 3;
%     cond(icond).sleg = 'PMShort t-1 Err';
%     cond(icond).spikesf = cond(1).spikesf;
%     cond(icond).sweepsf   = {'ChoiceCorrect',0};
%      cond(icond).trialRelsweepsf   = {1, 'PrematureShort',1};
%     cond(icond).alignEvent= alignEvent;
%     cond(icond).plotparam.scolor = 'k';
  
    h  = psthCondSpikes(spikesNoW,cond, WOI, options);
    
    set(h.hAx,'Color','none')
    set(h.hpsth(2),'Linestyle','--')
%     set(h.hpsth(3),'Linestyle',':')
    
    plotSpikeWave(spikesNoW,Electrode,UnitID,1);
    
    clear sleg; for icond =1 : length(cond),       sleg{icond} =  cond(icond).sleg; end
    hlegPsth = legend(h.hAx(1),h.hpsth,sleg);
    defaultLegend(hlegPsth,[],7)

%     if 1
%         r = brigdefs;
%         sAnimal = spikes.sweeps.Animal;
%         savepath = fullfile(r.Dir.EphysFigs,sAnimal,'PSTH');
%         parentfolder(savepath,1);
%         export_fig(h.fig,fullfile(savepath,options.savefile),'-pdf')
%         saveas(h.fig,fullfile(savepath,options.savefile))
%         disp([ 'saved to ' fullfile(savepath,options.savefile)])
%     end
%     
    %% plot by Stimulation
    WOI  = [1 0.6]*1000;
    alignEvent = 'TrialInit';
    clear options cond
    options.bsave = 0;
    options.sDesc = 'Light';
    sAnimal = spikesNoW.sweeps.Animal;
    sDate = spikesNoW.sweeps.Date;
    options.savefile = sprintf('%s_AL%s_%sE%d_U%d%s%s',options.sDesc,alignEvent, sDate,Electrode,UnitID );
    options.dpFieldsToPlot = {};
    options.sortSweepsByARelativeToB= {'firstSidePokeTime',alignEvent};
    options.plottype = {'psth','rasterplot'};
    options.BOOTSTRAP = 1;
    
    %     icond = 1;
    %     cond(icond).sleg = 'Stim';
    %     cond(icond).spikesf = {'Electrode',Electrode,'Unit',UnitID};
    %     cond(icond).sweepsf   = {'ChoiceCorrect',[0 1]};
    %     cond(icond).trialRelsweepsf   = {1 'stimulationOnCond',@(x) x~=0};
    %     cond(icond).alignEvent= alignEvent; % NOTE Times must be relative to the beginning of the session
    %     cond(icond).plotparam.scolor = 'b';
    %     icond = 2;
    %     cond(icond).sleg = 'Ctrl';
    %     cond(icond).spikesf = cond(1).spikesf;
    %     cond(icond).sweepsf   = {'ChoiceCorrect',[0 1]};
    %     cond(icond).trialRelsweepsf   = {1 'stimulationOnCond',0};
    %     cond(icond).alignEvent= alignEvent;
    %     cond(icond).plotparam.scolor = 'k';
    %
        options.sDesc = 'LightOnPM';
     icond = 1;
    cond(icond).sleg = 'Stim t-1 PM';
    cond(icond).spikesf = {'Electrode',Electrode,'Unit',UnitID};
    cond(icond).sweepsf   = {'Premature',1};
    cond(icond).trialRelsweepsf   = {0, 'stimulationOnCond',@(x) x~=0};
    cond(icond).alignEvent= alignEvent; % NOTE Times must be relative to the beginning of the session
    cond(icond).plotparam.scolor = 'b';
    icond = 2;
    cond(icond).sleg = 'Ctrl t-1  PM';
    cond(icond).spikesf = cond(1).spikesf;
    cond(icond).sweepsf   = {'Premature',1};
    cond(icond).trialRelsweepsf   = {0, 'stimulationOnCond',0};
    cond(icond).alignEvent= alignEvent;
    cond(icond).plotparam.scolor = 'k';
%     
%     icond = 1;
%     cond(icond).sleg = 'Stim t-1 Cor';
%     cond(icond).spikesf = {'Electrode',Electrode,'Unit',UnitID};
%     cond(icond).sweepsf   = {'ChoiceCorrect',[1 0],'ChoiceLeft',[0 1]};
%     cond(icond).trialRelsweepsf   = {1, 'stimulationOnCond',@(x) x~=0};
%     cond(icond).alignEvent= alignEvent; % NOTE Times must be relative to the beginning of the session
%     cond(icond).plotparam.scolor = 'b';
%     icond = 2;
%     cond(icond).sleg = 'Ctrl t-1  Cor';
%     cond(icond).spikesf = cond(1).spikesf;
%     cond(icond).sweepsf   = {'ChoiceCorrect',1 ,'ChoiceLeft',[0 1]};
%     cond(icond).trialRelsweepsf   = {1, 'stimulationOnCond',0};
%     cond(icond).alignEvent= alignEvent;
%     cond(icond).plotparam.scolor = 'k';
%     icond = 3;
%     cond(icond).sleg = 'Stim t-1 Err';
%     cond(icond).spikesf = {'Electrode',Electrode,'Unit',UnitID};
%     cond(icond).sweepsf   = {'ChoiceCorrect',0 ,'ChoiceLeft',[0 1]};
%     cond(icond).trialRelsweepsf   = {1, 'stimulationOnCond',@(x) x~=0};
%     cond(icond).alignEvent= alignEvent; % NOTE Times must be relative to the beginning of the session
%     cond(icond).plotparam.scolor = 'b';
%     icond = 4;
%     cond(icond).sleg = 'Ctrl t-1 Err';
%     cond(icond).spikesf = cond(1).spikesf;
%     cond(icond).sweepsf   = {'ChoiceCorrect',0 ,'ChoiceLeft',[0 1]};
%     cond(icond).trialRelsweepsf   = {1, 'stimulationOnCond',0};
%     cond(icond).alignEvent= alignEvent;
%     cond(icond).plotparam.scolor = 'k';
    
    h  = psthCondSpikes(spikesNoW,cond, WOI, options);
%     set(h.hpsth(3:4),'Linestyle','--')
    
    clear sleg; for icond =1 : length(cond),       sleg{icond} =  cond(icond).sleg; end
    hlegPsth = legend(h.hAx(1),h.hpsth,sleg);
    defaultLegend(hlegPsth,[],7)
    
    set(h.hAx,'Color','none')
    plotSpikeWave(spikesNoW,Electrode,UnitID,1);
    
    
    if 1
        r = brigdefs;
        sAnimal = spikes.sweeps.Animal;
        savepath = fullfile(r.Dir.EphysFigs,sAnimal,'PSTH');
        parentfolder(savepath,1);
        export_fig(h.fig,fullfile(savepath,options.savefile),'-pdf')
        %         plot2svg(fullfile(savepath,options.savefile),h.fig)
        saveas(h.fig,fullfile(savepath,options.savefile))
        disp([ 'saved to ' fullfile(savepath,options.savefile)])
    end
    %% plot by CORRECT / ERROR
    clear options cond;
    options.sDesc = 'RewardedTrial';
    
    WOI  = [0.5 9]*1000;
    alignEvent = 'firstSidePokeTime';
    options.bsave =0;
    sAnimal = spikesNoW.sweeps.Animal;
    sDate = spikesNoW.sweeps.Date;
    options.savefile = sprintf('%s_AL%s_%sE%d_U%d%s%s',options.sDesc,alignEvent, sDate,Electrode,UnitID );
    options.sortSweepsByARelativeToB= {'firstSidePokeTime',alignEvent};
    options.plottype = {'psth','rasterplot'};
    options.BOOTSTRAP = 1;
    options.dpFieldsToPlot = {'TrialInit'};
    options.dpFieldsToPlotColor = {'k'};
    
    icond = 1;
    cond(icond).sleg = 'L Cor Choice';
    cond(icond).spikesf = {'Electrode',Electrode,'Unit',UnitID};
    cond(icond).sweepsf   = {'ChoiceLeft',1,'ChoiceCorrect',1};
    cond(icond).trialRelsweepsf   = {};
    cond(icond).alignEvent= alignEvent; % NOTE Times must be relative to the beginning of the session
    cond(icond).plotparam.scolor = 'g';
    icond = 2;
    cond(icond).sleg = 'L Err Choice';
    cond(icond).spikesf = {'Electrode',Electrode,'Unit',UnitID};
    cond(icond).sweepsf   = {'ChoiceLeft',1,'ChoiceCorrect',0};
    cond(icond).trialRelsweepsf   = {};
    cond(icond).alignEvent= alignEvent; % NOTE Times must be relative to the beginning of the session
    cond(icond).plotparam.scolor = 'r';
    icond = 3;
    cond(icond).sleg = 'R Cor Choice';
    cond(icond).spikesf = cond(1).spikesf;
    cond(icond).sweepsf   = {'ChoiceLeft',0,'ChoiceCorrect',1};
    cond(icond).trialRelsweepsf   ={};
    cond(icond).alignEvent= alignEvent;
    cond(icond).plotparam.scolor = 'g';
    icond = 4;
    cond(icond).sleg = 'R Err Choice';
    cond(icond).spikesf = cond(1).spikesf;
    cond(icond).sweepsf   = {'ChoiceLeft',0,'ChoiceCorrect',0};
    cond(icond).trialRelsweepsf   = {};
    cond(icond).alignEvent= alignEvent;
    cond(icond).plotparam.scolor = 'r';
    h  = psthCondSpikes(spikesNoW,cond, WOI, options);
    set(h.hpsth(3:4),'Linestyle','--')
    
    set(h.hAx,'Color','none')
    
    plotSpikeWave(spikesNoW,Electrode,UnitID,1);
    % add Legend
    clear sleg; for icond =1 : length(cond),       sleg{icond} =  cond(icond).sleg; end
    hlegPsth = legend(h.hAx(1),h.hpsth,sleg);
    defaultLegend(hlegPsth,[],7)
    
    if 1
        r = brigdefs;
        sAnimal = spikes.sweeps.Animal;
        savepath = fullfile(r.Dir.EphysFigs,sAnimal,'PSTH');
        parentfolder(savepath,1);
        export_fig(h.fig,fullfile(savepath,options.savefile),'-pdf')
        saveas(h.fig,fullfile(savepath,options.savefile))
        disp([ 'saved to ' fullfile(savepath,options.savefile)])
    end
    %% plot by LEft RIGHT
    WOI  = [3 0.5]*1000;
    alignEvent = 'TrialInit';
    clear options cond;
    options.bsave =0;
    options.sDesc = 'CorrectTrialAfterChoice';
    sAnimal = spikesNoW.sweeps.Animal;
    sDate = spikesNoW.sweeps.Date;
    options.savefile = sprintf('%s_AL%s_%sE%d_U%d%s%s',options.sDesc,alignEvent, sDate,Electrode,UnitID );
    options.dpFieldsToPlot = {};
    options.sortSweepsByARelativeToB= {'firstSidePokeTime',alignEvent};
    options.plottype = {'psth','rasterplot'};
    options.BOOTSTRAP = 1;
    icond = 1;
    cond(icond).sleg = 't+1 L Cor Choice';
    cond(icond).spikesf = {'Electrode',Electrode,'Unit',UnitID};
    cond(icond).sweepsf   = {'ChoiceLeft',1,'ChoiceCorrect',1};
    cond(icond).trialRelsweepsf   = {1,'ChoiceCorrect',1};
    cond(icond).alignEvent= alignEvent; % NOTE Times must be relative to the beginning of the session
    cond(icond).plotparam.scolor = 'g';
    icond = 2;
    cond(icond).sleg = 't+1 L Err Choice';
    cond(icond).spikesf = {'Electrode',Electrode,'Unit',UnitID};
    cond(icond).sweepsf   = {'ChoiceLeft',1,'ChoiceCorrect',0};
    cond(icond).trialRelsweepsf   = {1,'ChoiceCorrect',1};
    cond(icond).alignEvent= alignEvent; % NOTE Times must be relative to the beginning of the session
    cond(icond).plotparam.scolor = 'r';
    icond = 3;
    cond(icond).sleg = 't+1 R Cor Choice';
    cond(icond).spikesf = cond(1).spikesf;
    cond(icond).sweepsf   = {'ChoiceLeft',0,'ChoiceCorrect',1};
    cond(icond).trialRelsweepsf   = {1,'ChoiceCorrect',1};
    cond(icond).alignEvent= alignEvent;
    cond(icond).plotparam.scolor = 'g';
    icond = 4;
    cond(icond).sleg = 't+1 R Cor Choice';
    cond(icond).spikesf = cond(1).spikesf;
    cond(icond).sweepsf   = {'ChoiceLeft',0,'ChoiceCorrect',0};
    cond(icond).trialRelsweepsf   = {1,'ChoiceCorrect',1};
    cond(icond).alignEvent= alignEvent;
    cond(icond).plotparam.scolor = 'r';
    h  = psthCondSpikes(spikesNoW,cond, WOI, options);
    set(h.hpsth(3:4),'Linestyle','--')
    
    set(h.hAx,'Color','none')
    
    plotSpikeWave(spikesNoW,Electrode,UnitID,1);
    % add Legend
    clear sleg; for icond =1 : length(cond),       sleg{icond} =  cond(icond).sleg; end
    hlegPsth = legend(h.hAx(1),h.hpsth,sleg);
    defaultLegend(hlegPsth,[],7)
    
    if 1
        r = brigdefs;
        sAnimal = spikes.sweeps.Animal;
        savepath = fullfile(r.Dir.EphysFigs,sAnimal,'PSTH');
        parentfolder(savepath,1);
        export_fig(h.fig,fullfile(savepath,options.savefile),'-pdf')
        saveas(h.fig,fullfile(savepath,options.savefile))
        disp([ 'saved to ' fullfile(savepath,options.savefile)])
    end
end


%% multiple correct in a row

  WOI  = [3 0.5]*1000;
    alignEvent = 'TrialInit';
    clear options cond;
    options.bsave =0;
    options.sDesc = 'CorrectTrialAfterChoice';
    sAnimal = spikesNoW.sweeps.Animal;
    sDate = spikesNoW.sweeps.Date;
    options.savefile = sprintf('%s_AL%s_%sE%d_U%d%s%s',options.sDesc,alignEvent, sDate,Electrode,UnitID );
    options.dpFieldsToPlot = {};
    options.sortSweepsByARelativeToB= {'firstSidePokeTime',alignEvent};
    options.plottype = {'psth','rasterplot'};
    options.BOOTSTRAP = 1;
    icond = 1;
    cond(icond).sleg = 't+1 L Cor Choice';
    cond(icond).spikesf = {'Electrode',Electrode,'Unit',UnitID};
    cond(icond).sweepsf   = {};
    cond(icond).trialRelsweepsf   = {{-1,'ChoiceCorrect',1},{-2,'ChoiceCorrect',0},{-3,'ChoiceCorrect',0},{-4,'ChoiceCorrect',0}};
    cond(icond).alignEvent= alignEvent; % NOTE Times must be relative to the beginning of the session
    cond(icond).plotparam.scolor = 'rr';
    icond = 2;
    cond(icond).sleg = 't+1 L Err Choice';
    cond(icond).spikesf = {'Electrode',Electrode,'Unit',UnitID};
    cond(icond).sweepsf   = {'ChoiceLeft',1,'ChoiceCorrect',0};
    cond(icond).trialRelsweepsf   = {{-1,'ChoiceCorrect',1},{-2,'ChoiceCorrect',1},{-3,'ChoiceCorrect',0},{-4,'ChoiceCorrect',0}};
    cond(icond).alignEvent= alignEvent; % NOTE Times must be relative to the beginning of the session
    cond(icond).plotparam.scolor = 'g';
    icond = 3;
    cond(icond).sleg = 't+1 L Err Choice';
    cond(icond).spikesf = {'Electrode',Electrode,'Unit',UnitID};
    cond(icond).sweepsf   = {'ChoiceLeft',1,'ChoiceCorrect',0};
    cond(icond).trialRelsweepsf   = {{-1,'ChoiceCorrect',1},{-2,'ChoiceCorrect',1},{-3,'ChoiceCorrect',1},{-4,'ChoiceCorrect',0}};
    cond(icond).alignEvent= alignEvent; % NOTE Times must be relative to the beginning of the session
    cond(icond).plotparam.scolor = 'b';
    icond =4;
    cond(icond).sleg = 't+1 L Err Choice';
    cond(icond).spikesf = {'Electrode',Electrode,'Unit',UnitID};
    cond(icond).sweepsf   = {'ChoiceLeft',1,'ChoiceCorrect',0};
    cond(icond).trialRelsweepsf   = {{-1,'ChoiceCorrect',1},{-2,'ChoiceCorrect',1},{-3,'ChoiceCorrect',1},{-4,'ChoiceCorrect',1}};
    cond(icond).alignEvent= alignEvent; % NOTE Times must be relative to the beginning of the session
    cond(icond).plotparam.scolor = 'k';
    
       h  = psthCondSpikes(spikesNoW,cond, WOI, options);
    set(h.hpsth(3:4),'Linestyle','--')
    
    set(h.hAx,'Color','none')
    
    plotSpikeWave(spikesNoW,Electrode,UnitID,1);
    % add Legend
    clear sleg; for icond =1 : length(cond),       sleg{icond} =  cond(icond).sleg; end
    hlegPsth = legend(h.hAx(1),h.hpsth,sleg);
    defaultLegend(hlegPsth,[],7)

