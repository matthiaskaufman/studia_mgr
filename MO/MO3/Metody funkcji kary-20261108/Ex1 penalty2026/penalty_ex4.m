clear; clc; close all;

%% ==============================
% PARAMETRY
% ===============================
r = 5;              % parametr kary zewnętrznej
mu = 0.5;           % parametr bariery (r = 1/mu = 2)
alpha_ext = 0.05;
alpha_int = 0.1;

%% ==============================
% SIATKA DO WYKRESÓW
% ===============================
x = linspace(-0.5,2.5,400);
y = linspace(-0.5,2.5,400);
[X,Y] = meshgrid(x,y);

%% ==============================
% ===== METODA KARY ZEWNĘTRZNEJ
% ===============================
disp('METODA KARY ZEWNĘTRZNEJ')
x_ext = [0;0];          % start
traj_ext = x_ext';      % zapis trajektorii

for k = 1:8
    
    grad = [2*(x_ext(1)-2) + 2*r*(x_ext(1)+x_ext(2)-2);
            2*(x_ext(2)-1) + 2*r*(x_ext(1)+x_ext(2)-2)];
        
    x_ext = x_ext - alpha_ext*grad
    traj_ext = [traj_ext; x_ext'];
end

% Funkcja z karą
F_ext = (X-2).^2 + (Y-1).^2 + r*(X+Y-2).^2;

% Wykres
figure
contour(X,Y,F_ext,30)
hold on
plot(traj_ext(:,1),traj_ext(:,2),'o-','LineWidth',2)
plot(x,2-x,'k','LineWidth',2)  % granica ograniczenia
plot(1.5,0.5,'r*','MarkerSize',10) % optimum
title('Kara zewnętrzna – poziomice i trajektoria')
xlabel('x_1')
ylabel('x_2')
grid on
hold off

pause
%saveas(gcf,'kara_zewnetrzna.png')

%% ==============================
% ===== METODA KARY WEWNĘTRZNEJ
% ===============================
disp('METODA KARY WNĘTRZNEJ')
x_int = [0.5;0.5];      % punkt startowy dopuszczalny
traj_int = x_int';

for k = 1:8
    
    barrier = mu/(2 - x_int(1) - x_int(2));
    
    grad = [2*(x_int(1)-2) + barrier;
            2*(x_int(2)-1) + barrier];
        
    x_int = x_int - alpha_int*grad
    traj_int = [traj_int; x_int'];
end

% Funkcja barierowa (tylko obszar dopuszczalny)
F_int = (X-2).^2 + (Y-1).^2;
mask = (2 - X - Y) > 0;
F_int(mask) = F_int(mask) - mu*log(2 - X(mask) - Y(mask));
F_int(~mask) = NaN;

% Wykres
figure
contour(X,Y,F_int,30)
hold on
plot(traj_int(:,1),traj_int(:,2),'o-','LineWidth',2)
plot(x,2-x,'k','LineWidth',2)
plot(1.5,0.5,'r*','MarkerSize',10)
title('Kara wewnętrzna – poziomice i trajektoria')
xlabel('x_1')
ylabel('x_2')
grid on
hold off

%saveas(gcf,'kara_wewnetrzna.png')