%Porównanie rozwi¹zania zadania minimalizacji funkcji celu z ograniczeniem rownosciowych 
% metod¹ Lagrange'a i metod¹ funkcji kary (z kar¹ kwadratow¹ ) oraz funkcj¹
% fminunc
%Zadanie: funkcja celu:  z(x,y)=x^2+y^2
%ograniczenia: 3*X+2*Y-8=0 

%.................metoda Lagrange'a..............................

%1. Rozwi¹zanie uk³adu warunków Lagrangea (zaimplementowane w pliku lagrange)
x0 = [4 3 3];
%options=optimset('Display','iter'); 
options=optimset('Display','off');      % Option to display output
[z,fval] = fsolve(@lagrange,x0,options);  % Call optimizer 
%rozw.  analityczne, metoda Lagrange'a :  [1.8462    1.2308   -1.2308]
% mo¿na tak¿e uzyæ funkcji fmincon

%...................Metoda FUNKCJI KARY.........................................
%dziedzina dyskretna funkcji celu (X,Y)i ograniczeñ (X1,Y1)- rectangular grid (siatka)
[X,Y] = meshgrid(-20:.5:20); 
Z = X.^2 + Y.^2; 
X1=-20:.5:20;
Y1=-(3/2)*X1+4;

disp('')
disp('Interpretacja graficzna metody funkjci kary')

% konstrukcja funkcji kary
%wykres przestrzenny funkcji celu bez kary
r=0;   
Z = X.^2 +Y.^2+r*(3*X+2*Y-8).^2;
figure(1)
surf(X,Y,Z,'EdgeColor','interp')

disp ('r=0 - wykres poziomic funkcji celu bez kary')
figure(2)
[c1,h1]=contour(X,Y,Z);
hold on
clabel(c1,h1);
hold on
plot(X1,Y1,'k' )  % Color is proportional to surface height
hold on
[C,R] = gradient(Z); %gradient numeryczny
%mesh(X,Y,Z)
%hold on
quiver(X,Y,C,R) %pole wektorowe 
pause

%............................................................
disp('')
disp('Wykresy funkcji kary i ograniczenia Y1 przy wzroœcie wartoœci r')
r=r+0.01;    % wzrost wartosci r
for i=0:1:3.  
Z = X.^2 +Y.^2+r*(3*X+2*Y-8).^2;
figure(3)
[c1,h1]=contour(X,Y,Z);
hold on
clabel(c1,h1);
hold on
plot(X1,Y1,'k' )  % Color is proportional to surface height
hold on
[C,R] = gradient(Z); %gradient numeryczny
%mesh(X,Y,Z)
%hold on
quiver(X,Y,C,R) %pole wektorowe 
r=r+0.01;
pause
end

disp('')
disp('Wykresy funkcji kary i ograniczenia Y1 dla odpowiednio duzej wartosci r, np. r=3')

r=3; % zapuscic wykresy dla r nawet do 10 - roznych ale d¹z¹cych do neskonczonosci
figure(4)
Z = X.^2 +Y.^2+r*(3*X+2*Y-8).^2;
[c1,h1]=contour(X,Y,Z);
hold on
clabel(c1,h1);
plot(X1,Y1,'k')  % Color is proportional to surface height
hold on
[C,R] = gradient(Z); %gradient numeryczny
%mesh(X,Y,Z)
hold on
quiver(X,Y,C,R) %pole wektorowe 
pause

% gdy r d¹zy do nieskonczonosci - wykres przestrzenny funkcji z kar¹ dla r=30
r=30;
figure(5)
Z = X.^2 +Y.^2+r*(3*X+2*Y-8).^2;
%Z = X.^2 +Y.^2-1*(3*X+2*Y-8);
surf(X,Y,Z,'EdgeColor','interp')

pause
%....................WYNIKI........................................
disp(' ')
disp('Podsumowanie')
disp('Rozwiazanie zadania optymalizacji funkcji z kar¹ i fminunc dla r=30')
r=30;
options = optimoptions(@fminunc,'Display','off','Algorithm','quasi-newton');
x = fminunc(@(x) x(1)^2 +x(2)^2+r*(3*x(1)+2*x(2)-8)^2,[2;2],options);

disp(' ')
disp('Rozwi¹zanie numeryczne metod¹ funkcji kary (x,y,r)')
X = sprintf('x=%d; y=%d; r=%d ',x,r);
disp(X)

disp(' ')
disp('Rozwi¹zanie analityczne metod¹ Lagrangea (x,y,lambda)')
X = sprintf('x=%d; y=%d; lambda=%d ',z);
disp(X)
%rozw numeryczne: x = 1.8414, y=1.2276
%rozw. analityczne metoda Lagrangea: x=1.8462, y=1.2308
