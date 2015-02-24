function [thisSession_roc thisSession_Area thisSession_H thisSession_Electrode thisSession_datenum]...
    = plotROC_spikes(spikes,condset)


%% 
 
fd = fieldnames(roc)
fd = fd(~ismember(fd,{'all_roc','condset'}));
ncell =  length(roc(1,1).all_Area)
ncond  = 2;
nstep = size(roc,2);

% predefine
for ifd = 1:length(fd)
    fld = fd{ifd}
    eval(['all_' fld ' =  nan([' num2str([ncond nstep ncell]) ']);'])
    for icond = 1:ncond
        for istep = 1:nstep
            eval(['all_' fld '(' num2str(icond) ',' num2str(istep) ',:) = roc(' num2str(icond) ',' num2str(istep) ').' fld ';'])
        end
    end
end

