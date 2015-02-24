function response = fprintf_SCI(id,cmd)
GOODCOM = [65 13]';  % CR A is expected after most commands

fprintf(id,cmd);
response = fread(id,2,'uchar');
if ~isequal(response,GOODCOM )
    error('COM6 error with %s: \n \t %s',cmd,char(response)')
end
   
