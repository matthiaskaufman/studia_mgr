%% 1. Funkcja i ograniczenia (wariant b)
clear; clc;
f = @(x) 100*(x(2)-x(1)^2)^2 + (1-x(1))^2;
% g=0 -> x2=2-x1; h=x1+x2-3=-1, wiec mu=0.

%% 2. Rownanie stacjonarnosci
% Po podstawieniu t=x1 mamy:
% f(t)=100*t^4+200*t^3-299*t^2-402*t+401
% df/dt=400*t^3+600*t^2-598*t-402
wsp = [100 200 -299 -402 401];
t = sort(real(roots(polyder(wsp))));
x = [t, 2-t];

%% 3. Klasyfikacja i mnoznik Lagrange'a
for k=1:numel(t)
    xk = x(k,:)';
    grad = [-400*xk(1)*(xk(2)-xk(1)^2)+2*(xk(1)-1);200*(xk(2)-xk(1)^2)];
    lambda = -sum(grad)/2;
    d2 = polyval(polyder(polyder(wsp)),t(k));
    fprintf('x=(%.6f, %.6f), f=%.6f, lambda=%.6f, f2=%.6f\n',xk,f(xk),lambda,d2);
end
