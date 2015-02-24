function [PID]= getPID(simagename)

%BA
 PID = []; % default
 
[a w]= dos(['tasklist /FI "IMAGENAME eq ' simagename '" /FO "CSV" /NH']);
C = textscan(w,'%s %s %s %s %s %s','delimiter',',');

%PID
a = C{2};
try
    for i = 1:length(a)
        if ~isempty(a{i})
            PID(i)= str2num(a{i}(2:end-1));
        end
    end
    
%     %MEMUSAGE
%     a = C{5};
%     for i = 1:length(a)
%         MEMUSAGE(i)= str2num(strrep( a{i}(2:end-3),'.',''));
%     end
catch ME
    getReport(ME)
    PID = [];
%     MEMUSAGE = [];
end
    

