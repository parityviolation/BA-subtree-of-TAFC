% filename =  'E:\Bass\ephys\copy\021514\datafile001-01.nev';
% filename =  'E:\Bass\ephys\copy\021514\datafile001.nev';
% filename =  'E:\Bass\ephys\Sert_179\test sorting sofia\022314\Sorted\datafile002-sorted-ch-39-42-60.nev';

% HOW to summarize units?
% more days to sort (some partly sorted but some electrodes may still have
% units
% do I need to collapse across days?

%% ******************** BUILDING spike structs **************
buildoptions.bNoWaveforms = 0;
buildoptions.bRecomputeDp = 1
buildoptions.bNOVideo = 1;
%% 020514
filename =  'E:\Bass\ephys\copy\020514\datafile001-01.nev';
spikes = buildSpikes2(filename,'',[],buildoptions); spikes = filtspikes(spikes,0,{'Unit',@(x) ~ismember(x,[0 255])}); % concatenate
spikes.Analysis.EUPlusLabel =           ...
 {    34 1  'multiunit'
    35 1  'multiunit'
    36 1  'multiunit'
    42 1  'multiunit'
    44 1  'dirty'
    46 1  'dirty'
    46 2  'dirty'
    64 1  'dirty'
 };
saveSpikes(spikes)
%% 021514
filename =  'E:\Bass\ephys\copy\021514\datafile001-01.nev';
spikes = buildSpikes2(filename,'',[],buildoptions); spikes = filtspikes(spikes,0,{'Unit',@(x) ~ismember(x,[0 255])}); % concatenate
spikes.Analysis.EUPlusLabel =           ...
 {    34 1  'multiunit'
    35 1  'multiunit'
    35 2  'dirty'
    36 1  'multiunit'
    36 2  'multiunit'
    38 1  'multiunit'
    42 1  'ok'
    42 2  'dirty'
    42 3  'multiunit'
    44 1  'dirty'
    44 2  'multiunit'
    48 1  'multiunit'
    52 1  'multiunit'
    60 1  'multiunit'
    60 2  'ok'
    64 1  'dirty'
    64 1  'multiunit'
 };
saveSpikes(spikes)
%% 021614
filename =  'E:\Bass\ephys\copy\021614\datafile002-01.nev';
spikes = buildSpikes2(filename,'',[],buildoptions); spikes = filtspikes(spikes,0,{'Unit',@(x) ~ismember(x,[0 255])}); % concatenate
spikes.Analysis.EUPlusLabel =           ...
 {    34 1  'dirty'
     34 2  'multiunit'
    36 1  'multiunit'
    38 1  'ok'
    40 1  'dirty'
    42 1  'ok'
    42 2  'dirty'
    42 3  'multiunit'
    44 1  'ok'
    44 2  'multiunit'
    44 3  'multiunit'
    46 1  'ok'
    46 2  'multiunit'
    46 3  'dirty'
    50 1  'multiunit'
    64 1  'multiunit'
    64 2  'dirty'
    64 3  'dirty'
 };
saveSpikes(spikes)
%% 021914
filename =  'E:\Bass\ephys\copy\021914\datafile001-04.nev';
spikes = buildSpikes2(filename,'',[],buildoptions); spikes = filtspikes(spikes,0,{'Unit',@(x) ~ismember(x,[0 255])}); % concatenate
spikes.Analysis.EUPlusLabel =           ...
 {  34 1  'dirty'
    34 2  'multiunit'
    36 1  'multiunit'
    37 1  'dirty'
    38 1  'dirty'
    40 1  'multiunit'
    42 1  'ok'
    42 2  'multiunit'
    44 1  'multiunit'
    44 2  'multiunit'
    46 1  'ok'
    46 2  'dirty' 
    52 1  'multiunit'
    60 1  'dirty'
    64 1  'multiunit'
 };
saveSpikes(spikes)
%% 022014
filename =  'E:\Bass\ephys\copy\022014\datafile003-01.nev';
spikes = buildSpikes2(filename,'',[],buildoptions); spikes = filtspikes(spikes,0,{'Unit',@(x) ~ismember(x,[0 255])}); % concatenate
spikes.Analysis.EUPlusLabel =           ...
 {  34 1  'multiunit'
    36 1  'dirty'
    37 1  'multiunit'
    38 1  'multiunit'
    42 1  'multiunit'
    42 2  'ok'
    44 1  'multiunit'
    44 2  'multiunit'
    44 3  'ok'
    46 1  'dirty'
    60 1  'dirty FS'
    64 1  'ok FS'
 };
saveSpikes(spikes)
%% 022214
filename =  'E:\Bass\ephys\copy\022214\datafile001-01.nev';
spikes = buildSpikes2(filename,'',[],buildoptions); spikes = filtspikes(spikes,0,{'Unit',@(x) ~ismember(x,[0 255])}); % concatenate
spikes.Analysis.EUPlusLabel =           ...
 {  
    34 1  'multiunit'
    34 2  'dirty'
    36 1  'multiunit'
    37 1  'multiunit'
    38 1  'multiunit'
    40 1  'multiunit'
    42 1  'ok'
    42 2  'dirty'
    42 3  'multiunit'
    44 1  'good'
    44 2  'multiunit'
    46 1  'multiunit'
    46 2  'ok'
    48 1  'dirty'
    48 2  'dirty'
    52 1  'dirty'
    52 2  'dirty'
    52 3  'multiunit'
    60 2  'ok'
    60 1  'dirty'
    64 1  'dirty FS'
 };
saveSpikes(spikes)
%% 022314
filename =  'E:\Bass\ephys\copy\022314\datafile002-03.nev';
spikes = buildSpikes2(filename,'',[],buildoptions); spikes = filtspikes(spikes,0,{'Unit',@(x) ~ismember(x,[0 255])}); % concatenate
spikes.Analysis.EUPlusLabel =           ...
 {
    34 1  'multiunit';
    35 1  'multiunit'
    36 1  'dirty'
    38 1 'multiunit'
    39 1  'ok'
    39 2  'dirty'
    42 1  'good'
    42 2  'multiunit'
    44 1   'ok'
    44 2  'multiunit'
    48 1  'multiunit'
    52 1  'dirty'
    56 1  'multiunit'
    60 1 'good'
    60 2 'dirty'
    60 3 'multiunit'
    64 1 'good'};
saveSpikes(spikes)
%% 022514
filename =  'E:\Bass\ephys\copy\022514\datafile001-02.nev';
spikes = buildSpikes2(filename,'',[],buildoptions); spikes = filtspikes(spikes,0,{'Unit',@(x) ~ismember(x,[0 255])}); % concatenate
spikes.Analysis.EUPlusLabel =           ...
    {
    34 1  'dirty';
    35 1  'multiunit'
    36 1  'multiunit'
    37 1  'good'
    37 2  'good'
    37 3  'ok'
    38 1 'multiunit'
    39 1  'good'
    40 1  'multiunit'
    43 1  'good FS'
    44 1   'dirty'
    44 2  'multiunit'
    46 1  'multiunit'
    50 1  'multiunit'
    52 1  'multiunit'
    60 1 'ok'
    60 2 'dirty'
    64 1 'ok FS'};
saveSpikes(spikes)
%% 022614
filename =  'E:\Bass\ephys\copy\022614\datafile001-03.nev';
spikes = buildSpikes2(filename,'',[],buildoptions); spikes = filtspikes(spikes,0,{'Unit',@(x) ~ismember(x,[0 255])}); % concatenate
spikes.Analysis.EUPlusLabel =           ...
{
    34 1  'ok';
    35 1  'dirty'
    36 1  'dirty'
    37 1  'good'
    37 2  'good'
    39 1  'good'
    39 2  'dirty'
    42 1  'ok'
    42 2  'ok'
    42 3  'ok'
    43 1  'good FS'
    44 1   'ok'
    44 2  'multiunit'
    46 1  'dirty'
    47 1  'ok'
    47 2  'multiunit'
    52 1  'dirty'
    56 1  'multiunit'
    58 1 'ok'
    60 1 'ok'
    60 2 'dirty'
    64 1 'dirty FS'};
saveSpikes(spikes)
%% 022714
buildoptions.bNOVideo = 0;
buildoptions.bRecomputeDp = 0;
filename =  'E:\Bass\ephys\copy\022714\datafile002-04.nev';
spikes = buildSpikes2(filename,'',[],buildoptions); spikes = filtspikes(spikes,0,{'Unit',@(x) ~ismember(x,[0 255])}); % concatenate
spikes.Analysis.EUPlusLabel =           ...
{
    34 1  'multiunit';
    35 1  'dirty'
    36 1  'dirty'
    37 1  'dirty'
    37 2  'dirty'
    38 1  'multiunit'
    39 1  'good'
    39 2  'multiunit'
    40 1  'multiunit'
    42 1  'ok'
    42 2  'multiunit'
    43 1  'good FS'
    44 1   'multiunit'
    46 1  'dirty'
    46 2  'multiunit'
    52 1  'multiunit'
    58 1  'dirty'
     60 1 'dirty'
     60 2 'dirty'
    64 1 'dirty FS'
    64 2 'multiunit'};
saveSpikes(spikes)
%% 022814 % SHITT PERFORMANCE UNFINISHED SORTING
% buildoptions.bNOVideo = 0;
% buildoptions.bRecomputeDp = 0;
% filename =  'E:\Bass\ephys\copy\022814\datafile002-02.nev';
% spikes = buildSpikes2(filename,'',[],buildoptions); spikes = filtspikes(spikes,0,{'Unit',@(x) ~ismember(x,[0 255])}); % concatenate
% spikes.Analysis.EUPlusLabel =           ...
% {
%     
%     37 1  'good'
%     37 2  'good'
%     39 1  'good'
%     43 1  'good FS'
%     44 1   'ok'
%     46 1  'dirty'
%     46 2  'multiunit'
%     52 1  'multiunit'
%     58 1  'dirty'
%      60 1 'good'
%      60 2 'ok'
%     64 1 'good FS'};
% saveSpikes(spikes)
%% 030714
filename =  'E:\Bass\ephys\copy\030714\datafile006-01.nev';
spikes = buildSpikes2(filename,'',[],buildoptions); spikes = filtspikes(spikes,0,{'Unit',@(x) ~ismember(x,[0 255])}); % concatenate

spikes.Analysis.EUPlusLabel =           ...
{
    36 1  'multiunit';
    38 1  'multiunit';
    40 1  'dirty';
    42 1  'dirty';
    44 1  'multiunit';
    44 2  'ok';
   46 1  'multiunit';
   56 1  'multiunit';
   64 1  'dirty FS';}
saveSpikes(spikes)
%% 030814
filename =  'E:\Bass\ephys\copy\030814\datafile007-02.nev';
spikes = buildSpikes2(filename,'',[],buildoptions); spikes = filtspikes(spikes,0,{'Unit',@(x) ~ismember(x,[0 255])}); % concatenate

spikes.Analysis.EUPlusLabel =           ...
{
    52 1  'ok';
    56 1  'dirty';
    56 2  'multiunit';
   60 1  'multiunit';
   60 2  'multiunit';
   64 1  'good FS';}
saveSpikes(spikes)
%% 031014
filename =  'E:\Bass\ephys\copy\031014\datafile002-01.nev';
spikes = buildSpikes2(filename,'',[],buildoptions); spikes = filtspikes(spikes,0,{'Unit',@(x) ~ismember(x,[0 255])}); % concatenate

spikes.Analysis.EUPlusLabel =           ...
{
    56 1  'dirty';
   64 1  'good FS';}
saveSpikes(spikes)
%% 031114
filename =  'E:\Bass\ephys\copy\031114\datafile003-01.nev';
spikes = buildSpikes2(filename,'',[],buildoptions); spikes = filtspikes(spikes,0,{'Unit',@(x) ~ismember(x,[0 255])}); % concatenate

spikes.Analysis.EUPlusLabel =           ...
{
    49 1  'dirty';
   52 1  'good FS';
    56 1  'multiunit';
    58 1  'multiunit';
    60 1  'multiunit';
   64 1  'good FS';}
saveSpikes(spikes)
%% 031214  recording stops at sec 11864
filename =  'E:\Bass\ephys\copy\031214\datafile004-01.nev';
spikes = buildSpikes2(filename,'',[],buildoptions); spikes = filtspikes(spikes,0,{'Unit',@(x) ~ismember(x,[0 255])}); % concatenate

spikes.Analysis.EUPlusLabel =           ...
{
   52 1  'ok FS';
    56 1  'dirty';
   64 1  'good FS';}
saveSpikes(spikes)
%% 031314
filename =  'E:\Bass\ephys\copy\031314\datafile005-01.nev';
spikes = buildSpikes2(filename,'',[],buildoptions); spikes = filtspikes(spikes,0,{'Unit',@(x) ~ismember(x,[0 255])}); % concatenate

spikes.Analysis.EUPlusLabel =           ...
{
   52 1  'dirty FS';
    60 1  'multiunit';
   64 1  'dirty FS';}
saveSpikes(spikes)
%% 031414
filename =  'E:\Bass\ephys\copy\031414\datafile006-01.nev';
spikes = buildSpikes2(filename,'',[],buildoptions); spikes = filtspikes(spikes,0,{'Unit',@(x) ~ismember(x,[0 255])}); % concatenate

spikes.Analysis.EUPlusLabel =           ...
{
   52 1  'ok FS';
   56 1  'dirty';
   58 1  'multiunit';
    60 1  'okay';
   64 1  'good FS';}
saveSpikes(spikes)
%% 031714
filename =  'E:\Bass\ephys\copy\031714\datafile001-01.nev';
spikes = buildSpikes2(filename,'',[],buildoptions); spikes = filtspikes(spikes,0,{'Unit',@(x) ~ismember(x,[0 255])}); % concatenate

spikes.Analysis.EUPlusLabel =           ...
{
   52 1  'dirty FS';
}
saveSpikes(spikes)
%% 052714
filename =  'E:\Bass\ephys\copy\052714\datafile001-01.nev';
spikes = buildSpikes2(filename,'',[],buildoptions); spikes = filtspikes(spikes,0,{'Unit',@(x) ~ismember(x,[0 255])}); % concatenate

spikes.Analysis.EUPlusLabel =           ...
{
   52 1  'dirty FS';
}
saveSpikes(spikes)
%% 052914 all bonsai files missing no video
filename =  'E:\Bass\ephys\copy\052914\datafile003-01.nev';
spikes = buildSpikes2(filename,'',[],buildoptions); spikes = filtspikes(spikes,0,{'Unit',@(x) ~ismember(x,[0 255])}); % concatenate

spikes.Analysis.EUPlusLabel =           ...
{
   52 1  'multiunit FS';
   54 1  'good';
   64 1  'multiunit FS';
}
saveSpikes(spikes)
%% 053014
filename =  'E:\Bass\ephys\copy\053014\datafile004-01.nev';
spikes = buildSpikes2(filename,'',[],buildoptions); spikes = filtspikes(spikes,0,{'Unit',@(x) ~ismember(x,[0 255])}); % concatenate

spikes.Analysis.EUPlusLabel =           ...
{
   52 1  'multiunit FS';
   54 1  'ok';
   64 1  'multiunit FS';
}
saveSpikes(spikes)
%% 060214 1 (crappy performance, stimulatino each trial)
filename =  'E:\Bass\ephys\copy\060214\datafile001-02.nev';
spikes = buildSpikes2(filename,'',[],buildoptions); spikes = filtspikes(spikes,0,{'Unit',@(x) ~ismember(x,[0 255])}); % concatenate
spikes.Analysis.EUPlusLabel =           ...
{
   52 1  'multiunit FS';
   54 1  'ok';
   64 1  'multiunit FS';
};
saveSpikes(spikes)
%% 060214 2 (crappy performance,
filename =  'E:\Bass\ephys\copy\060214\datafile002-03.nev';
spikes = buildSpikes2(filename,'',[],buildoptions); spikes = filtspikes(spikes,0,{'Unit',@(x) ~ismember(x,[0 255])}); % concatenate
spikes.Analysis.EUPlusLabel =           ...
{
   52 1  'ok FS';
   54 1  'ok';
   54 2  'dirty';
   64 1  'ok FS';
};saveSpikes(spikes)
%% 060314
filename =  'E:\Bass\ephys\copy\060314\datafile001-01.nev';
spikes = buildSpikes2(filename,'',[],buildoptions); spikes = filtspikes(spikes,0,{'Unit',@(x) ~ismember(x,[0 255])}); % concatenate
spikes.Analysis.EUPlusLabel =           ...
{
   52 1  'ok FS';
   54 1  'ok';
   64 1  'ok FS';
};saveSpikes(spikes)
%% 060414
filename =  'E:\Bass\ephys\copy\060414\datafile002-01.nev';
spikes = buildSpikes2(filename,'',[],buildoptions); spikes = filtspikes(spikes,0,{'Unit',@(x) ~ismember(x,[0 255])}); % concatenate
spikes.Analysis.EUPlusLabel =           ...
{
   52 1  'ok FS';
   54 1  'dirty';
   64 1  'ok FS';
};saveSpikes(spikes)
%% 060514
filename =  'E:\Bass\ephys\copy\060514\datafile003-02.nev';
spikes = buildSpikes2(filename,'',[],buildoptions); spikes = filtspikes(spikes,0,{'Unit',@(x) ~ismember(x,[0 255])}); % concatenate
spikes.Analysis.EUPlusLabel =           ...
{
   52 1  'dirty FS';
   64 1  'multiunit';
};saveSpikes(spikes)
%% 060614 No video data Bonsai files empty
filename =  'E:\Bass\ephys\copy\060614\datafile001-02.nev';
spikes = buildSpikes2(filename,'',[],buildoptions); spikes = filtspikes(spikes,0,{'Unit',@(x) ~ismember(x,[0 255])}); % concatenate
spikes.Analysis.EUPlusLabel =           ...
{
   52 1  'dirty FS';
   52 2  'ok FS';
   64 1  'multiunit FS';
};saveSpikes(spikes)

% %%
% p = '/Volumes/Masa/Bass/ephys/copy';
% p = 'C:\Users\Behave\Dropbox\PatonLab\Paton Lab\Data\TAFCmice\Ephys\InTask\Analysis\SertxChR2_179';
% filename =  'E:\Bass\ephys\copy\022514\datafile001-02.nev';
% spikes  = buildSpikes2(filename,'',[],buildoptions); spikes = filtspikes(spikes,0,{'Unit',@(x) ~ismember(x,[0 255])});
% filename =  'E:\Bass\ephys\copy\022614\datafile001-01.nev';
% spikes = buildSpikes2(filename,'',spikes,buildoptions); spikes = filtspikes(spikes,0,{'Unit',@(x) ~ismember(x,[0 255])}); % concatenate
% filename =  'E:\Bass\ephys\copy\022714\datafile002-01.nev';
% spikes = buildSpikes2(filename,'',spikes,buildoptions); spikes = filtspikes(spikes,0,{'Unit',@(x) ~ismember(x,[0 255])}); % concatenate
% filename =  'E:\Bass\ephys\copy\022714\datafile002-01.nev';
% spikes = buildSpikes2(filename,'',spikes,buildoptions); spikes = filtspikes(spikes,0,{'Unit',@(x) ~ismember(x,[0 255])}); % concatenate
% filename =  'E:\Bass\ephys\copy\022814\datafile002-02.nev';
% spikes = buildSpikes2(filename,'',spikes,buildoptions); spikes = filtspikes(spikes,0,{'Unit',@(x) ~ismember(x,[0 255])}); % concatenate
% 
% % Some how the 0225-28 is fucked up have to remake
% spikes = filtspikes(spikes,0,{'Unit', @(x) ~ismember(x,[0 255])}) ;% only include sorted units
% savefile = fullfile(p,'Spikes0225-27.mat');
% %save(savefile,'spikes','-v7.3')
% load(savefile)
% 
% EU = [ 43 1 ;...
%     39 1;...
%     37 2];
% make function that plots aligned on X all stimuli on the same plot

