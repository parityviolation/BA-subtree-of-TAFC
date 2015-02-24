figure(100)
y = b(1:30);
x = [1:size(y)]';
p = polyfit(x,y,6);
xf = [0:0.1:size(x)]';
f = polyval(p,xf);
plot(x,y/1000,'ob',xf,f/1000,'-g')
hold on;
plot(xf(3:end),ddf,'-r')

figure(101)
plot(y)
hold all
plot(3:size(y,1),diff(diff(y)),'r')

%%% DOES NOT work don't know why
%% fits are variable
%% sum of Expontentials exp(x./-td)-exp(x./-tr);
% function fitdata = eventFit(y,riseWindow,fallWindow)
%
% const = cellstr(['tr';'td']);
ftype = fittype( 'exp(x/-td)-exp(x/-tr)','ind','x')
x = [riseWindow(1):riseWindow(2)]';
opts = fitoptions('Method','NonlinearLeastSquares','Algorithm','Gauss-Newton','Robust','on','StartPoint',[10 1])
[a gof out] = fit(x,-1*y(riseWindow(1):riseWindow(2)),ftype,opts)
% [a] = fit(x,-1*y(riseWindow(1):riseWindow(2)),ftype)

%% Naka rushton
% WHY do these two functions give very different fits?
%  nakaRushtonFun = g/(1 + (C/C50)b)
%  nakaRushtonFun = ('b(1)/(1+(X/b(2)^b(3))','X','b')
 Starting = [1 0.2 3];
 nakaRushtonFun = @(b,X) 1 - b(1)./(1+(X./b(2)).^b(3));
 
x = [0.01:0.01:1];y = nakaRushtonFun(Starting,x)

Estimates=lsqcurvefit(nakaRushtonFun,Starting,x,y)
[Estimates,R,J,COVB,MSE] =NLINFIT(x,y,nakaRushtonFun,Starting)
Estimates = real(Estimates);
% To check the fit
fx = [min(x):min(x):max(x)];
figure(3);clf;
plot(x,y,'*')
hold on
plot(fx,Estimates(1).*(fx.^Estimates(3)./(Estimates(2).^Estimates(3) + fx.^Estimates(3))) + Estimates(4),'r')

%% Sine wave
 Starting = [1 0 0];
y = a(:,1)
 x = linspace(0,330,12)';
sineFun =    @(b,X) b(1) +b(2)*sind(2*X+b(3))
Estimates=lsqcurvefit(sineFun,Starting,x,y)
figure(3);clf;
plot(x,y,'*')
hold on
step = 60; xf = linspace(0,360-(360/step),60)';
plot(xf,sineFun(Estimates,xf),'r')
%% fit 2 gaussians
 Starting = [0 1 1 45 0];
y = a(:,1)
 x = linspace(0,330,12)';
 
 % repeat
% the tuning curve was fitted as the sum of two Gaussians centered on ?pref
% (b5)
% and ?pref + ?, of different amplitudes b(2) and b(3) but equal width ? (b4),
% with a constant baseline b(1)
GaussFun =    @(b,X) b(1) +b(2)*exp(-(X-b(5)).^2/(2*b(4)^2)) +b(3)*exp(-(X-(b(5)+180)).^2/(2*b(4)^2));
Estimates=lsqcurvefit(GaussFun,Starting,x,y)
step = 60; xf = linspace(0,360-(360/step),60)';
figure(4);clf;
plot(x,y,'*')
hold on


plot(xf,GaussFun(Estimates,xf),'r')

