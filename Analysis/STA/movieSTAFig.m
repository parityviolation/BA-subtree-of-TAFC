function h = movieSTAFig(expt,unitTag,fileInd,b)
r = RigDefs();

STAparams.tbin = 10*1e-3;
STAparams.WOI = [400 100]*1e-3;
cond = [] ;% this is currently not used in
STAresult = computeSTA(expt,unitTag,fileInd,STAparams,cond);

if STAresult.bfullfield
    h.tbin = STAresult.STAparams.tbin;
    h.WOI = STAresult.STAparams.WOI;
   [h.dx h.dy h.dWOI] =size(STAresult.movie{1}); 
   
    h.dl_x = [1:h.dWOI]*h.tbin*1e3-h.WOI(1)*1e3;
    h.fig = figure;
    sFigName = sprintf('%s STA Browser',STAresult.unitTag);
    m = squeeze(STAresult.movie{1});
    plot(h.dl_x ,m);
    axis tight
    defaultAxes(gca)
    setTitle(gca,['nspks: ' num2str(STAresult.nspikes)]) ;
else   
    h = STABrowser(STAresult);
end


%% annotate
[trodeNum unitInd] = readUnitTag(unitTag); % Get tetrode number and unit index from unit tag

if ~exist('spikes','var')
    % Get spikes from trode number and unit index
    spikes = loadvar(fullfile(r.Dir.Spikes,expt.sort.trode(trodeNum).spikesfile));
    % Get unit label
    try    h.label = getUnitLabel(expt,trodeNum,unitInd); catch h.label = 'none'; end
else
    h.label = 'no label';
end


% --- Make info table
genotype = expt.info.mouse.genotype;
try
    if isfield(expt.info.transgene,'construct1')
        transgene = expt.info.transgene.construct1;
    elseif isfield(expt.info.transgene,'construct')
        transgene = expt.info.transgene.construct;
    end
catch
    transgene = '';
end

try temp = {expt.sort.trode(trodeNum).unit.assign}; catch temp = [] ;end % newly created trode after expt was made in MakeExpt doesn't have .unit field
temp = cell2mat(temp);
k = find(temp == unitInd);
unitLabel = h.label;
try depth = getUnitDepth(expt,unitTag,maxch); catch depth = NaN; end  % BA using unitTag here which is the SORT trode is not compatible with having different sorts than probes
exptInfo = strvcat(expt.name, [genotype ',' ' ' transgene], unitLabel,...
    num2str(depth), unitTag);
h.textbox = annotation(h.fig,'textbox',[0.62 0.83 0.38 0.15],'String',exptInfo,...
    'EdgeColor','none','HorizontalAlignment','right','Interpreter',...
    'none','Color',[0.2 0.2 0.2],'FontSize',9,'FitBoxToText','on');
%%
sname = [r.Dir.Fig expt.name '_' unitTag '_' STAresult.type '_STA'];
if b.save
    disp(['Saving' ' ' sname])
    saveas(h.fig,sname,'pdf')
    saveas(h.fig,sname,'fig')
    saveas(h.fig,sname,'epsc')
    sname = [sname '.epsc'];
    %         export_fig sname
end
%%
if b.print
    print('-dwinc',h.fig)
    disp(['Printing' ' ' sname])
end
