function [yy,xx] = psychometric(pars,xx) 
%PSYCHOMETRIC a psychometric function
% 
% yy = psychometric([gamma lambda mu s],xx)
% 
% gamma =, lamdba = lapse rate
% 
% mu = location, s = scale (logistic function)
%
% part of the Matteobox toolbox
%
% 2009-08-28 Andrew Zaharia

if length(pars)==4
	gamma  = pars(1);
	lambda = pars(2);
	mu	    = pars(3);
	s      = pars(4);
else
	error('psychometric.m requires 4 parameters.');
end

yy = gamma + ( 1 - gamma - lambda ) * logistic([mu s],xx);