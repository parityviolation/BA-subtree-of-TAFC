function varargout = plotContrastResponse(response,contrast,hAxes,blog,response_sem,bfit)
% plotContrastResponse(response,contrast,hAxes)
%
% INPUT
%   response: A matrix of column vectors, where the response in each row
%   corresponds to the angle in theta
%   theta: A column vector of angles.
%
%   response_sem is optional. if included should have same number of
%   columns as response
% OUTPUT
%   varargout{1} = hLine: Handles to lines
%   varargout{2} = hAxes: Handle to axes

% Created: 6/21/10 - SRO

if nargin < 3||isempty(hAxes)
    hAxes = axes;
end

if nargin < 4||isempty(blog)
    blog = 0;
end


if nargin < 5||isempty(response_sem)
    response_sem = [];
end

if nargin < 6||isempty(bfit)
    bfit = 0;
end


for i = 1:size(response,2)
    if ~isempty(response_sem)
        set(hAxes,'NextPlot','add');
        hLineerror(i) = errorbar(hAxes,contrast,response(:,i),...
            response_sem(:,i),'linestyle','none');
    else
        hLineerror(i) = line(NaN,NaN);
    end
    
    hLine(i) = line('Parent',hAxes,'XData',contrast,'YData',response(:,i),...
        'linestyle','none','marker','o','markersize',3);
    
    bcannot_fit = 1;
    if bfit & sum(isnan(response(:,i)))<3
        rrfit = response(~isnan(response(:,i)),i)'; %%% NOTE THIS transpose might be wrong
        ccfit = contrast(~isnan(contrast));
        if length(ccfit) == length(rrfit);
            bcannot_fit = 0;
            [ ~, params(i,:) ] = fitit('hyper_ratio',rrfit(:),...
                [ 0 0.15 0 0 ], [], [ 2*max(rrfit) max(ccfit) 10 max(rrfit) ], ...
                [0 1e-4 1e-4 5], ccfit(:) );
            fitc = logspace(-3,0,200);
            hLinefit(i) = line(fitc,hyper_ratio(params(i,:),fitc),'color','k','Parent',hAxes);
        end
    end
    if bcannot_fit
        hLinefit(i) = line(NaN,NaN);
        params(i,:) = nan(1,4);
    end
end
maxR = max(max(response));
minR = 0;
if isnan(maxR) || (maxR == 0)
    maxR = 1;
    disp('Max value NaN or zero')
end
if maxR < 0
    minR = min(min(response));
    maxR = 0;
end
set(hAxes,'XLim',[0 1], 'YLim',[minR maxR],...
    'XTick',[0 0.5 1],'XTickLabel',{'0';'0.5';'1'});

if blog
    set(hAxes,'XScale','log')
end


% Output
varargout{1} = hLine;
varargout{2} = hAxes;
varargout{3} = hLineerror;
varargout{4} = hLinefit;
varargout{5} = params;

