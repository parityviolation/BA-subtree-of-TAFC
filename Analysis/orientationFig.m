function h = orientationFig(expt,unitTag,fileInd,b,spikes,bfit)
% function orientationFig(expt,unitTag,fileInd,b,spikes)
%
% INPUT
%   expt: Experiment struct
%   unitTag: Tag of the form 'trode_assign', e.g 'T2_15'
%   fileInd: Vector of file indices to be included in analysis.
%   cond: **** Need to add this ****
%       - cond.type: String with condition for filtering spikes struct( e.g. 'led','hM4D', etc)
%       - cond.value: List of values for filtering spikes struct
%   b: Flag structure with field b.save, b.print, b.pause, b.close

% Created: 5/13/10 - SRO
% Modified: 5/16/10 - SRO
% Modified: 5/16/10 -  BA added ability to pass in spikes directly, this
% makes it compatible with use during Merge Tool usage
bbootstrap = 1;

if nargin < 4 | isempty(b),
    b.pause = 0;
    b.save = 0;
    b.print = 0;
    b.close = 0;
end

if nargin < 6, bfit=1; end


% Rig defaults
rigdef = RigDefs;
if ~ismember(expt.analysis.orientation.cond.tags,'all')
    expt = analysis_def(expt); % OVERRIDE condition values
%     expt.led.windows = [0.5 2];
    expt.analysis.orientation = expt.analysis.orientation;
end


if 1
    expt.analysis.orientation.fileInd = fileInd;
    saveexptstruct(expt)
end

% Set cond struct
cond = expt.analysis.orientation.cond;
cond.type = 'led';
cond.values = {[0]}; % only plot on 
cond.tags = {'off'};

% Set time window struct
w = expt.analysis.orientation.windows;

% Temporary color
if isempty(cond.color)
    cond.color = {[0 0 1],[1 0 0],[0 1 0],[1 0 1],[0.3 0.3 0.3], [.3 .8 .3], [.3 .3 .8],  [.7 .5 .5], [.6 .8 .6], [.6 .6 .8], [.5 .7 .7], [0.3 0.3 0.3],[0.7 0.7 0.7]};
end

% -- Load Spikes
[trodeNum unitInd] = readUnitTag(unitTag); % Get tetrode number and unit index from unit tag

label = 'no label'; bload_spikes=0; % default
if ~exist('spikes','var'),         bload_spikes = 1; 
elseif isempty(spikes),         bload_spikes = 1; end

if bload_spikes
    % Get spikes from trode number and unit index
    spikes = loadvar(fullfile(rigdef.Dir.Spikes,expt.sort.trode(trodeNum).spikesfile));
    % Get unit label
    try    label = getUnitLabel(expt,trodeNum,unitInd); catch label = 'none'; end
end
% Extract spikes for unit and files
spikes = filtspikes(spikes,0,'assigns',unitInd,'fileInd',fileInd);

% BA hack to handle LED condition is read through AI and has noise
spikes = fixLEDcond_helper(expt,spikes,cond.values);
%
% spikes.sweeps.stimcond(isnan(spikes.sweeps.stimcond)) = 10;
% spikes = SpikesAddConds(spikes);

% -- Find Exist Figure (don't remake if exists and has same conditions and number of spikes
sname = sprintf('%s OriTuning',unitTag);

if 0 % replace old figure
    h.fig =findobj('Name',sname); % replace existing figure if it exists
else h.fig = []; end

bFigureDone = 0;
try h = guidata(h.fig); catch h = []; end

if ~isempty(h),
    thisdata.cond = cond; thisdata.fileInd = fileInd; thisdata.unitTag = unitTag;    thisdata.nspikes = length(spikes.spiketimes);
    if ~isempty(comp_struct(h.data,thisdata,[],[],[],[],0))
        clf(h.fig); % the Existing figure is not the same
    else bFigureDone=1; end
end

% -- MAKE FIGURE
if ~bFigureDone
    h.fig = landscapeFigSetup();
%     set(h.fig,'Visible','off','Position',rigdef.Analysis.Orientation.Position,'Name',sname )
    
    % save info that makes this plot unique
    h.unitTag = unitTag;
    h.label = label;
    
    h.data.cond = cond;
    h.data.fileInd = fileInd;
    h.data.unitTag = h.unitTag;
    h.data.nspikes = length(spikes.spiketimes); % because cluster could have the same name but have been split
    
    if ~isempty(spikes.spiketimes)
        % Set NaNs = 0
        spikes.led(isnan(spikes.led)) = 0;
        spikes.sweeps.led(isnan(spikes.sweeps.led)) = 0;
        
        % Get stimulus parameters
        stimulusstruct = expt.stimulus(fileInd(1));
        collapse_var = 2;
        stim = getStimCode(stimulusstruct,collapse_var);
        
        % If using all trials
        if strcmp(cond.type,'all')
            spikes.all = ones(size(spikes.spiketimes));
            cond.values = {1};
        end
        
        % **BA kluggy for size tuning
%         stim.values = unique(spikes.sweeps.stimcond);
%         stim.code = {[1],2,3}; disp('temp kluggy for size tuning')
        % **
        
        % Make spikes substruct for each stimulus value and condition value
        for m = 1:length(stim.values)
            for n = 1:length(cond.values)
                if strcmp(cond.type,'led')
                    spikes.tempfield = spikes.led;
                    spikes.tempfield = compareDouble(spikes.tempfield,cond.values{n});
                    spikes.sweeps.tempfield = spikes.sweeps.led;
                    spikes.sweeps.tempfield = compareDouble(spikes.sweeps.tempfield,cond.values{n});
                    cspikes(m,n) = filtspikes(spikes,0,'stimcond',stim.code{m},'tempfield',1);
                    %                     cspikes(m,n) =filtspikes(spikes,0,'tempfield',1); % all conditions
                    if isempty( cspikes(m,n).spiketimes )
                        disp('cspikes is empty')
                        %                         keyboard
                    end
                else
                    cspikes(m,n) = filtspikes(spikes,0,'stimcond',stim.code{m},cond.type,cond.values{n});
                end
            end
        end
        
        % --- Make raster plot for each cspikes substruct
        %     figure(99)
        for m = 1:size(cspikes,1)       % m is number of stimulus values
            h.r.ax(m) = axes('Parent',h.fig);
            defaultAxes(h.r.ax(m));
            for n = 1:size(cspikes,2)   % n is number of conditions
                h.r.l(m,n) = raster(cspikes(m,n),h.r.ax(m),1);
            end
        end
        h.r.ax = h.r.ax';
        set(h.r.ax,'Box','on')
        
        % Add handles to appropriate condition field
        for n = 1:size(cspikes,2)
            h.(cond.tags{n}) = [];
            h.(cond.tags{n}) = [h.(cond.tags{n}); h.r.l(:,n)];
        end
        
        % Set axes properties
        hTemp = reshape(h.r.ax,numel(h.r.ax),1);
        ymax = setSameYmax(hTemp);
        removeAxesLabels(hTemp)
        defaultAxes(hTemp)
        gray = [0.85 0.85 0.85];
        set(hTemp,'YColor',gray,'XColor',gray,'XTick',[],'YTick',[]);
        
        % Set stimulus condition as title
        for i = 1:length(stim.values)
            temp{i} = round(stim.values(i));
        end
        temph = get(h.r.ax,'Title');
        if iscell(temph), temph = cell2mat(temph); end
        set(temph,{'String'},temp','Position',[1 0 1]);  %'Position',[1.4983 0 1]
        
        % --- Make PSTH for each cspikes substruct
        try
            for m = 1:size(cspikes,1)       % m is number of stimulus valuesf
                h.psth.ax(m) = axes('Parent',h.fig);
                for n = 1:size(cspikes,2)   % n is number of conditions
                    [h.psth.l(m,n) temp N centers temp h.psth.patch(m,n)] = psth(cspikes(m,n),100,h.psth.ax(m),1,0);
                    if ~isempty(cspikes(m,n).spiketimes)
                        try h.psth.n(m,:,n) = N; % first conditions might have no spikes in which case psth.n has the wrong dimensions
                        catch h.psth.n = nan(size(cspikes,1),length(N),size(cspikes,2)); end
                    else
                        h.psth.n(m,:,n) = NaN;
                    end
                    
                end
            end
            h.psth.ax = h.psth.ax';
        catch ME
            getReport(ME)
        end
        
        % Add handles to appropriate condition field
        for n = 1:size(cspikes,2)
            h.(cond.tags{n}) = [h.(cond.tags{n}); h.psth.l(:,n); h.psth.patch(:,n)];
        end
        expt.led.windows
        % Set axes properties
        setRasterPSTHpos(h)
        hTemp = reshape(h.psth.ax,numel(h.psth.ax),1);
        ymax = setSameYmax(hTemp,15);
        for i = 1  % for first axes
            addStimulusBar(h.psth.ax(i),[expt.analysis.orientation.vstimpresent  ymax]);
%             addStimulusBar(h.psth.ax(i),[expt.led.windows  ymax*.95],'',cond.color{2}); % add LED bar
        end
        removeInd = 1:length(hTemp);
        keepInd = ceil(length(hTemp)/2) + 1;
        removeAxesLabels(hTemp(setdiff(removeInd,keepInd)))
        defaultAxes(hTemp,0.25,0.1)
        
        % --- Compute average response as a function oriention
        [allfr nallfr allfr_sem] = computeResponseVsStimulus(spikes,stim,cond,w,0);
       [allfrsubspont allfrsubspont_sem] = computeResponseVsStimulus(spikes,stim,cond,w,1);
        
        % --- Make orientation tuning plots
        h.ori.ax = axes('Parent',h.fig); ylabel('spikes/s','FontSize',8)
%         h.ori_subspont.ax = axes('Parent',h.fig);
        theta = stim.values';
%         if any(theta>90), bfit = 1; else bfit = 0; end % klugge for size tuning
        try
            [h.ori.l, ~,  h.ori.el, h.ori.fl]= plotOrientTuning(allfr.stim,theta,h.ori.ax,allfr_sem.stim,bfit);
             xlabel('orientation','FontSize',8)
%            [h.ori_subspont.l, ~,  h.ori_subspont.el, h.ori_subspont.fl]= plotOrientTuning(allfrsubspont.stim,theta,h.ori_subspont.ax,allfrsubspont_sem.stim,bfit);
%             [h.nori.l ~,  ~, h.nori.fl]= plotOrientTuning(nallfr.stim,theta,h.nori.ax,[],bfit);
            defaultAxes([h.ori.ax],0.18,0.1);
            xlabel('orientation','FontSize',8)
            setTitle(h.ori.ax,'stim window',8);
%             setTitle(h.ori_subspont.ax,'- spont',8);

            % Add handles to appropriate condition field
            for n = 1:size(cspikes,2)
                h.(cond.tags{n}) = [h.(cond.tags{n}); h.ori.l(:,n);h.ori.el(:,n);h.ori.fl(:,n); h.nori.fl(:,n); h.nori.l(:,n)]; ;
            end
        catch ME
            getReport(ME)
        end
        setColor(  [h.ori.el h.ori.fl],'b');
        set(h.ori.ax,'xlim',[0 360])
%         setColor(  [h.ori_subspont.el h.ori_subspont.fl],'b');
%         set(h.ori_subspont.ax,'xlim',[0 360])
%         
        % --- Make polar plots
        try
        polplots = {'stim','on','off'};
        for i = 1:length(polplots)
            win = polplots{i};
            temp = allfr.(win);
            temp(temp<0) = 0;
            [h.pol.(win).l, h.pol.(win).ax] = polarOrientTuning(temp,theta);
            set(get(gca,'Title'),'String',win,'Visible','on');
        end
%         temp = nallfr.stim;
%         temp(temp<0) = 0;
%         [h.npol.l, h.npol.ax] = polarOrientTuning(temp,theta);
%         set(get(gca,'Title'),'String','norm','Visible','on');
        
        % Add handles to appropriate condition field
        for n = 1:size(cspikes,2)
            for i = 1:length(polplots)
                win = polplots{i};
                h.(cond.tags{n}) = [h.(cond.tags{n}); h.pol.(win).l(n)];
            end
            h.(cond.tags{n}) = [h.(cond.tags{n}); h.npol.l(n)];
        end
        catch ME
            getReport(ME)
        end
        % --- Compute average waveform
        [h.avgwv.l h.avgwv.ax maxch] = plotAvgWaveform(spikes);
        axis off
        
        % --- Make autocorrelation plot
        h.autocorr.ax = axes('Visible','off','Parent',h.fig);
        [  h.autocorr.ax] =  plot_isi( spikes, unitInd, 0 );
        defaultAxes(h.autocorr.ax,0.22,0.14);
        set(findobj(h.autocorr.ax,'Tag','line'),'FaceColor',[0.15 0.15 0.15],'EdgeColor',[0.15 0.15 0.15]);
        setTitle(h.autocorr.ax,num2str( length(spikes.spiketimes)))
        
        % % --- Plot firing rate vs time
        [h.frvt.l h.frvt.ax] = plotSpikesPerTrial(spikes,[],0);
        defaultAxes(h.frvt.ax,0.22,0.14);
        xlabel('trial','FontSize',8); ylabel('spikes/trial','FontSize',8);
        % -- ADD light trials to plot
        ledontrials = spikes.sweeps.led>0.5;
        tempx = get(h.frvt.l,'Xdata'); tempy = nan(size(tempx));
        tempy(ledontrials)= max(get(h.frvt.l,'Ydata'));
        h.frvt.lledtrial = line(tempx,tempy,'color',cond.color{2},'parent',h.frvt.ax);
        
        % --- Plot average PSTH across all stimulus conditions
        h.allp.ax = axes('Parent',h.fig);
        try
            for n = 1:length(cond.values)
                if strcmp(cond.type,'led')
                    spikes.tempfield = spikes.led;
                    spikes.tempfield = compareDouble(spikes.tempfield,cond.values{n});
                    spikes.sweeps.tempfield = spikes.sweeps.led;
                    spikes.sweeps.tempfield = compareDouble(spikes.sweeps.tempfield,cond.values{n});
                    tempspikes = filtspikes(spikes,0,'tempfield',1,'stimcond',cell2mat(stim.code)); % BA all conditions included in this figure (this may be a subset of all conditions in the experiment)
                else
                    tempspikes = filtspikes(spikes,0,cond.type,cond.values{n},'stimcond',cell2mat(stim.code));
                end
                [h.allp.l(:,n) temp temp temp temp h.allp.patch(:,n)] = psth(tempspikes,50,h.allp.ax,1,bbootstrap);
            end
        catch ME
            getReport(ME)
        end
        defaultAxes(h.allp.ax,0.22,0.12);
        ylim = get(h.allp.ax,'Ylim');
        ymax = max(ylim)*1.05; set(h.allp.ax,'Ylim',[ylim(1) ymax])
        addStimulusBar(h.allp.ax,[expt.analysis.orientation.vstimpresent  ymax]);
%         addStimulusBar(h.allp.ax,[expt.led.windows  ymax*.95],'',cond.color{2}); % add LED bar
%         
        % Add handles to appropriate condition field
        for n = 1:size(cspikes,2)
            h.(cond.tags{n}) = [h.(cond.tags{n}); h.allp.l(:,n); h.allp.patch(:,n)];
        end
        
        % --- Compute average firing rate  (spontaneous, evoked, on-transient, off)
        
        for i = 1:length(cond.values)
            tempspikes = filtspikes(spikes,0,cond.type,cond.values{i});
            wnames = fieldnames(w);
            for n = 1:length(wnames)
                temp = wnames{n};
                fr.(temp)(i) = computeFR(tempspikes,w.(temp));
            end
        end
        clear tempspikes
        
        %         % Make category plot for each time window
        %         for i = 1:length(wnames)
        %             temp = wnames{i};
        %             [h.avgfr.(temp).l h.avgfr.(temp).ax] = plotCategories(fr.(temp),cond.tags,'');
        %             setTitle(gca,temp,7);
        %         end
        %         defaultAxes(h.avgfr.spont.ax,0.1,0.48);
        
        % --- Compute OSI
        try
            tempspikes = filtspikes(spikes,0,cond.type,cond.values{i});
            wnames = fieldnames(w);
            wnames = wnames(ismember(wnames,{'stim'}));
            
            for n = 1:length(wnames)
                temp = wnames{n};
                [osi.(temp) osimod.(temp)]= orientTuningMetric(allfr.(temp),theta);
               [osi_subspont.(temp)]= orientTuningMetric(allfrsubspont.(temp),theta);                
            end
            
            clear tempspikes
            
            % Make category plot for each time window
            for i = 1:length(wnames)
                temp = wnames{i};
                [h.avgfr.(temp).l h.avgfr.(temp).ax] = plotCategories(osi.(temp),'','');
                setTitle(gca,temp,7);
            end
           
            
            setTitle(h.ori.ax,['CV: ' num2str(osi.stim,'%1.2f ')])
            
        catch ME
            getReport(ME)
        end
       
        h.ratecum.ax = helperEvoked(h,expt,spikes,cspikes);
        
        % --- Define locations in respective axes matrix
        h.mat(1).params.matpos = [0 0.68 0.49 0.35];                % [left top width height]
        h.mat(1).params.figmargin = [0.00 0 0 0.05];                % [left right top bottom]
        h.mat(1).params.matmargin = [0 0 0 0];                      % [left right top bottom]
        h.mat(1).params.cellmargin = [0.05 0.035 0.05 0.05];        % [left right top bottom]
        h.mat(1).ncol = 3;
        h.mat(1).nrow = 2;
        h.mat(1).h(1) = h.autocorr.ax;
        h.mat(1).h(2) = h.frvt.ax;
        h.mat(1).h(3) = h.ori.ax;
        h.mat(1).h(4) = h.avgwv.ax;
        h.mat(1).h(5) = h.allp.ax;
        h.mat(1).h(6) = h.ratecum.ax;
        
        h.mat(2).params.matpos = [0.49 0.68 0.18 0.28];
        h.mat(2).params.figmargin = [0 0 0 0];
        h.mat(2).params.matmargin = [0 0 0 0];
        h.mat(2).params.cellmargin = [0.03 0.03 0.02 0.02];
        h.mat(2).ncol = 2;
        h.mat(2).nrow = 2;
        h.mat(2).h(1) = h.pol.stim.ax;
        h.mat(2).h(2) = h.pol.on.ax;
%         h.mat(2).h(3) = h.npol.ax;
        h.mat(2).h(3) = h.pol.off.ax;
        
        h.mat(3).params.matpos = [0.67 0.68 0.15 0.31];
        h.mat(3).params.figmargin = [0 0 0 0];
        h.mat(3).params.matmargin = [0 0 0 0];
        h.mat(3).params.cellmargin = [0.03 0.03 0.05 0.05];
        h.mat(3).ncol = 2;
        h.mat(3).nrow = 2;
%         h.mat(3).h(2) = h.ori_subspont.stim.ax;
        h.mat(3).h(1) = h.avgfr.stim.ax;
%         h.mat(3).h(3) = h.avgfr.on.ax;
%         h.mat(3).h(4) = h.avgfr.off.ax;
%         
        % --- Place axes on axesmatrix
        for i = 1:length(h.mat)
            ind = 1:length(h.mat(i).h);
            setaxesOnaxesmatrix(h.mat(i).h,h.mat(i).nrow,h.mat(i).ncol,ind, ...
                h.mat(i).params,h.fig);
        end
        % --- Set colors
        for i = 1:length(cond.tags)
            hands = h.(cond.tags{i});
            ind = isprop(hands,'color');
            set(hands(ind),'Color',cond.color{i})
            % deal with patches seperately
            ind = isprop(hands,'facecolor');
            set(hands(ind),'facecolor',cond.color{i})
            
        end
        
        
        % --- Make info table
        genotype = expt.info.mouse.genotype;
        try
            if isfield(expt.info.transgene,'construct1')
                transgene = expt.info.transgene.construct1;
            elseif isfield(expt.info.transgene,'construct')
                transgene = expt.info.transgene.construct;
            end
        catch
            transgene = '';
        end
        
        try temp = {expt.sort.trode(trodeNum).unit.assign}; catch temp = [] ;end % newly created trode after expt was made in MakeExpt doesn't have .unit field
        temp = cell2mat(temp);
        k = find(temp == unitInd);
        unitLabel = h.label;
        try depth = getUnitDepth(expt,unitTag,maxch); catch depth = NaN; end  % BA using unitTag here which is the SORT trode is not compatible with having different sorts than probes
        exptInfo = strvcat(expt.name, [genotype ',' ' ' transgene], unitLabel,...
            num2str(depth), unitTag);
        h.textbox = annotation(h.fig,'textbox',[0.77 0.1 0.2 0.05],'String',exptInfo,...
            'EdgeColor','none','HorizontalAlignment','right','Interpreter',...
            'none','Color',[0.2 0.2 0.2],'FontSize',9,'FitBoxToText','on');
        
        
        
        % Make figure visible
        %     set([h.frvt.ax;h.frvt.l],'Visible','off')
        set(h.fig,'Visible','on')
        h.w = w;
        
        % save figure info in figure
        guidata(h.fig,h)
        
        
        
        
    end
    
    
end
set(h.fig,'Visible','on') % figure could be in visible but already exist
if b.pause
    %     reply = input('Do you want to print? y/n [n]: ', 's');
    %     if isempty(reply)
    %         reply = 'n';
    %     end
    %     if strcmp(reply,'y')
    %         b.print = 1;
    %     end
    
    reply = input('Do you want to save? y/n [n]: ', 's');
    if isempty(reply)
        reply = 'n';
    end
    if strcmp(reply,'y')
        b.save = 1;
    end
end



sname = [rigdef.Dir.Fig expt.name '_' unitTag '_Ori'];
if b.save
    desc = input('add descriptor? ', 's');
    if ~isempty(desc)
        sname = [sname '_' desc];
    end
    %     if ~strcmp(label,{'in process','garabage'})
    
    disp(['Saving' ' ' sname])
    saveas(h.fig,sname,'fig')
    export_fig(sname,'-eps',h.fig)
    %     end
end

if b.print
    print('-dwinc',h.fig)
    disp(['Printing' ' ' sname])
end

if b.close
    close(h.fig)
end

% --- Subfunctions --- %

function setRasterPSTHpos(h)

nstim = length(h.r.ax);
ncol = ceil(nstim/2);
rrelsize = 0.65;                      % Relative size PSTH to raster
prelsize = 1-rrelsize;

% Set matrix position
margins = [0.05 0.02 0.05 0.005];
matpos = [margins(1) 1-margins(2) 0.37 1-margins(4)];  % Normalized [left right bottom top]

% Set space between plots
s1 = 0.003;
s2 = 0.035;
s3 = 0.02;

% Compute heights
rowheight = (matpos(4) - matpos(3))/2;
pheight = (rowheight-s1-s2)*prelsize;
rheight = (rowheight-s1-s2)*rrelsize;

% Compute width
width = (matpos(2)-matpos(1)-(ncol-1)*s3)/ncol;

% Row positions
p1bottom = matpos(3) + rowheight;
p2bottom = matpos(3);
r1bottom = p1bottom + pheight + s1;
r2bottom = p2bottom + pheight + s1;

% Compute complete positions
for i = 1:nstim
    if i <= ncol
        col = matpos(1)+(width+s3)*(i-1);
        p{i} = [col p1bottom width pheight];
        r{i} = [col r1bottom width rheight];
    elseif i > ncol
        col = matpos(1)+(width+s3)*(i-1-ncol);
        p{i} = [col p2bottom width pheight];
        r{i} = [col r2bottom width rheight];
    end
end

% Set positions
set([h.psth.ax; h.r.ax],'Units','normalized')
set(h.psth.ax,{'Position'},p')
set(h.r.ax,{'Position'},r')




 function hAx = helperEvoked(h,expt,spikes,cspikes)
% plot distribution of spiking before stimulus (baseline)
% and during stimulation
% test sigifigance with ks test

% 
vstimpresent = expt.analysis.orientation.vstimpresent;
baseline =  vstimpresent - diff(vstimpresent); % for spontaneous firing rate
cond(1).timeInterval = baseline;
cond(1).label = 'spont';

% getStimulus Evoked spikes 
cond(2).timeInterval = vstimpresent;
cond(2).label = 'evoked';

nboot = 1000;

% for all stimuli
for icond= 1:2
    spikesCond = filtspikes(spikes,0,'spiketimes', @(x) x>cond(icond).timeInterval(1) & ...
        x<=cond(icond).timeInterval(2));
    % spikesInTrial(spikes)
    i=1;
    clear nspikes;
    for itrial = spikesCond.sweeps.trials; % find the number of spikes in each trial
        nspikes(i ) = sum(spikesCond.trials==itrial);
        i = i+1;
    end
    r = nspikes/diff(cond(icond).timeInterval) ;% spikes per sec
    
    data(icond).rate = r;
%     data(icond).bootRate = sort(bootstrp(nboot,@median,rate));
    sleg{icond} = cond(icond).label;
end

% plot the cum distributions of rates during all stimulus period and
% baseline
hAx = axes('Parent',h.fig);
line([1:length(data(1).rate)],cumsum(data(1).rate)/max(cumsum(data(1).rate)),'color','k','Parent',hAx);
hold all
line([1:length(data(2).rate)],cumsum(data(2).rate)/max(cumsum(data(2).rate)),'color','b','Parent',hAx);
set(hAx,'XTickLabel',[])

hLeg = legend(sleg);
 defaultLegend(hLeg,'SouthEast',7)
 
[~, p] = kstest2(data(1).rate,data(2).rate); % test of baseline and evoked distributions differ
setTitle(hAx,['p = ' num2str(p,'%1.2g')]);

%% for each stimulus
clear p 
icond = 2; % only need to get stimulus period we already have the baseline from above
for m= 1:size(cspikes,1)
    spikesCond = filtspikes(cspikes(m,1),0,'spiketimes', @(x) x>cond(icond).timeInterval(1) & ...
        x<=cond(icond).timeInterval(2));
    % spikesInTrial(spikes)
    i=1;
    clear nspikes;
    for itrial = spikesCond.sweeps.trials; % find the number of spikes in each trial
        nspikes(i ) = sum(spikesCond.trials==itrial);
        i = i+1;
    end
    r = nspikes/diff(cond(icond).timeInterval) ;% spikes per sec
    
    % boot strap an distribution of rates
    cspikedata(m).rate = r;
    [~, p(m)] = kstest2(data(1).rate,cspikedata(m).rate); % test of baseline and evoked distributions differ
    
    % put p-value in top right corner
    xl = get(h.psth.ax(m),'xlim');
    yl = get(h.psth.ax(m),'ylim');
    
end
% p = mafdr(p); % correction for multiple comparisons (but this is not
% required)
 
for m= 1:size(cspikes,1)
    text(xl(2),yl(2)*.98,['p = ' num2str(p(m),'%1.1g')],'FontSize',7,'HorizontalAlignment','right','Parent',h.psth.ax(m))
end


function hleg = defaultLegend(hleg,Location,Fontsize)
legend(hleg,'boxoff')
set(hleg,'Visible','off');
set(get(hleg,'Children'),'Visible','on')  ;
if nargin >2
set(hleg,'FontSize',Fontsize);
end
if nargin <2
Location  = 'Best';
end
set(hleg,'Interpreter','none','Location',Location,'Color','none');

