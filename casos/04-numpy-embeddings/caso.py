"""Vectorizar o sufrir + búsqueda semántica mínima."""
import time
import numpy as np

# ── vectorización: el benchmark ──────────────────────────────────
datos = list(range(1_000_000))
arr = np.array(datos)

t0 = time.perf_counter(); _ = [x * 2 + 1 for x in datos]; t_loop = time.perf_counter() - t0
t0 = time.perf_counter(); _ = arr * 2 + 1;                t_vec = time.perf_counter() - t0
print(f"loop: {t_loop*1000:.0f} ms | vectorizado: {t_vec*1000:.1f} ms | {t_loop/t_vec:.0f}× más rápido")

# ── broadcasting: centrar columnas sin loops ─────────────────────
M = np.arange(12, dtype=float).reshape(3, 4)
centrada = M - M.mean(axis=0)
assert np.allclose(centrada.mean(axis=0), 0)
print("broadcasting: columnas centradas, medias ≈ 0")

# ── embeddings: top-k por similitud coseno ───────────────────────
rng = np.random.default_rng(7)
E = rng.random((1000, 256), dtype=np.float32)     # 1000 docs embebidos
consulta = E[42] + rng.normal(0, 0.05, 256).astype(np.float32)  # parecida al doc 42

similitud = (E @ consulta) / (np.linalg.norm(E, axis=1) * np.linalg.norm(consulta))
top5 = np.argsort(similitud)[-5:][::-1]
print("top-5 más parecidos a la consulta:", top5)
assert top5[0] == 42, "el doc 42 debería ganar: la consulta se construyó desde él"
print("✔ el más parecido es el doc 42 — la geometría funciona")
