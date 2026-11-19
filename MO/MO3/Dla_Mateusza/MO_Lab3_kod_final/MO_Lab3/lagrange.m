% Metoda Lagrange'a - Rosenbrock, wariant b
% d = [x1, x2, lambda]

function F = lagrange(d)
F(1) = -400*d(1)*(d(2)-d(1)^2) + 2*(d(1)-1) + d(3);
F(2) = 200*(d(2)-d(1)^2) + d(3);
F(3) = d(1)+d(2)-2;
end
