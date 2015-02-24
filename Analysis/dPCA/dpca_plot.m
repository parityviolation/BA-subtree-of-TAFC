function dpca_plot(Xfull, W, V, combinedParams, whichMarg, ...
    time, events, Ysize, componentsSignif, legendSubplot, Xfull_extra, ...
    margNames, plotFunction)

numCompToShow = 15;
numCompToShow = min(numCompToShow, size(W,2));

X = Xfull(:,:)';
Xcen = bsxfun(@minus, X, mean(X));
XfullCen = bsxfun(@minus, Xfull, mean(X)');
N = size(X, 1);
dataDim = size(Xfull);

Z = Xcen * W;

% Decompose variance
totalvar = sum(sum(Xcen.^2)) / N;
explVar = sum(Z.^2)/N / totalvar * 100;
Xmargs = marginalize(XfullCen, combinedParams);
for i=1:length(Xmargs)
    varDecomp(i,:) = sum((Xmargs{i}(:,:)' * W).^2) / size(Xmargs{i}(:,:),2);
end

timeComp = [];
for k = 1:length(combinedParams)
    if combinedParams{k}{1} == length(size(Xfull))-1
        timeComp = k;
        break
    end
end

if length(size(Xfull))==4
    ind = [3 1 2 4];
    
    componentsToPlot = [];
    subplots = [];
    for i=1:length(ind);
        if ~isempty(componentsSignif) && ind(i) ~= timeComp
            moreComponents = find(whichMarg == ind(i) & sum(componentsSignif, 2)'~=0, 3);
        else
            moreComponents = find(whichMarg == ind(i), 3);
        end
        componentsToPlot = [componentsToPlot moreComponents];
        subplots = [subplots (i-1)*5+3:(i-1)*5+3 + length(moreComponents) - 1];
    end
else
    componentsToPlot = 1:12;
    subplots = [3 4 5 8 9 10 13 14 15 18 19 20];
end
    
Zfull = reshape(Z(:,componentsToPlot)', [length(componentsToPlot) dataDim(2:end)]);

if ~isempty(Xfull_extra)
    XF = Xfull_extra(:,:)';
    XFcen = bsxfun(@minus, XF, mean(X));%nanmean(XF));
    ZF = XFcen * W;
    dataDimFull = size(Xfull_extra);
    Zfull = reshape(ZF(:,componentsToPlot)', [length(componentsToPlot) dataDimFull(2:end)]);
end

% plot individual components using provided function
figure 
for c = 1:length(componentsToPlot)
    cc = componentsToPlot(c);
    subplot(4, 5, subplots(c))
    
    if ~isempty(componentsSignif)
        signifTrace = componentsSignif(cc,:);
    else
        signifTrace = [];
    end
    
    dim = size(Xfull);
    cln = {c};
    for i=2:length(dim)
        cln{i} = ':';
    end
    
    plotFunction(time, Zfull(cln{:}), Ysize(whichMarg(cc))*[-1 1], explVar(cc), cc, events, signifTrace, whichMarg(cc))
    
    if ismember(subplots(c), [3 8 13 18])
        if subplots(c) == 3
            xlabel('Time (s)')
        else
            set(gca, 'XTickLabel', [])
        end
        ylabel('Normalized firing rate (Hz)')
    else
        set(gca, 'XTickLabel', [])
        set(gca, 'YTickLabel', [])
    end
end 

if length(size(Xfull))==4
    offsetX = 0.41;
    ind = [3 1 2 4];
    yposs = [0.85 0.65 0.45 0.25];

    for m=1:4
        annotation('textarrow', offsetX*[1 1], yposs(m)*[1 1], 'string', margNames{ind(m)}, ...
            'HeadStyle','none','LineStyle', 'none', 'TextRotation',90, 'FontSize', 20, 'FontWeight', 'bold');
    end
end

% explained variance
[~,S,~] = svd(Xcen');
S = diag(S(:,1:numCompToShow));
explPCA = cumsum(S.^2'/N / totalvar * 100);

explDPCA = [];
for i=1:numCompToShow
    explDPCA(i) = 100 - sum(sum((Xcen - Z(:,1:i)*V(:,1:i)').^2))/N / totalvar * 100;    
end

axBar = subplot(4,5,[1 2 6 7]);
hold on
axis([0 numCompToShow+1 0 ceil(max(explPCA(end), explDPCA(end))/10)*10])
xlabel('Component')
ylabel('Explained variance (%)')
title('Explained variance')
b = bar(varDecomp(:,1:numCompToShow)'  / totalvar * 100, 'stacked', 'BarWidth', 0.75);

[ax, h1, h2] = plotyy(nan,nan,1:length(explPCA), [explPCA; explDPCA]);
set(h2(1), 'Color', [0 0 0], 'LineWidth', 2)
set(h2(2), 'Color', [0 0 0], 'LineStyle', '--', 'LineWidth', 2)
set(ax(1), 'Ylim', [0 (sum(varDecomp(:,1))/totalvar*100) * 1.1])
set(ax(2), 'Ylim', [0 100])
set(ax(1), 'YTick', 5:5:(sum(varDecomp(:,1))/totalvar*100) * 1.1)
set(ax(2), 'YTick', [25 50 75 100])
box(ax(1), 'off')
set(get(ax(2), 'YLabel'), 'String', 'Cumulative explained variance (%)')
set(get(ax(1), 'YLabel'), 'Color', [0 0 0])
set(ax(1), 'YColor', [0 0 0])

% n = fix(0.5*256);
% r = [(0:1:n-1)/n,ones(1,n)];
% g = [(0:n-1)/n, (n-1:-1:0)/n];
% b = [ones(1,n),(n-1:-1:0)/n];
% redBlue256 = [r(:), g(:), b(:)]; 
r = [5 48 97]/256;       %# end
w = [.95 .95 .95];    %# middle
b = [103 0 31]/256;       %# start
c1 = zeros(128,3); c2 = zeros(128,3);
for i=1:3
    c1(:,i) = linspace(r(i), w(i), 128);
    c2(:,i) = linspace(w(i), b(i), 128);
end
redBlue256 = [c1;c2];

if length(margNames) == 4
    colormap([0 1 0; 1 0 0; 0.6 0.6 0.6; 0 0 1; redBlue256; flipud(gray(128))])
    caxis([1 4+256+128])
else
    colormap([jet(length(margNames)); redBlue256; flipud(gray(128))])
    caxis([1 length(margNames)+256+128])
end

legend({margNames{:},'PCA expl variance', 'dPCA expl variance'}, 'Location', 'East');

% angles and correlations between components

a = corr(Z(:,1:numCompToShow));
b = V(:,1:numCompToShow)'*V(:,1:numCompToShow);

display(['Maximal correlation: ' num2str(max(abs(a(a<0.999))))])
display(['Minimal angle: ' num2str(acosd(max(abs(b(b<0.999)))))])

[csp, psp] = corr(V(:,1:numCompToShow), 'type', 'Spearman');
[cpr, ppr] = corr(V(:,1:numCompToShow));
map = tril(a,-1)+triu(b);

axColormap = subplot(4,5,[11 12 16 17]);
image(round(map*128)+128+length(margNames))

%axis square
%title({'Dot products between axes (upper-right)', 'Correlations between projections (lower-left)'})
xlabel('Component')
ylabel('Component')

cb = colorbar();
set(cb, 'ylim', [length(margNames)+1 260], 'YTick', [length(margNames)+1:65:260 260], 'YTickLabel', -1:0.5:1)

hold on
[i,j] = ind2sub(size(triu(b,1)), find(abs(triu(b,1)) > 3/sqrt(size(Xfull,1)) & psp<0.001 & ppr<0.001 & sign(csp)==sign(cpr)));
plot(j,i,'k*')

% [cpr, ppr] = corr(Z(:,1:numCompToShow));
% [csp, psp] = corr(Z(:,1:numCompToShow), 'type', 'Spearman');
% %[i,j] = ind2sub(size(tril(a,1)), find(abs(tril(a,-1))>0.001 & ppr<0.001));
% [i,j] = ind2sub(size(tril(a,1)), find(abs(tril(a,-1))>0.001 & psp<0.001 & ppr<0.001 & sign(csp)==sign(cpr)));
% plot(j,i,'k*')

% figure and subplot sizes

set(gcf, 'Position', [0 0 1800 1000])

pos = get(axColormap, 'Position');
width = pos(4)*1000/1800;
set(axColormap, 'Position', [pos(1) pos(2) width pos(4)])
posB = get(axBar, 'Position');
set(axBar, 'Position', [posB(1) posB(2) width posB(4)])

set(axBar, 'Xlim', [0.5 numCompToShow+0.5])
set(axBar, 'Xtick', [1 5:5:numCompToShow])
set(ax(2), 'Xlim', [0.5 numCompToShow+0.5])
set(ax(2), 'XTick', [])
set(axColormap, 'Xtick', [1 5:5:numCompToShow])
set(axColormap, 'Ytick', [1 5:5:numCompToShow])

% legend
s = subplot(4,5,legendSubplot);
delete(s)
subplot(4,5,legendSubplot)
plotFunction('legend', Xfull)

% pie
% xmarg = marginalize(Xfull, combinedParams, 'full');
% for i=1:length(xmarg)
%     varmarg(i) = sum(xmarg{i}(:).^2);
% end
% axes('position', [0.25 0.6 0.1 0.1])
% pie(varmarg)
% caxis([1 4+256+128])

