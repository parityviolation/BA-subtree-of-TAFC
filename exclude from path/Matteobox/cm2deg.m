function deg = cm2deg( dist, cm)
% CM2DEG converts centimeters into degrees
%
% deg = cm2deg( dist ) tells you what 1 cm is in degrees. Dist is in cm.
%
% deg = cm2deg( dist, cm ) lets you specity how many centimeters (default: 1)
%
% SEE ALSO: deg2cm
%
% 2010-03 MC added factors of 2 so when cm->Inf it gives 180 (not 90)

if nargin<1
    error('syntax is deg = cm2deg( dist, cm)');
end

if nargin<2, cm = 1; end

% deg = atan(cm/dist)/(pi/180); until 2010-03-05

deg = 2* atan(cm/(2*dist))/(pi/180);