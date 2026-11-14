%% 1. Funkcja z kara
clear; clc;
f = @(x) 100*(x(2)-x(1)^2)^2 + (1-x(1))^2;
g = @(x) sum(x)-2;
h = @(x) sum(x)-3;
F = @(x,r) f(x) + r*g(x)^2 + r*max(0,h(x))^2;
rLista = [1 10 100 1000];
x = [-1;2];

%% 2. Petla po parametrach
op = optimoptions('fminunc','Algorithm','quasi-newton','Display','off');
for r=rLista
    [x,wartosc,flaga] = fminunc(@(z) F(z,r),x,op);
    fprintf('r=%5g | x=(%10.6f, %10.6f) | f=%10.6f | F=%10.6f | g=%g | exit=%d\n', ...
        r,x(1),x(2),f(x),wartosc,g(x),flaga);
end
