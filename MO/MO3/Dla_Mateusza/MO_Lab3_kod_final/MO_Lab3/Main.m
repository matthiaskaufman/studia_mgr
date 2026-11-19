%% 1. WYWOLANIA
clc;
clear;
close all;

x0 = [-1 2];
r_values = [1 10 100 1000];

D = policz_wyniki(x0,r_values);

Tabela_Lagrange = D.Tabela_Lagrange;
Tabela_fmincon = D.Tabela_fmincon;
Tabela_kara = D.Tabela_kara;
Tabela_porownanie = D.Tabela_porownanie;

disp(Tabela_Lagrange);
disp(Tabela_fmincon);
disp(Tabela_kara);
disp(Tabela_porownanie);

rysuj_wykresy(D);
%% 2. FUNKCJE MATEMATYCZNE
function D = policz_wyniki(x0,r_values)

    % Lagrange: fsolve (skrypt prowadzacej)
    z = lagrange_example1();
    n = size(z,1);
    x1 = z(:,1);
    x2 = z(:,2);
    lambda = z(:,3);
    mu = zeros(n,1);
    fL = zeros(n,1);
    gL = zeros(n,1);
    hL = zeros(n,1);
    rodzaj = cell(n,1);

    for i = 1:n
        fL(i) = lagrange_fun(z(i,:));
        gL(i) = x1(i) + x2(i) - 2;
        hL(i) = x1(i) + x2(i) - 3;
        d2 = 1200*x1(i)^2 + 1200*x1(i) - 598;

        if abs(fL(i)) < 1e-7
            rodzaj{i} = 'minimum globalne';
        elseif d2 > 0
            rodzaj{i} = 'minimum lokalne';
        else
            rodzaj{i} = 'maksimum lokalne';
        end
    end

    D.Tabela_Lagrange = table(x1,x2,lambda,mu,fL,gL,hL,rodzaj);
    D.z = z;
    D.iglobal = find(strcmp(rodzaj,'minimum globalne'),1);
    D.ilokal = find(strcmp(rodzaj,'minimum lokalne'),1);
    D.imaks = find(strcmp(rodzaj,'maksimum lokalne'),1);

    if isempty(D.iglobal) || isempty(D.ilokal) || isempty(D.imaks)
        error('Brakuje jednego z trzech punktow Lagrange''a.');
    end

    % fmincon (skrypt prowadzacej)
    [xmin,fmin,exitflag,output] = lagrange_example2(x0);
    gmin = xmin(1)+xmin(2)-2;
    hmin = xmin(1)+xmin(2)-3;
    D.Tabela_fmincon = table(xmin(1),xmin(2),fmin,abs(gmin),max(0,hmin), ...
        output.iterations,exitflag,'VariableNames', ...
        {'x1','x2','f','blad_g','naruszenie_h','iteracje','exitflag'});
    D.xmin = xmin;

    % Funkcja kary (skrypty prowadzacej)
    W = penalty_ex3_iter(x0,r_values);
    D.Tabela_kara = array2table(W,'VariableNames', ...
        {'r','x1','x2','f','F_z_kara','blad_g','naruszenie_h','iteracje','exitflag'});
    D.W = W;

    % Porownanie metod
    ig = D.iglobal;
    il = D.ilokal;
    k = size(W,1);
    metoda = {'Lagrange - globalne'; 'Lagrange - lokalne'; 'fmincon'; 'Funkcja kary'};
    x_por = [x1(ig); x1(il); xmin(1); W(k,2)];
    y_por = [x2(ig); x2(il); xmin(2); W(k,3)];
    f_por = [fL(ig); fL(il); fmin; W(k,4)];
    blad_g = [abs(gL(ig)); abs(gL(il)); abs(gmin); W(k,6)];
    blad_h = [max(0,hL(ig)); max(0,hL(il)); max(0,hmin); W(k,7)];
    D.Tabela_porownanie = table(metoda,x_por,y_por,f_por,blad_g,blad_h);

end
%% 3. FUNKCJE WIZUALIZACJI
function rysuj_wykresy(D)
    rysuj_poziomice(D);
    for i = 1:size(D.W,1)
        rysuj_powierzchnie(D,i);
    end
    rysuj_blad(D);
end

function rysuj_poziomice(D)
    [X,Y] = meshgrid(-3:0.05:2,-1:0.05:6);
    Z = 100*(Y-X.^2).^2 + (1-X).^2;
    t = -3:0.05:2;
    z = D.z;
    W = D.W;
    xmin = D.xmin;

    figure('Name','01 - Poziomice i ograniczenia', ...
        'NumberTitle','off','WindowStyle','docked','Color','w');
    [~,hc] = contour(X,Y,Z,[0.1 1 5 10 25 50 100 250 500 1000 2500 5000], ...
        'LineWidth',0.9);
    hold on;
    hg = plot(t,2-t,'k-','LineWidth',1.8);
    hh = plot(t,3-t,'k--','LineWidth',1.8);
    h1 = plot(z(D.iglobal,1),z(D.iglobal,2),'go', ...
        'MarkerFaceColor','g','MarkerEdgeColor','k','MarkerSize',9);
    h2 = plot(z(D.ilokal,1),z(D.ilokal,2),'yo', ...
        'MarkerFaceColor','y','MarkerEdgeColor','k','MarkerSize',9);
    h3 = plot(z(D.imaks,1),z(D.imaks,2),'mo', ...
        'MarkerFaceColor','m','MarkerEdgeColor','k','MarkerSize',9);
    hf = plot(xmin(1),xmin(2),'r*','MarkerSize',12);
    hk = plot(W(:,2),W(:,3),'b.-','MarkerSize',13,'LineWidth',1.2);
    hs = plot(W(end,2),W(end,3),'bs','MarkerSize',9,'LineWidth',1.3);
    xlabel('x_1','Color','k');
    ylabel('x_2','Rotation',0,'HorizontalAlignment','right','Color','k');
    title('Funkcja Rosenbrocka i ograniczenia','Color','k');
    legend([hc hg hh h1 h2 h3 hf hk hs], ...
        {'Poziomice f(x)','g(x)=0','h(x)=0','Minimum globalne', ...
        'Minimum lokalne','Maksimum lokalne','fmincon', ...
        'Kolejne punkty kary','Kara r=1000'}, ...
        'Location','eastoutside','Color','w','TextColor','k');
    xlim([-3 2]); ylim([-1 6]);
    set(gca,'Color','w','FontSize',11,'XColor','k','YColor','k');
    grid on; box on; hold off;

end

function rysuj_powierzchnie(D,i)
    r = D.W(i,1);
    x = D.W(i,2);
    y = D.W(i,3);
    F = D.W(i,5);
    [X,Y] = meshgrid(-3:0.1:2,-1:0.1:6);
    Z = 100*(Y-X.^2).^2 + (1-X).^2 ...
        + r*(X+Y-2).^2 + r*max(0,X+Y-3).^2;

    figure('Name',sprintf('%02d - Kara r=%g',i+1,r), ...
        'NumberTitle','off','WindowStyle','docked','Color','w');
    surf(X,Y,Z,'EdgeColor','none');
    hold on;
    hn = plot3(x,y,F,'ro','MarkerSize',10, ...
        'MarkerFaceColor','r','MarkerEdgeColor','k');
    hg = plot3(1,1,0,'gs','MarkerSize',10, ...
        'MarkerFaceColor','g','MarkerEdgeColor','k');
    xlabel('x_1','Color','k');
    ylabel('x_2','Rotation',0,'HorizontalAlignment','right','Color','k');
    zlabel('F(x,r)','Color','k');
    title(sprintf('Funkcja kary, r = %g',r),'Color','k');
    legend([hn hg],{'fminunc','Minimum globalne'}, ...
        'Location','northeast','Color','w','TextColor','k');
    view(45,30);
    cb = colorbar;
    cb.Color = 'k';
    set(gca,'Color','w','FontSize',11,'XColor','k','YColor','k','ZColor','k');
    grid on; box on; hold off;

    % Wspolrzedne minimum z fminunc i minimum globalnego
    datatip(hn,x,y,F,'Location','northeast');
    datatip(hg,1,1,0,'Location','northwest');
end

function rysuj_blad(D)
    W = D.W;
    figure('Name','06 - Wplyw wspolczynnika kary', ...
        'NumberTitle','off','WindowStyle','docked','Color','w');
    loglog(W(:,1),W(:,6),'-o','LineWidth',1.7,'MarkerSize',7);
    xlabel('Wspolczynnik kary r','Color','k');
    ylabel('|g(x)| = |x_1+x_2-2|', ...
        'Rotation',0,'HorizontalAlignment','right','Color','k');
    title('Wplyw wspolczynnika kary na spelnienie rownosci','Color','k');
    set(gca,'Color','w','FontSize',11,'XColor','k','YColor','k');
    grid on; box on;

end
