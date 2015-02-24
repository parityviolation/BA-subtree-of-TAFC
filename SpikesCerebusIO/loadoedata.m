function d = loadoedata(direc,channels,type)

% direc = 'D:\EphysData\SertxChR2_179\raw_2014-01-22_20-00-06\';
% direc = 'D:\EphysData\SertxChR2_179\openField_2014-01-26_18-35-55';
direc = 'F:\Bass\ephys\Sert179\2014-02-09_16-22-17';
switch (type)
    case 'c' % load continuous
        
        for ichn = 1:length(channels)
            thisChan = channels (ichn);
            
            filename = ['100_CH' num2str(thisChan) '.continuous'];
            [tempdata, ~, info] = load_open_ephys_data(fullfile(direc,filename));
            d.date = info.date_created;
            d.ChannelID(ichn) = info.header.channel;
            d.filename{ichn} = filename;
            if ichn ==1
                d.dt = 1/info.header.sampleRate;
                d.Data = nan(size(tempdata,1),length(Channels));
            end
            d.Data(:,ichn) = tempdata;
        end
        
    case 's' % load spikes
        for ichn = 1:length(channels)
            thisChan = channels (ichn);
            filename = ['Singleelectrode' num2str(thisChan) '.spikes'];
            [data, timestamps, info] = load_open_ephys_data(fullfile(direc,filename));
            d.spk.data = single(data);
            d.spk.timestamps = single(timestamps);
            d.spk.info = info;        end
    case {'e','events','event'} % load events
        
        filename = 'all_channels.events';
        [data, timestamps, info] = load_open_ephys_data(fullfile(direc,filename));
        d.events.data = single(data);
        d.events.timestamps = single(timestamps);
        d.events.info = info;
end


d.fullfilename = fullfile(direc,filename);
d.filename = filename;
d.path = direc;


