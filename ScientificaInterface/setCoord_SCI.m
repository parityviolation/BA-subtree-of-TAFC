function setCoord_SCI(id,coord)
% coord in mm
coord = coord *10000; % convert to tenths of micron default Scientifica units
if length(coord)==2
    cmd  = sprintf('ABS %d %d', coord (1) ,coord(2));   
else
    cmd  = sprintf('ABS %d %d %d', coord (1) ,coord(2),coord(3));
end
fprintf_SCI(id,cmd);