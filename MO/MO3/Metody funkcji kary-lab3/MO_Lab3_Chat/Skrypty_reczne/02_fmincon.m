%% 1. Dane
clear; clc;
f = @(x) 100*(x(2)-x(1)^2)^2 + (1-x(1))^2;
x0 = [-1;2];
A = [1 1]; b = 3;
Aeq = [1 1]; beq = 2;

%% 2. Optymalizacja
op = optimoptions('fmincon','Algorithm','sqp','Display','iter');
[x,fx,exitflag] = fmincon(f,x0,A,b,Aeq,beq,[],[],[],op);
fprintf('x1=%.8f, x2=%.8f, f=%.8f, exit=%d\n',x(1),x(2),fx,exitflag);
fprintf('g(x)=%g, h(x)=%g\n',sum(x)-2,sum(x)-3);

%% 3. Kontrola z innego punktu
[x2,f2] = fmincon(f,[1;1],A,b,Aeq,beq,[],[],[],op);
fprintf('Drugi start: x=(%.6f, %.6f), f=%g\n',x2,f2);
