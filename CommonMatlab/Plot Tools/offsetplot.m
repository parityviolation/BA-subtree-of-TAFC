function [s h] = offsetplot(data,dt,off,han,initialOffset)
% function offsetplot(data,dt,off,fid)
% plots data multiple rows of data offset along the y axis
% 
% INPUT:
%        data - N by M matrix
%               where rows N are to be plotted at different offets along
%               the y axis
%        dt - 1/sample rate (s)
%        off - offset along the y-axis in units of std
%        fid - figure handle or axis handle (not sure this is working quite
%        right)
% OUTPUT:
%        s - offset (off*std)
% BA 020707
%%
if nargin <4;
    figure;
    han = gca;
end
if nargin <5;    initialOffset = 0;end

if nargin <3||isempty(off)
    off = mean(std(data,1,2))*2;
end
s = mean(std(data))*off; % average std for all rows
data = data + repmat([0:size(data,2)-1],size(data,1),1)*s+initialOffset*s;

% xval = single(repmat([0:size(data,1)-1]',1,size(data,2))*dt);
xval = [1:size(data,1)]*dt;
%% plot
h = plot(xval,data);
axis tight
if isequal(get(han,'Type'),'axes')
    set(h,'Parent',han)
end
