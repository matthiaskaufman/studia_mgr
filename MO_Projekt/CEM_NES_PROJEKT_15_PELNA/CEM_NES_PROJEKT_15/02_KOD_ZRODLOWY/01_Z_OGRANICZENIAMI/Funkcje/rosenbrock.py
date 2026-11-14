import numpy as np


def rosenbrock(x, a=1.0, b=100.0):
    x1, x2 = x
    return (a - x1) ** 2 + b * (x2 - x1 ** 2) ** 2