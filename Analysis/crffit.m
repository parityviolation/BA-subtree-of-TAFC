function dfit = crffit(x,y)

% nakaRushtonFun = 1 - g/(1 + (C/C50)^n)

try
    g=-6;
    c50=0.5;
    n=-2;
    f = fittype('g/(1+(x/c50)^n)');
    options = fitoptions(f);
    set(options,'StartPoint',[g; c50; n]);
    set(options,'Upper',[inf; 1;  inf]);
    set(options,'Lower',[-inf;  0; -inf]);
    set(options,'MaxFunEvals',10000);
    [dfit.cfun dfit.gof] = fit(x,y,f,options);
    dfit.go.squared
%     [Estimates fit.resnorm fit.res]=lsqcurvefit(nakaRushtonFun,Starting,x,y);
%     dfit.fun = nakaRushtonFun;
%     dfit.b = Estimates;
    %  fit.g = Estimates(1);
    %  fit.c50 = Estimates(2);
    %  fit.n = Estimates(3);
catch ME
    getReport(ME)
    dfit = [];
    %     fit.g = NaN;
    %     fit.c50  = NaN;
    %     fit.n = NaN;
end
% [Estimates,R,J,COVB,MSE] =NLINFIT(x,y,nakaRushtonFun,Starting)
% Estimates = real(Estimates);

% ftype = fittype( 'exp(x/-td)-exp(x/-tr)','ind','x')
% x = [riseWindow(1):riseWindow(2)]';
% opts = fitoptions('Method','NonlinearLeastSquares','Algorithm','Gauss-Newton','Robust','on','StartPoint',[10 1])
% [a gof out] = fit(x,-1*y(riseWindow(1):riseWindow(2)),ftype,opts)
