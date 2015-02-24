function h = updateOnlineFR(h,spiketimes,cond)
%
% INPUT
%   h: guidata for the FR figure
%   spiketimes:
%
% OUTPUT

%   Created: SRO 4/30/10
%   Modifed: BA 9/20


% h.colors{1,1} = [0.5 0.5 0.5];
% % h.colors{2,1} = 	[0, 183, 235]/255;
% h.colors{2,1} = 	[224, 255, 255]/255;
% h.colors{3,1} = [0 0 1];
% h.colors{1,2} = [0 0 0];
% h.colors{2,2} = [0 1 0];
% h.colors{3,2} = [0 127/255 0];

    h.windows = {[0 0.5] [0.5 1] [1.05 2]};


% Get time of sweep relative to first sweep
if isnan(h.time)
    h.starttime = clock;
    h.time(1) = 0;
else
    h.time(end+1) = etime(clock,h.starttime)/60; % In minutes
end

switch h.cond.engage
    case 'off'
        icond = 1;
        
    case 'on'
        
        if cond.led>= h.cond.value(2) ;
            icond = 2;
        else
            icond = 1; % ASSUMES condition 1 is No LED
        end
end

for ichn = 1:size(h.frData,1) % BA this outer loop could probably be removed with vectorized operation
    for iwind = 1:size(h.frData,2)
        
        % Compute% BA this probably could be ma
        window = h.windows{iwind};
        k = ((spiketimes{ichn} >= window(1)) & (spiketimes{ichn} <= window(2)));
        if isempty(k), k = 0; end
        ind = length(h.time);
        if ind>size(h.frData,4) % grow data matrix
            temp = nan(size(h.frData));
            temp(:,:,:,1:size(h.frData,4)) = h.frData;
            h.frData = temp;
        end
        h.frData(ichn,iwind,icond,ind) = sum(k)/diff(window);
        
        % Update plot
        set(h.lines(ichn,iwind,icond),'XData',h.time,'YData',h.frData(ichn,iwind,icond,1:ind));
    end
    
end
if max(h.time) > 0
    set(h.axs(:),'XLim',[0 max(h.time)])
end

% Update ticks
for i = 1:h.nPlotOn
    % Put 2 ticks on y-axis
    setAxisTicks(h.axs(i));
end

guidata(h.frFig,h)