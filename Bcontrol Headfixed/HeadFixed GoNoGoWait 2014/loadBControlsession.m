function dp = loadBControlsession(nAnimal,nsession,protocol)
% function ratbase = loadsession(nAnimal,nsession,protocol)
% function ratbase = loadsession(filename)

% loadsession - transforms data format from SoloData to dataparsed
%
%   Reads data in files saved from solo system and transforms it
%   to a user-friendly 'dataparsed' data format.

%   - OUTPUT


if isunix
    slash = '/';
else
    slash = '\';
end

rd = brigdefs('bcontrol');
% solo_filename = fullfile('C:\ratter\data\Data\BVA\VGAT_1385','data_@Head_fixed2_BVA_VGAT_1385_141014a.mat');


% if nargin <=1,
%     behavior_only = 1; %default is use solo time (third column)
% end;
nfile = 1;
if nargin ==1 % assume input is a filename with path
    solo_filename = {nAnimal};
elseif nargin ==0
    [FileName,PathName] = uigetfile(fullfile(rd.Dir.BControlDataBehav,slash,'*.mat'),'MultiSelect','On','Select Behavior file to analyze');
    if iscell(FileName)
        
        nfile = length(FileName);
        for ifile = 1: nfile
            solo_filename{ifile} = fullfile(PathName,FileName{ifile});
        end
    else
        solo_filename{1} = fullfile(PathName,FileName);
    end
else
    % DataFolder=fullfile('C:\Users\Bass\Documents\BVA_Work\SoloData');
    DataFolder=fullfile(rd.Dir.BControlDataBehav,experimenter,nAnimal);
    
    
    f = dir([DataFolder '\*' protocol '*.mat']);
    solo_filename = {fullfile(DataFolder,f(nsession).name)};
end
%% Information about session
for ifile = 1:nfile
    load(solo_filename{ifile})
    dp(ifile).FullPath = solo_filename{ifile};
    dp(ifile).FileNumber = NaN;
    [dp(ifile).PathName, dp(ifile).FileName] = fileparts(solo_filename{ifile});
    dp(ifile).Animal = saved.SavingSection_ratname;
    
    %get protocol name
    fldn = fieldnames(saved);
    for ifld = 1:length(fldn)
        tmp = strfind(fldn{ifld}, '_LastTrialEvents');
        if ~isempty(tmp)
            dp(ifile).Protocol = fldn{ifld}(1:tmp-1);
            break;
        end
    end
    dp(ifile).ProtocolVersion = '';
    
    
    dp(ifile).Experimenter =saved.SavingSection_experimenter;
    dp(ifile).Date =    datestr(datenum(saved.SavingSection_SaveTime),'YYMMDD');
    
    %% Initialize trial-based variables
    start_trial=1;
    end_trial = length(saved_history.ProtocolsSection_parsed_events);
    num_trials=end_trial-start_trial+1;
    
    dp(ifile).Rev = 0;
    dp(ifile).recordingSystem = 'bcontrol';
    dp(ifile).Box = 1;
    dp(ifile).AnimalSpecies = '';
    
    % Manually entered % BA % Protocol head_fixed2
    dp(ifile).odorDesc = {'AmylAcitate','Oct','Carv'};
    dp(ifile).trialTypeDesc = {'Go','No Go','Wait'};
    
    dp(ifile).ntrials = num_trials;
    start = zeros(num_trials, 1)';
    dp(ifile).TrialInit =  NaN(num_trials, 1)';
    dp(ifile).TrialAvail =  NaN(num_trials, 1)';
    dp(ifile).trialTypeIndex = NaN(num_trials, 1)';
    dp(ifile).trialType = cell(num_trials,1)';
    dp(ifile).timeResponseAvailable = NaN(num_trials, 1)';
    dp(ifile).timeOutcome = NaN(num_trials, 1)';
    dp(ifile).water = NaN(num_trials, 1)';
    dp(ifile).airpuff = NaN(num_trials, 1)';
    dp(ifile).ChoiceCorrect= NaN(num_trials, 1)';
    dp(ifile).ChoiceCorrectGo= NaN(num_trials, 1)';
    dp(ifile).ChoiceCorrectNoGo= NaN(num_trials, 1)';
    dp(ifile).ChoiceCorrectWait= NaN(num_trials, 1)';
    dp(ifile).timeOutcome= NaN(num_trials, 1)';
    dp(ifile).Premature =  NaN(num_trials, 1)';
    
    dp(ifile).timeStimulationOff =  NaN(num_trials, 1)';
    dp(ifile).stimulation =  NaN(num_trials, 1)';
    dp(ifile).delayStimulationOn  =  NaN(num_trials, 1)';
    dp(ifile).startStateStimulationOn  =  cell(num_trials, 1)';
    dp(ifile).stimulationFreq  =  NaN(num_trials, 1)';
    dp(ifile).stimulationPulseDuration  =  NaN(num_trials, 1)';
    
    % for compatiblity
    dp(ifile).controlLoop = NaN(num_trials, 1)';
    dp(ifile).reDraw = NaN(num_trials, 1)';
    
    dp(ifile).odorValve = cell2mat(saved_history.Head_fixed2_current_odor(1:num_trials))'; % note this will be insufficient for odor definition if more than 1 Bank is used
    
    % stimulation coordinates
    dp(ifile).stimulationCoordX = cell2mat(saved_history.Head_fixed2_photostimulationCoordX(1:num_trials))';
    dp(ifile).stimulationCoordY = cell2mat(saved_history.Head_fixed2_photostimulationCoordY(1:num_trials))';
    dp(ifile).stimulationCoordZ = cell2mat(saved_history.Head_fixed2_photostimulationCoordZ(1:num_trials))';
    
    % trialTypesInSession = unique(saved_history.OdorSection_odor_type2);
    % if any(~ismember(trialTypesInSession,dp(ifile).trialTypeDesc))
    %     error('unknown trial type in this session')
    % end
    
    
    % licks
    % ParsedEvents_history{10}.pokes.C % remember beginings and ends
    
    %% Extract trial by trial information
    % get all state transition data
    ParsedEvents_history=saved_history.ProtocolsSection_parsed_events(start_trial:end_trial);
    
    for trial_num = 1:num_trials
        
        dp(ifile).trialType(trial_num) = eval(['saved_history.OdorSection_odor_type' num2str(dp(ifile).odorValve(trial_num)) '('  num2str(trial_num),')']);
        dp(ifile).trialTypeIndex(trial_num) = ismember(dp(ifile).trialType{trial_num},dp(ifile).trialTypeDesc);
        
        % get the matrix of states, actions, and times for each trial
        parsed_events = ParsedEvents_history{trial_num};
        
        % extract trial start time
        % TrialInit
        current_trial_start = parsed_events.states.state_0(1,2); % BA check this with Eran or code
        start(trial_num) = current_trial_start;
        
        dp(ifile).TrialInit(trial_num) =current_trial_start*1000;
        dp(ifile).TrialAvail(trial_num) =current_trial_start*1000;
        % Odor On
        dp(ifile).timeOdorOn(trial_num) = parsed_events.states.odor_valve_on(1,1)*1000;
        dp(ifile).timeOdorOff(trial_num) = parsed_events.states.odor_valve_on(1,2)*1000;
        dp(ifile).timeResponseAvailable(trial_num) = parsed_events.states.wait(1,2)*1000; % this is the end of the wait time that exists for all trials
        
        dp(ifile).ChoiceCorrect(trial_num) = 0;
        switch (lower(dp(ifile).trialType{trial_num}))
            case 'go'
                if ~isempty(parsed_events.states.water)
                    dp(ifile).water(trial_num) = 1;
                    dp(ifile).ChoiceCorrect(trial_num) = 1;
                    dp(ifile).ChoiceCorrectGo(trial_num) = 1;
                    dp(ifile).timeOutcome(trial_num)  = parsed_events.states.water(1,1)*1000;% not could be water/punishment/water+tone, impatient trials have NaN outcome.
                else dp(ifile).water(trial_num) = 0;
                    dp(ifile).ChoiceCorrectGo(trial_num) = 0;
                    dp(ifile).timeOutcome(trial_num)  = parsed_events.states.iti(1,1)*1000;
                end
                thisSection = 'GoSection_Go_';
            case 'nogo'
                if ~isempty(parsed_events.states.punish)
                    dp(ifile).airpuff(trial_num) = 1;
                    dp(ifile).timeOutcome(trial_num)  = parsed_events.states.punish(1,1)*1000;% not could be water/punishment/water+tone, impatient trials have NaN outcome.
                    dp(ifile).ChoiceCorrectNoGo(trial_num) = 0;
                else
                    dp(ifile).ChoiceCorrect(trial_num) = 1;
                    dp(ifile).ChoiceCorrectNoGo(trial_num) = 1;
                    dp(ifile).airpuff(trial_num) = 0;
                    dp(ifile).timeOutcome(trial_num)  = parsed_events.states.iti(1,1)*1000;
                end
                thisSection = 'NoGoSection_NoGo_';
            case 'wait'
                if ~isempty(parsed_events.states.water)
                    dp(ifile).water(trial_num) = 1;
                    dp(ifile).ChoiceCorrect(trial_num) = 1;
                    dp(ifile).ChoiceCorrectWait(trial_num) = 1;
                    
                    dp(ifile).Premature(trial_num) =0;
                    dp(ifile).timeOutcome(trial_num)  = parsed_events.states.water(1,1)*1000;% not could be water/punishment/water+tone, impatient trials have NaN outcome.
                else dp(ifile).water(trial_num) = 0;
                    dp(ifile).Premature(trial_num) =1; 
                    dp(ifile).ChoiceCorrectWait(trial_num) = 0; 
                    dp(ifile).timeOutcome(trial_num)  = parsed_events.states.iti(1,1)*1000;
                end
                thisSection = 'WaitingSection_Wait_';
            otherwise
                error(' unknown trial type');
                
                
        end
        
        
        % stimulation
        if ~isempty(parsed_events.states.iti_stim)
            dp(ifile).stimulation(trial_num) = 1;
            dp(ifile).timeStimulationOff(trial_num)  = parsed_events.states.iti_stim(1,1)*1000;%
            
            % NOTE these shouldn't change unless the user is messing them
            % during the session. Have not verified that they are correct (may
            % be offset where these values are changed a trial BEFORE the trial
            % they are actually used
            dp(ifile).delayStimulationOn(trial_num)  = saved_history.([thisSection 'light_train_delay']){trial_num};
            dp(ifile).startStateStimulationOn(trial_num)  = saved_history.([thisSection 'start_state'])(trial_num);
            dp(ifile).stimulationFreq(trial_num)  = saved_history.([thisSection 'light_frequency']){trial_num};
            dp(ifile).stimulationPulseDuration(trial_num)  = saved_history.([thisSection 'light_pulse_duration']){trial_num};
        elseif ~isempty(parsed_events.states.iti_nostim)
            dp(ifile).stimulation(trial_num) = 0;
        end
        
        dp(ifile).TrialNumber(trial_num) = trial_num;
        
        
    end; %end trial for-loop
    
    dp(ifile).absolute_trial = dp(ifile).TrialNumber;
    dp(ifile).parsedEvents_history = ParsedEvents_history';
    
end

if nfile>1
    options.concatenateTimes =1 ;
dp = concdp(dp,[],options);
end


