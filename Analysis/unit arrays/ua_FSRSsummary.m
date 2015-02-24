function hl = ua_FSRSsummary(ua, fdname,bins,hAx,plotType)
% plot RS FS summary
if nargin <5|| isempty(plotType),plotType = 1; end
if nargin <3|| isempty(bins),bins = [0:0.1:1];end
if  nargin <4|| isempty(hAx),hAx = gca; end

% % hack for subfields
% if strfind(fdname,'.')
%     for i = 1:length(ua)
%         try
%             s = sprintf('ua(%d).%s',i,fdname);
%             ua(i).temp = eval(s);
%         catch % sometimes subfield doesn't exit
%             ua(i).temp  = NaN;
%         end
%
%     end
%     fdname = 'temp';
% end

uaFS = filtUnitArray(ua,0,'label','FS good unit');
OSI = cell2mat({uaFS.(fdname)});
if ismember(fdname,{'temp','orievokedrate','osi','orispontrate','spontrate'}), OSIFS = OSI(1:2:end);
    % ASSUME THE FIRST CONDITION IS NO LIGHT. AND ONLY USE THIS CONDITION
else
    OSIFS = OSI;
end
nFS = sum(~isnan(OSIFS));
uaRS= filtUnitArray(ua,0,'label','good unit');
OSI = cell2mat({uaRS.(fdname)});
if ismember(fdname,{'temp','orievokedrate','osi','orispontrate','spontrate'}), OSIRS = OSI(1:2:end);
    % ASSUME THE FIRST CONDITION IS NO LIGHT. AND ONLY USE THIS CONDITION
else
    OSIRS = OSI;
end
% disp('********* Temp hack to remove OSI< 0 and > 1 they shouldn''t exist!!!!!!!!!!')
% OSIRS(OSIRS<0|OSIRS>1) = NaN;
nRS = sum(~isnan(OSIRS));
% OSIFS
% OSIRS


[s sig] = ttest2(OSIRS,OSIFS);
switch plotType
    
    case 1; % plot histogram
        [a_FS x] = hist(OSIFS,bins);
        [a_RS x] = hist(OSIRS,bins);
        
        hl = stairs(x',[a_RS/sum(a_RS); a_FS/sum(a_FS) ]');
        set(hl(1),'color','b','linewidth',2)
        set(hl(2),'color','r','linewidth',2)
        hold on;
        xlim([min(bins) max(bins)])
        
    case 2;
        x = [1 2];
        xvec = ones(size(OSIFS));
        
        hl(1) = line(x(1)*xvec,OSIFS,'color','r','Marker','o','LineStyle','none');
        hl(2) = line([x(1)-.2 x(1)+.2],[1 1]*nanmean(OSIFS),'color','r','linewidth',2);
        xvec = ones(size(OSIRS));
        hold on;
        
        plot(x(2)*xvec,OSIRS,'color','b','Marker','o','LineStyle','none')
        hl(2) = line([x(2)-.2 x(2)+.2],[1 1]*nanmean(OSIRS),'color','b','linewidth',2);
        set(gca,'XTick',x)
        set(gca,'XTickLabel',{'FS','RS'})
        xlim([x(1)-.5 x(2)+.5]);
        
        
end
title(['nPV = ' num2str(nFS) ' nRS = ' num2str(nRS) ' p<' num2str(sig,'%1.1g')]);
defaultAxes(hAx)
set(gca,'box','off')


