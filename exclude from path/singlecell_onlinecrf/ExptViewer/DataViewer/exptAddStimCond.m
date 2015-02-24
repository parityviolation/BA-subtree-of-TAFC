function expt = exptAddStimCond(expt)
%
%
%   Created: 4/6/10 - SRO
%   Modified: 4/19/10 - BA added TDT compatibility made singles

RigDef = RigDefs;

exptname = expt.name;
startInd = 1;
for i = 1:length(expt.files.names)
    triggers = single(expt.files.triggers(i));
    
    if isTDTexpt(expt)
        fName = fullfile(RigDef.Dir.Data,expt.files.names{i});
        [junk swcond] = loadTDThelper_getStimCond(fName ,'Vcod');
   
    else
        
        files = dir([RigDef.Dir.Data getfileheaderhelper(expt.files.names{i}) '*_TrigCond.mat']);
        if ~isempty(files)  % Determine whether any Trig condition files exist
            
            fName = fullfile(RigDef.Dir.Data,seperateFileExtension(getFilename(expt.files.names{i})));
            [junk swcond] = getStimCond({fName},1);
   
        elseif isfield(expt.sweeps,'trial')
            expt.sweeps.stimcond = nan(size(expt.sweeps.trial),'single');
            sprintf('\t\t **************************************************');
            sprintf('\t\t No Stimulus condition data exists .stimcond is NAN');
            sprintf('\t\t **************************************************');
            i = length(expt.files.names)+1; % break out of for loop
        end

    end
    
    if size(swcond,2) > triggers
        % Remove nans, if they exists (this occurs when DaqController is
        % stopped before completing specified triggers)
        swcond(triggers+find(isnan(swcond(triggers+1:end)))) = [];       
    end
%     triggers with no stimulus information check if there are NaNs <triggers
    if any(isnan(swcond)),display(sprintf('\t MISSING StimCond %s: Triggers %s', fName, num2str(find(isnan(swcond))))); end
    expt.sweeps.stimcond(startInd:startInd+triggers-1) = single(swcond);
    startInd = startInd + triggers;
end


