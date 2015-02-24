function [rr, ss] = GaussNoiseRate(vv, vsigma, k)
% GaussNoiseRate firing rate model based on potential and gaussian noise
%
% rr = GaussNoiseRate(vv, vsigma) returns rectified firing rates
%
% rr = GaussNoiseRate(vv, vsigma, k) applies a scaling factor k to the firing rates
%
% [rr, ss] = GaussNoiseRate(vv, vsigma) also returns the standard deviation of the firing rates
% 
% Example:
%
% vsigma = 4;
% vv = [-20:20];
% [rr, ss] = GaussNoiseRate(vv, vsigma);
% figure; 
% fillplot( vv, rr-ss, rr+ss, [0.8 0.8 0.8] ); hold on
% plot(vv,rr, 'k');
% xlabel('Voltage');
% ylabel('Firing rate');
% title(sprintf('Sigma = %d',vsigma));

if nargin < 3
   k = 1;
end

threshold = 0;
nv = length(vv(:));

if vsigma == 0
    rr = vv;
    rr(rr<threshold) = 0;
    ss = zeros(size(rr));
    return;
end

vspan = linspace(-5*vsigma,5*vsigma,100);
pdist = exp(-vspan.^2/(2*vsigma.^2));
pdist = pdist/sum(pdist);

rr = zeros(size(vv)); ss = zeros(size(vv));
for iv = 1:nv
    vmean = vv(iv);
    vdist = vmean+vspan;
    ii = vdist > threshold;
    rmean = sum( vdist(ii).*pdist(ii) );
    rr(iv) = k*rmean;
    %rvar = sum ( pdist(ii) .* ((vdist(ii) - rmean).^2) ); % variance of weighted sum
    rvar = 1/(1-sum(pdist(ii).^2)) * sum ( pdist(ii) .* ((vdist(ii) - rmean).^2) ); % unbiased estimate of population variance of weighted sum
    
    ss(iv) = sqrt(rvar);
end


