function m = mode_guesser(x,p)

    if nargin < 2, p = .1; end
    
    num_samples = length(x);
    shift = round( num_samples * p );
    
    x = sort(x);
    [val,m_spot] = min( x(shift+1:end) - x(1:end-shift) );
    
    m = x( round(m_spot + (shift/2)) );