%% 1. WYWOLANIA
clear; clc; close all;

p.size_pop = 20;        % 20, 40, 80
p.Pc = 0.8;             % 0.6, 0.8, 0.95
p.Pm = 0.05;            % 0.01, 0.05, 0.1
p.max_gen = 50;         % 20, 50, 100
p.seed = 2026;
p.index = 1;            % 1 - Jc1, 2 - Jc2

p.w1 = 1;
p.w2 = 0.1;
p.tstop = 15;
p.bits = [10 14 14];
p.vlb = [0 0 0];
p.vub = [10 10 10];
p.folder = fileparts(mfilename('fullpath'));
addpath(p.folder);

W = obliczenia(p);
rysuj(W);

%% 2. FUNKCJE MATEMATYCZNE
function W = obliczenia(p)
rng(p.seed);
load_system(fullfile(p.folder, 'ex_5.slx'));
sim0 = Simulink.SimulationInput('ex_5');
sim0 = setModelParameter(sim0, 'StopTime', num2str(p.tstop), ...
    'ReturnWorkspaceOutputs', 'on');

[pop, lchrom] = encode([], p.vlb, p.vub, p.bits);
pop = [pop; double(rand(p.size_pop, lchrom) < 0.5)];
Jhist = zeros(p.max_gen, 1);
Khist = zeros(p.max_gen, 3);
Jbest = inf;

for g = 1:p.max_gen
    K = decode(pop, p.vlb, p.vub, p.bits);   % kolejnosc: Kp, Kd, Ki
    Jpop = zeros(p.size_pop, 1);
    for i = 1:p.size_pop
        Jpop(i) = ocena(sim0, K(i,:), p);
    end

    [Jgen, nr] = min(Jpop);
    if Jgen < Jbest
        Jbest = Jgen;
        Kbest = K(nr,:);
        chrom_best = pop(nr,:);
    end
    Jhist(g) = Jbest;
    Khist(g,:) = Kbest;
    fprintf('Generacja %3d / %3d    J = %.6f\n', g, p.max_gen, Jbest);

    if g < p.max_gen
        pop = selection(pop, Jpop);
        pop = mate(pop);
        pop = xover(pop, p.Pc);
        pop = mutate(pop, p.Pm);
        pop(1,:) = chrom_best;
    end
end

[~, dane] = ocena(sim0, Kbest, p);
W.p = p;
W.K = Kbest;
W.J = Jbest;
W.Jhist = Jhist;
W.Khist = Khist;
W.t = dane(:,1);
W.r = dane(:,2);
W.y = dane(:,3);
W.u = dane(:,4);
W.ostatnia_poprawa = find([true; diff(Jhist) < -1e-10], 1, 'last');

fprintf('\nsize_pop=%d, Pc=%.2f, Pm=%.2f, max_gen=%d, seed=%d\n', ...
    p.size_pop, p.Pc, p.Pm, p.max_gen, p.seed);
fprintf('Kp=%.5f, Kd=%.5f, Ki=%.5f, J=%.6f\n', ...
    W.K(1), W.K(2), W.K(3), W.J);
fprintf('Bez poprawy: %d generacji\n', p.max_gen - W.ostatnia_poprawa);
end

function [J, dane] = ocena(sim0, K, p)
simin = setBlockParameter(sim0, 'ex_5/PID', ...
    'Kp', num2str(K(1),17));
simin = setBlockParameter(simin, 'ex_5/PID', ...
    'Kd', num2str(K(2),17));
simin = setBlockParameter(simin, 'ex_5/PID', ...
    'Ki', num2str(K(3),17));
wynik = sim(simin);
dane = wynik.get('simout');               % [t, r, y, u]
e = dane(:,2) - dane(:,3);
u = dane(:,4);
if p.index == 1
    J = p.w1*sum(e.^2) + p.w2*sum(u.^2);
else
    J = p.w1*sum(abs(e)) + p.w2*sum(abs(u));
end
end

%% 3. FUNKCJE WIZUALIZACJI
function rysuj(W)
g = (1:length(W.Jhist))';
f = figure('Name', 'MO - Laboratorium 4', 'NumberTitle', 'off', ...
    'Color', 'w', 'Position', [100 80 1150 670]);
% Jasny pasek nawigacji - niezalezny od ciemnego motywu MATLAB-a.
panele = gobjects(1,4);
for n = 1:4
    panele(n) = uipanel('Parent', f, 'Units', 'normalized', ...
        'Position', [0 0 1 0.94], 'BackgroundColor', 'w', ...
        'BorderType', 'none');
    if n > 1
        set(panele(n), 'Visible', 'off');
    end
end

nazwy = {'J - calosc', 'J - koniec', 'Nastawy PID', 'Odpowiedz skokowa'};
for n = 1:4
    uicontrol('Parent', f, 'Style', 'pushbutton', 'String', nazwy{n}, ...
        'Units', 'normalized', 'Position', [(n-1)/4 0.94 1/4 0.06], ...
        'BackgroundColor', 'w', 'ForegroundColor', 'k', ...
        'FontSize', 11, 'Callback', @(~,~) pokaz_panel(panele, n));
end

t1 = panele(1);
t2 = panele(2);
t3 = panele(3);
t4 = panele(4);

ax = os(t1, [0.12 0.17 0.84 0.73], 'Zbieznosc funkcji celu', 'Generacja', 'J');
plot(ax, g, W.Jhist, 'b-', 'LineWidth', 1.8);
xlim(ax, [1 max(2,g(end))]);
rozstep = max(W.Jhist) - min(W.Jhist);
ylim(ax, [min(W.Jhist)-0.04*rozstep, max(W.Jhist)+0.04*rozstep]);

k = max(1, floor(g(end)/2)):g(end);
ax = os(t2, [0.12 0.17 0.84 0.73], 'Koncowe generacje', 'Generacja', 'J');
plot(ax, g(k), W.Jhist(k), 'b-', 'LineWidth', 1.8);
xlim(ax, [g(k(1)), max(g(k(1))+1,g(end))]);
roznica = max(W.Jhist(k)) - min(W.Jhist(k));
margines = max(0.05, 0.1*roznica);
ylim(ax, [min(W.Jhist(k))-margines, max(W.Jhist(k))+margines]);

ax = os(t3, [0.12 0.60 0.84 0.31], 'Najlepsze nastawy Kp i Ki', 'Generacja', 'Nastawa');
plot(ax, g, W.Khist(:,1), 'b-', g, W.Khist(:,3), 'g-', 'LineWidth', 1.7);
leg = legend(ax, 'Kp', 'Ki', 'Location', 'northeast');
set(leg, 'Color', 'w', 'TextColor', 'k', 'EdgeColor', 'k');
xlim(ax, [1 max(2,g(end))]);

ax = os(t3, [0.12 0.15 0.84 0.31], 'Najlepsza nastawa Kd', 'Generacja', 'Kd');
plot(ax, g, W.Khist(:,2), 'Color', [0.85 0.3 0], 'LineWidth', 1.7);
xlim(ax, [1 max(2,g(end))]);

ax = os(t4, [0.12 0.17 0.84 0.73], 'Odpowiedz skokowa najlepszego PID', 'Czas [s]', 'r, y');
plot(ax, W.t, W.r, 'k--', W.t, W.y, 'b-', 'LineWidth', 1.8);
leg = legend(ax, 'Wartosc zadana', 'Wyjscie ukladu', 'Location', 'southeast');
set(leg, 'Color', 'w', 'TextColor', 'k', 'EdgeColor', 'k');
xlim(ax, [0 W.p.tstop]);
end

function ax = os(tab, pos, tytul, osX, osY)
ax = axes('Parent', tab, 'Position', pos);
hold(ax, 'on'); grid(ax, 'on'); box(ax, 'on');
set(ax, 'FontSize', 12, 'Color', 'w', ...
    'XColor', 'k', 'YColor', 'k', 'GridColor', [0.75 0.75 0.75]);
title(ax, tytul, 'Color', 'k');
xlabel(ax, osX, 'Rotation', 0, 'Color', 'k');
ylabel(ax, osY, 'Rotation', 0, 'Color', 'k', ...
    'HorizontalAlignment', 'right');
end

function pokaz_panel(panele, nr)
set(panele, 'Visible', 'off');
set(panele(nr), 'Visible', 'on');
end
