%%Minimize f(x,y)=(x+7y)3 on the disk x2+y2≤1 by iteratively 
% using fminsearch with a quadratic penalty term.
clc
clear
close
f = @(x) (x(1) + 7*x(2)).^3;
c = @(x) x(1).^2 + x(2).^2 - 1;
x0 = randn(2, 1);

for M = [1e3, 1e6, 1e9, 1e12]
    x0 = fminsearch(@(x) f(x) + M*max(c(x), 0).^2, x0);
    fprintf('Found x = (%g, %g), |x| = %g, f(x) = %g \n', x0, norm(x0), f(x0));
end
    
fprintf('Found x* = (%g, %g), |x| = %g, f(x) = %g \n', x0, norm(x0), f(x0));
