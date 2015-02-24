function h = updateOnlineLFP(h,data,cond)
%
% INPUT
%   h: guidata for the PSTH figure
%   data:
%   cond:
%
% OUTPUT

%   Created: SRO 5/4/10
%   Modifed:

% Extract data in window
try data = data(h.windowPts(1):h.windowPts(2),:);
catch ME
    getReport(ME)
end
h.window = [0.04 1];

% Low-pass filter
data = fftFilter(data,32000,300,1);

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
                if 0  % find exact condtion
                    n = find(h.cond.value == cond.led);
                else % find greater than minimum Voltage
                    % SRO code (above) is too sensitive to defining the exact led
                    % condition
                    if h.cond.value <= cond.led;
                        n = 2;
                    else
                        n = 1; % ASSUMES condition 1 is No LED
                    end
                end
                for m = 1:size(h.lfpData,1)
                    h = lfpComputeUpdate(h,data,m,n);
                end
            case 'stim'
        end
end

% Update ticks
for i = 1:h.nPlotOn
    % Put 2 ticks on y-axis
    setAxisTicks(h.axs(i));
end

guidata(h.lfpFig,h)


% --- Subfunctions --- %

function h = lfpComputeUpdate(h,data,m,n)
if size(data,1) == size(h.lfpData{m,n},1) % because an entire sweep may not have been acquired
    % Update trial counter
    h.trialcounter(m,n) = h.trialcounter(m,n) + 1;
    
    % Add data to lfpData
    try h.lfpData{m,n} = sum([h.lfpData{m,n} data(:,m)],2);
    catch ME % if fails then resetlfpData
        disp(sprintf('\tError: with lfpData averaging\n \tLFP Average RESET'));
        h.lfpData{m,n} = data(:,m);
        h.trialcounter(m,n) = 1;
        getReport(ME)
    end
    
    % Update LFP line
    set(h.lines(m,n),'XData',h.xdata,'YData',h.lfpData{m,n}/h.trialcounter(m,n),'Visible','on');
    set(get(h.lines(m,n),'Parent'),'Visible','on');
    axis tight
    
end

guidata(h.lfpFig,h);


