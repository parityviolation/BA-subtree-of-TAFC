function Displacement = PlotDisplaced(tt,zz,v,mode,colors)
% PlotDisplaced plots traces vertically displaced
% 
% PlotDisplaced(zz) with zz nTraces X nSamples
%
% PlotDisplaced(tt,zz) with zz nTraces X nSamples
%
% PlotDisplaced(tt,zz,v) lets you specify how many standard deviations v
% separate the traces (DEFAULT: 5)
%
% PlotDisplaced(tt,zz,v,displacement) 'absolute' interprets v as an absolute displacement (not
% the number of standard deviations) (DEFAULT: 'std')
%
% PlotDisplaced(tt,zz,v, displacement, colors) lets you specify a color (e.g.
% 'k') or a sequence of colors (e.g. 'rbgk')
%
% Displacement = PlotDisplaced(...) reports the absolute displacement
%
% 2007 Matteo Carandini
% 2007-06 SK removed limitation on number of traces by looping through 'colors' string 
% 2007-06 MC added an indication of amplitude
% 2007-06 MC added output of displacement
% 2008-06 LB added input color
% 2009-04 ND added ability to specify mode without specifying displacement magnitude

if nargin<5
    colors = 'rbgk';
end

if nargin<4
    mode = 'std';
end

if nargin<3 || isempty(v)
    v = 5;
end

if nargin<2
    zz = tt;
    tt = 1:size(zz,2);
end

[nc,nt] = size(zz);

% added 2008-11-10
zz = zz - mean(zz(:));

%colors = 'rbgkrbgkrbgkrbgkrbgkrbgk';
%colors = 'rbgk';

switch mode
    case 'std'
        Displacement = v*nanstd(zz(:));
    otherwise
        Displacement = v;
end
Displacement = Displacement+eps; % to deal with case when it is zero

for ic = 1:nc
    plot( tt, zz(ic,:) - (ic-1)*Displacement, 'color', colors(mod(ic-1, length(colors))+1) ); hold on
end
% axis tight
% commented out 2008-11-10

set(gca,...
     'ytick',zz(1,1)+[-Displacement 0 ],...
    'yticklabel',[0 str2num(num2str(Displacement,2))],...
    'ycolor','k',...
    'box','off',...
       'xlim',[-inf inf],...
    'ylim',Displacement * [ -nc 1 ]); % added the last two 2008-11-10

