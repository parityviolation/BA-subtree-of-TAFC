function h = updateOnlinePSTH(h,spiketimes,cond)
%
% INPUT
%   h: guidata for the PSTH figure
%   spiketimes:
%   cond:
%
% OUTPUT
%
%   Created: SRO 4/30/10
%   Modifed: SRO 5/4/10

switch h.cond.engage
    case 'off'
        n = 1;
        for m = 1:size(h.psthData,1)
            h = psthComputeUpdate(h,spiketimes,m,n);
        end
    case 'on'
        switch h.cond.type
            case 'led'
                n = find(h.cond.value == cond.led);
                for m = 1:size(h.psthData,1)
                    h = psthComputeUpdate(h,spiketimes,m,n);
                end
            case 'stim'
        end
end

guidata(h.psthFig,h)

% --- Subfunctions --- %

function h = psthComputeUpdate(h,spiketimes,m,n)

% Update trial counter
h.trialcounter(m,n) = h.trialcounter(m,n) + 1;

% Compute spikes per bin
if ~isempty(spiketimes{m})
    [counts bin] = histc(spiketimes{m},h.edges);
else
    counts = zeros(size(h.edges));
end
% Add counts to psthData

h.psthData{m,n} = sum([h.psthData{m,n} counts(1:end-1)'],2);

% Update histogram
set(h.lines(m,n),'XData',h.xloc,'YData',h.psthData{m,n}/h.trialcounter(m,n)/h.binsize);

axis tight

guidata(h.psthFig,h)

