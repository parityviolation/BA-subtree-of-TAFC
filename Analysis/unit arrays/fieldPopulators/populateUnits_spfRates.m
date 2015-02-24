function unitArray = populateUnits_spfRates(unitArray)

unitArray = unitArray_forEachUnit(unitArray, @populateUnit_spfRates,1);