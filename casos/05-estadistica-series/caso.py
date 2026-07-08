"""TCL en acción + serie temporal con estacionalidad."""
import numpy as np
import polars as pl

rng = np.random.default_rng(7)

# ── TCL: medias de muestras → campana, aunque los datos no ───────
poblacion = rng.exponential(100, 1_000_000)        # sesgadísima
print(f"población: media={poblacion.mean():.1f}, mediana={np.median(poblacion):.1f} (sesgo!)")

medias = np.array([rng.choice(poblacion, 500).mean() for _ in range(2000)])
# si es campana: ~68% dentro de 1 desvío de la media
dentro_1sd = np.mean(np.abs(medias - medias.mean()) < medias.std())
print(f"medias muestrales: {dentro_1sd:.0%} dentro de ±1 desvío (campana ≈ 68%)")
assert 0.6 < dentro_1sd < 0.75, "el TCL no apareció?!"

# ── serie temporal: tendencia + estacionalidad semanal ───────────
dias = 120
t = np.arange(dias)
serie = 100 + t * 0.8 + 15 * np.sin(2 * np.pi * t / 7) + rng.normal(0, 4, dias)
df = pl.DataFrame({"dia": t, "ventas": serie}).with_columns(
    pl.col("ventas").rolling_mean(window_size=7).alias("tendencia_7d"),
    (pl.col("ventas") / pl.col("ventas").shift(7)).alias("vs_semana_pasada"),
)
print(df.tail(5))
ultima = df.drop_nulls().tail(30)
print(f"tendencia (últimos 30d): {ultima['tendencia_7d'][0]:.0f} → {ultima['tendencia_7d'][-1]:.0f} (crece)")
print("✔ comparar contra el MISMO día de la semana pasada, no contra ayer")
