% Make matrix for dPCA
% data= Unit x stimulus x decision x PSTH x trial
% numTrial = (iUnit,intv,decision)+1
savepath = 'C:\Users\Behave\Dropbox (Learning Lab)\PatonLab\Paton Lab\Data\TAFCmice\Ephys\InTask\Analysis\SertxChR2_179\dPCA\';

saveMatFile = '4Interval5Sessions';
bd = brigdefs;
flist = dirc([fullfile(bd.Dir.spikesStruct,'SertxChR2_179\') '*.mat']);
fname = flist(:,1);

nfiles =  1:5; %length(fname); % 6 and 7 have 8 intervals the easiest 2 are not 2.4 but could be averaged
int_list = round([0.6    1.05       1.95    2.4]*1000);
% nfiles =  1:7; %length(fname); % 6 and 7 have 8 intervals the easiest 2 are not 2.4 but could be averaged
% int_list = round([0.6    1.05    1.26    1.74    1.95    2.4]*1000);
alignEvent = 'TrialInit';
WOI  = [3 3]*1000;
clear options
options.binsize = 50;
options.nsmooth =round(200/ options.binsize);

nintv = length(int_list);
ncondPerAlignEvent = 2;
nAlign = length(alignEvent);

clear condSet
icondSet = 1; % doens't work with many rightnow
condSet(icondSet).sweepsf = {'ChoiceLeft',0,'ChoiceCorrect',[0 1]};
condSet(icondSet).index = [1 1]; % RIGHT NOTPREMATIRE
icondSet = icondSet+1;
condSet(icondSet).sweepsf = {'ChoiceLeft',1,'ChoiceCorrect',[0 1]};
condSet(icondSet).index = [2 1]; % LEft NOTPREMATIRE
icondSet = icondSet+1;
condSet(icondSet).sweepsf = {'PrematureShort',[1]};
condSet(icondSet).index = [1 2]; % Right NOTPREMATIRE
icondSet = icondSet+1;
condSet(icondSet).sweepsf = {'PrematureLong',[1]};
condSet(icondSet).index = [2 2]; % LEft NOTPREMATIRE
% 
ncond(1) = 2;
ncond(2) = 2;
ntime = 121;
ncondSet = length(condSet);

unitPsth = struct([]);
iunit = 0; ntotalTrials = 0;
estimateUnits = 100;
estimateTrials = 100;
firingRates = nan(estimateUnits,nintv,ncond(1),ncond(2),ntime,estimateTrials,'single');
numTrials = nan(estimateUnits,nintv,ncond(1),ncond(2),'single');
for ifile = 6:7
    
    load(fullfile(bd.Dir.spikesStruct,'SertxChR2_179\',fname{ifile}));
    [spikes.sweeps]= prematurePsycurvHelper(spikes.sweeps);
    spikes.sweeps.Interval = spikes.sweeps.IntervalwithPM;
    spikes.sweeps.Interval(ismember(spikes.sweeps.Interval,[0.45 0.72])) = 0.6;
    spikes.sweeps.Interval(ismember(spikes.sweeps.Interval,[2.28 2.55])) = 2.4;
    spikes.sweeps.IntervalR = round(spikes.sweeps.Interval*spikes.sweeps.Scaling);
    
    spikes.sweeps.IntervalSet*spikes.sweeps.Scaling
end 
    EU = spikes.Analysis.EU;
    for iEU = 1:size(EU,1),        [spikes]= addUnits_spikes(spikes, EU(iEU,:) );  end
    spikesNoW = rmfield(spikes,'waveforms');
    
    nTrialsInFile = spikesNoW.sweeps.ntrials;
    for iEU =1: size(EU,1)
        iunit = iunit+1;
%         unitPsth(iunit).firingRates = nan(nintv,condSet(ii).value ,ntime,nTrialsInFile,'single');
%         unitPsth(iunit).numTrials = nan(nintv,ncond1,'single');
        Electrode = EU(iEU,1);
        UnitID =  EU(iEU,2);
        
        options.bsave = 0;
        options.bootstrap = 0;
        options.bplot = 0;
        options.dpFieldsToPlot = {};
        options.sortSweepsByARelativeToB= {};
        options.plottype = {'psth'};
        
        sAnimal = spikesNoW.sweeps.Animal;
        sDate = spikesNoW.sweeps.Date;
        
        cond.spikesf = {'Electrode',Electrode,'Unit',UnitID};
        for ic = 1:ncondSet
            thissweepsf = condSet(ic).sweepsf;
            ind =condSet(ic).index;
            for  intv = 1: nintv
                cond.sweepsf = {thissweepsf{:} 'IntervalR',int_list(intv)};
                these_spikes = filtspikes(spikesNoW,0,cond.spikesf,cond.sweepsf);
                ntrials = these_spikes.sweeps.ntrials;
                if ntrials ==0,                   disp(['iEU' num2str(iEU) ' ic' num2str(ic) ' intv' num2str(intv) ' No trials']);                end
                trialNum(iunit,intv,ind(1),ind(2)) = ntrials;               
                for itrial = 1:ntrials
                    thiscond.sweepsf = {'TrialNumber',itrial}; thiscond.spikesf ={}; thiscond.alignEvent = alignEvent;
                    [~,  ~, data]= psthCondSpikes(these_spikes,thiscond, WOI, options);
                    firingRates(iunit,intv,ind(1),ind(2), : ,itrial) = data.psth;
                end
            end
        end
 
%         iunit = length(unitPsth)+1;
%         unitPsth(iunit).options = options;
%         unitPsth(iunit).cond = cond;
%         unitPsth(iunit).data = data;
%         unitPsth(iunit).Electrode = Electrode;
%         unitPsth(iunit).unitID = UnitID;
%         unitPsth(iunit).wv = spikesNoW.units.wv(iEU,:);
%         unitPsth(iunit).wvstd = spikesNoW.units.wvstd(iEU,:);
%         unitPsth(iunit).info = spikes.info;
%         
        
    end % each Unit
end

save(fullfile(savepath,saveMatFile),'firingRates','trialNum','nfiles','fname','alignEvent','condSet');
%%
firingRates = squeeze(firingRates(:,:,:,2,:,:)) ;% select only side
firingRatesAverage = nanmean(firingRates,ndims(firingRates));
trialNum = squeeze(trialNum);

% find units that have minimum rate
MINRATE = 0.1; % haz

meanRates = nanmean(nanmean(nanmean(firingRatesAverage,2),3),4);
indUnits =  ~isnan(meanRates) & meanRates>MINRATE;
trialNum = trialNum(indUnits,:,:);
firingRates = firingRates(indUnits,:,:,:,:);
firingRatesAverage = firingRatesAverage(indUnits,:,:,:);
firingRates = double(firingRates);
firingRatesAverage = double(firingRatesAverage);
trialNum = double(trialNum);
timeEvents = [62 78 82 99 108];


%%
% TODO
% Look at email Dmitry sent you. run test example 
% for all Unit

% PUT IN average of unit when data missing (this will deteriorate decoding
% in some cases)
% for iunit = 1:size(trialNum,1)
%     trialNum(iunit,intv,ind(1),ind(2))
    