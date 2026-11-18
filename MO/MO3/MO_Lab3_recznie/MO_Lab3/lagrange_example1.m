% Sprawdzenie rownan Lagrange'a przy pomocy fsolve
% Trzy starty, poniewaz sa trzy punkty stacjonarne

function z = lagrange_example1()

x0 = [-3 5 0; -1 3 0; 2 0 0];
options = optimset('Display','off');

z = zeros(3,3);
for i = 1:3
    [p,fval,exitflag] = fsolve(@lagrange,x0(i,:),options);
    if exitflag <= 0 || norm(fval) > 1e-5
        error('fsolve nie znalazl rozwiazania dla startu nr %d',i);
    end
    z(i,:) = p;
    fprintf('Lagrange %d: x1=%.6f x2=%.6f lambda=%.6f\n', ...
        i,p(1),p(2),p(3));
end

end
