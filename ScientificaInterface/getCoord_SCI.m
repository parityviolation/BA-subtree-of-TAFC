function coord= getCoord_SCI(id)
fprintf(id,sprintf('p'));
a = '';
this = 0;
while (this~= 13)
this = fread(id,1);
a(end+1) = char(this);
end
coord = str2num(a);
disp(a);