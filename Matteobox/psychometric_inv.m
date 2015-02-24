function xx = psychometric_inv(pars,yy)
%PSYCHOMETRIC_INV: Inverse of the psychometric (logistic) function
% 
% xx = psychometric_inv([gamma lambda mu s],yy)
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
	error('psychometric_inv.m requires 4 parameters.');
end

% yy = gamma + ( 1 - gamma - lambda ) * logistic([mu s],xx);
xx = mu - s*log( ( (1-gamma-lambda)./(yy-gamma) ) - 1 );