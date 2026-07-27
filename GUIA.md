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

## Como pedirle las cosas al agente

Esta parte no es sobre el proxy: es sobre como usar el agente para que rinda.
Cambia mas el resultado que elegir modelo.

**Una orden completa vale mas que 300 pedidos sueltos.**

### Por que

Cada turno de una sesion reenvia el contexto acumulado. El turno N paga por todo
lo que paso en los turnos 1 a N-1.

```
costo  ~  turnos x contexto_promedio
            |              |
       vos lo elegis   crece con los turnos
```

Los dos factores crecen juntos, asi que el costo es superlineal en la cantidad de
turnos. Medicion real sobre 50 sesiones de trabajo:

| turnos | output que produjo | contexto releido | ratio |
|--------|--------------------|------------------|-------|
| 2350   | 1.65M tokens       | 802M tokens      | 485:1 |
| 2508   | 1.32M tokens       | 561M tokens      | 424:1 |
| 1578   | 1.35M tokens       | 513M tokens      | 379:1 |
| 1072   | 0.68M tokens       | 401M tokens      | 592:1 |

Cuatro sesiones largas concentraron mas de la mitad del consumo total de las 50.

Y el dato clave: **el ratio se mantiene igual sin importar que modelo corras**.
Cambiar de modelo no mueve esto. Cambiar como pedis, si.

### Las tres formas de trabajar

**Peor: 300 pedidos independientes.** Cada pedido es un turno que arrastra todo lo
anterior. Ademas pagas tres veces: reestablecer contexto, planificar con informacion
parcial, y rehacer lo que el pedido 40 hizo distinto al 90.

**Mejor: una orden completa.** El modelo planifica una vez contra informacion
completa, ejecuta, y verifica.

**Optimo: una orden completa que abre en paralelo.** El contexto de un subagente es
descartable: arranca de cero, trabaja con contexto chico, y devuelve solo el resumen.
Si el costo crece con el cuadrado de los turnos, repartir gana:

```
1 sesion  x 160 turnos  ->  160 x 160    = 25.600
8 agentes x  20 turnos  ->  8 x 20 x 20  =  3.200
```

Ocho veces mas barato, y ademas terminan antes porque corren a la vez.

### Que lleva una orden completa

- **Objetivo**: que tiene que ser verdad cuando termine.
- **Alcance**: archivos y funciones exactas. Y que NO tocar.
- **Restricciones**: convenciones, librerias permitidas, patrones a seguir.
- **Contratos**: si se reparte en paralelo, las interfaces se deciden ANTES.
- **Criterio de aceptacion**: observable, no "que funcione".
- **Verificacion**: el comando concreto que lo prueba.

Lo que no esta en la orden, el modelo lo inventa. Y lo inventa distinto cada vez.

### Anti-patrones

- **Goteo**: "ahora hace X" repetido 300 veces. Cada gota cuesta el contexto entero.
- **Un archivo por pedido**: si son 20 archivos independientes, es una orden con
  reparto, no 20 pedidos.
- **Ping-pong antes de arrancar**: cada aclaracion es un turno caro. Manda el brief
  completo aunque te lleve mas escribirlo.
- **Pedir confirmacion a mitad**: duplica los turnos y corta el hilo de razonamiento.
- **Serializar lo que no depende**: si B no necesita la salida de A, van juntos.
- **Sesion eterna**: seguir en el turno 2000 porque "ya tiene contexto". Ese contexto
  es exactamente lo que estas pagando en cada turno.

### Cuando cortar la sesion

Cortar y arrancar de nuevo es la optimizacion mas grande y es gratis. Una sesion de
2500 turnos cuesta varias veces una de 500 por el mismo trabajo.

Corta cuando:

- Cambiaste de tarea u objetivo.
- El agente empieza a releer cosas que ya habia leido.
- La tarea original ya esta terminada y verificada.

> Regla corta: escribi el brief completo, identifica que partes son independientes,
> deja que llegue hasta la verificacion sin interrumpir, y corta cuando termino.

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
