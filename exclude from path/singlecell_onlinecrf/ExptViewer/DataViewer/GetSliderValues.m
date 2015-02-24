function handles = GetSliderValues(handles)

Thresholds = cell2mat(get(handles.hAllSliders,'Value'));
Invert = sign(Thresholds);
Invert(Invert==0) = 1;
handles.Thresholds = [abs(Thresholds) Invert];
setappdata(handles.hDataViewer,'Thresholds',handles.Thresholds);