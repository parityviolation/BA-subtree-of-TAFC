function setPIDPriority(PID,priority)

switch(lower(priority))
    case 'high'
        priority_str = '128';
    case 'normal'
        priority_str = '32';
    case 'above normal'
        priority_str = '32768';        
%     case 'realtime' % doesn't seem to work may need to changes user access to
%     make it work
%         priority_str = '256';
end

[a w] = dos(['wmic process where ' ...
    '(processid = "' num2str(PID) '") CALL setpriority ' priority_str]);
