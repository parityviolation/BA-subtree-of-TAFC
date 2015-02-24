function plotset(nsetup,fid)
% function plotset(nsetup,fid)
% setup plot according to config predefined nsetup
% dirc holding config files:
if exist('fid','var')
    if ~isempty(fid)
        figure(fid);
    end
else fid = gca; end

switch (nsetup)
    case 1
        set(fid,'Box','off','color','none')
end

% global DPATH
% % if ~exist('dpath')
% % %     dpath = '/Volumes/MatlabCode/DEFINE/';
% %     dpath = 'C:\Documents and Settings\Bassam\My Documents\Scanziani Lab\MatLab\DEFINE\';
% % end
% sfn = ['c_plotsetup_' num2str(nsetup)];
% 
% run([DPATH sfn]);
