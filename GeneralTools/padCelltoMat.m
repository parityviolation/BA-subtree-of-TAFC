function outMat = padCelltoMat(cellin)

nelement = length(cellin);
sizes = reshape(cell2mat(cellfun(@size, cellin,'UniformOutput',false)),2,nelement)';
maxs = max(sizes);
outMat = nan(maxs(1),maxs(2), nelement);
for i= 1:nelement
    thissize =sizes(i,:);
    outMat(1:thissize(1),1:thissize(2),i) = cellin{i};
end