function unitArray = populateUnits_orievokedrate(unitArray)

 unitArray = unitArray_forEachUnit(unitArray, @populateUnit_orievokedrate, 1);