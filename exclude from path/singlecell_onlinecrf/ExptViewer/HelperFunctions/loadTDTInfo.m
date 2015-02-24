function [triggers sweeplength Fs varparam param paramsfile] = loadTDTInfo(blkpath)
% function [triggers sweeplength Fs varparam param paramsfile] = loadTDTInfo(blkpath)
%
% INPUT blkpath the fullpath of block directory
%
% Desc: gets acquisition parameters, and creates Files with Stimulus
% parameters _SFile _TrigCond (puts them in the block directory)

EPOCNAME = 'Vcod';
% EPOCNAME = 'Tick';
WAVEDATANAME = 'Rawd';
MAXEPOCS = 10000;

ind = strfind(blkpath,'\');ind = ind(end);
if isempty(ind); error('TDT tank and block must both be included'); end
tank = blkpath(1:ind-1);
blk = blkpath(ind+1:end);  

if isempty(regexp(blk,'~'));  blk = ['~' blk]; end% remember it should start with a tilda else TDT won't index based on each epoc star

temp = dirc([blkpath '\*.Tdx']);
filename = temp{2};
[sweeplength varparam param paramsfile]  = helpGetsweeplength(blkpath,filename); % 

TT = actxcontrol('TTank.X');
invoke(TT,'ConnectServer','Local','Me');
e=invoke(TT,'OpenTank',tank,'R');% this should all have error checking but I have left it out.
e1=invoke(TT,'SelectBlock',blk);% this should all have error checking but I have left it out.
  
if e1+e==2 % basic error checking
    
    invoke(TT,'ReadEventsV',100,'Rawd',0,0,0,0,'ALL');
    Fs = invoke(TT,'ParseEvInfoV',0,1,9);% Gets the sampling rate for that event % =24414.062500;
    
    %the part above is self explanatory
    invoke(TT,'ResetFilters');
    TT.CreateEpocIndexing;
    TT.SetGlobalV('RespectOffsetEpoc',0); % else will not include events that occured with "sweeplength of onset" but after offset
    
    temp =invoke(TT,'GetEpocsV',EPOCNAME,0,0,MAXEPOCS); % Returns the Epoc events for Trigger returns a NaN event in this case
    % get VstimConditions
    if isnan(temp); error('no TDT epocs found'); end
    if isempty(dir(fullfile(blkpath,[filename '_TrigCond.*'])));
        cond.data = temp([2 1],:);
        % save a file with the conditions of each sweep to be compatible with DAQ
        % version of acquisition
        save(fullfile(blkpath,sprintf([filename,'_TrigCond'])),'-struct','cond','data');
    end
    % check that sweeplength is not longer than Epocs (this code is not
    % necessary to extract data from TT, just for error checking
    temp2 = min(diff(temp(2,:)));
    if sweeplength > temp2;
        error(sprintf('************************** sweeplength cannot exceed time to next Epoc: %1.3f ****************',temp2))
        %         sweeplength = temp2;
    end
     
        % read
    Filt = invoke(TT,'SetepocTimeFilterV', EPOCNAME,0,sweeplength);% Sets the Time filter so that the Epoc event occurs in the
    if ~Filt;        error('Error creating tdt time filter'); end
    % of the sequence.
    tranges = invoke (TT, 'GetValidTimeRangesV');% Gets the start and end of the Time ranges.
    
    triggers = size(tranges,2);
end


end
function [sweeplength varparam param paramsfile]  = helpGetsweeplength(blkpath,filename)
    %% create <filename>_SFile.mat with information about where to get
% Vstimulus param file
RigDef = RigDefs;
sfile = fullfile(blkpath,[filename '_SFile.*']);
if isempty(dir(sfile))
    bsave = 1;
    sfilename = sprintf('%s.Tdx',filename);
else
    bsave = 0;
    sfilename =filename;
end
[varparam param params.sfilename] = getPsychStimParameters(sfilename,blkpath,RigDef.Dir.VStimLog);
params.condName  = param.StimulusName;
% get sweeplength form Vstim Info
sweeplength = param.StimDuration;
if param.blankbkgrnd; sweeplength = sweeplength + param.Baseline ; end
params.sweeplength = sweeplength;
if bsave;    save(fullfile(blkpath,[filename '_SFile']),'params'); end

paramsfile = params.sfilename;
end

