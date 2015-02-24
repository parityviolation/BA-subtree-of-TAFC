function [filterdata dt data] =  preprocessDAQ(LOADPATH,STF,chns,filtparam,bNoLoad)
% function [filterdata dt data(unfiltered)] =  preprocessDAQ(LOADPATH,STF,chns,filtparam,bNoLoad);
%
% LOADPATH - (optional) will use defualt DAQSAVEPATH if empty
% STF - struct must have .filename, must have length 1, may have .MAXTRIGGER
%    if filename is from a tdt acquistion then
%           % STF must contain fields
%           .filename (block name)  remember it should start with a tilda
%           .tdt.tank
%           better way to
% chn - vector of chns to load
% filtparam
% .dfilter (required)
% .subsample (optional)
% .maxlevel (optional) for HP wavelet filter where HP = (1/dt)/(2^(filtparam.maxlevel+1))
% .filttype (optional) used by prepdata to choose kind of filter
% bNoLoad (optiona) force data to be reloaded even if same file was
% previously filted with same parameters

cleanHz = 50;
% check input parameters right and set defaults
if length(STF)>1 ; error('only one DAQfile at a time can be processed by this function'); end

if ~isfield(filtparam,'dfilter')
    filtparam.dfilter = [NaN NaN cleanHz 0];
    %     error('filtparam.dfilter must be specified as follows: [LOW HIGH linfreq bremovelinefreq]')
end
if ~isfield(filtparam,'maxlevel') % default no wavelet HP filter
    filtparam.maxlevel = [];
end
if ~isfield(filtparam,'subsample') % default no subsampling
    filtparam.subsample = 1;
end
if ~exist('bNoLoad','var') || isempty(bNoLoad); bNoLoad = 0; end

flagClean60Hz = []; % Set to empty if you want a subset of the data to be tested for 60HZ
bChopUpData = 1;% because arrays get too big and wavefilter chokes
ARBLIMIT = 1*32e3;

RigDef = bRigdefs;
DAQSAVEPATH =RigDef.Dir.EphysData ;DAQFILTEREDSAVEPATH=RigDef.Dir.EphysDataFilt;
if isempty(LOADPATH);LOADPATH = DAQSAVEPATH; end                                    % only used for DAQ not for TDT


SAVEPATHFILTERED = DAQFILTEREDSAVEPATH;


typ = 'nidaq';
if isfield(STF,'tdt')
    typ = 'tdt';
else
    
    [path fn ext] = fileparts(STF.filename);
    if isequal('.ns6',ext)
        typ = 'cerebus';
    end
end

STF.filename = seperateFileExtension(STF.filename); % remove extension

if isequal(typ,'tdt');                                                              % name for saving/loading filterdata
    tempfilename = loadTDThelper_makefilename(fullfile(DAQSAVEPATH,STF.tdt.tank,STF.tdt.blk));
    %   tempfilename = loadTDThelper_makefilename([STF.tdt.tank '\' STF.tdt.blk]);
else tempfilename = STF.filename; end
i = 0;
for ichn =   chns
    i = i+1; % index for tempdata
    % look for previously saved data with same filters
    filterfilename  = fullfile(SAVEPATHFILTERED,sprintf('%s_DAQchn%sfilt%sHP%dsubsample%d',tempfilename,strrep(num2str(ichn),'  ','_'), regexprep(num2str(filtparam.dfilter),'\s*','_'),filtparam.maxlevel,filtparam.subsample));
    
    if ~isempty(dir([filterfilename '.mat']))&& ~bNoLoad     & nargout>0                          % check if these data have been filtered already
        load(filterfilename);
        tempdata{i} = filterdata;
        params = filtparam;
        if ~isempty(comp_struct(params,filtparam,[],[],[],[],0));
            warning('Loaded file params do NOT match params. So the way savefilename is names should be changed to fix this.')
        end
        
        if ~isempty(filtparam.maxlevel);                  HPFILTER = (1/dt)/(2^(filtparam.maxlevel+1));      sprintf('%s Wavelet HIGH-PASS Filter: %s Hz',num2str(HPFILTER));            end
        fprintf('%s Channel %d previously filtered data loaded... dfilter: %s\n', getFilename(tempfilename), ichn, num2str(filtparam.dfilter))   ;
        
    else
        [data dt] = loaddatahelper(LOADPATH,STF,ichn,typ);
        if ~isempty(filtparam.subsample) && filtparam.subsample~=1
            dt = dt*filtparam.subsample;
            data = data(1:filtparam.subsample:end,:,:);
        end
        [numpoints, numsweeps, numwires] = size(data);
        dataclass = class(data);
        bChopped = 0; % flag set to 1 if data gets chopped
        if bChopUpData % transform into chopped form (later transform back)
            if numpoints >  ARBLIMIT% arb limit
                if numsweeps ==1 % only reshaping if there is just 1 sweep
                    bChopped =1;
                    for ii =1:numwires
                        realnumpoints = numpoints;
                        numsweeps =ceil(numpoints/ARBLIMIT);
                        
                        if ii==1; tempd = zeros(ARBLIMIT,numsweeps,numwires,class(data)); end
                        temp = data(:,:,ii);
                        temp = [temp(:); temp(end)*ones(numsweeps*ARBLIMIT-numpoints,1)];
                        tempd(:,:,ii) = reshape(temp,ARBLIMIT,numsweeps,1);
                    end
                    data = tempd;
                    clear tempd;
                end
            end
        end
        
        %%% test if need to remove 60Hz
        if 0
            if isempty(flagClean60Hz)||flagClean60Hz==1
                prepdata(squeeze(data(1:min(1/dt,end),1,1)),1,dt,[NaN,NaN,cleanHz 1]);
                flagClean60Hz = 0;
                if 0 % if you want a dialog to popup each time and ask whether to clean 60Hz
                    button = questdlg('Clean 60Hz?','Filtering',...
                        'Yes','No to All','Yes to All','No to All');
                    if strcmp(button,'Yes')
                        flagClean60Hz = 1;
                    elseif strcmp(button,'No to All')
                        flagClean60Hz = 0;
                    elseif strcmp(button,'Yes to All')
                        flagClean60Hz = 2;
                    end
                end
                if flagClean60Hz; bCLEAN60HZ=1; else bCLEAN60HZ=0; end
            end
        else bCLEAN60HZ = 0;
        end
        
        if bCLEAN60HZ
            
            filtparam.dfilter([3 4]) = [cleanHz 1]; clear filterdata;
            display(['Cleaning ' 'Hz'])
        else
            filtparam.dfilter([3 4])  = [0 1];
        end
        %     tic
        if any(size(data)==1)%     don't squeez unless necessary (because take lots of memory)
            filterdata = prepdata(squeeze(data(:,:,:)),0,dt,filtparam);
        elseif length(size(data))==3
            filterdata = prepdata(data(:,:,:),0,dt,filtparam);
        elseif  length(size(data))==2
            filterdata = prepdata(data,0,dt,filtparam);
        end
            
            
        %     toc
        %     for ii =1 : size(data,3)
        %         filterdata(:,:,ii) = prepdata(squeeze(data(:,:,ii))',0,dt,filtparam)';
        %     end
        if nargout<3; clear data; end
        
        if ~isempty(filtparam.maxlevel)
            HPFILTER = (1/dt)/(2^(filtparam.maxlevel+1));
            display(['Wavelet HIGH-PASS Filter: ' num2str(HPFILTER) ' Hz'])
            filterdata = wavefilter(filterdata(:,:,:),filtparam.maxlevel);
        end
        if bChopped % transform back to correct form if chopped up
            for ii =1:numwires
                if ii==1; tempd = zeros(realnumpoints,1,numwires,dataclass); end
                temp = filterdata(:,:,ii);
                tempd(:,1,ii) = temp(1:realnumpoints);
            end
            filterdata = tempd;
            clear tempd;
        end
        if numsweeps==1 % for case of only 1 file make 3D to be compatible
            filterdata  = permute(filterdata, [1,3,2] );
        end
        [pth fn ext] = fileparts(filterfilename);
        parentfolder(pth,1)
        filterdata = single(filterdata);
        save(filterfilename,'filterdata','filtparam','dt','-v7.3');
        tempdata{i} = filterdata; clear filterdata;

    end
end

% concatenate seperately loaded channels into one variable
[nsamples ntriggers] = size(tempdata{1});
filterdata = cell2mat(tempdata);
clear tempdata;
filterdata = reshape(filterdata,[nsamples ntriggers size(filterdata,2)/ntriggers]); % reformat as samples x triggers x channels


if nargout>=3 && ~exist('data','var')% if data doesn't exist and is requested
    [data dt] = loaddatahelper(LOADPATH,STF,chns,typ);
end

function [data dt] = loaddatahelper(LOADPATH,STF,chns,typ)



switch typ
    case 'cerebus'
        LOADFILE = fullfile(LOADPATH,[STF.filename '.ns6']);
        d = loadedata(LOADFILE,chns,[0 600]);
        dt = d.dt;
        data = single(d.Data)';
        clear d;
        
    case 'nidaq'
        LOADFILE = fullfile(LOADPATH,STF.filename);
        if isfield(STF,'MAXTRIGGER')
            if length(STF.MAXTRIGGER)==1 && STF.MAXTRIGGER>1;TrigRange = [1 STF.MAXTRIGGER];
            else TrigRange = STF.MAXTRIGGER; end
            [data dt] = loadDAQData(LOADFILE,chns,TrigRange);
            %             data = data*1000;
        else
            [data dt] = loadDAQData(LOADFILE,chns);
        end
        
    case 'tdt'
        if isfield(STF,'MAXTRIGGER')
            if ~isempty(STF.MAXTRIGGER)
                diplay('Loading tdt data is not currently compatible with MAXTRIGGER')
            end
        end
        
        [data dt] = loadTDTData(STF,chns);
end
