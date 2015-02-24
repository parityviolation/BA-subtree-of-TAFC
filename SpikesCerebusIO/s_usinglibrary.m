%  CANT figure out how to read in continuous data!!!

Expt.ephys.rawdataFilename= 'E:\Bass\ephys\Sert_179\012014\datafile006';
fn = Expt.ephys.rawdataFilename

r = brigdefs
fn=[fn, '.ns6'];
[ns_Result] = ns_SetLibrary(r.Dir.CereLib);
[ns_Result, hFile] = ns_OpenFile(fn);
[ns_Result, FileInfo] = ns_GetFileInfo(hFile);
[ns_Result, EntityInfo] = ns_GetEntityInfo(hFile, [1 : FileInfo.EntityCount]);

% 
% [ns_RESULT, nsEventInfo] = ns_GetEventInfo(hFile, EntityID)

NeuralList = find([EntityInfo.EntityType] == 4);    % List of EntityIDs needed to retrieve the information and data
SegmentList = find([EntityInfo.EntityType] == 3);
AnalogList = find([EntityInfo.EntityType] == 2);
EventList = find([EntityInfo.EntityType] == 1);
% get segmented channel

chn=35;
for j = NeuralList
    label = EntityInfo(j).EntityLabel; %e.g. 'chan1'
    if strcmp(label, ['chan' num2str(chn)]) %
        idx = [j]; 
    end
end

[ns_Result, ns_info] = ns_GetSegmentInfo(hFile,idx)


count =EntityInfo(idx).ItemCount
[ns_Result, nsAnalogInfo] = ns_GetAnalogInfo(hFile,idx); 
 [ns_RESULT, TimeStamp, Data, SampleCount, UnitID] = ns_GetSegmentData(hFile, idx,[1: count]);


% get sync event
di_idx=[];
for j = EventList
    label = EntityInfo(j).EntityLabel; %e.g. 'chan1'
    if strcmp(label, 'digin') %
        idx = [j]; 
    end
end
count =EntityInfo(idx).ItemCount
[ns_Result, nsEventInfo] = ns_GetEventInfo(hFile,idx); 
[ns_Result, TimeStamp, Data, DataSize]  = ns_GetEventData(hFile,idx,[1:count]);

syncEvent = TimeStamp(Data==4)
