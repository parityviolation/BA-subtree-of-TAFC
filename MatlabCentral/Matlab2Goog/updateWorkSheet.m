function s = updateWorkSheet(s)

% s is a struct created for every worksheet read from google docs
% see openGoogleWorkSheet(aTokenDocs,aTokenSpreadsheet,s)
% grow the Gspreadsheet as much as necessary
if ~isempty(s.cellEdited)
    new_nR = max(s.cellEdited(:,2));
    if new_nR > s.nR
        changeWorksheetNameAndSize(s.spreadsheetKey,s.worksheetKey,new_nR,s.nC,s.worksheetTitle,s.aTokenSpreadsheet)
        s.nR = new_nR;
    end
    
    % update all the edited cells
    for icell = 1:size(s.cellEdited,1)
        tableRow =  s.cellEdited(icell,1);
        ssRow = s.cellEdited(icell,2);
        Col = s.cellEdited(icell,3); % note GWS is -1 compared to Col in Table
        cellValue = s.table{tableRow,Col};
        if isnumeric(cellValue)
            cellValue = num2str(cellValue);
        end
        % move to update
        editWorksheetCell(s.spreadsheetKey,s.worksheetKey,ssRow,Col-1,cellValue,s.aTokenSpreadsheet);
        disp(['updated ' num2str(ssRow) ' ' num2str(Col)]);
        
        % if ssRow>s.nonEmptyRow
        %     s.nonEmptyRow = ssRow;
        % end
    end
    s.cellEdited = [];
end
