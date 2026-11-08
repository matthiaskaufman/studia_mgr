 %%  Comparing two penalty functions (Linear penalty and Quadratic penalty)
%Minimize f(x,y)=(x+7y)3 on the disk x2+y2≤1 by using fminsearch with a penalty term.


f = @(x) (x(1) + 7*x(2)).^3;
c = @(x) x(1).^2 + x(2).^2 - 1;  %ograniczenie typu c(x)<=0.
M = 1e6; %waga dla kary -wspołczynnik r 

x0 = randn(2, 1);
xm1 = fminsearch(@(x) f(x) + M*max(c(x), 0), x0);
xm2 = fminsearch(@(x) f(x) + M*max(c(x), 0).^2, x0);

fprintf('Linear penalty: found x = (%g, %g), |x| = %g, f(x) = %g \n', xm1, norm(xm1), f(xm1));
fprintf('Quadratic penalty: found x = (%g, %g), |x| = %g, f(x) = %g \n', xm2, norm(xm2), f(xm2));