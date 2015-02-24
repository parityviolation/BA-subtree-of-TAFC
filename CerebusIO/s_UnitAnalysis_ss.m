%% ********************* loadSpikeStruct and analyze
r = brigdefs;
p  = fullfile(r.Dir.spikeStruct, 'SertxChR2_179');
% ss = {'SertxChR2_179_D140223F1_spikes'};
d = dirc(fullfile(p,'*.mat'));
ss = d(:,1);
ss = ss(2:end,1);
bplotEachSession = 0;
nSessions = length(ss);

clear condset;
ics = 1;
condset(ics).WOI  = [-0.5 0.0]*1000;
condset(ics).alignEvent = 'TrialInit'; %'firstSidePokeTime';
condset(ics).sDesc = ['Choice' ' [' num2str(condset(ics).WOI,' %d') ']ms ' condset(ics).alignEvent ];

condset(ics).cond(1).sDesc = 'Correct';
condset(ics).sDesc = [condset(ics).cond(1).sDesc ' [' num2str(condset(ics).WOI,' %d') ']ms ' condset(ics).alignEvent ];
condset(ics).cond(1).sweepsf = {'ChoiceCorrect',1}; %,'Interval',@(x) x < 0.5
condset(ics).cond(1).alignEvent = condset(ics).alignEvent;
condset(ics).cond(2).sDesc = 'Error';
condset(ics).cond(2).sweepsf = {'ChoiceCorrect',0}; %,'Interval',@(x) x < 0.5
condset(ics).cond(2).alignEvent = condset(ics).alignEvent;

ics = 2;
condset(ics).WOI  = [-0.5 0.0]*1000;
condset(ics).alignEvent = 'TrialInit'; % 'firstSidePokeTime';

condset(ics).cond(1).sDesc = 'Premature';
condset(ics).sDesc = [condset(ics).cond(1).sDesc ' [' num2str(condset(ics).WOI,' %d') ']ms ' condset(ics).alignEvent ];

condset(ics).cond(1).sweepsf = {'Premature',1}; %,'Interval',@(x) x < 0.5
condset(ics).cond(1).alignEvent = condset(ics).alignEvent;
condset(ics).cond(2).sDesc = 'NotPremature';
condset(ics).cond(2).sweepsf = {'Premature',0}; %,'Interval',@(x) x < 0.5
condset(ics).cond(2).alignEvent = condset(ics).alignEvent;

%% get roc for all cells across sessions
clear roc
    figname = []
for ics = 1:length(condset)
    roc(ics).all_roc = {};
    roc(ics).all_Area = [];
    roc(ics).all_H = []; % signifigance
    roc(ics).electrode = []; % signifigance
    roc(ics).datenum = []; % signifigance
    
    figname = [figname ' ' condset(ics).cond(1).sDesc];
end


for ispikeStruct = 8%1:  nSessions 
    load(fullfile(p,ss{ispikeStruct}))
    %add average WAveforms
    EUPlus = spikes.Analysis.EUPlusLabel;
    for iEU = 1:size(EUPlus,1)
        [spikes]= addUnits_spikes(spikes, EUPlus(iEU,:) );
    end
    EU = cell2mat(EUPlus(:,1:2));
    spikesNoW = rmfield(spikes,'waveforms');
    hprog = waitbar(ispikeStruct/nSessions);
    for ics =  1:length(condset)
        clear thisSession_roc thisSession_Area thisSession_H thisSession_Electrode thisSession_datenum
        %%
        for iEU =1: size(EU,1) %13
            Electrode = EU(iEU,1);
            UnitID =  EU(iEU,2);
            % ADD grouping by interval including all intervals at least X long)
            % s_unitregression_inprog
            %% For ROC
            clear options cond;
            ElectUnit = [Electrode UnitID];            
            cond(1) = condset(ics).cond(1);            
            cond(2) = condset(ics).cond(2);            
            cond(1).spikesf = {'Electrode',ElectUnit(1),'Unit',ElectUnit(2)};
            cond(2).spikesf = {'Electrode',ElectUnit(1),'Unit',ElectUnit(2)};                
            WOI  = condset(ics).WOI;
            
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
        roc(ics).all_roc = { roc(ics).all_roc{:} thisSession_roc{:}};
        roc(ics).all_Area = [ roc(ics).all_Area thisSession_Area];
        roc(ics).all_H = [ roc(ics).all_H thisSession_H];
        roc(ics).electrode = [ roc(ics).electrode thisSession_Electrode];
        roc(ics).datenum = [ roc(ics).datenum thisSession_datenum];
        roc(ics).condset = condset(ics);
    end
end
delete(hprog)

%% plot and save
nc = 2
nr = 2

for ics = 1:length(condset)
    
    all_roc = roc(ics).all_roc;
    all_H = logical(roc(ics).all_H);
    roc(ics).all_H = logical(roc(ics).all_H);
    all_Area = roc(ics).all_Area;
    thisroc = roc(ics);
    
    h.fig = figure('name',figname);
    for iUnit = 1:size(all_roc,2)%[6 10 13]
        subplot(nr,nc,1)
        hline = line(all_roc{iUnit}(1,:),all_roc{iUnit}(2,:),'marker','.','linestyle','-');
        if  all_H(iUnit)
            setColor(hline,'r');
        else setColor(hline,'k'); end
    end
    line([0,1],[0,1],'color','k');
    axis square
    
    subplot(nr,nc,2)
    [a x] = hist(all_Area);
    hbar = findobj(gca,'Type','patch');
    hbar = bar(x,a); hold on
    set(hbar(1),'FaceColor',[1 1 1]*.5,'EdgeColor','k');
    [a x] = hist(all_Area(all_H==1),x);
    hbar(2)  = bar(x,a); hold on
    
    set(hbar(2),'FaceColor','r','EdgeColor','k');
    
    title([condset(ics).sDesc  ' n =' num2str(sum(all_H)) '/' num2str(length(all_H)) ])
    
     roc1 = roc(1); roc2 = roc(2);
    subplot(nr,nc,3)
     plotROCvsROC(roc1,roc2)
     
     
    subplot(nr,nc,4) 
    % ADD distribution across days
    %Distribution Across Electrodes
   
    e = unique(roc(ics).electrode);
    nspikes = [];nroc1 = []; nroc2 = []; nroc12 = [];
    for ie = e
        nspikes(end+1) = sum(roc(ics).electrode==ie);
        nroc1(end+1)  = sum(roc(ics).electrode==ie&roc1.all_H);
        nroc2(end+1)  = sum(roc(ics).electrode==ie&roc2.all_H);
        nroc12(end+1)  = sum(roc(ics).electrode==ie&roc2.all_H&roc1.all_H);
    end
    nspikesBundle = [];nroc1Bundle = []; nroc2Bundle = []; nroc12Bundle = [];
    for ib = 1:4
        thisBundle = [(32+(ib-1)*8):(40+(ib-1)*8)];
        nspikesBundle(end+1) = sum(ismember(roc(ics).electrode,thisBundle))/8;
        nroc1Bundle(end+1)  = sum(ismember(roc(ics).electrode,thisBundle)&roc1.all_H)/8;
        nroc2Bundle(end+1)  = sum(ismember(roc(ics).electrode,thisBundle)&roc2.all_H)/8;
        nroc12Bundle(end+1)  = sum(ismember(roc(ics).electrode,thisBundle)&roc2.all_H&roc1.all_H)/8;
        eBundle(ib) = mean(thisBundle );
        
    end
    
        
    if 1 % fraction
        plot(e,nroc1./nspikes,'.-r');hold on;
        plot(e,nroc2./nspikes,'.-b');hold on;
        plot(e,nroc12./nspikes,'.-g');hold on;
        
        plot((eBundle),nroc1Bundle./nspikesBundle,'.-r','Linewidth',2,'markersize',15);hold on;
        plot(eBundle,nroc2Bundle./nspikesBundle,'.-b','Linewidth',2,'markersize',15);hold on;
        plot(eBundle,nroc12Bundle./nspikesBundle,'.-g','Linewidth',2,'markersize',15);hold on;
        
        axis tight
        ax2 = axes('Position',get(gca,'Position'),...
            'XAxisLocation','top',...WOI
            'YAxisLocation','right',...
            'Color','none',...
            'XColor','k','YColor','g','Xtick',[],'Xticklabel',[]);
        ylabel('num units')
        xlabel('electrode')
        linkaxes([gca ax2],'x');
        hold on
        plot(e,nspikes,'.-k','Parent',ax2);
        plot(eBundle,nspikesBundle,'.-k','Parent',ax2,'Linewidth',2,'markersize',15);
        axis tight
    else
        plot(e,nspikes,'-.','k');hold on;
        plot(e,nroc1,'-.','r');hold on;
        plot(e,nroc2,'-.','b');hold on;
        plot(e,nroc12,'-.','g');hold on;
    end
    xlabel('electrode')
    
    sAnimal = spikes.sweeps.Animal;
    plotAnn([condset(ics).sDesc ' ' num2str(nSessions) ' Sessions ' sAnimal])

    savepath = fullfile(r.Dir.EphysFigs,sAnimal,'ROC');
    parentfolder(savepath,1);
    savefile = condset(ics).sDesc    ;
    
    
    export_fig(h.fig,fullfile(savepath,savefile),'-pdf')
    %     plot2svg(fullfile(savepath,[savefile,'.svg']),h.fig)
%     saveas(h.fig,fullfile(savepath,savefile))
    save(fullfile(savepath,savefile),'thisroc','ss')
end


