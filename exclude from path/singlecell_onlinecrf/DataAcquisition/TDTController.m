function varargout = TDTController(varargin)
%
%
%   Created: 1/10 - SRO
%   Modified: 5/10/10 - SRO


% Begin initialization code - DO NOT EDIT
% This code is generated via the GUIDE program used to generate this GUI
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @TDTController_OpeningFcn, ...
    'gui_OutputFcn',  @TDTController_OutputFcn, ...
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


% --- Executes just before TDTController is made visible.
function TDTController_OpeningFcn(hObject, eventdata, handles, varargin)

% Set TDTController handle as appdata
setappdata(hObject,'hDaqCtlr',hObject);

% TDTController handle is output
handles.output = hObject;

% Assign TDTController handle in base workspace
assignin('base','hDaqController',hObject);

% Rig specific defaults
RigDef = RigDefs;
handles.RigDef = RigDef;

% Determine which board is being used, and how many ai channels
handles.board.ID = RigDef.equipment.board.ID;
handles.board.numAnalogInputCh = RigDef.equipment.board.numAnalogInputCh;


% Enable/disable LED GUI button
if RigDef.led.Enable == 0
    set(handles.hLEDSetupButton,'Enable','off')
end

% Setup  TDT control
handles =updateTDTconnection(handles);

% Execute if using DataViewer GUI. Can be modified to use different online
% plotting method and/or callback.
if strcmp(RigDef.Daq.OnlinePlotting,'DataViewer');
    % Update guidata so DataViewer has access to updated info
    guidata(hObject,handles);
    
    % Create the DataViewer GUI
    handles.hDataViewer = DataViewer('Visible','off',handles.hDaqController);
    % Set the trigger function
    handles = updateTDTCallbackTimer(handles); % BA (Requires hDataViewer to be defined)
    
end


% % Set SaveName callback function
% handles.SaveNameFcn = @ed4_savefilename_Callback;
% Set ExptName as appdata for use by other GUIs
[ExptPath ExptName] = loadTDThelper_getTankBlk(handles.tdtparams.blkPATH);
setappdata(handles.hDaqController,'ExptName',ExptName);

% Set experiment table as appdata in TDTController
setappdata(handles.NewExptButton,'ExptTable',handles.RigDef.ExptTable.Parameters);

% Use new experiment callback to generate new experiment
guidata(hObject,handles);
handles.hExptTable = NewExptButton_Callback(handles.NewExptButton, [], handles);

% Add flag to LED Setup button
setappdata(handles.hLEDSetupButton,'bLED',0)

% Update the handles structure
guidata(hObject,handles);


% --- Outputs from this function are returned to the command line.
function varargout = TDTController_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;
RigDef = RigDefs;
set(hObject,'Units','Pixels','Position',[RigDef.Daq.Position 439 216],'Visible','on');
pause(0.25)



function StartDAQ_Callback(hObject, eventdata, handles)
handles = toggleStartDAQ(get(hObject,'Value'),handles);
handles.aiparams.sweeplength = handles.tdtparams.SweepDuration;
guidata(hObject,handles);
 % this is a bit of a hack to keep compatible with Analog out

function handles = toggleStartDAQ(status,handles)
if status == 1 % Start data acquisition and disable other GUI elements
    handles =updateTDTconnection(handles); % must be initized before DA starts recording
    
    set(handles.StartDAQ,'String','Stop DAQ');
    set(handles.StartDAQ,'Value',1);
    set(handles.StartDAQ,'BackgroundColor',[1 0 0]);
    set(handles.ed4_savefilename,'Enable','Off');
    set(handles.NewExptButton,'Enable','Off');
    set(handles.hLEDSetupButton,'Enable','Off');
    set(handles.makeExpt,'Enable','Off');
    set(handles.exptTag,'Enable','Off');
    set(handles.NewExptButton,'Enable','Off');
%     handles.tdtparams.DA.SetSysMode(2) % change to 2 for preview mode
    while(handles.tdtparams.DA.GetSysMode<=0 ) % wait for
        sprintf('Waiting for TDT to start Recording')
        pause(0.05)
    end
    handles =updateTDTconnection(handles);  % must get current block and tank information
    handles =updateTDTCallbackTimer(handles);
    start(handles.TDTtimer);
    
elseif status == 0
    set(handles.StartDAQ,'String','Start DAQ');
    set(handles.StartDAQ,'Value',0);
    set(handles.StartDAQ,'BackgroundColor',[0 0.498 0]);
    set(handles.ed4_savefilename,'Enable','On');
    set(handles.NewExptButton,'Enable','On');
    set(handles.hLEDSetupButton,'Enable','On');
    set(handles.NewExptButton,'Enable','On');
    set(handles.makeExpt,'Enable','On');
    set(handles.exptTag,'Enable','On');
    stop(handles.TDTtimer);
%     handles.tdtparams.DA.SetSysMode(0)
end

function handles =updateTDTconnection(handles)
DEFAULT_SAMPLERATE = 24414.0625000000;
% Needed both to start TDT acquisition and to pass to timerCallback
handles.tdtparams.DA = actxcontrol('TDevAcc.X');% Loads ActiveX methods (to control Project)
handles.tdtparams.DA.ConnectServer('Local')
handles.tdtparams.TT = actxcontrol('TTank.X'); % ActiveX to load data from TDT tank

% Setup access to TDT tank
tank = handles.tdtparams.DA.GetTankName;
invoke(handles.tdtparams.TT,'ConnectServer','Local','Me');
if invoke(handles.tdtparams.TT,'OpenTank',tank,'R')~=1; sprintf('Failed Opening %s',tank); end
recblock = handles.tdtparams.TT.GetHotBlock;
handles.tdtparams.blkPATH = fullfile(tank,recblock);

% The parameters BELOW are only needed to initialize DataViewer
handles.tdtparams.TriggerNum = 0;
if ~isempty(recblock)
    [handles.tdtparams.SampleRate,handles.tdtparams.SweepDuration ] = GetFsDurationTrig_TDThelper(handles.tdtparams.blkPATH);
    if isnan(handles.tdtparams.SampleRate), handles.tdtparams.SampleRate= DEFAULT_SAMPLERATE; end
else display('PsychStimController must be running before TDT acquisition can begin');
    handles.tdtparams.SampleRate = DEFAULT_SAMPLERATE; % Hz (default max for TDT rx5)
    handles.tdtparams.SweepDuration = 4;
end

% define TDT parameters many are for compatiblity with DAQcontroller
set(handles.ed4_savefilename,'String',handles.tdtparams.blkPATH);
handles.tdtparams.TriggerRepeat = NaN;
handles.tdtparams.LogFileName = recblock;
handles.tdtparams.SamplesPerTrigger = handles.tdtparams.SweepDuration*handles.tdtparams.SampleRate;
handles.tdtparams.pathname= tank;


function handles =updateTDTCallbackTimer(handles)

userdata.lastTriggerPlotted = 0;

handles.TDTtimerPeriod = handles.tdtparams.SweepDuration/2; % this isn't really optimized probably don

% check if TDTtimer is already defined
tlist = timerfind;
if isempty(tlist)
    ind = [];
elseif length(tlist)>1
    ind = find(cellfun(@(x) isequal(x,'TDTtimer'),tlist.Name));
else ind = 1; end

if isempty(ind)  % create timer
    handles.TDTtimer = timer;
else
    handles.TDTtimer= tlist(ind);
end

set(handles.TDTtimer,'executionMode','fixedRate','Period',handles.TDTtimerPeriod,...
    'StartDelay',handles.tdtparams.SweepDuration,'BusyMode','drop','Name','TDTtimer','Tag','TDTtimer',...
    'TimerFcn',{@TDTDataViewerCallback,handles.hDataViewer,handles.tdtparams},...
    'UserData',userdata)


function ed4_savefilename_Callback(hObject, eventdata, handles)
% TO DO this expt name should be take from expt table or something
% PROB: if expt name is block name then it will not be unique
temp = get(hObject,'String');
if ~handles.tdtparams.DA.SetTankName(temp)
    error('failed to set Tank Name');
end
[ExptPath ExptName] = loadTDThelper_getTankBlk(handles.tdtparams.blkPATH);
setappdata(handles.hDaqController,'ExptName',ExptName);
handles.tdtparams.LogFileName = ExptName;

guidata(hObject,handles);




function ExptTableButton_Callback(hObject, eventdata, handles)

ExptTableNew(handles.hDaqController,0);          % ExptTable(handles,newFlag). newFlag == 0 loads current as opposed default experiment details.

function hExptTable = NewExptButton_Callback(hObject, eventdata, handles)

setappdata(handles.NewExptButton,'ExptTable',handles.RigDef.ExptTable.Parameters);
hExptTable = ExptTableNew(handles.hDaqController,1);

function hLEDSetupButton_Callback(hObject, eventdata, handles)

aoGUI('Visible','off',handles.hDataViewer,handles.hDaqController);

function makeExpt_Callback(hObject, eventdata, handles)

ExptTable = getappdata(handles.NewExptButton,'ExptTable');
expt = MakeExptBA(ExptTable);      % BA - Using my MakeExpt
assignin('base','expt',expt);

function exptTag_Callback(hObject, eventdata, handles)
RigDef = RigDefs;
tag = get(hObject,'String');
exptName = [RigDef.SaveNamePrefix '_' datestr(now,29) '_' tag];
set(handles.ed4_savefilename,'String',...
    [handles.tdtparams.pathname exptName '_1']);
ed4_savefilename_Callback(handles.ed4_savefilename,eventdata,handles)

% Set experiment name in ExptTable
h = handles.hExptTable;
ExptTable = get(h.table,'Data');
% Determine row, then set name
iRow = strcmp(ExptTable(:,1),'Experiment name');
if any(iRow)
    ExptTable{iRow,2} = exptName;
    set(h.table,'Data',ExptTable)
    set(h.save,'Enable','on','FontWeight','bold','ForegroundColor',[1 0 0]);
end


% --- Create functions --- %
function hDaqController_CreateFcn(hObject, eventdata, handles)
function ed4_savefilename_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function exptTag_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- End create functions --- %


function hDaqController_DeleteFcn(hObject, eventdata, handles)
if isfield(handles,'tdtparams')
    handles.tdtparams.DA.CloseConnection
    handles.tdtparams.TT.CloseTank
    handles.tdtparams.TT.ReleaseServer
end
function hDaqController_CloseRequestFcn(hObject, eventdata, handles)
if isfield(handles,'tdtparams')
    handles.tdtparams.DA.CloseConnection
    handles.tdtparams.TT.CloseTank
    handles.tdtparams.TT.ReleaseServer
end



function edit11_Callback(hObject, eventdata, handles)
% hObject    handle to exptTag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of exptTag as text
%        str2double(get(hObject,'String')) returns contents of exptTag as a double


% --- Executes during object creation, after setting all properties.
function edit11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to exptTag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in hLEDSetupButton.
function pushbutton15_Callback(hObject, eventdata, handles)
% hObject    handle to hLEDSetupButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in makeExpt.
function pushbutton16_Callback(hObject, eventdata, handles)
% hObject    handle to makeExpt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in NewExptButton.
function pushbutton17_Callback(hObject, eventdata, handles)
% hObject    handle to NewExptButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in ExptTableButton.
function pushbutton18_Callback(hObject, eventdata, handles)
% hObject    handle to ExptTableButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function edit12_Callback(hObject, eventdata, handles)
% hObject    handle to ed4_savefilename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed4_savefilename as text
%        str2double(get(hObject,'String')) returns contents of ed4_savefilename as a double


% --- Executes during object creation, after setting all properties.
function edit12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed4_savefilename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
