function [hAx fid]= plotclusterTuning(expt,spikes,fileInd,bLed)
% function [hAx fid]= plotclusterTuning(expt,spikes,fileInd)
% TO DO catch case of varparam in different files are different
varparamTemplate = expt.stimulus(fileInd(1)).varparam;
nVar = length(varparamTemplate);
for i = 2:length(fileInd)
    if ~isequal(expt.stimulus(fileInd(i)).varparam,varparamTemplate)
        error('varparam in selectedfiles do not match')
    end
end

%% Contrast
% user specific would be here
% sStimVar = 'Contrast';
%% ORIENTATION
sStimVar = 'Orientation'; 


indVar = find(ismember({varparamTemplate.Name},sStimVar));
if  isempty(indVar)
    s = sprintf('None of the files selected for analysis vary %s',sStimVar);
    error(s);
end

if indVar==1
    if nVar>1% collapse var2
        spikes = spikes_collapseVarParam(spikes,varparamTemplate,2);
    end
    nCond = length(unique(varparamTemplate(1).Values));
elseif indVar==2 && nVar>1 % collapse var1
    spikes =  spikes_collapseVarParam(spikes,varparamTemplate,1);
    nCond = length(unique(varparamTemplate(2).Values));
end

sName = '';
if exist('bLed','var') % use bLed as a sort criteria and note it in the figure name
    sName = sprintf('%s LED %d',sStimVar,bLed);
end

fid = figure;
fid(2) = figure;
fid(3) = figure;
set(fid,'Visible','off')
set(fid(1),'Name',sprintf('K Tuning %s',sName));
set(fid(2),'Name',sprintf('Raster: K Tuning %s',sName));
set(fid(3),'Name',sprintf('PSTH: K Tuning %s',sName));
set(fid,'Tag','K Tuning');
selectassigns = unique(spikes.assigns);
nclus = length(selectassigns);

ncol = spikes.params.display.max_cols;
nrow = ceil(nclus/ncol);
binsizePSTH = 50; %ms

hAxes = [];
hAxesPsth = [];

sparam =  expt.stimulus(fileInd(1)).params;
for i = 1:nclus
    clear cspikes;
    for iVar = 1:nCond
        icond = iVar ;
        if exist('bLed','var') % use bLed as a sort criteria
            cspikes(iVar,1) = filtspikes(spikes,0,'assigns',selectassigns(i),'stimcond',icond,'led',bLed);
        else
            cspikes(iVar,1) = filtspikes(spikes,0,'assigns',selectassigns(i),'stimcond',icond);
        end
    end
    
    set(0,'CurrentFigure',fid(3));
    [hAxesPsth hPsth  junk junk] = psthBA(cspikes,[],hAxesPsth,1,1);
    set(hPsth(~isnan(hPsth)),'Color',spikes.info.kmeans.colors(selectassigns(i),:))
    
    set(0,'CurrentFigure',fid(2));
    [hAxes ph] = rasterBA(cspikes,hAxes,1,0);
    set(ph(~isnan(ph)),'Color',spikes.info.kmeans.colors(selectassigns(i),:))
    
    set(0,'CurrentFigure',fid(1));
    [nPSTH edgesPSTH] = psthBA(cspikes,binsizePSTH,[],[],0);
    
    analyzewindow = [ 0 min(sparam.StimDuration, size(nPSTH,3)*binsizePSTH*1e-3)];
    analyzewindowbins = [max(1,analyzewindow(1)/(binsizePSTH*1e-3)) analyzewindow(2)/(binsizePSTH*1e-3)];
    ratePSTH = mean(nPSTH(:, :,analyzewindowbins(1):analyzewindowbins(2)),3);
    switch lower(sStimVar)
        case 'orientation'
            theta = deg2rad(varparamTemplate(indVar).Values);
                hAx(i) = axes();
            [hl  hAx(i)] = plotOriTuning(theta,ratePSTH);
            if 1 % polar plot needs special formating ttreatement
                set(0,'Showhiddenhandles','on');
                    htitle = get(hAx(i),'Title');
                extrastuff = setdiff(get(hAx(i),'children'),[hl htitle]);
                set(extrastuff,'Visible','off');
                %                set(hpAxes,'Position',get(hpAxes,'Position').*[-3*(i==1)-1 -1.5 1.5 1.5]) % make ploar axes bigger and shift over
            end
            
        case 'contrast'
            xval = varparamTemplate(indVar).Values;
            hAx(i) = axes('Parent',fid(1),'color','none');
                htitle = get(hAx(i),'Title');
            hl = line(xval,ratePSTH,'marker','o','linestyle','-','Parent',hAx(i));
    end
    set(hl,'color',spikes.info.kmeans.colors(selectassigns(i),:),'linewidth',2); % NOTE color are wrong
    set(htitle,'String',sprintf(' # %d',selectassigns(i)),'color',spikes.info.kmeans.colors(selectassigns(i),:));
    
    


end
% setaxesOnaxesmatrix(hAx(i),nrow,ncol,i,[],fid(1));
    setaxesOnaxesmatrix(hAx,nrow,ncol,[1:nclus],[],fid(1));

set([hAxesPsth hAxes],'Color',[0 0 0])
set(fid([2 3]),'Color',[0 0 0])
set(hAxes,'XColor',[1 1 1])
set(hAxes,'YColor',[1 1 1])

set(fid,'Visible','on')

%     TO DO add raster (only of max respond condition)