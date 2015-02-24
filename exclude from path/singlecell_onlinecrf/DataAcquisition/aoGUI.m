function varargout = aoGUI(varargin)
%
%
%
%
%   Created: 2/10 - SRO
%   Modified: 7/5/10 - BA

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @aoGUI_OpeningFcn, ...
    'gui_OutputFcn',  @aoGUI_OutputFcn, ...
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



function aoGUI_OpeningFcn(hObject, eventdata, handles, varargin)

global AIOBJ
global ao % use daqfind and a Tag to replace this % e.g. daqfind('Tag','AOOBJ')
RigDef = RigDefs;

% Set handles for DataViewer and DaqController
handles.hDataViewer = varargin{3};
handles.hDaqController = varargin{4};

% Populate LED pull-down with LEDs in RigDefs
set(handles.ID,'String',RigDef.ao.ID,'Value',1);

% Set strings on LED toggles
set(handles.chn1Tg,'String',RigDef.ao.ID{1});
set(handles.chn2Tg,'String',RigDef.ao.ID{2});
set(handles.chn3Tg,'String',RigDef.ao.ID{3});

% Set Trigger strings
if isfield(RigDef.ao,'TriggerSourceList')
    set(handles.popupTrigger,'String',RigDef.ao.TriggerSourceList);
end

% Try to get aoWavObj from previous analog output object
try
    aoWavObj = get(ao,'UserData');
end

% % Delete analog output object if it exists
% try
%     delete(ao);
%     clear ao;
% end

% If aoWavObj exists, use its data to set defaults in GUI
noaoWavObj = 0;
try
    if isstruct(aoWavObj)
        handles.aoWavObj = aoWavObj;
        handles = setGuiValues(handles);
    else
        noaoWavObj = 1;
    end
catch
    noaoWavObj = 1;
end

% If aoWavObj doesn't exist, set default GUI values
if noaoWavObj
    set(handles.ID,'Value',1);
    set(handles.TrigFreq,'String',2);
    set(handles.TimeOffset,'String',0);
    set(handles.NumPulses,'String',1);
    set(handles.Width,'String',1.5);
    set(handles.Amplitude,'String',5);
    set(handles.VoltageOffset,'String',RigDef.ao.Offset{1});
    set(handles.Freq,'String',.01);
end

% Store analog output parameters in aoWavObj
for i = 1:length(RigDef.ao.ID)
    handles.aoWavObj(i).OutputRange = 5;        % V
    handles.aoWavObj(i).UnitsRange = 5;        % V
    handles.aoWavObj(i).VoltageOffset = RigDef.ao.Offset{i};
    handles.aoWavObj(i).SampleRate = AIOBJ.SampleRate;
    handles.aoWavObj(i).Duration = AIOBJ.SamplesPerTrigger/AIOBJ.SampleRate;
    handles.aoWavObj(i).NumSamples = AIOBJ.SampleRate*handles.aoWavObj(i).Duration;
    handles.aoWavObj(i).Output = 'on';
    handles.aoWavObj(i).Engaged = 'no';
    handles.aoWavObj(i).ID = RigDef.ao.ID{i};
    handles.aoWavObj(i).HwChannel = RigDef.ao.HwChannel{i};
    handles.aoWavObj(i).TriggerFrequency = 2;
    handles.aoWavObj(i).TimeOffset = 0;
    handles.aoWavObj(i).NumPulses = 1;
    handles.aoWavObj(i).Width = 1.5;
    handles.aoWavObj(i).Amplitude = 5;
    handles.aoWavObj(i).WaveformType = 'square';
    handles.aoWavObj(i).Freq = .01;
    handles.aoWavObj(i).bchanged = 1;

    s = get(handles.popupTrigger,'String');
    handles.aoWavObj(i).TriggerSource = s{1} % default to first value in popupTrigger

end
% Make waveform lines
for i = 1:length(RigDef.ao.ID)
    handles.hLine(i) = line([0 1],[0 1],'Parent',handles.axes1,'Visible','off');
    set(handles.axes1,'YLim',[0 5.1],'XLim',[0 handles.aoWavObj(i).Duration]);
    switch i
        case 1
            set(handles.hLine(i),'Color',[0 0 0.85])
        case 2
            set(handles.hLine(i),'Color',[0.85 0 0])
        case 3
            set(handles.hLine(i),'Color',[0 0.85 0])
    end
end

% Update handles structure
guidata(hObject, handles); % this must be done before the slider callback is called

% Set min and max slider values
handles = updateSliders(handles);

% Setup Continues Slider callback see http://undocumentedmatlab.com/blog/continuous-slider-callback/
hhSlider = handle(handles.AmplitudeSlider);hProp = findprop(hhSlider,'Value');  % a schema.prop object
handles.hListener = handle.listener(hhSlider,hProp,'PropertyPostSet',{@contAmplitudeSliderCB,handles});
hhSlider = handle(handles.OffsetSlider); hProp = findprop(hhSlider,'Value');  % a schema.prop object
handles.hListener = handle.listener(hhSlider,hProp,'PropertyPostSet',{@contOffsetSliderCB,handles});


% Set default slider positions
set(handles.AmplitudeSlider,'Value',handles.aoWavObj(1).Amplitude);
set(handles.OffsetSlider,'Value',0);




% Engage first toggle
set(handles.chn1Tg,'Value',1);
handles.aoWavObj(1).Engaged = 'yes';

updateGUIFields(handles)

% Display 
DisplayWaveform(handles);
DefaultAxes(handles.axes1);

% Update handles structure
guidata(hObject, handles);

function varargout = aoGUI_OutputFcn(hObject, eventdata, handles)
set(hObject,'Units','Pixels','Visible','on'); pause(0.2);

function TrigFreq_Callback(hObject, eventdata, handles)
handles = GetGuiValues(handles);
DisplayWaveform(handles);
toggleAONotUpdated(handles,1);

function TimeOffset_Callback(hObject, eventdata, handles)
handles = GetGuiValues(handles);
DisplayWaveform(handles);
toggleAONotUpdated(handles,1);

function NumPulses_Callback(hObject, eventdata, handles)
handles = GetGuiValues(handles);
DisplayWaveform(handles);
toggleAONotUpdated(handles,1);

function Amplitude_Callback(hObject, eventdata, handles)
handles = GetGuiValues(handles);
DisplayWaveform(handles);
toggleAONotUpdated(handles,1);

function VoltageOffset_Callback(hObject, eventdata, handles)
handles = GetGuiValues(handles);
DisplayWaveform(handles);
toggleAONotUpdated(handles,1);

function MakeAOobject_Callback(hObject, eventdata, handles)

makeAOhelper(handles)


function Width_Callback(hObject, eventdata, handles)
handles = GetGuiValues(handles);
DisplayWaveform(handles);
toggleAONotUpdated(handles,1);

function CloseButton_Callback(hObject, eventdata, handles)
delete(handles.aoGUI)

function AmplitudeSlider_Callback(hObject, eventdata, handles)
% % Set new value in edit box and display wave
 makeAOhelper(handles); % auto update ao
 
function OffsetSlider_Callback(hObject, eventdata, handles)
% Set new value in edit box and display wave
 
function ID_Callback(hObject, eventdata, handles)
ID = get(handles.ID,'Value');
handles = setGuiValues(handles,ID);
guidata(hObject,handles);



function Waveform_Callback(hObject, eventdata, handles)

     updateGUIFields(handles);
     handles = GetGuiValues(handles);
DisplayWaveform(handles);


% --- Subfunctions --- %

function handles = toggleAONotUpdated(handles,btoggle)
% set button red (used for cases were AO if changed but not updated)
if btoggle
    set(handles.MakeAOobject,'BackgroundColor',[0.86 0 0]);
    i = get(handles.ID,'Value');
    handles.aoWavObj(i).bchanged =  1; % this flag is set to 1 when aoWavObj is changed but MakeAnalogOut hasn't been updated
    
else
    set(handles.MakeAOobject,'BackgroundColor',[0.831 0.816 0.784]);
end
guidata(handles.aoGUI,handles);


function makeAOhelper(handles)

global AIOBJ;
global ao;

try
    stop(ao);
end

% Delete analog output object if it exists
try
    delete(ao);
end


aoWavObj = handles.aoWavObj;

% Make analog output object using parameters in aoWavObj
aoWavObj = MakeAnalogOut(aoWavObj);


% Add LED flag to DataViewer % TODO (BA) REMOVE THIS LED and DAQController
% dependency?
setappdata(handles.hDataViewer,'bLED',1);
%  BA when Daqplotchooser is used to update the daqcontroler the hDataViewer
% deleted and recreated, with a new handle making this handle obsolete, and
% creating an error here
h = guidata(handles.hDaqController);
set(h.hLEDSetupButton,'ForegroundColor',[0 0 0.85]);
handles = toggleAONotUpdated(handles,0);

% Store aoWavObj in analog output object
set(ao,'UserData',aoWavObj);

% Add updated aoWavObj to handles and update handles
handles.aoWavObj = aoWavObj;

guidata(handles.aoGUI,handles);

function handles = updateFromAIOBJ(handles)

global AIOBJ
for i = 1:length(handles.aoWavObj)
    handles.aoWavObj(i).SampleRate = AIOBJ.SampleRate;
    handles.aoWavObj(i).Duration = AIOBJ.SamplesPerTrigger/AIOBJ.SampleRate;
    handles.aoWavObj(i).NumSamples = AIOBJ.SampleRate*handles.aoWavObj(i).Duration;
end
guidata(handles.aoGUI,handles)

function updateGUIFields(handles)

% update based on AIOBJ
s = get(handles.Waveform,'String');
s = s{get(handles.Waveform,'Value')};

switch s
    case 'pulse train'
        set(handles.Freq,'Enable','On')
        set(handles.NumPulses,'Enable','On')
        if 1/str2num(get(handles.Freq,'String')) <... % fix case where pulse is longer than pulse period
                str2num(get(handles.Width,'String'))
            set(handles.Width,'String',num2str(1/str2num(get(handles.Freq,'String'))/2))
        end
    otherwise
        set(handles.Freq,'Enable','Off')
        set(handles.NumPulses,'Enable','Off')
        
end
guidata(handles.aoGUI,handles)


function DisplayWaveform(handles)

aoWavObj = handles.aoWavObj;
% Get indices of engaged Chns
engagedChn = getEngagedChn(handles);
for i = 1:length(engagedChn)
    if engagedChn(i)
        waveform = MakeOutputWaveform(aoWavObj(i));
        dt = 1/aoWavObj(i).SampleRate;
        t = 0:dt:aoWavObj(i).Duration-dt;
        set(handles.hLine(i),'XData',t,'YData',waveform,'LineWidth',1.5);
        set(handles.hLine(i),'Visible','on')
    elseif ~engagedChn(i)
        set(handles.hLine(i),'Visible','off')
    end
end

 set(handles.axes1,'XLim',[0 handles.aoWavObj(1).Duration]);
set(get(handles.axes1,'XLabel'),'String','sec');
set(get(handles.axes1,'YLabel'),'String','volts');
DefaultAxes(handles.axes1);

function handles = GetGuiValues(handles)

handles = updateFromAIOBJ(handles);
i = get(handles.ID,'Value');

handles.aoWavObj(i).TriggerFrequency = str2num(get(handles.TrigFreq,'String'));
handles.aoWavObj(i).TimeOffset = str2num(get(handles.TimeOffset,'String'));
handles.aoWavObj(i).NumPulses = str2num(get(handles.NumPulses,'String'));
handles.aoWavObj(i).Width = str2num(get(handles.Width,'String'));
handles.aoWavObj(i).Amplitude = str2num(get(handles.Amplitude,'String'));
handles.aoWavObj(i).VoltageOffset = str2num(get(handles.VoltageOffset,'String'));
handles.aoWavObj(i).Freq = str2num(get(handles.Freq,'String'));

% Don't allow amplitude to go below voltage offset
if handles.aoWavObj(i).Amplitude < handles.aoWavObj(i).VoltageOffset
    handles.aoWavObj(i).Amplitude = handles.aoWavObj(i).VoltageOffset;
    set(handles.Amplitude,'String',num2str(handles.aoWavObj(i).Amplitude));
end

% ao ID
IDstrings = get(handles.ID,'String');
value = get(handles.ID,'Value');
handles.aoWavObj(i).ID = IDstrings{value};
% Waveform
waveStrings = get(handles.Waveform,'String');
value = get(handles.Waveform,'Value');
handles.aoWavObj(i).WaveformType = waveStrings{value};
% Set sliders
set(handles.OffsetSlider,'Value',handles.aoWavObj(i).TimeOffset);
set(handles.AmplitudeSlider,'Value',handles.aoWavObj(i).Amplitude);

guidata(handles.aoGUI,handles)

function handles = setGuiValues(handles,i)
% i is the index to a particular LED. Uses values in aoWavObj to set values
% in GUI.

if nargin < 2
    i = 1;
end

aoWavObj = handles.aoWavObj;

set(handles.TrigFreq,'String',num2str(aoWavObj(i).TriggerFrequency));
set(handles.TimeOffset,'String',num2str(aoWavObj(i).TimeOffset));
set(handles.NumPulses,'String',num2str(aoWavObj(i).NumPulses));
set(handles.Width,'String',num2str(aoWavObj(i).Width));
set(handles.Amplitude,'String',num2str(aoWavObj(i).Amplitude));
set(handles.VoltageOffset,'String',num2str(aoWavObj(i).VoltageOffset));
set(handles.Freq,'String',num2str(aoWavObj(i).Freq));


function engagedChn = getEngagedChn(handles)

engagedChn(1) = get(handles.chn1Tg,'Value');
engagedChn(2) = get(handles.chn2Tg,'Value');
engagedChn(3) = get(handles.chn3Tg,'Value');
engagedChn = logical(engagedChn);

function handles = chnTgCallback(hObject,handles)
value = get(hObject,'Value');
guidata(hObject,handles)

function handles = updateSliders(handles)
% Get slider range for active LED
VoltageOffset = str2double(get(handles.VoltageOffset,'String'));
maxAmp = 5;
set(handles.AmplitudeSlider,'Min',VoltageOffset,'Max',maxAmp);

minOffset = 0;
maxOffset = handles.aoWavObj(1).Duration;
set(handles.OffsetSlider,'Min',minOffset,'Max',maxOffset);

% Set slider values
set(handles.AmplitudeSlider,'Value',str2double(get(handles.Amplitude)));
set(handles.OffsetSlider,'Value',str2double(get(handles.TimeOffset)));


% --- Create functions --- %
function AmplitudeSlider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
function axes1_CreateFcn(hObject, eventdata, handles)
function ID_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function Waveform_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function TimeOffset_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function TrigFreq_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function Width_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function VoltageOffset_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function Amplitude_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function NumPulses_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes during object creation, after setting all properties.
function OffsetSlider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function deleteAOobject_Callback(hObject, eventdata, handles)
global ao AIOBJ
% Delete analog output object if it exists
try
    AIOBJ.StartFcn = '';
    stop(ao)
    delete(ao)
    clear ao
end

% Remove LED flag from DataViewer
setappdata(handles.hDataViewer,'bLED',0)
h = guidata(handles.hDaqController);
set(h.hLEDSetupButton,'ForegroundColor',[0 0 0]);


% --- Executes on button press in chn1Tg.
function chn1Tg_Callback(hObject, eventdata, handles)
engaged = get(handles.chn1Tg,'Value');
if engaged
    handles.aoWavObj(1).Engaged = 'yes';
else
    handles.aoWavObj(1).Engaged = 'no';
end
handles = toggleAONotUpdated(handles,1);
guidata(hObject,handles)
DisplayWaveform(handles)


% --- Executes on button press in chn2Tg.
function chn2Tg_Callback(hObject, eventdata, handles)
engaged = get(handles.chn1Tg,'Value');
if engaged
    handles.aoWavObj(2).Engaged = 'yes';
else
    handles.aoWavObj(2).Engaged = 'no';
end
handles = toggleAONotUpdated(handles,1);
guidata(hObject,handles)
DisplayWaveform(handles)

% --- Executes on button press in chn3Tg.
function chn3Tg_Callback(hObject, eventdata, handles)
engaged = get(handles.chn1Tg,'Value');
if engaged
    handles.aoWavObj(3).Engaged = 'yes';
else
    handles.aoWavObj(3).Engaged = 'no';
end
handles = toggleAONotUpdated(handles,1);
guidata(hObject,handles)
DisplayWaveform(handles)

function Freq_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function Freq_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over AmplitudeSlider.
function contAmplitudeSliderCB(hObject, eventdata, handles)
handles =guidata(handles.aoGUI); % get updated version of handles
set(handles.Amplitude,'String',num2str(get(handles.AmplitudeSlider,'Value')));
handles = GetGuiValues(handles);
DisplayWaveform(handles);
toggleAONotUpdated(handles,1);

function contOffsetSliderCB(hObject, eventdata, handles)
handles =guidata(handles.aoGUI); % get updated version of handles
set(handles.TimeOffset,'String',num2str(get(handles.OffsetSlider,'Value')));
handles = GetGuiValues(handles);
DisplayWaveform(handles);
toggleAONotUpdated(handles,1);


% --- Executes on selection change in popupTrigger.
function popupTrigger_Callback(hObject, eventdata, handles)

toggleAONotUpdated(handles,1)
for i = 1:length(aoWavObj)
    s = get(handles.popupTrigger,'String');
    handles.aoWavObj(i).TriggerSource = s{get(handles.popupTrigger,'Value')};
end

% --- Executes during object creation, after setting all properties.
function popupTrigger_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
