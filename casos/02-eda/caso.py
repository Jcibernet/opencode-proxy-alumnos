"""EDA en 5 pasos sobre ventas sintéticas."""
import random
import polars as pl

random.seed(7)
filas = [
    {"venta_id": i,
     "cliente_id": random.randint(1, 40),
     "monto": round(random.expovariate(1 / 120), 2),   # cola larga a propósito
     "cantidad": random.randint(1, 5)}
    for i in range(1, 501)
]
filas[10]["monto"] = None                 # nulo plantado
filas[20]["monto"] = 9_999.0              # outlier plantado
filas.append(filas[5].copy())             # duplicado plantado

df = pl.DataFrame(filas)

print("── 1. estructura:", df.shape, dict(df.schema))
print("── 2. nulos por columna:"); print(df.null_count())
print("   duplicados:", df.is_duplicated().sum())
print("── 3. distribución de monto:"); print(df.select("monto").describe())

media, desvio = df["monto"].mean(), df["monto"].std()
outliers = df.filter(((pl.col("monto") - media) / desvio).abs() > 3)
print(f"── 4. outliers (>3 desvíos): {len(outliers)} fila(s)")
print(outliers)

print("── 5. correlación monto↔cantidad:")
print(df.select(pl.corr("monto", "cantidad")))

# la lección del describe(): media vs mediana
mediana = df["monto"].median()
print(f"\nmedia={media:.1f} vs mediana={mediana:.1f} → cola larga: la media miente")
