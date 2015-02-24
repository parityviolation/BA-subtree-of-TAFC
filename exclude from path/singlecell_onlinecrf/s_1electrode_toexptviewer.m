unitInd = 4 
selectedfileInd = 6;
tempspikesL = filtspikes(spikes,0,'led',1,'assigns',unitInd,'fileInd',selectedfileInd);


a = 'F:\VCData\ExptTable\BA_2010-07-01_M1p3_440_exptdetails';
MakeExpt(a,[],[8 9 10 11 12 13 14 15 16 17 18 19 20 21]);


a = 'F:\VCData\ExptTable\BA_2010-07-06_M1p6_400_exptdetails';
MakeExpt(a,[],[3 8 10]);

a = 'F:\VCData\ExptTable\BA_2010-07-06_M1p11_539_exptdetails';
MakeExpt(a,[],[23 24]);

a = 'F:\VCData\ExptTable\BA_2010-07-06_M1p11_317_exptdetails';
MakeExpt(a,[],[16 19]);


a = 'F:\VCData\ExptTable\BVA2010-07-14Cell3.mat';
MakeExpt(a,[],[1:6]);



a = 'F:\VCData\ExptTable\BA_2010-07-16_Cell9_D235_exptdetails';
MakeExpt(a,[],[12:16 20]);
%%
spikes_plotbs