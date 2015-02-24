function [hAxOri fid]= plotclusterTuning(expt,spikes,fileInd,bLed)
% function [hAxOri fid]= plotclusterTuning(expt,spikes,fileInd)
% TO DO catch case of varparam in different files are different
varparamTemplate = expt.stimulus(fileInd(1)).varparam;
nVar = length(varparamTemplate);
for i = 2:length(fileInd)
    if ~isequal(expt.stimulus(fileInd(i)).varparam,varparamTemplate)
        error('varparam in selectedfiles do not match')
    end
end

if 0
    % % code to pick varparam with orientation /contrast  instead of just using
    % % Varparam(1)
    % analType = 'Orientation' %  'Contrast'; %
    % user specific would be here
    indSelect = find(ismember({varparamTemplate.Name},analType));
    if  isempty(indSelect)
        error('None of the files selected for analysis vary Orientation')
    end
else indSelect = 1; end

if indSelect==1
    nCond = length(unique(varparamTemplate(1).Values));
    % collapse var2
    if nVar>1,    spikes = spikes_collapseVarParam(spikes,varparamTemplate,2); end
elseif indSelect==2 && nVar>1 % collapse var1
    spikes =  spikes_collapseVarParam(spikes,varparamTemplate,1);
    nCond = length(unique(varparamTemplate(2).Values));
end

% create string for naming figures
sName = spikes.info.spikesfile;
if exist('bLed','var') % use bLed as a sort criteria and note it in the figure name
    sName = sprintf('%s LED %',sName,bLed);
end
spikes.led = spikes.led>1; spikes.sweeps.led = spikes.sweeps.led>1; % make led binary

selectassigns = unique(spikes.assigns);
nclus = length(selectassigns);





% -- PSTH with and with out light
% create figure
sname = sprintf('LIGHT no LIGHT: %s',sName); h =findobj('Name',sname);
if isempty(h),
    hfPSTH = figure;    set(hfPSTH,'Name',sname);
else hfPSTH =  h; end

set(hfPSTH,'Visible','off')
set(hfPSTH,'Tag','Cluster Tuning');

set(0,'CurrentFigure',hfPSTH); clf;

ncol = spikes.params.display.max_cols;
nrow = ceil(nclus/ncol);
binsizePSTH = 50; %ms

for iclus = 1:nclus
    cspikes = filtspikes(spikes,0,'assigns',selectassigns(iclus),'led',1);
    hAxesPsthL(iclus)  = axes();
    [hAxesPsthL(iclus) hPsth  junk junk] = psthBA(cspikes,[],hAxesPsthL(iclus),1,1);
%         set(hPsth(~isnan(hPsth)),'Color',spikes.info.kmeans.colors(selectassigns(iclus),:))
    set(hPsth(~isnan(hPsth)),'Color','b')
    cspikes = filtspikes(spikes,0,'assigns',selectassigns(iclus),'led',0);
    [hAxesPsthL(iclus) hPsth  junk junk] = psthBA(cspikes,[],hAxesPsthL(iclus),1,1);
    set(hPsth(~isnan(hPsth)),'Color','k')
    params.cellmargin = [0.03 0.03  0.05  0.05 ];
    setaxesOnaxesmatrix(hAxesPsthL(iclus),nrow,ncol,iclus,params,hfPSTH);
    set(get(hAxesPsthL(iclus),'Title'),'String',num2str(selectassigns(iclus)),...
            'Color',spikes.info.kmeans.colors(selectassigns(iclus),:),'FontWeight','bold');
    ha = insetplot(0.8,hAxesPsthL(iclus),1);
    cspikes.params.display.default_waveformmode = 2;
    [hL hAwave(iclus)] = plotAvgWaveform(cspikes,ha);
    set(hL,'Color','r','LineWidth',1);
end
set([hAxesPsthL],'Color','none')
%  scale all waveforms on same scale
if length(hAwave)>1,ylims = cell2mat(get(hAwave,'YLIM'));
else ylims = get(hAwave,'YLIM'); end
set(hAwave,'YLIM',[min(ylims(:,1)) max(ylims(:,2))])
set(hfPSTH,'Visible','on')

% --- plot PSTH for each var1 condition
if 0
    for iclus = 1:nclus
        % create figure
        sname = sprintf('%d psthTune: %s',selectassigns(iclus),sName); h =findobj('Name',sname);
        if ~isempty(h),        delete(h); end
        fidTune(iclus) = figure('Name',sname,'Visible','Off','Position',  [1687           5         560         975]);
        
        hAxesPsth = [];
        for iled = [0 1]
            
            clear cspikes;
            for iVar = 1:nCond
                icond = iVar ;
                cspikes(iVar,1) = filtspikes(spikes,0,'assigns',selectassigns(iclus),'stimcond',icond,'led',iled);
            end
            set(0,'CurrentFigure', fidTune(iclus));
            [hAxesPsth hPsth  junk junk] = psthBA(cspikes,[],hAxesPsth,1,1);
            if iled,            set(hPsth(~isnan(hPsth)),'Color',spikes.info.kmeans.colors(selectassigns(iclus),:))
            else,             set(hPsth(~isnan(hPsth)),'Color','k'); end
            
        end
        set([hAxesPsth],'Color','none')
        setSameYmax(hAxesPsth)
        
    end
    set(fidTune,'Visible','on')
end

% -- Tunig CURVE for each cluster and condition
% setup plotting and condition params
cond.timewindow(1,:) = [0.5 1.5]; % in seconds so that rate is spikes/sec
cond.timewindow(2,:) = [1.51 2.5];
ntimewindows =size(cond.timewindow,1);

cond.led = [ 0 1];
condcolor = ['k','b'];
nledcond = length(cond.led);

% create figure
sname = sprintf('TuningCurve: %s',sName); h =findobj('Name',sname);
if isempty(h),
    hfTune = figure;    set(hfTune,'Name',sname,'Position', [2240           5         680         975]);
else hfTune =  h; end
% set(hfTune,'Visible','off')
set(hfTune,'Tag','Cluster Tuning');
set(0,'CurrentFigure',hfTune); clf;

% create axes
    params.cellmargin = [0.03 0.05  0.05  0.05 ];
    params.figmargin = [0.04 0.03  0.02  0.0 ];
hAxesTunCurv = axesmatrix(nclus,ntimewindows,[1:nclus*ntimewindows],params,hfTune);
% format axes
set(hAxesTunCurv,'Color','none','TickDir','Out')

for iclus = 1:nclus
  % display cluster
    set(get(hAxesTunCurv(iclus*ntimewindows-1),'Ylabel'),'String',num2str(selectassigns(iclus)),...
        'Color',spikes.info.kmeans.colors(selectassigns(iclus),:),'FontWeight','bold');
  
    
    % --  plot Tuning in timewindow
    for itimewindow = 1:ntimewindows
        timewindow = cond.timewindow(itimewindow,:);
        % set axis for time window and cluster
        
        
        for iled = 1:nledcond % conditions
            ledcond = cond.led(iled);
            clear rate;
            for iVar = 1:nCond
                icond = iVar ;
                tempspikes = filtspikes(spikes,0,'assigns',selectassigns(iclus),'stimcond',icond,'led',ledcond);
                numtrials = length(tempspikes.sweeps.trials);
                
                n = histc(tempspikes.spiketimes,timewindow);
                rate(iVar) = n(1)/numtrials/diff(timewindow);
            end
            % plot tuning curve
            ind = (iclus*ntimewindows)-1 + itimewindow-1;
            hl = line(varparamTemplate(1).Values,rate,'color',...
                condcolor(iled),'Parent',hAxesTunCurv(ind));
        end
    end
end

% display time windows
for  itimewindow = 1:ntimewindows
    set(get(hAxesTunCurv(itimewindow),'Title'),'String',['[' num2str(cond.timewindow(itimewindow,:)) ']' ],'FontWeight','bold');
end
%
set(hfTune,'Visible','on')


% % % -- Polar tuning and raster
% sname = sprintf('Polar: %s',sName); h =findobj('Name',sname);
% if isempty(h),
%     fid = figure;    set(fid(1),'Name',sname);
% else fid =  h; end
% sname = sprintf('Raster: %s',sName); h =findobj('Name',sname);
% if isempty(h),
%     fid(2) = figure;    set(fid(2),'Name',sname);
% else fid(2) =  h; end
% 
% sparam =  expt.stimulus(fileInd(1)).params;
% if isequal(analType,'Orientation');
%     theta = deg2rad(varparamTemplate(indOrientation).Values);
% end
% 
% 
% hAxes = [];
% for iclus = 1:nclus
%     for iVar = 1:nCond
%         icond = iVar ;
%         cspikes(iVar,1) = filtspikes(spikes,0,'assigns',selectassigns(iclus),'stimcond',icond);
%     end
%     set(0,'CurrentFigure',fid(2));
%     [hAxes ph] = rasterBA(cspikes,hAxes,1,0);
%     set(ph(~isnan(ph)),'Color',spikes.info.kmeans.colors(selectassigns(iclus),:))
%
%     set(0,'CurrentFigure',fid(1));
%     [nPSTH edgesPSTH] = psthBA(cspikes,binsizePSTH,[],1,0);
%
%     analyzewindow = [ 0 min(sparam.StimDuration, size(nPSTH,3)*binsizePSTH*1e-3)];
%     analyzewindowbins = [max(1,analyzewindow(1)/(binsizePSTH*1e-3)) analyzewindow(2)/(binsizePSTH*1e-3)];
%     ratePSTH = mean(nPSTH(:, :,analyzewindowbins(1):analyzewindowbins(2)),3);
%     hAxOri(iclus) = axes();
%     [hpolar  hAxOri(iclus)] = plotOriTuning(theta,ratePSTH);
%     setaxesOnaxesmatrix(hAxOri(iclus),nrow,ncol,iclus,[],fid(1));
%     if 1 % polar plot needs special formating ttreatement
%         set(0,'Showhiddenhandles','on')
%         htitle = get(hAxOri(iclus),'Title');
%         extrastuff = setdiff(get(hAxOri(iclus),'children'),[hpolar htitle]);
%         set(extrastuff,'Visible','off');
%         %                set(hpAxes,'Position',get(hpAxes,'Position').*[-3*(iclus==1)-1 -1.5 1.5 1.5]) % make ploar axes bigger and shift over
%     end
%     set(hpolar,'color',spikes.info.kmeans.colors(selectassigns(iclus),:),'linewidth',2);
%     title(sprintf(' # %d',selectassigns(iclus)));
%
% end
%
% set(hAxes,'XColor',[1 1 1])
% set(hAxes,'YColor',[1 1 1])
%     set(hAxes,'Color',[0 0 0])
%     set(fid([2 3]),'Color',[0 0 0])

% set(fid,'Visible','on')

%     TO DO add raster (only of max respond condition)