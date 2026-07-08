"""Convolución = producto punto deslizante; tokens = fusionar pares frecuentes."""
import numpy as np
from collections import Counter

# ── PARTE 1: convolución que detecta un borde ────────────────────
img = np.zeros((6, 6)); img[:, 3:] = 1.0          # borde vertical en la columna 3

filtro = np.array([[-1., 0., 1.],
                   [-1., 0., 1.],
                   [-1., 0., 1.]])                # detector de bordes verticales

mapa = np.zeros((4, 4))
for i in range(4):
    for j in range(4):
        mapa[i, j] = np.sum(img[i:i+3, j:j+3] * filtro)   # producto punto 3×3

print("mapa de activación (alto = borde):")
print(mapa)
assert mapa[:, 0].max() == 0 and mapa[:, 1:3].max() == 3.0
print("✔ el filtro se activa EXACTAMENTE donde está el borde\n")

# ── PARTE 2: mini-BPE — construir tokens por frecuencia ──────────
corpus = "los datos no mienten pero los datos mal leidos mienten mucho"
tokens = list(corpus)                              # arrancamos por caracteres

for paso in range(12):                             # 12 fusiones
    pares = Counter(zip(tokens, tokens[1:]))
    (a, b), freq = pares.most_common(1)[0]
    if freq < 2:
        break
    nuevo, i, out = a + b, 0, []
    while i < len(tokens):
        if i < len(tokens) - 1 and tokens[i] == a and tokens[i + 1] == b:
            out.append(nuevo); i += 2
        else:
            out.append(tokens[i]); i += 1
    tokens = out
    print(f"fusión {paso+1}: {(a+b)!r:>12} (aparecía {freq} veces) → {len(tokens)} tokens")

print("\ntokens finales:", tokens)
print(f"✔ de {len(corpus)} caracteres a {len(tokens)} tokens: eso hace BPE, "
      "con ~100k fusiones aprendidas de todo internet")
