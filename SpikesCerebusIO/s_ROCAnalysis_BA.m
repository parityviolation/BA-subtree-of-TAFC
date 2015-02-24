%% ********************* loadSpikeStruct and analyze
r = brigdefs;
if 0
    p  = fullfile(r.Dir.spikesStruct, 'SertxChR2_179');
    % ss = {'SertxChR2_179_D140223F1_spikes'};
    d = dirc(fullfile(p,'*.mat'));
    ss = d(:,1);
    ss = ss(2:end,1);
    bplotEachSession = 0;
    
    
    nSessions = length(ss);
%     nSessions = 8
    
%     clear spikeSession
    % % Load sessions
    hbar = waitbar(0,'Loading SpikeStructs');
    for ispikeStruct = 1:  nSessions%8
        load(fullfile(p,ss{ispikeStruct}))
        %add average WAveforms
        EUPlus = spikes.Analysis.EUPlusLabel;
        for iEU = 1:size(EUPlus,1)
            [spikes]= addUnits_spikes(spikes, EUPlus(iEU,:) );
        end
        EU = cell2mat(EUPlus(:,1:2));
        spikesNoW = rmfield(spikes,{'waveforms','assigns','unwrapped_times'}); % saves time in filtering
        if isfield(spikes.sweeps,'video')
            spikesNoW.sweeps = rmfield(spikes.sweeps,{'video'}); % saves time in filtering
        end
         if isfield(spikes.sweeps,'PokeTimes')
            spikesNoW.sweeps = rmfield(spikes.sweeps,{'PokeTimes'}); % saves time in filtering
        end
        hbar = waitbar(ispikeStruct/nSessions,hbar,[num2str(ispikeStruct) ' of ' str2num(nSessions) ' Session ' ss{ispikeStruct}] );
        
        spikeSession(ispikeStruct) = spikesNoW;
        
    end
    delete(hbar)
end
%% Define ROCs

nstepWOI = 1;
stepsizeWOI = 0; % repeat the ROC this many times each time moving the window over by stepsizeWOI

clear condset;
ics = 1;
condset(ics).WOI  = [.300 0.6]*1000;
condset(ics).alignEvent = 'tone2Time'; %'firstSidePokeTime';
condset(ics).cond(1).sDesc = 'ChoiceandLeft';
condset(ics).sDesc = [condset(ics).cond(1).sDesc ' [' num2str(condset(ics).WOI,' %d') ']ms ' condset(ics).alignEvent ];

condset(ics).cond(1).sweepsf = {'ChoiceCorrect',1,'ChoiceLeft',1}
condset(ics).cond(1).alignEvent = condset(ics).alignEvent;
condset(ics).cond(2).sDesc = 'Error';
condset(ics).cond(2).sweepsf = {'ChoiceCorrect',0,'ChoiceLeft',1}
condset(ics).cond(2).alignEvent = condset(ics).alignEvent ;

ics = 2;
condset(ics).WOI  =  [.300 0.6]*1000;
condset(ics).alignEvent = 'tone2Time'; % 'firstSidePokeTime';
condset(ics).cond(1).sDesc = 'ChoiceandRight';
condset(ics).sDesc = [condset(ics).cond(1).sDesc ' [' num2str(condset(ics).WOI,' %d') ']ms ' condset(ics).alignEvent ];

condset(ics).cond(1).sweepsf = {'ChoiceCorrect',1,'ChoiceLeft',0}
condset(ics).cond(1).alignEvent = condset(ics).alignEvent;
condset(ics).cond(2).sDesc = 'ShortSide';
condset(ics).cond(2).sweepsf = {'ChoiceCorrect',0,'ChoiceLeft',0}
condset(ics).cond(2).alignEvent = condset(ics).alignEvent ;

%% get roc for all cells across sessions
clear roc
figname = []
for ics = 1:length(condset)
    for istep = 1:nstepWOI
        roc(ics,istep).all_roc = {};
        roc(ics,istep).all_Area = [];
        roc(ics,istep).all_H = []; % signifigance
        roc(ics,istep).electrode = []; % signifigance
        roc(ics,istep).all_datenum = []; % signifigance
    end
end

%%
 hbar = waitbar(0);
for ispikeStruct = 1:nSessions%8
    spikes = spikeSession(ispikeStruct) ;
    if isfield(spikes.sweeps,'video')
        spikes.sweeps = rmfield(spikes.sweeps,{'video'}); % saves time in filtering
    end
    EUPlus = spikes.Analysis.EUPlusLabel;
    EU = cell2mat(EUPlus(:,1:2));
    hbar = waitbar(ispikeStruct/nSessions,hbar,['ROCs ' spikes.sweeps.FileName]);
    
    % add relative spike times
    
    for ics =  1:length(condset)
 
        
        for istepWOI = 1:nstepWOI
                   clear options cond;
            cond(1) = condset(ics).cond(1);
            cond(2) = condset(ics).cond(2);
            WOI  = condset(ics).WOI+(istepWOI-1)*stepsizeWOI;
                        
            clear thisSession_roc thisSession_Area thisSession_H thisSession_Electrode thisSession_datenum
            %%
            
            for iEU =1: size(EU,1) %13
                Electrode = EU(iEU,1);
                UnitID =  EU(iEU,2);
                % ADD grouping by interval including all intervals at least X long)
                % s_unitregression_inprog
                %% For ROC
                ElectUnit = [Electrode UnitID];
                cond(1).spikesf = {'Electrode',ElectUnit(1),'Unit',ElectUnit(2)};
                cond(2).spikesf = {'Electrode',ElectUnit(1),'Unit',ElectUnit(2)};
                
                [rc,Area,H] = unitROC(spikes,WOI,cond);
                
                thisSession_roc{iEU} = rc;
                thisSession_Area(iEU) = Area;
                thisSession_H(iEU)= H;
                thisSession_Electrode(iEU) = Electrode;
                thisSession_datenum(iEU) =datenum( spikes.sweeps.Date,'yymmdd');
            end
            
            if bplotEachSession
                figure('name',[ ss{ispikeStruct} ' '  roc(ics).sDesc])
                for iUnit = 1:size(all_roc,2)%[6 10 13]
                    subplot(1,2,1)
                    hline = line(thisSession_roc{iUnit}(1,:),thisSession_roc{iUnit}(2,:),'marker','.','linestyle','-');
                    if  thisSession_H(iUnit)
                        setColor(hline,'r');
                    else setColor(hline,'k'); end
                end
                line([0,1],[0,1],'color','k');
                axis square
                
                subplot(1,2,2)
                [a x] = hist(thisSession_Area);
                hbar = findobj(gca,'Type','patch');
                hbar = bar(x,a); hold on
                set(hbar(1),'FaceColor',[1 1 1]*.5,'EdgeColor','k');
                [a x] = hist(thisSession_Area(thisSession_H==1),x);
                hbar(2)  = bar(x,a); hold on
                
                set(hbar(2),'FaceColor','r','EdgeColor','k');
            end
            roc(ics,istepWOI).all_roc = { roc(ics,istepWOI).all_roc{:} thisSession_roc{:}};
            roc(ics,istepWOI).all_Area = [ roc(ics,istepWOI).all_Area thisSession_Area];
            roc(ics,istepWOI).all_H = [ roc(ics,istepWOI).all_H thisSession_H];
            roc(ics,istepWOI).electrode = [ roc(ics,istepWOI).electrode thisSession_Electrode];
            roc(ics,istepWOI).all_datenum = [ roc(ics,istepWOI).all_datenum thisSession_datenum];
            roc(ics,istepWOI).condset = condset(ics);
        end
    end
    
end
delete(hbar)

ncondset = length(condset);
figname = condset(1).alignEvent ;
for ics = 1:ncondset,    figname = [figname '_' condset(ics).cond(1).sDesc];end

sAnimal = spikes.sweeps.Animal;
strWOI = [' [' num2str(condset(1).WOI ,' %d') ']'];
strWOI = strrep(strWOI,'-','n')

savefile = [figname '_WOI' strWOI '_' num2str(nstepWOI) '_steps_'  num2str(stepsizeWOI) 'ms'] ;


savepath = fullfile(r.Dir.EphysFigs,sAnimal,'ROC');
parentfolder(savepath,1);
if bsave
    save(fullfile(savepath,savefile),'roc','ss','stepsizeWOI','nstepWOI','condset','ncondset')
end
%% plot and save

nc = 2;
nr = 1+ncondset;

mycolor = [1 0 0;
           0 0 1];
       
nstepWOI = size(roc,2);
% bsave = 0;
figurewidth = 592;
figureoffset = linspace(0,1800-figurewidth,nstepWOI);

for istepWOI = 1:nstepWOI
    sWOI{1} = [' [' num2str((condset(1).WOI+(istepWOI-1)* stepsizeWOI)/1000  ,' %1.1f') ']'];
    sWOI{2} = [' [' num2str((condset(2).WOI+(istepWOI-1)* stepsizeWOI)/1000  ,' %1.1f') ']'];
    sAnn = [figname  'WOI' cell2mat(sWOI)];
    [    figureoffset(istepWOI)   figurewidth   592   854]
    h.fig = figure('name',sAnn,'Position',[    figureoffset(istepWOI)  140    figurewidth   854]);
    for ics = 1:length(condset)
        
        Nsignificant(ics,istepWOI) = sum(roc(ics).all_H);
        Nsignificant_positive(ics,istepWOI) = sum(roc(ics).all_Area(logical(roc(ics).all_H))>0);
        Npositive(ics,istepWOI) = sum(roc(ics).all_Area>0);
        
        all_roc = roc(ics,istepWOI).all_roc;
        all_H = logical(roc(ics,istepWOI).all_H);
        roc(ics,istepWOI).all_H = logical(roc(ics,istepWOI).all_H);
        all_Area = roc(ics,istepWOI).all_Area;
        thisroc = roc(ics,istepWOI);
        
        subplot(nr,nc,1+ncondset *(ics-1))
        for iUnit = 1:size(all_roc,2)%[6 10 13]
            hline = line(all_roc{iUnit}(1,:),all_roc{iUnit}(2,:),'marker','.','linestyle','-');
            if  all_H(iUnit)
                setColor(hline,mycolor(ics,:));
            else setColor(hline,'k'); end
        end
        line([0,1],[0,1],'color','k');
        axis square
        
        subplot(nr,nc,2+ncondset *(ics-1))
        [a x] = hist(all_Area);
        hbar = findobj(gca,'Type','patch');
        hbar = bar(x,a); hold on
        set(hbar(1),'FaceColor',[1 1 1]*.5,'EdgeColor','k');
        [a x] = hist(all_Area(all_H==1),x);
        hbar(2)  = bar(x,a); hold on
        
        set(hbar(2),'FaceColor',mycolor(ics,:),'EdgeColor','k');
        
        title([condset(ics).cond(1).sDesc sWOI{ics}  ' n =' num2str(sum(all_H)) '/' num2str(length(all_H)) ])
    end
    roc1 = roc(1,istepWOI); roc2 = roc(2,istepWOI);
    
    subplot(nr,nc,nr*nc-1)
    plotROCvsROC(roc1,roc2)
    
    
    subplot(nr,nc,nr*nc)
    % ADD distribution across days
    %Distribution Across Electrodes
    e = unique(roc(ics,istepWOI).electrode);
    nspikes = [];nroc1 = []; nroc2 = []; nroc12 = [];
    for ie = e
        nspikes(end+1) = sum(roc(ics,istepWOI).electrode==ie);
        nroc1(end+1)  = sum(roc(ics,istepWOI).electrode==ie&roc1.all_H);
        nroc2(end+1)  = sum(roc(ics,istepWOI).electrode==ie&roc2.all_H);
        nroc12(end+1)  = sum(roc(ics,istepWOI).electrode==ie&roc2.all_H&roc1.all_H);
    end
    nspikesBundle = [];nroc1Bundle = []; nroc2Bundle = []; nroc12Bundle = [];
    for ib = 1:4
        thisBundle = [(32+(ib-1)*8):(40+(ib-1)*8)];
        nspikesBundle(end+1) = sum(ismember(roc(ics,istepWOI).electrode,thisBundle))/8;
        nroc1Bundle(end+1)  = sum(ismember(roc(ics,istepWOI).electrode,thisBundle)&roc1.all_H)/8;
        nroc2Bundle(end+1)  = sum(ismember(roc(ics,istepWOI).electrode,thisBundle)&roc2.all_H)/8;
        nroc12Bundle(end+1)  = sum(ismember(roc(ics,istepWOI).electrode,thisBundle)&roc2.all_H&roc1.all_H)/8;
        eBundle(ib) = mean(thisBundle );
        
    end
    
    % % ROC by electrode
    plot(e,nroc1./nspikes,'.-r');hold on;
    plot(e,nroc2./nspikes,'.-b');hold on;
    plot(e,nroc12./nspikes,'.-g');hold on;
    
    plot((eBundle),nroc1Bundle./nspikesBundle,'.-r','Linewidth',2,'markersize',15);hold on;
    plot(eBundle,nroc2Bundle./nspikesBundle,'.-b','Linewidth',2,'markersize',15);hold on;
    plot(eBundle,nroc12Bundle./nspikesBundle,'.-g','Linewidth',2,'markersize',15);hold on;
    box off
    axis tight
    ax2 = axes('Position',get(gca,'Position'),...
        'XAxisLocation','top',...WOI
        'YAxisLocation','right',...
        'Color','none',...
        'XColor',get(gcf,'color'),'YColor','k','Xtick',[],'Xticklabel',[]);
    ylabel('num units')
    xlabel('electrode')
    linkaxes([gca ax2],'x');
    hold on
    plot(e,nspikes,'.-k','Parent',ax2);
    plot(eBundle,nspikesBundle,'.-k','Parent',ax2,'Linewidth',2,'markersize',15);
    ylim([0 max(nspikes)])
    xlabel('electrode')
    
    
    plotAnn([sAnn ' ' num2str(nSessions) ' Sess ' sAnimal])
    plotAnn(condset(1).alignEvent,1)
    
    if bsave   
            savefile = strrep(sAnn,'-','n');
        export_fig(h.fig,fullfile(savepath,savefile),'-pdf')
        %     plot2svg(fullfile(savepath,[savefile,'.svg']),h.fig)
%            saveas(h.fig,fullfile(savepath,savefile),'fig')
    end
end


figure;
% sum

%%  convert to matrix
 
fd = fieldnames(roc)
fd = fd(~ismember(fd,{'all_roc','condset'}));
ncell =  length(roc(1,1).all_Area)
ncond  = 2;
nstep = size(roc,2);

% predefine
for ifd = 1:length(fd)
    fld = fd{ifd}
    eval(['all_' fld ' =  nan([' num2str([ncond nstep ncell]) ']);'])
    for icond = 1:ncond
        for istep = 1:nstep
            eval(['all_' fld '(' num2str(icond) ',' num2str(istep) ',:) = roc(' num2str(icond) ',' num2str(istep) ').' fld ';'])
        end
    end
end



