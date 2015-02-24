%%

close all

%%



% do rest of electrodes
analysisType =  'two variables';
analysisType =  'collapse var2';
% analysisType =  'collapse var1';
%%
% 033110
selectedUnitTags = {'T3_4','T3_21','T3_54','T3_56'};
selectedUnitTags = {'T1_1','T1_2','T1_6','T1_7','T1_17'};
selectedUnitTags = {'T4_3','T4_19', 'T4_74','T4_80',  'T4_131','T4_170', 'T4_230'}; %  too small to be good 'T4_125',
% 040910 MUA  FS RS FS
selectedUnitTags = {'T2_6','T2_7', 'T2_8','T2_13',  'T2_14','T2_17', 'T2_20', 'T2_24''T2_25','T2_27',  'T2_28'}; %  too small to be good 'T4_125',
% selectedUnitTags = {'T4_1','T4_6', 'T4_19','T4_21',  'T4_44','T4_47', 'T4_48', 'T4_49'}; %  too small to be good 'T4_125',

selectedUnitTags = {'T1_1','T1_4', 'T1_6','T1_13', 'T1_8'};

%% File selection

if 1  % enable to select files to analyze
trodeInd = 1;
fileInd = expt.sort.trode(trodeInd).fileInds(:);
tempList = expt.files.names(fileInd);
tempList  = cellfun(@getFilename, tempList,'UniformOutput',0);% get only files

prompt = {'Select files to analyze'};
selected = listdlg('ListString',tempList,'PromptString',prompt); pause(0.05)
selectedfileInd = expt.sort.trode(trodeInd).fileInds(selected);


end


%% run analysis for data with LED on and off
lasttetnum = 0;
close all;
fid = [];
for i = 1:length(selectedUnitTags)
unitTag = selectedUnitTags{i};
[tetnum unitInd] = getUnitInfo(unitTag);

% load right spikes file if necessary
if tetnum~=lasttetnum
spikes = getSpikes(expt,unitTag);
end


plotparam.legendDesc = ['no light'];
plotparam.bclearplot = 1  ; % or append
plotparam.colorPSTH = 'r';
plotparam.colorraster = 'r';
plotparam.summaryLinecolor= [1 0 0]  ; % or append
plotparam.summaryLinewidth= 0;
tempspikesL = filtspikes(spikes,0,'assigns',unitInd,'fileInd',selectedfileInd);
fid(end+1) = getUnitTuningBA(tempspikesL,unitTag,analysisType,plotparam);


% plotparam.legendDesc = ['blue light'];
% plotparam.colorPSTH = 'k';
% plotparam.colorraster = 'k';
% plotparam.bclearplot = 0 ; % or append
% plotparam.summaryLinewidth= 2  ; % or append
% plotparam.summaryLinecolor= [0 0 0]  ; % or append
% tempspikesL = filtspikes(spikes,0,'led',1,'assigns',unitInd,'fileInds',selectedTrials);
% fid(end+1) = getUnitTuningBA(tempspikesL,unitTag,analysisType,plotparam);
lasttetnum = tetnum;


end

set(fid,'Position',[2         263        1916         695]);
set(fid,'Position',[43 135 869 768]);
set(fid,'Visible','On');

%% view figures
fid = fid([1:3, 5:end])
%% save figures
RigDefaultsScript



figureFilenames = get(fid,'Tag');

if length(fid)>1
figureFilenames = cellfun(@(x) fullfile(RigDefaults.DirAnalyzed,'Figures',x),figureFilenames,'UniformOutput',0);
else
    figureFilenames = get(fid,'Tag');
    figureFilenames = {fullfile(RigDefaults.DirAnalyzed,'Figures',figureFilenames)};
end

for i = 1:length(figureFilenames)
    [junk fold] =getFilename(figureFilenames{i});
    parentfolder(fold,1);
    saveas(fid(i),sprintf('%s_%s_high',figureFilenames{i},analysisType))
end

%% print figures
set(fid,'Visible','Off');
for i = 1:length(fid)
    set(0,'CurrentFigure',fid(i))
    printOrientfig;
end

%% remove psth or raster
h = findobj(gcf,'Tag','psth')
% set(gcf,'CurrentAxes',h(1))
% axis tight
set(h,'YLIM',[0 90])

hr = findobj(gcf,'Tag','raster')
hrc = get(hr,'Children')
hrc = cellfun(@(x) findobj(x,'Type','line'),hrc,'UniformOutput',0)
cellfun(@(x) set(x,'visible','off'),hrc,'UniformOutput',0)
axis tight

%%

hr = findobj(gcf,'Tag','psth')
hrc = get(hr,'Children')
hrc = cellfun(@(x) findobj(x,'Type','line'),hrc,'UniformOutput',0)
cellfun(@(x) set(x,'visible','off'),hrc,'UniformOutput',0)
axis tight

