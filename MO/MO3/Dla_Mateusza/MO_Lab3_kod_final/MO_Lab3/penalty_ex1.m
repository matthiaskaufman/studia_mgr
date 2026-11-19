% Funkcja kary kwadratowej i fminunc
% Na podstawie penalty_ex1.m prowadzacej

function [x,fval,exitflag,output] = penalty_ex1(x0,r)

f = @(x) 100*(x(2)-x(1)^2)^2 + (1-x(1))^2;
g = @(x) x(1)+x(2)-2;
h = @(x) x(1)+x(2)-3;

options = optimoptions(@fminunc,'Display','off','Algorithm','quasi-newton');
[x,fval,exitflag,output] = fminunc(@(x) ...
    f(x) + r*g(x)^2 + r*max(0,h(x))^2, x0, options);

end
