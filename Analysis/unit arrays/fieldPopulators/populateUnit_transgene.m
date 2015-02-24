function unit = populateUnit_transgene(unit, curExpt, curTrodeSpikes,varargin)

expt = curExpt;

% get rid of empty and turn to empty str (makes life easier using ismember
% later)
if isstruct(expt.info.transgene)
if isempty(expt.info.transgene.construct1), construct1 = '';
else construct1 = expt.info.transgene.construct1; end

if isempty(expt.info.transgene.construct2), construct2 = '';
else construct2 = expt.info.transgene.construct2; end

unit.transgene = {construct1,construct2};
else
    unit.transgene = {expt.info.transgene,''};

end