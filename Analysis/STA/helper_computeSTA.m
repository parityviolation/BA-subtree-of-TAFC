function movieSTA = helper_computeSTA(moviedata,frameNum)
% --- convert  movie in form Space x Frame from xSpace x ySpace x Frame 

% frameNum  - frame numbers around each spike that go into the STA

% moviedata = loadSTAmovie(templateMovieName);
[dx dy df] = size(moviedata); % get xspace x yspace x frames of movie

Stim = reshape(moviedata,dx*dy,df);
% Stim = uint8( double(Stim)- repmat(reshape(mean(moviedata,3),dx*dy,1),[1 df]));
% BA not sure if this is the right way to subtract noise
% clear moviedata;

% ***** THIS IS A HACK frames that exist in data but not in movie suggest
% something is VERY WRONG. and needs a real fix

% find any spikes that have frametimes> moviedata frames and through away
nFrames= size(moviedata,3);
maxActualFrames = max(frameNum(:));
if maxActualFrames>nFrames,
    s = sprintf('\n spikes with these frames will be removed ***** THIS IS A HACK frames that exist in data but not in movie suggest');
    display(['                  Movie frames: ' num2str(nFrames) '< Actual frames: ' num2str(maxActualFrames) s]);
end

% something is VERY WRONG. and needs a real fix
% remove spikes with frames that don't exist in the movie
[r c] = find(frameNum>nFrames);
frameNum(:,c) =[]; 

dWOI = size(frameNum,1); % get length of STA movie in frames
nspikes = size(frameNum,2);


%% convert ST_Frames into stimlus movie from just frame numbers
spkchunk = 500;
% compute STA in spike chunks otherwise too much memory
nchunks =max(1,ceil(nspikes/spkchunk));
chunk_movieSTA = zeros(nchunks,dWOI*dx*dy);
disp('************ Computing STA **************')
for ichunk = 1:nchunks
    
    endInd = min(dWOI*ichunk*spkchunk,nspikes*dWOI);
    
    thischunk_frameNums = frameNum(1+(dWOI*spkchunk*(ichunk-1)):endInd);
    temp = Stim(:,thischunk_frameNums); % get frames for spikes in this chucnk
    thischunk_nspikes = length(thischunk_frameNums)/dWOI;
    chunk_movieSTA(ichunk,:) = single(mean(reshape(temp,dWOI*dx*dy,thischunk_nspikes),2));
    % weight be number of spikes
    chunk_movieSTA(ichunk,:)  = chunk_movieSTA(ichunk,:) *thischunk_nspikes;
end
clear Stim
% compute average weighted by the number of spikes in each chunk
if min(size(chunk_movieSTA))>1
movieSTA = sum(chunk_movieSTA);
else
    movieSTA = chunk_movieSTA;
end
clear chunk_movieSTA;
   movieSTA = movieSTA /nspikes;
movieSTA = reshape(movieSTA,dx,dy,dWOI);
movieSTA = movieSTA- repmat(mean(moviedata,3),[1 1 dWOI]); % subtract mean movie from each frame