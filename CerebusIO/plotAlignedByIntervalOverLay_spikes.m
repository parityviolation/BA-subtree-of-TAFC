function h = plotAlignedByIntervalOverLay_spikes(spikes,alignEvent,WOIin,ElectUnit,options)
% function h = plotAlignedByIntervalOverLay_spikes(spikes,alignEvent,ElectUnit,options)
%
% plots Raster and PSTH for each stimulus interval aligned on alignEvents

r = brigdefs;


WOI   = [-0.5 3]*1000; % ms
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

if ~isfield(options,'cond')
    options.cond(1).sweepsf      = {};
end


if ~isfield(options,'bGTInterval') % include intervals greater than or equal to the current one.
    options.bGTInterval      = 0;
end

if ~isfield(options,'BINSIZE')
    options.binsize = 20;
end
% psth.. size of bins for psth (ms)
if ~isfield(options,'NSMOOTH')
    options.nsmooth = round(200/ options.binsize);  % psth...number of neighboring points to use in moving average
end
if ~isfield(options,'BOOTSTRAP')
    options.bootstrap = 0;
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

bplotspikewave = 0;
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
savefile = sprintf('%s_Overlay_AL%s_%s_E%d_U%d_GTInterval%d',options.Desc,alignEvent, sDate,Electrode,UnitID,options.bGTInterval   );
sAnn = savefile;


%plot params
clear h
sVisibility = 'off';
h.fig = figure('Position',[    1114         464         554         518],...
    'Name',savefile, 'NumberTitle','off','Visible',sVisibility);
stimLineColor = [1 1 1]*0.5;

ncond = length(options.cond);
nInterval = length(spikes.sweeps.IntervalSet);
plotnRow = ncond;
plotnCol = 1;

mycolor1 = hot(nInterval/2+4);mycolor2 = cool(nInterval/2+4);
mycolor = [mycolor1(1:nInterval/2,:); mycolor2(1:nInterval/2,:) ];
clear hPsth hRaster cond
optionsPsth = options;
optionsRaster = options;
for icond = 1:ncond
    thisSweepf =  options.cond(icond).sweepsf;
    
    optionsPsth.hAx = axes('parent',h.fig);hold(optionsPsth.hAx ,'on');
    hAxPsth(icond)= optionsPsth.hAx ;
    
    optionsRaster.hAx = axes('parent',h.fig);hold(optionsRaster.hAx ,'on');
    hAxRaster(icond)= optionsRaster.hAx ;
    
    clear tempcond
    for iInterval = 1:nInterval
        tempcond(iInterval).spikesf = spikesf;
        tempcond(iInterval).alignEvent  = alignEvent;
        
        if options.bGTInterval      == 0;
            f = @(x) x == spikes.sweeps.IntervalSet(iInterval);
        else
            f = @(x) x >= spikes.sweeps.IntervalSet(iInterval);
        end
        tempcond(iInterval).sweepsf     = {thisSweepf{:},'Interval',f};
        
        tempcond(iInterval).plotparam.scolor = mycolor(iInterval,:);
        tempcond(iInterval).plotparam.endline = spikes.sweeps.IntervalSet(iInterval)*spikes.sweeps.Scaling/1000;
        %         cond(icond).plotparam.endlinedotted = WOI(2)/1000;
    end
    optionsPsth.plottype = {'psth'};
    htemp  = psthCondSpikes(spikes,tempcond, WOI, optionsPsth);
    
     % add gray area marking first to last tone.
    for iInterval = 1:nInterval
        w = spikes.sweeps.IntervalSet(iInterval)*spikes.sweeps.Scaling/1000;
        if ismember(alignEvent ,{'tone2Time'}),           w = -w;        end
        if ismember(alignEvent,{'tone2Time','TrialInit',}),        addStimulusBox(hAxPsth(icond), [w 0.01],'',stimLineColor) ;       end
    end
    
    optionsRaster.plottype = {'rasterplot'};
    htemp  = psthCondSpikes(spikes,tempcond, WOI, optionsRaster);
    set(htemp.hAx,'xlim',[-WOI(1) WOI(2)]/1000);
    hEvent = htemp.hEvent;
    
     % add gray area marking first to last tone.
    for iInterval = 1:nInterval
        w = spikes.sweeps.IntervalSet(iInterval)*spikes.sweeps.Scaling/1000;
        if ismember(alignEvent ,{'tone2Time'}),           w = -w;        end
        if ismember(alignEvent,{'tone2Time','TrialInit'}),        addStimulusBox(hAxRaster(icond), [w 0.01],'',stimLineColor) ;       end
    end
    if plotnCol == icond % create Event Tick Legends
        clear sleg;
        for iEvent = 1:length(options.dpFieldsToPlot), sleg{iEvent} = options.dpFieldsToPlot{iEvent}; end
        hlegEvent = legend(hAxRaster(icond),hEvent,sleg);
    end
    if isfield(options.cond(icond),'sDesc')
        setTitle([hAxPsth(icond)],options.cond(icond).sDesc,12);
    end
    
    
end
setTitle([hAxRaster],'');
setYLabel(hAxPsth,'spikes/s');

%
set(hAxRaster,'color','none');
set(hAxPsth,'color','none');
linkaxes([hAxRaster hAxPsth],'x')

%  remove xaxis from all but the bottom
setXLabel(hAxPsth,'');
% setYLabel(hAxPsth,'');
set(hAxPsth,'XTickLabel','');
% set(hAxRaster(2:end),'XTickLabel','');
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
h.mat(2).params.matpos = [0.05 .48 0.95 0.48];
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
    %     export_fig(h.fig,fullfile(savepath,savefile),'-pdf')
    plot2svg(fullfile(savepath,[savefile,'.svg']),h.fig)
    saveas(h.fig,fullfile(savepath,savefile))
end
