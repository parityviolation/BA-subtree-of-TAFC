function depth = getUnitDepth(expt,unitTag,maxch)
%
%
%
%

% Created: SRO - 7/7/10


% Get tetrode number and unit index from unit tag
loc = strfind(unitTag,'_');
trodeNum = str2num(unitTag(loc-1));
unitInd = str2num(unitTag(loc+1:end));

% Get probe struct
probe = expt.probe;
trodeSites = probe.trode.sites{trodeNum};
siteNum = trodeSites(maxch);
if ~isempty(probe.sitedepth)
    depth = round(probe.sitedepth(probe.channelorder == siteNum));
else
    depth = NaN;
end






