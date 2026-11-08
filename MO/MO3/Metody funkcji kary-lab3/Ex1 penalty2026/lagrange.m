%1. Metoda Lagrangea  dla funkcji postaci: z(x,y)=x^2+y^2 i ograniczenia 3*X+2*Y-8=0 
%2. Solve nonlinear equation - Lagrange condition dla d=[x,y,lam]

function F = lagrange(d)
F(1)= 2*d(1) +3*d(3);
F(2)= 2*d(2) + 2*d(3);
F(3)= 3*d(1)+2*d(2)-8;
end 
% wywo³anie:
%dx0 = [0 0 0];
% options=optimset('Display','iter');   % Option to display output
% [z,fval] = fsolve(@lagrange,x0,options)  % Call optimizer
