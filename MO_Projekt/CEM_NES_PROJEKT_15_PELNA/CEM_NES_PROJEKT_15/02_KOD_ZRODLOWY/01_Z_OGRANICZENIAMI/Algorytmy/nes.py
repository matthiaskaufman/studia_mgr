import numpy as np
from utilities.warunki_stopu import check_stop_conditions

def natural_evolution_strategies(objective_func, init_mean, init_std, pop_size=100, 
                                 learning_rate_mean=0.1, learning_rate_std=0.05,
                                 max_iter=1000, n_stall=20, tol_stall=1e-6):
    """
    Implementacja algorytmu Natural Evolution Strategies (NES) dla problemów minimalizacji.
    
    Parametry:
    - objective_func: funkcja celu do zminimalizowania
    - init_mean: punkt startowy (początkowa średnia rozkładu, wektor numpy)
    - init_std: początkowe odchylenie standardowe (wektor numpy)
    - pop_size: rozmiar populacji
    - learning_rate_mean: krok uczenia dla przesunięcia średniej
    - learning_rate_std: krok uczenia dla zmiany rozrzutu (std)
    - max_iter, n_stall, tol_stall: parametry warunków stopu
    """
    mean = np.array(init_mean, dtype=float)
    std = np.array(init_std, dtype=float)
    dim = len(mean)
    
    history_mean = [mean.copy()]
    history_std = [std.copy()]
    history_best_f = []
    eval_count = 0
    
    for iteration in range(max_iter):
        # 1. Generowanie szumu i próbek (Sampling)
        # Losujemy szum ze standardowego rozkładu normalnego N(0, 1)
        z = np.random.randn(pop_size, dim)
        # Nakładamy szum na naszą obecną średnią i odchylenie
        samples = mean + std * z
        
        # 2. Ocena (Evaluation)
        scores = np.array([objective_func(sample) for sample in samples])
        eval_count += pop_size
        # Zapisujemy najlepszy wynik do historii (do warunków stopu i wykresów)
        best_score = np.min(scores)
        history_best_f.append(best_score)
        
        # 3. Normalizacja wyników (Fitness Shaping)
        # Bardzo ważny krok w NES - zapobiega zdominowaniu gradientu przez jeden ekstremalny wynik
        scores_std = np.std(scores)
        if scores_std == 0:
            scores_std = 1e-8 # Zabezpieczenie przed dzieleniem przez zero
            
        normalized_scores = (scores - np.mean(scores)) / scores_std
        
        # 4. Szacowanie gradientu i aktualizacja (Update)
        # Liczymy, jak szum (z) wpłynął na znormalizowany wynik.
        # UWAGA: ponieważ MINIMALIZUJEMY funkcję, idziemy w kierunku UJEMNEGO gradientu
        grad_mean = np.dot(z.T, normalized_scores) / pop_size
        grad_std = np.dot((z**2 - 1).T, normalized_scores) / pop_size
        
        # Przesuwamy rozkład
        mean = mean - learning_rate_mean * std * grad_mean
        std = std - learning_rate_std * std * grad_std
        
        # Zabezpieczenie: odchylenie standardowe nie może spaść poniżej zera
        std = np.maximum(std, 1e-6)
        
        history_mean.append(mean.copy())
        history_std.append(std.copy())
        
        # 5. Sprawdzanie warunków stopu
        stop_reached, message = check_stop_conditions(
            iteration=iteration, 
            max_iter=max_iter,
            history_best_f=history_best_f,
            n_stall=n_stall,
            tol_stall=tol_stall
        )
        
        if stop_reached:
            print(message)
            break
            
    return mean, best_score, history_mean, history_std, history_best_f, eval_count