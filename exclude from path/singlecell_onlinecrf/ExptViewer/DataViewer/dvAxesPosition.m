function axPos = dvAxesPosition(nAxes,margins)
%
% INPUT
%   nAxes: Number of axes to be generated
%   margins: [LeftMargin RightMargin TopMargin BottomMargin]
% OUTPUT
%   axPos: Cell array of axes positions in normalized units
%
%   Created: SRO 4/30/10
%   Modified: 

LeftMargin = margins(1);
RightMargin = margins(2);
BottomMargin = margins(3);
TopMargin = margins(4);
InterAxisSpace = 0.005;
AxisWidth = 1 - LeftMargin - RightMargin;                               
AxisHeight = (1 - BottomMargin - TopMargin - nAxes*InterAxisSpace)/nAxes;


for i = 1:nAxes
    VertLoc = BottomMargin + (nAxes-i)*(AxisHeight+InterAxisSpace);
    axPos{i} = [LeftMargin VertLoc AxisWidth AxisHeight];
end
