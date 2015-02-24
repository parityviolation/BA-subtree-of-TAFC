function varargout = ExptDataViewer(varargin)
%
%   Created: 3/16/10 - SRO
%   Modified: 4/5/10 - SRO

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @ExptDataViewer_OpeningFcn, ...
    'gui_OutputFcn',  @ExptDataViewer_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before ExptDataViewer is made visible.
function ExptDataViewer_OpeningFcn(hObject, eventdata, handles, varargin)

%%% Code specific to ExptDataViewer %%%

% Get channel information from AIOBJ
handles.expt = varargin{3};
ind = 1 ;% BA should be file specific?
handles.ExptName = handles.expt.name;
handles.SampleRate = handles.expt.files.Fs(ind);
handles.SweepDuration = handles.expt.files.duration(ind);
if isTDTexpt(handles.expt)    % BA
    % BA these are added to make compatible with DataViewer
    handles.nActiveChannels = length(handles.expt.info.probe.channelorder);
    for i = 1:handles.nActiveChannels
        handles.daqinfo.ObjInfo.Channel(i).Index = i;
        handles.daqinfo.ObjInfo.Channel(i).HwChannel = handles.daqinfo.ObjInfo.Channel(i).Index;
        handles.daqinfo.ObjInfo.Channel(i).ChannelName = num2str(handles.daqinfo.ObjInfo.Channel(i).Index); % BA 
    end
    handles.ChannelName  =  {handles.daqinfo.ObjInfo.Channel.ChannelName}';
else
    handles.daqinfo = handles.expt.files.daqinfo(1); % BA are all these DAQ specific variables required, can the be made into less DAQ specific
    handles.Channel = handles.daqinfo.ObjInfo.Channel;
    handles.nActiveChannels = length(handles.Channel);
    handles.ChannelName = {handles.Channel.ChannelName}';
end

% Generate the struct PlotObj for holding data, states, and info
PlotObj.ExptName = handles.ExptName;
PlotObj.UpdateType = 'Increment';
PlotObj.UpdateValue = 1;
PlotObj.FileList = handles.expt.files.names;
PlotObj.FileIndex = 1;
PlotObj.FileNum = 1;
PlotObj.Trigger = 1;
PlotObj.TriggersInFile = handles.expt.files.triggers;
PlotObj.Fs = handles.expt.files.Fs(1);  % Assumes sampling rate is same across files
setappdata(handles.hDataViewer,'PlotObj',PlotObj);

% Set downsample flag (TO DO: determine what default should be)
handles.bDownSample = 1;
set(handles.DownSampleToggle,'State','on');

% Set probe info as appdata in DataViewer (TO DO: check where probe data is
% added in other DataViewer)
probe = handles.expt.info.probe;
setappdata(handles.hDataViewer,'probe',probe);

% Set initial values in GUI
set(handles.ExperimentName,'String',getFilename(handles.ExptName)); % BA
set(handles.FileNumEdit,'String',PlotObj.FileNum);
set(handles.TriggerNumEdit,'String',PlotObj.Trigger);

% Set flag for  ExptDataViewer
dvMode = 'Expt';

%%% End code specific to ExptDataViewer %%%

handles = DataViewerHelper(handles,dvMode);

% Update handles structure
guidata(hObject, handles);

% Add first sweep to plot
handles = UpdatePlot(handles);

% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = ExptDataViewer_OutputFcn(hObject, eventdata, handles)

% Position GUI
RigDef = RigDefs;
set(hObject,'Position', RigDef.DataViewer.Position ,'Units','Pixels','Visible','on');
pause(0.25)
% set(hObject,'Position', [1542 -116 1568 940],'Units','Pixels');   % home PC


% --- Toolbar tools --- %

function xConstrainedZoom_ClickedCallback(hObject, eventdata, handles)

state = get(hObject,'State');
switch state
    case 'on'
        zoom xon
        set(handles.yConstrainedZoom,'State','off');
    case 'off'
        zoom off
end

function yConstrainedZoom_ClickedCallback(hObject, eventdata, handles)

state = get(hObject,'State');
switch state
    case 'on'
        zoom yon
        set(handles.xConstrainedZoom,'State','off');
    case 'off'
        zoom off
end

function DefaultZoom_OffCallback(hObject, eventdata, handles)

set(handles.xConstrainedZoom,'State','off');
set(handles.yConstrainedZoom,'State','off');

function DefaultZoom_ClickedCallback(hObject, eventdata, handles)

function FileNumEdit_Callback(hObject, eventdata, handles)

PlotObj = getappdata(handles.hDataViewer,'PlotObj');
PlotObj.UpdateType = 'GoTo';
PlotObj.FileNum = str2num(get(hObject,'String'));
PlotObj.FileIndex = PlotObj.FileNum;
UpdatePlotObj(handles,PlotObj);
handles = UpdatePlot(handles);
figure(handles.hDataViewer);

function FileNumEdit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function TriggerNumEdit_Callback(hObject, eventdata, handles)

PlotObj = getappdata(handles.hDataViewer,'PlotObj');
PlotObj.UpdateType = 'GoTo';
PlotObj.Trigger = str2num(get(hObject,'String'));
UpdatePlotObj(handles,PlotObj);
handles = UpdatePlot(handles);

function TriggerNumEdit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function hDataViewer_KeyPressFcn(hObject, eventdata, handles)

Key = eventdata.Key;
PlotObj = getappdata(handles.hDataViewer,'PlotObj');
switch Key  
    case 'rightarrow'
        PlotObj.UpdateType = 'Increment';
        PlotObj.UpdateValue = 1;
    case 'leftarrow'
        PlotObj.UpdateType = 'Increment';
        PlotObj.UpdateValue = -1;
    case 'uparrow'
        PlotObj.UpdateType = 'GoTo';
        PlotObj.FileIndex = PlotObj.FileIndex + 1;
    case 'downarrow'
        PlotObj.UpdateType = 'GoTo';
        PlotObj.FileIndex = PlotObj.FileIndex - 1;
    case 'y'
        yAutoScaleDV(handles);
    case 't'
        xAutoScaleDV(handles);
end

bUpdate = strcmp(Key,{'rightarrow' 'leftarrow' 'uparrow' 'downarrow'});
bUpdate = any(bUpdate);
if bUpdate
    UpdatePlotObj(handles,PlotObj);
    handles = UpdatePlot(handles);
end

function TriggerUpButton_Callback(hObject, eventdata, handles)

PlotObj = getappdata(handles.hDataViewer,'PlotObj');
PlotObj.UpdateType = 'Increment';
PlotObj.UpdateValue = 1;
UpdatePlotObj(handles,PlotObj);
handles = UpdatePlot(handles);

function TriggerDownButton_Callback(hObject, eventdata, handles)

PlotObj = getappdata(handles.hDataViewer,'PlotObj');
PlotObj.UpdateType = 'Increment';
PlotObj.UpdateValue = -1;
UpdatePlotObj(handles,PlotObj);
handles = UpdatePlot(handles);

% --------------------------------------------------------------------
function yAutoScale_ClickedCallback(hObject, eventdata, handles)

yAutoScaleDV(handles);

% --------------------------------------------------------------------
function xAutoScale_ClickedCallback(hObject, eventdata, handles)

xAutoScaleDV(handles);

function GetThreshButton_Callback(hObject, eventdata, handles)

Thresholds = cell2mat(get(handles.hAllSliders,'Value'));             % Indexing is by channel index

% if ~isTDTexpt(handles.expt)  % BA
%     Thresholds = Thresholds(2:17);
% end
expt = handles.expt;
expt.sort.manualThresh = Thresholds;
assignin('base','expt',expt);
save(expt.info.exptfile,'expt');

% --------------------------------------------------------------------
function DownSampleToggle_ClickedCallback(hObject, eventdata, handles)

state = get(hObject,'State');
switch state
    case 'on'
        handles.bDownSample = 1;
    case 'off'
        handles.bDownSample = 0;
end
guidata(hObject,handles);


% --- Subfunctions --- %

% ---
function handles = UpdatePlot(handles)
% UpdatePlot and dvProcessDisplay serve the same function as DataViewerCallback.

% Get PlotObj
PlotObj = getappdata(handles.hDataViewer,'PlotObj');

% Get all plot vectors (store in struct, dv)
dv = dvCallbackHelper(handles.hDataViewer);

% Read daq file
FileName = PlotObj.FileList{PlotObj.FileIndex};
FileName = fullfile(handles.RigDef.Dir.Data,FileName);
data = loaddata(FileName,[1:handles.nActiveChannels],'Triggers',PlotObj.Trigger);
data = squeeze(data);

% Set sample rate
dv.Fs = PlotObj.Fs;

% Process and display data
dvProcessDisplay(dv,data);


% ---
function UpdatePlotObj(handles,PlotObj)

switch PlotObj.UpdateType
    case 'Increment'
        % Increment within file
        PlotObj.Trigger = PlotObj.Trigger + PlotObj.UpdateValue;  
        % Go to next file
        if PlotObj.Trigger > PlotObj.TriggersInFile(PlotObj.FileIndex)                   
            PlotObj.FileIndex = PlotObj.FileIndex + 1;
            if PlotObj.FileIndex > length(PlotObj.FileList)
                PlotObj.FileIndex = 1;
            end
            PlotObj.FileNum = PlotObj.FileIndex;        % Make more general by using file name to derive FileNum
            PlotObj.Trigger = 1;
        end
        % Go to previous file
        if PlotObj.Trigger < 1                                                           
            PlotObj.FileIndex = PlotObj.FileIndex - 1;
            if PlotObj.FileIndex < 1
                PlotObj.FileIndex = length(PlotObj.FileList);
            end
            PlotObj.FileNum = PlotObj.FileIndex;
            PlotObj.Trigger = PlotObj.TriggersInFile(PlotObj.FileIndex);
        end
    case 'GoTo'
        if PlotObj.FileIndex > length(PlotObj.FileList)
            PlotObj.FileIndex = 1;
        end
        if PlotObj.FileIndex < 1
            PlotObj.FileIndex = length(PlotObj.FileList);
        end
        PlotObj.FileNum = PlotObj.FileIndex;    
end

setappdata(handles.hDataViewer,'PlotObj',PlotObj);
UpdateGuiValues(handles,PlotObj);

% ---
function UpdateGuiValues(handles,PlotObj)
set(handles.FileNumEdit,'String',num2str(PlotObj.FileNum));
set(handles.TriggerNumEdit,'String',num2str(PlotObj.Trigger));


% --- End of subfunctions --- %




% --- Sliders callbacks --- %
% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)

yTemp = get(hObject,'Value');
yTemp = [yTemp yTemp];
set(handles.hThresh(1),'YData',yTemp);
handles = GetSliderValues(handles);
guidata(handles.hDataViewer,handles);
function slider1_CreateFcn(hObject, eventdata, handles)

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
function slider2_Callback(hObject, eventdata, handles)
yTemp = get(hObject,'Value');
yTemp = [yTemp yTemp];
set(handles.hThresh(2),'YData',yTemp);
handles = GetSliderValues(handles);
guidata(handles.hDataViewer,handles);
function slider2_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
function slider3_Callback(hObject, eventdata, handles)
yTemp = get(hObject,'Value');
yTemp = [yTemp yTemp];
set(handles.hThresh(3),'YData',yTemp);
handles = GetSliderValues(handles);
guidata(handles.hDataViewer,handles);
function slider3_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
function slider4_Callback(hObject, eventdata, handles)
yTemp = get(hObject,'Value');
yTemp = [yTemp yTemp];
set(handles.hThresh(4),'YData',yTemp);
handles = GetSliderValues(handles);
guidata(handles.hDataViewer,handles);
function slider4_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
function slider5_Callback(hObject, eventdata, handles)
yTemp = get(hObject,'Value');
yTemp = [yTemp yTemp];
set(handles.hThresh(5),'YData',yTemp);
handles = GetSliderValues(handles);
guidata(handles.hDataViewer,handles);
function slider5_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
function slider6_Callback(hObject, eventdata, handles)
yTemp = get(hObject,'Value');
yTemp = [yTemp yTemp];
set(handles.hThresh(6),'YData',yTemp);
handles = GetSliderValues(handles);
guidata(handles.hDataViewer,handles);
function slider6_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
function slider7_Callback(hObject, eventdata, handles)
yTemp = get(hObject,'Value');
yTemp = [yTemp yTemp];
set(handles.hThresh(7),'YData',yTemp);
handles = GetSliderValues(handles);
guidata(handles.hDataViewer,handles);
function slider7_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
function slider8_Callback(hObject, eventdata, handles)
yTemp = get(hObject,'Value');
yTemp = [yTemp yTemp];
set(handles.hThresh(8),'YData',yTemp);
handles = GetSliderValues(handles);
guidata(handles.hDataViewer,handles);
function slider8_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
function slider9_Callback(hObject, eventdata, handles)
yTemp = get(hObject,'Value');
yTemp = [yTemp yTemp];
set(handles.hThresh(9),'YData',yTemp);
handles = GetSliderValues(handles);
guidata(handles.hDataViewer,handles);
function slider9_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
function slider10_Callback(hObject, eventdata, handles)
yTemp = get(hObject,'Value');
yTemp = [yTemp yTemp];
set(handles.hThresh(10),'YData',yTemp);
handles = GetSliderValues(handles);
guidata(handles.hDataViewer,handles);
function slider10_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
function slider11_Callback(hObject, eventdata, handles)
yTemp = get(hObject,'Value');
yTemp = [yTemp yTemp];
set(handles.hThresh(11),'YData',yTemp);
handles = GetSliderValues(handles);
guidata(handles.hDataViewer,handles);
function slider11_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
function slider12_Callback(hObject, eventdata, handles)
yTemp = get(hObject,'Value');
yTemp = [yTemp yTemp];
set(handles.hThresh(12),'YData',yTemp);
handles = GetSliderValues(handles);
guidata(handles.hDataViewer,handles);
function slider12_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
function slider13_Callback(hObject, eventdata, handles)
yTemp = get(hObject,'Value');
yTemp = [yTemp yTemp];
set(handles.hThresh(13),'YData',yTemp);
handles = GetSliderValues(handles);
guidata(handles.hDataViewer,handles);
function slider13_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
function slider14_Callback(hObject, eventdata, handles)
yTemp = get(hObject,'Value');
yTemp = [yTemp yTemp];
set(handles.hThresh(14),'YData',yTemp);
handles = GetSliderValues(handles);
guidata(handles.hDataViewer,handles);
function slider14_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
function slider15_Callback(hObject, eventdata, handles)
yTemp = get(hObject,'Value');
yTemp = [yTemp yTemp];
set(handles.hThresh(15),'YData',yTemp);
handles = GetSliderValues(handles);
guidata(handles.hDataViewer,handles);
function slider15_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
function slider16_Callback(hObject, eventdata, handles)
yTemp = get(hObject,'Value');
yTemp = [yTemp yTemp];
set(handles.hThresh(16),'YData',yTemp);
handles = GetSliderValues(handles);
guidata(handles.hDataViewer,handles);
function slider16_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
function slider17_Callback(hObject, eventdata, handles)
yTemp = get(hObject,'Value');
yTemp = [yTemp yTemp];
set(handles.hThresh(17),'YData',yTemp);
handles = GetSliderValues(handles);
guidata(handles.hDataViewer,handles);
function slider17_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
function slider18_Callback(hObject, eventdata, handles)
yTemp = get(hObject,'Value');
yTemp = [yTemp yTemp];
set(handles.hThresh(18),'YData',yTemp);
handles = GetSliderValues(handles);
guidata(handles.hDataViewer,handles);
function slider18_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
function slider19_Callback(hObject, eventdata, handles)
yTemp = get(hObject,'Value');
yTemp = [yTemp yTemp];
set(handles.hThresh(19),'YData',yTemp);
handles = GetSliderValues(handles);
guidata(handles.hDataViewer,handles);
function slider19_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
function slider20_Callback(hObject, eventdata, handles)
yTemp = get(hObject,'Value');
yTemp = [yTemp yTemp];
set(handles.hThresh(20),'YData',yTemp);
handles = GetSliderValues(handles);
guidata(handles.hDataViewer,handles);
function slider20_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
function slider21_Callback(hObject, eventdata, handles)

yTemp = get(hObject,'Value');
yTemp = [yTemp yTemp];
set(handles.hThresh(21),'YData',yTemp);
handles = GetSliderValues(handles);
guidata(handles.hDataViewer,handles);
function slider21_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
function slider22_Callback(hObject, eventdata, handles)
yTemp = get(hObject,'Value');
yTemp = [yTemp yTemp];
set(handles.hThresh(22),'YData',yTemp);
handles = GetSliderValues(handles);
guidata(handles.hDataViewer,handles);
function slider22_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
function slider23_Callback(hObject, eventdata, handles)
yTemp = get(hObject,'Value');
yTemp = [yTemp yTemp];
set(handles.hThresh(23),'YData',yTemp);
handles = GetSliderValues(handles);
guidata(handles.hDataViewer,handles);
function slider23_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
function slider24_Callback(hObject, eventdata, handles)
yTemp = get(hObject,'Value');
yTemp = [yTemp yTemp];
set(handles.hThresh(24),'YData',yTemp);
handles = GetSliderValues(handles);
guidata(handles.hDataViewer,handles);
function slider24_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
