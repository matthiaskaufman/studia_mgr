% Kolejne wartosci kary. Poprzedni wynik jest nowym startem.
% Na podstawie penalty_ex3_iter.m prowadzacej

function wyniki = penalty_ex3_iter(x0,r_values)

f = @lagrange_fun;
wyniki = zeros(length(r_values),9);
k = 0;

for M = r_values
    k = k+1;
    [x0,F,exitflag,output] = penalty_ex1(x0,M);
    g = x0(1)+x0(2)-2;
    h = x0(1)+x0(2)-3;

    wyniki(k,:) = [M x0(1) x0(2) f(x0) F abs(g) max(0,h) output.iterations exitflag];
    fprintf('r=%g: x=(%.6f, %.6f), f=%.6f, |g|=%.3g\n', ...
        M,x0(1),x0(2),f(x0),abs(g));
end

end
