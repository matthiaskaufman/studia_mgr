clear; clc; close all;

%% ============================================================
%  USTAWIENIA
% ============================================================

Ts = 0.1;

model = 'ModelSilnika_MiI2012';   % zmień, jeśli Twój model ma inną nazwę

open_system(model);

set_param(model, ...
    'SolverType', 'Fixed-step', ...
    'Solver', 'ode4', ...
    'FixedStep', num2str(Ts));

%% ============================================================
%  1. Jedna długa symulacja i podział danych
% ============================================================

Tend_all = 500;
Ttrain_part = 350;

[t_all, Uall] = sygnaly_wejsciowe(Tend_all, Ts, 3);

Uw_in = [t_all Uall(:,1)];
Ut_in = [t_all Uall(:,2)];
M_in  = [t_all Uall(:,3)];

assignin('base','Uw_in',Uw_in);
assignin('base','Ut_in',Ut_in);
assignin('base','M_in',M_in);

set_param(model, 'StopTime', num2str(Tend_all));
sim(model);

Iw_all = Iw_ref(:);
It_all = It_ref(:);
om_all = omega_ref(:);

Yall = [Iw_all It_all om_all];

%% ============================================================
%  2. Podział: początek trening, końcówka test
% ============================================================

idx_train = t_all <= Ttrain_part;
idx_test  = t_all >  Ttrain_part;

t_train = t_all(idx_train);
Utrain  = Uall(idx_train,:);
Ytrain  = Yall(idx_train,:);

t_test = t_all(idx_test) - t_all(find(idx_test,1));
Utest  = Uall(idx_test,:);
Ytest  = Yall(idx_test,:);

Ntr = size(Utrain,1);
Nts = size(Utest,1);

fprintf('Dane uczace: %.1f s, liczba probek: %d\n', ...
    t_train(end), length(t_train));

fprintf('Dane testowe: %.1f s, liczba probek: %d\n', ...
    t_test(end), length(t_test));

%% ============================================================
%  3. Parametry sieci
% ============================================================

D1 = 10;    % opóźnienia dla Iw
D2 = 8;     % opóźnienia dla dIt
D3 = 10;    % opóźnienia dla domega

H1 = 8;
H2 = 15;
H3 = 20;

epochs = 300;

%% ============================================================
%  4. SIEĆ 1: Uw -> Iw
% ============================================================

fprintf('\nUczenie sieci 1: Uw -> Iw\n');

X1_train = zeros(D1+1, Ntr-D1);
T1_train = zeros(1, Ntr-D1);

kol = 0;

for i = D1+1:Ntr
    kol = kol + 1;

    probka = [];

    for d = 0:D1
        probka = [probka; Utrain(i-d,1)];
    end

    X1_train(:,kol) = probka;
    T1_train(:,kol) = Ytrain(i,1);
end

net_Iw = fitnet(H1, 'trainlm');
net_Iw.divideFcn = 'dividetrain';
net_Iw.trainParam.epochs = epochs;
net_Iw.performFcn = 'mse';

net_Iw = train(net_Iw, X1_train, T1_train);

%% Test sieci Iw

Iw_pred_full = zeros(Nts,1);
Iw_pred_full(1:D1) = Ytest(1:D1,1);

X1_test = zeros(D1+1, Nts-D1);

kol = 0;

for i = D1+1:Nts
    kol = kol + 1;

    probka = [];

    for d = 0:D1
        probka = [probka; Utest(i-d,1)];
    end

    X1_test(:,kol) = probka;
end

Iw_pred_full(D1+1:end) = net_Iw(X1_test)';

%% ============================================================
%  5. SIEĆ 2: przyrost dIt
% ============================================================

fprintf('\nUczenie sieci 2: dIt\n');

nX2 = 4*(D2+1) + D2;

X2_train = zeros(nX2, Ntr-D2-1);
T2_train = zeros(1, Ntr-D2-1);

kol = 0;

for i = D2+2:Ntr
    kol = kol + 1;

    probka = [];

    % aktualne i opóźnione: Uw, Ut, M, Iw
    for d = 0:D2
        probka = [probka; Utrain(i-d,1)];   % Uw
        probka = [probka; Utrain(i-d,2)];   % Ut
        probka = [probka; Utrain(i-d,3)];   % M
        probka = [probka; Ytrain(i-d,1)];   % Iw
    end

    % poprzednie wartości It
    for d = 1:D2
        probka = [probka; Ytrain(i-d,2)];
    end

    X2_train(:,kol) = probka;

    % uczymy przyrostu, nie wartości
    T2_train(:,kol) = Ytrain(i,2) - Ytrain(i-1,2);
end

net_dIt = fitnet(H2, 'trainlm');
net_dIt.divideFcn = 'dividetrain';
net_dIt.trainParam.epochs = epochs;
net_dIt.performFcn = 'mse';

net_dIt = train(net_dIt, X2_train, T2_train);

%% Test dIt rekurencyjnie

It_pred_full = zeros(Nts,1);

% początkowa historia dla testu
It_pred_full(1:D2+1) = Ytest(1:D2+1,2);

for i = D2+2:Nts

    probka = [];

    for d = 0:D2
        probka = [probka; Utest(i-d,1)];        % Uw
        probka = [probka; Utest(i-d,2)];        % Ut
        probka = [probka; Utest(i-d,3)];        % M
        probka = [probka; Iw_pred_full(i-d)];   % Iw z sieci
    end

    for d = 1:D2
        probka = [probka; It_pred_full(i-d)];
    end

    dIt = net_dIt(probka);

    It_pred_full(i) = It_pred_full(i-1) + dIt;
end

%% ============================================================
%  6. SIEĆ 3: przyrost domega
% ============================================================

fprintf('\nUczenie sieci 3: domega\n');

nX3 = 5*(D3+1) + D3;

X3_train = zeros(nX3, Ntr-D3-1);
T3_train = zeros(1, Ntr-D3-1);

kol = 0;

for i = D3+2:Ntr
    kol = kol + 1;

    probka = [];

    % aktualne i opóźnione: Uw, Ut, M, Iw, It
    for d = 0:D3
        probka = [probka; Utrain(i-d,1)];   % Uw
        probka = [probka; Utrain(i-d,2)];   % Ut
        probka = [probka; Utrain(i-d,3)];   % M
        probka = [probka; Ytrain(i-d,1)];   % Iw
        probka = [probka; Ytrain(i-d,2)];   % It
    end

    % poprzednie wartości omega
    for d = 1:D3
        probka = [probka; Ytrain(i-d,3)];
    end

    X3_train(:,kol) = probka;

    % uczymy przyrostu omega
    T3_train(:,kol) = Ytrain(i,3) - Ytrain(i-1,3);
end

net_domega = fitnet(H3, 'trainlm');
net_domega.divideFcn = 'dividetrain';
net_domega.trainParam.epochs = epochs;
net_domega.performFcn = 'mse';

net_domega = train(net_domega, X3_train, T3_train);

%% Test domega rekurencyjnie

omega_pred_full = zeros(Nts,1);

% początkowa historia dla testu
omega_pred_full(1:D3+1) = Ytest(1:D3+1,3);

for i = D3+2:Nts

    probka = [];

    for d = 0:D3
        probka = [probka; Utest(i-d,1)];          % Uw
        probka = [probka; Utest(i-d,2)];          % Ut
        probka = [probka; Utest(i-d,3)];          % M
        probka = [probka; Iw_pred_full(i-d)];     % Iw z sieci
        probka = [probka; It_pred_full(i-d)];     % It z sieci
    end

    for d = 1:D3
        probka = [probka; omega_pred_full(i-d)];
    end

    domega = net_domega(probka);

    omega_pred_full(i) = omega_pred_full(i-1) + domega;
end

%% ============================================================
%  7. Porównanie z modelem referencyjnym
% ============================================================

Dmax = max([D1 D2 D3]);

Y_true = Ytest(Dmax+2:end,:);

Y_pred = [ ...
    Iw_pred_full(Dmax+2:end), ...
    It_pred_full(Dmax+2:end), ...
    omega_pred_full(Dmax+2:end) ...
];

t_plot = t_test(Dmax+2:end);

blad = Y_true - Y_pred;

RMSE_Iw = sqrt(mean(blad(:,1).^2));
RMSE_It = sqrt(mean(blad(:,2).^2));
RMSE_omega = sqrt(mean(blad(:,3).^2));

fprintf('\nWyniki modelu z przyrostami:\n');
fprintf('RMSE Iw    = %.5f\n', RMSE_Iw);
fprintf('RMSE It    = %.5f\n', RMSE_It);
fprintf('RMSE omega = %.5f\n', RMSE_omega);

%% ============================================================
%  8. Wykresy porównawcze
% ============================================================

figure;
plot(t_plot, Y_true(:,1), 'LineWidth', 1.2); hold on;
plot(t_plot, Y_pred(:,1), '--', 'LineWidth', 1.2);
grid on;
xlabel('t [s]');
ylabel('Iw [A]');
legend('Model referencyjny', 'Model neuronowy');
title('Porównanie Iw');

figure;
plot(t_plot, Y_true(:,2), 'LineWidth', 1.2); hold on;
plot(t_plot, Y_pred(:,2), '--', 'LineWidth', 1.2);
grid on;
xlabel('t [s]');
ylabel('It [A]');
legend('Model referencyjny', 'Model neuronowy');
title('Porównanie It');

figure;
plot(t_plot, Y_true(:,3), 'LineWidth', 1.2); hold on;
plot(t_plot, Y_pred(:,3), '--', 'LineWidth', 1.2);
grid on;
xlabel('t [s]');
ylabel('\omega [rad/s]');
legend('Model referencyjny', 'Model neuronowy');
title('Porównanie omega');

%% ============================================================
%  9. Wykresy błędów
% ============================================================

figure;
plot(t_plot, blad(:,1), 'LineWidth', 1.1);
grid on;
xlabel('t [s]');
ylabel('błąd Iw');
title('Błąd Iw');

figure;
plot(t_plot, blad(:,2), 'LineWidth', 1.1);
grid on;
xlabel('t [s]');
ylabel('błąd It');
title('Błąd It');

figure;
plot(t_plot, blad(:,3), 'LineWidth', 1.1);
grid on;
xlabel('t [s]');
ylabel('błąd omega');
title('Błąd omega');

%% ============================================================
%  10. Zapis sieci
% ============================================================

save('model_blackbox_delta_3_sieci.mat', ...
    'net_Iw', 'net_dIt', 'net_domega', ...
    'D1', 'D2', 'D3', ...
    'RMSE_Iw', 'RMSE_It', 'RMSE_omega', ...
    'Ts');

disp('Sieci zapisane do model_blackbox_delta_3_sieci.mat');

%% ============================================================
%  11. Generowanie bloków Simulinka
% ============================================================

gensim(net_Iw, Ts);
save_system(gcs, 'blok_net_Iw');

gensim(net_dIt, Ts);
save_system(gcs, 'blok_net_dIt');

gensim(net_domega, Ts);
save_system(gcs, 'blok_net_domega');

disp('Wygenerowano bloki: blok_net_Iw, blok_net_dIt, blok_net_domega');