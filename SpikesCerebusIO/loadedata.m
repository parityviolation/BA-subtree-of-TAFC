function d = loadedata(filename,channels,timerange,sampleEvery)
% time range in sec
% channels = [1:4 8]
% timerange = [0 10]
% filename = 'E:\Bass\ephys\Sert_179\011814\datafile002.ns6'
bplot = 0;
bsaveAsMat = 1;
bloadFromMat = 1;
       
[PATHSTR,NAME,EXT] =fileparts (filename);

% for loading and saving matlab
sdir = fullfile(PATHSTR,'Matlab');
f = [NAME EXT];
savef= strrep(f,'.','_');
savef= fullfile(sdir,[savef num2str(channels,'_%d') '.mat']);

switch(EXT)
    case '.ns6'
        if nargin ==2 & length(channels)==1 & bloadFromMat
             if exist(savef,'file')
                load(savef)
                return
            end
        end
        
        if 1
            %        SYNTAX d = openNSx('report','read',filename,'p:short',['c:' num2str(channels)], ['t:' num2str(timerange(1)) ':' num2str(timerange(2))],'sec')
            % see User guide for NPMK  http://support.blackrockmicro.com/KB/News
            eStr = ['d = openNSx(''report'',''read'',''' filename ''',''p:short'''];
            if exist('channels','var') & ~isempty(channels)
                eStr = [eStr ',''c:' num2str(channels) '''' ] ;
            end
            if exist('timerange','var') & ~isempty(timerange)
                eStr = [eStr ',''t:' num2str(timerange(1)) ':' num2str(timerange(2)) ''',''sec'''];
            end
            if exist('sampleEvery','var') & ~isempty(sampleEvery) % subsample
                eStr = [eStr ', ''s:' num2str(sampleEvery(1)) '''' ];
            end
        end
        
        
       if exist('sampleEvery','var') & ~isempty(sampleEvery)
           d.subsample = sampleEvery;
       else
           d.subsample = NaN;
       end
       
         eStr = [eStr ');'];
        eval(eStr);
        
        d.dt = 1/d.MetaTags.SamplingFreq;
        
        if bplot
            figure
            offset = 5;
            offsetplot(d.Data',d.dt,offset)
%             plot([1:length(d.Data)]*d.dt,d.Data)
        end
        
        if bsaveAsMat
            parentfolder(sdir,1)
            save(savef,'d')
            disp(['saved ' savef ])
        end
    case '.nev'
        
        
        % CRASHES TAKES FOREVER
         
%         if exist('timerange','var') & ~isempty(timerange)
%             d = openNEV(filename,'report','uV',['t:' num2str(timerange(1)) ':' num2str(timerange(2)) '''']);
%         else
%             d = openNEV(filename,'report','uV');
%         end
    otherwise
        error('unknown file time')
end
end
