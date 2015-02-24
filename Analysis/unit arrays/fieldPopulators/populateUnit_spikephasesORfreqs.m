function unit = populateUnit_spikephasesORfreqs(unit, curExpt, curTrodeSpikes, varargin)
    if(iscell(varargin{1}))
        varargin = varargin{1};
    end
    
    field_name = varargin{1};
    if(length(varargin) > 1)
        user_input = varargin{2};
    else
        user_input = 'n';
    end
    if(length(varargin) > 2)
        force_load = varargin{3};
    else
        force_load = 0;
    end
        
    
    tempspikes = filtspikes(curTrodeSpikes, 0, 'assigns', unit.assign);        
    if(~force_load)
        meanspikeCond = (strcmp(field_name, 'mean_spike_phase'));    
        circstdCond = (strcmp(field_name, 'phase_circ_std'));
        % ugly code below, as was rushing before SfN. will strip redundant lines in
        % if statements in upcoming commit
        if(meanspikeCond)
            if(isfield(unit, 'spikephases'))
                unit.mean_spike_phase = circularMean(unit.spikephases(:), 360, 1);
                return;
            elseif(isfield(tempspikes, 'spikephases'))
                unit.mean_spike_phase = circularMean(tempspikes.spikephases(:), 360, 1);
                return;
            end
        elseif(circstdCond)
            if(isfield(unit, 'phase_circ_std'))
                phases_no_nan = unit.spikephases(~isnan(unit.spikephases));
                unit.phase_circ_std = circ_std(phases_no_nan(:) ./ 180 * pi) ./ pi * 180;
                return;
            elseif(isfield(tempspikes, 'phase_circ_std'))
                phases_no_nan = tempspikes.spikephases(~isnan(tempspikes.spikephases));
                unit.phase_circ_std = circ_std(phases_no_nan(:) ./ 180 * pi) ./pi * 180;
                return;
            end                
        elseif(isfield(tempspikes, field_name))
            % if the spike struct already has spikephases or freqs, life is
            % easy        
            if(~all(isnan(tempspikes.(field_name))))
                unit.(field_name) = tempspikes.(field_name);            
                return;
            end
        end
    end
    
    % otherwise, let's extract spikephases and save (with permission) the intermediate steps
    % for later
    disp(['populateUnit_spikephasesORfreqs: Unit (expt: ', unit.expt_name, ', tag: ', unit.unit_tag, ', label: ', unit.label, ', # spikes: ', num2str(unit.numspikes), ') has no ', field_name, ' in spike struct.']);    
    
    if(strcmpi(user_input, 'ask'))
        user_input = input(['Do you want to extract ', field_name, ' from the raw data? (press ''y'' to load, anything else to skip)'], 's');
    end            
    
    if(~strcmpi(user_input, 'y') && ~strcmpi(user_input, 'yes') && ~strcmpi(user_input, '1'))
        disp('Skipping...');
        unit.spikephases = [];
        return;
    end
    
    disp('Extracting spike-triggered LFP phase/freq/power from raw data... this will take a while.');
    oscillationRange = [20, 80]; % hz
    % the following line will save the spikephases/freqs to the spikes
    % struct files
    [spikephases, spikefreqs, spikepows] = extractSpikePhasesAndFreqs(curExpt, unit, curTrodeSpikes, 0, oscillationRange);
    % phases/freqs should be saved now
    
    % only add the requested fields to the unit object (though all the
    % phases/freqs have been cached in the spikes struct no matter what)
    if(strcmp(field_name, 'spikephases'))
        unit.spikephases = spikephases;       
    elseif(strcmp(field_name, 'spikefreqs'))
        unit.spikefreqs = spikefreqs;
    elseif(strcmp(field_name, 'mean_spike_phase'))
        unit.mean_spike_phase = circularMean(spikephases, 360, 1);
    elseif(strcmp(field_name, 'spikepows'))
        unit.spikepows = spikepows;
    else
        warning('Unrecognized field name!');
    end
        
    
end


