function expt = analysis_def(expt)
% function expt = analysis_def(expt)
%   Sets default fields and values for SRO's analysis struct
%
%
%

% Created: 5/23/10 - SRO


% --- Set fields for all analysis types
% analysisType = {'orientation','contrast','srf'};
% field = {'fileInd','stim','cond','w'};
% for i = 1:length(analysisType)
%     for k = 1:length(field)
%         expt.analysis.(analysisType{i}).(field{k}) = [];
%     end
% end
% 
% % --- Set stim fields
% analysisType = {'orientation','contrast','srf'};
% field = {'values','code'};
% for i = 1:length(analysisType)
%     for k = 1:length(field)
%         expt.analysis.(analysisType{i}).stim.(field{k}) = [];
%     end
% end
% 
% % --- Set cond fields
% analysisType = {'orientation','contrast','srf'};
% field = {'type','values','tags','color'};
% for i = 1:length(analysisType)
%     for k = 1:length(field)
%         expt.analysis.(analysisType{i}).cond.(field{k}) = [];
%     end
% end
% 
% 
% % --- Default windows (in seconds)
% % Orientation
% expt.analysis.orientation.duration = 3;
% w.spont = [0 0.5];
% w.stim = [1 2.5];
% w.on = [0.5 1];
% w.off = [3 3.5];
% expt.analysis.orientation.vstimpresent = [0.5 3];
% 
% expt.analysis.orientation.windows = w;


%
expt.analysis.orientation.cond.type = 'led';

if 1% ignor amplitude % NEED to change setting in Orientation figure (TO DO find better solution)
    expt.analysis.orientation.cond.values = {0 1};
    expt.analysis.orientation.cond.tags = {'off','on'};
    
elseif 1
%      cond = unique(roundn(expt.sweeps.led,-2));
    expt.analysis.orientation.cond.values = {0 0.1 5 };
    expt.analysis.orientation.cond.tags = {'a0','a01','a5'};
else
        expt.analysis.orientation.cond.values = {[0 1]};
    expt.analysis.orientation.cond.tags = {'all'};

    %     cond = {0 0.05 0.08 0.1 0.15 0.2 .25 .5 1 2};
%     expt.analysis.orientation.cond.tags = {'a0','a05','a08','a1','a15','a20','a25','a50','a100','a200'};
    
end

% 
% % % Spatial
% % expt.analysis.spatial.duration = 2.6;
% % w.spont = [0 0.25];
% % w.stim = [0.255 1.75];
% % w.on = [0.25 0.75];
% % w.off = [2 2.6];
% % expt.analysis.spatial.windows = w;
% %
% % Contrast
% expt.analysis.contrast.duration = 3;
% w.spont = [0 0.5];
% w.stim = [0.5 2.5];
% w.on = [0.5 1];
% w.off = [3 3.5];
% expt.analysis.contrast.vstimpresent = [0.5 3];
% 
% expt.analysis.contrast.windows = w;
% % 
% % expt.analysis.contrast.cond.type = 'led';
if 1
    expt.analysis.contrast.cond.values = {0 1};
    expt.analysis.contrast.cond.tags = {'off','on'};
%     expt.analysis.contrast.cond.values = {0};
%     expt.analysis.contrast.cond.tags = {'off'};
else % multiple amplitudes
%     expt.analysis.contrast.cond.values = {0 0.2};
%     expt.analysis.contrast.cond.tags = {'off','on'};
    expt.analysis.contrast.cond.values = {0 0.05};
    expt.analysis.contrast.cond.tags = {'off','on'};

%     expt.analysis.contrast.cond.values = {0 0.5 1};
%     expt.analysis.contrast.cond.tags = {'off','on05','on15'};

end


