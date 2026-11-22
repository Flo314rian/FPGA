import numpy as np
import matplotlib.pyplot as plt


S = [2, 0, 1]
H = [1, 2, 3]
# Erwartet: [2, 4, 7, 2, 3]
# Erwartet: [1, 3, 5, 3]
### FALTUNG 
g = np.zeros(len(S)+len(H)-1)

t_l = len(S) + len(H) - 1

n_len = len(H)
# for  the outer loop
for k in range(0, t_l):
    for n in range(0, n_len):
        value  = S[ k - n ] if (k - n) >= 0 and (k - n) < len(S) else 0

        g[k] += value * H[  n ]

print(g)