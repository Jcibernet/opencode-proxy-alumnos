# Casos de estudio

Un directorio por tema del programa: código ejecutable, datos sintéticos
autogenerados, cero setup salvo lo indicado en cada README. La teoría vive
en el Notion del programa; acá se ve **directo en código**.

| Caso | Tema | Página del programa |
|---|---|---|
| [01-tipos-de-datos](01-tipos-de-datos/) | Mutación, alias, defaults mutables | Tipos de Datos (Analytics) |
| [02-eda](02-eda/) | Los 5 pasos del EDA con Polars | EDA (Analytics) |
| [03-normalizacion-medallion](03-normalizacion-medallion/) | Bronze/silver/gold + formas normales | Normalización (Analytics) |
| [04-numpy-embeddings](04-numpy-embeddings/) | Vectorización + similitud coseno top-k | NumPy (Herramientas) / Álgebra (Science) |
| [05-estadistica-series](05-estadistica-series/) | TCL + series temporales | Estadística (Science) |
| [06-calculo-gradiente](06-calculo-gradiente/) | Descenso de gradiente desde cero | Cálculo (Science) |
| [07-spark-local](07-spark-local/) | PySpark modo local | Spark (Engineering) |
| [08-system-design](08-system-design/) | Banco de preguntas + flujo Excalidraw | System Design (Engineering) |

## Cómo correrlos

Cada caso indica su comando. El patrón general con [uv](https://docs.astral.sh/uv/):

```bash
cd casos/02-eda
uv run --with polars caso.py
```

Consejo: abrilos **con tu agente** (opencode/droid vía el proxy de este repo)
y pedile que te explique línea por línea, que rompa algo a propósito, o que
extienda el caso. Para eso está.
