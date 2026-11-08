function [A, B, C, D] = bicycle_matrices(par, Ts, aux)
% BICYCLE_MATRICES  Macierze przestrzeni stanow modelu rowerowego dla idgrey.
%
%   Sygnatura zgodna z wymaganiem idgrey:
%     [A, B, C, D] = fcn(par, Ts, aux)
%
%   Argumenty:
%     par  - wektor estymowanych parametrow: par(1)=Cf, par(2)=Cr [N/rad]
%     Ts   - okres probkowania (nieuzywany; model ciagly, FCT='c')
%     aux  - wektor stalych parametrow: [m, Iz, a, b, Vx]
%
%   Wyjscia: macierze A, B, C, D modelu ciaglego
%
%   Model rowerowy dynamiki poprzecznej pojazdu (Rajamani, 2012).
%   Stan: x = [v_y; r], wejscie: u = delta, wyjscie: y = r.
%   Zalozenie: liniowa zaleznosc sily bocznej od kata znoszenia.
%   Konwencja znakow katow znoszenia:
%     alfa_f = delta - (v_y + a*r)/Vx
%     alfa_r = -(v_y - b*r)/Vx

Cf = par(1) * 1000;   
Cr = par(2) * 1000;
m  = aux(1);   
Iz = aux(2);
a  = aux(3);   
b  = aux(4);   
Vx = aux(5);

A = [-(Cf+Cr)/(m*Vx), ((b*Cr - a*Cf)/(m*Vx) - Vx);
     -(a*Cf - b*Cr)/(Iz*Vx),  -(a^2*Cf + b^2*Cr)/(Iz*Vx)];
B = [Cf/m;
     a*Cf/Iz];
C = [0, 1]; % wyjscie: predkosc katowa odchylenia r
D = 0;
end