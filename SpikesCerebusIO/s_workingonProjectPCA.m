project onto PCA
pcaAnalysis.filenames =  fname(nfiles);
pcaAnalysis.options.alignEvent =  alignEvent;
pcaAnalysis.options.binsize =  options.binsize ;
pcaAnalysis.options.nsmooth =  options.nsmooth; 
pcaAnalysis.intv_list = int_list;
pcaAnalysis.unitPsth = unitPsth;
pcaAnalysis.nUnit = nUnit;


%% Project unit activities onto PCs
% normalize all PSTH to the peak

% SCORE: each row is a unit. each col is its contribution to a component.
% create PComp (i.e COEFF)
%
 test = SCORE'*allUnits ;% WHY does this not work !!!!!!!!!!
 
 
for iPC = 1:
    
    (SCORE nUnit  x  nPC)T  UNIT nUnit x nTime = 
    
wjps te
