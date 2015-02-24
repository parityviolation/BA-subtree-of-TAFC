function h = plot_significanceMovingWindow(data1,data2,windowSize,windowOverlap,options)
%
% BA 040914
% compare 2 sets of timeseries
% test if there is a significant difference in a moving window
% Sig is computed using bootstrap
% bootfun is mean by default but can be customized
%
% data1 = spdfilt';
% data2 =  spdfilt';
% moving window signifigance test
% data1 %- samples x trials
% data2 %-  samples x trials
% windowSize = 10; %  samples
% windowOverlap = 5; % samples

if nargin < 4
    error('must specify 4 inputs')
end
if size(data1,1)~=size(data2,1)
    error('data1 and data2 must be equal in dim 1');
end

% defaults
bplot = 1;
bNoerrorbar = 0;

% methods of signifigance
% sigMethod = 'boot' % use bootstrap ( this finds more siginfigance, since
% it only uses 1 distribution not the other)
sigMethod = 'ranksum'; % use

% bootstrap parameters
nboot = 500;
bootfun = @nanmedian;

alpha = 0.05; % signifigance level


dt = 1;
xOffset = 0;
% plot options
mycolor{1} = [0 0 0]; % color of data set with more trials
mycolor{2}= [0 0 1]; %
hAx = gca;

if exist('options','var')
    if isfield(options,'dt')
        dt = options.dt; % (optional) scale factor for samples to time
    end
    if isfield(options,'dt')
        xOffset = options.xOffset; % (optional) scale factor for samples to time
    end
    if isfield(options,'color')
        mycolor = options.color; % (optional) scale factor for samples to time
    end
    if isfield(options,'alpha')
        alpha = options.alpha; % (optional) scale factor for samples to time
    end
    if isfield(options,'bootfun')
        bootfun = options.bootfun; % (optional) scale factor for samples to time
    end
    if isfield(options,'hAx')
        hAx = options.hAx; % (optional) scale factor for samples to time
    end
end

% Figure out how many windows
nsamples = size(data1,1);
nsteps = floor(nsamples-(windowOverlap+windowSize)/windowOverlap);
temp = ([1:nsteps]-1)*windowOverlap+windowSize;
nsteps = sum(temp<=nsamples);
lastSample = temp(nsteps);

% Use  dataset with more trials for bootstrapping (first index is for
% boostraping)
indData = [1 2];
if size(data2,2)>size(data1,2),indData = [2 1]; end

%  data outside of the last window truncated
dataCell{1} = data1(1:lastSample,:);
dataCell{2} = data2(1:lastSample,:);
clear data1 data2;

stat = nan(nsteps,length(dataCell));% the statistic bootfun for each window of each dataset
statci{1} = nan(nsteps,2);
statci{2} = nan(nsteps,2);
hsig = nan(nsteps,1);
for istep = 1: nsteps
    offsetInd = (istep-1)*windowOverlap;
    thisWindowInd = [1+offsetInd:offsetInd+windowSize];
    
    for idata = indData
        thisWindow{idata} = nanmean(dataCell{indData(idata)}(thisWindowInd,:,:));
        thisWindow{idata}(isnan(thisWindow{idata})) = []; % removenans
        stat(istep,idata) =  bootfun(thisWindow{idata}');
        if ~bNoerrorbar
            [statci{idata}(istep,:) bootstat] = bootci(nboot,{bootfun,thisWindow{idata}'});
        end
        [statci{idata}(istep,:) ] = 0;
    end
    
    % compute ranksum signifgance
    [p(istep) hsig(istep)] = ranksum(thisWindow{1} ,thisWindow{2}, 'alpha',alpha);
end

switch (sigMethod)
    case 'boot'
        % find the windows were data outside of the ci
        hsig  = single(stat(:,2) < statci{1}(:,1) | stat(:,2) > statci{1}(:,2));
    otherwise
end
hsig(hsig==0) = NaN;

%%
if  bplot
    xtime = [1:nsteps]*windowOverlap*dt+xOffset;
    if ~bNoerrorbar % plot with patch %not good for saving
        [h.hl(1) h.hp(1)] = errorpatch(xtime',stat(:,1),stat(:,1)-statci{1}(:,1),statci{1}(:,2)-stat(:,1),hAx); hold on
        setColor([h.hl(1) h.hp(1)],mycolor{1})
        [h.hl(2) h.hp(2)] = errorpatch(xtime',stat(:,2),stat(:,2)-statci{2}(:,1),statci{2}(:,2)-stat(:,2),hAx); hold on
        setColor([h.hl(2) h.hp(2)],mycolor{2})
    else
        h.hl(1) = line(xtime,stat(:,1),'color',mycolor{1},'Parent',hAx);
        h.hl(2) = line(xtime,stat(:,2),'color',mycolor{2},'Parent',hAx);
    end
    %        plot line on top if significantly different
    y = max(get(hAx,'ylim'))*1.02;
    h.hl(3) = line(xtime,hsig*y,'color','k','Marker','none','Linestyle','-','Linewidth',2,'Parent',hAx);
end

