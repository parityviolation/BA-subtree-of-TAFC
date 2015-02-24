function handles = DataViewerHelper(handles,dvMode)
% This function is called by both DataViewer (used during data acquisition)
% and ExptDataViewer (used to viewer data following acquisition).
%
%
%   Created: 4/3/10 - SRO
%   Modified: 4/30/10 - SRO

% Set position of header panel
set(handles.hDataViewer,'Units','Pixels');
set(handles.headerPanel,'Position',[-0.005 0.965 1.01 0.035]);

% Set DataViewer handle as appdata
setappdata(handles.hDataViewer,'hDataViewer',handles.hDataViewer);

% Set rig defaults
RigDef = RigDefs;
handles.RigDef = RigDef;

% Make vector containing all axes handles (handles.hAllAxes) and all slider
% handles (handles.hAllSliders)
for i = 1:24
    s = ['handles.hAllAxes(' num2str(i) ') = handles.axes' num2str(i) ';'];
    eval(s);
    s = ['handles.hAllSliders(' num2str(i) ') = handles.slider' num2str(i) ';'];
    eval(s);
end

% Delete axes and sliders for inactive channels
if length(handles.hAllAxes) > handles.nActiveChannels
    try
        delete(handles.hAllAxes(handles.nActiveChannels+1:end));
        delete(handles.hAllSliders(handles.nActiveChannels+1:end));
    end
    handles.hAllAxes(handles.nActiveChannels+1:end) = [];
    handles.hAllSliders(handles.nActiveChannels+1:end) = [];
end

% Set on and off plot vectors (default is all active channels)
dvplot.pvOn = (1:handles.nActiveChannels)';
dvplot.pvOff = [];

% Set filter and threshold vectors (default is no filtering or threshold)
dvplot.lpvOn = []; 
dvplot.hpvOn = [];
dvplot.rvOn = [];
dvplot.rvOff = [];

% Set plot vectors as appdata in DataViewer
setappdata(handles.hDataViewer,'dvplot',dvplot)

% Initialize and open PlotChooser. The DataViewer handle is passed
% to PlotChooser, and vice versa.
guidata(handles.hDataViewer, handles);
switch dvMode
    case 'Daq'
        handles.hPlotChooser = PlotChooser('Visible','off',handles.hDataViewer);
    case 'Expt'
        handles.hPlotChooser = ExptPlotChooser('Visible','off',handles.hDataViewer);
end

% Initialize plots
handles = InitializeDataViewerPlots(handles);

% Initialize spikeHist and spikeMean

% Get slider values for spike detection
handles = GetSliderValues(handles);




