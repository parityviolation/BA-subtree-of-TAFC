%this function finds all occurances of event a that are not within
%time(front) and time(back) of event b

% This function will now work for you sofia

function[output] = notSync(a,b,front,back)
output = [];

for i = 1:length(a)
    ha = find(b>a(i)+front & b<a(i)+back);
    if ~isempty(ha)
    elseif isempty(ha)
        output = [output a(i)];
    end
end
