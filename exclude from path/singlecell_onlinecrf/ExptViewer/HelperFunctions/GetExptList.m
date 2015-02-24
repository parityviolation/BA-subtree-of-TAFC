function ExptList = GetExptList()
%
%
%   Created: 3/10 - SRO
%   Modified: 4/5/10 - SRO

RigDef = RigDefs;
cd(RigDef.Dir.Expt);
ExptList = dir('*expt.mat');
ExptList = {ExptList.name}';
for i = 1:length(ExptList)
    f = ExptList{i};
    f = f(1:end-9);
    ExptList{i} = f;
end

ExptList = flipdim(ExptList,1);