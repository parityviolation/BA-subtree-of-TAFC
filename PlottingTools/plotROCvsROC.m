function plotROCvsROC(roc1,roc2)
hAx = gca;

%         roc(ics).all_Area = [ roc(ics).all_Area thisSession_Area];
%         roc(ics).all_H = [ roc(ics).all_H thisSession_H];
%         roc(ics).condset = condset(ics);


%BA

mycolor1 = 'r';
mycolor2 = 'b';
mycolor12 = 'g';

roc2.all_H = logical(roc2.all_H);
roc1.all_H = logical(roc1.all_H);

epsilon = [0 0] %rand(size(roc1.all_Area,2))*.007;
roc1.all_Area = roc1.all_Area+epsilon(:,1)';
roc2.all_Area = roc2.all_Area+epsilon(:,2)';
line(roc1.all_Area,roc2.all_Area,'linestyle','none','marker','o','color','k');
line(roc1.all_Area(roc1.all_H),roc2.all_Area(roc1.all_H),'linestyle','none','marker','o','color',mycolor1);
line(roc1.all_Area(roc2.all_H),roc2.all_Area(roc2.all_H),'linestyle','none','marker','o','color',mycolor2);
line(roc1.all_Area(roc2.all_H&roc1.all_H),roc2.all_Area(roc2.all_H&roc1.all_H),'linestyle','none','marker','.',...
    'markersize',18,'color',mycolor12);
axis square
setaxEq(hAx);
line([-1 -1],[1 1],'linestyle',':');
line([0 0],[-1 1],'linestyle',':');
line([-1 1],[0 0],'linestyle',':');

xlabel(roc1.condset.sDesc );
ylabel(roc2.condset.sDesc );