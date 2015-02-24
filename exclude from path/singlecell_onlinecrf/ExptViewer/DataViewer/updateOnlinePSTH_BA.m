function h = updateOnlinePSTH_BA(h,cond)
%
% function [h] = updateOnlinePSTH_BA(h,cond,current_ledcond,istimcond) %% DEBUG VERSION
%
% INPUT
%   h: guidata for the PSTH figure
%   spiketimes:
%   cond:
%
% OUTPUT
%
%   Created: SRO 4/30/10
%   Modifed: SRO 5/4/10

% update the list of conditions

% if conditions changed then  reset plot

%  if h.nStimCond~=length(cond.list_stimcond),     h.nStimCond = cond.list_stimcond; end
%  if h.nLEDCond~=length(cond.list_ledcond),     h.nLEDCond = cond.list_ledcond; end
%
%   % call reset function

bDebug = 0;
%
% Determine whether plot
if ~bDebug
    switch h.cond.engage
        case 'off'
            bcond = [0 0]; % use condition [ledcond  stimcond]
        case 'on'
            switch h.cond.type
                case 'led'
                    bcond = [1 0];
                    
                case 'stim'
                    
                    bcond = [0 1];
                    
                case 'stimled'
                    bcond = [1 1];
            end
    end
    
    
    h = psthComputeUpdate(h,h.spikesCell,cond,bcond);
end
%     **  BA Tuning
if h.bTuning
% set(h.psthTuningFig ,'Name',['Tuning ' num2str(analWindow,'%1.2f ')])
h.analWindow = [0.1 1.2];

% confidence interval
alpha = 0.05;

ncond = length(cond.VarParam(1).Values);
nledcond = 2;
for mchn = length(h.spikesCell) % 3 % channels
    if ~isempty(h.spikesCell{mchn}.sweeps.led) || ~isempty(h.spikesCell{mchn}.sweeps.stimcond)
        
        tmp_spikes = h.spikesCell{mchn};
        if ~bDebug
            current_ledcond = cond.led;
            istimcond = cond.stim;
        end
        iledcond = find(cond.list_ledcond==current_ledcond);
         % initialize analysis fields if it doesn't exit
        if ~isfield(h.spikesCell{mchn},'analysis') || ~isfield(h.spikesCell{mchn}.analysis,'sumspikes_intrial')
            tmp_spikes.analysis.sumspikes_intrial = cell(nledcond,ncond);
            tmp_spikes.analysis.spikerate = zeros(nledcond,ncond);
        end
        
        % get all spikes with the same conditions as the last sweep        
        ftmp_spikes = filtspikes(tmp_spikes,0,'stimcond',istimcond,'led',current_ledcond);
        
        
        if isempty(ftmp_spikes.sweeps.trialsInFilter), ntrialsInFilter = 0;
        else   ntrialsInFilter = max(ftmp_spikes.sweeps.trialsInFilter);   end%number of trials with these conditions
        
        if ntrialsInFilter
            % for all the trials that haven't been counted yet count spikes
            tmp_sumspike = tmp_spikes.analysis.sumspikes_intrial{iledcond,istimcond}; % variable for use in loop
            for itrial = size(tmp_spikes.analysis.sumspikes_intrial{iledcond,istimcond},1)+1 :  ntrialsInFilter
                spike_intrial = ftmp_spikes.spiketimes(ftmp_spikes.trialsInFilter==itrial);
                if ~isempty(spike_intrial)
                    [n bin] =histc(spike_intrial,h.analWindow); %      get spikes in window
                    tmp_sumspike(itrial) = n(1); % put sum so that it doesn't have to be recomuted
                else
                    tmp_sumspike(itrial) = 0;
                end
            end
            tmp_spikes.analysis.sumspikes_intrial{iledcond,istimcond} = tmp_sumspike ;
            tmp_spikes.analysis.spikerate(iledcond,istimcond) = nansum(tmp_sumspike)/ntrialsInFilter/diff(h.analWindow);
            %         a = [iledcond istimcond nansum(tmp_sumspike)        length(tmp_sumspike) ntrialsInFilter]
            %         if ~mod(max(tmp_spikes.sweeps.trials),25)
            %             disp('here')
            %         end
            %         if istimcond==1
            %             disp('here')
            %         end
        else
            
            tmp_spikes.analysis.spikerate(iledcond,istimcond)  = NaN;
            tmp_spikes.analysis.sumspikes_intrial{iledcond,istimcond} = NaN;
        end
        
        if ntrialsInFilter>=3 % computer ci
            meanfunc = @(x) (nanmean(x)/diff(h.analWindow));
            tmp_spikes.analysis.spikerate_ci(iledcond,istimcond,:) = bootci(100,{meanfunc,tmp_sumspike},'alpha',alpha);
        else tmp_spikes.analysis.spikerate_ci(iledcond,istimcond,:) = [0 0]; end
        tuningci = tmp_spikes.analysis.spikerate_ci;
        
        % UPDATE plots
        try
            set(h.linesTun(mchn,iledcond),'XData',   cond.VarParam(1).Values,'YData',tmp_spikes.analysis.spikerate(iledcond,:));
            set(h.axsTun(mchn),'Xlim',[min(cond.VarParam(1).Values) max(cond.VarParam(1).Values)])
            AddAxesLabels(h.axsTun(mchn),cond.VarParam(1).Name,'h.spikesCell{mchn}/sec')
            
        catch ME
            getReport(ME)
            disp('RESETTING OnlinePSTH');
            h = helperReset_onlinePSTH_BA(h);
            guidata(h.psthFig,h)
        end
        tempy = [tuningci(iledcond,:,1) tuningci(iledcond,end:-1:1,2)];% reformat for patch data
        if any(isnan(tempy)) % WHY ARE NANs getting through?
            display('still finding nans');
            tempy(isnan(tempy)) = 0;
        end
        tempx = [cond.VarParam(1).Values cond.VarParam(1).Values(end:-1:1)];% would be more efficient to only do this one at beginning, but psthonlin might be called before we know the varvalues
        set(h.patchTunConf(mchn,iledcond),'YData',tempy,'XData',tempx); % note patch ydata consists of the lowerci concatenated with the upperci
        %         catch ME
        %             getReport(ME)
        %             display('any is nan') ; any(isnan(trialSum))
        %         end
        
        
        % plot raster of all conditions
        
        % % plot raster of each condition;
        % if ~ishandle(100)
        %     figure(100);title('raster');
        %     h.hAx_Raster = gca;
        % end
        h.spikesCell{mchn} =   tmp_spikes;
        
        %     if  ~bDebug % TAKES TOO MUCH RESOURCES .. try again when
        %     callback is fixed to be on SamplesAcquired 
        %         if ~ishandle(999)
        %             figure(999);title('raster');
        %             h.hAx_Raster = gca;
        %         elseif ~isfield(h,'hAx_Raster'), set(0,'CurrentFigure',999),h.hAx_Raster = gca; end
        %
        %         if ~ishandle(h.hAx_Raster), h.hAx_Raster = axes('Parent',999); title('raster'); end
        %         [hr h.hAx_Raster] = raster(tmp_spikes,h.hAx_Raster,0,0);
        %     end
    end
end

if  ~bDebug
    guidata(h.psthFig,h)
     assignin('base','tmpspikes',tmp_spikes)
end

end



% --- Subfunctions --- %

function h = psthComputeUpdate(h,spikesCell,cond,bcond) % nled is condition

% bcond = [0 0]; % use condition [ledcond  stimcond]

%     temp = h.trialcounter

for mchn = 1:length(spikesCell) % 3
    if ~isempty(spikesCell{mchn}.sweeps.led) || ~isempty(spikesCell{mchn}.sweeps.stimcond)
        current_ledcond = cond.led;
        iledcond = find(cond.list_ledcond==current_ledcond);        
        if isempty(iledcond), iledcond = 1; end
        
        istimcond = find(cond.list_stimcond==spikesCell{mchn}.sweeps.stimcond(end));
         if isempty(istimcond), istimcond = 1; end
         
       indSpiketimes = (spikesCell{mchn}.trials==spikesCell{mchn}.sweeps.trials(end)); % get only spikes from the last trial
        % Update trial counter
        h.trialcounter(mchn,iledcond,istimcond) = h.trialcounter(mchn,iledcond,istimcond) + 1;
        
        
        % Compute spikes per bin
        if any(indSpiketimes) % BA take care of no spikes
            
            [counts bin] = histc(spikesCell{mchn}.spiketimes(indSpiketimes),h.edges);
            
            %         % Add counts to psthData
            h.psthData(mchn,iledcond,istimcond,:,h.trialcounter(mchn,iledcond,istimcond)) = int16(counts(1:end-1));
            if 0
                %             Yval =          nanmean(squeeze(h.psthData(mchn,iledcond,istimcond,:,:)),2)'/h.binsize;
                % collapse along istimcond
            else        Yval = nanmean(squeeze(nanmean(h.psthData(mchn,iledcond,:,:,:))),2)/h.binsize;
                istimcond = 1;
            end
            % Update histogram
%             if bcond(1), iledcond = 1; end % collapse along conditions if requested
%             if bcond(2), istimcond = 1; end
            try
                %                 [size(h.xloc) size(Yval)]
                set(h.lines(mchn,iledcond,istimcond),'XData',h.xloc(:),'YData',Yval(:));
                set(h.axs(mchn),'Xlim',[0 max(h.xloc)])
                axis tight
            catch ME
                getReport(ME)
                disp('RESETTING OnlinePSTH');
                h = helperReset_onlinePSTH_BA(h);
                guidata(h.psthFig,h)
            end
        else
            h.psthData(mchn,iledcond,istimcond,:,h.trialcounter(mchn,iledcond,istimcond)) = 0;
        end
    end
    
    
end

guidata(h.psthFig,h)

