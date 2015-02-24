function unitArray = populateUnits_contValues(unitArray)

 unitArray = unitArray_forEachUnit(unitArray, @populateUnit_contValues, 1);