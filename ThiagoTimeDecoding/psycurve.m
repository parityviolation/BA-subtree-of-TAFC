function [psyc, IntervalSet, beta, slope, bias] = psycurve(varargin)
% [psyc, IntervalSet, beta, slope, bias] = psycurve(data,plot,fitPsy)
% data is a struct output by parsedata, or a cell array {interval, intSet, choice}.
% |plot| is a boolean telling whether to plot results. |fitPsy| is a
% boolean telling whether to fit a logistic regression to data. psyc is a 
% n-by-1 vector with the proportion of long reports for the stimuli given 
% by the n-by-1 vector stimSet. IntervalSet is intSet. beta are the fitted
% coefficients. slope and bias are slope and bias of fitted function.

%% Form of psychometric function to be fit
%     function error = sse_psy(param)
%         x = stimSet;
%         a = param(1);
%         b = param(2);
%         %         y = (exp((x-b)/a)./(1+exp((x-b)/a)));
%         l = param(3);
%         u = param(4);
%         y = l + (1-l-u)*(exp((x-b)/a)./(1+exp((x-b)/a)));
%         error = sum(sqrt((y-psyc).^2));
%     end

%% Input arguments
if isstruct(varargin{1})
    dataParsed = varargin{1};
    IntervalVector = dataParsed.Interval;
    IntervalSet = dataParsed.IntervalSet;
    choiceLong = dataParsed.ChoiceLeft;
elseif iscell(varargin{1})
    data = varargin{1};
    IntervalVector = data{1};
    IntervalSet = data{2};
    choiceLong = data{3}';
end

if nargin < 2
    plotb = true;
else
    plotb = varargin{2};
end

if nargin < 3
    fitPsy = true;
else
    fitPsy = varargin{3};
end

choiceLong(choiceLong==-1) = 0;
psyc = zeros(size(IntervalSet));
n = nan(size(IntervalSet));

for s = 1:length(IntervalSet)
    s_index = IntervalVector==IntervalSet(s);
    psyc(s) = nansum(choiceLong(s_index))/sum(s_index);
    n(1,s) = sum(s_index);
end

if fitPsy
    
%     %-- Sigmoid: 4 parameters (slope, bias, lower and upper asymptotes)--%
%         param_init = [.2 .5 min(psyc) max(psyc)];
% %     param_init = [0.2 0.5];
%     
%     [param_fit, ~, ~, ~] = fminsearch(@(param) sse_psy4(param,IntervalSet,psyc), param_init);
%     
%     x = linspace(0,1,100);
%     a = param_fit(1);
%     b = param_fit(2);
%     %     b = 0.5;
%     l = param_fit(3);
%     u = param_fit(4);
% %     y = l + (u-l)*(exp((x-b)/a)./(1+exp((x-b)/a)));
%     %     y = b + (exp((x-.5)/a)./(1+exp((x-.5)/a)));
%     y = l + (u-l)*(exp((x-b)/a)./(1+exp((x-b)/a)));
% %         y = (exp((x-b)/0.1)./(1+exp((x-b)/0.1)));
%     slope = (y(51)-y(50))/(x(51)-x(50));
    % param_fit(end,5) = sse_psy(fmin_outp');
    
    %% GLM fit
    X = IntervalVector;
    y = choiceLong';
    beta = glmfit(X,y,'binomial');
    xaxis = linspace(0,1,101);
    e = exp(beta(1)+beta(2)*xaxis);
    ycont = e./(1+e);
    pse_ndx = find(abs(ycont-0.5)==min(abs(ycont-0.5)));
    if numel(pse_ndx)>1 | pse_ndx==length(ycont)
        slope = 0;
        bias = NaN;
    else
        slope = ((ycont(pse_ndx+1)-ycont(pse_ndx-1))/(xaxis(pse_ndx+1)-xaxis(pse_ndx-1)))/2; % Increase in p(c=long) for 1% increase in interval duration around half-height
        bias = xaxis(pse_ndx);
    end
    
    
else
    pse_ndx = nan;
    beta = nan;
    bias = nan;
    slope = nan;
end

h = [];
% Plot
if plotb
    %     set(0,'DefaultAxesColorOrder',flipud([0.9569    0.1059    0.1373;    0.0078    0.6784    0.9216]))
    h = figure('WindowStyle','docked');
    errorbar(IntervalSet,psyc,sqrt((psyc.*(1-psyc))./n),'.','MarkerSize',20),axis([0 1 0 1]);
    %     plot(stimSet,psyc,'.')
    %     set(h,'Name',['Rat ' dataParsed{1,1} ', under ' dataParsed{1,4} ' on ' dataParsed{1,3}]),title(get(h,'Name'));
    hold on
    
    if fitPsy
        plot(xaxis,ycont,'r')
        plot(.5,.5,'+k')
%         annotation('arrow',[.5 xaxis(pse_ndx)],[.5 .5])
        %     legend Data
    end
    a = gca;
    set(a,'FontName','Arial')
    set(a,'FontSize',16)
    set(a,'FontWeight','normal')
    set(a,'Box','off')
    set(a,'YTick',[0 .25 .5 .75 1])
    xlabel 'Interval duration (boundary = 0.5)'
    ylabel 'Probability of long choice'
end

% varargout{5} = output;
% varargout{6} = param_fit_fval;
% varargout{7} = param_fit_exitflag;
end