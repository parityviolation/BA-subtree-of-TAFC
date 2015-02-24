function rr = ThreshLinear(pars,vv)
% ZeroThenLinear is zero up to a threshold, then it is linear
%
% rr = ThreshLinear([thresh slope],vv)
%
% 2011-06 Matteo Carandini recreated for the n-th time


[thresh slope] = vecdeal(pars);

rr = slope*(vv-thresh);
rr(vv<thresh) = 0;


