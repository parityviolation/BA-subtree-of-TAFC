function varargout = DataViewer(varargin)
%
%
%
%   Created: 1/10 - SRO
%   Modified: 4/15/10 - SRO
%   Modified: 5/31/10 - BA 


% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @DataViewer_OpeningFcn, ...
    'gui_OutputFcn',  @DataViewer_OutputFcn, ...
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


% --- Executes just before DataViewer is made visible.
function DataViewer_OpeningFcn(hObject, eventdata, handles, varargin)

rigdef = RigDefs;

%%% Code specific to DaqController version of DataViewer %%%

% Get handle to DaqController GUI
handles.hDaqCtlr = varargin{3};
DaqCtlrData = guidata(handles.hDaqCtlr);

% DataViewer GUI handle is passed to DaqController via the output function
handles.output = hObject;

% Assign DataViewer handle in base workspace
assignin('base','hDaqDataViewer',hObject);

% Hide analysis buttons if not flagged in RigDefs
if ~rigdef.DataViewer.AnalysisButtons
    set([handles.psthButton, handles.FRButton, handles.LFPButton handles.SpikeSelectionButton],...
        'Enable','off','Visible','off');
end

% Get channel information from AIOBJ for either NIDAQ or TDT
if isfield(DaqCtlrData,'tdtparams')
    %    % Setup for TDT (use TDTController)
       handles = tdtHelperSetup(handles,DaqCtlrData)   ;
else 
     % Setup for  NI-DAQ board (use DaqController)
    handles = nidaqHelperSetup(handles,DaqCtlrData);
end
clear DaqCtlrData

% Store handles for text boxes displaying trigger number
setappdata(hObject,'hTriggerNum',handles.TriggerNumText);
hTriggerNum = getappdata(hObject,'hTriggerNum');
set(hTriggerNum,'String',handles.TriggerNum);
setappdata(hObject,'hVstimNum',handles.VstimNumText);
setappdata(hObject,'hLedNum',handles.LedNumText);

% Set flag for Daq DataViewer
dvMode = 'Daq';

%%% End code specific to DaqController version of DataViewer %%%

handles = DataViewerHelper(handles,dvMode);

% Update handles structure
guidata(hObject, handles);

function handles = nidaqHelperSetup(handles,DaqCtlrData)

global AIOBJ
handles.Channel = get(AIOBJ,'Channel');
handles.nActiveChannels = length(handles.Channel);
handles.ChannelName = handles.Channel.ChannelName;
handles.SampleRate = AIOBJ.SampleRate;
handles.TriggerNum = AIOBJ.TriggersExecuted;

handles.SweepDuration = DaqCtlrData.aiparams.sweeplength;
handles.board = DaqCtlrData.board;



function handles = tdtHelperSetup(handles,DaqCtlrData)

%    % Setup for TDT (use TDTController)
TEMPhandles.expt.info.probe.channelorder = [1:16]; % BA TODO get this from block
handles.nActiveChannels = length(TEMPhandles.expt.info.probe.channelorder);
for i = 1:handles.nActiveChannels
    % BA for some reason the format here requires all entries to by
    % cells this seems to be different than in ExptDataViewer
    handles.daqinfo.ObjInfo.Channel.Index{i} = i;
end
handles.daqinfo.ObjInfo.Channel.Index = handles.daqinfo.ObjInfo.Channel.Index';
handles.daqinfo.ObjInfo.Channel.HwChannel = handles.daqinfo.ObjInfo.Channel.Index;
handles.daqinfo.ObjInfo.Channel.ChannelName = cellfun(@num2str ,handles.daqinfo.ObjInfo.Channel.Index, 'UniformOutput',0); % BA

handles.Channel = handles.daqinfo.ObjInfo.Channel;
handles.ChannelName  =  handles.daqinfo.ObjInfo.Channel.ChannelName';
handles.SampleRate = DaqCtlrData.tdtparams.SampleRate;
handles.SweepDuration  = DaqCtlrData.tdtparams.SweepDuration;
handles.TriggerNum = 0;

handles.board  = 'tdt';


% --- Outputs from this function are returned to the command line.
function varargout = DataViewer_OutputFcn(hObject, eventdata, handles)

varargout{1} = handles.output;

% Position GUI
RigDef = RigDefs;
set(hObject,'Position', RigDef.DataViewer.Position ,'Units','Pixels','Visible','on');
pause(0.25)


% --- Toolbar tools --- %
% --------------------------------------------------------------------
function xConstrainedZoom_ClickedCallback(hObject, eventdata, handles)

state = get(hObject,'State');
switch state
    case 'on'
        zoom xon
        set(handles.yConstrainedZoom,'State','off');
    case 'off'
        zoom off
end
% --------------------------------------------------------------------
function yConstrainedZoom_ClickedCallback(hObject, eventdata, handles)

state = get(hObject,'State');
switch state
    case 'on'
        zoom yon
        set(handles.xConstrainedZoom,'State','off');
    case 'off'
        zoom off
end
% --------------------------------------------------------------------
function DefaultZoom_OffCallback(hObject, eventdata, handles)
set(handles.xConstrainedZoom,'State','off');
set(handles.yConstrainedZoom,'State','off');
% --------------------------------------------------------------------
function xAutoScale_ClickedCallback(hObject, eventdata, handles)
xAutoScaleDV(handles)
% --------------------------------------------------------------------
function yAutoScale_ClickedCallback(hObject, eventdata, handles)
yAutoScaleDV(handles)


% --- Executes on key press with focus on hDataViewer and none of its controls.
function hDataViewer_KeyPressFcn(hObject, eventdata, handles)

Key = eventdata.Key;
switch Key  
    case 'y'
        yAutoScale(handles);
    case 't'
        xAutoScale(handles);
end


% --- Slider callback functions --- %
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
guidata(handles.hDataViewer,handles)
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


% --- Executes on button press in psthButton.
function psthButton_Callback(hObject, eventdata, handles)
dvplot = getappdata(handles.hDataViewer,'dvplot');

if ~isempty(dvplot.rvOn)
if get(hObject,'Value')
%     handles.psth = onlinePSTH(handles);
    handles.psth = onlinePSTH_BA(handles);
    setappdata(handles.hDataViewer,'psthON',1)
    guidata(hObject,handles)
elseif ~get(hObject,'Value')
    setappdata(handles.hDataViewer,'psthON',0)
end
end
    


% --- Executes on button press in FRButton.
function FRButton_Callback(hObject, eventdata, handles)
dvplot = getappdata(handles.hDataViewer,'dvplot');
if ~isempty(dvplot.rvOn)

if get(hObject,'Value')
    handles.fr = onlineFR(handles);
    setappdata(handles.hDataViewer,'frON',1)
    guidata(hObject,handles)
elseif ~get(hObject,'Value')
    setappdata(handles.hDataViewer,'frON',0)
end

end
% --- Executes on button press in LFPButton.
function LFPButton_Callback(hObject, eventdata, handles)

if get(hObject,'Value')
    handles.lfp = onlineLFP(handles);
    setappdata(handles.hDataViewer,'lfpON',1)
    guidata(hObject,handles)
elseif ~get(hObject,'Value')
    setappdata(handles.hDataViewer,'lfpON',0)
end


% --- Executes on button press in SpikeSelectionButton.
function SpikeSelectionButton_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
    handles.onlineSpkSel = initOnlineSpkSelect;
    setappdata(handles.hDataViewer,'SpkSelectON',1)
    guidata(hObject,handles)
elseif ~get(hObject,'Value')
    setappdata(handles.hDataViewer,'SpkSelectON',0)
end


% --- Executes on button press in invertbutton.
function invertbutton_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
    setappdata(handles.hDataViewer,'invertON',1)
    guidata(hObject,handles)
elseif ~get(hObject,'Value')
    setappdata(handles.hDataViewer,'invertON',0)
end
