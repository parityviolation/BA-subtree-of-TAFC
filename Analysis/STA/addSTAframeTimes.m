function expt = addSTAframeTimes(expt,DAQchn_FLIPS)
% function expt = addSTAframeTimes(expt,DAQchn_FLIPS)

r = RigDefs;

if nargin <2,    DAQchn_FLIPS =  r.vstim.flipAIChan; end


LEDchns = cell2mat(r.led.AIChan );


%  find movie stimuli files
indMovie = zeros(length(expt.stimulus));
for i = 1:length(expt.stimulus)
    if  isequal(expt.stimulus(i).params.StimulusName,'Movie')
        indMovie(i) = 1;
    end
end
indMovie = find(indMovie);

% DAQchn_FLIPS = 23; % chn with FLIPS on it
try
    for i = 1:length(indMovie); % for all files with movies
        indfile = indMovie(i);
        
        moviedata = loadSTAmovie(expt.stimulus(indfile).params.MovieName);
        mvframes = size(moviedata,3); % use to check if movie frames match recorded frames
        logstring = [];
        for itrigger = 1:expt.files.triggers(indfile) % for each trigger
            % --- Add FrameTimes
            
            STF.filename = fullfile(r.Dir.Data, expt.files.names{indfile});
            STF(1).MAXTRIGGER = itrigger;
            
            swdata = getFramesTimes('',STF,mvframes,DAQchn_FLIPS);
            actualframes = length(swdata.frametime);
            % get actual framerate
            expt.stimulus(indfile).params.ActualMovieRate = mode(diff(swdata.sample)/expt.files.Fs(indfile))^-1;
            s = sprintf(' Movie rate:  %1.1f Actual Rate: %1.1f', expt.stimulus(indfile).params.MovieRate, expt.stimulus(indfile).params.ActualMovieRate);
            disp(s);
            s = sprintf('Movie frames:  %1.1f Actual Frames: %1.1f',mvframes, actualframes);
            disp(s);
            
            % custom removal of frames that are from movie to gray (this happens every
            % 3 secs
            if  mvframes < actualframes % assume that gray is added
                s = sprintf ('%s,******** removing 1 frame every 3 secs because of inserted gray period *********', logstring);
                grayperiod = 3; % sec
                grayframe = expt.stimulus(indfile).params.MovieRate *grayperiod;
                ind_mask = ones(size( swdata.frametime),'int16');
                ind_mask(grayframe+1:grayframe+1:end) = 0;
                swdata.frametime = swdata.frametime(logical(ind_mask));
                swdata.sample = swdata.sample(logical(ind_mask));
                
                s = sprintf('%s,\n        Frames = %s',s, num2str(length(swdata.frametime)));
                display(s);
                logstring = sprintf ('%s,%s', logstring,s);
            end
            expt.LOG.getFramesTimes = logstring;
            expt.analysis.STA.files(indfile).trigger(itrigger).frametimes = swdata.frametime;
            expt.analysis.STA.files(indfile).trigger(itrigger).sample = swdata.sample;
            
            
            % --- Add LED status for frames
            ledstatus = getLEDduringFrameTimes(STF.filename,swdata.sample,LEDchns);
            expt.analysis.STA.files(indfile).trigger(itrigger).led = ledstatus;
            
        end
    end
catch ME
    getReport(ME)
end