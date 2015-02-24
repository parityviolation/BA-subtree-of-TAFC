function [data meanvalue] = stardardizeLEDamp(data,values,win)
% function data = stardardizeLEDamp(data,values,window)

% function to make LED amplitude (which vary slightly because of noise
% in DAQ, standard value

% BA 102910

% % TO DOmake sure values are greater than a win apart
% diff(values)
% if
meanvalue = values;

for i = 1:length(values)
    if length(win) == 1 % treate win as a distance
        distance = abs(data-values(i));
        data(distance<win) = values(i);
    else % find data within each win and assign it to value
        ind = data>=win(i,1) & data<=win(i,2);
        data(ind) = values(i);
        meanvalue(i) = mean(data(ind));
        
        N(i) = sum(ind);
        
    end
    
end
% sum(N);
% length(data)
