# Caso 3 — Normalización + arquitectura medallón

Pipeline bronze → silver → gold con Polars: cada stage una copia nueva,
formas normales en silver, min-max y z-score en gold.

```bash
uv run --with polars caso.py
```

Página: **Normalización** (track Analytics).
