function y = nansem( x, flag, dim )
% NANSEM standard error of the mean that ignores NaNs
%
% y = nansem( x )
%
% y = nansem( x, flag ) specifies the flag to pass to nanstd
% 
% y = nansem( x, flag, dim )
%
% part of Matteobox
% 2006-09 (or earlier) MC created
% 2009-03 MC corrected (divide by sqrt(n), not by n)

if nargin<3
    dim = [];
end

if nargin<2
    flag = [];
end

n =  sum( ~isnan(x), dim );
y = nanstd( x, flag, dim ) ./ sqrt(n-1);

