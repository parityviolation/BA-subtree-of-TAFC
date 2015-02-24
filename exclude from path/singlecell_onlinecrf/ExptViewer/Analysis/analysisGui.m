function analysisGui(expt)

% BA version
selectedUnitTags =expt.analysis.currentAnalysis.unitTags;
% do rest of electrodes
% analysisType =  'two variables';
% analysisType =  'collapse var2';
analysisType =  'collapse var1';
%% File selection
% selectedfileInd = [1:2];
if 1  % enable to select files to analyze
 [tetnum junk] = getunitInfo(selectedUnitTags{1});
    fileInd = expt.sort.trode(tetnum).fileInds(:);
    selectedfileInd = GUI_listFilesVisualParams('exptStruct',expt,'fileInd',fileInd);
else
    selectedfileInd = [1:length(expt.files.names)]
end

lasttetnum = 0;
% close all;
fid = [];
for i = 1: length(selectedUnitTags)
    unitTag = selectedUnitTags{i};
    [tetnum unitInd] = getUnitInfo(unitTag);
    
    % load right spikes file if necessary
    if tetnum~=lasttetnum
        spikes = getSpikesStruct(expt,unitTag);
    end
    
    plotparam.legendDesc = ['no light'];
    plotparam.bclearplot = 1  ; % or append
    plotparam.colorPSTH = 'k';
    plotparam.colorraster = 'k';
    plotparam.summaryLinecolor= [0 0 0]  ; % or append
    plotparam.summaryLinewidth= 1;
 tempspikesL = filtspikes(spikes,0,'led',0,'assigns',unitInd,'fileInd',selectedfileInd);
    getUnitTuningBA(tempspikesL,unitTag,analysisType,plotparam);
    
    
    plotparam.legendDesc = ['blue light'];
    plotparam.colorPSTH = 'c';
    plotparam.colorraster = 'c';
    plotparam.bclearplot = 0 ; % or append
    plotparam.summaryLinewidth= 2  ; % or append
    plotparam.summaryLinecolor= [0, 255/255, 255/255]  ; % or append
    tempspikesL = filtspikes(spikes,0,'led',1,'assigns',unitInd,'fileInd',selectedfileInd);
    fid(end+1) = getUnitTuningBA(tempspikesL,unitTag,analysisType,plotparam);
    
    lasttetnum = tetnum;
    
    
end
fid = fid(~isnan(fid)); % remove nan fid from units that had no spikes for a condition
set(fid,'Position',[2         263        1916         695]);
set(fid,'Position',[43 135 869 768]);
set(fid,'Visible','On');

%% save figures
if ~isempty(fid)
    rigdef = RigDefs;
    
    
    fid = findobj('-regexp','Name','AnalysisBA');
    figureFilenames = get(fid,'Tag');
    
    if length(fid)>1
        figureFilenames = cellfun(@(x) fullfile(rigdef.Dir.Analyzed,'Figures',x),figureFilenames,'UniformOutput',0);
    else
        figureFilenames = get(fid,'Tag');
        figureFilenames = {fullfile(rigdef.Dir.Analyzed,'Figures',figureFilenames)};
    end
    
    for i = 1:length(figureFilenames)
        [junk fold] =getFilename(figureFilenames{i});
        parentfolder(fold,1);
        saveas(fid(i),sprintf('%s_%s',figureFilenames{i},analysisType))
    end
end