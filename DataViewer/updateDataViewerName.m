function updateDataViewerName(obj,event,hDaqController)

handles = guidata(hDaqController);
sName = getFilename(obj.LogFileName);
if isequal(obj.LoggingMode,'Disk&Memory'),
    sdesc = '';
    sName = sprintf('DaqDataViewer              %s %s',sdesc, sName);
    
else
    sName = 'DaqDataViewer NOT SAVING';
end
set(handles.hDataViewer,'Name',sName);
