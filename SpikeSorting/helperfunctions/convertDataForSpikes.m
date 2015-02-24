function data = convertDataForSpikes(data)
    for i = 1:size(data,2)
        if size(data,3) > 1 % If more than 1 channel
            dataTemp{i} = squeeze(permute(data(:,i,:),[2 1 3]));
        else
            dataTemp{i} = data(:,i);
        end
    end
    data = dataTemp; clear dataTemp