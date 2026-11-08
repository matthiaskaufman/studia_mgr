

dt = 0.01;
Tstop = 20;


%% 1. Dane uczące

t = (0:dt:Tstop)';

Uw = [t, 300 + 50*(mod(floor(t),2)*2-1)];
Ut = [t, min(400, 20*t)];
M  = [t, 5 + 3*(mod(floor(t/3),2)*2-1)];



X = [Uw(:,2)'; Ut(:,2)'; M(:,2)'];
Y = [Iw_s(:)'; It_s(:)'; omega_s(:)'];

N = min(size(X,2), size(Y,2));
X = X(:,1:N);
Y = Y(:,1:N);
t = t(1:N);

Xseq = con2seq(X);
Yseq = con2seq(Y);

%% 2. Sieć NARX

inputDelays = 1:3;
feedbackDelays = 1:3;
hiddenNeurons = 10;

net = narxnet(inputDelays, feedbackDelays, hiddenNeurons);

net.trainFcn = 'trainlm';

net.divideParam.trainRatio = 0.70;
net.divideParam.valRatio   = 0.15;
net.divideParam.testRatio  = 0.15;

%% 3. Uczenie NARX

[Xs, Xi, Ai, Ts] = preparets(net, Xseq, {}, Yseq);

disp('Uczenie sieci NARX...')
[net, tr] = train(net, Xs, Ts, Xi, Ai);

%% 4. Sprawdzenie na danych uczących

Ynet = net(Xs, Xi, Ai);

Ynet_mat = cell2mat(Ynet);
Ysim_mat = cell2mat(Ts);

e = Ysim_mat - Ynet_mat;

MSE_train = mean(e(:).^2);
RMSE_train = sqrt(MSE_train);
MAE_train = mean(abs(e(:)));

disp(' ')
disp('--- WYNIKI NA DANYCH UCZĄCYCH ---')
disp(['MSE_train  = ', num2str(MSE_train)])
disp(['RMSE_train = ', num2str(RMSE_train)])
disp(['MAE_train  = ', num2str(MAE_train)])

%% 5. Nowe dane testowe

t_test = (0:dt:Tstop)';

Uw = [t_test, 300 + 70*(mod(floor(t_test/1.5),2)*2-1)];

Ut_value = 400*(1-exp(-0.35*t_test)) + 20*sin(2*t_test);
Ut_value = max(0, min(400, Ut_value));
Ut = [t_test, Ut_value];

M = [t_test, 5 + 2*(mod(floor(t_test/4),2)*2-1)];



Xtest = [Uw(:,2)'; Ut(:,2)'; M(:,2)'];
Ytest = [Iw_s(:)'; It_s(:)'; omega_s(:)'];

Ntest = min(size(Xtest,2), size(Ytest,2));
Xtest = Xtest(:,1:Ntest);
Ytest = Ytest(:,1:Ntest);
t_test = t_test(1:Ntest);

Xtestseq = con2seq(Xtest);
Ytestseq = con2seq(Ytest);

%% 6. Test NARX na nowych danych

[Xt, Xti, Ati, Tt] = preparets(net, Xtestseq, {}, Ytestseq);

Ytest_net = net(Xt, Xti, Ati);

Ytest_net_mat = cell2mat(Ytest_net);
Ytest_sim_mat = cell2mat(Tt);

e_test = Ytest_sim_mat - Ytest_net_mat;

MSE_test = mean(e_test(:).^2);
RMSE_test = sqrt(MSE_test);
MAE_test = mean(abs(e_test(:)));

disp(' ')
disp('--- WYNIKI NA NOWYCH DANYCH TESTOWYCH ---')
disp(['MSE_test  = ', num2str(MSE_test)])
disp(['RMSE_test = ', num2str(RMSE_test)])
disp(['MAE_test  = ', num2str(MAE_test)])

t_plot = t_test(end-size(Ytest_net_mat,2)+1:end);

%% 7. Wykresy

figure
plot(t_plot(:), Ytest_sim_mat(1,:).', 'LineWidth', 1.2)
hold on
plot(t_plot(:), Ytest_net_mat(1,:).', '--', 'LineWidth', 1.2)
grid on
title('NARX: porównanie Iw')
xlabel('czas [s]')
ylabel('Iw [A]')
legend('Model Simulink', 'Sieć NARX')

figure
plot(t_plot(:), Ytest_sim_mat(2,:).', 'LineWidth', 1.2)
hold on
plot(t_plot(:), Ytest_net_mat(2,:).', '--', 'LineWidth', 1.2)
grid on
title('NARX: porównanie It')
xlabel('czas [s]')
ylabel('It [A]')
legend('Model Simulink', 'Sieć NARX')

figure
plot(t_plot(:), Ytest_sim_mat(3,:).', 'LineWidth', 1.2)
hold on
plot(t_plot(:), Ytest_net_mat(3,:).', '--', 'LineWidth', 1.2)
grid on
title('NARX: porównanie omega')
xlabel('czas [s]')
ylabel('\omega [rad/s]')
legend('Model Simulink', 'Sieć NARX')

figure
plot(t_plot(:), e_test(1,:).')
grid on
title('NARX: błąd Iw')
xlabel('czas [s]')
ylabel('Iw model - Iw sieć')

figure
plot(t_plot(:), e_test(2,:).')
grid on
title('NARX: błąd It')
xlabel('czas [s]')
ylabel('It model - It sieć')

figure
plot(t_plot(:), e_test(3,:).')
grid on
title('NARX: błąd omega')
xlabel('czas [s]')
ylabel('\omega model - \omega sieć')

%% 8. Zapis i blok do Simulinka

save('siec_silnika_NARX.mat', ...
    'net', 'tr', ...
    'MSE_train', 'RMSE_train', 'MAE_train', ...
    'MSE_test', 'RMSE_test', 'MAE_test', ...
    'inputDelays', 'feedbackDelays', 'hiddenNeurons')

gensim(net)