%% MO2 - Identyfikacja parametrow wahadla
clc; clear; close all;

% Funkcje prowadzacej czytaja plik o nazwie grupa1
copyfile('dane1_wah_grupa4.mat','dane1_wah_grupa1.mat','f');

%% Dane pomiarowe
load('dane1_wah_grupa4.mat');
time = dane1.t;
sampleTime = mean(diff(time));
input = dane1.um;
xRef = dane1.ym(:,1);
phiRef = dane1.ym(:,2);

%% Punkt poczatkowy i ograniczenia
lambda0 = [0.4 0.1 0.35];
lb = [1e-6 1e-6 1e-6];
ub = [2 1 1];

%% lsqnonlin
fOFRV = @(lambda) fObjectiveFunctionReturnVector(lambda,xRef,phiRef);
[wynik1,resnorm,~,~,info1] = lsqnonlin(fOFRV,lambda0,lb,ub);

%% fmincon
fOFRS = @(lambda) fObjectiveFunctionReturnScalar(lambda,xRef,phiRef);
[wynik2,fval,~,info2] = fmincon(fOFRS,lambda0,[],[],[],[],lb,ub);

%% Wykresy dopasowania
[x1,phi1] = fSimulateModel(wynik1(1),wynik1(2),wynik1(3));
[x2,phi2] = fSimulateModel(wynik2(1),wynik2(2),wynik2(3));
fPlotResponseComparison(wynik1(1),wynik1(2),wynik1(3));
fPlotResponseComparison(wynik2(1),wynik2(2),wynik2(3));

%% Porownanie wynikow
T = table({'lsqnonlin';'fmincon'}, ...
    [wynik1(1);wynik2(1)], ...
    [wynik1(2);wynik2(2)], ...
    [wynik1(3);wynik2(3)], ...
    [resnorm;fval], ...
    [info1.iterations;info2.iterations], ...
    'VariableNames',{'Metoda','m','l','I','J','Iteracje'});
format long g
disp(T)
