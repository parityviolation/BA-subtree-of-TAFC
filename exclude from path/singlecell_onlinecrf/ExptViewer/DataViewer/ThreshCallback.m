function handles = ThreshCallback(hObject,eventdata,handles,UpdateFlag)
%
%
%
%   Created: 4/5/10 - SRO
%   Modified:

if nargin == 3
    UpdateFlag = 1;
end
status = get(hObject,'Value');
if status == 1
    if strcmp(get(hObject,'Enable'),'on')
        set(hObject,'BackgroundColor',[0.3 0.3 1]);       % blue
    end
elseif status == 0
    if strcmp(get(hObject,'Enable'),'on')
        set(hObject,'BackgroundColor',[0.8 0.8 0.8]);
    end
end

% Set limits of slider to min and max of axis
TglIndex = find(handles.hTglThr == hObject);
AxisLimits = get(handles.hAllAxes(TglIndex),'YLim');
set(handles.hAllSliders(TglIndex),'Min',AxisLimits(1),'Max',AxisLimits(2));

% Make slider vector
handles = MakeThreshVector(handles);
guidata(handles.hPlotChooser,handles);
% Update DataViewer
dvHandles = guidata(handles.hDataViewer);
UpdateDataViewer(dvHandles);