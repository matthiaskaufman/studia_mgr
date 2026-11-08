function [t, U] = sygnaly_wejsciowe(Tend, Ts, seed)

    rng(seed);

    t = (0:Ts:Tend)';
    N = length(t);

    Uw_cmd = losowe_schodki(N, Ts, [200 400]);
    Ut_cmd = losowe_schodki(N, Ts, [0 400]);
    M_cmd  = losowe_schodki(N, Ts, [0 10]);

    Uw = filtr_inercyjny(Uw_cmd, Ts, 1.0);
    Ut = filtr_inercyjny(Ut_cmd, Ts, 2.0);
    M  = filtr_inercyjny(M_cmd,  Ts, 0.8);

    Uw = Uw + 15*sin(2*pi*0.015*t) + 8*sin(2*pi*0.041*t);
    Ut = Ut + 25*sin(2*pi*0.012*t) + 10*sin(2*pi*0.035*t);
    M  = M  + 0.6*sin(2*pi*0.020*t);

    % rozruch silnika
% rozruch silnika - inny dla danych uczących i testowych
if seed == 1
    idx0 = t <= 25;
    Uw(idx0) = 300;
    Ut(idx0) = linspace(0, 300, sum(idx0));
    M(idx0)  = 2;
else
    idx0 = t <= 30;
    Uw(idx0) = 350;
    Ut(idx0) = linspace(0, 250, sum(idx0));
    M(idx0)  = 4;
end

    % ograniczenia z zadania
    Uw = min(max(Uw, 200), 400);
    Ut = min(max(Ut, 0), 400);
    M  = min(max(M, 0), 10);

    U = [Uw Ut M];
end

function x = losowe_schodki(N, Ts, zakres)

    x = zeros(N,1);
    i = 1;

    while i <= N
        czas_trwania = 8 + 22*rand;
        L = max(1, round(czas_trwania / Ts));

        wartosc = zakres(1) + rand * (zakres(2) - zakres(1));

        i2 = min(N, i + L - 1);
        x(i:i2) = wartosc;

        i = i2 + 1;
    end
end

function y = filtr_inercyjny(x, Ts, T)

    y = zeros(size(x));
    y(1) = x(1);

    alpha = Ts / (T + Ts);

    for i = 2:length(x)
        y(i) = y(i-1) + alpha * (x(i) - y(i-1));
    end
end