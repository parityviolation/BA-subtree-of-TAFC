function a =  killPID(PID)
 a = dos(['TASKKILL /PID ' num2str(PID)]);