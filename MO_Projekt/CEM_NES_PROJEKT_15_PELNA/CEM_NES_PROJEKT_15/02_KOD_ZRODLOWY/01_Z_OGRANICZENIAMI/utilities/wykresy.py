import os
import re
import matplotlib.pyplot as plt
import matplotlib.colors as colors
import matplotlib.ticker as ticker
import numpy as np

def _get_safe_filename(title):
    """Pomocnicza funkcja zamieniająca tytuł wykresu na bezpieczną nazwę pliku."""
    polskie = {'ą': 'a', 'ć': 'c', 'ę': 'e', 'ł': 'l', 'ń': 'n', 'ó': 'o', 'ś': 's', 'ź': 'z', 'ż': 'z',
               'Ą': 'A', 'Ć': 'C', 'Ę': 'E', 'Ł': 'L', 'Ń': 'N', 'Ó': 'O', 'Ś': 'S', 'Ź': 'Z', 'Ż': 'Z'}
    for k, v in polskie.items():
        title = title.replace(k, v)
    title = title.lower().replace(" - ", "_").replace(" ", "_")
    title = re.sub(r'[^\w\s_]', '', title)
    return f"{title}.png"

def _handle_save_or_show(title, save_dir):
    """Decyduje, czy zapisać wykres do pliku, czy przygotować do wyświetlenia."""
    if save_dir:
        os.makedirs(save_dir, exist_ok=True)
        filename = _get_safe_filename(title)
        full_path = os.path.join(save_dir, filename)
        plt.savefig(full_path, dpi=300, bbox_inches='tight')
        plt.close()
        print(f" Zapisano: {full_path}")
    else:
        pass

def plot_convergence(history_f, title="Spadek wartości funkcji celu", save_dir=None):
    plt.figure(figsize=(8, 5))
    plt.plot(history_f, marker='.', linestyle='-', color='b')
    plt.title(title)
    plt.xlabel('Iteracja')
    plt.ylabel('Wartość funkcji celu')
    plt.grid(True)
    plt.yscale('log')
    
    _handle_save_or_show(title, save_dir)

def plot_contour(objective_func, history_mean, bounds, title="Contour Plot", constraint_type=None, save_dir=None):
    x_min, x_max, y_min, y_max = bounds
    x = np.linspace(x_min, x_max, 500)
    y = np.linspace(y_min, y_max, 500)
    X, Y = np.meshgrid(x, y)
    
    Z = np.zeros_like(X)
    for i in range(X.shape[0]):
        for j in range(X.shape[1]):
            Z[i, j] = objective_func(np.array([X[i, j], Y[i, j]]))
            
    plt.figure(figsize=(8, 6))
    Z_safe = np.clip(Z, 1e-10, None)
    vmin, vmax = Z_safe.min(), Z_safe.max()
    levels = np.logspace(np.log10(vmin), np.log10(vmax), 50)
    
    contour = plt.contourf(X, Y, Z_safe, levels=levels, norm=colors.LogNorm(vmin=vmin, vmax=vmax), cmap='viridis', alpha=0.9)
    cbar = plt.colorbar(contour, label='Wartość funkcji (skala logarytmiczna)', ticks=ticker.LogLocator(base=10.0))
    
    # --- RYSOWANIE I CIENIOWANIE OGRANICZEŃ ---
    if constraint_type == 'rosenbrock':
        # Usunięto szare tło! Zostawiamy tylko grubą linię.
        x_line = np.linspace(x_min, x_max, 100)
        plt.plot(x_line, 1.5 - 0.5 * x_line, color='magenta', linestyle='--', linewidth=2.5, label='Ograniczenie: 1.5 - 0.5*x1 - x2 = 0')
        plt.ylim(y_min, y_max)
    elif constraint_type == 'camel':
        # Cieniujemy obszar na zewnątrz koła
        Z_constr = X**2 + Y**2
        plt.contourf(X, Y, Z_constr, levels=[1.0, 1e10], colors=['gray'], alpha=0.3)
        circle = plt.Circle((0, 0), 1.0, color='magenta', fill=False, linestyle='--', linewidth=2.5, label='Ograniczenie: x1^2 + x2^2 <= 1')
        plt.gca().add_patch(circle)
    elif constraint_type == 'himmelblau':
        # Cieniujemy prawą stronę (x1 > 0)
        plt.axvspan(0, x_max, color='gray', alpha=0.3)
        plt.axvline(x=0, color='magenta', linestyle='--', linewidth=2.5, label='Ograniczenie: x1 <= 0')
    
    # Dodajemy legendę szarego tła tylko dla Camel i Himmelblau
    if constraint_type in ['camel', 'himmelblau']:
        plt.fill_between([], [], color='gray', alpha=0.3, label='Strefa zakazana')
    
    history_np = np.array(history_mean)
    hx, hy = history_np[:, 0], history_np[:, 1]
    plt.plot(hx, hy, color='red', marker='o', markersize=4, linewidth=2, label='Ścieżka algorytmu')
    plt.plot(hx[0], hy[0], 'go', markersize=8, label='Start')
    plt.plot(hx[-1], hy[-1], 'r*', markersize=12, label='Znalezione minimum')
    
    plt.title(title)
    plt.xlabel('x1')
    plt.ylabel('x2')
    plt.legend(loc='upper right')
    plt.grid(True, linestyle='--', alpha=0.5)
    
    _handle_save_or_show(title, save_dir)

def plot_population_stages(objective_func, history_mean, history_std, bounds, title="Rozwój populacji", constraint_type=None, save_dir=None):
    x_min, x_max, y_min, y_max = bounds
    x = np.linspace(x_min, x_max, 300)
    y = np.linspace(y_min, y_max, 300)
    X, Y = np.meshgrid(x, y)
    
    Z = np.zeros_like(X)
    for i in range(X.shape[0]):
        for j in range(X.shape[1]):
            Z[i, j] = objective_func(np.array([X[i, j], Y[i, j]]))
            
    Z_safe = np.clip(Z, 1e-10, None)
    vmin, vmax = Z_safe.min(), Z_safe.max()
    levels = np.logspace(np.log10(vmin), np.log10(vmax), 40)
    
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))
    fig.suptitle(title, fontsize=16)
    
    stages = [0, len(history_mean) // 2, len(history_mean) - 1]
    stage_names = ["Początek (Iteracja 0)", f"Środek (Iteracja {stages[1]})", f"Koniec (Iteracja {stages[2]})"]
    
    for ax, idx, name in zip(axes, stages, stage_names):
        ax.contourf(X, Y, Z_safe, levels=levels, norm=colors.LogNorm(vmin=vmin, vmax=vmax), cmap='viridis', alpha=0.7)
        
        # --- RYSOWANIE I CIENIOWANIE OGRANICZEŃ NA SUB-PANELACH ---
        if constraint_type == 'rosenbrock':
            x_line = np.linspace(x_min, x_max, 100)
            ax.plot(x_line, 1.5 - 0.5 * x_line, color='magenta', linestyle='--', linewidth=2)
            ax.set_ylim(y_min, y_max)
        elif constraint_type == 'camel':
            Z_constr = X**2 + Y**2
            ax.contourf(X, Y, Z_constr, levels=[1.0, 1e10], colors=['gray'], alpha=0.4)
            circle = plt.Circle((0, 0), 1.0, color='magenta', fill=False, linestyle='--', linewidth=2)
            ax.add_patch(circle)
        elif constraint_type == 'himmelblau':
            ax.axvline(x=0, color='magenta', linestyle='--', linewidth=2)
            ax.axvspan(0, x_max, color='gray', alpha=0.4)

        mean = history_mean[idx]
        std = history_std[idx]
        pop = np.random.normal(loc=mean, scale=std, size=(100, 2))
        
        ax.scatter(pop[:, 0], pop[:, 1], c='white', edgecolors='black', alpha=0.6, s=25, label='Próbki')
        ax.plot(mean[0], mean[1], 'r*', markersize=15, label='Średnia')
        ax.set_title(name)
        ax.set_xlabel('x1')
        ax.set_ylabel('x2')
        ax.legend(loc='lower right')
        ax.grid(True, linestyle='--', alpha=0.5)
        
    plt.tight_layout()
    _handle_save_or_show(title, save_dir)