function [hl hp]= errorPatch(varargin)
% function [hl hp]= errorPatch(x,y,u)
% function [hl hp]= errorPatch(x,y,u,hAx)
% function [hl hp]= errorPatch(x,y,u,l)
% function [hl hp]= errorPatch(x,y,u,l,hAx,bforfig)

bDeltaError = 1; % THIS DOESN't seem to work
% BA
if nargin<2
    error('function requires x, y and at least one errorvar value')
elseif nargin==2
    x = varargin{1};
    y = varargin{2};
    u = zeros(size(y));
    l =  zeros(size(y));
    hAx = gca;
elseif nargin==3
    x = varargin{1};
    y = varargin{2};
    u = varargin{3};
    l =  varargin{3};
    hAx = gca;
elseif nargin==4
    if ishandle(varargin{4})
        x = varargin{1};
        y = varargin{2};
        u = varargin{3};
        l = varargin{3};
        hAx =  varargin{4};
    else
        x = varargin{1};
        y = varargin{2};
        u = varargin{3};
        l =  varargin{4};
        hAx = gca;
    end
elseif nargin>=5
    x = varargin{1};
    y = varargin{2};
    u = varargin{3};
    l = varargin{4};
    hAx =  varargin{5};
end

if nargin==6
    bforfig = varargin{6};
end

if ~exist('bforfig','var')
    bforfig = 0;
end


[npts,nlns] = size(x);
if (nlns == 1),  y = y(:); l = l(:); u = u(:);  end;
if (~isequal(size(x), size(y), size(u), size(l)))
    error('The sizes of X, Y, L and U must be the same.');
end



% Plot the error patches ...
hl = zeros(1,nlns);
hp = zeros(1,nlns);
for ln = 1:nlns
    hl(ln) = line(x(:,ln),y(:,ln),'Parent',hAx);
    xwrap = [x(:,ln)',fliplr(x(:,ln)')];
    if bDeltaError
        ywrap = [(y(:,ln)+u(:,ln))', flipud(y(:,ln)-l(:,ln))'];
    else
        ywrap = [(u(:,ln))', flipud(l(:,ln))'];
    end
    if bforfig
        line(x(:,ln),y(:,ln)+u(:,ln),'Parent',hAx,'color',get(hl(ln), 'Color'));
        line(x(:,ln),y(:,ln)-l(:,ln),'Parent',hAx,'color',get(hl(ln), 'Color'));
    else
        hp(ln) = patch(xwrap, ywrap, get(hl(ln), 'Color'), ...
            'EdgeColor', 'none', 'FaceAlpha', 0.25,'Parent',hAx);
    end
end
