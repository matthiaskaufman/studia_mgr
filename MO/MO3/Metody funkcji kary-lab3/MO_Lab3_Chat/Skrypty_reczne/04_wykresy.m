%% 1. Poziomice i ograniczenia
clear; clc; close all;
[X,Y] = meshgrid(linspace(-3.2,2.1,170),linspace(-.5,5.6,170));
Z = 100*(Y-X.^2).^2+(1-X).^2;
figure; contour(X,Y,Z,[.1 1 3 6 10 20 50 100 200 500]); hold on;
u = linspace(-3.2,2.1,200);
plot(u,2-u,'k-','LineWidth',2);
plot(u,3-u,'k--','LineWidth',2);
plot(1,1,'rp','MarkerFaceColor','r');
plot(-1.99665923,3.99665923,'bo');
plot(-1,2,'gs');
xlabel('x_1'); ylabel('x_2'); grid on;
legend('Poziomice','g=0','h=0','Globalne','Lokalne','Start');

%% 2. Powierzchnia z kara
r=10;
F = Z+r*(X+Y-2).^2+r*max(0,X+Y-3).^2;
figure; surf(X,Y,F,'EdgeColor','none');
view(40,28); colorbar; grid on;
title('Funkcja z kara, r=10'); xlabel('x_1');ylabel('x_2');zlabel('F(x,r)');
