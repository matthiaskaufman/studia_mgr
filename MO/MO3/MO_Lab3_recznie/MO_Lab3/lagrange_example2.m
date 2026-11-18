% Przyklad fmincon z ograniczeniami liniowymi - wariant b

function [xmin,feval,exitflag,output] = lagrange_example2(x0)

A = [1 1];
B = 3;
Aeq = [1 1];
Beq = 2;
options = optimoptions('fmincon','Algorithm','interior-point','Display','off');

[xmin,feval,exitflag,output] = fmincon(@lagrange_fun,x0,A,B,Aeq,Beq,[],[],[],options);

end
