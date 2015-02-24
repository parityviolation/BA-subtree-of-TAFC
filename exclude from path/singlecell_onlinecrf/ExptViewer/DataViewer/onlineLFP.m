function h = onlineLFP(dvHandles)
%
% INPUT
%   dvHandles: DataViewer handles
%
% OUTPUT
%   h: guidata for the LFP figure
%
%   Created: SRO 5/3/10
%   Modified: BA 6/11/10

% Rig defaults
rigdef = RigDefs;
h.FigDir = rigdef.Dir.FigOnline;   
h.FigType = 'LFP';
h.ExptName = getappdata(dvHandles.hDaqCtlr,'ExptName');

% Get updated plot vectors from DataViewer appdata
h.hDataViewer = dvHandles.hDataViewer;
dvplot = getappdata(dvHandles.hDataViewer,'dvplot');
nPlotOn = numel(dvplot.pvOn);
h.nPlotOn = nPlotOn;
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

% Set default LFP window
h.window = [0.04 0.7];
h.Fs = dvHandles.SampleRate; % BA 6/5/10 modified used to be hardcoded 32000
h.windowPts = round(h.window*h.Fs);
h.xdata = h.window(1):1/h.Fs:h.window(2);

% Make figure
h.lfpFig = figure('Visible','off','Color',[1 1 1], ...
    'Position',rigdef.onlineLFP.Position,'Name','LFP','NumberTitle','off');

% Modify toolbar and menu
removeToolbarButtons(h.lfpFig);
h.hSave = tb_saveFig(h.lfpFig);
h.hSaveDisp = tb_saveFigDisp(h.lfpFig);

% Make gui objects
h.headerPanel = uipanel('Parent',h.lfpFig,'Units','Normalized', ...
    'Position',[-0.005 0.965 1.01 0.035]);
h.resetButton = uicontrol('Parent',h.headerPanel,'Style','pushbutton','String','reset', ...
    'Units','normalized','Position',[0.02 0.15 0.25 0.65],'Tag','resetButton');
h.windowButton = uicontrol('Parent',h.headerPanel,'Style','pushbutton','String','window', ...
    'Units','normalized','Position',[0.3 0.15 0.35 0.65],'Tag','windowButton');
h.condButton = uicontrol('Parent',h.headerPanel,'Style','pushbutton','String','cond', ...
    'Units','normalized','Position',[0.68 0.15 0.25 0.65],'Tag','condButton');

% Make axes
margins = [0.1 0.15 0.042 0.035];
axPos = dvAxesPosition(nPlotOn,margins);
for i = 1:length(ChannelOrder)% BA this creates an axes for each channel
        h.axs(i) = axes('Parent',h.lfpFig,'Visible','off');
    DefaultAxes(h.axs(i),0.35,0.2);
    set(h.axs(i),'LooseInset', [0,0,0,0]); % BA make axis bigger
    RemoveAxesLabels(h.axs(i));
    xlim(h.window);
end

% Initialize condition struct
h.cond.engage = 'off';
h.cond.type = '';
h.cond.value = [];

% Set colors for lines
h.colors{1} = [0 0 1];          % Blue
h.colors{2} = [0 127/255 0];    % Green
h.colors{3} = [1 0 0];          % Red

% Initialize LFP data
h.nCond = 1;
h.lfpData = cell(length(ChannelOrder),h.nCond); % creats an lfpData for all channels even if not plotted
for m = 1:size(h.lfpData,1)
    for n = 1:size(h.lfpData,2)
        h.lfpData{m,n} = zeros(size(h.xdata))';
    end
end

% Make lines
for m = 1:size(h.lfpData,1)
    for n = 1:size(h.lfpData,2)
        tempColor = get(dvHandles.hPlotLines(m),'Color');
        h.lines(m,n) = line('Parent',h.axs(m),'Color',tempColor,'Visible','off', ...
            'XData',h.xdata,'YData',h.lfpData{m,n});
    end
end

% Position axes
for i = 1:nPlotOn
    k = pvOnOrdered(i);
    set(h.axs(k),'Position',axPos{i});
    if ~isempty(RasterOn)
        if k == RasterOn(end)
            AddAxesLabels(h.axs(k),'sec','mV')
        end
    end
end

% Add callbacks to buttons
set(h.resetButton,'Callback',{@resetButton_Callback})
set(h.windowButton,'Callback',{@windowButton_Callback})
set(h.condButton,'Callback',{@condButton_Callback})

% Initialize trial counter
h.trialcounter = zeros(size(h.lfpData));

% Make LFPs visible
lfpOn(h,h.rvOn)

% Make figure visible
set(h.lfpFig,'Visible','on')

% Save guidata
guidata(h.lfpFig,h)


% --- Subfunctions --- %

function lfpOn(h,k)
set(h.axs(k),'Visible','on')
set(h.lines(k,:),'Visible','on')


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

% Update lfpData
h.nCond = length(h.cond.value);
h.lfpData = cell(h.nPlotOn,h.nCond);

% Update lines
delete(h.lines)
for m = 1:size(h.lfpData,1)
    for n = 1:size(h.lfpData,2)
        tempColor = h.colors{mod(length(h.colors),n)+1};
        h.lines(m,n) = line('Parent',h.axs(m),'Color',tempColor,'Visible','off', ...
            'XData',h.xdata,'YData',h.lfpData{m,n});
    end
end

% Initialize data in lines
for m = 1:size(h.lfpData,1)
    for n = 1:size(h.lfpData,2)
        h.lfpData{m,n} = zeros(size(h.xdata))';
        set(h.lines(m,n),'XData',h.xdata,'YData',h.lfpData{m,n});
    end
end

% Make LFPs visible
lfpOn(h,h.rvOn)

% Initialize trial counter
h.trialcounter = zeros(size(h.lfpData));

guidata(hObject,h)

function resetButton_Callback(hObject,eventdata)
% Get guidata
h = guidata(hObject);
% Delete lines
delete(h.lines)
% Initialize lfpData
h.lfpData = cell(h.nPlotOn,h.nCond);
for m = 1:size(h.lfpData,1)
    for n = 1:size(h.lfpData,2)
        h.lfpData{m,n} = zeros(size(h.xdata))';
    end
end
% Make lines
for m = 1:size(h.lfpData,1)
    for n = 1:size(h.lfpData,2)
        if h.nCond == 1
            dvHandles = guidata(h.hDataViewer);
            tempColor = get(dvHandles.hPlotLines(m),'Color');
        else
            tempColor = h.colors{mod(length(h.colors),n)+1};
        end
        h.lines(m,n) = line('Parent',h.axs(m),'Color',tempColor,'Visible','off', ...
            'XData',h.xdata,'YData',h.lfpData{m,n});
    end
end
% Set data
for m = 1:size(h.lfpData,1)
    for n = 1:size(h.lfpData,2)
        h.lfpData{m,n} = zeros(size(h.xdata))';
        set(h.lines(m,n),'XData',h.xdata,'YData',h.lfpData{m,n});
    end
end
% Make lfps visible
lfpOn(h,h.rvOn)

% Initialize trial counter
h.trialcounter = zeros(size(h.lfpData));

guidata(h.lfpFig,h)

