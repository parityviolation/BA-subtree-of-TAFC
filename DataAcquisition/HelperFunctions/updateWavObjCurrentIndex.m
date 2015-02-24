function aoWavObj = updateWavObjCurrentIndex(aoWavObj)
% function aoWavObj = updateWavObjCurrentIndex(aoWavObj)
% BA augment index of varing parameters by 1

f = fieldnames(aoWavObj.CurrentIndex);
for ifdname = 1:length(f)
    afieldname = f{ifdname};
    tempInd = aoWavObj.CurrentIndex.(afieldname) + 1;
    aoWavObj.CurrentIndex.(afieldname) =  mod(tempInd-1,length(aoWavObj.(afieldname)))+1;
end