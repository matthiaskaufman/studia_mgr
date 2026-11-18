% Metody optymalizacji - Rosenbrock, wariant b
% Uruchom Main.m. Wyniki beda w Command Window i na wykresach.

clc;
clear;
close all;

x0 = [-1 2];
r_values = [1 10 100 1000];

%% 1. Lagrange - sprawdzenie przez fsolve
z = lagrange_example1();

x1 = z(:,1);
x2 = z(:,2);
lambda = z(:,3);
mu = zeros(3,1);  % dla wariantu b nierownosc jest nieaktywna
fL = zeros(3,1);
gL = zeros(3,1);
hL = zeros(3,1);
rodzaj = cell(3,1);

for i = 1:3
    fL(i) = lagrange_fun(z(i,:));
    gL(i) = x1(i)+x2(i)-2;
    hL(i) = x1(i)+x2(i)-3;
    d2 = 1200*x1(i)^2+1200*x1(i)-598;
    if abs(fL(i)) < 1e-7
        rodzaj{i} = 'minimum globalne';
    elseif d2 > 0
        rodzaj{i} = 'minimum lokalne';
    else
        rodzaj{i} = 'maksimum lokalne';
    end
end

Tabela_Lagrange = table(x1,x2,lambda,mu,fL,gL,hL,rodzaj);
disp(Tabela_Lagrange);

%% 2. fmincon
[xmin,fmin,exitflag,output] = lagrange_example2(x0);
gmin = xmin(1)+xmin(2)-2;
hmin = xmin(1)+xmin(2)-3;
Tabela_fmincon = table(xmin(1),xmin(2),fmin,abs(gmin),max(0,hmin), ...
    output.iterations,exitflag,'VariableNames', ...
    {'x1','x2','f','blad_g','naruszenie_h','iteracje','exitflag'});
disp(Tabela_fmincon);

%% 3. Metoda funkcji kary
W = penalty_ex3_iter(x0,r_values);
Tabela_kara = array2table(W,'VariableNames', ...
    {'r','x1','x2','f','F_z_kara','blad_g','naruszenie_h','iteracje','exitflag'});
disp(Tabela_kara);

%% 4. Tabela porownawcza
[~,iGlobal] = min(fL);
iLokal = find(strcmp(rodzaj,'minimum lokalne'),1);
n = size(W,1);
metoda = {'Lagrange - globalne'; 'Lagrange - lokalne'; 'fmincon'; 'Funkcja kary'};
x_por = [x1(iGlobal); x1(iLokal); xmin(1); W(n,2)];
y_por = [x2(iGlobal); x2(iLokal); xmin(2); W(n,3)];
f_por = [fL(iGlobal); fL(iLokal); fmin; W(n,4)];
blad_g = [abs(gL(iGlobal)); abs(gL(iLokal)); abs(gmin); W(n,6)];
blad_h = [max(0,hL(iGlobal)); max(0,hL(iLokal)); max(0,hmin); W(n,7)];
Tabela_porownanie = table(metoda,x_por,y_por,f_por,blad_g,blad_h);

disp(Tabela_porownanie);

%% 5. Wykres warstwicowy z ograniczeniami (zapis recznie z okna)
[X,Y] = meshgrid(-3:0.05:2,-1:0.05:6);
Z = 100*(Y-X.^2).^2+(1-X).^2;
t = -3:0.05:2;

figure(1);
contour(X,Y,Z,30);
hold on;
plot(t,2-t,'k-','LineWidth',1.5);
plot(t,3-t,'k--','LineWidth',1.5);
plot(x1,x2,'ko','MarkerFaceColor','y','MarkerSize',7);
plot(xmin(1),xmin(2),'r*','MarkerSize',10);
plot(W(end,2),W(end,3),'bs','MarkerSize',8);
xlabel('x_1'); ylabel('x_2');
title('Funkcja Rosenbrocka i ograniczenia');
legend('f(x)','g(x)=0','h(x)=0','Lagrange','fmincon','kara','Location','best');
grid on; hold off;

%% 6. Wykresy przestrzenne funkcji z kara
[X,Y] = meshgrid(-3:0.1:2,-1:0.1:6);
for i = 1:length(r_values)
    r = r_values(i);
    Z = 100*(Y-X.^2).^2+(1-X).^2 ...
        + r*(X+Y-2).^2 + r*max(0,X+Y-3).^2;

    figure(i+1);
    surf(X,Y,Z,'EdgeColor','none');
    hold on;
    plot3(W(i,2),W(i,3),W(i,5),'r.','MarkerSize',25);
    xlabel('x_1'); ylabel('x_2'); zlabel('F(x,r)');
    title(sprintf('Funkcja kary, r = %g',r));
    view(40,30); colorbar; grid on;
    hold off;
end

%% 7. Blad ograniczenia przy roznych wartosciach r
figure(6);
semilogx(W(:,1),W(:,6),'-o','LineWidth',1.5);
xlabel('Wspolczynnik kary r');
ylabel('|x_1+x_2-2|');
title('Wplyw wspolczynnika kary na spelnienie ograniczenia');
grid on;

disp('Gotowe. Tabele sa w Workspace, wykresy w oknach Figure.');
