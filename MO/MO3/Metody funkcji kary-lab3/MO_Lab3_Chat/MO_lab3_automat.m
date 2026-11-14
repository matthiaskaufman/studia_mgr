function MO_lab3_automat
% MO - funkcja Rosenbrocka, wariant b.
% Uruchom Run. Wyniki i obrazy wykresow trafia do tego folderu.
clc; close all;
folder = fileparts(mfilename('fullpath'));
excelPlik = fullfile(folder, 'Wyniki_i_wykresy.xlsx');
folderRys = fullfile(folder, 'Wykresy_png');
if ~exist(folderRys,'dir'), mkdir(folderRys); end
if ~isfile(excelPlik)
    error('Brak pliku Wyniki_i_wykresy.xlsx obok skryptu.');
end

x0 = [-1; 2];
rList = [1 10 100 1000];
f = @(x) 100*(x(2)-x(1)^2)^2 + (1-x(1))^2;
g = @(x) x(1) + x(2) - 2;
h = @(x) x(1) + x(2) - 3;
F = @(x,r) f(x) + r*g(x)^2 + r*max(0,h(x))^2;

%% 1. Lagrange / KKT: x2=2-x1, h=-1, mu=0
% f(t,2-t) = 100*t^4 + 200*t^3 - 299*t^2 - 402*t + 401
% f'(t) = 400*t^3 + 600*t^2 - 598*t - 402
wsp = [100 200 -299 -402 401];
t = roots(polyder(wsp));
t = sort(real(t(abs(imag(t)) < 1e-8)));
if numel(t) ~= 3, error('Nie znaleziono 3 rzeczywistych punktow stacjonarnych.'); end
pkt = [t(:), 2-t(:)];
fKKT = zeros(3,1); lam = zeros(3,1); d2 = zeros(3,1);
for k = 1:3
    x = pkt(k,:)';
    fKKT(k) = f(x);
    d2(k) = polyval(polyder(polyder(wsp)), t(k));
    grad = [-400*x(1)*(x(2)-x(1)^2)+2*(x(1)-1); 200*(x(2)-x(1)^2)];
    lam(k) = -sum(grad)/2;
end
[~,indNaj] = min(fKKT);
xDok = pkt(indNaj,:)';
[~,indLok] = min(abs(t+1.99665923));
xLok = pkt(indLok,:)';

%% 2. fmincon - start z instrukcji + kontrola przy [1;1]
optC = optimoptions('fmincon','Algorithm','sqp','Display','off', ...
    'MaxIterations',3000,'OptimalityTolerance',1e-10, ...
    'ConstraintTolerance',1e-10,'StepTolerance',1e-12);
A = [1 1]; b = 3;
Aeq = [1 1]; beq = 2;
[xCon,fCon,exitCon,outCon] = fmincon(f,x0,A,b,Aeq,beq,[],[],[],optC);
[xCon2,fCon2,exitCon2] = fmincon(f,[1;1],A,b,Aeq,beq,[],[],[],optC);

%% 3. Funkcja kary, fminunc, kolejne r
optU = optimoptions('fminunc','Algorithm','quasi-newton', ...
    'Display','off','MaxIterations',3000, ...
    'OptimalityTolerance',1e-10,'StepTolerance',1e-12);
wynKary = zeros(numel(rList),10);
xAkt = x0;
for k = 1:numel(rList)
    r = rList(k);
    [xAkt,FK,flag,info] = fminunc(@(x) F(x,r),xAkt,optU);
    wynKary(k,:) = [r xAkt(1) xAkt(2) f(xAkt) FK g(xAkt) ...
        max(0,h(xAkt)) flag info.iterations r*g(xAkt)^2];
end

%% 4. Wykres 1 - poziomice i ograniczenia
xx = linspace(-3.2,2.1,210);
yy = linspace(-0.5,5.6,210);
[X,Y] = meshgrid(xx,yy);
Z = 100*(Y-X.^2).^2+(1-X).^2;
rys = cell(6,1);
fig = figure('Visible','off','Color','w','Position',[80 80 1000 650]);
contour(X,Y,Z,[0.1 1 3 6 10 20 50 100 200 500 1000]); hold on;
plot(xx,2-xx,'k-','LineWidth',1.9);
plot(xx,3-xx,'k--','LineWidth',1.5);
plot(xDok(1),xDok(2),'rp','MarkerSize',13,'MarkerFaceColor','r');
plot(xLok(1),xLok(2),'md','MarkerSize',10,'MarkerFaceColor','m');
plot(xCon(1),xCon(2),'bo','MarkerSize',9,'LineWidth',1.7);
plot(x0(1),x0(2),'gs','MarkerSize',9,'LineWidth',1.5);
xlabel('x_1'); ylabel('x_2'); grid on; axis equal;
xlim([-3.2 2.1]); ylim([-0.5 5.6]);
title('Funkcja Rosenbrocka - poziomice i ograniczenia');
legend('f(x) - poziomice','g(x)=0','h(x)=0','minimum globalne', ...
    'minimum lokalne','fmincon','punkt startowy','Location','northeastoutside');
rys{1} = fullfile(folderRys,'01_poziomice.png');
print(fig,rys{1},'-dpng','-r150'); close(fig);

%% 5. Wykresy 2-5 - powierzchnie z kara
[Xs,Ys] = meshgrid(linspace(-3.1,2.0,115),linspace(-0.3,5.3,115));
Zs = 100*(Ys-Xs.^2).^2+(1-Xs).^2;
for k = 1:numel(rList)
    r = rList(k);
    ZZ = Zs + r*(Xs+Ys-2).^2 + r*max(0,Xs+Ys-3).^2;
    xp = wynKary(k,2:3)';
    fig = figure('Visible','off','Color','w','Position',[80 80 1000 650]);
    surf(Xs,Ys,ZZ,'EdgeColor','none'); hold on;
    plot3(xp(1),xp(2),F(xp,r),'ro','MarkerFaceColor','r','MarkerSize',9);
    shading interp; view(40,28); grid on; colorbar;
    xlabel('x_1'); ylabel('x_2'); zlabel('F(x,r)');
    title(sprintf('Funkcja z kara zewnetrzna, r = %g',r));
    rys{k+1} = fullfile(folderRys,sprintf('%02d_kara_r%d.png',k+1,r));
    print(fig,rys{k+1},'-dpng','-r150'); close(fig);
end

%% 6. Wykres 6 - wplyw parametru
fig = figure('Visible','off','Color','w','Position',[80 80 1000 650]);
loglog(rList,abs(wynKary(:,6)),'o-','LineWidth',2,'MarkerSize',9);
grid on; xlabel('Parametr kary r'); ylabel('|g(x)|');
title('Wplyw r na naruszenie ograniczenia rownosciowego');
rys{6} = fullfile(folderRys,'06_wplyw_parametru.png');
print(fig,rys{6},'-dpng','-r150'); close(fig);

%% 7. Aktualizacja komorek i zdjec w istniejacym Excelu
% Zmiany w pliku xlsx robimy bez Excel COM (dziala tez bez Excel na Macu).
aktualizujExcel(excelPlik,rys,pkt,fKKT,lam,d2, ...
    xDok,xLok,xCon,fCon,xCon2,fCon2,wynKary,exitCon,exitCon2);

fprintf('\n=== LABORATORIUM: WARIANT b ===\n');
fprintf('Globalne Lagrange: (%.8f, %.8f), f = %.8f\n',xDok,f(xDok));
fprintf('Lokalne Lagrange: (%.8f, %.8f), f = %.8f\n',xLok,f(xLok));
fprintf('fmincon z [-1;2]: (%.8f, %.8f), f = %.8f, flag = %d\n',xCon,fCon,exitCon);
fprintf('fmincon z [1;1]:  (%.8f, %.8f), f = %.8f, flag = %d\n',xCon2,fCon2,exitCon2);
disp('Metoda kary: kolumny [r, x1, x2, f, F, g, h_plus, exitflag, iteracje, r*g^2]');
disp(wynKary);
fprintf('Excel: %s\n',excelPlik);
fprintf('Wykresy: %s\n',folderRys);
end

function aktualizujExcel(xlsx,rys,pkt,fKKT,lam,d2,xDok,xLok,xCon,fc,xCon2,fc2,kar,flag1,flag2)
folderTemp = tempname;
mkdir(folderTemp);
czysc = onCleanup(@() usunTemp(folderTemp));
unzip(xlsx,folderTemp);

% Podsumowanie, wiersze 7-11; E i F maja formuly Excela.
X = [xDok(:)';xLok(:)';xCon(:)';xCon2(:)';kar(end,2:3)];
fv = [0;fKKT(1);fc;fc2;kar(end,4)];
% fKKT(1) to minimum lokalne (-1.9966), bo t jest posortowane.
rv = [0;0;0;0;kar(end,1)];
for k=1:5
    row = k+6;
    numer(folderTemp,1,sprintf('B%d',row),X(k,1));
    numer(folderTemp,1,sprintf('C%d',row),X(k,2));
    numer(folderTemp,1,sprintf('D%d',row),fv(k));
    numer(folderTemp,1,sprintf('E%d',row),abs(sum(X(k,:))-2));
    numer(folderTemp,1,sprintf('F%d',row),max(0,sum(X(k,:))-3));
    numer(folderTemp,1,sprintf('G%d',row),rv(k));
end
% Punkty KKT, wiersze 6-8.
for k=1:3
    row=k+5;
    vals=[pkt(k,:) fKKT(k) lam(k) 0 d2(k)];
    cols='BCDEFG';
    for j=1:numel(cols)
        numer(folderTemp,2,sprintf('%c%d',cols(j),row),vals(j));
    end
end
% Funkcja kary, wiersze 7-10. Kolumny F,G to formuly w Excelu.
for k=1:size(kar,1)
    row=k+6;
    vals=[kar(k,2:5) kar(k,8:9)];
    cols='BCDEHI';
    numer(folderTemp,3,sprintf('F%d',row),abs(kar(k,6)));
    numer(folderTemp,3,sprintf('G%d',row),kar(k,7));
    for j=1:numel(cols)
        numer(folderTemp,3,sprintf('%c%d',cols(j),row),vals(j));
    end
end
% Png wchodza bezposrednio do gotowych miejsc w strukturze XLSX.
for k=1:numel(rys)
    if k==1, nazwaObrazu='image.png';
    else, nazwaObrazu=sprintf('image%d.png',k); end
    cel = fullfile(folderTemp,'xl','media',nazwaObrazu);
    if ~isfile(cel)
        error('Brak obrazu %s w szablonie. Nie mozna aktualizowac Excela.',cel);
    end
    copyfile(rys{k},cel,'f');
end
plikZip = [tempname '.zip'];
% Foldery i xml sa spakowane z taka sama struktura jak w xlsx.
zip(plikZip,{'[Content_Types].xml','_rels','docProps','xl'},folderTemp);
movefile(plikZip,xlsx,'f');
clear czysc;
end

function numer(folder,arkusz,adres,wartosc)
plik = fullfile(folder,'xl','worksheets',sprintf('sheet%d.xml',arkusz));
xml = fileread(plik);
wyrazenie = ['<x:c r="' adres '"[^>]*>[\s\S]*?</x:c>'];
[a,b] = regexp(xml,wyrazenie,'start','end','once');
if isempty(a)
    error('Nie znaleziono komorki %s w sheet%d.xml.',adres,arkusz);
end
fragment = xml(a:b);
wstaw = sprintf('<x:v>%.16g</x:v>',wartosc);
if isempty(regexp(fragment,'<x:v>[\s\S]*?</x:v>','once'))
    error('Komorka %s nie jest liczbowa - skontroluj szablon.',adres);
end
nowy = regexprep(fragment,'<x:v>[\s\S]*?</x:v>',wstaw,'once');
xml = [xml(1:a-1),nowy,xml(b+1:end)];
fid = fopen(plik,'w');
if fid < 0, error('Nie mozna zapisac %s',plik); end
fwrite(fid,xml,'char'); fclose(fid);
end

function usunTemp(folder)
if exist(folder,'dir'), rmdir(folder,'s'); end
end
