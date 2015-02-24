function [W,V,whichMarg,explVar] = dpca(Xfull, numComps, combinedParams, lambda)

if nargin < 2
    numComps = 10;
end

if nargin < 3
    combinedParams = [];
end    

if nargin < 4
    lambda = 50;
end

X = Xfull(:,:);
X = bsxfun(@minus, X, mean(X,2));
XfullCen = reshape(X, size(Xfull));

totalVar = sum(X(:).^2);

Xmargs = marginalize(XfullCen, combinedParams);
for i=1:length(Xmargs)
    Xmargs{i} = bsxfun(@times, Xmargs{i}, ones(size(XfullCen)));
    Xmargs{i} = Xmargs{i}(:,:);
end

%[xu, xs, xv] = svd(X);
%Xr = xs(1:lambda, 1:lambda) * xv(:,1:lambda)';
%Xr = [X totalVar*lambda*eye(size(X,1))];
decoder = [];
encoder = [];
whichMarg = [];

for i=1:length(Xmargs)
    if length(numComps) == 1
        nc = numComps;
    else
        nc = numComps(i);
    end
    
    if length(lambda) == 1
        thisLambda = lambda;
    else
        thisLambda = lambda(i);
    end
    
    if nc == 0
        continue
    end
    
    Xr = [X totalVar*thisLambda*eye(size(X,1))];
    
    %Xf = Xmargs{i};
    Xf = [Xmargs{i} zeros(size(X,1))];
    
    % matlab's recommended way
    % C = Xf/Xr;
    % [U,~,~] = svd(C*Xr);
    % U = U(:,1:nc);
    
    % fast dirty way
    C = Xf*Xr'/(Xr*Xr');
    M = C*Xr;
    [U,~,~] = eigs(M*M', nc);
    P = U;
    D = U'*C;
    
%     for c = 1:nc
%         alpha(c) = trace(P(:,c)*D(c,:)*X*Xmargs{i}') / sum(sum((P(:,c)*D(c,:)*X).^2));
%     end
%     D = diag(alpha)*D;
    
    decoder = [decoder; D];
    encoder = [encoder P];    
    whichMarg = [whichMarg i*ones(1, nc)];
end

V = encoder;
W = decoder';
%W = xu(:,1:lambda)*decoder';

toFlip = find(sum(sign(V))<0);
W(:, toFlip) = -W(:, toFlip);
V(:, toFlip) = -V(:, toFlip);

if length(numComps) == 1
    Z = W'*X;
    explVar = sum(Z.^2,2);
    [~ , order] = sort(explVar, 'descend');
    
    W = W(:, order(1:numComps));
    V = V(:, order(1:numComps));
    whichMarg = whichMarg(order(1:numComps));
end

Z = W'*X;
explVar = [];
for i=1:length(Xmargs)
    explVar(i,:) = sum((W' * Xmargs{i}(:,:)).^2, 2)';
end
totalvar = sum(sum(X.^2));
explVar = explVar / totalVar;

% display(num2str(sum(sign(V(:,1:min(15,size(V,2)))))))

