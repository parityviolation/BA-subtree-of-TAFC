function licks = buildLicks(dp)
% uses same as Spikes but with licks
%BA

if nargin==0
    dp = loadBControlsession;
end

rd = brigdefs();
licks.info.spikesfile  =   fullfile(rd.Dir.BStruct,[dp.FileName '_LickStruct']);
licks.dataDesc = 'licks';
sweeps = createSweeps(dp);

sweeps.TrialAvailEphys = sweeps.TrialAvail;
sweeps.nTrialsAvailEphysAndBehavior = sweeps.ntrials;
sweeps.nTrialsAvailEphys = sweeps.ntrials;
sweeps.firstLickAfterResponseAvailable = nan(size(sweeps.TrialInit));
sweeps.firstLickAfterOdorOn =  nan(size(sweeps.TrialInit));
sweeps.lastLickBeforeOdorOn =  nan(size(sweeps.TrialInit));
sweeps.nLicks =zeros(size(sweeps.TrialInit));
sweeps.nLicksBeforeOdor =zeros(size(sweeps.TrialInit));
sweeps.nLicksDuringOdorDelay = zeros(size(sweeps.TrialInit));
sweeps.nLicksDuringResponseAvailable =zeros(size(sweeps.TrialInit));
sweeps.nLicksDuringOutcome = zeros(size(sweeps.TrialInit));


allLicks = [];
TrialNumber = [];
for itrial   = 1:sweeps.ntrials
    timeOffset = 0;
    if isfield(dp,'sessiontimeOffset')
        timeOffset = dp.sessiontimeOffset(itrial);
    end
    
    thisTrialLicks = (dp.parsedEvents_history{itrial}.pokes.C +timeOffset)*1000;
    if ~isempty(thisTrialLicks)
        if itrial < sweeps.ntrials-1
            nextTrialLicks = (dp.parsedEvents_history{itrial+1}.pokes.C + timeOffset)*1000;
        end
        
        % Take care of edges effects on licks:
        %    if licking is occuring at the start/end of the trial the licking on/off is
        %    NAN respectively.
        if isnan(thisTrialLicks(end,2))
            if itrial>1 & itrial < sweeps.ntrials-1
                
                if isempty(nextTrialLicks)| isnan(nextTrialLicks(1,1)) % if lick ended before the next trial or next trial has no licks began, half way to the next trial as the lick length
                    thisTrialLicks(end,2) = (dp.parsedEvents_history{itrial+1}.states.state_0(end,1)+ timeOffset +thisTrialLicks(end,1))/2;
                else % fill in the missing lickEnd with the nexttrials first lickEnd
                    thisTrialLicks(end,2) = nextTrialLicks(1,2);
                end                
            else % remove if it is the last trial
                thisTrialLicks(end,:) = [];
            end
            
        end
        
        if ~isempty(thisTrialLicks)
            % Remove licks that didn't start on the trial
            if isnan(thisTrialLicks(1,1)),        thisTrialLicks(1,:) = [];    end
        end
        allLicks = [allLicks; thisTrialLicks];
        TrialNumber = [TrialNumber; itrial*ones(size(thisTrialLicks,1),1)];
        
        %find first Lick after X
        delta = thisTrialLicks(:,1) - sweeps.timeResponseAvailable(itrial);
        ind = find(delta>0,1,'first');
        if ~isempty(ind)
            sweeps.firstLickAfterResponseAvailable (itrial) =thisTrialLicks(ind ,1);
        end
        
        delta = thisTrialLicks(:,1) - sweeps.timeOdorOn(itrial);
        ind = find(delta>0,1,'first');
        if ~isempty(ind)
            sweeps.firstLickAfterOdorOn (itrial) =thisTrialLicks(ind ,1);
        end
        
        delta = thisTrialLicks(:,1) - sweeps.timeOdorOn(itrial);
        ind = find(delta<0,1,'last');
        if ~isempty(ind)
            sweeps.lastLickBeforeOdorOn (itrial) =thisTrialLicks(ind ,1);
        end
        
          
        if ~isempty(thisTrialLicks)
            
            sweeps.nLicks(itrial) = size(thisTrialLicks,1);
            % nLicksBeforeOdor
            b =  thisTrialLicks(:,1) < sweeps.timeOdorOn(itrial);
            if any(b),sweeps.nLicksBeforeOdor(itrial) =sum(b);
            end
            
            
            % nLicksDuringOdorDelay
            b =  thisTrialLicks(:,1)<sweeps.timeResponseAvailable(itrial)& ...
            thisTrialLicks(:,1) > sweeps.timeOdorOn(itrial);
            if any(b),sweeps.nLicksDuringOdorDelay(itrial) =sum(b);
            end
            
                       % nLicksDuringResponseAvailable
            b = thisTrialLicks(:,1) >= sweeps.timeResponseAvailable(itrial) & ...
                thisTrialLicks(:,1) <  sweeps.timeOutcome(itrial) ;
            if any(b),sweeps.nLicksDuringResponseAvailable(itrial) =sum(b);
            end

            
            b = thisTrialLicks(:,1) >= sweeps.timeOutcome(itrial);
            if any(b),sweeps.nLicksAfterOutcome(itrial) =sum(b);
            end
            
            
        end



    end
    
end


% NOTE could add to spiketimes rather than replace it
licks.TrialNumber =TrialNumber';
licks.spiketimes = allLicks(:,1)';
licks.licksOnOff = allLicks';

licks.assigns = -1*ones(size(licks.spiketimes),'int8');
licks.Electrode = zeros(size(licks.spiketimes),'int8');
licks.Unit = zeros(size(licks.spiketimes),'int8');




% if bAppend
%    spikesIn.sweeps = rmfield(spikesIn.sweeps,'stats');
%     sweeps = concdp(spikesIn.sweeps,sweeps);
%     
%     [p name]  = fileparts(spikes.info.spikesfile);
%     spikesIn.info.spikesfile = fullfile(p,[name '_multiple.mat']);
%     
%     spikesIn.info.nev(end+1)             = spikes.info.nev;
%     if isfield(spikesIn,'waveforms')
%         spikesIn.waveforms            = [spikesIn.waveforms; spikes.waveforms];
%     end
%     spikesIn.Electrode            = [spikesIn.Electrode spikes.Electrode];
%     spikesIn.Unit                 = [spikesIn.Unit spikes.Unit];
%     spikesIn.info.detect.dur      = spikesIn.info.detect.dur + spikes.info.detect.dur;
%     spikesIn.spiketimes           = [spikesIn.spiketimes spikes.spiketimes]; 
%     spikesIn.TrialNumber          =  [spikesIn.TrialNumber spikes.TrialNumber+max(spikesIn.TrialNumber)]; 
%     disp(['concatenating ' spikes.info.spikesfile 'to spikes'] )
%     
%     spikesIn.nTrialsAvailEphysAndBehavior = [ spikesIn.nTrialsAvailEphysAndBehavior spikes.nTrialsAvailEphysAndBehavior]; % BA untested 5/29/14
%     spikesIn.nTrialsAvailEphys = [ spikesIn.nTrialsAvailEphys spikes.nTrialsAvailEphys]; % BA untested 5/29/14
%     spikes = spikesIn;
%     
% end
% 

sweeps.ephysTimeScalar = 1;
licks.sweeps = sweeps;

