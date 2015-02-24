function [x1,x2,w] = fld( spikes, c1, c2, show)

if nargin == 3, show = 1; end

% get collection of waveforms
w1 = spikes.waveforms( spikes.hierarchy.assigns == c1, :);
w2 = spikes.waveforms( spikes.hierarchy.assigns == c2, :);

% calcualte scatter matrices
S1 = cov(w1) * (size(w1,1)-1);
S2 = cov(w2) * (size(w2,1)-1);
Sw = S1 + S2;

% calculate FLD
w = inv(Sw)*( mean(w1)-mean(w2) )';

% project data
x1 = w' * w1';
x2 = w' * w2';


if show
    [n1,y1] = hist(x1,25);
    [n2,y2] = hist(x2,25);
    h1 = bar(y1,n1);
    hold on
    h2 = bar(y2,n2);
    hold off
    set(h1,'FaceColor',[0 0 1 ],'EdgeColor',[0 0 1 ])
    set(h2,'FaceColor',[1 0 0 ],'EdgeColor',[1 0 0 ])
 %   legend( ['cluster ' num2str(c1)],['cluster ' num2str(c2)])

end    