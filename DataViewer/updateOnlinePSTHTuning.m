function h = updateOnlinePSTHTuning(h,spiketimes,cond)
%
% INPUT
%   h: guidata for the PSTH figure
%   spiketimes:
%   cond:
%
% OUTPUT
%   Created: BA 9/12/10 
nstimcond = cond.stim(2);
icond = cond.led;
if ~isnan(nstimcond)
switch h.cond.engage
    case 'off'
        icond = 1;
        try
        for ichn = 1:size(h.psthData,1)
            h = psthComputeUpdate(h,spiketimes,ichn,nstimcond,icond);
        end
        end
    case 'on'
        switch h.cond.type
            case 'led'
               
                if 0  % find exact condtion
                     icond = find(h.cond.value >= cond.led*0.999 & h.cond.value <= cond.led*1.001);
                else % find greater than minimum Voltage
                    % SRO code (above) is too sensitive to defining the exact led
                    % condition
                    if cond.led>= h.cond.value(2) ;
                        icond = 2;
                    else
                        icond = 1; % ASSUMES condition 1 is No LED
                    end
                end
                for ichn = 1:size(h.psthData,1)
                    h = psthComputeUpdate(h,spiketimes,ichn,nstimcond,icond);
                end
            case 'stim'
        end
end
% h.raster
for i = 1:length(h.RasterOn)
    irow = h.RasterOn(i);
     temp = cell2mat(get(h.axs(irow,:),'YLIM'));
    ylim = [min(temp(:,1)) max(temp(:,2))];
    set(h.axs(irow,:),'YLIM',ylim);
    
    
end


% plot the number trials at each condition
s = sprintf('%d  %d',h.trialcounter(1,nstimcond,1),h.trialcounter(1,nstimcond,2));
set(cell2mat(get(h.axs(:),'Title')),'color',[0.3 0.3 0.3])
setTitle(h.axs(h.RasterOn(1),nstimcond),s,[],[],'r' );

% display(['  ** times cond' num2str(nstimcond) ' ' num2str(h.trialcounter(ichn,nstimcond,:),'%d ')])% Update ticks
for i = 1:h.nPlotOn
    % Put 2 ticks on y-axis
    setAxisTicks(h.axs(i));
end

guidata(h.psthFigTuning,h)
end
% --- Subfunctions --- %

function h = psthComputeUpdate(h,spiketimes,ichn,nstimcond,icond)

% Update trial counter
h.trialcounter(ichn,nstimcond,icond) = h.trialcounter(ichn,nstimcond,icond) + 1;
% Compute spikes per bin
if ~isempty(spiketimes{ichn})
    [counts bin] = histc(spiketimes{ichn},h.edges);
else
    counts = zeros(size(h.psthData,4)+1,1)';
end
% Add counts to psthData
h.psthData(ichn,nstimcond,icond,:) = sum([squeeze(h.psthData(ichn,nstimcond,icond,:))  counts(1:end-1)'],2);

if any(h.psthData(ichn,nstimcond,icond,:)) % only update if non zero
    % Update histogram
    set(h.lines(ichn,nstimcond,icond),'XData',h.xloc,'YData',h.psthData(ichn,nstimcond,icond,:)/h.trialcounter(ichn,nstimcond,icond)/h.binsize);
    axis tight
end

Mx  = max([get(h.lines(ichn,nstimcond,icond),'YData'),get(h.axs(ichn,1),'YLIM')]);
Mn = min([get(h.lines(ichn,nstimcond,icond),'YData'),get(h.axs(ichn,1),'YLIM')]);
ylim = [Mn Mx];
irow = ichn;
set(h.axs(irow,:),'YLIM',ylim);


guidata(h.psthFigTuning,h)

