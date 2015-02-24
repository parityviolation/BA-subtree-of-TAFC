function unitArray = populateUnits_contRates(unitArray)

 unitArray = unitArray_forEachUnit(unitArray, @populateUnit_contRates, 1);