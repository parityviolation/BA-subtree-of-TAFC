% load
r = brigdefs;
chn = 3
basedir = r.Dir.EphysData;
mdir = 'Sert_179\012014\';
fileheader = 'datafile006';
f = [fileheader '.ns6'];
filename = fullfile(basedir,mdir,f)

%% load digital events
[path fn ext] = fileparts(filename);
sdir = fullfile(r.Dir.EphysData,mdir,'Matlab');
savef= strrep(f,'.','_');
savef= fullfile(sdir,[savef '_' 'digital.mat']);

if exist(savef,'file')
    load(savef);
else
    ev = loadDdata(filename);
    save(savef,'ev');
end

%% script for all channels
chns = [1:32];
lowPass = 300;
i = 0;
for ichn = chns
    ichn
    i = i+1;
    try
        d = loadedata(filename,ichn);
        
        d.lfp.lowPass = lowPass;
        % subsample
        d.lfp.subsample = 10;
        d.lfp.dt = d.dt*d.lfp.subsample;
        d.lfp.data = d.Data(1:d.lfp.subsample:end);
        
        ev_temp.timestamp_samples= round(ev.timestamp/d.dt);
        ev_temp.dt = d.dt;
        
        d.ev = ev_temp;
        % get sta LFP
        d.ev.WOI = [10 10];
        
        d.lfp.LowPass= 50;
        d.lfp.fdata = filtdata(double(d.Data)',1/d.dt,d.lfp.lowPass,'low');
        sWOI = round(d.ev.WOI/d.dt);
        w = getWOI(d.lfp.fdata,d.ev.timestamp_samples,sWOI);
        xtime = [-sWOI(1):sWOI(2)]*d.dt;
        
        %% intialize variables
        if i == 1
            meanEventTrigeredLFP = nan(length(chns),size(xtime,2));
        end

        meanEventTrigeredLFP(i,:) =nanmean(w);
        
                 
        
    catch ME
        ichn
        getReport(ME)
    end
    
end
% save

savef= strrep(filename,'.','_');

[path fn ext] = fileparts(filename);

path = fullfile(path,'LFP');
parentfolder(path,1)

header = 'LFP';
save(fullfile(path,[header fn]),'meanEventTrigeredLFP')
% plot multiunit PSTH

% plot for unstimulated trials

%%

offsetplot(meanEventTrigeredLFP,d.lfp.dt)
