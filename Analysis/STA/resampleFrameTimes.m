function [resample_frame_bin lstTime] = resampleFrameTimes(frametime,tbin,WOI)
% function [resample_frame_bin lstTime] = resampleFrameTimes(frametime,tbin,WOI)
% 
% supersample Frame times for use with computSTA.m

% BA 101110

lstTime = frametime(end) + WOI(1); % time after which not to accept spikes (because spikes may occur after frames stop being shown)

% convert frametimes to bins (super sampling) TODO vectorize (not actually slow)
frame_bin = floor((frametime)/tbin)+1; % tbin that each frame is in
% there is no zero tbin
resample_frame_bin = zeros(round(lstTime/tbin),1,'int32'); %sweep length vector one element for each bin
for frameN = 1:length(frame_bin)-1 % for each frame
    resample_frame_bin(int32([frame_bin(frameN):(frame_bin(frameN+1)-1)]))= frameN; %
end
resample_frame_bin(frame_bin(end):end) = length(frame_bin);
% 
% if any(resample_frame_bin==0)
%     keyboard
% end

% remove bins with no frames
resample_frame_bin(resample_frame_bin==0) = [];

