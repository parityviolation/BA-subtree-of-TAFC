% function y = Weibull(param,x)
% slope = param(1);
% thr = param(2);
% l = param(3);
% u = param(4);
function y = weibull(param,x)
slope = param(1);
thr = param(2);
l = param(3);
u = param(4);

y =  l + (u-l) .* (1 - exp(-((x ./ thr) .^ slope)));


