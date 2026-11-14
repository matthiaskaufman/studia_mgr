def check_stop_conditions(iteration, max_iter, history_best_f, n_stall, tol_stall):
    """
    Sprawdza warunki stopu: Maksymalną liczbę iteracji oraz Kryterium stagnacji.
    """
    # 1. WARUNEK: Maksymalna liczba iteracji
    if iteration >= max_iter - 1:
        return True, f"Stop w iteracji {iteration}: Osiągnięto limit iteracji ({max_iter})."

    # 2. WARUNEK: Kryterium stagnacji (steady-state)
    # Uruchamiamy sprawdzanie dopiero, gdy mamy wystarczająco długą historię (minimum n_stall + 1 wpisów)
    if len(history_best_f) > n_stall:
        # Wyciągamy ostatnie wyniki o długości n_stall + 1
        recent_history = history_best_f[-(n_stall + 1):]
        stagnation = True
        
        # Sprawdzamy różnice krok po kroku w naszym oknie historii
        for i in range(n_stall):
            delta = abs(recent_history[i+1] - recent_history[i])
            # Jeśli w którymkolwiek kroku zmiana była większa niż próg, to nie ma stagnacji
            if delta >= tol_stall:
                stagnation = False
                break
                
        if stagnation:
            return True, f"Stop w iteracji {iteration}: Stagnacja funkcji celu przez {n_stall} iteracji (zmiany < {tol_stall})."

    return False, ""