%% Prosta estymacja parametrów modelu wahad³a- 2 kroki gradientowe
clear; clc;

% Wczytanie danych referencyjnych
load dane1_wah_grupa1.mat
xRef = dane1.ym(:,1);
phiRef = dane1.ym(:,2);

% Parametry pocz¹tkowe
lambda = [0.4, 1.0, 0.35];   % [m, l, I]
delta = 0.01;                 % ma³a zmiana do przybli¿enia gradientu
alpha = 0.1;                  % krok aktualizacji

% Funkcja celu
f = @(lam) sum((xRef - fSimulateModel(lam(1), lam(2), lam(3))) .^2 + ...
               (phiRef - fSimulateModel(lam(1), lam(2), lam(3))) .^2);

fprintf('Krok 0: lambda = [%.3f %.3f %.3f], f = %.4f\n', lambda, f(lambda));

%% Aproksymacja gradientu numerycznego
grad = zeros(1,3);
for i = 1:3
    lam_step = lambda;
    lam_step(i) = lam_step(i) + delta;
    grad(i) = (f(lam_step) - f(lambda)) / delta;   % przybli¿ony pochodny
end

% Aktualizacja parametrów w kierunku przeciwnym do gradientu
lambda1 = lambda - alpha * grad;
fprintf('Krok 1: lambda = [%.3f %.3f %.3f], f = %.4f\n', lambda1, f(lambda1));

%% Drugi krok
grad = zeros(1,3);
for i = 1:3
    lam_step = lambda1;
    lam_step(i) = lam_step(i) + delta;
    grad(i) = (f(lam_step) - f(lambda1)) / delta;
end

lambda2 = lambda1 - alpha * grad;
fprintf('Krok 2: lambda = [%.3f %.3f %.3f], f = %.4f\n', lambda2, f(lambda2));