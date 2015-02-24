
function fid = getUnitTuningBA(spikes,unitTag,analysisType,plotparam,stimParam)
% function fid = getUnitTuningBA(spikes,unitTag,analysisType,plotparam,stimParam)
% for now assume that only 1 stimulus kind is contained in trials passed
% in
% INPUT
%  spikes - should be already filtered for desired units and trials
RigDef = RigDefs;
if ~isempty(spikes.spiketimes) % check that spikes exist 
    
    if ~isfield(plotparam,'colorPSTH')
        plotparam.colorPSTH = 'b';
        plotparam.colorraster = 'k';
        plotparam.summaryLinecolor= [1 1 1]  ; % or append
        plotparam.summaryLinewidth= 1  ; % or append
        
    end
    
    % get Vstim parameters if it isn't supplied
    % [tetIndex] = getunitInfo(unitTag);
    if ~exist('stimParam','var')
        load( fullfile(RigDef.Dir.Expt,getFilename(spikes.info.exptfile)),'expt')
        
        refFileInd = spikes.sweeps.fileInd(1);
        stimParam.varparam  = expt.stimulus(refFileInd).varparam;
        stimParam.sparam  = expt.stimulus(refFileInd).params;
        % check that stim condition of all files is the same
        for i = unique(spikes.sweeps.fileInd)
            if ~isempty(comp_struct(stimParam.varparam , expt.stimulus(i).varparam,[],[],[],[],0))
                error('Files cannot be analyzed together VarParams do not match')
            end
            if ~isempty(comp_struct(stimParam.sparam , expt.stimulus(i).params,[],[],[],[],0))
                warning('Files have different Sparam properties');
            end
        end
    end
    
    
    
    switch analysisType
        
        case 'collapse var2'
%             tempvarparam  = stimParam.varparam ;                        
%             spikes = spikes_collapseVarParam(spikes,stimParam.varparam,2);          
%             tempvarparam(2).Values = num2str(tempvarparam(2).Values);% collapsed variables must
%              stimParam.varparam = tempvarparam;
            [spikes stimParam] = collapseVarParam_Helper(spikes,stimParam,2);
        case 'collapse var1'
%             tempvarparam  = stimParam.varparam ;
%             tempvarparam(1).Values = num2str(tempvarparam(1).Values);% collapsed variables must
%             stimParam.varparam = tempvarparam;
                        [spikes stimParam] = collapseVarParam_Helper(spikes,stimParam,1);

        case 'two variables' % plot summary for 2 varying parameters
            % look up fileindex of first  file to getall vstim params
            % get stim params
    end
    fid  = getUnitTuning2var(spikes,unitTag,stimParam,plotparam);
else
    fid = NaN;
end