function d = degdiff(d1,d2,circledeg)
% DEGDIFF difference in degrees between two angles
%
% d = degdiff(d1,d2), where d1 and d2 are in degrees. Differences are
% between -180 and 180.
%
% d = degdiff(d1,d2,180), indicates that you want to be on the half circle
% (get answers between -90 and 90)
%
% 1999 Matteo Carandini
% 2009-12 MC added the 180 thing
%
% part of the Matteobox toolbox

if nargin < 3
    circledeg = 360;
end

if circledeg == 180
    d1 = 2*d1;
    d2 = 2*d2;
end

d = 180/pi*angle(exp(1i*(d1-d2)*pi/180));

if circledeg == 180
    d = d/2;
end
