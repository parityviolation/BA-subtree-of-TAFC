%% Preamble
clear all
% close all
clc
tic
if ismac
    [~,username] = system('whoami');
    if strcmp(username(1:end-1),'thiago')
        dbDir = '/Users/thiago/Dropbox (Learning Lab)/';
    elseif strcmp(username(1:end-1),'Tiago')
        dbDir = '/Users/Tiago/Dropbox/';
    elseif strcmp(username(1:end-1),'ptiagomonteiro')
        dbDir = '/Users/ptiagomonteiro/Dropbox/';
    elseif strcmp(username(1:end-1),'jp2063')
        dbDir = '/Users/jp2063/Dropbox/';
    end
elseif isunix
    dbDir = '/home/thiago/Dropbox (Learning Lab)/';
else
    display 'Not a UNIX system. Terminal based functions will fail.'
end

common.intSet = [.2 .35 .65 .8];
% common.intSet = [.2 .35 .42 .46 .54 .58 .65 .8];
% Myints = {[5 6],[4 5],[5 6]};
% common.rang = [-1 3]; %[-1 1]./120; % In seconds, relative to interval onset
common.fps = 120;
% common.F = round((common.rang(1):.1:common.rang(2))*common.fps); % 100ms steps
% common.mysize = [240, 320];
% mysize = [480, 640];
% common.tbef = 3;
% common.taft = 5;
% common.tbefa = 0.5;
% common.tafta = 0.5;
% common.mfps = 90;
common.lwid = 2; % Line width

% common.xrange = (common.tbef+[-.5 2.5])*common.fps;
% common.xaxisFull = linspace(-common.tbef,common.taft,(common.tbef+common.taft)*common.fps+1);
% common.tNdx = common.xrange(1):common.xrange(2);
% common.ctNdx = (common.tbef-common.tbefa)*common.fps:(common.tbef+common.tafta)*common.fps; % frame index for Classification period
% common.inttNdx = common.tbef*common.fps:(common.tbef+2.4)*common.fps+1;
% 
% common.xaxis = common.xaxisFull(common.tNdx);
% common.cxaxis = common.xaxisFull(common.ctNdx);
% common.inttxaxis = common.xaxisFull(common.inttNdx);

%% PSTHs
common.xaxis = [-1:.02:3]*1000;

%% Plotting
pvar.scale = 2;
pvar.shade = .2;

pvar.time_xlim = [-1 3]*1000;
pvar.time_xrange = diff(pvar.time_xlim);
pvar.time_xlim(1) = pvar.time_xlim(1) - pvar.time_xrange*.05;
pvar.time_xlim(2) = pvar.time_xlim(2) + pvar.time_xrange*.05;
pvar.time_xtick = sort([common.intSet*3 -1 0 1.5 3]*1000);
pvar.time_xticklabel = {'-1' '0' '0.6' '1.05' '1.5' '1.95' '2.4' '3'};

pvar.alchoice_xtick_xlim = [-3 1]*1000;
pvar.time_xrange = diff(pvar.alchoice_xtick_xlim);
pvar.alchoice_xtick_xlim(1) = pvar.alchoice_xtick_xlim(1) - pvar.time_xrange*.05;
pvar.alchoice_xtick_xlim(2) = pvar.alchoice_xtick_xlim(2) + pvar.time_xrange*.05;
pvar.alchoice_xtick = [-3:1]*1000;
pvar.alchoice_xticklabel = {'-3' '-2' '-1' '0' '1'};

pvar.unit_tick = [0 0.5 1];
pvar.unit_ticklabel = [0 0.5 1];
pvar.unit_lim = [-.05 1.05];

pvar.psyc_xtick = sort([common.intSet 0.5]);
pvar.psyc_xticklabel = {'0.6' '' '' '' '1.5' '' '' '' '2.4'};
pvar.psyc_xlim = [min(common.intSet) max(common.intSet)]; 
pvar.psyc_xrange = diff(pvar.psyc_xlim);
pvar.psyc_xlim(1) = pvar.psyc_xlim(1) - pvar.psyc_xrange*.05; 
pvar.psyc_xlim(2) = pvar.psyc_xlim(2) + pvar.psyc_xrange*.05;

pvar.pred_lim = [.45 1.05];
pvar.pred_tick = [.5 .75 1];

pvar.tick_length = ones(1,2)*0.02;
%% Colormaps

% pvar.colora = summer(4);% colora(end,:) =  [1 0.85 0];
% pvar.colora = [linspace(0,1,4)',linspace(0.5,.85,4)',linspace(0.5,0,4)']
nSubjs = 3;
pvar.colora = [linspace(0,1,nSubjs)',linspace(0.5,.85,nSubjs)',linspace(0.55,0,nSubjs)'];
clear nSubjs

% pvar.colorp = cool(6);
% pvar.colorp = rgb2hsv(pvar.colorp); pvar.colorp(:,3) = 0.65;
% pvar.colorp = hsv2rgb(pvar.colorp);
% 
% pvar.colorp100 = cool(100);
% pvar.colorp100 = rgb2hsv(pvar.colorp100); pvar.colorp100(:,3) = 0.65;
% pvar.colorp100 = hsv2rgb(pvar.colorp100);

pvar.colorc = [5 122 166; 255 44 0; 132, 234, 0]/255;
myalpha = .7;
pvar.colorc_patch = pvar.colorc*(1-myalpha)+ones(size(pvar.colorc))*myalpha;

% pvar.colorb = flipud([.75 0 0; 1 .75 0; 0 0 0]);
% pvar.colorb = pvar.colorb.*myalpha + ones(3)*(1-myalpha);

clear myalpha

pvar.colord = [255,106,0; 255,186,0; 24,38,176; 0,160,138]/255;
pvar.colord = [pvar.colord; flipud(pvar.colord)];

pvar.colorcp = [220,0,85; 255,79,0]/255; % Neural(1,:) and Behavioral(2,:) Choice Probability
pvar.colorcp_patch = [238,107,158; 255,158,115]/255;
pvar.colorcp = fliplr(pvar.colorcp);
pvar.colorcp_patch = fliplr(pvar.colorcp_patch);

pvar.colori = jet(length(common.intSet));

pvar.axcol = [1 1 1]*.2;