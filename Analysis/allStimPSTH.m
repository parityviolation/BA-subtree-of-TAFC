function varargout = allStimPSTH(n,centers,w,hAxes)
% Computes average PSTH across all stimuli conditions for different
% conditions values for the specific condition type (e.g. condtype =
% 'led', condvalue = [0 5]).

if nargin < 4
    hAxes = axes;
end

n = mean(n,1);
n = squeeze(n);
if isvector(n)
    n = n';
end

for i = 1:size(n,2) % For number of conditions
    hLine(i) = line('XData',centers(1:end-1),'YData',n(1:end-1,i),...
    'Parent',hAxes,'LineWidth',1.5);
end

ylabel('spikes/s','FontSize',8); xlabel('seconds','FontSize',8)
ymax = setSameYmax(hAxes,15);
addStimulusBar(hAxes,[w.stim ymax]);
xlim([0 max([0.00001 centers(1:end-1)])]);

% Outputs
varargout{1} = hLine;
varargout{2} = hAxes;