function h = onlinePSTH_BA(dvHandles)
%
% INPUT
%   dvHandles: DataViewer handles
%
% OUTPUT
%   h: guidata for the PSTH figure
%
%   Created: SRO 4/30/10
%   Modified: BA 6/11/10
h.bTuning = 0;

% Rig defaults
rigdef = RigDefs;
h.FigDir = rigdef.Dir.FigOnline;   
h.FigType = 'PSTH';
h.ExptName = getappdata(dvHandles.hDaqCtlr,'ExptName');

% Get updated plot vectors from DataViewer appdata
dvplot = getappdata(dvHandles.hDataViewer,'dvplot');
h.nPlotOn = numel(dvplot.pvOn);
h.rvOn = dvplot.rvOn;

% Get channel order
ChannelOrder = getappdata(dvHandles.hDataViewer,'ChannelOrder');

% Get adjusted channel order
kv = ismember(ChannelOrder,dvplot.pvOn);
pvOnOrdered = ChannelOrder(kv);
RasterOn = ismember(pvOnOrdered,dvplot.rvOn);
RasterOn = pvOnOrdered(RasterOn);

% Get sweep length
temp = guidata(dvHandles.hDaqCtlr);
h.sweeplength = temp.aiparams.sweeplength;

% Compute bin size
h.binsize = 0.05;  % s
numEdges = ceil(h.sweeplength/h.binsize + 1);
h.edges = linspace(0,h.sweeplength,numEdges);
h.binsize = mean(diff(h.edges)); % BA binsize is may not be exactly the h.binsize defined, because of linspace.
h.xloc = h.binsize/2:h.binsize:(h.edges(end)-h.binsize/2);

% Make figure
h.psthFig = figure('Visible','off','Color',[1 1 1], ...
    'Position',rigdef.onlinePSTH.Position,'Name','PSTH','NumberTitle','off');

% Modify toolbar and menu
removeToolbarButtons(h.psthFig);
h.hSave = tb_saveFig(h.psthFig);
h.hSaveDisp = tb_saveFigDisp(h.psthFig);

% Make gui objects
h.headerPanel = uipanel('Parent',h.psthFig,'Units','Normalized', ...
    'Position',[-0.005 0.965 1.01 0.035]);
h.resetButton = uicontrol('Parent',h.headerPanel,'Style','pushbutton','String','reset', ...
    'Units','normalized','Position',[0.02 0.15 0.25 0.65],'Tag','resetButton');
h.condButton = uicontrol('Parent',h.headerPanel,'Style','pushbutton','String','cond', ...
    'Units','normalized','Position',[0.3 0.15 0.25 0.65],'Tag','condButton');

% Make axes
margins = [0.25 0.15 0.042 0.035];
axPos = dvAxesPosition(h.nPlotOn,margins);
for i = 1:length(ChannelOrder)% BA this creates an axes for each channel
    h.axs(i) = axes('Parent',h.psthFig,'Visible','off');
    DefaultAxes(h.axs(i),0.35,0.2);
    RemoveAxesLabels(h.axs(i));
    xlim([0 h.sweeplength]);
end

% default number of conditions
h.nLEDCond = 2;
h.nStimCond = 65; 
% Initialize psthData (todo update if the number of actual conditions is
% different)
ntrials = 30;
h.psthData = nan(length(ChannelOrder),h.nLEDCond,h.nStimCond,length(h.xloc),ntrials,'single');


% intialize spikes for psth
spikes.spiketimes = [];
spikes.trigger = [];
spikes.trials = [];
spikes.stimcond = [];
spikes.led = [];
spikes.sweeps.stimcond = [];
spikes.sweeps.led = [];
spikes.sweeps.trigger = [];
spikes.sweeps.trials = [];
spikes.onlineassigns = [];
spikes.analysis = [];
 h.spikesCell = cell(1);
for ichn = 1:length(ChannelOrder) % for all channels
    h.spikesCell{ichn} = spikes;
end

% h.analWindow = [0.01 0.15]; % (win to analyze in tuning TO DO get automatically
% h.analWindow = [0.05 2.05]; % (win to analyze in tuning TO DO get automatically
h.analWindow = [0.05 2.05]; % (win to analyze in tuning TO DO get automatically

% Initialize condition struct
h.cond.engage = 'off';
h.cond.type = '';
h.cond.value = [];

% Set colors for lines
h.colors{1} = [0 0 1];
h.colors{2} = [0 127/255 0];
h.colors{3} = [1 0 1];

% Make lines
for m = 1:size(h.psthData,1)
    for n = 1:size(h.psthData,2)
        for i = 1:size(h.psthData,3)            
%             tempColor = get(dvHandles.hPlotLines(m),'Color');
         tempColor = h.colors{mod(length(h.colors),n)+1};
            h.lines(m,n,i) = line('Parent',h.axs(m),'Color',tempColor,'Visible','off', ...
                'XData',h.xloc,'YData',h.psthData(m,n,i,:));
        end
    end
end

% Position axes
for i = 1:h.nPlotOn
k = pvOnOrdered(i);
    set(h.axs(k),'Position',axPos{i});
    if ~isempty(RasterOn)
        if k == RasterOn(end)
            AddAxesLabels(h.axs(k),'sec','spikes/sec')
        end
    end
end

% ********* * BA Setup Tuning Figure
% NOTE only compatible with 1 varing parameters in Vstim

if h.bTuning

h.psthTuningFig = figure('Visible','off','Color',[1 1 1], ...
    'Position',rigdef.onlinePSTH_Tuning.Position,'Name',['Tuning ' num2str(h.analWindow,'%1.2f ')],'NumberTitle','off');
% Make axes
margins = [0.25 0.15 0.042 0.035];
axPos = dvAxesPosition(h.nPlotOn,margins);
for i = 1:length(ChannelOrder)% BA this creates an axes for each channel
    h.axsTun(i) = axes('Parent',h.psthTuningFig,'Visible','off');
    DefaultAxes(h.axsTun(i),0.35,0.2);
    RemoveAxesLabels(h.axsTun(i));
end

% Make lines
for m = 1:size(h.psthData,1) % channelse
    for n = 1:size(h.psthData,2) % LED conditions
         tempColor = h.colors{mod(length(h.colors),n)+1};
%            tempColor = get(dvHandles.hPlotLines(m),'Color');
        intialConf = zeros(size(h.psthData,3),2);
        [h.linesTun(m,n), h.patchTunConf(m,n)] = boundedline([1:size(h.psthData,3)],zeros(size(h.psthData,3),1),intialConf,'-o',h.axsTun(m),'cmap',tempColor,'alpha','transparency',0.2);
        set(h.linesTun(m,n),'Visible','off');
        set(h.patchTunConf(m,n),'Visible','off');
    end
end

% Position axes
for i = 1:h.nPlotOn
    k = pvOnOrdered(i);
    set(h.axsTun(k),'Position',axPos{i});
    if ~isempty(RasterOn)
        if k == RasterOn(end)
            AddAxesLabels(h.axsTun(k),'','spikes/sec')
        end
    end
end

set(h.psthTuningFig,'Visible','on')

end
%*******************

% Add callbacks to buttons
set(h.resetButton,'Callback',{@resetButton_Callback})
set(h.condButton,'Callback',{@condButton_Callback})

% Initialize trial counter
temp = size(h.psthData);
h.trialcounter = zeros(temp(1:3));

% Make PSTHs visible
helperpsthOn_onlinePSTH_BA(h,h.rvOn)

% Make figure visible
set(h.psthFig,'Visible','on')

% Save guidata
guidata(h.psthFig,h);



% --- Subfunctions --- %
function psthOn(h,k)
set(h.axs(k),'Visible','on')
temp = h.lines(k,:,:);
set(temp(:),'Visible','on')


function resetButton_Callback(hObject,eventdata)
% Get guidata

h = guidata(hObject);

h = helperReset_onlinePSTH_BA(h);
guidata(h.psthFig,h)

function condButton_Callback(hObject,eventdata)
% Get guidata
h = guidata(hObject);

% Dialog to set conditions
prompt = {'led or stim','values'};
answer = inputdlg(prompt,'Enter',1);

% Set condition struct  % BA TO dO redesign all this 
h.cond.engage = 'on'; 
h.cond.type = answer{1};
h.cond.value = str2num(answer{2});

% Update psthData
h.nCond = length(h.cond.value); % BA old not used. 

h.psthData = zeros(size(h.psthData,1),h.nLEDCond,h.nStimCond,length(h.xloc),'single');

% Update lines
try delete(h.lines(:)); end
%  Make lines
for m = 1:size(h.psthData,1)
    for n = 1:size(h.psthData,2)
        for i = 1:size(h.psthData,3)            
        tempColor = h.colors{mod(length(h.colors),n)+1};
            h.lines(m,n,i) = line('Parent',h.axs(m),'Color',tempColor,'Visible','off', ...
                'XData',h.xloc,'YData',h.psthData(m,n,i,:));
        end
    end
end

% Make PSTHs visible
psthOn(h,h.rvOn)


% Initialize trial counter
temp = size(h.psthData);
h.trialcounter = zeros(temp(1:3));

guidata(hObject,h)
