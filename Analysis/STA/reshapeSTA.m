function [data d]= reshapeSTA(data, d)

if ndims(data)==3 % convert to 2 SPACE x TIME
    [dx dy df] = size(data); % get xspace x yspace x frames of movie
    
    data = reshape(data,dx*dy,df);
    d = [dx dy df];
    
else % convert to 3 xspace x yspace xtime
    dx = d(1); dy = d(2); df = d(3);
    data = reshape(data,[dx,dy,df]);
end