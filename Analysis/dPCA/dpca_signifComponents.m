function componentsSignif = dpca_signifComponents(accuracy, accuracyShuffle, whichMarg, combinedParams, numComp, minChunk)

componentsSignif = zeros(length(whichMarg), size(accuracy,2));

timeMarg = [];
params = [];
for k = 1:length(combinedParams)
    params = [params cell2mat(combinedParams{k})];
end
for k = 1:length(combinedParams)
    if combinedParams{k}{1} == max(params) && length(combinedParams{k}) == 1
        timeMarg = k;
        break
    end
end

for marg = setdiff(1:length(combinedParams), timeMarg)
    compMarg = find(whichMarg == marg, numComp);
    for d = 1:length(compMarg)
        if marg < timeMarg
            num = (marg-1)*numComp + d;
            numSh = marg;
        else
            num = (marg-2)*numComp + d;
            numSh = marg-1;
        end
        componentsSignif(compMarg(d),:) = accuracy(num,:) > max(accuracyShuffle(numSh, :,:), [], 3);
    end    
end

% remove short chunks of significance

for i=1:size(componentsSignif, 1)
    s = componentsSignif(i,:);
    ns = find(s == 0);
    tooShort = find(diff(ns) > 1 & diff(ns) < minChunk);
    for t = 1:length(tooShort)
        s(ns(tooShort(t))+1:ns(tooShort(t)+1)-1) = 0;
    end
    
    componentsSignif(i,:) = s;
end

