
% NOTE + Y is Anterior
% NOTE + X is RIGHT
% NOTE + Z is UP
if exist('id','var')
    try
        fclose(id)
    catch ME
        getReport(ME)
    end
    clear id
        global id

else
        global id

    id = fopen_SCI('COM6');
end
  fprintf_SCI(id,'ANGLE 0');
    
%     position at bregma by hand
    input('Set at bregma Manually and press ENTER')
    fprintf_SCI(id,'zero'); % set on bregma by hand
    setHome(id)
    getCoord_SCI(id)

goHome(id)
