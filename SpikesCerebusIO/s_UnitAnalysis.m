%% ********************* loadSpikeStruct and analyze
r = brigdefs;
p  = fullfile(r.Dir.spikesStruct, 'SertxChR2_179');
% ss = {'SertxChR2_179_D140223F1_spikes'};
d = dirc(fullfile(p,'*.mat'));
ss = d(:,1);
ss = ss(2:end,1);
%%
for ispikeStruct = 1%: length(ss) %8
    load(fullfile(p,ss{ispikeStruct}))
    %add average WAveforms
    EUPlus = spikes.Analysis.EUPlusLabel;
    for iEU = 1:size(EUPlus,1)
        [spikes]= addUnits_spikes(spikes, EUPlus(iEU,:) );
    end
    EU = cell2mat(EUPlus(:,1:2));
    spikesNoW = rmfield(spikes,'waveforms');
    
        
    
    for iEU =1: size(EU,1) %13
        Electrode = EU(iEU,1);
        UnitID =  EU(iEU,2);
        % ADD grouping by interval including all intervals at least X long)
        s_unitregression_inprog
        %% For ROC
        
       % alignEvent = 'TrialInit';
       
       alignEvent = 'firstSidePokeTime';
       clear options;
       ElectUnit = [Electrode UnitID];
       
       options.alignEvent = alignEvent;
       options.bsave = 1;
       options.cond(1).sDesc = 'Correct';
       options.cond(1).sweepsf = {'ChoiceCorrect',1}; %,'Interval',@(x) x < 0.5
       options.cond(1).alignEvent = alignEvent;
       trials_corr = find(spikes.sweeps.ChoiceCorrect==1);
       options.cond(1).spikesf = {'Electrode',ElectUnit(1),'Unit',ElectUnit(2)};
       
       
        options.cond(2).sDesc = 'Error';
        options.cond(2).sweepsf = {'ChoiceCorrect',0}; %,'Interval',@(x) x < 0.5
        options.cond(2).alignEvent = alignEvent;
        trials_incorr = find(spikes.sweeps.ChoiceCorrect==0);
        options.cond(2).spikesf = {'Electrode',ElectUnit(1),'Unit',ElectUnit(2)};
        
        
        options.Desc = alignEvent;
        for i=1:length( options.cond), options.Desc = [options.Desc options.cond(i).sDesc]; end
        options.bGTInterval      = 0;
        options.bplotspikewave =1;
        options.dpFieldsToPlot = {'firstSidePokeTime'};
        options.sortSweepsByARelativeToB= {'firstSidePokeTime',alignEvent};
        WOI  = [0 0.5]*1000;
       
        
        
        %%
        
          
       % alignEvent = 'TrialInit';
        alignEvent = 'firstSidePokeTime';
           clear options;
     
        options.bsave = 1;
        options.cond(1).sDesc = 'Correct';
        options.cond(1).sweepsf = {'ChoiceCorrect',1};
        options.cond(1).alignEvent = alignEvent;

        options.cond(2).sDesc = 'Error';
        options.cond(2).sweepsf = {'ChoiceCorrect',0}; 
        options.cond(2).alignEvent = alignEvent;
        
        options.Desc = alignEvent;
        for i=1:length( options.cond), options.Desc = [options.Desc options.cond(i).sDesc]; end
        options.bGTInterval      = 0;
        options.bplotspikewave =1;
        options.dpFieldsToPlot = {'firstSidePokeTime'};
        options.sortSweepsByARelativeToB= {'firstSidePokeTime',alignEvent};
        WOI  = [-0.5 3]*1000;
        
        h = plotAlignedByIntervalOverLay_spikes(spikesNoW,alignEvent,WOI,[Electrode UnitID],options);
        set(h.fig,'WindowStyle','docked')
    
     %%   
        
               
%         alignEvent = 'tone2Time';
%         clear options;
%         options.bsave = 1;
%         options.cond(1).sDesc = 'Correct';
%         options.cond(1).sweepsf = {'ChoiceCorrect',1};
%         options.cond(2).sDesc = 'Error';
%         options.cond(2).sweepsf = {'ChoiceCorrect',0};      
%         options.Desc = alignEvent;
%         for i=1:length( options.cond), options.Desc = [options.Desc options.cond(i).sDesc]; end
%         options.bGTInterval      = 1;
%         options.bplotspikewave =1;
%         options.dpFieldsToPlot = {'firstSidePokeTime'};
%         options.sortSweepsByARelativeToB= {'firstSidePokeTime',alignEvent};
%         WOI  = [3 0.5]*1000;
%         h = plotAlignedByIntervalOverLay_spikes(spikesNoW,alignEvent,WOI,[Electrode UnitID],options);
%         set(h.fig,'WindowStyle','docked')
%         
%         
%         alignEvent = 'firstSidePokeTime';
%         clear options;
%         options.bsave = 1;
%         options.cond(1).sDesc = 'Correct';
%         options.cond(1).sweepsf = {'ChoiceCorrect',1};
%         options.cond(2).sDesc = 'Error';
%         options.cond(2).sweepsf = {'ChoiceCorrect',0};      
%         options.Desc = alignEvent;
%         for i=1:length( options.cond), options.Desc = [options.Desc options.cond(i).sDesc]; end
%         options.bGTInterval      = 1;
%         options.bplotspikewave =1;
%         options.dpFieldsToPlot = {'tone2Time'};
%         options.sortSweepsByARelativeToB= {'firstSidePokeTime','tone2Time'};
%         WOI  = [3 0.5]*1000;
%         h = plotAlignedByIntervalOverLay_spikes(spikesNoW,alignEvent,WOI,[Electrode UnitID],options);
%         set(h.fig,'WindowStyle','docked')

        if 0
            alignEvent = 'firstSidePokeTime';
            options.dpFieldsToPlot = {'tone2Time'};
            options.sortSweepsByARelativeToB= {'tone2Time',alignEvent};
            options.bsave = 1;
            options.bootstrap = 0;
            options.bplotspikewave = 1;
            WOI  = [-0.5 3]*1000;
            h = plotAlignedByInterval_spikes(spikesNoW,alignEvent,WOI,[Electrode UnitID],options);
            set(h.fig,'WindowStyle','docked')
            alignEvent = 'tone2Time';
            options.dpFieldsToPlot = {'firstSidePokeTime'};
            options.sortSweepsByARelativeToB= {'firstSidePokeTime',alignEvent};
            WOI  = [-2.5 0.5]*1000;
            h = plotAlignedByInterval_spikes(spikesNoW,alignEvent,WOI,[Electrode UnitID],options);
            set(h.fig,'WindowStyle','docked')
            alignEvent = 'TrialInit';
            options.dpFieldsToPlot = {'firstSidePokeTime'};
            options.sortSweepsByARelativeToB= {'firstSidePokeTime',alignEvent};
            WOI  = [-0.5 1]*1000;
            h = plotAlignedByInterval_spikes(spikesNoW,alignEvent,WOI,[Electrode UnitID],options);
            set(h.fig,'WindowStyle','docked')
        end
        %% plot by Correct Error Premature
        if 1
            WOI  = [-1 0.6]*1000;
            alignEvent = 'TrialInit';
            clear options cond;
            options.bsave = 0;
            options.bootstrap = 0;
            options.binsize = 20;
            options.nsmooth =round(50/ options.binsize);
            
            options.sDesc = 'CorrectErrorPremature';
            sAnimal = spikesNoW.sweeps.Animal;
            sDate = spikesNoW.sweeps.Date;
            options.savefile = sprintf('%s_AL%s_%sE%d_U%d%s%s',options.sDesc,alignEvent, sDate,Electrode,UnitID );
            options.dpFieldsToPlot = {};
            options.sortSweepsByARelativeToB= {'firstSidePokeTime',alignEvent};
            options.plottype = {'psth','rasterplot'};
            icond = 1;
            cond(icond).sleg = 'Correct';
            cond(icond).spikesf = {'Electrode',Electrode,'Unit',UnitID};
            cond(icond).sweepsf   = {'ChoiceCorrect',1};
            cond(icond).trialRelsweepsf   = {{-1, 'Premature',[0]}};
            cond(icond).alignEvent= alignEvent; % NOTE Times must be relative to the beginning of the session
            cond(icond).plotparam.scolor = 'g';
            icond = 2;
            cond(icond).sleg = 'Error';
            cond(icond).spikesf = {'Electrode',Electrode,'Unit',UnitID};
            cond(icond).sweepsf   = {'ChoiceCorrect',0};
            cond(icond).trialRelsweepsf   = {{-1, 'Premature',[0]}};
            cond(icond).alignEvent= alignEvent; % NOTE Times must be relative to the beginning of the session
            cond(icond).plotparam.scolor = 'r';
            icond = 3;
            cond(icond).sleg = 'Premature';
            cond(icond).spikesf = {'Electrode',Electrode,'Unit',UnitID};
            cond(icond).sweepsf   = {'Premature',1};
            cond(icond).trialRelsweepsf   = {{-1, 'Premature',[0]}};
            cond(icond).alignEvent= alignEvent; % NOTE Times must be relative to the beginning of the session
            cond(icond).plotparam.scolor = 'y';
            
            
            [h  ntrialsInCond]= psthCondSpikes(spikesNoW,cond, WOI, options);
            set(h.hAx,'Color',[1 1 1]*.2)
            set(h.fig,'WindowStyle','docked')
            %         set(h.hAx,'Color','none')
            set(h.hpsth(2),'Linestyle','--')
            %     set(h.hpsth(3),'Linestyle',':')
            
            plotSpikeWave(spikesNoW,Electrode,UnitID,1);
            
            clear sleg; for icond =1 : length(cond),       sleg{icond} =  [cond(icond).sleg ' n = ' num2str(ntrialsInCond(icond),'%d')] ; end
            hlegPsth = legend(h.hAx(1),h.hpsth,sleg);
            defaultLegend(hlegPsth,[],7)
            
            if 1
                r = brigdefs;
                sAnimal = spikes.sweeps.Animal;
                savepath = fullfile(r.Dir.EphysFigs,sAnimal,'PSTH');
                parentfolder(savepath,1);
                %                 export_fig(h.fig,fullfile(savepath,options.savefile),'-pdf')
                plot2svg(fullfile(savepath,[options.savefile,'.svg']),h.fig)
                saveas(h.fig,fullfile(savepath,options.savefile))
                disp([ 'saved to ' fullfile(savepath,options.savefile)])
            end
        end
        
        %% plot by PREMATURE
        if 1
            WOI  = [-3 3]*1000;
            alignEvent = 'TrialInit';
            clear options cond;
            options.bsave = 0;
            options.bootstrap = 0;
            options.binsize = 20;
            options.nsmooth =round(50/ options.binsize);
            
            options.sDesc = 'PrematureShortLong';
            sAnimal = spikesNoW.sweeps.Animal;
            sDate = spikesNoW.sweeps.Date;
            options.savefile = sprintf('%s_AL%s_%sE%d_U%d%s%s',options.sDesc,alignEvent, sDate,Electrode,UnitID );
            options.dpFieldsToPlot = {};
            options.sortSweepsByARelativeToB= {'firstSidePokeTime',alignEvent};
            options.plottype = {'psth','rasterplot'};
            icond = 1;
            cond(icond).sleg = 'Not PM';
            cond(icond).spikesf = {'Electrode',Electrode,'Unit',UnitID};
            cond(icond).sweepsf   = {'Premature',0};
            cond(icond).trialRelsweepsf   = {};
            cond(icond).alignEvent= alignEvent; % NOTE Times must be relative to the beginning of the session
            cond(icond).plotparam.scolor = 'r';
            icond = 2;
            cond(icond).sleg = 'PrematureLong';
            cond(icond).spikesf = {'Electrode',Electrode,'Unit',UnitID};
            cond(icond).sweepsf   = {'PrematureLong',1};
            cond(icond).trialRelsweepsf   = {};
            cond(icond).alignEvent= alignEvent; % NOTE Times must be relative to the beginning of the session
            cond(icond).plotparam.scolor = 'k';
            icond = 3;
            cond(icond).sleg = 'PrematureShort';
            cond(icond).spikesf = {'Electrode',Electrode,'Unit',UnitID};
            cond(icond).sweepsf   = {'PrematureShort',1};
            cond(icond).trialRelsweepsf   = {};
            cond(icond).alignEvent= alignEvent; % NOTE Times must be relative to the beginning of the session
            cond(icond).plotparam.scolor = 'k';
            
            
            [h  ntrialsInCond]= psthCondSpikes(spikesNoW,cond, WOI, options);
            
            set(h.fig,'WindowStyle','docked')
            %         set(h.hAx,'Color','none')
            set(h.hpsth(2),'Linestyle','--')
            %     set(h.hpsth(3),'Linestyle',':')
            
            plotSpikeWave(spikesNoW,Electrode,UnitID,1);
            
            clear sleg; for icond =1 : length(cond),       sleg{icond} =  [cond(icond).sleg ' n = ' num2str(ntrialsInCond(icond),'%d')] ; end
            hlegPsth = legend(h.hAx(1),h.hpsth,sleg);
            defaultLegend(hlegPsth,[],7)
            
            if 1
                r = brigdefs;
                sAnimal = spikes.sweeps.Animal;
                savepath = fullfile(r.Dir.EphysFigs,sAnimal,'PSTH');
                parentfolder(savepath,1);
                %                 export_fig(h.fig,fullfile(savepath,options.savefile),'-pdf')
                plot2svg(fullfile(savepath,[options.savefile,'.svg']),h.fig)
                saveas(h.fig,fullfile(savepath,options.savefile))
                disp([ 'saved to ' fullfile(savepath,options.savefile)])
            end
        end
        %% plot by Stimulation
        if 1
            WOI  = [-1 4]*1000;
            alignEvent = 'TrialInit';
            clear options cond
            
            options.bsave = 0;
            options.sDesc = 'Light';
            sAnimal = spikesNoW.sweeps.Animal;
            sDate = spikesNoW.sweeps.Date;
            options.savefile = sprintf('%s_AL%s_%sE%d_U%d%s%s',options.sDesc,alignEvent, sDate,Electrode,UnitID );
            options.dpFieldsToPlot = {};
            options.sortSweepsByARelativeToB= {'firstSidePokeTime',alignEvent};
            options.plottype = {'psth','rasterplot','test'};
            options.bootstrap = 1;
            
            options.WOIsize = 0.2;
            options.beginOfFirstWOI = WOI(1)/1000;
            options.endOfLastWOI = WOI(2)/1000;
            options.lockOut =0.0;
            options.test = 'ranksum';


            icond = 1;
            cond(icond).sleg = 'Stim ';
            cond(icond).spikesf = {'Electrode',Electrode,'Unit',UnitID};
            cond(icond).sweepsf   = { 'stimulationOnCond',@(x) x~=0};
            cond(icond).trialRelsweepsf   = {};
            cond(icond).alignEvent= alignEvent; % NOTE Times must be relative to the beginning of the session
            cond(icond).plotparam.scolor = 'b';
            icond = 2;
            cond(icond).sleg = 'Ctrl';
            cond(icond).spikesf = cond(1).spikesf;
            cond(icond).sweepsf   = { 'stimulationOnCond',0};
            cond(icond).trialRelsweepsf   = {};
            cond(icond).alignEvent= alignEvent;
            cond(icond).plotparam.scolor = 'k';
            
            
            [h  ntrialsInCond]= psthCondSpikes(spikesNoW,cond, WOI, options);
            %     set(h.hpsth(3:4),'Linestyle','--')
            
            clear sleg; for icond =1 : length(cond),       sleg{icond} =  [cond(icond).sleg ' n = ' num2str(ntrialsInCond(icond),'%d')] ; end
            hlegPsth = legend(h.hAx(1),h.hpsth,sleg);
            defaultLegend(hlegPsth,[],7)
            
            %             set(h.hAx,'Color','none')
            plotSpikeWave(spikesNoW,Electrode,UnitID,1);
            
            
            if 1
                r = brigdefs;
                sAnimal = spikes.sweeps.Animal;
                savepath = fullfile(r.Dir.EphysFigs,sAnimal,'PSTH');
                parentfolder(savepath,1);
                %                 export_fig(h.fig,fullfile(savepath,options.savefile),'-pdf')
                plot2svg(fullfile(savepath,[options.savefile,'.svg']),h.fig)
                saveas(h.fig,fullfile(savepath,options.savefile))
                disp([ 'saved to ' fullfile(savepath,options.savefile)])
            end
        end
        %% plot by CORRECT / ERROR
        if 1
            clear options cond;
            options.sDesc = 'RewardedTrial';
            
            WOI  = [-0.5 3]*1000;
            alignEvent = 'firstSidePokeTime';
            options.bsave =0;
            sAnimal = spikesNoW.sweeps.Animal;
            sDate = spikesNoW.sweeps.Date;
            options.savefile = sprintf('%s_AL%s_%sE%d_U%d%s%s',options.sDesc,alignEvent, sDate,Electrode,UnitID );
            options.sortSweepsByARelativeToB= {'TrialInit',alignEvent};
            options.plottype = {'psth','rasterplot'};
            options.bootstrap = 1;
            options.dpFieldsToPlot = {};
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
            set(h.fig,'WindowStyle','docked')
            
            set(h.hpsth(3:4),'Linestyle','--')
            
            set(h.hAx,'Color',[1 1 1]*.2)
            
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
                %                 export_fig(h.fig,fullfile(savepath,options.savefile),'-pdf')
                plot2svg(fullfile(savepath,[options.savefile,'.svg']),h.fig)
                saveas(h.fig,fullfile(savepath,options.savefile))
                disp([ 'saved to ' fullfile(savepath,options.savefile)])
            end
        end
    end
end