function h = onlineFR(dvHandles)
%
% INPUT
%   dvHandles: DataViewer handles
%
% OUTPUT
%   h: guidata for the FR figure
%
%   Created: SRO 4/30/10
%   Modified: SRO 5/10/10

% Rig defaults
rigdef = RigDefs;
h.FigDir = rigdef.Dir.FigOnline;   
h.FigType = 'FR';
h.ExptName = getappdata(dvHandles.hDaqCtlr,'ExptName');

h.hDataViewer = dvHandles.hDataViewer;
h.hDaqCtlr = dvHandles.hDaqCtlr;
h.dv_hPlotLines =dvHandles.hPlotLines;

% by default inherit 'showAllYAxes' status from dataviewer (which inherits
% from RigDefs)
showAllYAxes = getappdata(h.hDataViewer, 'showAllYAxes');

% Get updated plot vectors from DataViewer appdata
dvplot = getappdata(dvHandles.hDataViewer,'dvplot');
nPlotOn = numel(dvplot.pvOn);
h.nPlotOn = nPlotOn;

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

% Set default windows for computing avg firing rate
if isfield(rigdef.onlineFR,'windows')
    h.windows = eval(rigdef.onlineFR.windows);  % Default values if 'cancel' is pushed
else
    h.windows = {[0 0.5] [0.5 1.5] [1.6 2.5]};
end


% Make figure
h.frFig = figure('Visible','off','Color',[1 1 1], ...
    'Position',rigdef.onlineFR.Position ,'Name','Firing rate','NumberTitle','off');

% Modify toolbar and menu
removeToolbarButtons(h.frFig);
h.hSave = tb_saveFig(h.frFig);
h.hSaveDisp = tb_saveFigDisp(h.frFig);
h.hToggleYAxes = tb_addToolbarButton(h.frFig, 'file_save.png', 'toggle', @toggleYAxesButton_ClickedCallback);

% Make gui objects
h.headerPanel = uipanel('Parent',h.frFig,'Units','Normalized', ...
    'Position',[-0.005 0.965 1.01 0.035]);
h.resetButton = uicontrol('Parent',h.headerPanel,'Style','pushbutton','String','reset', ...
    'Units','normalized','Position',[0.02 0.15 0.25 0.65],'Tag','resetButton');
h.condButton = uicontrol('Parent',h.headerPanel,'Style','pushbutton','String','cond', ...
    'Units','normalized','Position',[0.3 0.15 0.25 0.65],'Tag','condButton');
h.windowsButton = uicontrol('Parent',h.headerPanel,'Style','pushbutton','String','windows', ...
    'Units','normalized','Position',[0.58 0.15 0.25 0.65],'Tag','windowsButton');
h.newButton = uicontrol('Parent',h.headerPanel,'Style','pushbutton','String','new', ...
    'Units','normalized','Position',[ 0.8600    0.1500    0.2500    0.6500],'Tag','newButton');

% get margins for axes
if isfield(rigdef.onlineFR,'axesmargins')
    margins = rigdef.onlineFR.axesmargins;
else
    margins = [0.25 0.15 0.042 0.035];
end


% Initialize firing rate data
h.nWind = length(h.windows);
h.time = [];


% Initialize condition struct
h.cond.engage = 'on';
h.cond.type = 'led';
h.cond.value = [0 1];
h.nCond = length(h.cond.value); % LED

% Set colors for lines
% cond, window
h.colors{1,1} = [0.5 0.5 0.5];
% h.colors{2,1} = 	[0, 183, 235]/255;
h.colors{2,1} = [255 0 0]/255;
h.colors{3,1} = [102, 0, 0]/255;
h.colors{1,2} = [0 0 0];
h.colors{2,2} = [0 1 0];
h.colors{3,2} = [0 127/255 0];

guidata(h.frFig,h)
h = resetFRlines(h.frFig);


% Add callbacks buttons
set(h.resetButton,'Callback',{@resetButton_Callback});
set(h.windowsButton,'Callback',{@windowsButton_Callback});
set(h.condButton,'Callback',{@condButton_Callback});
set(h.newButton,'Callback',{@newButton_Callback,dvHandles,h.frFig});

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
set(h.frFig,'Visible','on'); pause(0.05)
% Save guidata
guidata(h.frFig,h); 



% --- Subfunctions --- %

function frOn(h,k)
set(h.axs(k),'Visible','on')
set(h.lines(k,:),'Visible','on')

function newButton_Callback(hObject,eventdata,handles,figH)
% Added KR 6/30/10
% This callback remakes entire figure, so newly threshold-ed channels are included
% onlinePSTH queries DaqPlotChooser for channels with Threshold ON

% Close this figure
close(figH);
handles.fr=[];

% Remake figure
handles.fr = onlineFR(handles);
guidata(handles.hDataViewer,handles);

function resetButton_Callback(hObject,eventdata)
h = resetFRlines(hObject);

function windowsButton_Callback(hObject,eventdata)
h = guidata(hObject);

% Enter window for computing spike rate
prompt = {'Spontaneous window (s)','Stimulus window (s)','Off window (s)'};
answer = inputdlg(prompt,'Enter',1);
for i = 1:length(answer)
    h.windows{i} = str2num(answer{i});
end

resetButton_Callback(h.resetButton,eventdata)

guidata(hObject,h)

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
h.nCond = length(h.cond.value);


guidata(hObject,h);
% % Update lines
h = resetFRlines(hObject);

function h = resetFRlines(hObject)
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


% create axes
try delete(h.axs(:)); end % BA could be more efficient if just find out if new lines are needed
for ichn = 1:length(ChannelOrder)
    h.axs(ichn) = axes('Parent',h.frFig,'Visible','off');
    defaultAxes(h.axs(ichn),0.35,0.2);
    removeAxesLabels(h.axs(ichn)); 
end

% set axis fontsize
set(h.axs(:),'FontSize',7)

h.time = NaN;
% Make lines
try delete(h.lines(:)); end % BA could be more efficient if just find out if new lines are needed
h.frData = nan(length(ChannelOrder),h.nWind,h.nCond,1e3);

for ichn = 1:size(h.frData,1)
    for iwind = 1:size(h.frData,2)
        for icond = 1:size(h.frData,3)
            
            h.lines(ichn,iwind,icond) = line('Parent',h.axs(ichn),'Color',h.colors{iwind,icond},'Visible','off', ...
                'XData',[],'YData',[],'Marker','o','MarkerFaceColor',h.colors{iwind,icond}, ...
                'MarkerEdgeColor',h.colors{iwind,icond},'LineStyle','none','MarkerSize',2);
        end
    end
end

% Position axes
%  % Position axes
nAxesRow = length(h.RasterOn); % look up number of visible channels
if h.RasterOn % no nothing if no rasters are enabled
    nAxesCol = 1;
    axsToPlot = h.axs(h.RasterOn)';
    params.figmargin = [0.15 0.01  0.04  0.01 ];
    params.cellmargin = [0.01 0.01  0.01  0.01 ];
    setaxesOnaxesmatrix(axsToPlot(:),nAxesRow,nAxesCol,[1:nAxesRow*nAxesCol],params,h.frFig);
    AddAxesLabels(axsToPlot(end),'minutes','spikes/sec');
else
    disp('*********** Cannot create FR vs time: No Thresholding is enabled *************')
end


% Make axes and lines visible
frOn(h,dvplot.rvOn)

guidata(hObject,h);