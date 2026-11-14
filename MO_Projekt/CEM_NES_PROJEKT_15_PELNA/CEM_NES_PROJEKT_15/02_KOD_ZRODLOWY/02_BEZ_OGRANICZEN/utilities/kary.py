import numpy as np

class WyjatekOgraniczenia(Exception):
    """Własny wyjątek, który przechowuje informację, jak bardzo naruszono warunek."""
    def __init__(self, stopien_naruszenia):
        self.stopien_naruszenia = stopien_naruszenia

# Ograniczenia dla poszczególnych funkcji

def rosenbrock_z_ograniczeniem(x, func_bazowa):
    # Ograniczenie równościowe: 1.5 - 0.5*x1 - x2 = 0
    h_x = 1.5 - 0.5 * x[0] - x[1]
    
    # Komputer nigdy nie wylosuje idealnego 0.0, więc dajemy mikroskopijną tolerancję
    # Jeśli punkt jest poza tą linią, rzucamy wyjątkiem
    if abs(h_x) > 1e-4:
        raise WyjatekOgraniczenia(abs(h_x))
        
    return func_bazowa(x)

def camel_z_ograniczeniem(x, func_bazowa):
    # Ograniczenie nierównościowe (koło): x1^2 + x2^2 <= 1
    # Przekształcamy do postaci g(x) <= 0  ->  x1^2 + x2^2 - 1 <= 0
    g_x = x[0]**2 + x[1]**2 - 1.0
    
    if g_x > 0:
        raise WyjatekOgraniczenia(g_x)
        
    return func_bazowa(x)

def himmelblau_z_ograniczeniem(x, func_bazowa):
    # Własne ograniczenie:
    # Himmelblau ma 4 minima. Zmuśmy go, żeby szukał tylko po lewej stronie osi Y
    # Czyli x1 <= 0
    g_x = x[0]
    
    if g_x > 0:
        raise WyjatekOgraniczenia(g_x)
        
    return func_bazowa(x)


# Funkcja kary 

def zastosuj_kare(x, funkcja_ograniczona, func_bazowa, r=10000.0):
    """
    Łapie wyjątki z owijek i zamienia je na ogromną karę.
    r - mnożnik kary (im większy, tym bardziej algorytm ucieka od zakazanej strefy)
    """
    try:
        return funkcja_ograniczona(x, func_bazowa)
    except WyjatekOgraniczenia as e:
        # Jeśli wyskoczył błąd (jesteśmy poza obszarem), nakładamy kare
        # Kara rośnie do kwadratu w zależności od tego, jak bardzo jesteśmy poza obszarem
        kara = r * (e.stopien_naruszenia ** 2)
        
        # Ostateczny wynik to wartość bazowa + ogromna kara
        return func_bazowa(x) + kara