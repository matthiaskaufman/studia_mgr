% Interpretacja graficzna mnozników (metody ) Lagrange'a 
% funkcja celu:  z(x,y)=x^2+y^2
% ograniczenia: 3*X+2*Y-8=0 

clc
clear

x0 = [4 3 3];

disp('Rozwi¹zanie analityczne metod¹ Lagrangea (x,y,lambda)')

options=optimset('Display','iter');   % Option to display output
[z,fval] = fsolve(@lagrange,x0,options);  % Call optimizer
%rozw.  [1.8462    1.2308   -1.2308]

A = sprintf('x=%d; y=%d; lambda=%d ',z);
disp(A)
pause


disp('')
disp('Interpretacja graficzna ekstremum warunkowego - metoda Lagrangea')

[X,Y] = meshgrid(-15:.5:15); %dziedzina dyskretna funkcji - rectangular grid (siatka)
Z = X.^2 + Y.^2; 
X1=-8:.5:8;
Y1=-(3/2)*X1+4;

lambda=-1.5   %wykres funkcji celu Z(x,y) i ograniczeñ Y1

for i=0:0.5:1.  % wykresy funkcji Lagrange'a L(x,y,lambda) i ograniczenia Y1 przy zmianie wartoœci Lambda
Z = X.^2 +Y.^2+lambda*(3*X+2*Y-8);
[c1,h1]=contour(X,Y,Z);
figure(1)
hold on
clabel(c1,h1);
hold on
plot(X1,Y1,'k' )  % Color is proportional to surface height
hold on
[C,R] = gradient(Z); %gradient numeryczny
%mesh(X,Y,Z)
%hold on
quiver(X,Y,C,R) %pole wektorowe 
lambda=lambda-0.5
pause
end


disp('Interpretacja graficzna ekstremum bezwarunkowego funkcji Lagrangea')
figure(2)
lambda=-1.2308
Z = X.^2 +Y.^2-1.2308*(3*X+2*Y-8);
%Z = X.^2 +Y.^2-1*(3*X+2*Y-8);
% surf(X,Y,Z,'EdgeColor','interp') 
% hold on
[c1,h1]=contour(X,Y,Z);
hold on
clabel(c1,h1);
plot(X1,Y1,'k')  % Color is proportional to surface height
hold on
[C,R] = gradient(Z); %gradient numeryczny
%mesh(X,Y,Z)
hold on
quiver(X,Y,C,R) %pole wektorowe 



%figure(3)
%subplot(2,1,1)
%surf(X,Y,Z,'EdgeColor','interp') 
% mesh(x,y,z) % mesh, surf, surfc
% view(30,60);
% colormap(hot)

% subplot(2,1,2)
% [c,h]=contour(X,Y,Z)
% colorbar 
% clabel(c,h)
% hold on
% [C,R] = gradient(Z); %gradient numeryczny
% %mesh(X,Y,Z)
% %hold on
% quiver(X,Y,C,R) %pole wektorowe 
% 
