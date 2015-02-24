function h = ua_plotWaveform(ua_temp,ax)

if nargin<2, ax = gca; end

% load the spikes file of this  ua
[ua_temp] = populateUnitFields( addUnitFields(ua_temp, 'avgSpikeWav'));
% there must be abetter way
for i = 1:length(ua_temp)
    avgwv_maxch{i} = ua_temp(i).avgSpikeWav.wvMaxChn;
    xtime{i} = ua_temp(i).avgSpikeWav.timebase;    
end
 
% normalize to trough
avgwv_maxch = cellfun(@(x) x/min(x)*sign(min(x)),avgwv_maxch,'UniformOutput',0);
% set trough time
xtime = cellfun(@(y,x) x-x(find(y==min(y),1,'first')),avgwv_maxch, xtime,'UniformOutput',0);

h = cellfun(@(y,x) line(x,y),avgwv_maxch,xtime,'UniformOutput',0);

set(cell2mat(h),'Parent',ax);