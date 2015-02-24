function h = ExptTableNew(varargin)
% GUI with table for entering experimental information during an
% experiment. Data in the table can be used to set fields in the expt
% struct by using the getFromExptTable function when making an expt.

%   Created: SRO - 5/10/10
%   Modified: SRO - 5/20/10

% Inputs
h.hDaqCtlr = varargin{1};
newFlag = varargin{2};

rigdef = RigDefs;

% Make figure
hFig = figure('Visible','off','menubar','none','NumberTitle','off', ...
    'Name','ExptTable','Color',[0.925 0.914 0.847],'HandleVisibility',...
    'callback');
h.ExptTableFig = hFig;
set(hFig,'Units','pixels','Position',[rigdef.ExptTable.Position 439 420],'Resize', ...
    'off');

% Add panel
h.backPanel = uipanel('Parent',h.ExptTableFig,'Units','normalized', ...
    'Position',[0.01 0.01 0.98 0.98]);

% Add save button
h.save = uicontrol('Parent',h.backPanel,'String', ...
    'Save','Units','pixels','Position',[15 5 80 26]);

% Add clear button
h.clear = uicontrol('Parent',h.backPanel,'String', ...
    'Clear','Units','pixels','Position',[100 5 60 26]);

% Add save template button
h.saveTemplate = uicontrol('Parent',h.backPanel,'String', ...
    'Save template','Units','pixels','Position',[208 5 100 26]);

% Add open template button
h.openTemplate = uicontrol('Parent',h.backPanel,'String', ...
    'Open template','Units','pixels','Position',[313 5 100 26]);

% Add table
h.table = uitable('Parent',h.backPanel,'Units','normalized', ...
    'Position',[0.033 0.191 0.94 0.8],'ColumnEditable',logical([1 1]),'ColumnFormat',{'char','char'});
set(h.table,'ColumnWidth',{136 247},'ColumnName',[],'RowName',[]);

if rigdef.ExptTable.MarkPanel
    % Add mark buttons
    h.markPanel = uipanel('Parent',h.backPanel,'Units','pixels',...
        'Position',[15 36 402 37]);
    h.marktxt = uicontrol('Parent',h.markPanel,'Units','pixels',...
        'String','Mark:','Style','text','Position',[24 5 30 20],...
        'FontSize',8);
    buttonnames = {'time','event','newcell'};
    for i = 1:length(buttonnames)
        name = buttonnames{i};
        namestr = [upper(name(1)) name(2:end)];
        xpos = 83 + 90*(i-1);
        h.(name) = uicontrol('Parent',h.markPanel,'Units','pixels',...
            'String',namestr,'Position',[xpos 6 80 24]);
    end
    set(h.time,'Callback',@time_callback)
    set(h.event,'Callback',@event_callback)
%     set(h.cond,'Callback',@cond_callback)
    set(h.newcell,'Callback',@newcell_callback)
else
    set(h.table,'Position',[0.033 0.105 0.94 0.87]);
end

% Set callback functions
set(h.save,'Callback',@save_callback)
set(h.clear,'Callback',@clear_callback)
set(h.saveTemplate,'Callback',@saveTemplate_callback)
set(h.openTemplate,'Callback',@openTemplate_callback)
set(h.table,'CellEditCallback',@tableEdit_callback)

% Save guidata
guidata(hFig,h)

% ExptTable handle as appdata
setappdata(hFig,'hExptTable',hFig);

% Assign ExptTable handle in base workspace
assignin('base','hExptTable',hFig);

% Get handles for DaqController
hDC = guidata(h.hDaqCtlr);
h.ExptTableButton = hDC.ExptTableButton;

% Place experiment table
if newFlag == 1
    ExptTable = getappdata(hDC.NewExptButton,'ExptTable');
elseif newFlag == 0
    ExptTable = getappdata(hDC.ExptTableButton,'ExptTable');
end
set(h.table,'Data',ExptTable);
UpdateExptName(h)

% Enable the save button
set(h.save,'Enable','on','FontWeight','bold','ForegroundColor',[1 0 0]);

% Set directories
h.saveDir = rigdef.Dir.Data;
h.exptTableDir = [rigdef.Dir.Settings 'ExptTable\'];

% Save guidata
guidata(hFig,h)

% Make figure visible
set(hFig,'Visible','on')


% --- Subfunctions --- %

function row = emptyRow(data)
row = -1;
temp = strcmp('',data);
k = find(temp(:,1) == 1);

for i = 1:length(k)
    if temp(k(i),2) == 1
        row = k(i);
        break
    end
end

function enableSave(hObject)
set(hObject,'Enable','on','FontWeight','bold','ForegroundColor',[1 0 0]);

% --- Callbacks --- %

function save_callback(hObject,eventdata)
h = guidata(hObject);
Data = get(h.table,'Data');
temp = Data(3,2);
SaveName = strcat(temp{1},'_ExptTable');
SaveName = fullfile(h.saveDir,SaveName);
save(SaveName,'Data');

% Set ExptTable as appdata in ExptTableButton
setappdata(h.ExptTableButton,'ExptTable',Data)

% Save as template called 'current'
ExptTablePath = h.exptTableDir;
ExptTable = Data;
save([ExptTablePath 'Current'],'ExptTable')

% Return button to default state
set(h.save,'Enable','off','FontWeight','normal','ForegroundColor',[0 0 0]);

function clear_callback(hObject,eventdata)
h = guidata(hObject);
% Get updated ExptTable
ExptTable = get(h.table,'Data');
% Clear entries from 2nd column
for i = 1:length(ExptTable)
    ExptTable{i,2} = ' ';
end
% Update table
set(h.table,'Data',ExptTable);

% % Set info in table as app data in the ExptTableButton on the DaqController
% ExptTable = get(handles.hTable,'Data');
% setappdata(handles.ExptTableButton,'ExptTable',ExptTable);

enableSave(h.save);

function saveTemplate_callback(hObject,eventdata)
h = guidata(hObject);
% Get updated ExptTable
ExptTable = get(h.table,'Data');
% Set save path
ExptTablePath = h.exptTableDir;
cd(ExptTablePath)
% User input
uisave('ExptTable');

function openTemplate_callback(hObject,eventdata)
h = guidata(hObject);
% Path to ExptTable templates
ExptTablePath = h.exptTableDir;
cd(ExptTablePath);
% User choose file
ExptTableFile = uigetfile('*.mat');
if ~ExptTableFile == 0
    load(ExptTableFile);
    % The variable stored in file is called ExptTable
    set(h.table,'Data',ExptTable);
    
    % % Set info in table as app data in the ExptTableButton on the DaqController
    % ExptTable = get(h.table,'Data');
    % setappdata(handles.ExptTableButton,'ExptTable',ExptTable);
    
    % Enable the save button
    enableSave(h.save);
end

function tableEdit_callback(hObject,eventdata)
h = guidata(hObject);
% Enable the save button

enableSave(h.save);


function newcell_callback(hObject,eventdata)

   global AIOBJ
    if strcmp(AIOBJ.Running,'Off')
        
        rigdef = RigDefs();
        h = guidata(hObject);
        expttable = get(h.table,'data');
        
        [exptname irow_exptname] = getFromExptTable(expttable,'Experiment name');
        % save current expttable
        save(fullfile(rigdef.Dir.ExptTable,  exptname ),'expttable');
        
        % copy n rows from current expt
        N = 23; Ntotal = 100;
        expttable = expttable(1:N,:);
        for i = N+1:Ntotal,        expttable(i,:) = {'',''}; end
        
        % clear penentration and depth
        [junk irow] = getFromExptTable(expttable,'Penentration number');
        expttable{irow,2} = '';
        [junk irow] = getFromExptTable(expttable,'Recording depth');
        expttable{irow,2} = '';
        
        % augment cell number
        [svalue irow] = getFromExptTable(expttable,'Cell Number in Animal');
        expttable{irow,2} = num2str(str2num(svalue)+1);
        
                set(h.table,'data',expttable); % this call resets the y scroll position

         UpdateExptName(h);
          
        
    else
        disp('Can create new Cell ExptTable DAQ is running')
    end
    
function newExptname = UpdateExptName(h) % UNTESTED
global AIOBJ

expttable = get(h.table,'data');
% get filename header from AIBOJ
[f f_path] = getFilename(AIOBJ.LogFileName); % will use the same path as in the daq controller
f = seperateFileExtension(f);
ind = regexp(f,'_'); if isempty(ind), ind = length(f)+1; else ind = ind(1); end
f = f(1:ind-1);
% remove CEll suffix
ind = regexp(f,'Cell'); if isempty(ind), ind = length(f)+1; else ind = ind(1); end
newExptname = f(1:ind-1);

% get penentration and depth
[junk irow] = getFromExptTable(expttable,'Experiment name');
cellnumber = getFromExptTable(expttable,'Cell Number in Animal');
if ~isnan(cellnumber)
    newExptname = sprintf('%sCell%s',newExptname,cellnumber);
end
expttable{irow,2} = newExptname;
set(h.table,'data',expttable); % this call resets the y scroll position

if  strcmp(AIOBJ.Running,'Off')
      % if AIOBJ is not running update the Savefilename
        hDaqCtrl_handles = guidata(h.hDaqCtlr);     
        
        AIOBJ.LogFileName =   fullfile(f_path,newExptname);
        hDaqCtrl_handles.aiparams.LogFileName = fullfile(f_path,newExptname);
        set(hDaqCtrl_handles.ed4_savefilename,'String',AIOBJ.LogFileName)
        guidata(h.hDaqCtlr,hDaqCtrl_handles);
end      

enableSave(h.save);

function time_callback(hObject,eventdata)
h = guidata(hObject);
jUIScrollPane = findjobj(h.table);
hy_scrollbar_value = jUIScrollPane.VerticalScrollBar.getValue; % keep current scroll position

jUITable = jUIScrollPane.getViewport.getView;
% get JavaObject from (http://www.mathworks.com/matlabcentral/newsreader/view_thread/165066)
row = jUITable.getSelectedRow + 1; % Java indexes start at 0
col = jUITable.getSelectedColumn + 1;

if row & col % are zero if nothing is selected
    expttable = get(h.table,'data');
    expttable{row,col} = datestr(now,14);
    set(h.table,'data',expttable); % this call resets the y scroll position
    enableSave(h.save);
    pause(0.010);  % see EDT wait for VerticalScrollBar.Value to be set to zero (this is a hack but can't get the call back to work)
               % see http://undocumentedmatlab.com/blog/matlab-and-the-event-di
               % spatch-thread-edt/ for documentation
    jUIScrollPane.VerticalScrollBar.setValue(hy_scrollbar_value) % set the Y scroll position back  
end


function event_callback(hObject,eventdata)

global AIOBJ
h = guidata(hObject);
jUIScrollPane = findjobj(h.table);
hy_scrollbar_value = jUIScrollPane.VerticalScrollBar.getValue; % keep current scroll position

ExptTable = get(h.table,'Data');
irow = emptyRow(ExptTable);
% make table longer there are no empty rows
if irow ==-1,
    nrows = size(ExptTable,1);
    temp = cell(nrows*2,2);
    temp(1:size(ExptTable,1),:) = ExptTable;
    ExptTable = temp;
    irow = nrows+1;
end
ExptTable{irow,1} = sprintf('%s %d %s', getFilename(AIOBJ.LogFileName), AIOBJ.TriggersExecuted,datestr(now,14));
ExptTable{irow,2} = 'event';
set(h.table,'Data',ExptTable)
enableSave(h.save);
pause(0.010);  % see EDT wait for VerticalScrollBar.Value to be set to zero (this is a hack but can't get the call back to work)
               % see http://undocumentedmatlab.com/blog/matlab-and-the-event-di
               % spatch-thread-edt/ for documentation
               jUIScrollPane.VerticalScrollBar.setValue(hy_scrollbar_value) % set the Y scroll position back


function cond_callback(hObject,eventdata)
 
    h = guidata(hObject);
    ExptTable =  get(h.table,'Data');
    
    irow = emptyRow(ExptTable);
    prompt = {'Enter condition type:','Enter condition value:'};
    dlg_title = 'Mark condition';
    nlines= 1;
    answer = inputdlg(prompt,dlg_title,nlines);
    
    % Set event data
    event = [answer{1} '_' answer{2} '_' datestr(now,30)];
    ExptTable{irow,1} = 'cond';
    ExptTable{irow,2} = event;
    set(h.table,'Data',ExptTable)
    
    enableSave(h.save);





