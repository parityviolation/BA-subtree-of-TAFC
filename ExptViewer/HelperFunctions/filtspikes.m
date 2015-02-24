function spikes = filtspikes(spikes,flag,spikefilter,sweepfilter,trialRelativeSweepfilter)
% function spikes = filtspikes(spikes,bOR,spikefilter) {property,value}, sweepfilter {sweep property,sweeps value})
%
% Filter the spikes struct according to one or more property/value pairs.
%
% INPUTS
%   spikes: The spikes struct
%   flag:  % this filter only includes spikes that occured within the duration of a trial filtered for with (sweep filter), Trial Duration is defined from TrialAvail to next TrialAvail
%   varargin: A property value pair used to filter the spikes struct
%   according to the value of the given property for each spike. Multiple
%   property/value pairs can be used to output the spikes corresponding to
%   the intersection (AND) or union (OR) of multiple conditions.
%
% OUTPUTS
%   spikes: The filtered spikes struct

%   Created: 3/15/10 - SRO
%   Modified: 3/30/10 - BA added bOR
%   Modified: 2/17/14 - BA added bOR

% if any(~ismember(spikes.TrialNumber,spikes.sweeps.TrialNumber)) % this
% can happen because some spikes are before or after the trials
%     %    error this shoudln't happen
%     keyboard
% end
reqLength = length(spikes.spiketimes);
bOR = 0;
if nargin < 3
    error('Not enough arguments supplied')
end


numSortFields = length(spikefilter)/2;
emptyspots = zeros(numSortFields,1);
thecell = spikefilter;
 sortfield = {};
 sortvalue = {};
 emptyspots = [];
for i = 1:numSortFields
    sortfield{i} = thecell{(i-1)*2+1};
    sortvalue{i} = thecell{2*i};
    emptyspots(i) = ~isempty(sortfield{i});
end


if exist('sweepfilter','var') | exist('trialRelativeSweepfilter','var') % these sort fields will be applied to sweeps first
    if ~exist('trialRelativeSweepfilter','var')
        trialRelativeSweepfilter = {};
    end
    if ~exist('sweepfilter','var')
        sweepfilter = {};
    end
    spikes.sweeps = filtbdata(spikes.sweeps,bOR,sweepfilter,trialRelativeSweepfilter);
    if flag==1  % this filter only includes spikes that occured within the duration of a trial filtered for with (sweep filter), Trial Duration is defined from TrialAvail to next TrialAvail
 
        TrialNumberFilter = spikes.sweeps.absolute_trial;
        sortfield{end+1} = 'TrialNumber'; % BA WATCH OUT this field is NOT absolute in .sweeps (that is why sweeps.absolute_trial is referenced, this should be fixed .. but worried about breaking older shit)
        sortvalue{end+1} = TrialNumberFilter;
        emptyspots(end+1) = ~isempty(length(sortfield));
    end
end

sortfield = sortfield(logical(emptyspots));
sortvalue = sortvalue(logical(emptyspots));
numSortFields = length(sortfield);
sortvector = logical(ones(1,reqLength));
% Make logical vector to sort spikes
for i = 1:numSortFields
    if(isa(sortvalue{i}, 'function_handle'))
        fcn_hand = sortvalue{i};
        tempvector = arrayfun(fcn_hand, spikes.(sortfield{i}));
    else
        tempvector = ismember(spikes.(sortfield{i}),sortvalue{i});     % Take trials = value
    end
    
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

% Find fields that have same length as spiketimes
fieldList = fieldnames(spikes);

% Use logical vector to extract spikestimes, trials, etc.
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

% % Filter sweeps struct on fields present in both spikes and sweeps
% temp = ismember(sortfield,fieldnames(spikes.sweeps));
% sw.fieldnames = sortfield(temp);
% sw.sortvalue = sortvalue(temp);
% if any(temp)
%     spikes.sweeps = filtsweeps(spikes.sweeps,bOR,sw);
% end
% 
spikes = UpdateTrials(spikes);

if ~isempty(spikes.spiketimes)
    if ~isequal(size(spikes.spiketimes),size(spikes.TrialNumber))  % error checking this should never happen
        keyboard
    end
end



