function hSaveButton = tb_saveFigDisp(hFig)


hSaveButton = tb_saveFig(hFig);

% Change icon image and clicked callback
iconFile = 'C:\Documents and Settings\Bass\My Documents\MATLAB\MatlabCodeBase\GuiTools\Icons\file_saveDisp.png';

set(hSaveButton,'CData',iconRead(iconFile),'ClickedCallback',@saveDispButton_callback)


% --- Subfunction --- %

function saveDispButton_callback(hObject,eventdata)

h = guidata(hObject);

file = saveButton_callback(hObject,eventdata);
pause(0.5)
hTemp = openfig(file);
set(hTemp,'Visible','off')
removeAllUIcontrols(hTemp)
set(hTemp,'Visible','on')



