function nargoutchk(minargs, maxargs)
 
  if (nargin ~= 2)
    error('%s: Usage: narginchk(minargs, maxargs)',upper(mfilename));
  elseif (~isnumeric (minargs) || ~isscalar (minargs))
    error ('minargs must be a numeric scalar');
  elseif (~isnumeric (maxargs) || ~isscalar (maxargs))
    error ('maxargs must be a numeric scalar');
  elseif (minargs > maxargs)
    error ('minargs cannot be larger than maxargs')
  end
 
 
  args = evalin ('caller', 'nargout;');
 
 
  if (args < minargs)
    error ('not enough output arguments');
  elseif (args > maxargs)
    error ('too many output arguments');
  end
 
end