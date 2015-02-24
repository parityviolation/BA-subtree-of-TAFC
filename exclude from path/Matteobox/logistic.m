function [yy,xx] = logistic(pars,xx) 
%LOGISTIC a logistic function
% 
% yy = logistic([mu s],xx)
% 
% mu = location, s = scale
%
% part of the Matteobox toolbox
%
% 2009-08-28 Andrew Zaharia

if length(pars)==2
	mu	  = pars(1);
	s    = pars(2);
else
	error('logistic.m requires 2 parameters.');
end

yy = 1 ./ ( 1 + exp(-(xx - mu)/s) );