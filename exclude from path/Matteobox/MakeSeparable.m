function [BestCol,BestRow,BestScl,BestModel,Residual,SingValues] = MakeSeparable(MatrixIn,ShowGraphics)
% MakeSeparable finds the best separable approximation to a matrix
% 
% [BestRow,BestCol,BestScl,BestModel,Residual] = MakeSeparable(MatrixIn,ShowGraphics);
%
%This function uses singular value decomposition to obtain the best
%separable model of MatrixIn.  It returns the best row, the best column,the
%best scaling factor, the best model (bestrow*bestcol*bestscale) and the 
%residual between the best model and MatrixIn
%
%Originally called MakeBestSeparableModel
%
%Set ShowGraphics to 1 if you'd like to see some output figures.
%
% Example:
% col = normrnd(0,1,200,1);
% row = exp(-(-10:10).^2/5)+1;
% data = col*row;
% [BestRow,BestCol,BestScl,BestModel,Residual] = MakeSeparable(data,1);
%   
% 2006-03 RAF wrote it.
% 2006-05 RAF added the eigenspectrum as an output
% 2007-06 MC commented out "axes equal"
% 2009-05 MC imposed removing the grand mean first
% 2009-07 SK made it return the singular values
% 2010-05 MC removed the grand mean subtraction (user does it if they want)

if nargin<2
    ShowGraphics = 0;
end
if nargin<1
    error('MakeSeparable requires a matrix as an input.');
end

% remove the overall mean (added by MC 2009-05)
% MatrixIn = MatrixIn - mean(MatrixIn(:));

[U,S,V] = svd(MatrixIn,'econ');
BestRow = U(:,1);
BestCol = V(:,1)';
BestScl = S(1,1);
BestModel = BestRow*BestCol*BestScl;
Residual = MatrixIn - BestModel;

SingValues = nan(1, size(S,1));
for i = 1:size(S,1)
    SingValues(i) = S(i,i);
end

if ShowGraphics == 1
    %1st principal Component figure
    lims(1,:) = [min(MatrixIn(:)) max(MatrixIn(:))];
    lims(2,:) = [min(BestModel(:)) max(BestModel(:))];
    lims(3,:) = [min(Residual(:)) max(Residual(:))];
    clims = [min(lims(:,1)) max(lims(:,2))];
    figure('Color',[1 1 1]);
    subplot(1,3,1);
    imagesc(MatrixIn,clims);
    title('Original Matrix');axis tight; % axis equal;
    subplot(1,3,2);
    imagesc(BestModel,clims);
    title('Best Separable Model');axis tight; % axis equal;
    subplot(1,3,3);
    imagesc(Residual,clims);
    title('Residual');axis tight; % axis equal;
    colormap bone;
    
    %Eigenspectrum figure
    PC = linspace(1,size(S,1),size(S,1));
    for il = 1:size(S,1)
        VarAccount(il) = S(il,il)./sum(S(:));
    end
    CumAccount = cumsum(VarAccount);
    figure('Color',[1 1 1]);
    stem(PC,VarAccount);hold on;plot(PC,CumAccount,'r-');
    title('Eigenspectrum');
    xlabel('Principal Component #');
    ylabel('% Variance accounted');
    legend('Individual','Cumulative');
end

return

%------To test it.
ShowGraphics = 1;
FieldMat = repmat(linspace(0,1,50),50,1);
MatrixIn = randn(50,50)+10.*sin(2.*pi.*FieldMat);
[BestCol,BestRow,BestScl,BestModel,Residual] = MakeBestSeparableModel(MatrixIn,ShowGraphics);

