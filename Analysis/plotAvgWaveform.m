function varargout = plotAvgWaveform(spikes,hAxes)
%
%
%
%
%

% Created: 6/21/10 - SRO
%          9/10/10 - BA added scalebar and dividers
if nargin < 2
    hAxes = axes;
end

[avgwv maxch] = computeAvgWaveform(spikes.waveforms);
avgwv = reshape(avgwv,numel(avgwv),1);
xdata = 1:length(avgwv);

hLine = line('Parent',hAxes,'XData',xdata,'YData',avgwv,'Color',[0.2 0.2 0.2]);
try     set(hAxes,'XLim',[0 max(xdata)*1.3],'YLim',[min(avgwv) max(avgwv)]); end

set(hAxes,'Visible','Off');
time_scalebar = 1;
num_channels = size(spikes.waveforms,3);
num_samples = size(spikes.waveforms,2);

ylims = get(hAxes,'YLim');
% create dividers
for j = 1:num_channels-1
    l(j) = line( 1 + num_samples * j * [1 1], ylims);
end
if num_channels > 1, set( l, 'Color',[1 1 1],'LineWidth',1.5 ); end
  


% create 1ms scalebar
ms =  time_scalebar*spikes.params.Fs/1000;
maxX = num_channels*num_samples;
lineY = ylims(1) + (ylims(2)-ylims(1)) * .075;
hbarX = line(  maxX - 5 - [0 ms], lineY*[1 1] );

% voltage scalebar
v_scalebar = 0.1; % mV
hbarY = line(  maxX*[1 1] , [lineY lineY+v_scalebar] );

set([hbarY hbarY],'color',[0.15 0.15 0.15])

varargout{1} = hLine;
varargout{2} = hAxes;
varargout{3} = maxch;
varargout{4} = hbarX;
varargout{5} = hbarY;