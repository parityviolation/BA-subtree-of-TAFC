function percentCPUTime = getcpuusage(PID)
 [a w] = dos(['wmic path win32_perfformatteddata_perfproc_process where' ...
'(IDProcess = "' num2str(PID) '") get PercentProcessorTime /format:list']);

percentCPUTime = str2num(w(strfind(w,'=')+1:end));