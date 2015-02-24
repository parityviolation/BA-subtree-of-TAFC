function [o,d,cv] = CircStats360(oo,rr)
% CircStats360 returns basic circular statistics for the 0-360 range
%
% [o,d,cv] = CircStats360(oo,rr) takes as input the orientations oo
% (between 0 and 360 deg) and the corresponding responses rr, and returns:
%
% The preferred orientation o (in degrees, between 0 and 180)
% The preferred direction d (in degrees, between 0 and 360)
% The circular variance cv (between 0 and 1)
% 
% See also CIRCSTATS, CIRCCORR.

f2 = sum( (rr(:)-mean(rr)) .* exp(2*i*oo(:)*pi/180) );
f1 = sum( (rr(:)-mean(rr)) .* exp(  i*oo(:)*pi/180) );
f0 = sum( rr(:) );

% preferred orientation
o = angle(f2)*180/pi /2;
if o<0, o= o+180; end

% preferred direction
d = angle(f1)*180/pi;
if d<0, d= d+360; end

% circular variance
cv = 1 - abs(f2)/abs(f0);

return

%% code to test the function

oo = 0:15:330;

dd = linspace(0,360,15);
ee = zeros(15,1);
ff = zeros(15,1);

Rp = 10;
Rn = 2;
Ro = 4;
sigma = 20;

for id = 1:15
    Dp = dd(id);
    rr = oritune([Dp, Rp, Rn, Ro, sigma],oo);
    % figure; plot(oo,rr,'ko-');
    [ee(id), ff(id), cv] = CircStats360(oo,rr);
end

figure; plot(dd,ee,'ko');
set(gca,'xlim',[0 360])
set(gca,'ylim',[0 180])
axis equal

figure; plot(dd,ff,'ko');
set(gca,'xlim',[0 360])
set(gca,'ylim',[0 360])
axis square

cvs = zeros(15,1);
sigmas = linspace(5,60,15);
Ro = 1;

for isigma = 1:15
    sigma = sigmas(isigma);
    rr = oritune([Dp, Rp, Rn, Ro, sigma],oo);
    [o,d,cvs(isigma)] = CircStats360(oo,rr);
    
end

figure; plot(sigmas,cvs)





    
