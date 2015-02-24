function unitArray = populateUnits_crf(unitArray)

unitArray = unitArray_forEachUnit(unitArray, @populateUnit_crf,1);