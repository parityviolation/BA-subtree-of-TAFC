function unitArray = populateUnits_orispontrate(unitArray)

unitArray = unitArray_forEachUnit(unitArray, @populateUnit_orispontrate,1);