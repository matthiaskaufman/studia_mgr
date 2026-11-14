import numpy as np
import matplotlib.pyplot as plt

from Algorytmy.cem import cross_entropy_method
from Algorytmy.nes import natural_evolution_strategies

from Funkcje.rosenbrock import rosenbrock 
from Funkcje.three_hump_camel import three_hump_camel
from Funkcje.himmelblau import himmelblau

from utilities.wykresy import plot_convergence, plot_contour, plot_population_stages

def main():
    print("=== Testowanie algorytmów BEZ OGRANICZEŃ (wersja bazowa) ===\n")
    
    # Wykresy zapiszą się w osobnym folderze, żeby nie pomieszać ich z tymi z karą!
    OUTPUT_FOLDER = "raport_wykresy_bez_kar" 
    
    # =========================================================
    # 1. FUNKCJA ROSENBROCKA
    # =========================================================
    print("\n--- 1. Funkcja Rosenbrocka ---")
    init_mean_rosen = np.array([2.5, 2.5]) 
    init_std_rosen = np.array([5.0, 5.0])  
    
    # --- CEM ---
    best_x_r, best_f_r, hist_x_r, hist_std_r, hist_f_r, evals_r = cross_entropy_method(
        objective_func=rosenbrock, # Przekazujemy czystą funkcję
        init_mean=init_mean_rosen, init_std=init_std_rosen,
        pop_size=200, elite_frac=0.1, max_iter=500, n_stall=20, tol_stall=1e-6
    )
    print(f"[CEM] Znalezione minimum (x): {best_x_r}")
    print(f"[CEM] Wartość funkcji f(x): {best_f_r:.6f}")
    print(f"[CEM] Wywołań funkcji celu (NFE): {evals_r}")
    
    plot_convergence(hist_f_r, title="Zbieżność CEM - Rosenbrock", save_dir=OUTPUT_FOLDER)
    plot_contour(rosenbrock, hist_x_r, bounds=[-5, 10, -5, 10], title="Ścieżka CEM - Rosenbrock", save_dir=OUTPUT_FOLDER)
    plot_population_stages(rosenbrock, hist_x_r, hist_std_r, bounds=[-5, 10, -5, 10], title="Rozwój populacji CEM - Rosenbrock", save_dir=OUTPUT_FOLDER)

    # --- NES ---
    best_x_r_nes, best_f_r_nes, hist_x_r_nes, hist_std_r_nes, hist_f_r_nes, evals_r_nes = natural_evolution_strategies(
        objective_func=rosenbrock, # Przekazujemy czystą funkcję
        init_mean=init_mean_rosen, init_std=init_std_rosen,
        pop_size=200, learning_rate_mean=0.1, learning_rate_std=0.05, 
        max_iter=500, n_stall=20, tol_stall=1e-6
    )
    print(f"[NES] Znalezione minimum (x): {best_x_r_nes}")
    print(f"[NES] Wartość funkcji f(x): {best_f_r_nes:.6f}")
    print(f"[NES] Wywołań funkcji celu (NFE): {evals_r_nes}")
    
    plot_convergence(hist_f_r_nes, title="Zbieżność NES - Rosenbrock", save_dir=OUTPUT_FOLDER)
    plot_contour(rosenbrock, hist_x_r_nes, bounds=[-5, 10, -5, 10], title="Ścieżka NES - Rosenbrock", save_dir=OUTPUT_FOLDER)
    plot_population_stages(rosenbrock, hist_x_r_nes, hist_std_r_nes, bounds=[-5, 10, -5, 10], title="Rozwój populacji NES - Rosenbrock", save_dir=OUTPUT_FOLDER)


    # =========================================================
    # 2. FUNKCJA THREE-HUMP CAMEL
    # =========================================================
    print("\n--- 2. Funkcja Three-Hump Camel ---")
    init_mean_camel = np.array([2.0, 2.0])  
    init_std_camel = np.array([2.0, 2.0])   
    
    # --- CEM ---
    best_x_c, best_f_c, hist_x_c, hist_std_c, hist_f_c, evals_c = cross_entropy_method(
        objective_func=three_hump_camel,
        init_mean=init_mean_camel, init_std=init_std_camel,
        pop_size=100, elite_frac=0.1, max_iter=500, n_stall=20, tol_stall=1e-6
    )
    print(f"[CEM] Znalezione minimum (x): {best_x_c}")
    print(f"[CEM] Wartość funkcji f(x): {best_f_c:.6f}")
    print(f"[CEM] Wywołań funkcji celu (NFE): {evals_c}")

    plot_convergence(hist_f_c, title="Zbieżność CEM - Three-Hump Camel", save_dir=OUTPUT_FOLDER)
    plot_contour(three_hump_camel, hist_x_c, bounds=[-5, 5, -5, 5], title="Ścieżka CEM - Three-Hump Camel", save_dir=OUTPUT_FOLDER)
    plot_population_stages(three_hump_camel, hist_x_c, hist_std_c, bounds=[-5, 5, -5, 5], title="Rozwój populacji CEM - Camel", save_dir=OUTPUT_FOLDER)

    # --- NES ---
    best_x_c_nes, best_f_c_nes, hist_x_c_nes, hist_std_c_nes, hist_f_c_nes, evals_c_nes = natural_evolution_strategies(
        objective_func=three_hump_camel,
        init_mean=init_mean_camel, init_std=init_std_camel,
        pop_size=100, learning_rate_mean=0.1, learning_rate_std=0.05, 
        max_iter=500, n_stall=20, tol_stall=1e-6
    )
    print(f"[NES] Znalezione minimum (x): {best_x_c_nes}")
    print(f"[NES] Wartość funkcji f(x): {best_f_c_nes:.6f}")
    print(f"[NES] Wywołań funkcji celu (NFE): {evals_c_nes}")

    plot_convergence(hist_f_c_nes, title="Zbieżność NES - Three-Hump Camel", save_dir=OUTPUT_FOLDER)
    plot_contour(three_hump_camel, hist_x_c_nes, bounds=[-5, 5, -5, 5], title="Ścieżka NES - Three-Hump Camel", save_dir=OUTPUT_FOLDER)
    plot_population_stages(three_hump_camel, hist_x_c_nes, hist_std_c_nes, bounds=[-5, 5, -5, 5], title="Rozwój populacji NES - Camel", save_dir=OUTPUT_FOLDER)


    # =========================================================
    # 3. FUNKCJA HIMMELBLAU
    # =========================================================
    print("\n--- 3. Funkcja Himmelblau ---")
    init_mean_himm = np.array([0.0, 0.0])  
    init_std_himm = np.array([3.0, 3.0])   
    
    # --- CEM ---
    best_x_h, best_f_h, hist_x_h, hist_std_h, hist_f_h, evals_h = cross_entropy_method(
        objective_func=himmelblau,
        init_mean=init_mean_himm, init_std=init_std_himm,
        pop_size=150, elite_frac=0.1, max_iter=500, n_stall=20, tol_stall=1e-6
    )
    print(f"[CEM] Znalezione minimum (x): {best_x_h}")
    print(f"[CEM] Wartość funkcji f(x): {best_f_h:.6f}")
    print(f"[CEM] Wywołań funkcji celu (NFE): {evals_h}")
    
    plot_convergence(hist_f_h, title="Zbieżność CEM - Himmelblau", save_dir=OUTPUT_FOLDER)
    plot_contour(himmelblau, hist_x_h, bounds=[-5, 5, -5, 5], title="Ścieżka CEM - Himmelblau", save_dir=OUTPUT_FOLDER)
    plot_population_stages(himmelblau, hist_x_h, hist_std_h, bounds=[-5, 5, -5, 5], title="Rozwój populacji CEM - Himmelblau", save_dir=OUTPUT_FOLDER)

    # --- NES ---
    best_x_h_nes, best_f_h_nes, hist_x_h_nes, hist_std_h_nes, hist_f_h_nes, evals_h_nes = natural_evolution_strategies(
        objective_func=himmelblau,
        init_mean=init_mean_himm, init_std=init_std_himm,
        pop_size=150, learning_rate_mean=0.1, learning_rate_std=0.05, 
        max_iter=500, n_stall=20, tol_stall=1e-6
    )
    print(f"[NES] Znalezione minimum (x): {best_x_h_nes}")
    print(f"[NES] Wartość funkcji f(x): {best_f_h_nes:.6f}")
    print(f"[NES] Wywołań funkcji celu (NFE): {evals_h_nes}")
    
    plot_convergence(hist_f_h_nes, title="Zbieżność NES - Himmelblau", save_dir=OUTPUT_FOLDER)
    plot_contour(himmelblau, hist_x_h_nes, bounds=[-5, 5, -5, 5], title="Ścieżka NES - Himmelblau", save_dir=OUTPUT_FOLDER)
    plot_population_stages(himmelblau, hist_x_h_nes, hist_std_h_nes, bounds=[-5, 5, -5, 5], title="Rozwój populacji NES - Himmelblau", save_dir=OUTPUT_FOLDER)

if __name__ == "__main__":
    main()