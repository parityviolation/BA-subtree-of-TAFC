% load worksheet0
clear variables; clc;

userName='bassam.atallah'; %your '...@gmail.com' email address; if empty you can enter one in the dialog box. 

[aTokenDocs,aTokenSpreadsheet]=connectNAuthorize(userName);
pause(0.5);

s.spreadsheetTitle = 'TAFC Mice Weights Table';
s.worksheetTitle = 'Sheet55';
s.nColToGet = 6;
s.nRowToGet = 3;%number of rows from the bottom, counting from the first     non empty row
s = openGoogleWorkSheet(s,aTokenDocs,aTokenSpreadsheet);
s = addExptRow(s,weight,boxIndex,protocol)
h = createTable_GoogleWS(s)

