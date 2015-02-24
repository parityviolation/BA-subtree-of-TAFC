function hax = playSTA(movieSTA,STAresult,hax,Nstd)
if ~exist('hax','var'); hax = gca; end
% STA temporal params
if ~exist('STAresult','var');
    tbin = 1; WOI = 0; totalspikes = NaN;
else
    tbin = STAresult.STAparams.tbin;
    WOI = STAresult.STAparams.WOI;
    totalspikes = STAresult.nspikes;
end
% TODO SET color axes in standard deviations
temp = double(movieSTA/std(movieSTA(:)));
cmin = min(temp(:));
cmax = max(temp(:));
clims = [cmin cmax];

% threshold
% TODO: REPLACE 
%%
for i=1: size(temp,3)
    frm = temp(:,:,i);
    % threshold above a certain threshold
    if exist('Nstd','var')
        frm(abs(frm)<Nstd) = 0;
    end
    [hax him]= plotSTA(frm,hax,clims);
    hb = colorbar;
    s = ['Nspikes:' num2str(totalspikes) ' ' num2str(i) ' ' num2str((i*tbin-WOI(1))*1000) 'ms'];
    hTitle = setTitle(hax,s);
    set(hTitle,'Color','k');
    pause(.05)
end

%% play as movie
if 0
    mvtemp = temp;
    mvtemp = mvtemp - min(mvtemp(:));
    mvtemp = mvtemp/max(mvtemp(:));
    for i=1: size(mvtemp,3)
        mov(i) = im2frame(repmat(mvtemp(:,:,i),[1 1 3]))
    end
    movie(mov,1)
end

