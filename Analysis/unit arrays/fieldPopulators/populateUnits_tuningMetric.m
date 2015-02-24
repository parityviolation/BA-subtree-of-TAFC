function unitArray = populateUnits_oriTuning(unitArray)

unitArray = unitArray_forEachUnit(unitArray, @populateUnit_oriTuning,1);