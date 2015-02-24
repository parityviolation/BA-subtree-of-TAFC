function varargout = plotOrientTuning(response,theta,hAxes,response_sem,bfit)
% function varargout = plotOrientTuning(response,theta,hAxes)
%
% INPUT
%   response: A matrix of column vectors, where the response in each row
%   corresponds to the angle in theta
%   theta: A column vector of angles.
%
% OUTPUT
%   varargout{1} = hLine: Handles to lines
%   varargout{2} = hAxes: Handle to axes

% Created: 5/16/10 - SRO

if nargin < 3
    hAxes = axes;
end
if nargin <4||isempty(response_sem)
    response_sem = [];
end

if nargin < 5||isempty(bfit)
    bfit = 0;
end
% Replicate theta to get same number of columns as response matrix
ncol = size(response,2);
theta = repmat(theta,1,ncol);

% Make sure theta is defined at both 0 and 360 degrees
if ~ismember(360,theta)&ismember(0,theta)
    nrow = size(response,1);
    response(nrow+1,:) = response(theta==0);
    if ~isempty(response_sem)
        response_sem(nrow+1,:) = response_sem(theta==0);
    end
    
    theta(nrow+1,:) = 360;
end

if bfit
    rtemp = response;
    if size(rtemp,2)>1 && all(isfinite(nanmean(rtemp(:,2)))) % for 2G fit
        % use first 2 conditions to fix prefferred direction
        rr_ctrl = rtemp(:,1); rr_opto = rtemp(:,2); % assume first condition is control (not critical here)
        rr_opto(isnan(rr_opto)) = 1; % remove nans
        rr_ctrl(isnan(rr_ctrl)) = 0;
        rmerge = nanmean( [rr_ctrl*(rr_ctrl\rr_opto), rr_opto], 2 );
        parsmerge = fitori(theta(:,1),rmerge);
        Dp = parsmerge(1); % fix the preferred direction
        if size(rtemp,2)>2
            disp('more than 2 Ori conditions found, only first 2 used to fix prefferred direction of 2Gfit')
        end
    else
        Dp = NaN;
    end
end

for i = 1:size(response,2)
    hLine(i) = line('Parent',hAxes,'XData',theta(:,i),'YData',response(:,i),...
        'linestyle','none','marker','o','markersize',3);
    if ~isempty(response_sem)
        set(hAxes,'NextPlot','add');
        hLineerror(i) = errorbar(hAxes,theta(:,i),response(:,i),...
            response_sem(:,i),'linestyle','none');
    else
        hLineerror(i) = line(NaN,NaN);
    end
    
    
    if bfit
        ind = ~isnan(response(:,i));
        fitr = response(ind,i);
        fittheta = theta(ind,i);
        
        params(i,:)= fitori(fittheta,fitr,[],[Dp NaN NaN NaN NaN]);
        fitt = [0:360];
        hLinefit(i) = line(fitt,oritune(params(i,:),fitt),'color','k','Parent',hAxes);
        
    else
        hLinefit(i) = line(NaN,NaN);
        params = NaN;
    end
end
if ~isempty(response_sem)
    response = response +response_sem;
end
maxR = max(max(response))*1.05;
if ~isempty(response_sem)
    response = response -2*response_sem;
end

minR = min(min(response));
if isnan(maxR) || (maxR <= 0)
    maxR = 1;
    disp('Max value NaN or zero')
end
set(hAxes,'XLim',[0 360], 'YLim',[minR maxR],...
    'XTick',[0 180 360],'XTickLabel',{'0';'180';'360'});


% Output
varargout{1} = hLine;
varargout{2} = hAxes;
varargout{3} = hLineerror;
varargout{4} = hLinefit;
varargout{5} = params;

