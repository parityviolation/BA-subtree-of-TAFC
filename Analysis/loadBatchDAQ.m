function [data dt] = loadBatchDAQ(filenames,channels,filtparams,bNoLoad)
if nargin<2 ,error('must specify filenames and channels'); end
if nargin<3 ,filtparams = []; end
if nargin<4 ,bNoLoad = 0; end
for i = 1: length(filenames)
    FN.filename= filenames{i};
    [tempdata{i} dt]= preprocessDAQ([],FN,channels,filtparams,bNoLoad);
end

data = cell2mat(tempdata);

