function ax = gridplot(nrows, ncols, irow, icol, varargin)
% GRIDPLOT a smarter version of subplot
%
% ax = gridplot(nrows,cols) returns a matrix of axes ax
%
% ax = gridplot(nrows, ncols, irow, icol)
% places a subplot at irow, icol in a grid of nrows, ncols.
% Also takes care of the "align" flag that suddenly was required in Matlab
% version 7.
% 
% ax = gridplot(nrows, ncols, iax) figures out where you want the iplot
%
% ax = gridplot(nrows, ncols, irow, icol, 'Property1', 'value1',
% 'Property2', 'value2', ...) allows for 
%
% Part of Matteobox
% See also SUBPLOT
%
% 2005-09 Matteo Carandini
% 2007-09 MC added option to provide just 3 inputs
% 2008-06 LB added option to provide more graphics properties/value pairs
% 2009-05 MC added option to provide just 2 inputs

if nargin == 2
    ax = zeros(nrows,ncols);
    for irow = 1:nrows
        for icol = 1:ncols
            ax(irow,icol) = gridplot(nrows,ncols,irow,icol);
        end
    end
    return;
end

if isempty(irow) || isempty(icol)
    ax = NaN;
    return
end

if nargin >= 4
    if irow>nrows || icol>ncols
        error('inconsistent inputs');
    end
    iax = icol+(irow-1)*ncols;
else
    iax = irow; % the third argument
end

% actually I am not sure the instruction "version" existed before Matlab 7
% also, I am assuming the "align" hassle started with release 14.

if version('-release') >= 14
    ax = subplot( nrows, ncols, iax, 'align');
else
    ax = subplot( nrows, ncols, iax);
end
if ~isempty(varargin)
    set(ax, varargin{:});
end