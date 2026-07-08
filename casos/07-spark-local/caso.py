"""PySpark local: mismos verbos que Polars, motor distribuido."""
from pyspark.sql import SparkSession, functions as F

spark = SparkSession.builder.appName("ventas-local").master("local[*]").getOrCreate()
spark.sparkContext.setLogLevel("ERROR")

datos = [(i, i % 40 + 1, float(20 + (i * 37) % 480)) for i in range(1, 501)]
ventas = spark.createDataFrame(datos, ["venta_id", "cliente_id", "monto"])

resumen = (
    ventas
    .filter(F.col("monto") > 0)                 # transformación (lazy)
    .groupBy("cliente_id")
    .agg(F.sum("monto").alias("total"), F.count("*").alias("compras"))
    .orderBy(F.desc("total"))
)

resumen.show(5)                                  # acción: acá corre todo
print("plan físico optimizado por Catalyst:")
resumen.explain(mode="simple")
spark.stop()
print("✔ misma API que verías en Databricks/Glue/Dataproc")
