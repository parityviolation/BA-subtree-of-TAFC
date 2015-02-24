function sweeps = filtsweeps(sweeps,bOR,varargin)
% sweeps = filtsweeps(sweeps,bOR,varargin {property,value})
% Filter the spikes struct according to one or more property/value pairs. 
% INPUTS
%   sweeps:
%   varargin: A property value pair that is used to filter the spikes
%   struct according to the value of the given property for each spike.
%   Multiple property/value pairs can be used to output the spikes
%   corresponding to the intersection of multiple conditions.
% OUTPUTS
%   spikes:
%
%   3/14/10 - SRO
% 3/30/ - BA added bOR

% Set sort field and values from varargin
numSortFields = length(varargin)/2;
for i = 1:numSortFields
    sortfield(i) = {varargin{(i-1)*2+1}};
    sortvalue{i} = varargin{2*i};
end

if ~isempty(sweeps)
% Make logical vector to sort sweeps
for i = 1:numSortFields
    tempvector = ismember(sweeps.(sortfield{i}),sortvalue{i});     % Take trials = value
    
    if (numSortFields > 1) && (i > 1)
        if bOR % BA
            sortvector = sortvector | tempvector;
            
        else % and
            sortvector = sortvector & tempvector;
        end
    else
        sortvector = tempvector;
    end
end

% Use logical vector to extract file, trigger, trial, etc.
reqSize = size(sweeps.trials);  % will find the fields that have a value for each sweep
fieldList = fieldnames(sweeps);
for i = 1:length(fieldList)
    if isequal(size(sweeps.(fieldList{i})),reqSize);       
        sweeps.(fieldList{i}) = sweeps.(fieldList{i})(sortvector);      % Using dynamic field names\
    end
end


end

