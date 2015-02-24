% save channel  as binary
temp = [filterdata filterdata];
[p n e] = fileparts(STF.filename);
savepath = fullfile(LOADPATH,'binary');
parentfolder(savepath,1)
fid = fopen(fullfile(savepath,[ '2t.bin']), 'w');
% MUST SAVE with each ROW is a CHANNEL
fwrite(fid, single(temp'), 'single');
fclose(fid);