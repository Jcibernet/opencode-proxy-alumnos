# opencode-proxy-alumnos

Proxy local listo para usar **opencode** y **droid** con los principales modelos de
**OpenAI (GPT / Codex)** y **Anthropic (Claude)** mediante **login web (OAuth)** con tu
propia cuenta. No necesitas API keys: inicias sesion una vez en el navegador y listo.

Por debajo usa [CLIProxyAPI](https://github.com/router-for-me/CLIProxyAPI), que levanta
un servidor local compatible con OpenAI en `http://127.0.0.1:8317` y traduce las
peticiones hacia Claude y GPT usando tu sesion.

---

## Agentes soportados

Instala el agente que vayas a usar (puedes usar ambos):

1. **opencode** -> https://opencode.ai/docs/  (instalacion: `curl -fsSL https://opencode.ai/install | bash`)
2. **droid** (Factory) -> https://docs.factory.ai/  (instalacion: `curl -fsSL https://app.factory.ai/cli | sh`)

---

## Requisitos

- Linux, macOS o Windows (con Git Bash / WSL)
- `curl` y `tar` (vienen por defecto en la mayoria de sistemas)
- Un navegador para el login OAuth
- Una cuenta de Anthropic (Claude) y/o de OpenAI (GPT/Codex)

---

## Instalacion rapida

```bash
# 1) Clona este repo
git clone https://github.com/Jcibernet/opencode-proxy-alumnos.git
cd opencode-proxy-alumnos

# 2) Descarga el binario del proxy y prepara la config
./scripts/setup.sh

# 3) Inicia sesion con tu cuenta (abre el navegador)
./scripts/login.sh            # menu: 1) Anthropic  2) OpenAI
# o directo:
./scripts/login.sh anthropic
./scripts/login.sh openai

# 4) Arranca el proxy (dejalo corriendo en esta terminal)
./scripts/proxy-start.sh
```

Deja el proxy corriendo. En **otra terminal**, instala la config de tu agente:

```bash
# Para opencode:
./scripts/install-opencode-config.sh

# Para droid:
./scripts/install-droid-config.sh
```

Luego abre tu agente:

```bash
opencode      # elige un modelo cliproxy/...
droid         # elige un modelo "(Subscription via Proxy)"
```

---

## Como funciona

```
opencode / droid  ->  http://127.0.0.1:8317  (CLIProxyAPI)  ->  Anthropic / OpenAI
                                  ^
                          tu sesion OAuth
                       (~/.cli-proxy-api)
```

- El proxy escucha **solo en localhost** (`127.0.0.1`), nadie en tu red lo usa.
- Tus credenciales OAuth se guardan en `~/.cli-proxy-api` y **nunca** se suben a git.
- `apiKey: "sk-dummy"` en las configs es un valor de relleno: el proxy ya tiene tu sesion.

---

## Scripts incluidos

| Script | Que hace |
|---|---|
| `scripts/setup.sh` | Descarga el binario oficial de CLIProxyAPI y crea `config.yaml`. |
| `scripts/login.sh` | Login web (OAuth) con Anthropic u OpenAI. |
| `scripts/proxy-start.sh` | Arranca el proxy en `http://127.0.0.1:8317`. |
| `scripts/install-opencode-config.sh` | Copia la config a `~/.config/opencode/opencode.jsonc`. |
| `scripts/install-droid-config.sh` | Copia la config a `~/.factory/settings.json`. |

---

## Modelos disponibles

**Anthropic (Claude)** — requiere `./scripts/login.sh anthropic`
- `claude-sonnet-4-5-20250929` (por defecto)
- `claude-haiku-4-5-20251001`

**OpenAI (GPT / Codex)** — requiere `./scripts/login.sh openai`
- `gpt-5`
- `gpt-5-codex`

Puedes editar `opencode/opencode.jsonc` y `droid/settings.json` para anadir o
cambiar modelos, y volver a ejecutar los scripts `install-*`.

---

## Problemas comunes

- **"No se encuentra el binario"**: corre `./scripts/setup.sh` primero.
- **El agente no ve los modelos**: asegurate de que el proxy este corriendo
  (`./scripts/proxy-start.sh`) y de haber instalado la config del agente.
- **Error 401 / sin credenciales**: vuelve a iniciar sesion con `./scripts/login.sh`.
- **Servidor sin navegador**: usa `./scripts/login.sh anthropic --no-browser` y abre
  manualmente la URL que aparece en la terminal.

---

## Seguridad

- No compartas tu carpeta `~/.cli-proxy-api`: contiene tus tokens personales.
- El `.gitignore` ya excluye binarios, credenciales y logs.
- Cada alumno usa **su propia cuenta**; este proxy no comparte credenciales entre personas.
