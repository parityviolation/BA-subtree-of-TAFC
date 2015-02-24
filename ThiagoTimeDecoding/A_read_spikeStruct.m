%% Preamble
neurTAFCm_SharedVariables
dataDir = [dbDir 'PatonLab/Data/'];
%% Variables
savevar = true;
bin = 500; % 200, 500
% step = round(bin/20); % == 20ms
step = round(bin/10);
evint = 'StimOn'; %,'Choice'
bounds = [-1 3]*1000; % Size of Evint   ([-1 3]*1000),
minFr = 0.5; % minimum firing rate
SubjName = struct2cell(dir([dataDir 'TAFCmice/Ephys/SpikeStruct'])); SubjName = SubjName(1,3:end)';

%% Action!
clear myTAFC
myTAFC = struct;
for r = 1:length(SubjName)
    subjName = SubjName{r};
    Session = struct2cell(dir([dataDir 'TAFCmice/Ephys/SpikeStruct/' subjName])); Session = Session(1,4:end)';
%     dataBhv.(subjName) = struct;
    for s = 1:length(Session)
        load([dataDir 'TAFCmice/Ephys/SpikeStruct/' subjName '/' Session{s}]);
        spikes = rmfield(spikes,'waveforms');
        perf = psycurve(spikes.sweeps,0,0); perf(spikes.sweeps.IntervalSet<.5) = 1-perf(spikes.sweeps.IntervalSet<.5);
%         perf = spikes.sweeps.ChoiceCorrect;
        if nanmean(perf)>=.75
            [counts, meanFr] = interfacing(spikes);
            myTAFC.(subjName).(['s' Session{s}(16:21)]).neur.Counts = counts(:,:,meanFr>=minFr);
            myTAFC.(subjName).(['s' Session{s}(16:21)]).bhv = spikes.sweeps;
            if size(myTAFC.(subjName).(['s' Session{s}(16:21)]).neur.Counts,1) ~= length(myTAFC.(subjName).(['s' Session{s}(16:21)]).bhv.TrialNumber)
                myTAFC.(subjName) = rmfield(myTAFC.(subjName),['s' Session{s}(16:21)]);
            end
        end
    end
end
        
if savevar; save('myTAFC','myTAFC','-v7.3'); end

% %% Taking a look at performance
% intSet = common.intSet;
% 
% psycs = cell(length(SubjName),1);
% perf = cell(length(SubjName),1);
% figure;
% for r = 1:length(SubjName)
%     subjName = SubjName{r};
%     session = fieldnames(myTAFC.(subjName));
%     display(['Running subject ' subjName])
%     dataBhv.(subjName) = struct;
%     psycs{r} = nan(length(session),length(intSet));
%     C = winter(length(session));
%     subplot(2,length(SubjName),r), hold on
%     title(subjName)
%     for s = 1:length(session)
% %         display(['Running session ' session{s}])
%         % for s = randi(length(session))
%         psycs{r}(s,:) = psycurve(myTAFC.(subjName).(session{s}).bhv,0,0);
%         plot(intSet,psycs{r}(s,:),'color',C(s,:),'linewidth',common.lwid)
%         set(gca,'xlim',pvar.psyc_xlim,'xtick',pvar.psyc_xtick,'xticklabel',pvar.psyc_xticklabel,...
%             'ylim',pvar.unit_lim,'ytick',pvar.unit_lim,'yticklabel',pvar.unit_ticklabel,'tickdir','out')
%         axis square
%     end
%     perf{r} = psycs{r}; perf{r}(:,1:4) = 1-perf{r}(:,1:4);
%     mean(perf{r},2)
%     subplot(2,length(SubjName),length(SubjName)+r)
%     errorbar(intSet,mean(psycs{r}),std(psycs{r}),'color',mean(C),'linewidth',common.lwid)
%     set(gca,'xlim',pvar.psyc_xlim,'xtick',pvar.psyc_xtick,'xticklabel',pvar.psyc_xticklabel,...
%         'ylim',pvar.unit_lim,'ytick',pvar.unit_lim,'yticklabel',pvar.unit_ticklabel,'tickdir','out','box','off')
%     axis square
% end
