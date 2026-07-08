"""Encontrar w=3.5, b=8 sin decírselo: solo con el gradiente."""
import numpy as np

rng = np.random.default_rng(7)
X = rng.uniform(0, 10, 200)
y = 3.5 * X + 8 + rng.normal(0, 2, 200)     # la verdad oculta

w, b, lr = 0.0, 0.0, 0.01

for paso in range(2001):
    y_pred = w * X + b
    error = y_pred - y
    grad_w = 2 * np.mean(error * X)
    grad_b = 2 * np.mean(error)
    w -= lr * grad_w
    b -= lr * grad_b
    if paso % 500 == 0:
        print(f"paso {paso:4d}: w={w:.3f} b={b:.3f} error²={np.mean(error**2):.1f}")

assert abs(w - 3.5) < 0.15 and abs(b - 8) < 0.6
print(f"\n✔ encontró w≈{w:.2f} (verdad 3.5) y b≈{b:.2f} (verdad 8)")
print("probá subir lr a 0.1: explota. Bajalo a 0.0001: no llega. Ese es el dial.")
