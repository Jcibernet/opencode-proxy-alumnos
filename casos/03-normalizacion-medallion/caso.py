"""Bronze/Silver/Gold: copias por stage, nunca mutar la anterior."""
import os, random
import polars as pl

random.seed(7)
os.makedirs("data/bronze", exist_ok=True)
os.makedirs("data/silver", exist_ok=True)
os.makedirs("data/gold", exist_ok=True)

# ── BRONZE: el crudo, tal como llegó (desnormalizado, sucio) ─────
clientes = [("ana@mail.com", "Ana"), ("bob@mail.com", "Bob"), ("cai@mail.com", "Cai")]
crudo = [
    {"venta_id": i, "cliente_email": (c := random.choice(clientes))[0],
     "cliente_nombre": c[1], "producto": random.choice(["Teclado", "Mouse", "Monitor"]),
     "cantidad": random.randint(1, 3), "monto": str(round(random.uniform(10, 500), 2))}
    for i in range(1, 101)
]
pl.DataFrame(crudo).write_parquet("data/bronze/ventas.parquet")
print("bronze:", pl.read_parquet("data/bronze/ventas.parquet").shape, "(inmutable desde acá)")

# ── SILVER: tipar + limpiar + NORMALIZAR (formas normales) ───────
silver = (
    pl.scan_parquet("data/bronze/ventas.parquet")
    .with_columns(pl.col("monto").cast(pl.Float64))
    .unique()
    .collect()
)
# 2FN/3FN: cada hecho vive una sola vez
tabla_clientes = silver.select("cliente_email", "cliente_nombre").unique()
tabla_ventas = silver.select("venta_id", "cliente_email", "producto", "cantidad", "monto")
tabla_clientes.write_parquet("data/silver/clientes.parquet")
tabla_ventas.write_parquet("data/silver/ventas.parquet")
print("silver: clientes", tabla_clientes.shape, "| ventas", tabla_ventas.shape)

# ── GOLD: agregar + normalización ESTADÍSTICA ────────────────────
gold = (
    tabla_ventas.group_by("cliente_email")
    .agg(pl.col("monto").sum().alias("total"), pl.len().alias("compras"))
    .with_columns(
        ((pl.col("total") - pl.col("total").min())
         / (pl.col("total").max() - pl.col("total").min())).alias("total_minmax"),
        ((pl.col("total") - pl.col("total").mean())
         / pl.col("total").std()).alias("total_z"),
    )
)
gold.write_parquet("data/gold/ventas_por_cliente.parquet")
print("gold:"); print(gold)
print("\n✔ bronze quedó intacto: silver/gold se REGENERAN, no se parchan")
