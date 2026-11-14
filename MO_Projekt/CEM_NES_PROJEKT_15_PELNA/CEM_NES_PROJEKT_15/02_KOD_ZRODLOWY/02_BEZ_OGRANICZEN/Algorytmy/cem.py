import numpy as np
from utilities.warunki_stopu import check_stop_conditions

def cross_entropy_method(objective_func, init_mean, init_std, pop_size=100, elite_frac=0.2, 
                         max_iter=1000, n_stall=10, tol_stall=1e-6):
    """
    Implementacja algorytmu Cross-Entropy Method (CEM) z kryterium stagnacji.
    
    Parametry:
    - objective_func: funkcja celu do zminimalizowania
    - init_mean: punkt startowy (początkowa średnia rozkładu, wektor numpy)
    - init_std: początkowe odchylenie standardowe (zasięg poszukiwań, wektor numpy)
    - pop_size: rozmiar populacji losowanej w każdej iteracji
    - elite_frac: ułamek najlepszych osobników (tzw. elity)
    - max_iter: maksymalna liczba iteracji (warunek stopu 1)
    - n_stall: liczba iteracji do stwierdzenia stagnacji (warunek stopu 2)
    - tol_stall: próg tolerancji dla różnicy wyników w stagnacji (warunek stopu 2)
    """
    mean = np.array(init_mean, dtype=float)
    std = np.array(init_std, dtype=float)
    dim = len(mean)
    n_elite = int(pop_size * elite_frac)
    
    history_mean = [mean.copy()]
    history_std = [std.copy()]
    history_best_f = []
    eval_count = 0

    for iteration in range(max_iter):
        # 1. Generowanie i ocena próbek
        samples = np.random.normal(loc=mean, scale=std, size=(pop_size, dim))
        scores = np.array([objective_func(sample) for sample in samples])
        eval_count += pop_size
        
        # 2. Selekcja elity
        elite_indices = np.argsort(scores)[:n_elite]
        elite_samples = samples[elite_indices]
        
        # Zapisanie najlepszego wyniku w historii (bardzo ważne dla warunku stagnacji)
        best_score = scores[elite_indices[0]]
        history_best_f.append(best_score)
        
        # 3. Aktualizacja rozkładu na podstawie elity
        mean = np.mean(elite_samples, axis=0)
        std = np.std(elite_samples, axis=0)
        history_mean.append(mean.copy())
        history_std.append(std.copy())
        
        # 4. Sprawdzanie warunków stopu (Max iteracje i Stagnacja)
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