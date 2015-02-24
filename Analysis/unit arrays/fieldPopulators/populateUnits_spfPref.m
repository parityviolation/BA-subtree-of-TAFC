function unitArray = populateUnits_spfPref(unitArray)

 unitArray = unitArray_forEachUnit(unitArray, @populateUnit_spfPref, 1);