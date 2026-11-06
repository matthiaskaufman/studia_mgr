function [x, phi] = fSimulateModel(m, l, I)

%% Utworzenie modelu

model = fCreateInvertedPendulumStateSpaceModel(m, l, I);

%% Odczyt danych wejściowych

data = load('dane1_wah_grupa1.mat');

u = data.dane1.um(:,1);
t = data.dane1.t(:,1);

%% Symulacja

out = lsim(model, u, t);

%% Wyjścia

x   = out(:,1);
phi = out(:,2);

end