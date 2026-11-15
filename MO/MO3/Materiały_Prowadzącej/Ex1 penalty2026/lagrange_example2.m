x0=[4,3];
Aeq=[3,2];
Beq=8;
options = optimoptions('fmincon','Algorithm','interior-point');
[xmin,feval,exitflag,output,lambda,grad,hessian]=fmincon(@lagrange_fun,x0,[],[],Aeq,Beq,[],[],[],options)
