function [indlight ledamp] = getLEDCondfromDAQ(STF,chn,DAQSAVEPATH,bNoplot)
% function indlight = getLEDCondfromDAQ(STF,chn,DAQSAVEPATH,bNoplot)
% to seperate sweeps were light was on from off:
% detects sweeps that have an integratal that is greater than mean/2 of the
% mean integral of all sweeps. and calls those on.
%
if ~exist('bNoplot','var'),bNoplot = 0; end
if ~isstruct(STF)
    temp = STF ;% to avoid warning
    clear STF
    STF.filename = temp;
    % note doesn't deal with multiple file input in non-struct format
end

for i = 1:length(STF)
    filtparam.dfilter = [NaN,200,60 0]; % for other filters (none)
    bNoLoad = 0;                                                    % reload of you can
    % Get data
    [data dt]= preprocessDAQ([],STF,chn,filtparam,bNoLoad);
    if ~bNoplot
        try hf = figure('Name',sprintf('%s chn %d',STF.filename,chn)); end
        %     hf = figure(99);
    end
    
    %     [data dt] = loadDAQData(fullfile(DAQSAVEPATH,STF(i).filename),chn);
    
    % % method 1
    % temp = sum(data(:,:,1));
    % m = mean(temp);
    % temp = temp - mean(temp);
    % indlight{i} = temp> 0;
    
    % range method
    %     R = range(data);
    %     R = mean(R(R>(min(R)+.2)));
    %     M = mean(min(data));
    %     temp =  max(data);
    %     indlight{i} = temp >= M+R;
    % % method max
    
    if 1 % current method
        ledamp{i} = max(data);
        m =0.01; % Value must be greater than 0.5 (this prevents setting LEDcond = 1 when no light was on for the entire file)
        indlight{i} = ledamp{i}> m;
        
    else % old method
        ledamp{i} = max(data);
        m = max(mean(ledamp{i}),0.5); % Value must be greater than 0.5 (this prevents setting LEDcond = 1 when no light was on for the entire file)
        indlight{i} = ledamp{i}> m;
    end
    
    
    if ~bNoplot
        subplot(4,1,1)
        [a x] = hist(ledamp{i}); h = stairs(x,a); hold all;
        line([m m],[0 1]*max(a),'color','r','linewidth',2)
        subplot(4,1,2);
        if any(indlight{i})
            plot(repmat([1:4:size(data,1)]'*dt,1,sum(indlight{i})),data(1:4:end,indlight{i},1)+max(max(max(data(:,indlight{i},1)),max(ylim)))*1.05,'color',get(h,'color')); hold on;
        end
        n = sum(indlight{i});
        title(sprintf('ON %d',n));
        subplot(4,1,3);
        if any(~indlight{i})
            plot(repmat([1:4:size(data,1)]'*dt,1,sum(~indlight{i})),data(1:4:end,~indlight{i},1)+max(max(max(data(:,~indlight{i},1)),max(ylim)))*1.05,'color',get(h,'color')); hold on;
        end
        n = sum(~indlight{i});
        title(sprintf('OFF %d',n));
        
        subplot(4,1,4);
        plot(indlight{i}); xlabel('trigger #')
        sl{i} = STF(i).filename;
    end
end
if ~bNoplot
    subplot(4,1,1)
    legend(sl,'Interpreter','none');
end