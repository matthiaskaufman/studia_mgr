% Sprawdzenie warunkow Lagrange'a przez fsolve
% Starty blisko trzech roznych punktow stacjonarnych

function z = lagrange_example1()

x0 = [-2.5 4.2 -2; -0.6 2.7 -450; 1.2 0.9 0];
options = optimset('Display','off');
z = zeros(3,3);

for i = 1:3
    [p,fval,exitflag] = fsolve(@lagrange,x0(i,:),options);

    if exitflag <= 0 || norm(fval) > 1e-5
        error('fsolve nie znalazl rozwiazania dla startu %d',i);
    end

    for j = 1:i-1
        if norm(p-z(j,:)) < 1e-4
            error('fsolve znalazl drugi raz ten sam punkt');
        end
    end

    z(i,:) = p;
    fprintf('Lagrange %d: x1=%.6f  x2=%.6f  lambda=%.6f\n', ...
        i,p(1),p(2),p(3));
end

end
