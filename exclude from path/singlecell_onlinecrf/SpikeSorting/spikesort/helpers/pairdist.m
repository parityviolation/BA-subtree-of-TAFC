function dists = pairdist(X,Y,nosqrt)
%PAIRDIST          Computes a pairwise Euclidean distance matrix.
%   DISTS = PAIRDIST(X) returns a symmetric positive definite matrix DISTS
%   such that the DISTS(i,j) is the Euclidean distance between the vectors
%   X(i,:) and X(j,:).  X must be a real-valued matrix.
%
%   DISTS = PAIRDIST(X,Y), where X is an M x D matrix and Y is N x D,
%   returns an M x N matrix DISTS such that DISTS(i,j) is the Euclidean
%   distance between X(i,:) and Y(j,:).  X and Y must be real-valued.
%
%   DISTS = PAIRDIST(X,Y, 'nosqrt') returns DISTS as above, except that
%   the squared distances are returned.  The algorithm to compute the
%   distances finds the squared distances in an intermediate step, so this
%   calculation is faster than returning the Euclidean distance proper.
%

CLASS = 'double'; % BA for memory saving

% check arguments %
if nargin < 2, Y = X; end
if nargin < 3, nosqrt = 0; end

[N,D1] = size(X);
[M,D2] = size(Y);

if (D1~=D2),  error('X and Y must have the same number of columns.');  end;
    
% distance is computed 1 matrix at a time to improve memory efficiency
if isequal(class(X),'single'),    X = double(X); end %  BA sqrt results are different with singles than doubles.
if isequal(class(Y),'single'),    Y = double(Y); end % BA sqrt results are different with singles than doubles.

normsqrX = sum(X.^2,2);
normsqrY = sum(Y.^2,2);
dists = [normsqrX * ones(1,M,CLASS)];
dists = dists + [ones(N,1,CLASS) * normsqrY'];
dists = dists - (2 * X * Y');

if any(dists(:)<0) % BA there is a problem where complex dists are created because dists - (2 * X * Y'); is negative this solves it
%     warning('dists has negative values')
    if any(dists(:) <-1e-6  ) % BA set arbitrary value and set everything larger to 10
        error(sprintf('dists has ''large'' negative values %1.2g',dists(dists(:) <-1e-6) ));
    else  % if doesn't exeed arbitrary value set to zero to avoid complex numbers
        dists(dists<0) = 0; 
    end  
end
%
if ~nosqrt,  dists = sqrt(dists);  end;


