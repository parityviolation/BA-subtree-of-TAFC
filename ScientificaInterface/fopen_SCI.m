function id = fopen_SCI(com)
if nargin ==0
    com = 'COM6';
end
id = serial(com);
set(id,'Terminator','CR/LF');
set(id,'FlowControl','hardware');


% % initialize
fopen(id)
fprintf(id,'date')
disp(char(fread(id,44)'))


