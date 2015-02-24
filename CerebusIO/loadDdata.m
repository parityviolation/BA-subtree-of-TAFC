function ev = loadDdata(filename)
% load digital channel 2 (could be modified to load other channels
dt = 1/30000;

r = brigdefs;
[ns_Result] = ns_SetLibrary(r.Dir.CereLib);
[ns_Result, hFile] = ns_OpenFile(filename);
[ns_Result, FileInfo] = ns_GetFileInfo(hFile);
[ns_Result, EntityInfo] = ns_GetEntityInfo(hFile, [1 : FileInfo.EntityCount]);

EventList = find([EntityInfo.EntityType] == 1);

% get sync event
idx=[];
for j = EventList
    label = EntityInfo(j).EntityLabel; %e.g. 'chan1'
    if strcmp(label, 'digin') %
        idx = [j]; 
    end
end
    
count =EntityInfo(idx).ItemCount;
[ns_Result, nsEventInfo] = ns_GetEventInfo(hFile,idx); 
[ns_Result, TimeStamp, Data, DataSize]  = ns_GetEventData(hFile,idx,[1:count]);

ev.dt = dt;
ev.data = unique(Data);
ev.timestamp = TimeStamp(Data==4);
ev.timestamp_sample= round(ev.timestamp/dt);
 
