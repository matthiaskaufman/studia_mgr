import numpy as np
import matplotlib.pyplot as plt

from Algorytmy.cem import cross_entropy_method
from Algorytmy.nes import natural_evolution_strategies

from Funkcje.rosenbrock import rosenbrock 
from Funkcje.three_hump_camel import three_hump_camel
from Funkcje.himmelblau import himmelblau

from utilities.wykresy import plot_convergence, plot_contour, plot_population_stages

from utilities.kary import zastosuj_kare, rosenbrock_z_ograniczeniem, camel_z_ograniczeniem, himmelblau_z_ograniczeniem

def main():
    print("Testowanie algorytmu CEM na różnych funkcjach optymalizacyjnych\n")
    OUTPUT_FOLDER = "raport_wykresy"

    # Tworzymy ograniczone wersje funkcji za pomocą lambd
    penalized_rosenbrock = lambda x: zastosuj_kare(x, rosenbrock_z_ograniczeniem, rosenbrock)
    penalized_camel = lambda x: zastosuj_kare(x, camel_z_ograniczeniem, three_hump_camel)
    penalized_himmelblau = lambda x: zastosuj_kare(x, himmelblau_z_ograniczeniem, himmelblau)
    
    # ---------------------------------------------------------
    print("\n1. Funkcja Rosenbrocka (z karą)")
    init_mean_rosen = np.array([2.5, 2.5]) # Punkt startowy
    init_std_rosen = np.array([5.0, 5.0])  # Rozrzut poszukiwań
    
    best_x_r, best_f_r, hist_x_r, hist_std_r, hist_f_r, eval_count_r = cross_entropy_method(
        objective_func=penalized_rosenbrock,
        init_mean=init_mean_rosen,
        init_std=init_std_rosen,
        pop_size=200,      # Rozmiar populacji
        elite_frac=0.1,    # Elityzm
        max_iter=500,      # Maksymalna liczba iteracji
        n_stall=20,        # Liczba iteracji do stwierdzenia stagnacji
        tol_stall=1e-6     # Tolerancja dla stagnacji
    )
    print(f"Znalezione minimum (x): {best_x_r}")
    print(f"Wartość funkcji f(x): {best_f_r:.6f}")
    print(f"Liczba wywołań funkcji celu: {eval_count_r}")
    
    # Rysowanie wykresów dla Rosenbrocka (zakres od -5 do 10)
    plot_convergence(hist_f_r, title="Zbieżność CEM - Rosenbrock (Kara)", save_dir=OUTPUT_FOLDER)
    
    plot_contour(rosenbrock, hist_x_r, bounds=[-5, 10, -5, 10], 
                 title="Ścieżka CEM - Rosenbrock (Kara)", constraint_type='rosenbrock', save_dir=OUTPUT_FOLDER)
                 
    plot_population_stages(rosenbrock, hist_x_r, hist_std_r, bounds=[-5, 10, -5, 10], 
                           title="Rozwój populacji CEM - Rosenbrock (Kara)", constraint_type='rosenbrock', save_dir=OUTPUT_FOLDER)

    # ---------------------------------------------------------
    print("\n2. Funkcja Three-Hump Camel (z karą)")
    init_mean_camel = np.array([2.0, 2.0])  # Punkt startowy
    init_std_camel = np.array([2.0, 2.0])   # Rozrzut poszukiwań
    
    best_x_c, best_f_c, hist_x_c, hist_std_c, hist_f_c, eval_count_c = cross_entropy_method(
        objective_func=penalized_camel,
        init_mean=init_mean_camel,
        init_std=init_std_camel,
        pop_size=100,      # Rozmiar populacji
        elite_frac=0.1,    # Elityzm
        max_iter=500,      # Maksymalna liczba iteracji
        n_stall=20,        # Liczba iteracji do stwierdzenia stagnacji
        tol_stall=1e-6     # Tolerancja dla stagnacji
    )
    print(f"Znalezione minimum (x): {best_x_c}")
    print(f"Wartość funkcji f(x): {best_f_c:.6f}")
    print(f"Liczba wywołań funkcji celu: {eval_count_c}")
    # Rysowanie wykresów dla Three-Hump Camel (zakres od -5 do 5)
    plot_convergence(hist_f_c, title="Zbieżność CEM - Three-Hump Camel (Kara)", save_dir=OUTPUT_FOLDER)
    plot_contour(three_hump_camel, hist_x_c, bounds=[-5, 5, -5, 5], title="Ścieżka CEM - Three-Hump Camel (Kara)", constraint_type='camel', save_dir=OUTPUT_FOLDER)
    # Wykres populacji
    plot_population_stages(three_hump_camel, hist_x_c, hist_std_c, bounds=[-5, 5, -5, 5], title="Rozwój populacji CEM - Camel (Kara)", constraint_type='camel', save_dir=OUTPUT_FOLDER)

    # ---------------------------------------------------------
    print("\n3. Funkcja Himmelblau (z karą)")
    init_mean_himm = np.array([0.0, 0.0])  # Punkt startowy
    init_std_himm = np.array([3.0, 3.0])   # Rozrzut poszukiwań
    
    best_x_h, best_f_h, hist_x_h, hist_std_h, hist_f_h, eval_count_h = cross_entropy_method(
        objective_func=penalized_himmelblau,
        init_mean=init_mean_himm,
        init_std=init_std_himm,
        pop_size=150,      # Rozmiar populacji
        elite_frac=0.1,    # Elityzm
        max_iter=500,      # Maksymalna liczba iteracji    
        n_stall=20,        # Liczba iteracji do stwierdzenia stagnacji
        tol_stall=1e-6     # Tolerancja dla stagnacji
    )
    print(f"Znalezione minimum (x): {best_x_h}")
    print(f"Wartość funkcji f(x): {best_f_h:.6f}")
    print(f"Liczba wywołań funkcji celu: {eval_count_h}")

    # Rysowanie wykresów dla Himmelblau (zakres od -5 do 5)
    plot_convergence(hist_f_h, title="Zbieżność CEM - Himmelblau (Kara)", save_dir=OUTPUT_FOLDER)
    plot_contour(himmelblau, hist_x_h, bounds=[-5, 5, -5, 5], title="Ścieżka CEM - Himmelblau (Kara)", constraint_type='himmelblau', save_dir=OUTPUT_FOLDER)
    # Wykres populacji
    plot_population_stages(himmelblau, hist_x_h, hist_std_h, bounds=[-5, 5, -5, 5], title="Rozwój populacji CEM - Himmelblau (Kara)", constraint_type='himmelblau', save_dir=OUTPUT_FOLDER)

# NESNESNESNESNESNESNESNESNESNESNESNESNESNESNESNESNESNESNESNESNESNESNESNESNESNESNESNESNESNESNES NES

    print("\nTestowanie algorytmu NES na różnych funkcjach optymalizacyjnych\n")
    
    # ---------------------------------------------------------
    print("\n1. Funkcja Rosenbrocka (z karą)")
    init_mean_rosen = np.array([2.5, 2.5]) # Punkt startowy
    init_std_rosen = np.array([5.0, 5.0])  # Rozrzut poszukiwań
    
    best_x_r_nes, best_f_r_nes, hist_x_r_nes, hist_std_r_nes, hist_f_r_nes, eval_count_r_nes = natural_evolution_strategies(
        objective_func=penalized_rosenbrock,
        init_mean=init_mean_rosen,
        init_std=init_std_rosen,
        pop_size=200,             # Rozmiar populacji
        learning_rate_mean=0.1,   # Krok uczenia dla średniej (NES)
        learning_rate_std=0.05,   # Krok uczenia dla rozrzutu (NES)
        max_iter=500,             # Maksymalna liczba iteracji
        n_stall=20,               # Liczba iteracji do stwierdzenia stagnacji
        tol_stall=1e-6            # Tolerancja dla stagnacji
    )
    print(f"Znalezione minimum (x): {best_x_r_nes}")
    print(f"Wartość funkcji f(x): {best_f_r_nes:.6f}")
    print(f"Liczba wywołań funkcji celu: {eval_count_r_nes}")
    # Rysowanie wykresów dla Rosenbrocka (zakres od -5 do 10)
    plot_convergence(hist_f_r_nes, title="Zbieżność NES - Rosenbrock (Kara)", save_dir=OUTPUT_FOLDER)
    plot_contour(rosenbrock, hist_x_r_nes, bounds=[-5, 10, -5, 10], title="Ścieżka NES - Rosenbrock (Kara)", constraint_type='rosenbrock', save_dir=OUTPUT_FOLDER)
    # Wykres populacji
    plot_population_stages(rosenbrock, hist_x_r_nes, hist_std_r_nes, bounds=[-5, 10, -5, 10], title="Rozwój populacji NES - Rosenbrock (Kara)", constraint_type='rosenbrock', save_dir=OUTPUT_FOLDER)

    # ---------------------------------------------------------
    print("\n2. Funkcja Three-Hump Camel (z karą)")
    init_mean_camel = np.array([2.0, 2.0])  # Punkt startowy
    init_std_camel = np.array([2.0, 2.0])   # Rozrzut poszukiwań
    
    best_x_c_nes, best_f_c_nes, hist_x_c_nes, hist_std_c_nes, hist_f_c_nes, eval_count_c_nes = natural_evolution_strategies(
        objective_func=penalized_camel,
        init_mean=init_mean_camel,
        init_std=init_std_camel,
        pop_size=100,             # Rozmiar populacji
        learning_rate_mean=0.1,   # Krok uczenia dla średniej (NES)
        learning_rate_std=0.05,   # Krok uczenia dla rozrzutu (NES)
        max_iter=500,             # Maksymalna liczba iteracji
        n_stall=20,               # Liczba iteracji do stwierdzenia stagnacji
        tol_stall=1e-6            # Tolerancja dla stagnacji
    )
    print(f"Znalezione minimum (x): {best_x_c_nes}")
    print(f"Wartość funkcji f(x): {best_f_c_nes:.6f}")
    print(f"Liczba wywołań funkcji celu: {eval_count_c_nes}")

    # Rysowanie wykresów dla Three-Hump Camel (zakres od -5 do 5)
    plot_convergence(hist_f_c_nes, title="Zbieżność NES - Three-Hump Camel (Kara)", save_dir=OUTPUT_FOLDER)
    plot_contour(three_hump_camel, hist_x_c_nes, bounds=[-5, 5, -5, 5], title="Ścieżka NES - Three-Hump Camel (Kara)", constraint_type='camel', save_dir=OUTPUT_FOLDER)
    # Wykres populacji
    plot_population_stages(three_hump_camel, hist_x_c_nes, hist_std_c_nes, bounds=[-5, 5, -5, 5], title="Rozwój populacji NES - Camel (Kara)", constraint_type='camel', save_dir=OUTPUT_FOLDER)

    # ---------------------------------------------------------
    print("\n3. Funkcja Himmelblau (z karą)")
    init_mean_himm = np.array([0.0, 0.0])  # Punkt startowy
    init_std_himm = np.array([3.0, 3.0])   # Rozrzut poszukiwań
    
    best_x_h_nes, best_f_h_nes, hist_x_h_nes, hist_std_h_nes, hist_f_h_nes, eval_count_h_nes = natural_evolution_strategies(
        objective_func=penalized_himmelblau,
        init_mean=init_mean_himm,
        init_std=init_std_himm,
        pop_size=150,             # Rozmiar populacji
        learning_rate_mean=0.1,   # Krok uczenia dla średniej (NES)
        learning_rate_std=0.05,   # Krok uczenia dla rozrzutu (NES)
        max_iter=500,             # Maksymalna liczba iteracji    
        n_stall=20,               # Liczba iteracji do stwierdzenia stagnacji
        tol_stall=1e-6            # Tolerancja dla stagnacji
    )
    print(f"Znalezione minimum (x): {best_x_h_nes}")
    print(f"Wartość funkcji f(x): {best_f_h_nes:.6f}")
    print(f"Liczba wywołań funkcji celu: {eval_count_h_nes}")
    
    # Rysowanie wykresów dla Himmelblau (zakres od -5 do 5)
    plot_convergence(hist_f_h_nes, title="Zbieżność NES - Himmelblau (Kara)", save_dir=OUTPUT_FOLDER)
    plot_contour(himmelblau, hist_x_h_nes, bounds=[-5, 5, -5, 5], title="Ścieżka NES - Himmelblau (Kara)", constraint_type='himmelblau', save_dir=OUTPUT_FOLDER)
    # Wykres populacji
    plot_population_stages(himmelblau, hist_x_h_nes, hist_std_h_nes, bounds=[-5, 5, -5, 5], title="Rozwój populacji NES - Himmelblau (Kara)", constraint_type='himmelblau', save_dir=OUTPUT_FOLDER)

    plt.show()

if __name__ == "__main__":
    main()