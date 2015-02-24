function [spikes stimParam nCond condVal] = collapseVarParam_Helper(spikes,stimParam,VarTOCollapse)
if VarTOCollapse==2
    tempvarparam  = stimParam.varparam ;
    spikes = spikes_collapseVarParam(spikes,stimParam.varparam,2);
    tempvarparam(2).Values = num2str(tempvarparam(2).Values);% collapsed variables must
    stimParam.varparam = tempvarparam;
    
elseif VarTOCollapse==1
    tempvarparam  = stimParam.varparam ;
    spikes = spikes_collapseVarParam(spikes,stimParam.varparam,1);
    tempvarparam(1).Values = num2str(tempvarparam(1).Values);% collapsed variables must
    stimParam.varparam = tempvarparam;
    
end

for i = 1: length(stimParam.varparam)
    if isnumeric(stimParam.varparam(i).Values)  % is ths a collapsed variable?
        nCond(i) = length(stimParam.varparam(i).Values);
    else nCond(i) = 1; % this takes care of case where one variable is collapsed and its variables are replaced with a string listing all values
    end
    condVal{i} = stimParam.varparam(i).Values ;
end

if length(nCond)==1 % case of 1 stim variable only
    nCond(2) = 1; condVal{2} = NaN;
    stimParam.varparam(2).Name = '';
end
