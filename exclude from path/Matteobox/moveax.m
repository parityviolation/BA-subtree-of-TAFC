function moveax(axlist,displacement)
% MOVEAX moves a list of axes by a given displacement
%
%	moveax(axlist,[dx dy]) adds dx and dy to the position of the axes in
%	axlist. If the units are normalized (which is the default), the values
%	are in fraction of a figure size.
%
%	moveax(axlist,[dx0 dy0 dxx dyy])
%
% See also: scaleax

% 1998 Matteo Carandini
% part of the Matteobox toolbox

if length(displacement)~=2 && length(displacement)~=4
   error('Displacement must have 2 or 4 elements');
end

axlist = axlist(:)';

if length(displacement)== 2
   displacement = [ displacement 0 0 ];
end

for ax = axlist
   set(ax,'position',get(ax,'position')+displacement);
end

