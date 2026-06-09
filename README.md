# opencode-proxy-alumnos

Repo listo para que alumnos usen **opencode** y **droid** con los principales
modelos de **OpenAI** y **Anthropic** usando **login web (OAuth)**.

No se usan API keys. Cada alumno inicia sesion con su propia cuenta en el
navegador y los tokens quedan guardados solo en su computadora.

El proxy local corre en:

```text
http://127.0.0.1:8317
```

---

## Agentes soportados

Instala el agente que quieras usar, en este orden recomendado:

1. **opencode**: https://opencode.ai/docs/

   Instalacion rapida:

   ```bash
   curl -fsSL https://opencode.ai/install | bash
   ```

2. **droid** (Factory): https://docs.factory.ai/

   Instalacion rapida:

   ```bash
   curl -fsSL https://app.factory.ai/cli | sh
   ```

Puedes instalar uno o los dos.

---

## Idea simple

```text
opencode / droid  ->  proxy local  ->  OpenAI o Anthropic
                         8317          login web OAuth
```

- OpenAI se usa con login web: `./scripts/login.sh openai`
- Anthropic se usa con login web: `./scripts/login.sh anthropic`
- Puedes hacer ambos logins y despues elegir modelo con `/models` en opencode.
- Tus tokens quedan en `~/.cli-proxy-api`. No compartas esa carpeta.

---

## Modelos configurados

El modelo default del repo es:

```text
gpt-5.5
```

Si no lo tienes disponible, no pasa nada: en opencode escribe `/models` y elige
el modelo que si aparezca para tu cuenta.

### OpenAI

Requiere:

```bash
./scripts/login.sh openai
```

Modelos:

| Modelo | Uso recomendado |
|---|---|
| `gpt-5.5` | Mejor modelo general, default del repo |
| `gpt-5.4` | Alternativa general |
| `gpt-5.3-codex` | Programacion / agentes de codigo |
| `gpt-5.4-mini` | Rapido / liviano |

### Anthropic

Requiere:

```bash
./scripts/login.sh anthropic
```

Modelos:

| Modelo | Uso recomendado |
|---|---|
| `claude-opus-4-8` | Mejor Claude disponible en esta config |
| `claude-opus-4-7` | Opus fuerte |
| `claude-opus-4-6` | Opus fuerte |
| `claude-sonnet-4-6` | Balance velocidad/calidad |
| `claude-haiku-4-5-20251001` | Rapido / small model |

---

## Instalacion para Windows

Recomendado: usar **PowerShell**.

1. Instala Git para Windows si no lo tienes: https://git-scm.com/download/win

2. Abre PowerShell y clona el repo:

   ```powershell
   git clone https://github.com/Jcibernet/opencode-proxy-alumnos.git
   cd opencode-proxy-alumnos
   ```

3. Descarga el proxy:

   ```powershell
   powershell -ExecutionPolicy Bypass -File .\scripts\setup.ps1
   ```

4. Inicia sesion con OpenAI y/o Anthropic:

   ```powershell
   .\scripts\login.ps1 openai
   .\scripts\login.ps1 anthropic
   ```

5. Instala la config del agente que vas a usar:

   ```powershell
   .\scripts\install-opencode-config.ps1
   .\scripts\install-droid-config.ps1
   ```

6. Deja corriendo el proxy en una terminal:

   ```powershell
   .\scripts\proxy-start.ps1
   ```

7. En otra terminal abre el agente:

   ```powershell
   opencode
   # o
   droid
   ```

---

## Instalacion para macOS

1. Abre Terminal y clona el repo:

   ```bash
   git clone https://github.com/Jcibernet/opencode-proxy-alumnos.git
   cd opencode-proxy-alumnos
   ```

2. Descarga el proxy:

   ```bash
   ./scripts/setup.sh
   ```

3. Inicia sesion con OpenAI y/o Anthropic:

   ```bash
   ./scripts/login.sh openai
   ./scripts/login.sh anthropic
   ```

4. Instala la config del agente que vas a usar:

   ```bash
   ./scripts/install-opencode-config.sh
   ./scripts/install-droid-config.sh
   ```

5. Deja corriendo el proxy en una terminal:

   ```bash
   ./scripts/proxy-start.sh
   ```

6. En otra terminal abre el agente:

   ```bash
   opencode
   # o
   droid
   ```

---

## Instalacion para Ubuntu / Linux

1. Instala herramientas basicas si faltan:

   ```bash
   sudo apt update
   sudo apt install -y git curl tar
   ```

2. Clona el repo:

   ```bash
   git clone https://github.com/Jcibernet/opencode-proxy-alumnos.git
   cd opencode-proxy-alumnos
   ```

3. Descarga el proxy:

   ```bash
   ./scripts/setup.sh
   ```

4. Inicia sesion con OpenAI y/o Anthropic:

   ```bash
   ./scripts/login.sh openai
   ./scripts/login.sh anthropic
   ```

5. Instala la config del agente que vas a usar:

   ```bash
   ./scripts/install-opencode-config.sh
   ./scripts/install-droid-config.sh
   ```

6. Deja corriendo el proxy en una terminal:

   ```bash
   ./scripts/proxy-start.sh
   ```

7. En otra terminal abre el agente:

   ```bash
   opencode
   # o
   droid
   ```

---

## Elegir modelo en opencode

Cuando abras opencode, escribe:

```text
/models
```

Elige el modelo que tengas disponible segun tu login:

- Si hiciste login con OpenAI, elige `gpt-5.5`, `gpt-5.4`, `gpt-5.3-codex` o `gpt-5.4-mini`.
- Si hiciste login con Anthropic, elige `claude-opus-4-8`, `claude-opus-4-7`, `claude-opus-4-6`, `claude-sonnet-4-6` o `claude-haiku-4-5-20251001`.
- Si hiciste ambos logins, puedes cambiar entre OpenAI y Anthropic.

El default es `gpt-5.5`, pero no todos los planes/cuentas muestran los mismos
modelos. Si no aparece, usa `/models` y selecciona otro.

---

## Manejar el esfuerzo: low / medium / high

En opencode puedes ver algo como:

```text
GPT-5.5 OpenAI · high
```

Ese `high` es el **effort** o variante de razonamiento del modelo. No es una
configuracion del proxy: lo maneja opencode al elegir el modelo.

Para cambiarlo:

1. Abre opencode.
2. Escribe `/models`.
3. Elige el modelo.
4. Si opencode muestra variantes, elige `low`, `medium` o `high`.

Uso recomendado:

| Effort | Cuando usarlo |
|---|---|
| `low` | Preguntas simples, cambios chicos, mas rapido |
| `medium` | Trabajo normal del curso |
| `high` | Tareas dificiles, debugging complejo, arquitectura |

Si un modelo no muestra `low/medium/high`, significa que ese modelo/proveedor no
expone variantes de effort en opencode.

Para fijarlo manualmente en una config avanzada de opencode, se puede usar
`variant` por agente. Ejemplo:

```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "model": "cliproxy/gpt-5.5",
  "agent": {
    "build": {
      "model": "cliproxy/gpt-5.5",
      "variant": "high"
    },
    "plan": {
      "model": "cliproxy/gpt-5.5",
      "variant": "high"
    }
  }
}
```

Despues de cambiar `opencode.jsonc`, cierra y vuelve a abrir opencode.

---

## Ver modelos reales disponibles

Con el proxy corriendo, puedes listar lo que tu cuenta realmente tiene activo:

### Windows

```powershell
.\scripts\list-models.ps1
```

### macOS / Ubuntu

```bash
./scripts/list-models.sh
```

Tambien puedes consultar directo:

```bash
curl http://127.0.0.1:8317/v1/models
```

---

## Terminal 1 y Terminal 2

Necesitas dos terminales:

### Terminal 1

Dejala abierta con el proxy corriendo:

```bash
./scripts/proxy-start.sh
```

En Windows:

```powershell
.\scripts\proxy-start.ps1
```

### Terminal 2

Abre el agente:

```bash
opencode
# o
droid
```

Si cierras la Terminal 1, el proxy se apaga y el agente deja de poder usar esos
modelos.

---

## Scripts incluidos

| Script | Windows | macOS/Linux | Que hace |
|---|---|---|---|
| Setup | `setup.ps1` | `setup.sh` | Descarga CLIProxyAPI y crea `config.yaml`. |
| Login | `login.ps1` | `login.sh` | Login web con OpenAI o Anthropic. |
| Proxy | `proxy-start.ps1` | `proxy-start.sh` | Arranca el proxy local en `8317`. |
| opencode | `install-opencode-config.ps1` | `install-opencode-config.sh` | Instala config de opencode. |
| droid | `install-droid-config.ps1` | `install-droid-config.sh` | Instala config de droid. |
| Modelos | `list-models.ps1` | `list-models.sh` | Lista modelos reales del proxy. |

---

## Problemas comunes

### No aparece GPT-5.5

Usa `/models` y elige otro modelo disponible. La disponibilidad depende de tu
cuenta/plan de OpenAI.

### Solo veo modelos de Anthropic

Probablemente solo hiciste login con Anthropic. Ejecuta:

```bash
./scripts/login.sh openai
```

En Windows:

```powershell
.\scripts\login.ps1 openai
```

### Solo veo modelos de OpenAI

Probablemente solo hiciste login con OpenAI. Ejecuta:

```bash
./scripts/login.sh anthropic
```

En Windows:

```powershell
.\scripts\login.ps1 anthropic
```

### El navegador no abre

Usa modo sin navegador y copia manualmente la URL:

```bash
./scripts/login.sh anthropic --no-browser
```

En Windows:

```powershell
.\scripts\login.ps1 anthropic -NoBrowser
```

### Error 401 o credenciales invalidas

Repite el login del proveedor:

```bash
./scripts/login.sh openai
./scripts/login.sh anthropic
```

### El proxy no responde

Arranca el proxy y dejalo corriendo:

```bash
./scripts/proxy-start.sh
```

### Windows bloquea scripts PowerShell

Ejecuta el setup asi:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\setup.ps1
```

---

## Seguridad

- No compartas `~/.cli-proxy-api`: contiene tus tokens personales.
- No subas tokens ni credenciales a GitHub.
- Cada alumno debe iniciar sesion con su propia cuenta.
- El proxy corre localmente en tu computadora.

---

## Reiniciar agentes

Despues de instalar o cambiar `opencode.jsonc`, cierra y vuelve a abrir
opencode. Las sesiones ya abiertas no recargan la configuracion automaticamente.
