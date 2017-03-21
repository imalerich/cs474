function [out] = phi(data)

x1 = data(:,1);
x2 = data(:,2);

if sqrt(x1.^2 + x2.^2) > 2
    out = [ 4 - x2 + abs(x1 - x2), 4 - x1 + abs(x1 - x2) ];
else
    out = [ x1, x2 ];
end

end
