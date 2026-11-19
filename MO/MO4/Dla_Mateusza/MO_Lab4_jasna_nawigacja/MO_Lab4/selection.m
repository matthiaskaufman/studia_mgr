function [new_gen, selected] = selection(old_gen, J)
% Selekcja ruletkowa - mniejsza wartosc J oznacza lepszego osobnika.
fit = 1 ./ (1 + J(:));
ruletka = cumsum(fit / sum(fit));
selected = zeros(size(J(:)));
for i = 1:length(selected)
    selected(i) = find(rand <= ruletka, 1, 'first');
end
new_gen = old_gen(selected, :);
end
