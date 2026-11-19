%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% evolve_pd
% Program do strojenia regulatora PID przy u¿yciu algorytmu genetycznego
%
% WskaŸniki jakoœci (funkcje kary)
% indice: 1 - Jc = w1*e^2 + w2*delta^2    ISE
% indice: 2 - Jc2 = w1*abs(e) + w2*abs(delta) IAE
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function evolve_pd_5

clear
close all
echo off
clc

index = 1;  % zmiania funkcji celu
NUMBER = 4; % zmiania nazwy pliku z wynikami

disp(['Index : ', num2str(index)])
disp(['Number : ', num2str(NUMBER)])


simulink_mdl = 'ex_5';

% wagi funkjci celu
w1 = 1; 
w2 = 0.1;

tstop = 15;

% Ustawienie zakresu zmiany parametrów algorytmu genetycznego
k1_min = 0;
k1_max = 10;
k2_min = 0;
k2_max = 10;
k3_min = 0;
k3_max = 10;

max_gen = 4;            % maksymalna liczba generacji (20),
size_pop = 10;           % Rozmiar populacji chromosomów, (40)
bits = [10 14 14];       % Liczba bitów na których kodowany jest pojedynczy parametr

open_system([simulink_mdl,'.slx'])

terminate = 0.0000001;   % warunek stopu - parametr zbieznosci funkjcji celu

lchrom = bits;
vlb = [k1_min k2_min k3_min];
vub = [k1_max k2_max k3_max];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
x0=[];

%konwersja wektora x0 o wartoœciach rzeczywistych na reprezentacjê binarn¹.

[fgen,lchrom] = encode(x0,vlb,vub,bits);     
% wygenerowanie nowej populacji chromosomów metod¹ "bit po bicie"
if size(fgen,1)<size_pop,
    fgen = [fgen; (rand(size_pop-size(fgen,1),lchrom)<0.5)];
end
new_gen = fgen;
Jcl = 0*ones(size_pop,max_gen); 


Pc = 0.02;    % Prawdopodobieñstwo wyst¹pienia krzy¿owania 0.5 ( inne do sprawdzenia : 0.02, 0.8 1 dla size_pop =20, max_gen=10)
Pm = 0.6;     % Prawdopodobieñstwo wyst¹pienia mutacji 0.03 (inne do sprawdzenia : 0.6, 0.01 0)

%Przyk³adowe wartoœci
%1. Dla Pm=0 i Pc=1 - brak recombinacji, wybierany ten sam osobnik,
%   silny nacisk selektywny, zwiêkszenie max_gen nic nie da
%2. Dla Pm=0.6 i Pc=0.02 - ci¹g³a recombinacja, brak zbieznoœci, 
%   s³aby nacisk selektywny

stats = [];

disp(['Numer generacji:']);       
STOP_FLAG = 0;
OPT_STOP = 1;

k = 1;
while STOP_FLAG ~= 1,    
   disp(k);
   old_gen = new_gen;
   k1k2k3_pop = decode( new_gen,vlb,vub,bits);   

   for ss=1:size_pop,
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Strojone parametry  :
        k1 = k1k2k3_pop(ss,1);
        k2 = k1k2k3_pop(ss,2);
        k3 = k1k2k3_pop(ss,3);
        %macierze przechowujace wyniki w poszczegolnych genracjach
        k1_size(ss,k)= k1k2k3_pop(ss,1);
        k2_size(ss,k)= k1k2k3_pop(ss,2);
        k3_size(ss,k)= k1k2k3_pop(ss,3);


        set_param([simulink_mdl,'/PID'],'Kp',num2str(k1),'Kd',num2str(k2),'Ki',num2str(k3));
        sim(simulink_mdl, tstop)
        t_tab= simout(:,1)';
        r_tab= simout(:,2)';
        y_tab= simout(:,3)';
        d_tab= simout(:,4)';
        [m,n]= size(simout);
        ones_tab= ones(1,m);

         switch index 
            case 1 
                Jc1(ss,k) = w1*(y_tab-r_tab)*(y_tab-r_tab)' + w2*d_tab*d_tab';
            case 2 
                Jc1(ss,k) = w1*abs(y_tab-r_tab)*ones_tab' + w2*abs(d_tab)*ones_tab';
        end;
        fitness(ss) = Jc1(ss,k);

    end;  

    [Jbest(k),bestone(k)] = min(Jc1(:,k)); % Zachowaj najlepsze parametry do wykreœlenia
    k1best(k) = k1k2k3_pop( bestone(k),1);
    k2best(k) = k1k2k3_pop( bestone(k),2);
    k3best(k) = k1k2k3_pop( bestone(k),3);
   
    stats = [stats; min(fitness) max(fitness) mean(fitness) std(fitness)];
   
    generation = k;    
    if terminate>0,
      if generation>5,
         if ( (stats(generation-5,1)-stats(generation,1))/ ...
               stats(generation,1)<terminate ) & ...
            (stats(generation,1)<stats(generation-5,1)),
            STOP_FLAG = 1;
         end
      elseif generation>1,
         if ( (stats(generation-1,3)-stats(generation,3))/ ...
               stats(generation,3)<terminate ) & ...
            (stats(generation,3)<stats(generation-1,3)),
            STOP_FLAG = 1;
         end
      end
    end

    if STOP_FLAG,
      fprintf('\n')
      disp('Algorytm genetyczny jest zbie¿ny')   
    end

    % Selekcja - wybór puli rodzicielskiej
   new_gen = selection(old_gen,fitness);

   % Mate - mieszanie chromosomów po selekcji 
   new_gen = mate(new_gen);

   % Krzy¿owanie - tworzenie nowych chromosomów
   new_gen = xover(new_gen,Pc);

   % Mutacja - mutowanie losowo wybranych bitów w populacji
   new_gen = mutate(new_gen,Pm);

   if k > max_gen,
       STOP_FLAG = 1; 
   end;    
   if STOP_FLAG == 0,
       k = k+1;    
   else
       max_gen = k-1;
   end    
end; % max_gen    - koniec pêtli

% wygenerowanie rozwi¹zañ na plaszczyznie R3
for k=1:1:max_gen,
figure (6)
plot3(k1_size(1:size_pop,k),k2_size(1:size_pop,k),k3_size(1:size_pop,k),'o');
hold on
pause
end

pause

% Wygenerowanie przebiegu czasowego dla najlepszych rozwi¹zañ
k1 = k1best(k);
k2 = k2best(k);
k3 = k3best(k);

set_param([simulink_mdl,'/PID'],'Kp',num2str(k1),'Kd',num2str(k2),'Ki',num2str(k3));
sim( simulink_mdl, tstop)

%save_system
%close_system

t_tab= simout(:,1)';
r_tab= simout(:,2)';
y_tab= simout(:,3)';
u_tab= simout(:,4)';

wyniki.time = t_tab;
wyniki.r_zad = r_tab;
wyniki.y_tab = y_tab;
wyniki.u_tab = u_tab;
wyniki.max_gen = max_gen;
wyniki.Jbest = Jbest;
wyniki.k1best = k1best;
wyniki.k2best = k2best;
wyniki.k3best = k3best;

switch index
  case 1 
    wyniki_pd_Jc1 = wyniki;
    if NUMBER == 1,
        save evolve_pd_1_Jc1 wyniki_pd_Jc1
    elseif NUMBER == 2,        
        save evolve_pd_2_Jc1 wyniki_pd_Jc1        
    elseif NUMBER == 3,        
        save evolve_pd_3_Jc1 wyniki_pd_Jc1        
    elseif NUMBER == 4,        
        save evolve_pd_4_Jc1 wyniki_pd_Jc1        
    elseif NUMBER == 5,        
        save evolve_pd_5_Jc1 wyniki_pd_Jc1        
    elseif NUMBER == 6,        
        save evolve_pd_6_Jc1 wyniki_pd_Jc1        
    elseif NUMBER == 7,        
        save evolve_pd_7_Jc1 wyniki_pd_Jc1        
    elseif NUMBER == 8,        
        save evolve_pd_8_Jc1 wyniki_pd_Jc1        
    elseif NUMBER == 9,        
        save evolve_pd_9_Jc1 wyniki_pd_Jc1        
    elseif NUMBER == 10,        
        save evolve_pd_10_Jc1 wyniki_pd_Jc1        
    end        
case 2 
    wyniki_pd_Jc2 = wyniki;
    save evolve_pd_1_Jc2  wyniki_pd_Jc2     
end;    

figure(1)
clf
plot( t_tab, y_tab, 'k-', t_tab, r_tab, 'k-.')
zoom
grid on
title('Odpowiedz uk³adu dla najlepszych parametrow')
xlabel('Czas')

figure(2)
clf
plot([0:max_gen],Jbest,'k-')
zoom
grid on
title('WskaŸnik jakoœci J_c_l dla najlepszego regulatora')
xlabel('Generacje')

figure(3)
clf
plot([0:max_gen], k1best,'k-')
zoom
grid on
title('Wzmocnienie Kp')
xlabel('Generacje')

figure(4)
clf
plot([0:max_gen],k2best,'k-')
zoom
grid on
title('Wzmocnienie Kd')
xlabel('Generacje')

figure(5)
clf
plot([0:max_gen],k3best,'k-')
zoom
grid on
title('Wzmocnienie Ki')
xlabel('Generacje')

