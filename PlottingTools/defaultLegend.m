function hleg = defaultLegend(hleg,Location,Fontsize)
legend(hleg,'boxoff')
set(hleg,'Visible','off');
set(get(hleg,'Children'),'Visible','on')  ;
if nargin >2
set(hleg,'FontSize',Fontsize);
end
if nargin <2|isempty(Location)
Location  = 'Best';
end
set(hleg,'Interpreter','none','Location',Location,'Color','none');
legendshrink(0.2,'',hleg)
set(hleg,'Location',Location);


