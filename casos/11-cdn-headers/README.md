# Caso 11 — Detective de headers: CDN, cache y TLS

Inspecciona cualquier URL y te dice si está detrás de un CDN, si la respuesta
fue HIT o MISS, y qué contrato de cache declara. Solo stdlib.

```bash
python3 caso.py https://www.cloudflare.com https://www.enkia.org
```

Página: **CDN, Cloudflare y Resend** (Engineering).
