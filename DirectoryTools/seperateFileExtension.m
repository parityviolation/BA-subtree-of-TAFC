function [filename ext] = seperateFileExtension(filename)
ind = regexp(filename,'\.');
if ~isempty(ind)
    filename = filename(1:ind(1)-1);
    ext = filename(ind(1):end);
else
    ext = '';
end

