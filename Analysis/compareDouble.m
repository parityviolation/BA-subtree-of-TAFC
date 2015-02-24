function y = compareDouble(x,value)
%
%
%
%

if ~(value == 0)
    y = (x > value - 1E-6*value) & (x < value + 1E-6*value);
else
    y = x == 0;
end