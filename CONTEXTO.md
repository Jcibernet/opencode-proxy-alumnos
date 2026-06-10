# Contexto del repo

Este repo fue armado para alumnos que no necesariamente programan ni conocen
configuraciones de agentes. La idea es que puedan instalar un proxy local,
hacer login web con su propia cuenta y usar **opencode** o **droid** con modelos
de OpenAI y Anthropic.

## Objetivo

Permitir que cada alumno use:

- **opencode**: https://opencode.ai/docs/
- **droid / Factory**: https://docs.factory.ai/

con un proxy local compatible con OpenAI:

```text
http://127.0.0.1:8317
```

El proxy usado es **CLIProxyAPI**:

```text
https://github.com/router-for-me/CLIProxyAPI
```

## Principio importante

No se comparten credenciales.

Cada alumno hace login web OAuth con su propia cuenta:

```bash
./scripts/login.sh openai
./scripts/login.sh anthropic
```

En Windows:

```powershell
.\scripts\login.ps1 openai
.\scripts\login.ps1 anthropic
```

Los tokens quedan localmente en:

```text
~/.cli-proxy-api
```

Esa carpeta nunca debe compartirse ni subirse a GitHub.

## Arquitectura

```text
opencode / droid  ->  CLIProxyAPI local  ->  OpenAI / Anthropic
                         127.0.0.1:8317      web login OAuth
```

El proxy corre localmente. Los agentes apuntan al proxy con:

```text
http://127.0.0.1:8317
```

Para opencode se usa:

```text
http://127.0.0.1:8317/v1
```

## Config del proxy

La configuracion base replica el setup usado en clase:

```yaml
port: 8317
remote-management:
  allow-remote: false
secret-key: ""
auth-dir: "~/.cli-proxy-api"
auth:
  providers: []
debug: false
```

Los modelos no se cargan desde `config.yaml`. Aparecen segun:

- la cuenta con la que el alumno hizo login;
- la disponibilidad del plan de OpenAI o Anthropic;
- la config del agente (`opencode/opencode.jsonc` o `droid/settings.json`).

## Modelos configurados

### OpenAI

Login:

```bash
./scripts/login.sh openai
```

Modelos configurados:

- `gpt-5.5`
- `gpt-5.4`
- `gpt-5.3-codex`
- `gpt-5.4-mini`

Default del repo:

```text
gpt-5.5
```

### Anthropic

Login:

```bash
./scripts/login.sh anthropic
```

Modelos configurados:

- `claude-opus-4-8`
- `claude-opus-4-7`
- `claude-opus-4-6`
- `claude-sonnet-4-6`
- `claude-haiku-4-5-20251001`

Small model:

```text
claude-haiku-4-5-20251001
```

## Eleccion de modelo

El default es `gpt-5.5`, pero puede no estar disponible para todos los alumnos.
La instruccion central es que en opencode usen:

```text
/models
```

y elijan el modelo que les aparezca segun el login que hicieron.

Si hicieron login con OpenAI, deberian ver modelos GPT/Codex. Si hicieron login
con Anthropic, deberian ver Claude. Si hicieron ambos logins, pueden alternar.

## Effort: low / medium / high

Cuando opencode muestra algo como:

```text
GPT-5.5 OpenAI · high
```

ese `high` es el effort o variante de razonamiento. No lo controla el proxy.
Se cambia desde `/models` cuando el modelo/proveedor expone variantes.

Guia rapida:

- `low`: tareas simples y respuestas rapidas.
- `medium`: uso normal.
- `high`: debugging, arquitectura y tareas dificiles.

## Scripts importantes

macOS / Linux:

```bash
./scripts/setup.sh
./scripts/login.sh openai
./scripts/login.sh anthropic
./scripts/proxy-start.sh
./scripts/install-opencode-config.sh
./scripts/install-droid-config.sh
./scripts/list-models.sh
```

Windows PowerShell:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\setup.ps1
.\scripts\login.ps1 openai
.\scripts\login.ps1 anthropic
.\scripts\proxy-start.ps1
.\scripts\install-opencode-config.ps1
.\scripts\install-droid-config.ps1
.\scripts\list-models.ps1
```

## Para verificar modelos reales

Con el proxy corriendo:

```bash
curl http://127.0.0.1:8317/v1/models
```

o:

```bash
./scripts/list-models.sh
```

En Windows:

```powershell
.\scripts\list-models.ps1
```

## Decisiones tomadas

- El repo no incluye el binario de CLIProxyAPI; `setup` descarga el release oficial.
- El repo no incluye tokens ni credenciales.
- Se agregaron scripts Bash y PowerShell para cubrir Ubuntu/Linux, macOS y Windows.
- Se priorizo que sea usable por alumnos no tecnicos.
- Se documento que el proxy debe quedar corriendo en una terminal separada.
- Se dejo `gpt-5.5` como default, pero se instruye usar `/models` si no aparece.
- Anthropic y OpenAI se manejan ambos por web login OAuth.

## Si hay que cambiar modelos despues

Actualizar estos archivos:

- `opencode/opencode.jsonc`
- `droid/settings.json`
- `README.md`

Si se agrega un modelo a opencode, recordar usar el prefijo del provider:

```text
cliproxy/modelo
```

Ejemplo:

```text
cliproxy/gpt-5.5
```

Despues de cambiar la config de opencode, hay que cerrar y abrir opencode para
que cargue los cambios.
