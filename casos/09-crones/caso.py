"""Pipeline idempotente: re-correr un día = reescribir ese día, nunca duplicar."""
import csv, os, random
from datetime import date

HOY = date.today().isoformat()
GOLD = "gold"
os.makedirs(GOLD, exist_ok=True)

# lock casero: si ya hay una corrida en curso, no arrancar (versión flock en el README)
LOCK = "/tmp/caso09.lock"
if os.path.exists(LOCK):
    raise SystemExit("ya hay una corrida en curso — me voy (eso es un lock)")
open(LOCK, "w").write(str(os.getpid()))

try:
    # "extraer" ventas del día (sintético pero determinístico por fecha)
    random.seed(HOY)
    ventas = [{"venta_id": i, "monto": round(random.uniform(10, 500), 2)} for i in range(50)]
    total = round(sum(v["monto"] for v in ventas), 2)

    # IDEMPOTENTE: partición por fecha — re-correr HOY pisa el archivo de HOY
    particion = f"{GOLD}/ventas_fecha={HOY}.csv"
    with open(particion, "w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=["venta_id", "monto"])
        w.writeheader(); w.writerows(ventas)

    print(f"partición {particion}: {len(ventas)} filas, total {total}")
    archivos = sorted(os.listdir(GOLD))
    print(f"particiones en gold: {archivos}")
    assert archivos.count(f"ventas_fecha={HOY}.csv") == 1, "¡duplicó la partición!"
    print("✔ corré este script las veces que quieras: hoy siempre es UNA partición")
    # en producción, acá va el ping al dead-man switch:
    # curl -fsS https://hc-ping.com/<uuid>
finally:
    os.remove(LOCK)
