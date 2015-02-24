function struct_OUT = dynamicfieldHelper(struct_IN,fld)
ind = strfind(fld,'.');
if ~isempty(ind)
    subfld = fld((1):ind(1)-1);
    leftoverfld = fld(ind(1)+1:end);
    
    struct_OUT = dynamicfieldHelper(struct_IN.(subfld),leftoverfld);
else
    struct_OUT = struct_IN.(fld);
end
