function STAresult = computeSTA(expt,unitTag,fileInd,STAparams,cond,spikes)

% TO DO quantify variablity of frametimes

if exist('spikes','var')
    frameNum = helperSTA_getSpikeFrameNum(expt,unitTag,fileInd,STAparams,cond,spikes);
else
    frameNum = helperSTA_getSpikeFrameNum(expt,unitTag,fileInd,STAparams,cond);
end
%% --- load movie
% check all files have same movie
templateMovieName = expt.stimulus( fileInd(1)).params.MovieName;
for ifile = 2 : length(fileInd) % for each file
    indfile  = fileInd(ifile);
    if ~isequal(expt.stimulus(indfile).params.MovieName,templateMovieName)
        s = sprintf('Different movies cannot be analyzed together');
        error(s);
    end
end

[moviestruct.moviedata moviestruct.displayParam moviestruct.stimulusParam]= loadSTAmovie(templateMovieName);

    STAresult.bfullfield = 0;

if moviestruct.stimulusParam.fullfield
    moviestruct.moviedata = moviestruct.moviedata(1,1,:);
    STAresult.type = 'fullfield';
    STAresult.bfullfield = 1;
else
    STAresult.type = '';
end
%
STAresult.exptname = expt.name;
STAresult.unitTag = unitTag;
STAresult.movieName = templateMovieName;
STAresult.nspikes = size(frameNum,2);
STAresult.STAparams = STAparams;
STAresult.fileInd = fileInd;
STAresult.frameNum  = frameNum;
STAresult.screenRes = [size(moviestruct.moviedata,1) size(moviestruct.moviedata,2)];

if  ~isempty(findstr(lower(expt.stimulus(indfile).params.MovieName),'sparse')) % sparse noise movie
    disp('*** Sparse Noise Movie ***')
    STAresult.type = 'sparse';
    grey = 128;
    white_movie = moviestruct.moviedata;
    white_movie(white_movie<grey) = 128;
    STAresult.movie{1} = helper_computeSTA(white_movie,frameNum);
    
    black_movie = moviestruct.moviedata;
    black_movie(black_movie>grey) = 128;
    STAresult.movie{2} = helper_computeSTA(black_movie,frameNum);
elseif moviestruct.stimulusParam.bbinary
    STAresult.type = [STAresult.type 'binary'];
    disp(['*** ' STAresult.type ' ***'])
    STAresult.movie{1} = helper_computeSTA(moviestruct.moviedata,frameNum);
    
elseif ~isempty(findstr(lower(expt.stimulus(indfile).params.MovieName),'white'))
    STAresult.type = [STAresult.type 'white'];
    disp(['*** ' STAresult.type ' ***'])
    
    if ~moviestruct.stimulusParam.fullfield% shrink moviedata to size of independent pixels
        px = moviestruct.stimulusParam.psize;
        m = moviestruct.moviedata(1:px:end,1:px:end,:);
    else
        m = moviestruct.moviedata;
    end
    
    STAresult.movie{1} = helper_computeSTA(m,frameNum);
    
else
    disp('*** Colored Noise Movie ***')
    % NOTE NOT WHITENED
    STAresult.type = 'colored';
    STAresult.movie{1} = helper_computeSTA(moviestruct.moviedata,frameNum);
end


% play  movie
if 0
    playSTA(STAresult.movie{1},STAresult)
    playSTA(STAresult.movie{2},STAresult)
    
end




