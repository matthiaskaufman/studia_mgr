function fPlotResponseComparison(m, l, I)

%% Dane referencyjne

data = load('dane1_wah_grupa1.mat');

xRef   = data.dane1.ym(:,1);
phiRef = data.dane1.ym(:,2);
time   = data.dane1.t(:,1);

%% Symulacja modelu

[x, phi] = fSimulateModel(m, l, I);

%% Utworzenie figury

figure('WindowStyle', 'normal');

%% Wykres położenia wózka

subplot(2,1,1);

p1 = plot(time, xRef, ...
          time, x, '--');

xlabel('Time [s]');
ylabel('Cart position');
title('Open-loop step response for cart position (x)');

p1(1).LineWidth = 2;
p1(2).LineWidth = 1.5;

legend( ...
    'Reference cart position', ...
    'Estimated cart position', ...
    'Location', 'best');

grid on;

%% Wykres kąta wahadła

subplot(2,1,2);

p2 = plot(time, phiRef, ...
          time, phi, '--');

xlabel('Time [s]');
ylabel('Angle from vertical');
title('Open-loop step response for pendulum angle from vertical (\phi)');

p2(1).LineWidth = 2;
p2(2).LineWidth = 1.5;

legend( ...
    'Reference angle', ...
    'Estimated angle', ...
    'Location', 'best');

grid on;

end