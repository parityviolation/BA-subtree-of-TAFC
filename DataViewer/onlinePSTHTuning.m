function h = onlinePSTHTuning(dvHandles)
%
% INPUT
%   dvHandles: DataViewer handles
%
% OUTPUT
%   h: guidata for the PSTH figure
%
%   Created: BA 9/12/10

% Rig defaults
rigdef = RigDefs;
h.FigDir = rigdef.Dir.FigOnline;
h.FigType = 'PSTHTune';
h.ExptName = getappdata(dvHandles.hDaqCtlr,'ExptName');

h.hDataViewer = dvHandles.hDataViewer;
h.hDaqCtlr = dvHandles.hDaqCtlr;
h.dv_hPlotLines =dvHandles.hPlotLines;

showAllYAxes = getappdata(h.hDataViewer, 'showAllYAxes');

% Make figure
h.psthFigTuning = figure('Visible','off','Color',[1 1 1], ...
    'Position',rigdef.onlinePSTHTuning.Position,'Name','PSTH Tune','NumberTitle','off');

% Modify toolbar and menu
removeToolbarButtons(h.psthFigTuning);
h.hSave = tb_saveFig(h.psthFigTuning);
h.hSaveDisp = tb_saveFigDisp(h.psthFigTuning);
h.hToggleYAxes = tb_addToolbarButton(h.psthFigTuning, 'file_save.png', 'toggle', @toggleYAxesButton_ClickedCallback);

% Make gui objects
h.headerPanel = uipanel('Parent',h.psthFigTuning,'Units','Normalized', ...
    'Position',[-0.005 0.965 1.01 0.035]);
h.resetButton = uicontrol('Parent',h.headerPanel,'Style','pushbutton','String','reset', ...
    'Units','normalized','Position',[0.02 0.15 0.25 0.65],'Tag','resetButton');
h.condButton = uicontrol('Parent',h.headerPanel,'Style','pushbutton','String','cond', ...
    'Units','normalized','Position',[0.3 0.15 0.25 0.65],'Tag','condButton');
h.newButton = uicontrol('Parent',h.headerPanel,'Style','pushbutton','String','new', ...
    'Units','normalized','Position',[0.58 0.15 0.25 0.65],'Tag','newButton');

% get margins for axes
if isfield(rigdef.onlinePSTHTuning,'axesmargins')
    margins = rigdef.onlinePSTHTuning.axesmargins;
else
    margins = [0.25 0.15 0.042 0.035];
end

% Initialize condition struct
h.cond.engage = 'on';
h.cond.type = 'led';
h.cond.value = [0 1];
h.nCond = length(h.cond.value); % LED

% Set colors for lines
h.colors{1} = [0 0 1];
h.colors{2} = [0 127/255 0];
h.colors{3} = [1 0 1];

% bins
h.binsize = 0.1;  % s


guidata(h.psthFigTuning,h)
h = resetPSTHlines(h.psthFigTuning);

% Add callbacks to buttons
set(h.resetButton,'Callback',{@resetButton_Callback});
set(h.condButton,'Callback',{@condButton_Callback});
set(h.newButton,'Callback',{@newButton_Callback,dvHandles,h.psthFigTuning});

% sync 'toggle Y axes' button w/ rest
states = {'Off', 'On'};
set(h.hToggleYAxes, 'State', states{showAllYAxes+1});

% Get channel order
ChannelOrder = getappdata(h.hDataViewer,'ChannelOrder');

% Add ticks
for i = 1:length(ChannelOrder)
    if showAllYAxes
        % Put 2 ticks on y-axis
        setAxisTicks(h.axs(i));
    end
end

% Make figure visible
set(h.psthFigTuning,'Visible','on');

% Save guidata
guidata(h.psthFigTuning,h);



% --- Subfunctions --- %

function psthOn(h,k)
set(h.axs(k),'Visible','on')
set(h.lines(k,:),'Visible','on')

function psthOff(h,k)
set(h.axs(k),'Visible','off')
set(h.lines(k,:),'Visible','off')

function newButton_Callback(hObject,eventdata,handles,psthFigH)
% Added KR 6/30/10
% This callback remakes entire figure, so newly threshold-ed channels are included
% onlinePSTHTuning queries DaqPlotChooser for channels with Threshold ON

% Close this figure
close(psthFigH);
handles.psthTune=[];

% Remake figure
handles.psthTune = onlinePSTHTuning(handles);
guidata(handles.hDataViewer,handles);

function resetButton_Callback(hObject,eventdata)
resetPSTHlines(hObject);


function condButton_Callback(hObject,eventdata)
% Get guidata
h = guidata(hObject);

% Dialog to set conditions
prompt = {'led or stim','values'};
answer = inputdlg(prompt,'Enter',1);

% Set condition struct
h.cond.engage = 'on';
h.cond.type = answer{1};
h.cond.value = str2num(answer{2});

% Update psthData
h.nCond = length(h.cond.value);
h.psthData = cell(h.nPlotOn,h.nCond);

guidata(hObject,h);
% Update lines
resetPSTHlines(hObject)

function toggleYAxesButton_ClickedCallback(hObject, eventdata)
h = guidata(hObject);
state = get(hObject, 'State');
showAllYAxes = strcmpi(state, 'on');

for i = 2:length(ChannelOrder)
    if showAllYAxes
        set(h.axs(i), 'YTickLabelMode', 'auto');
    else
        set(h.axs(i), 'YTickLabel', []);
    end
end
function h = refreshOnlineAnalysis(hObject)%%
% NOT QUITE WORKING
% function h = resetPSTHlines(hObject)%%
h = guidata(hObject);

flagReset = 0;
vstim = getappdata(h.hDataViewer,'vstim');
if isfield(h,'nstimcond1') % check if axes need to be recreated (if nstimcond1 has changed, or doesn't exist
    if h.nstimcond1 ~=length(vstim.VarParam(1).Values); % if
        flagReset = 1;
        try delete(h.axs(:)); end
    end
else flagReset = 1; end
if flagReset
    h = resetPSTHlines(hObject);
else
    
    dvplot = getappdata(h.hDataViewer,'dvplot');
    nPlotOn = numel(dvplot.pvOn);
    h.nPlotOn = nPlotOn;
    h.rvOn = dvplot.rvOn;
    % Get channel order
    ChannelOrder = getappdata(h.hDataViewer,'ChannelOrder');
    
    % Get adjusted channel order
    kv = ismember(ChannelOrder,dvplot.pvOn);
    pvOnOrdered = ChannelOrder(kv);
    RasterOn = ismember(pvOnOrdered,dvplot.rvOn);
    h.RasterOn = pvOnOrdered(RasterOn);
    
    %  % Position axes
    nAxesRow = length(h.RasterOn); % look up number of visible channels
    if h.RasterOn % no nothing if no rasters are enabled
        nAxesCol = h.nstimcond1;
        axsToPlot = h.axs(h.RasterOn,:)';
        params.figmargin = [0.01 0.01  0.04  0.01 ];
        params.cellmargin = [0.01 0.01  0.01  0.01 ];
        setaxesOnaxesmatrix(axsToPlot(:),nAxesRow,nAxesCol,[1:nAxesRow*nAxesCol],params,h.psthFigTuning);
        AddAxesLabels(h.axs(end,1),'sec','spikes/sec');
    else
        disp('*********** Cannot create PSTH: No Thresholding is enabled *************')
    end
    
    % Make PSTHs visible
    
    % BA make INVISSIBLE PLOTS THAT ARE OFF
    rvOff = ones(1,nPlotOn);
     rvOff(h.rvOn) = 0;
     rvOff = find(rvOff);
    psthOff(h,rvOff)
    
    psthOn(h,h.rvOn)
end
function h = resetPSTHlines(hObject)%%
h = guidata(hObject);

% Get updated plot vectors from DataViewer appdata
dvplot = getappdata(h.hDataViewer,'dvplot');
nPlotOn = numel(dvplot.pvOn);
h.nPlotOn = nPlotOn;
h.rvOn = dvplot.rvOn;

% Get channel order
ChannelOrder = getappdata(h.hDataViewer,'ChannelOrder');

% Get adjusted channel order
kv = ismember(ChannelOrder,dvplot.pvOn);
pvOnOrdered = ChannelOrder(kv);
RasterOn = ismember(pvOnOrdered,dvplot.rvOn);
h.RasterOn = pvOnOrdered(RasterOn);

% Get sweep length
temp = guidata(h.hDaqCtlr);
h.sweeplength = temp.aiparams.sweeplength; clear temp;

% Compute bin size
numEdges = ceil(h.sweeplength/h.binsize + 1);
h.edges = linspace(0,h.sweeplength,numEdges);
h.binsize = mean(diff(h.edges)); % BA binsize is may not be exactly the h.binsize defined, because of linspace.
h.xloc = h.binsize/2:h.binsize:(h.edges(end)-h.binsize/2);

% create axes
flagCreateAxs = 0;
vstim = getappdata(h.hDataViewer,'vstim');
if isfield(h,'nstimcond1') % check if axes need to be recreated (if nstimcond1 has changed, or doesn't exist
    if h.nstimcond1 ~=length(vstim.VarParam(1).Values); % if
        flagCreateAxs = 1;
        try delete(h.axs(:)); end
    end
else flagCreateAxs = 1; end
if flagCreateAxs
    if isempty(vstim)
        error('Cannot create PSTHTuning Figure, Vstim Conditions are unknown. Run acquisition for before opening PSTHTune')
    end
    try delete(h.axs(:)); end % BA could be more efficient if just find out if new lines are needed
    h.nstimcond1 = length(vstim.VarParam(1).Values);
    for icond1 = 1:h.nstimcond1
        for ichn = 1:length(ChannelOrder)% BA this creates an axes for each channel
            h.axs(ichn,icond1) = axes('Parent',h.psthFigTuning,'Visible','off');
            defaultAxes(h.axs(ichn,icond1),0.35,0.2);
            %         ADD title if ichn==1, title(% titles
        end
    end
    removeAxesLabels(h.axs(:));
end
set(h.axs(:),'XLIM',[0 h.sweeplength]);


% Make lines
try delete(h.lines(:)); end % BA could be more efficient if just find out if new lines are needed
% Initialize psthData
h.psthData = zeros(length(ChannelOrder),h.nstimcond1,h.nCond,length(h.xloc));


for ichn = 1:size(h.psthData,1)
    for istimcond1 = 1:size(h.psthData,2)
        for icond= 1: h.nCond% LED
            if h.nCond>1,                        tempColor = h.colors{mod(length(h.colors),icond)+1}; % color based on LED condition
            else,        tempColor = get(h.dv_hPlotLines(ichn),'Color'); end % color based on channel
            h.lines(ichn,istimcond1,icond) = line('Parent',h.axs(ichn,istimcond1),'Color',tempColor,'Visible','off', ...
                'XData',h.xloc,'YData',squeeze(h.psthData(ichn,istimcond1,icond,:)));
        end
    end
end

%  % Position axes
nAxesRow = length(h.RasterOn); % look up number of visible channels
if h.RasterOn % no nothing if no rasters are enabled
    nAxesCol = h.nstimcond1;
    axsToPlot = h.axs(h.RasterOn,:)';
    params.figmargin = [0.01 0.02  0.06  0.01 ];
    params.cellmargin = [0.01 0.01  0.01  0.01 ];
    setaxesOnaxesmatrix(axsToPlot(:),nAxesRow,nAxesCol,[1:nAxesRow*nAxesCol],params,h.psthFigTuning);
        AddAxesLabels(axsToPlot(nAxesRow:nAxesRow:end),'sec','spikes/sec');
else
    disp('*********** Cannot create PSTH: No Thresholding is enabled *************')
end
% Initialize trial counter
h.trialcounter = zeros(size(h.psthData,1),size(h.psthData,2),h.nCond);
s = sprintf('%d  %d',h.trialcounter(1,1,1),h.trialcounter(1,1,2));
set(cell2mat(get(h.axs(h.RasterOn(1),:),'Title')),'String',s,'fontsize',7,'Visible','On')
% Make PSTHs visible
psthOn(h,h.rvOn)

guidata(hObject,h)
