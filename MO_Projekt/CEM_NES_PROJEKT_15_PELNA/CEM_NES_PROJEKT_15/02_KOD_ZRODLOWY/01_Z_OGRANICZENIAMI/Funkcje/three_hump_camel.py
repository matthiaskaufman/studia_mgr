import numpy as np


def three_hump_camel(x):
    x1, x2 = x
    return 2 * x1**2 - 1.05 * x1**4 + (x1**6) / 6 + x1 * x2 + x2**2