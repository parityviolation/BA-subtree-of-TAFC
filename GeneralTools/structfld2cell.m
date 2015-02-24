function cellOut = structfld2cell(dp,fldname)

ndp = length(dp);
cellOut = cell(ndp,1);
for idp = 1:ndp
    cellOut{idp} = dp(idp).(fldname);   
end