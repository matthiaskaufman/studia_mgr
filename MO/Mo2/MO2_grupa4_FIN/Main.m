%% Main.m - Identyfikacja parametrow modelu odwroconego wahadla
% Polaczony skrypt realizujacy pelna procedure identyfikacji parametrow
% (dane i model poczatkowy, lsqnonlin, fmincon oraz porownanie wynikow)

%% 1. Przygotowanie srodowiska i wczytanie danych pomiarowych (Grupa 4)
clear; clc; close all;

folder = fileparts(mfilename('fullpath'));
if isempty(folder)
    folder = pwd;
end

% Obsluga uruchomienia zarowno z podkatalogu (np. 'recznie'), jak i z katalogu glownego
if exist(fullfile(folder, 'dane1_wah_grupa4.mat'), 'file')
    root = folder;
    roboczy = fullfile(folder, 'recznie', '_roboczy_grupa4');
else
    root = fileparts(folder);
    roboczy = fullfile(folder, '_roboczy_grupa4');
end

addpath(fullfile(root, 'funkcje_prowadzacej'));

z = load(fullfile(root, 'dane1_wah_grupa4.mat'));
t = z.dane1.t;
u = z.dane1.um(:,1);
xRef = z.dane1.ym(:,1);
phiRef = z.dane1.ym(:,2);
size(z.dane1.ym)

%% 2. Wykresy sygnalu wejsciowego i sygnalow wyjsciowych
figure('Name', 'Dane pomiarowe - wejscie i wyjscia');
subplot(3,1,1); plot(t, u); grid on; ylabel('u [N]');
subplot(3,1,2); plot(t, xRef); grid on; ylabel('x [m]');
subplot(3,1,3); plot(t, phiRef); grid on; ylabel('phi [rad]'); xlabel('t [s]');

%% 3. Symulacja modelu dla pierwszego przyblizenia (punkt startowy)
% Funkcja pomocnicza prowadzacej wczytuje plik dane1_wah_grupa1.mat,
% dlatego kopiujemy dane grupy 4 pod ta nazwa do katalogu roboczego.
if ~exist(roboczy, 'dir')
    mkdir(roboczy);
end
copyfile(fullfile(root, 'dane1_wah_grupa4.mat'), ...
    fullfile(roboczy, 'dane1_wah_grupa1.mat'));
cd(roboczy);

% Punkt startowy i ograniczenia parametrow: lambda = [m, l, I]
lambda0 = [0.4 0.1 0.35];
lb = [1e-6 1e-6 1e-6];
ub = [2 1 1];

[x0, phi0] = fSimulateModel(lambda0(1), lambda0(2), lambda0(3));

figure('Name', 'Model z pierwszym przyblizeniem');
subplot(2,1,1); plot(t, xRef, 'k', t, x0, 'r--'); grid on; legend('pomiar', 'model'); ylabel('x [m]');
subplot(2,1,2); plot(t, phiRef, 'k', t, phi0, 'r--'); grid on; legend('pomiar', 'model'); ylabel('phi [rad]'); xlabel('t [s]');

%% 4. Identyfikacja parametrow z uzyciem lsqnonlin
funLSQ = @(lambda) fObjectiveFunctionReturnVector(lambda, xRef, phiRef);
opcjeLSQ = optimoptions('lsqnonlin', 'Display', 'iter', 'MaxIterations', 400);

[lambdaLSQ, resnorm, ~, exitflag, output] = lsqnonlin(funLSQ, lambda0, lb, ub, opcjeLSQ)

% Wykres dopasowania i zapis wynikow lsqnonlin
fPlotResponseComparison(lambdaLSQ(1), lambdaLSQ(2), lambdaLSQ(3));
outputLSQ = output;
exitflagLSQ = exitflag;
save('wynik_lsq.mat', 'lambdaLSQ', 'resnorm', 'exitflag', 'output');

%% 5. Identyfikacja parametrow z uzyciem fmincon
funFMIN = @(lambda) fObjectiveFunctionReturnScalar(lambda, xRef, phiRef);
opcjeFMIN = optimoptions('fmincon', 'Algorithm', 'sqp', 'Display', 'iter', 'MaxIterations', 1000);

[lambdaFMIN, J, exitflag, output] = fmincon(funFMIN, lambda0, ...
    [], [], [], [], lb, ub, [], opcjeFMIN)

% Wykres dopasowania i zapis wynikow fmincon
fPlotResponseComparison(lambdaFMIN(1), lambdaFMIN(2), lambdaFMIN(3));
outputFMIN = output;
exitflagFMIN = exitflag;
save('wynik_fmin.mat', 'lambdaFMIN', 'J', 'exitflag', 'output');

%% 6. Porownanie wynikow obu metod optymalizacji
[x1, phi1] = fSimulateModel(lambdaLSQ(1), lambdaLSQ(2), lambdaLSQ(3));
[x2, phi2] = fSimulateModel(lambdaFMIN(1), lambdaFMIN(2), lambdaFMIN(3));

J1 = sum((xRef - x1).^2) + sum((phiRef - phi1).^2);
J2 = sum((xRef - x2).^2) + sum((phiRef - phi2).^2);

T = table({'lsqnonlin'; 'fmincon'}, ...
    [lambdaLSQ(1); lambdaFMIN(1)], ...
    [lambdaLSQ(2); lambdaFMIN(2)], ...
    [lambdaLSQ(3); lambdaFMIN(3)], ...
    [J1; J2], ...
    [outputLSQ.iterations; outputFMIN.iterations], ...
    'VariableNames', {'Metoda', 'm', 'l', 'I', 'J', 'Iteracje'})

figure('Name', 'Porownanie metod: lsqnonlin vs fmincon');
subplot(2,1,1);
plot(t, xRef, 'k', t, x1, 'b--', t, x2, 'r:');
legend('pomiar', 'lsqnonlin', 'fmincon');
ylabel('x [m]');
grid on;

subplot(2,1,2);
plot(t, phiRef, 'k', t, phi1, 'b--', t, phi2, 'r:');
legend('pomiar', 'lsqnonlin', 'fmincon');
ylabel('phi [rad]');
xlabel('t [s]');
grid on;
