function stim = makeStimStruct(expt,fileInd)


% Get stimulus parameters
if ~isempty(fileInd)
    
    varparam = expt.stimulus(fileInd(1)).varparam(1);
    stim.type = varparam.Name;
    if isfield(expt.stimulus(fileInd(1)).params,'oriValues')
        stim.values = expt.stimulus(fileInd(1)).params.oriValues;
    else
        stim.values = varparam.Values;
    end
    
    for i = 1:length(stim.values)
        stim.code{i} = i;
    end
else
    stim.values = NaN;
    stim.code = NaN;
end