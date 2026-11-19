function [new_gen,selected] = selection(old_gen,fitness)
% SELECTION wybiera osobniki proporcjonalnie od ich funkcji prze¿ycia.
%	[NEW_GEN,SELECTED] = SELECTION(OLD_GEN,FITNESS) losuje osobniki z OLD_GEN.
%       Najpierw losuje pozycje na które skopiuje najlepszego osobnika
%       potem pozycje na których skopjuje drugiego osobnika, 
%       itd. 
%       NEW_GEN ma tak¹ sam¹ liczbê osobników jak OLD_GEN.
%       SELECTED zawiera indeksy (wierszy) wybranych osobników 
%       (tzn.: NEW_GEN=OLD_GEN(SELECTED,:)).
%

%fitness = [289 1059 99 699];
norm_fit = fitness/sum(fitness);
norm_fit_selection = norm_fit;
selected = rand(size(fitness));
%selected = [0.0976 0.3987 0.3584 0.2853];
sum_fit = 0;
for i=1:length(fitness),
   [best_fitness, index_best] = min( norm_fit_selection);      
   sum_fit = sum_fit + norm_fit(i);
   index = find(selected<sum_fit);
   selected(index) = index_best;
   if isempty(index) == 0, 
       norm_fit_selection;    
       norm_fit_selection(index_best) = index_best;
   end;
end
new_gen = old_gen(selected,:);
% end selection