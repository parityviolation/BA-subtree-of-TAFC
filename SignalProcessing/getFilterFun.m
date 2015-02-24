function kernel = getFilterFun(filterlength,filttype)
%BA 052014
if nargin<2
    filttype = 'flat';
end
% filter
switch (filttype)
    case 'halfgaussian'
        % causal
        % for gaussian this is the STD,
        x = [filterlength*-3:1:filterlength*3]; % multiple by an odd number of STD makes an even number of index
        kernel =normpdf(x,0,filterlength) ; %
        
        kernel(filterlength*3+2:end) = 0;
    case 'gaussian' % noncausal
        % for gaussian this is the STD,
        x = [filterlength*-3:1:filterlength*3];
        kernel =normpdf(x,0,filterlength) ; %
        
    case 'flat' % causal
        kernel = [ones(1,filterlength) zeros(1,filterlength-1) ];
end
        
kernel = kernel/sum(kernel); % normalize because not quite normalized
% nanconv(y,kernel,'edge','1d') ;