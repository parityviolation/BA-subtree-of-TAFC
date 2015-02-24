function [moviedata displayParam stimulusParam] = loadSTAmovie(movieName)
r = RigDefs();
extradir =  '' ; % 'Sparse Noise\'; % should be removed % NOT COMPATIBLE WITH COLORED NOISE

% load movie.
try
    % find last directory in r.Dir.VstimMovies that matches
    %     movieName
    lastdir = 'movies\'; % STUPIDLY it expects the movieName to be in a folder called movies
    ind = strfind(movieName,lastdir) + length(lastdir);
    if isempty(ind) % if it is not it just takes the movieName filename
        lastdir = '\';
        ind = strfind(movieName,lastdir) + length(lastdir);
        ind = ind(end);
    end
    mvfn = fullfile(r.Dir.VstimMovies,extradir, movieName(ind:end));
    
    s= load(mvfn);
    moviedata = s.moviedata;
    displayParam = s.displayParam;
    if isfield(s,'stimulusParam')
        stimulusParam = s.stimulusParam;
    elseif isfield(s,'stimParam')
        stimulusParam = s.stimParam;
    end
    
    % add a few fields for backwards compatiblity
    if ~isfield(stimulusParam,'fullfield')
        stimulusParam.fullfield = 0;
    end
    if ~isfield(stimulusParam,'bbinary')
        stimulusParam.bbinary = 0;
    end
    
    
catch ME
    getReport(ME)
    keyboard
    
end

