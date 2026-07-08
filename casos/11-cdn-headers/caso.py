"""¿Quién sirve esta URL: el origen o el edge? Los headers lo cantan."""
import sys
import urllib.request

INTERESANTES = ["server", "cf-cache-status", "cf-ray", "cache-control", "age",
                "x-vercel-cache", "x-cache", "via", "x-railway-edge"]

def inspeccionar(url):
    req = urllib.request.Request(url, method="HEAD",
                                 headers={"User-Agent": "caso11-detective/1.0"})
    try:
        with urllib.request.urlopen(req, timeout=15) as resp:
            headers = {k.lower(): v for k, v in resp.headers.items()}
    except Exception as e:
        print(f"{url}: no se pudo ({e})"); return

    print(f"\n{url}")
    for h in INTERESANTES:
        if h in headers:
            print(f"  {h}: {headers[h]}")

    server = headers.get("server", "")
    cf = headers.get("cf-cache-status")
    if "cloudflare" in server:
        veredicto = f"detrás de Cloudflare — {cf or 'sin estado de cache'}"
        if cf == "HIT":
            veredicto += " (salió del edge: el origen NI SE ENTERÓ)"
        elif cf in ("MISS", "DYNAMIC"):
            veredicto += " (fue hasta el origen)"
    elif "x-vercel-cache" in headers:
        veredicto = f"CDN de Vercel — {headers['x-vercel-cache']}"
    elif "via" in headers or "x-cache" in headers:
        veredicto = "hay un proxy/CDN en el medio"
    else:
        veredicto = "parece servir directo del origen (sin CDN visible)"
    print(f"  → {veredicto}")

urls = sys.argv[1:] or ["https://www.cloudflare.com", "https://github.com", "https://www.enkia.org"]
for u in urls:
    inspeccionar(u)
print("\n✔ probá tu propio dominio: ¿tu origen está expuesto o tiene vestíbulo?")
