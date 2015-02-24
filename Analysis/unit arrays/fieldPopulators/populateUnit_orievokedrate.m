function unit = populateUnit_orievokedrate(unit, curExpt, curTrodeSpikes,varargin)

% get the maxium rate evoked by any stimulus (on average)

for i =1:length(unit)
    try
        %         ua2(i).orievokedrate = nanmean(ua2(i).oriRates.stim);
        ncond =  size(unit(i).oriRates.mn.stim,2);
        switch ncond
            case 1 % assume only 1 conditions is ctrl condition
                unit(i).orievokedrate =[max(unit(i).oriRates.mn.stim) NaN];
            case 2
                unit(i).orievokedrate =max(unit(i).oriRates.mn.stim);
        end
    catch ME, getReport(ME); unit(i).orievokedrate = [NaN NaN]; end
end