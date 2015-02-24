function unitArray = populateUnits_transgene(unitArray)

 unitArray = unitArray_forEachUnit(unitArray, @populateUnit_transgene, 1);
 
 