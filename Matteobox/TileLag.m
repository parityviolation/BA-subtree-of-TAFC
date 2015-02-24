function aaa = TileLag( aa, lags )
% TileLag builds a matrix from components that are increasingly lagged
%
% aaa = TileLag( aa, lags ) builds a matrix aaa by tiling aa with lag
% lags(1), then aa again with lag lags(2), etc.
%
% Very useful when doing reverse correlation.
%
% 2007 Matteo Carandini

nlags = length(lags);
[ns,nc] = size(aa);
aaa = zeros( ns, nlags*nc );
for ilag = 1:nlags
    aaa( :, (ilag-1)*nc+(1:nc) ) = circshift(aa,[lags(ilag) 0]); 
end