function saveexptstruct(expt)
r = RigDefs;
save(fullfile(r.Dir.Expt,getFilename(expt.info.exptfile)),'expt');
