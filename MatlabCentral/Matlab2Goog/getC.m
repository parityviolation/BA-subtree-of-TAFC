function getC(spreadsheetKey,worksheetKey,aToken)
import java.io.*;
import java.net.*;
import java.lang.*;

com.mathworks.mlwidgets.html.HTMLPrefs.setProxySettings

MAXITER=10;
success=false;

getURLStringList=['https://spreadsheets.google.com/feeds/worksheets/' spreadsheetKey '/private/full/' worksheetKey];
safeguard=0;

while (~success && safeguard<MAXITER)
    safeguard=safeguard+1;
    con = urlreadwrite(mfilename,getURLStringList);
    con.setInstanceFollowRedirects(false);
    con.setRequestMethod( 'POST' );
    con.setDoOutput( true );
    con.setRequestProperty('Content-Type','application/atom+xml;charset=UTF-8');
    con.setRequestProperty('Authorization',String('GoogleLogin ').concat(aToken));
    event=['<entry xmlns=''http://www.w3.org/2005/Atom'' '...
        'xmlns:gsx=''http://schemas.google.com/spreadsheets/2006/extended''>' ...
        '<gsx:field1Name>A</gsx:field1Name>'...
        '<gsx:field2Name>B</gsx:field2Name>'...

        '</entry>'];
    ps = PrintStream(con.getOutputStream());
    ps.print(event);
    ps.close(); clear ps;
    if (con.getResponseCode()~=200)
        con.disconnect();
        continue;
    end
    success=true;
end
if success
    con.disconnect(); clear con;
else
    display(['Last response was: ' num2str(con.getResponseCode) '/' con.getResponseMessage().toCharArray()']);
    clear con;
    return;
end