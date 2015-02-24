function [h ntrialAtThisCond data]= psthCondSpikes(spikes,cond, WOI, options)
% BA 012014
% multiple purpose PSTH conditional on sweeps
% also plots and sorts based on Events in  spikes.sweeps
%
% e.g.
% Electrode = 42;
% UnitID = 1;
% WOI  = [1 9]*1000; % ms
% icond = 1
% cond(icond).spikesf = {'Electrode',Electrode,'Unit',UnitID};
% cond(icond).sweepsf   = {'ChoiceLeft',1,'IntervalPrecise',sweeps.IntervalSet(1)*sweeps.Scaling};
% cond(icond).alignEvent= 'TrialInit'; % NOTE Times must be relative to the beginning of the session
% cond.plotparam.scolor = 'b';
% icond = 2
% cond(icond).spikesf = cond(1).spikesf;
% cond(icond).sweepsf   = {'ChoiceLeft',0,'IntervalPrecise',sweeps.IntervalSet(1)*sweeps.Scaling};
% cond(icond).alignEvent= 'TrialInit';
% cond(icond).plotparam.scolor = 'r';

% figure('Position',[  1108         559         560         420]);

bverbose = 0;
syncEvent = 'TrialAvail';
syncEventEphys = 'TrialAvailEphys';

data.psth =  [];
if isempty(cond)
    icond = 1;
    cond(icond).spikesf = {};
    cond(icond).sweepsf   = {};
    cond(icond).alignEvent= 'TrialInit'; % NOTE Times must be relative to the beginning of the session
    cond.plotparam.scolor = 'b';
end
if ~exist('options','var')
    options = struct();
end
if ~isfield(options,'plottype')
    options.plottype = {'psth','rasterplot'};
end

if ~isfield(options,'BINSIZE')&~isfield(options,'binsize')
    options.binsize = 20;
end
% psth.. size of bins for psth (ms)
if ~isfield(options,'NSMOOTH')&~isfield(options,'nsmooth')
    options.nsmooth = round(50/ options.binsize);  % psth...number of neighboring points to use in moving average
end
if ~isfield(options,'BOOTSTRAP')&~isfield(options,'bootstrap')
    options.bootstrap = 0; % THIS IS BROKEN
end
if ~isfield(options,'dpFieldsToPlot'),
    options.dpFieldsToPlot = {}; end

if ~isfield(options,'dpFieldsToPlotColor'),
    %      a = lines(length( options.dpFieldsToPlot));
    %     options.dpFieldsToPlotColor = mat2cell(a, ones(1, size(a, 1)), size(a, 2)); % convert to cells
    options.dpFieldsToPlotColor  = {'k','c','g','y'};
end
% options.sortSweepsByARelativeToB= {event,alignEvent};

if ~isfield(options,'bplotspikewave')
    options.bplotspikewave = 0;
end
if ~isfield(options,'bsave')
    options.bsave = 1;
end
if ~isfield(options,'savefile')
    options.savefile = '';
end

sAnn = options.savefile;

extraWOI = 0;
if options.nsmooth % make WOI larger for smoothing
    extraWOI = options.nsmooth*2*options.binsize;
end

% create labels
if ~isfield(cond,'sDesc')
    for icond = 1:length(cond)
        cond(icond).sDesc = '';
        for ifld = 1:length(cond(icond).sweepsf)
            thisFieldValue = cond(icond).sweepsf{ifld};
            if isa(thisFieldValue,'float')
                cond(icond).sDesc = sprintf('%s %1.2f',cond(icond).sDesc,thisFieldValue);
            elseif  isa(thisFieldValue,'string')
                cond(icond).sDesc = sprintf('%s %s',cond(icond).sDesc,thisFieldValue);
            else
                cond(icond).sDesc = sprintf('%s Unkn',cond(icond).sDesc);
            end
        end
    end
end
if ~isfield(cond,'plotparam')
  for icond = 1:length(cond)
        cond(icond).plotparam = [];
  end
end



% plotting Params
nr = length(options.plottype );
nc = 1;
h.hAx = [];

h.fig =[];
h.hAnn = [];
if options.bplot
    if ~isfield(options,'hAx')
        h.fig = figure( 'Name',options.savefile, 'NumberTitle','off','Visible','off');
        h.hAnn = plotAnn(options.savefile, h.fig );
    else
        h.fig = gcf;
    end
end
try
    trialsplotted = 0;
    
    ntrialAtThisCond = zeros(1,length(cond));
    for icond = 1:length(cond)
        iplt = 1;
        % filters for this condition
        spikesf = cond(icond).spikesf;
        if isfield(cond,'sweepsf'), sweepsf = cond(icond).sweepsf;
        else       sweepsf = {};   end
        if isfield(cond,'trialRelsweepsf'), trialRelsweepsf = cond(icond).trialRelsweepsf;
        else        trialRelsweepsf = {}; end
        % find the trials you want
        these_spikes = filtspikes(spikes,0,spikesf,sweepsf,trialRelsweepsf);
        these_spikes.spikeNumber = [1:length(these_spikes.spiketimes)];
        
        these_sweeps = these_spikes.sweeps;
        
        ntrialAtThisCond(icond)= length(these_spikes.sweeps.TrialNumber);
        
        if isfield(options,'sortSweepsByARelativeToB')
            if ~isempty(options.sortSweepsByARelativeToB)
                if bverbose
                    s = sprintf('\t sweeps sorted by %s relative to %s',options.sortSweepsByARelativeToB{1},options.sortSweepsByARelativeToB{2});
                    disp(s);
                end
                these_sweeps =  sortdpByTimeRelativeTo(these_sweeps,options.sortSweepsByARelativeToB{1},options.sortSweepsByARelativeToB{2});
            end
        end
        these_sweeps = addTimeRelativeTo(these_sweeps,options.dpFieldsToPlot,cond(icond).alignEvent,these_sweeps.ephysTimeScalar);
        % get time in Sweep for events to be plotted
        
        tempoptions.syncEventEphys = syncEventEphys;
        tempoptions.syncEvent = syncEvent;
        
        if isfield(cond(icond),'WOI')           thisWOI = cond(icond).WOI;
        else thisWOI = WOI; end
            
        [spikeTimeRelativeToEvent trials] = relativeSpiketimes_spikes(these_spikes,cond(icond).alignEvent,[thisWOI(1)+extraWOI thisWOI(2)+extraWOI],tempoptions);
        
        
        %     % these_spikes.spiketimesRelativeEvent = [1];
        %     spikeTimeRelativeToEvent = [];
        %     trials = [];
        %     for itrial = 1:these_sweeps.ntrials
        %         eventTime = these_sweeps.(cond(icond).alignEvent)(itrial); % ms
        %         eventTimeEphys = these_sweeps.(syncEventEphys)(itrial) +...
        %             (eventTime - these_sweeps.(syncEvent)(itrial))*these_sweeps.ephysTimeScalar; %ms
        %
        %         % get indices of spikes in the WOI
        %         spikeIndex = [find(these_spikes.spiketimes >= (eventTimeEphys -(WOI(1)+extraWOI)) &...
        %             these_spikes.spiketimes <= (eventTimeEphys +(WOI(2))+extraWOI))];
        %         spikeTimeRelativeToEvent = [spikeTimeRelativeToEvent these_spikes.spiketimes(spikeIndex) - eventTimeEphys];
        %         trials = [trials; itrial*ones(length(spikeIndex),1)];
        %     end
        
        if  ismember('psth',options.plottype)
            hold all;
            
            if isfield(options,'hAx')
                hAxpsth=options.hAx(1);
            elseif options.bplot==0
                hAxpsth = -1;
            else
                hAxpsth = subplot(nr,nc,iplt);
                set(hAxpsth,'parent',h.fig);
            end
            
            h.hAx(end+1) = hAxpsth;
            [temphpsth,~,tempPsth,centers,edges,hpp] = psthSpikes([spikeTimeRelativeToEvent/1000 trials],...
                options.binsize ,hAxpsth, options.nsmooth,options.bootstrap,thisWOI/1000,cond(icond).plotparam);
            iplt = iplt+1;
            if options.bplot
                h.hpsth(icond) = temphpsth;                 h.hPsthpatch(icond) = hpp;
            else                h.hpsth(icond) = NaN;                 h.hPsthpatch(icond) = NaN; end
            
            axis tight
            if nargout >2
                data.center = centers;
                data.edges = edges;
                data.psth = cat(1,data.psth,tempPsth); % this will break if WOIs of different total lengths are specified
            end
        else
            h.hpsth(icond)  = NaN;
        end
        
        if ismember('rasterplot',options.plottype)
            plotparam = cond(icond).plotparam;
            if isfield(options,'hAx')
                plotparam.hAx=options.hAx(end);
            else
                plotparam.hAx = subplot(nr,nc,iplt);
            end
            h.hAx(end+1) =  plotparam.hAx;
            h.hraster(icond) = rasterplot(spikeTimeRelativeToEvent/1000,trials,cond(icond).plotparam);
            set(h.hAx(end) ,'xlim',[-thisWOI(1) thisWOI(2)]/1000);
            
            % plot events
            thisEventTime = 0;
            h.hEvent = [];
            for ifld = 1:length(options.dpFieldsToPlot)
                pp.scolor = options.dpFieldsToPlotColor{ifld};
                pp.bAppend= 0;
                pp.hAx =  plotparam.hAx;
                thisEventTime = these_sweeps.([options.dpFieldsToPlot{ifld} '_EphysRelativeTime_' cond(icond).alignEvent ]);%  time of Eventto plot in Trial (arduino time)
                h.hEvent(ifld) = rasterplot(thisEventTime/1000,trialsplotted+[1:length(thisEventTime)],pp);
                set(h.hEvent(ifld),'linewidth',2.5);
            end
            trialsplotted = trialsplotted+length(thisEventTime);
            
        else
            h.hraster(icond)  = NaN;
        end
        
        
    end
    
    if  ismember('test',options.plottype) % NOTE you can't pass in hAx with this plot type
        thisoptions = options;
        thisoptions.binsize = thisoptions.binsize /1000;
        thisoptions.WOIoverlap = thisoptions.binsize;
        
        [p WOIcenters endWOIs] = compareCondPSTH_spikes(spikes,cond(1).alignEvent,cond,thisoptions);
        
        hAx(3) = subplot(nr,1,3);
        plot(endWOIs,[p],'linewidth',1.5)
        sleg = {'p'};
        defaultAxes(hAx(3));
        hleg = legend(sleg);
        defaultLegend(hleg);
        set(hAx(3),'color','none')
        
        % highlight signifigance
        p(p > 0.05) = NaN;
        hl = line(endWOIs,p,'linewidth',2.5,'color','g','linestyle','none','marker','.','markersize',10)
        uistack(hl,'top');
        title(thisoptions.test);
    end
    
    if options.bplot
        if options.bplotspikewave
            these_spikes = filtspikes(spikes,0,spikesf);
            plotSpikeWave(these_spikes,[],[],1);
        end
        
        
        for i = 1:length( h.hAx)
            yl = get(h.hAx(i),'ylim');
            hl = line([0 0],yl,'Linestyle','-','color',[1 1 1]*1,'Parent',h.hAx(i));
        end
        
        h.hAx = unique(h.hAx);
        
        setTitle(h.hAx(1),cond(1).alignEvent);
        
        
        if ~isfield(options,'hAx')
            set(h.fig,'Visible','on')
        end
        if options.bsave
            r = brigdefs;
            sAnimal = spikes.sweeps.Animal;
            savepath = fullfile(r.Dir.EphysFigs,sAnimal,'PSTH');
            parentfolder(savepath,1);
            %     export_fig(h.fig,fullfile(savepath,options.savefile),'-pdf')
            plot2svg(fullfile(savepath,options.savefile),h.fig)
            saveas(h.fig,fullfile(savepath,options.savefile))
            disp([ 'saved to ' fullfile(savepath,options.savefile)])
        end
    end
catch ME
    getReport(ME)
    set(h.fig,'Visible','on')
end

