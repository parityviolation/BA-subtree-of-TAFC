function playbeep
% http://www.h6.dion.ne.jp/~fff/old/technique/auditory/matlab.html
% cosine ramp


% prepare tone
cf = 200;                  % carrier frequency (Hz)
sf = 22050;                 % sample frequency (Hz)
d = 1.0;                    % duration (s)
n = sf * d;                 % number of samples
s = (1:n) / sf;             % sound data preparation
s = sin(2 * pi * cf * s);   % sinusoidal modulation

% prepare ramp
dr = d / 10;
nr = floor(sf * dr);
r = sin(linspace(0, pi/2, nr));
r = [r, ones(1, n - nr * 2), fliplr(r)];

% make ramped sound
s = s .* r;
sound(s, sf); 

end