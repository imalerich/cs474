function [Y] = p1predict(X)

w = [1; 1];
b = -3;
C = length(X);
Y = zeros(C, 1);

for i = 1:C
    Y(i, 1) = sign(w' * phi(X(i,:))' + b);
end

end
