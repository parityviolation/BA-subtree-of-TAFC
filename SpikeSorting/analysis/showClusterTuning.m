function showClusterTuning(bChooseFile)

if ~exist('bChooseFile','var')||isempty(bChooseFile), bChooseFile = 0; end
RigDefaults = RigDefs;
bMergeTool = 0;

% find handle of Split Tool
set(0,'Showhiddenhandles','on')

hSMT = findobj('-regexp','Name','Split Tool');
if isempty(hSMT) % look for Merge Tool
    hSMT = findobj('-regexp','Name','Merge Tool');
    bMergeTool = 1;
end

figdata = get(hSMT,'UserData');
if ~ bMergeTool% if Split Tool then  using the tempassigns from splittool
    figdata.spikes.assigns = figdata.tempassigns;
end

spikes = figdata.spikes;
selected_assigns = figdata.selected;
if isempty(selected_assigns), selected_assigns =  unique(spikes.assigns); selected_assigns  = selected_assigns(selected_assigns>0); end

% find files with orientation varying
% assume the expt struc in the workspace is the one we are working on

set(0,'Showhiddenhandles','on')
exv_handles = guidata(findobj('Name','ExptViewer'));
expt = exv_handles.expt;
assignin('base','expt',expt);
% hEV = findobj('-regexp','Name','ExptViewer');

set(0,'Showhiddenhandles','off')


% need to add ablity to change the file used for tuning
if ~isfield(expt.analysis,'currentAnalysis'), expt.analysis.currentAnalysis = []; end
if ~isfield(expt.analysis.currentAnalysis,'plotTuning_fileInd') || bChooseFile
    fileInd = expt.sort.trode(spikes.info.trodeInd).fileInds;
    selectedfileInd = GUI_listFilesVisualParams('exptStruct',expt,'fileInd',fileInd);
    expt.analysis.currentAnalysis.plotTuning_fileInd = selectedfileInd;
    save( fullfile(RigDefaults.Dir.Expt,getFilename(expt.info.exptfile)),'expt'); % BA this seems like it should be changed to save at rig specific location
    assignin('base','expt',expt)  
    % put it back in the ExptViewer for next time
    exv_handles.expt = expt; guidata(exv_handles.hExptViewer,exv_handles);
else
    selectedfileInd = expt.analysis.currentAnalysis.plotTuning_fileInd;
end
% save as defaults


% Update the fields added to spikes struct (outliers may have removed
% spikes)
if ~isequal(size(spikes.assigns),size(spikes.stimcond))
    spikes = spikesAddSweeps(spikes,expt,spikes.info.trodeInd);
    spikes = spikesAddConds(spikes);
end

% fix LED to be binary
spikes.led = spikes.led>0.95; spikes.sweeps.led = spikes.sweeps.led>0.95; % make led binary

%%% USER PREFS
b.pause = 0;
b.save = 0;
b.print = 0;
b.close = 0;


% defline led times
expt = led_def(expt);

% define analysis paramters
expt = analysis_def(expt);

% determine analysis type based on first selected file
varparamName = expt.stimulus(selectedfileInd(1)).varparam(1).Name ;
try
unitList = selected_assigns;
for iclus = 1:length(unitList)
    unitTag = sprintf('T%d_%d',spikes.info.trodeInd,unitList(iclus));
    
    switch lower(varparamName)
        case 'orientation'
            
            h{iclus} = orientationFig(expt,unitTag,selectedfileInd,b,spikes);
            % %                 fr{i} = allPolarPlots(expt,unitList{i},fileInd,h.chkVal);
        case 'contrast'
            h{iclus} = contrastFig(expt,unitTag,selectedfileInd,b,spikes);
    end
    
%     % color the waveform acording to the color in the splitmerge tool
%     set(h(iclus).avgwv.l, 'color', spikes.info.kmeans.colors(unitList(iclus),:));
end
end

if length(unitList)>1
summaryUnitFigure(expt,unitList,h)
end

    



