function unitArray = populateUnits_contspontrate(unitArray)

unitArray = unitArray_forEachUnit(unitArray, @populateUnit_contspontrate,1);