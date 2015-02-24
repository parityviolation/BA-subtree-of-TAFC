function [ifid plotparam] = getUnitTuning2var(spikes,unitTag,stimParam,plotparam)
rigdef = RigDefs;
analyzewindow = []; % can be made into an input later


% defaults;
if ~isfield(plotparam,'colorPSTH')
    plotparam.colorPSTH = 'b';
    plotparam.colorraster = 'k';
    plotparam.summaryLinecolor= [1 1 1]  ; % or append
    plotparam.summaryLinewidth= 1  ; % or append
    plotparam.legendDesc = '';
end
% setup plot locations
[axparams axparamsSummary axparamsSpk] = defineaxparams();

% define nCond (after they are switched)
condVal = cell(1,length(stimParam.varparam));
for i = 1: length(stimParam.varparam)
    if isnumeric(stimParam.varparam(i).Values)  % is ths a collapsed variable?
        nCond(i) = length(stimParam.varparam(i).Values);
    else nCond(i) = 1; % this takes care of case where one variable is collapsed and its variables are replaced with a string listing all values
    end
    condVal{i} = stimParam.varparam(i).Values ;
end

if length(nCond)==1 || nCond(2)==0% case of 1 stim variable only
    nCond(2) = 1; condVal{2} = NaN;
    stimParam.varparam(2).Name = '';
end

% make spike struct for each condition
clear cspikes;
for iVar1 = 1:nCond(1) % ROW
    for iVar2 = 1:nCond(2)
        icond = (iVar1-1)*nCond(2)+iVar2;
        cspikes(iVar1,iVar2) = filtspikes(spikes,0,'stimcond',icond);
    end
end

% get figure Tag based on unit and varparam names
figname = unitTag;
for i = 1:length(stimParam.varparam), figname=[figname ' ' stimParam.varparam(i).Name ' ' 'AnalysisBA_' ]; end
plotparam.plotTag = [fullfile(spikes.info.exptfile,figname)];

% find figure by tag
h.mainFigure = findobj('Tag',plotparam.plotTag);
if isempty(h.mainFigure),
    h.mainFigure = figure;
    plotparam.bclearplot = 1; % override bclearplot, figure doesn't exist can't notclear
end
if plotparam.bclearplot, clf; end % clear
% figure formatting
set(h.mainFigure,'position',[2          39        1178         919]); % MAKE rig specific
set(h.mainFigure,'Tag',plotparam.plotTag,'Name',figname,'NumberTitle','off',...
    'Visible','Off'); % turn off visibilty speeds up substantially
orient tall;
set(0,'CurrentFigure',h.mainFigure);

%add control buttons
h.headerPanel = uipanel('Parent',h.mainFigure,'Units','Normalized', ...
    'Position',[-0.005 0.965 1.01 0.035]);
h.togglePSTH = uicontrol('Parent',h.headerPanel,'Style','pushbutton','String','PSTH', ...
    'Units','normalized','Position',[0.02 0.15 0.25 0.65],'Tag','togglePSTH');
h.toggleRaster = uicontrol('Parent',h.headerPanel,'Style','pushbutton','String','Raster', ...
    'Units','normalized','Position',[0.3 0.15 0.25 0.65],'Tag','toggleRaster');
           % Add callbacks to buttons
set(h.togglePSTH,'Callback',{@togglePSTH_Callback})
set(h.toggleRaster,'Callback',{@toggleRaster_Callback})


% set(gcf,'Visible','on');
[tetIndex unitIndex] = getunitInfo(unitTag);
% plot spike wave forms
if 1
    if plotparam.bclearplot
        
        axesmatrix(2,1,1,axparamsSpk);
        if ~isempty(spikes.waveforms)
            plot_waveforms(spikes,unitIndex)
            % make pretty format
            hylabel = get(gca,'Ylabel'); title(get(hylabel,'String'));set(hylabel,'String',''); set(get(gca,'Xlabel'),'String','');
            set(gca,'Fontsize',7,'YAxisLocation','right');
            axesmatrix(2,1,2,axparamsSpk);
            plot_isi(spikes,unitIndex)
            hylabel = get(gca,'Ylabel'); title(get(hylabel,'String'));set(hylabel,'String','');set(get(gca,'Xlabel'),'String','');
            set(gca,'Fontsize',7,'ytick',[]);
        end
    end
end

% Rasterplot
if plotparam.bclearplot
    hlastAxesraster = []; hlastAxespsth= [];
    bappend =0;
else
    hlastAxesraster = sort(findobj(get(h.mainFigure,'Children'),'Tag','raster'));
    hlastAxespsth = sort(findobj(get(h.mainFigure,'Children'),'Tag','psth'));
    bappend =1;
end
[h.hAxes ph] = rasterBA(cspikes,hlastAxesraster,bappend,1);
set(ph(~isnan(ph)),'color',plotparam.colorraster);
% PSTH
binsizePSTH = 50; %ms
if ~ bappend; hlastAxespsth = h.hAxes; end   % overlay on rasterplot
[h.hPSTHAxes h.hPsth nPSTH edgesPSTH] = psthBA(cspikes,binsizePSTH,hlastAxespsth,bappend);
set(h.hPsth(~isnan(h.hPsth)),'color',plotparam.colorPSTH,'linewidth',0.2);
uistack(h.hPSTHAxes,'down');

        set(h.hAxes,'YLIM',[-5 max(cellfun(@max,get(h.hAxes,'UserData')))+1]); % y to 

if plotparam.bclearplot
    h.hlinkAxes(1) = linkprop(h.hAxes,{'YLIM','XLIM'}); % link x on raster and psth    
    h.hlinkAxes(2) = linkprop([h.hAxes h.hPSTHAxes],'XLIM'); % link x on raster and psth
    key = 'graphics_linkprop';
    setappdata(h.mainFigure,key,h.hlinkAxes);           % Store link object in first axis
end


% name Columns
stemp =condVal{2}; for i = 1:nCond(2), temp =condVal(2); set(get(h.hAxes(i),'Title'),'String',num2str(stemp(i),'%3.3g') ); end
stemp = sprintf('%s %s',stimParam.varparam(2).Name(1:min(length(stimParam.varparam(2).Name),5)) ,get(get(h.hAxes(1),'Title'),'String'));
set(get(h.hAxes(1),'Title'),'String',stemp);
% name Rows
stemp =condVal{1}; for i = 1:nCond(1), temp =condVal(2); set(get(h.hAxes((i-1)*nCond(2)+1),'ylabel'),'String',num2str(stemp(i),'%3.3g') ); end
stemp = sprintf('%s\n%s',stimParam.varparam(1).Name ,get(get(h.hAxes(1),'YLabel'),'String'));
set(get(h.hAxes(1),'YLabel'),'String',stemp);


% reposition h.hAxes to make room for summary plots
setaxesOnaxesmatrix(h.hAxes,nCond(1),nCond(2),[1:length(h.hAxes)],axparams)
setaxesOnaxesmatrix(h.hPSTHAxes,nCond(1),nCond(2),[1:length(h.hPSTHAxes)],axparams)

%%%%%%%% IN PROG BA
% mark Stimulus and mark analysis window
analyzewindow = [ 2.5 3.5];
if isempty(analyzewindow)
    % there is a delay before the LCD starts displaying hence the 0.05s
    % onset, spiking could occur after the stimulus so 0.1s is added to end
    analyzewindow = [ 0.05 min(stimParam.sparam.StimDuration+0.1, size(nPSTH,3)*binsizePSTH*1e-3)];
else
    analyzewindow(2) = min(analyzewindow(2), size(nPSTH,3)*binsizePSTH*1e-3);
end
analyzewindowbins = [max(1,analyzewindow(1)/(binsizePSTH*1e-3)) analyzewindow(2)/(binsizePSTH*1e-3)];

% draw stimulus period
%     if plotparam.bclearplot
%         Y = get(h.hAxes(1),'YLIM'); Y = [Y(1) Y(1) Y(2) Y(2)]; % order of vertices maters in patch
%         X = [0 [1 1].*stimParam.sparam.StimDuration 0];
%         hpat = patch(X,Y,[1 0 0].*0.8,'FaceAlpha',0.2,'EdgeColor','none','Parent',hAxes(1),'Tag','StimulusPeriod');
%         uistack(hpat,'bottom');
%         copyobj(hpat,hAxes(2:end))
%
%         % draw analysiswind period
%         temp = get(hAxes(1),'YLIM');
%         Y = (min(temp) - range(temp)*.01)*[1 1];
%         X =  analyzewindow;
%         hlineanal = line(X,Y,'Color','k','linewidth',2,'Parent',hAxes(1));
%         set(hAxes,'YLIM',[Y(1)*1.1 temp(2)]);
%     else % update stimuls period patch to be as long as the yaxis
%         Y = get(hAxes,'YLIM'); Y = [Y(1) Y(1) Y(2) Y(2)]; % order of vertices maters in patch
%         hpat = findobj(get(h.mainFigure,'Children'),'Tag','StimulusPeriod');
%         set(hpat,'YData',Y);
%         for i = 1:length(hpat(i)), uistack(hpat(i),'bottom'); end
%     end

if plotparam.bclearplot
    set(h.mainFigure,'Visible','On')
    Y = get(h.hAxes(1),'YLIM'); Y = [Y(1) Y(1) Y(2) Y(2)]; % order of vertices maters in patch
    X = [0 [1 1].*stimParam.sparam.StimDuration 0];
    hpat = patch(X,Y,[1 1 1].*0.65,'FaceAlpha',0.2,'EdgeColor','none','Parent',h.hAxes(1),'Tag','StimulusPeriod');
    uistack(hpat,'bottom');
    copyobj(hpat,h.hAxes(2:end))
    
        %     temp = get(h.hAxes(1),'YLIM');
    %     Y = (min(temp) - range(temp)*.02)*[1 1];
    %     X =  [0 stimParam.sparam.StimDuration];
    %     delete(findobj(h.hAxes,'Tag','vstim')); % remove old ones
    %     h.hlineanal = line(X,Y,'Color','r','linewidth',2,'Parent',h.hAxes(1),'Tag','vstim');
    %     set(h.hAxes,'YLIM',[(min(temp) - range(temp)*.03) temp(2)]);
    

    temp = get(h.hAxes(1),'YLIM');
    % draw analysiswind period lines
    delete(findobj(h.hAxes,'Tag','analysiswin')); % remove old ones
    %     Y = (min(temp) - range(temp)*.01)*[1 1];
    Y = -2*[1 1];
    X =  analyzewindow;
    h.hlineanal = line(X,Y,'Color','k','linewidth',2,'Parent',h.hAxes(1),'Tag','analysiswin');
  
    
     % TO DO add LED period (or could be ouside in getUnitTuningBA or
     % analysisgui.
     
else % set ylim on raster plots so that lines can be seen
    temp = get(h.hAxes(1),'YLIM');
    temp2 = get(findobj(h.hAxes,'Tag','analysiswin'),'YData'); if iscell(temp2), temp2 = temp2{end}; end % this really shouldn't happen, but if there is more than one figure it will.. vstim tag need to be mroe specific
    set(h.hAxes,'YLIM',[min(temp2) - range(temp)*.01 temp(2)]);
end

ratePSTH = mean(nPSTH(:, :,analyzewindowbins(1):analyzewindowbins(2)),3);
%
% % ADD BACKGROUND RATE
%
%
   unCollapsedVars =  find(cellfun(@isnumeric, condVal));
try
for i = unCollapsedVars
    %     if length(stimParam.varparam)==1 ||strfind(lower(stimParam.varparam(2).name),'spatial freq')
    if plotparam.bclearplot % make a new axes if it is a new plot
        h.hAxesSummary(i) = axesmatrix(1,2,i,axparamsSummary);
    else % use existing axes
        set(0,'ShowHiddenHandles','on')
        set(h.mainFigure,'CurrentAxes',findobj(get(h.mainFigure,'Children'),'Tag',sprintf('SummaryPlot%d',i)));
    end
    switch lower(stimParam.varparam(i).Name)
        case 'orientation'
            theta = deg2rad(condVal{i}); 
            theta(end+1) = theta(1);
            if min(size(ratePSTH))>1 % if not collapsed on 1 vstim variable
                if i==1;
                    theta = repmat(theta,size(ratePSTH,1),1)';
                    rho = [ratePSTH ratePSTH(:,1)]';
                    sl = condVal{2};
                else
                    theta = repmat(theta,size(ratePSTH,1),1)';
                    rho = [ratePSTH'; ratePSTH(:,1)'];sl = condVal{1};
                end
            else
                rho = ratePSTH;
                rho(end+1) = ratePSTH(1);
                if ~isrowvector(rho), rho = rho'; end
                sl = condVal{cellfun(@isnumeric,condVal)};
            end
            
%             if 1 % only plot polar for the condition with the most spikes
%                 [junk ind] = max(sum(rho(1:end-1,:)'))
%                  htemp = polar(theta,rho();         hpAxes = gca;hold on;
%             else
                            htemp = polar(theta,rho);         hpAxes = gca;hold on;
%             end
            set(htemp,'linewidth',plotparam.summaryLinewidth);
            % polar plot needs special formating ttreatement get rid of
            % axes etc
            % remote axes from polar plot (if it was just plotted)
            if plotparam.bclearplot
                set(0,'Showhiddenhandles','on')
                extrastuff = setdiff(get(hpAxes,'children'),htemp);
                set(extrastuff,'Visible','off');
%                set(hpAxes,'Position',get(hpAxes,'Position').*[-3*(i==1)-1 -1.5 1.5 1.5]) % make ploar axes bigger and shift over
            end
        otherwise
            if min(size(ratePSTH))>1 % if not collapsed on 1 vstim variable
                if i==1
                    xval = repmat( condVal{i}',1,size(ratePSTH,2)); sl = condVal{2};
                    yval = ratePSTH;
                else
                    xval = repmat( condVal{i},size(ratePSTH,2),1)'; sl = condVal{1};
                    yval = ratePSTH';
                end
                ColorSet = repmat(linspace(0.85,0,length(sl))'*plotparam.summaryLinecolor,1,1); % grayscale color map
                
            else
                xval = condVal{i};
                yval = ratePSTH; if ~isrowvector(yval); yval = yval'; end
                sl = condVal{cellfun(@isnumeric,condVal)};
                ColorSet = plotparam.summaryLinecolor;
            end
            set(gca, 'ColorOrder', ColorSet);
            
            hold on;
            
             htemp = line( xval,yval,'Marker','o');
             plotset(1);
             xlabel(stimParam.varparam(i).Name); ylabel('rate (hz)');
    end
    
    if plotparam.bclearplot % make a new axes if it is a new plot
        set( h.hAxesSummary(i),'Tag',sprintf('SummaryPlot%d',i)) % Tag these plots so they can be used next time the function is called
    end
    clear sleg; for j = 1:length(sl); sleg{j} = sprintf('%s %s',num2str(sl(j),'%3.3g'),plotparam.legendDesc); end % make legend strings
    hLeg(i) = legend(htemp,sleg,'Location','EastOutside');
end
helpAnnotate(spikes,unitTag,stimParam.sparam); % annotate plot with expt, unit and vstim params

catch
    'caught error'
end

ifid = h.mainFigure;
guidata(h.mainFigure,h)
% 
% set(h.mainFigure,'Visible','On');
function  helpAnnotate(spikes,unitTag,sparam)  %NESTED function (shares same workspace)

sDesc = sprintf('%s\n%s\n',unitTag,spikes.info.exptfile);
sDesc = sprintf('%s Mask %s', sDesc,sparam.Mask);
if length(unique(sparam.spfreq))==1 % report paramter if it doesn't vary
    sDesc = sprintf('%s\nSf %1.3g cpd', sDesc,sparam.spfreq);
end
if length(unique(sparam.tempFreq))==1
    sDesc = sprintf('%s\nTpf %1.1g Hz\n', sDesc,sparam.tempFreq);
end
if length(unique(sparam.orient))==1
    sDesc = sprintf('%s%3.3g Deg\n', sDesc,sparam.orient(1));
end
plotAnn( sprintf('\n\n\n\n\n%s',sDesc),[],1);

% plot

% xtime = [1:size(PSTHcond,3)]*dt;
% WOI = [0 swDurSamples-3];
%
% % integrate PSTH over analyzewindow
%
% set(gcf,'CurrentAxes',hAxes(1));                                                % analysis period
% line ([analyzewindowSamp(1)*dt analyzewindowSamp(2)*dt], [1 1].*max(YLIM)*-.02,'linewidth',2,'color','r')
% line ([0 stimParam.sparam.StimDuration], [1 1].*max(YLIM)*-.04,'linewidth',2,'color','k');% stimulus period
% set(gca,'YLIM',[max(ylim)*-.08 max(ylim)]);

% %% baseline periods is when gray background is on after
% % 100ms of the stimulus being off
% if ~isempty(stimParam.sparam.Baseline) && stimParam.sparam.Baseline
%     baselinesampWIND = round( [(stimParam.sparam.StimDuration+0.1)/dt min(size(PSTHcond,3),(stimParam.sparam.StimDuration+stimParam.sparam.Baseline)/dt)]);
% else baselinesampWIND = [NaN NaN]; end
%
%
% % % ADD handling of 2nd condition on same plot


% % ADD spike info

% % ADD
% summary of
%         polar plot if orientation tuning (if it is orientaiton
%         regular if spf or contrast
%

function [axparams axparamsSummary axparamsSpk]= defineaxparams()
axparams.matpos = [0 0.02 0.75 0.75];%         offset[left top]) , fraction [width height] of remaining figure (i.e. 1-(FIGMARG)  that is taken up by matrix(measured from WITHIN margin of figure)
axparams.figmargin = [0 0 0.010 0.01]; % margins within whole figure [ LEFT RIGHT TOP BOTTOM]
axparams.matmargin = [.03 0 0.0 0]; % margins within? whole matrix [ LEFT RIGHT TOP BOTTOM] note MATMARG, can also be thought of as position
axparams.cellmargin = [0.01 0.015 0.01 0.01]; % MARGIN around each axies (defines offset and size of each axes with a cell)

% bottom plots of CRF and ori
axparamsSummary.matpos = [ 0 0.75 1 0.25];
axparamsSummary.figmargin =  axparams.figmargin;
axparamsSummary.matmargin = [.03 0.03 0.04 0.03];
axparamsSummary.cellmargin = [0.01 0.12 0.00 0.00];

% spk plots
axparamsSpk.matpos = [.75 0.15 .25 0.5];
axparamsSpk.figmargin =  axparams.figmargin;
axparamsSpk.matmargin = [.03 0.05 0.01 0.08];
axparamsSpk.cellmargin = [0.01 0.01 0.09 0.09];

function toggleRaster_Callback(hObject,eventdata)
% Get guidata
h = guidata(hObject);

hrc = get(h.hAxes,'Children');
hrc = cellfun(@(x) findobj(x,'Type','line'),hrc,'UniformOutput',0);

if any(ismember(get(hrc{1},'Visible'),'off')) % check if is not visible
cellfun(@(x) set(x,'visible','on'),hrc,'UniformOutput',0)
set(h.hAxes,'visible','on')
else
cellfun(@(x) set(x,'visible','off'),hrc,'UniformOutput',0)
set(h.hAxes,'visible','off')
end
axis tight




function togglePSTH_Callback(hObject,eventdata)
% Get guidata
h = guidata(hObject);

hrc = get(h.hPSTHAxes,'Children');
hrc = cellfun(@(x) findobj(x,'Type','line'),hrc,'UniformOutput',0);

if any(ismember(get(hrc{1},'Visible'),'off')) % check if is not visible
cellfun(@(x) set(x,'visible','on'),hrc,'UniformOutput',0)
set(h.hAxes,'visible','on')
else
cellfun(@(x) set(x,'visible','off'),hrc,'UniformOutput',0)
set(h.hPSTHAxes,'visible','off')
end
axis tight




