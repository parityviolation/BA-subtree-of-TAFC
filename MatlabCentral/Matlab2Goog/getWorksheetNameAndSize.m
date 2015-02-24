function [rowCountNew,colCountNew,worksheetTitleNew] = getWorksheetNameAndSize(spreadsheetKey,worksheetKey,aToken)
import java.io.*;
import java.net.*;
import java.lang.*;
com.mathworks.mlwidgets.html.HTMLPrefs.setProxySettings;

MAXITER=10;
success=false;

getURLStringList=['https://spreadsheets.google.com/feeds/worksheets/' spreadsheetKey '/private/full/' worksheetKey];
safeguard=0;

while (~success && safeguard<MAXITER)
    safeguard=safeguard+1;
    con = urlreadwrite(mfilename,getURLStringList);
    con.setInstanceFollowRedirects(false);
    con.setRequestMethod( 'GET' );
    con.setDoInput( true );
    con.setRequestProperty('Content-Type','application/atom+xml;charset=UTF-8');
    con.setRequestProperty('Authorization',String('GoogleLogin ').concat(aToken));
    if (con.getResponseCode()~=200)
        con.disconnect();
        continue;
    end
end
    xmlData=xmlread(con.getInputStream());
    con.disconnect(); clear con;
rowCountNew = str2num(char(xmlData.getElementsByTagName('entry').item(0).getElementsByTagName('gs:rowCount').item(0).getFirstChild.getData));
colCountNew = str2num(char(xmlData.getElementsByTagName('entry').item(0).getElementsByTagName('gs:colCount').item(0).getFirstChild.getData));
worksheetTitleNew = char(xmlData.getElementsByTagName('entry').item(0).getElementsByTagName('title').item(0).getFirstChild.getData);