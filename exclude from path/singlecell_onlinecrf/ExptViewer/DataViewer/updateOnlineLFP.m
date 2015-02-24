
function h = updateOnlineLFP(h,data,cond)
%
% INPUT
%   h: guidata for the PSTH figure
%   data: 
%   cond: 
%
% OUTPUT
%
%   Created: SRO 5/4/10
%   Modifed: BA 6/5/10 (Fs is no longer hard coded)

% Extract data in window
data = data(h.windowPts(1):h.windowPts(2),:);

% Low-pass filter
data = fftFilter(data,h.Fs,300,1);

% Update and display LFP lines
switch h.cond.engage
    case 'off'
        n = 1;
        for m = 1:size(h.lfpData,1)
            h = lfpComputeUpdate(h,data,m,n);
        end
    case 'on'
        switch h.cond.type
            case 'led'
                n = find(h.cond.value == cond.led);
                for m = 1:size(h.lfpData,1)
                   h = lfpComputeUpdate(h,data,m,n);
                end
            case 'stim'
        end
end

guidata(h.lfpFig,h)


% --- Subfunctions --- %

function h = lfpComputeUpdate(h,data,m,n)
% Update trial counter
h.trialcounter(m,n) = h.trialcounter(m,n) + 1;

% Add data to lfpData
try
h.lfpData{m,n} = sum([h.lfpData{m,n} data(:,m)],2);
catch
    h.lfpData{m,n} = data(:,m); h.trialcounter(m,n) = 1;
    display('online ReSet LFP')
end
% Update LFP line
set(h.lines(m,n),'XData',h.xdata,'YData',h.lfpData{m,n}/h.trialcounter(m,n),'Visible','On');

axis tight

guidata(h.lfpFig,h)


