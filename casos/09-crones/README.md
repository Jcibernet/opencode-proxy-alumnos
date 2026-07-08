# Caso 9 — Crones: idempotencia y lock

Un pipeline programable que podés correr N veces sin duplicar nada, más el
workflow de GitHub Actions equivalente (`workflow-ejemplo.yml`).

```bash
python3 caso.py && python3 caso.py    # correlo DOS veces: mismo resultado
```

Para probarlo como cron real: `crontab -e` y agregá
`*/5 * * * * cd /ruta/a/este/caso && /usr/bin/python3 caso.py >> etl.log 2>&1`

Página: **Cron y scheduling** (Herramientas).
