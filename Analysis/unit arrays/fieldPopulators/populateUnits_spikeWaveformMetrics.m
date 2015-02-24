function unitArray = populateUnits_spikeWaveformMetrics(unitArray)
    unitArray = unitArray_forEachUnit(unitArray, @populateUnit_spikeWaveformMetrics, 1);                 
end

