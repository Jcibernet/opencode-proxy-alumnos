"""Churn sintético: el accuracy miente, el split no negocia, k-means agrupa."""
import numpy as np
from sklearn.ensemble import GradientBoostingClassifier
from sklearn.dummy import DummyClassifier
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score, recall_score
from sklearn.preprocessing import StandardScaler
from sklearn.cluster import KMeans

rng = np.random.default_rng(7)
N = 3000

# features: gasto mensual, compras, días desde última compra
gasto = rng.exponential(120, N)
compras = rng.poisson(4, N)
recencia = rng.exponential(30, N)
X = np.column_stack([gasto, compras, recencia])

# churn REAL depende de recencia alta + gasto bajo; solo el 8% churnea (desbalance)
# señal clara: clientes dormidos (recencia alta) que gastan poco y compran poco
score = 0.08 * recencia - 0.015 * gasto - 0.8 * compras
p = 1 / (1 + np.exp(-(score - 1.5)))
y = (rng.random(N) < p).astype(int)
print(f"churn real: {y.mean():.1%} de {N} clientes (desbalanceado a propósito)")

X_tr, X_te, y_tr, y_te = train_test_split(X, y, test_size=0.25, random_state=7, stratify=y)

# ── la trampa del accuracy ───────────────────────────────────────
tonto = DummyClassifier(strategy="most_frequent").fit(X_tr, y_tr)
modelo = GradientBoostingClassifier(random_state=7).fit(X_tr, y_tr)

acc_tonto = accuracy_score(y_te, tonto.predict(X_te))
acc_real = accuracy_score(y_te, modelo.predict(X_te))
rec_tonto = recall_score(y_te, tonto.predict(X_te), zero_division=0)
rec_real = recall_score(y_te, modelo.predict(X_te))

print(f"modelo 'siempre no': accuracy={acc_tonto:.1%}  recall={rec_tonto:.0%}  ← inútil con buen accuracy")
print(f"modelo real:         accuracy={acc_real:.1%}  recall={rec_real:.0%}  ← atrapa churners de verdad")
assert rec_real > 0.3 and rec_tonto == 0, "el modelo real debe atrapar churners; el tonto, ninguno"

# ── overfitting: evaluar con train infla ─────────────────────────
acc_train = accuracy_score(y_tr, modelo.predict(X_tr))
print(f"accuracy en TRAIN {acc_train:.1%} vs TEST {acc_real:.1%} → por esto el split no se negocia")

# ── no supervisado: segmentos ────────────────────────────────────
X_norm = StandardScaler().fit_transform(X)          # ¡normalizar ANTES de distancias!
seg = KMeans(n_clusters=3, random_state=7, n_init="auto").fit_predict(X_norm)
print("\nperfil de cada segmento (gasto, compras, recencia promedio):")
for s in range(3):
    m = X[seg == s].mean(axis=0)
    print(f"  segmento {s} ({(seg==s).sum():4d} clientes): "
          f"gasto={m[0]:6.0f}  compras={m[1]:.1f}  recencia={m[2]:5.1f} días")
print("✔ el algoritmo agrupó; ponerles nombre (fieles/dormidos/nuevos) es TU trabajo")
