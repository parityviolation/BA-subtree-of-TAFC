function bTTL = loadTDThelper_getTTL(blkPATH,EPOCNAME,EPOCNAMELIGHT,bsave,bsuppresserror)
% function bLight = loadTDThelper_getTTL(blkPATH,EPOCNAME,EPOCNAMELIGHT,bsave)
% find EPOCNAME epocs when TTL transitioned to high
filename = loadTDThelper_makefilename(blkPATH);

if nargin<2 || isempty(EPOCNAME); EPOCNAME = 'Vcod'; end;
if nargin<3 || isempty(EPOCNAMELIGHT); EPOCNAMELIGHT = 'Ligh'; end;
if nargin <4; bsave = 1; end
if nargin <5; bsuppresserror = 0; end

if isempty(dir(fullfile(blkPATH,[filename '_' EPOCNAMELIGHT 'Cond.*'])))
    temp = loadTDThelper_getEpocVal(blkPATH,EPOCNAME,bsuppresserror);
    try
        tempL = loadTDThelper_getEpocVal(blkPATH,EPOCNAMELIGHT,bsuppresserror);
    catch
        tempL = nan;
    end
    if isnan(temp)
        error('No Epocs exist')
    else
        temp = temp([2 3],:);
        bTTL = zeros(1,size(temp,2));
        if ~isnan(tempL)
            tempL = tempL([2 3],:);
            lenVstim = min(diff(temp(:,1:end-1))); % length of Vstim Epoc
            % skip last sweep it is possible that last TTL never went low
            for i = 1:size(temp,2)
                D = tempL(1,:) - temp(1,i);
                if any(D>0 & D<lenVstim) % find cases where TTL goes high during a Vstim
                    bTTL(i) = 1;
                end
            end
            if bsave;                save(fullfile(blkPATH,[filename,'_' EPOCNAMELIGHT 'Cond']),'bTTL');    end
        end
    end
else
    filename = regexprep(filename,'%%','%%%'); % to support % in filename
    a = load(fullfile(blkPATH,sprintf('%s_%sCond',filename,EPOCNAMELIGHT)));
    FN = fieldnames(a); % so that code is independent of the name
    bTTL = a.(FN{1});  
    if size(bTTL,1)==2 % for compatibility with case where bTTL has 2 rows the first is the time and the 2nd the TTL condition
        bTTL = bTTL(2,:);
    end
        bTTL = bTTL(~isnan(bTTL));

end