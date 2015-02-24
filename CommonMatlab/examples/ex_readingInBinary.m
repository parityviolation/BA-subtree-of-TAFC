filename = 'E:\Bass\ephys\Sert_179\012014\binary\32chn_5min_common_all.bin'
d = dir(filename)
f = fopen(filename);
sz = d.bytes;
chn = 32;
byte = 4;
samples = sz/byte/32;
m2 = fread(f,[chn samples],'single');
fclose(f)