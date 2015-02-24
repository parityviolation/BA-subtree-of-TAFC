
%%% WORKS WITH BOTH OLD AND NEW FOURIER
%%% FOR OLD FOURIER NEED TO CHOOSE vr, vl, hd, hu

set(0,'defaultfigureposition',[100,200,480,360])

%% Experiment parameters
% BA to do .. why are there not N different spots for each location?
fCamera = 5;
delay = 2; % BA to do average multiple delays
filt_sigma = 15;
filt_size =round(filt_sigma*3);
filesToAnalyze = [1:29]; % Per position,  sometimes files need to be excluded; (NOTE code changes this variable sometimes see below)
%% Script variables
save_flag = 1;
bfit = 0;
%% Import section
% Paths for stimulus information and camera videos
[expNumStim pathStimulus]=uigetfile('.mat','Select Experiment Stimulus File');
[~, saveFilenameHeader] = fileparts(expNumStim);
ind = strfind(pathStimulus,'\');ind = ind(end-1);
pathExpt = pathStimulus(1:ind);
ind = strfind(pathExpt,'\');
ExptName = pathExpt(ind(end-1)+1:ind(end)-1);
pathVideos=fullfile(pathExpt, 'CAMERA');

% [fileVessels pathVessels]=uigetfile('.fig','Select Vessels Image');
cd(pathStimulus);



% Imports stimulus parameters
stimData = load(fullfile(pathStimulus,expNumStim));
% vessels = getimage(openfig([pathVessels filesep fileVessels],'reuse','invisible'));
% vessels = rot90(vessels,-1);

% Gets videos to analyze
d = dir(fullfile(pathVideos,['*' saveFilenameHeader '*']));
if isempty(d)
    d = dir(fullfile(pathVideos));
end
str = {d.name};
str = sortrows({d.name}');
[s,v] = listdlg('PromptString','Select files to analyze:', 'OKString', 'OK',...
    'SelectionMode','multiple',...
    'ListSize',[300 900],...
    'ListString', str, 'Name', 'Select a File');
names = str(s);
numFiles = size(names, 1);

frame = read_qcamraw([pathVideos filesep names{1}],1);

%% Determines frames per file
framesPerFile = (stimData.baseline+stimData.ITI+stimData.stimLength)*fCamera;
framesTotal = framesPerFile*numFiles;

baselineAvg=nan(size(frame,1),size(frame,2),numFiles);
stimAvg=nan(size(frame,1),size(frame,2),numFiles);

baselineIndex = 1:fCamera*stimData.baseline;
stimIndex = (fCamera*stimData.baseline+delay+1):(fCamera*(stimData.baseline+stimData.stimLength+delay));


%%%%%%%%%% Load file section
%%
bskip = 0;
for k = 1:(numFiles)
    names{k}
    % Loads the file
    try
        rep = read_qcamraw([pathVideos filesep names{k}],1:framesPerFile);
    catch ME
        getReport(ME)
        if k == numFiles % sometimes last frame is missing take care of this
            filesToAnalyze = [1:stimData.stimRep-1]
            bskip = 1;
        end
    end
    
    if ~bskip
        baselineAvg(:,:,k)=mean(rep(:,:,baselineIndex),3);
        stimAvg(:,:,k)=mean(rep(:,:,stimIndex),3);
    end
end

deltaResp =stimAvg-baselineAvg;

%%
h = fspecial('gaussian', filt_size, filt_sigma);
% split by position of patch
nposition = size(stimData.posDeg,1);

deltaRespAvg = nan(size(deltaResp,1),size(deltaResp,2),nposition);
for ipos =1 : nposition
    ind = stimData.stimRep*(ipos-1)+1:stimData.stimRep*ipos;
    ind = ind(filesToAnalyze);
    deltaRespAvg(:,:,ipos) = imfilter(fliplr(mean(deltaResp(:,:,ind),3)),h);
end

%% Figures  on each position

nc =  ceil(sqrt(nposition));
nr = nc;

hf(1) = figure('Position',[100 100 800 800]);
for ipos =1 : nposition
    set(0,'CurrentFigure',hf(1));
    subplot(nr,nc,ipos)
    imagesc(deltaRespAvg(:,:,ipos)); colormap(gray)
    stitle = num2str(stimData.posDeg(ipos,:),' %d');
    if ipos ==1
        stitle = [ExptName ' ' stitle ];
    end
    title(stitle,'Interpreter','none');
    
    if bfit % 2d gaussian fit
        x0 = [1,0,50,100,50,0]; %Inital guess parameters
        Z = deltaRespAvg(:,:,ipos)/(-max(max(deltaRespAvg(:,:,ipos)))); % must invert it and normalize
        xin(6) = 0;
        x = x0;
        lb = [0,-MdataSize/2,0,-MdataSize/2,0];
        ub = [realmax('double'),MdataSize/2,(MdataSize/2)^2,MdataSize/2,(MdataSize/2)^2];
        [x,resnorm,residual,exitflag] = lsqcurvefit(@D2GaussFunction,x0,xdata,Z,lb,ub);
        x(6) = 0;
        fitdata(:,ipos) = x;
        
        figure;
        alpha(0)
        subplot(4,4, [5,6,7,9,10,11,13,14,15])
        imagesc(X(1,:),Y(:,1)',Z)
        title([ExptName ' ' num2str(stimData.posDeg(ipos,:),' %d') ]);
        set(gca,'YDir','reverse')
        % colormap('jet')
        
        %% -----Calculate cross sections-------------
        % generate points along horizontal axis
        m = -tan(x(6));% Point slope formula
        b = (-m*x(2) + x(4));
        xvh = -MdataSize/2:MdataSize/2;
        yvh = xvh*m + b;
        hPoints = interp2(X,Y,Z,xvh,yvh,InterpolationMethod);
        % generate points along vertical axis
        mrot = -m;
        brot = (mrot*x(4) - x(2));
        yvv = -MdataSize/2:MdataSize/2;
        xvv = yvv*mrot - brot;
        vPoints = interp2(X,Y,Z,xvv,yvv,InterpolationMethod);
        
        hold on % Indicate major and minor axis on plot
        
        % % plot pints
        % plot(xvh,yvh,'r.')
        % plot(xvv,yvv,'g.')
        
        % plot lins
        plot([xvh(1) xvh(size(xvh))],[yvh(1) yvh(size(yvh))],'r')
        plot([xvv(1) xvv(size(xvv))],[yvv(1) yvv(size(yvv))],'g')
        
        hold off
        axis([-MdataSize/2-0.5 MdataSize/2+0.5 -MdataSize/2-0.5 MdataSize/2+0.5])
        
        
        ymin = - noise * x(1);
        ymax = x(1)*(1+noise);
        xdatafit = linspace(-MdataSize/2-0.5,MdataSize/2+0.5,300);
        hdatafit = x(1)*exp(-(xdatafit-x(2)).^2/(2*x(3)^2));
        vdatafit = x(1)*exp(-(xdatafit-x(4)).^2/(2*x(5)^2));
        subplot(4,4, [1:3])
        xposh = (xvh-x(2))/cos(x(6))+x(2);% correct for the longer diagonal if fi~=0
        plot(xposh,hPoints,'r.',xdatafit,hdatafit,'black')
        axis([-MdataSize/2-0.5 MdataSize/2+0.5 ymin*1.1 ymax*1.1])
        subplot(4,4,[8,12,16])
        xposv = (yvv-x(4))/cos(x(6))+x(4);% correct for the longer diagonal if fi~=0
        plot(vPoints,xposv,'g.',vdatafit,xdatafit,'black')
        axis([ymin*1.1 ymax*1.1 -MdataSize/2-0.5 MdataSize/2+0.5])
        set(gca,'YDir','reverse')
        figure(gcf) % bring current figure to front
        
        string1 = ['       Amplitude','    X-Coordinate', '    X-Width','    Y-Coordinate','    Y-Width','     Angle'];
        string3 = ['Fit      ',num2str(x(1), '% 100.3f'),'             ',num2str(x(2), '% 100.3f'),'         ',num2str(x(3), '% 100.3f'),'         ',num2str(x(4), '% 100.3f'),'        ',num2str(x(5), '% 100.3f'),'     ',num2str(x(6), '% 100.3f')];
    end
    
    
end

%% Combine all positions into one plot
if bfit
    
    % plot fit gaussians on top of each other.
    % center only
    for ipos = 1:4
    plot(fitdata(2,ipos),fitdata(4,ipos),'o');
    sleg{ipos} = num2str(stimData.posDeg(ipos,:),' %d')
    hold all
    end
    legend(sleg)
    
end
% choose colors


% hf(2) = figure('Position',[100 100 800 800]);
% imagesc(vessels); colormap('gray')

% %% Saving section
if save_flag
    save(fullfile(pathExpt,'ANALYSIS',saveFilenameHeader),'deltaRespAvg','fCamera','delay','filt_size','filt_sigma')
end


