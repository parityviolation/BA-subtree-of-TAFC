% s_LoadSyncAndContinuous_Extract spikes

% load
r = brigdefs;
basedir = r.Dir.EphysData;
mdir = 'Sert_179\012014\';
fileheader = 'datafile008';
% mdir = 'Sert_179\012414';
% fileheader = 'datafile003';
f = [fileheader '.ns6'];
filename = fullfile(basedir,mdir,f);
THRESH_STD = 6;
fileFooter = ''
%% load digital events
[LOADPATH fn ext] = fileparts(filename);
STF.filename = [fn ext]

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
chns = [14];
filtparam.dfilter = [NaN,NaN,60 0]; % for other filters (none)
filtparam.maxlevel =  [5];                                        % for wavelet filter
bNoLoad = 0;                                                    % reload of you can
i = 14;
for ichn = chns
    try
        clear spikes
        if 1
            % %TODO fix so that saving doesn't overwrite
        [filterdata dt data] =  preprocessDAQ(LOADPATH,STF,ichn,filtparam,bNoLoad);
        else
            filterdata = m2(3,:)';
        end
                stds = 1.4785*mad(filterdata,1);
        data = convertDataForSpikes(filterdata);
        clear filterdata

        spikes = ss_default_params_custom(1/dt);
        spikes.params.display.label_categories = r.SS.label_categories ;
        spikes.params.display.label_colors = r.SS.label_colors;
        spikes.info.spikesfile = fullfile(LOADPATH,'spikes',['spikes_chn' num2str(ichn) fileFooter '.mat']);
        parentfolder(fileparts(spikes.info.spikesfile) ,1)
        
        spikes.info.detect.stds = stds;
        spikes.preprocess.filter.param = filtparam;
        %  spikes.preprocess.filter.name = filtparam.name ;
        spikes.params.detect_method = 'auto';
        spikes.params.thresh = THRESH_STD;
        
        spikes = ss_detect_custom(data,spikes);                             % Triggers x Samples x Channels
        %  TO DO   remove outliers
        clear data
        save(spikes.info.spikesfile,'spikes');
        
        
        % Heuristic for picking size of clusters
        spikes.params.kmeans_clustersize = round(max(500,length(spikes.spiketimes)/100));
        
        if 1
            % Cluster spikes
            spikes = ss_align(spikes);
            spikes = ss_kmeans(spikes);
            spikes = ss_energy(spikes);
            spikes = ss_aggregate(spikes);
            
            save(spikes.info.spikesfile,'spikes');
        end
        
    catch ME % save spikes if there is an error so nothing is lost
        getReport(ME)
        ichn
    end
    
end
% save
%%
splitmerge_tool(spikes)
%%
t = round(12/dt)
xtime = [1:t]*dt;
clf
plot(xtime,data(1:t));
hold all
plot(xtime,filterdata(1:t));
 Load events
 
