function h = plotAlignedByInterval_spikes(spikes,alignEvent,WOIin,ElectUnit,options)
% function h = plotAlignedByInterval_spikes(spikes,alignEvent,ElectUnit,options)
%
% plots Raster and PSTH for each stimulus interval aligned on alignEvents

r = brigdefs;


WOI   = [0.5 3]*1000; % ms
if exist('WOIin','var')
    if ~isempty(WOIin)
        WOI = WOIin;
    end
end


spikesf = {}; Electrode = NaN; UnitID = NaN;
if exist('ElectUnit','var')
    if ~isempty('ElectUnit')
        Electrode = ElectUnit(1); UnitID = ElectUnit(2);
        spikesf =  {'Electrode',ElectUnit(1),'Unit',ElectUnit(2)};
    end
end



if ~exist('options','var')
    options = struct();
end
if ~isfield(options,'BINSIZE')
    options.BINSIZE = 20;
end
% psth.. size of bins for psth (ms)
if ~isfield(options,'NSMOOTH')
    options.NSMOOTH = round(200/ options.BINSIZE);  % psth...number of neighboring points to use in moving average
end
if ~isfield(options,'BOOTSTRAP')
    options.BOOTSTRAP = 0;
end
if ~isfield(options,'hAx')
    options.hAx =[];
end
if ~isfield(options,'sortSweepsByARelativeToB')
   options.sortSweepsByARelativeToB{1} = 'firstSidePokeTime';
   options.sortSweepsByARelativeToB{2} = 'TrialInit';
end
if ~isfield(options,'dpFieldsToPlot'),
    options.dpFieldsToPlot = {'firstSidePokeTime'}; end
if ~isfield(options,'dpFieldsToPlotColor'),
    options.dpFieldsToPlotColor = {'k'};
end

if ~isfield(options,'bsave'),
    options.bsave=0 ;end

if options.bsave
    bsave = 1;
    options.bsave = 0; % so it is not saved in plotConSpikes
else
    bsave = 0;
end

if ~isfield(options,'bplotspikewave'),
    options.bplotspikewave=0 ;end

if options.bplotspikewave % must be turned off so that psthCondplot doesn't do the plotting 
    options.bplotspikewave =0;
    bplotspikewave = 1;
end

if ~isfield(options,'Desc')
    options.Desc = '';
end

sAnimal = spikes.sweeps.Animal;
sDate = spikes.sweeps.Date;
savepath = fullfile(r.Dir.EphysFigs,sAnimal,'PSTH');
parentfolder(savepath,1);
savefile = sprintf('%s_AL%s_%s_E%d_U%d%s%s ',options.Desc,alignEvent, sDate,Electrode,UnitID );
sAnn = savefile;


%plot params
clear h
sVisibility = 'off';
h.fig = figure('Position',[   1114          40         554         942],...
    'Name',savefile, 'NumberTitle','off','Visible',sVisibility);
stimBoxColor = [1 1 1]*0.5;

nInterval = length(spikes.sweeps.IntervalSet);
plotnCol = round(nInterval/2);
plotnRow = 2;

clear hPsth hRaster cond
for iInterval = 1:nInterval
    icond = 1;
    cond(icond).spikesf     = spikesf;
    cond(icond).sweepsf     = {'ChoiceLeft',0,'Interval',spikes.sweeps.IntervalSet(iInterval),'Premature' 0};
    cond(icond).alignEvent  = alignEvent;
    % cond(icond).alignEvent= 'firstSidePokeTime';
    if spikes.sweeps.IntervalSet(iInterval) < 0.5
        cond(icond).plotparam.scolor = 'g';
        cond(icond).sDesc       = ['Correct'];
        
    else
        cond(icond).plotparam.scolor = 'r';
        cond(icond).sDesc       = ['Error'];
    end
    icond = 2;
    cond(icond).spikesf     = cond(1).spikesf;
    cond(icond).sweepsf     = {'ChoiceLeft',1,'Interval',spikes.sweeps.IntervalSet(iInterval),'Premature' 0};
    cond(icond).alignEvent  = cond(1).alignEvent;
    cond(icond).sDesc       = ['Long'];
    % green is CORRECT, red is WRONG
    if spikes.sweeps.IntervalSet(iInterval) > 0.5
        cond(icond).plotparam.scolor = 'g';
        cond(icond).sDesc       = ['Correct'];
    else
        cond(icond).plotparam.scolor = 'r';
        cond(icond).sDesc       = ['Error'];
    end
    
    options.hAx = axes('parent',h.fig);hold(options.hAx ,'on');
    options.plottype = {'psth'};
    
    htemp  = psthCondSpikes(spikes,cond, WOI, options);
    
    hAxPsth(iInterval)= options.hAx ;
    %hpsth = htemp.hpsth;
    % add gray area marking first to last tone.
    w = spikes.sweeps.IntervalSet(iInterval)*spikes.sweeps.Scaling/1000;
    if isequal(alignEvent ,'tone2Time')
        x = -1*w;
    else
        x = 0;
    end
    if ismember(alignEvent,{'tone2Time','TrialInit'})
        addStimulusBox(hAxPsth(iInterval), [x w],'',stimBoxColor) ;
    end
    if iInterval==plotnCol  % add legend to PSTH plot
        clear sleg;
        for icond = 1:length(cond), sleg{icond} = cond(icond).sDesc; end
       % hlegPsth = legend(hAxPsth(iInterval),hpsth,sleg);
    end
    
    options.hAx = axes('parent',h.fig); hold(options.hAx ,'on');
    options.plottype = {'rasterplot'};
    htemp  = psthCondSpikes(spikes,cond, WOI, options);
    set(htemp.hAx,'xlim',[-WOI(1) WOI(2)]/1000);
    hEvent = htemp.hEvent;
    
    hAxRaster(iInterval) = options.hAx ;
    if ismember(alignEvent,{'tone2Time','TrialInit'}) % 
        addStimulusBox(hAxRaster(iInterval), [x w],'',stimBoxColor) ;
    end   
    if iInterval==plotnCol % create Event Tick Legends
        clear sleg;
        for iEvent = 1:length(options.dpFieldsToPlot), sleg{iEvent} = options.dpFieldsToPlot{iEvent}; end
        hlegEvent = legend(hAxRaster(iInterval),hEvent,sleg);
    end
    
    setTitle([hAxPsth(iInterval)],num2str(spikes.sweeps.IntervalSet(iInterval)*spikes.sweeps.Scaling/1000,'%1.2f'));
    
end

setTitle([hAxRaster],'');
setYLabel(hAxPsth(1:plotnRow:end),'spikes/s');

%
set(hAxRaster,'color','none');
set(hAxPsth,'color','none');

%  remove xaxis from all but the bottom
setXLabel(hAxPsth,'');
setYLabel(hAxPsth,'');
set(hAxPsth(2:end),'XTickLabel','');
set(hAxRaster(2:end),'XTickLabel','');
plotAnn(sAnn,h.fig)


% put axes in the right place
% PSTH
h.mat(1).params.matpos = [0.05 0.03 0.95 0.5];
h.mat(1).params.figmargin = [0 0 0 0];
h.mat(1).params.matmargin = [0 0 0 0];
h.mat(1).params.cellmargin = [0.03 0.06 0.05 0.05];
h.mat(1).ncol = plotnCol;
h.mat(1).nrow = plotnRow;
h.mat(1).h(1,:) = hAxPsth;
% % RASTER
h.mat(2).params.matpos = [0.05 .5 0.95 0.5];
h.mat(2).params.figmargin = [0 0 0 0];
h.mat(2).params.matmargin = [0 0 0 0];
h.mat(2).params.cellmargin = [0.03 0.06 0.05 0.05];
h.mat(2).ncol = plotnCol;
h.mat(2).nrow = plotnRow;
h.mat(2).h(1,:) = hAxRaster;

% --- Place axes on axesmatrix
for i = 1:length(h.mat)
    ind = 1:length(h.mat(i).h);
    setaxesOnaxesmatrix(h.mat(i).h,h.mat(i).nrow,h.mat(i).ncol,ind, ...
        h.mat(i).params,h.fig);
end


%format Legend
%defaultLegend(hlegPsth,[],7)
defaultLegend(hlegEvent,[],7)

if bplotspikewave
    plotSpikeWave(spikes,Electrode,UnitID,1);
end
set(h.fig,'Visible','on')
% remove xaxis from top

if bsave
    export_fig(h.fig,fullfile(savepath,savefile),'-pdf')
    saveas(h.fig,fullfile(savepath,savefile))
end
