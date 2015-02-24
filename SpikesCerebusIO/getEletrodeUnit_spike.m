function [electrode unit descstr] = getEletrodeUnit_spike(spikesOrspikesf)
% BA 052014

electrode = NaN;
unit = NaN;
if isstruct(spikesOrspikesf)
    spikes = spikesOrspikesf;
    electrode =  unique(spikes.Electrode);
    unit =  unique(spikes.Unit);   
else
    spikesf = spikesOrspikesf;
    ind  = find(  cellfun(@(x) isequal('Electrode',x),spikesf));
    if ~isempty(ind)       electrode = spikesf{ind+1};    end
    ind  = find(  cellfun(@(x) isequal('Unit',x),spikesf));
    if ~isempty(ind)        unit = spikesf{ind+1};    end  
end
    descstr = ['E' num2str(electrode,'%d_') 'U' num2str(unit,'%d_')];