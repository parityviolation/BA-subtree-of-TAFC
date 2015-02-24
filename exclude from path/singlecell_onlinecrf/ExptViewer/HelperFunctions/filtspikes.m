function spikes = filtspikes(spikes,bOR,varargin)
% function spikes = filtspikes(spikes,bOR,varargin)
%
% Filter the spikes struct according to one or more property/value pairs.
% INPUTS
%   spikes: The spikes struct. Data will be extracted from the following
%   fields if they exist in spikes:
%   {'waveforms','spiketimes','trials','assigns','stimulus','hm4d'};
%   varargin: A property value pair that is used to filter the spikes
%   struct according to the value of the given property for each spike.
%   Multiple property/value pairs can be used to output the spikes
%   corresponding to the intersection of multiple conditions.
% OUTPUTS
%   spikes: The spikes struct.
%
%   Created: 3/15/10 - SRO
%   Modified: 7/1/10 - BA added array support (doesn't work!!)

% for k = 1:length(spikes) % each 
    if any(~ismember(spikes.trials,spikes.sweeps.trials))
        %    error this shoudln't happen
        keyboard
    end
    
    if nargin < 4
        error('Not enough arguments supplied')
    end
    numSortFields = length(varargin)/2;
    for i = 1:numSortFields
        sortfield(i) = {varargin{(i-1)*2+1}};
        sortvalue{i} = varargin{2*i};
    end
    
    % Make logical vector to sort spikes
    for i = 1:numSortFields
        tempvector = ismember(spikes.(sortfield{i}),sortvalue{i});     % Take trials = value
        % Combine multiple conditions
        if (numSortFields > 1) && (i > 1)
            if bOR  % OR
                sortvector = sortvector | tempvector;
            else    % AND
                sortvector = sortvector & tempvector;
            end
        else
            sortvector = tempvector;
        end
    end
    
    % Use logical vector to extract spikestimes, trials, etc.
    reqLength = length(spikes.spiketimes);  % will find the fields that have a value for each spike
    fieldList = fieldnames(spikes);
    
    % and create them
    for i = 1:length(fieldList)
        if ismember(reqLength,size(spikes.(fieldList{i})));
            switch fieldList{i}
                case 'waveforms'
                    spikes.(fieldList{i}) = spikes.(fieldList{i})(sortvector,:,:);
                otherwise
                    spikes.(fieldList{i}) = spikes.(fieldList{i})(sortvector);      % Using dynamic field names
            end
        end
    end
    
    
    
    % If sorting is done on stimcond, led, or hm4d then sort sweeps struct and
    % update trials in spikes
    for i = 1:length(sortfield)
        if ismember(sortfield{i},fieldnames(spikes.sweeps));
            spikes.sweeps = filtsweeps(spikes.sweeps,bOR,sortfield{i},sortvalue{i});
        end
    end
    
    % if any(~ismember(spikes.trials,spikes.sweeps.trials))
    %     keyboard
    % end
    spikes = UpdateTrials(spikes);
    
    if ~isempty(spikes.spiketimes)
        if ~isequal(size(spikes.spiketimes),size(spikes.trialsInFilter))  % error checking this should never happen
            keyboard
        end
    end
    if isempty(spikes.spiketimes)
        warning('No spikes meeting these criteria were found')
    end
    
    
% end



