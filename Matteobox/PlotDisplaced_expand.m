function Displacement = PlotDisplaced_expand(tt,zz,v,mode,styles,linewidth)
% PlotDisplaced plots traces vertically displaced
% 
% PlotDisplaced(zz) with zz nTraces X nSamples
%
% PlotDisplaced(tt,zz) with zz nTraces X nSamples
%
% PlotDisplaced(tt,zz,v) lets you specify how many standard deviations v
% separate the traces (DEFAULT: 5)
%
% PlotDisplaced(tt,zz,v,'absolute') interprets v as an absolute displacement (not
% the number of standard deviations)
%
% PlotDisplaced(tt,zz,v, 'std', 'colors') lets you specify a color (e.g.
% 'k') or a sequence of colors (e.g. 'rbgk')
% 
% PlotDisplaced(tt,zz,v, 'std', 'styles') lets you specify things like
% markers ('o') or colors ('r') or linestyles('--') or a series of these in
% any order that will sort out which is which and then put them in a
% sequential order ('ro-bg*sk') will become markers ('o*s'), colors
% ('rbgk'), and linestyles('-'); each of the three will get cycled through
% so if specified differently, won't always have red line with circles. in
% this example, you'd always have lines, and you'd have red circles, blue
% stars, green squares, black CIRCLES and then red stars and so on...
% CAVEAT : Does not work for dash-dot and dash linestyles because those use
% two symbol indicators.
%
% PlotDisplaced(tt,zz,v, 'std', 'colors',linewith) lets you specify a linewidth (e.g.
% 1.5) or a vector of linewidths [1 1.5 2]. Defaults to 1
%
% Displacement = PlotDisplaced(...) reports the absolute displacement
%
% 2007 Matteo Carandini
% 2007-06 SK removed limitation on number of traces by looping through 'colors' string 
% 2007-06 MC added an indication of amplitude
% 2007-06 MC added output of displacement
% 2008-06 LB added input color
% 2008-12 ND added linewidth
% 2009-08 ND changed input color to something that figures out color, linestyle, and marker

if nargin<6 || isempty(linewidth)
    linewidth = 1;
end

colors = '';
markers = '';
linestyles = '';
if exist('styles','var')
    if isempty(styles)
        colors = 'rgbk';
        markers = {'none'};
        linestyles = '-';
    else
        for istyle = 1:length(styles)
            switch(styles(istyle))
                case 'r'
                    colors = [colors 'r'];
                case 'g'
                    colors = [colors 'g'];
                case 'b'
                    colors = [colors 'b'];
                case 'k'
                    colors = [colors 'k'];
                case 'c'
                    colors = [colors 'c'];
                case 'm'
                    colors = [colors 'm'];
                case 'y'
                    colors = [colors 'y'];
                case 'k'
                    colors = [colors 'k'];
                case 'o'
                    markers = [markers; {'o'}];
                case '.'
                    markers = [markers; {'.'}];
                case 'x'
                    markers = [markers; {'x'}];
                case '+'
                    markers = [markers; {'+'}];
                case '*'
                    markers = [markers; {'*'}];
                case 's'
                    markers = [markers; {'s'}];
                case 'd'
                    markers = [markers; {'d'}];
                case 'v'
                    markers = [markers; {'v'}];
                case '>'
                    markers = [markers; {'>'}];
                case '<'
                    markers = [markers; {'<'}];
                case '^'
                    markers = [markers; {'^'}];
                case 'p'
                    markers = [markers; {'p'}];
                case 'h'
                    markers = [markers; {'h'}];
                case '-'
                    linestyles = [linestyles '-'];
                case ':'
                    linestyles = [linestyles ':'];
                otherwise
                    colors = 'rgbk';
                    markers = {'none'};
                    linestyles = '-';
            end
        end
    end
else
    colors = 'rgbk';
    markers = {'none'};
    linestyles = '-';
end
% if you have tried to define the styles and something hasn't been defined
% then you probably don't want it so make the colors cycle do something
% smart with the other two.
if isempty(colors)
    colors = 'rgbk';
end
if isempty(markers)
    markers = {'none'};
    if isempty(linestyles)
        linestyles = '-';
    end
end
if isempty(linestyles)
    linestyles = {'none'};
end


if exist('mode','var')
    if isempty(mode)
        mode = 'std';
    end
else
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

switch mode
    case 'std'
        Displacement = v*nanstd(zz(:));
    otherwise
        Displacement = v;
end
Displacement = Displacement+eps; % to deal with case when it is zero

for ic = 1:nc
    h = plot( tt, zz(ic,:) - (ic-1)*Displacement, 'Color', colors(mod(ic-1, length(colors))+1) ); hold on
    set(h,'LineWidth',linewidth(mod(ic-1,length(linewidth))+1));
    set(h,'LineStyle',char(linestyles(mod(ic-1, length(linestyles))+1)));
    set(h,'Marker',char(markers(mod(ic-1,length(markers))+1)));
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

