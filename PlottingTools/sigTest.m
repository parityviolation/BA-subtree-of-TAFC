function varargout = sigTest(varargin)
% [stats] = sigTest(data,bplot,hAx,sigLevel)%
% ntotaltrials = data(1);
% ntotalvalue1 = data(2); % e.g. total n choice Left
% nvalue1 = data(3);
% ntrials = data(4) ;
% plotxvalue = data(5,icomp) ; % (only if plotting)
% BA
 
data= varargin{1};
if nargin < 2
    bplot = true;
else
    bplot = varargin{2};
end

if nargin < 3
    hAx = gca;
else
    hAx = varargin{3};
end

if nargin < 4
    sigLevel = 0.05;
else
    sigLevel = varargin{4};
end
n = size(data,2);

stats.p = NaN;
hl = [];
for icomp = 1:n
    ntotaltrials = data(1,icomp);
    ntotalvalue1 = data(2,icomp); % e.g. total n choice Left
    nvalue1 = data(3,icomp); % e.g. choice Left
    ntrials = data(4,icomp) ; 
    
    % perform Fisher Exact Test
    p = hygecdf(nvalue1,ntotaltrials,ntotalvalue1,ntrials);
%     if p > 0.5
%         p = 1-p;
%     end
    stats.p(icomp) = p;
    if bplot * size(data,1)==5
        yval = max(get(hAx,'ylim'));
        plotxvalue = data(5,icomp) ; % e.g. choice Left
        
        if stats.p(icomp) <=sigLevel
            hl(icomp) = line(plotxvalue,yval,'marker','*','Color',[1 1 1].*0.15,'MarkerSize',2);
        end
        
        
    end
end

 
varargout{1} = stats;
varargout{2} = hl;
