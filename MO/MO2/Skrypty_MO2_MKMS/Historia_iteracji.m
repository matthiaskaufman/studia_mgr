function Historia_iteracji
% Osobno: przebieg parametrow w kolejnych iteracjach
clc; close all;
copyfile('dane1_wah_grupa4.mat','dane1_wah_grupa1.mat','f');
dane = load('dane1_wah_grupa4.mat');

xRef = dane.dane1.ym(:,1);
phiRef = dane.dane1.ym(:,2);
lambda0 = [0.4 0.1 0.35];
lb = [1e-6 1e-6 1e-6];
ub = [2 1 1];

hist1 = [0 lambda0];
hist2 = [0 lambda0];

%% lsqnonlin
f1 = @(lambda) fObjectiveFunctionReturnVector(lambda,xRef,phiRef);
opcje1 = optimoptions('lsqnonlin','OutputFcn',@zapis1);
[wynik1,resnorm,~,~,info1] = lsqnonlin(f1,lambda0,lb,ub,opcje1);

%% fmincon
f2 = @(lambda) fObjectiveFunctionReturnScalar(lambda,xRef,phiRef);
opcje2 = optimoptions('fmincon','OutputFcn',@zapis2);
[wynik2,fval,~,info2] = fmincon(f2,lambda0,[],[],[],[],lb,ub,[],opcje2);

%% Tabele iteracji
T1 = array2table(hist1,'VariableNames',{'Iteracja','m','l','I'});
T2 = array2table(hist2,'VariableNames',{'Iteracja','m','l','I'});
format long g
disp('lsqnonlin:'); disp(T1)
disp('fmincon:'); disp(T2)

%% Wykresy parametrow
figure;
plot(hist1(:,1),hist1(:,2:4),'-o');
legend('m','l','I'); xlabel('Iteracja'); ylabel('Wartosc parametru');
title('Zmiana parametrow - lsqnonlin'); grid on;

figure;
plot(hist2(:,1),hist2(:,2:4),'-o');
legend('m','l','I'); xlabel('Iteracja'); ylabel('Wartosc parametru');
title('Zmiana parametrow - fmincon'); grid on;

fprintf('lsqnonlin: %d iteracji, J = %.6g\n',info1.iterations,resnorm);
fprintf('fmincon: %d iteracji, J = %.6g\n',info2.iterations,fval);

%% Zapis kolejnych punktow przez solvery
    function stop = zapis1(lambda,info,state)
        stop = false;
        if strcmp(state,'iter') && info.iteration > 0
            hist1(end+1,:) = [info.iteration lambda(:)'];
        end
    end

    function stop = zapis2(lambda,info,state)
        stop = false;
        if strcmp(state,'iter') && info.iteration > 0
            hist2(end+1,:) = [info.iteration lambda(:)'];
        end
    end
end
