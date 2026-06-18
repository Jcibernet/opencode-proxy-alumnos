# Guia de usuario -- opencode-proxy-alumnos

Una vez instalado, asi se usa en el dia a dia.

---

## Dia a dia (3 pasos)

### 1. Abri el proxy (Terminal 1)

```bash
cd opencode-proxy-alumnos
./scripts/proxy-start.sh
```

Deja esa terminal abierta. El proxy queda escuchando en `http://127.0.0.1:8317`.

### 2. Abri el agente (Terminal 2)

```bash
opencode
# o si usas droid:
droid
```

### 3. Eleji tu modelo

Apenas abra opencode, escribi:

```
/models
```

Te va a mostrar los modelos disponibles segun con que cuenta hiciste login.

**OpenAI (GPT / Codex):**
- `gpt-5.5` -- el mas potente, default del repo
- `gpt-5.4` -- alternativa general
- `gpt-5.3-codex` -- optimo para codigo
- `gpt-5.4-mini` -- rapido y liviano

**Anthropic (Claude):**
- `claude-opus-4-8` -- tope de gama
- `claude-opus-4-7` / `claude-opus-4-6` -- versiones anteriores
- `claude-sonnet-4-6` -- balance velocidad/calidad
- `claude-haiku-4-5-20251001` -- el mas rapido

> Si no ves un modelo, probablemente no hiciste login con ese proveedor. Volve a correr `./scripts/login.sh openai` o `./scripts/login.sh anthropic`.

---

## Elegir el "esfuerzo" del modelo

Cuando elegis modelo en `/models`, a veces ves:

```
GPT-5.5 OpenAI · high
```

Ese `high` es el **effort** o nivel de razonamiento:

| Effort | Cuando usarlo |
|--------|---------------|
| `low` | Consultas rapidas, cambios chicos |
| `medium` | Trabajo normal del dia a dia |
| `high` | Bugs dificiles, arquitectura, tareas complejas |

No todos los modelos muestran variantes de effort. Si no aparecen, no te preocupes.

---

## Ver que modelos tenes realmente

Con el proxy corriendo:

```bash
./scripts/list-models.sh
# o directo con curl:
curl http://127.0.0.1:8317/v1/models
```

Esto te muestra los modelos que tu cuenta realmente tiene habilitados, no la lista teorica del repo.

---

## Cambiar de cuenta o re-login

Si cambiaste de cuenta o se vencio la sesion:

```bash
./scripts/login.sh openai        # re-login OpenAI
./scripts/login.sh anthropic     # re-login Anthropic
```

Se abre el navegador, inicias sesion y listo. Los tokens se guardan en `~/.cli-proxy-api`.

---

## Consejos

- **Manten actualizado el proxy**: de vez en cuando corre `./scripts/setup.sh` para bajar la ultima version de CLIProxyAPI.
- **No compartas `~/.cli-proxy-api`**: ahi estan tus tokens personales. Esa carpeta esta en `.gitignore`.
- **Si el proxy se cae**: reinicia `./scripts/proxy-start.sh` en la Terminal 1.
- **Si opencode no reconoce el modelo**: cerra y volve a abrir opencode para que lea la config nueva.
- **Si ves `401` o `Unauthorized`**: hace login de nuevo con `./scripts/login.sh`.

---

## Estructura de archivos

```
opencode-proxy-alumnos/
  config.yaml          -- config del proxy (web login OAuth, sin API keys)
  bin/cli-proxy-api    -- el binario del proxy (lo descarga setup.sh)
  opencode/
    opencode.jsonc     -- config de opencode (se copia a ~/.config/opencode/)
  droid/
    settings.json      -- custom models de droid (se copia a ~/.factory/)
  scripts/
    setup.sh           -- descarga el proxy y crea config.yaml
    login.sh           -- login web OAuth con OpenAI o Anthropic
    proxy-start.sh     -- arranca el proxy en puerto 8317
    install-*.sh       -- copia la config al lugar correcto
    list-models.sh     -- muestra los modelos reales de tu cuenta
```
