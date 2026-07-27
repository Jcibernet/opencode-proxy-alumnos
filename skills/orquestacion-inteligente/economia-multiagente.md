# Economía de la orquestación multiagente

Medición real de un entorno de trabajo con agentes, con el desglose de dónde se
va el dinero y por qué. No son estimaciones: son los contadores de uso de
29.226 turnos registrados en 50 sesiones.

---

## 1. Metodología

Los datos salen de los registros de sesión del agente (`~/.omp/agent/sessions/`),
donde cada mensaje persiste su bloque `message.usage` con cuatro contadores de
token y su costo derivado:

| Campo | Qué mide |
|---|---|
| `input` | Tokens nuevos enviados al modelo en ese request |
| `output` | Tokens que el modelo generó |
| `cacheRead` | Tokens leídos del caché de prompt (contexto ya enviado antes) |
| `cacheWrite` | Tokens escritos al caché de prompt |
| `reasoningTokens` | Subconjunto de `output` gastado en razonamiento interno |

Los costos en USD son **precio de lista** de cada proveedor. En un plan por
suscripción no se facturan así, pero siguen siendo la medida correcta de
consumo relativo: es lo que se come la cuota.

Agregación: se recorren todos los `.jsonl` de sesión (hilo principal) y de
artefacto de subagente, sumando por componente.

---

## 2. El resultado central

```
                    tokens              USD        % del costo
input             119.409.911        $  260,61          5,2 %
output             19.555.519        $  505,72         10,1 %
cacheRead       5.234.903.278        $3.555,67         71,0 %
cacheWrite         73.539.700        $  689,31         13,8 %
─────────────────────────────────────────────────────────────
TOTAL           5.447.408.408        $5.011,31        100,0 %

turnos: 29.226        promedio: 186.394 tokens/turno, $0,1715/turno
```

Tres lecturas que cambian cómo se trabaja:

**El 71% del gasto es releer contexto.** No generar respuestas: releer lo que ya
se había mandado. Sumando `cacheWrite`, la gestión de contexto es el **84,7%**
del total.

**Producir la respuesta es el 10%.** Los 19,5M de tokens de `output` — el
producto real del trabajo — son el 0,36% de los tokens y el 10,1% del costo.

**Por cada USD 1 de respuesta producida se gastan USD 7,03 en releer.**

El caché no es el problema: es lo que hace viable un contexto largo. Sin él,
esos 5.234M de tokens se facturarían a precio de input completo. El problema
es *cuántas veces* hay que releer, y eso lo determina la cantidad de turnos.

---

## 3. Por qué el costo crece más rápido que el trabajo

Cada turno reenvía el contexto acumulado. El turno N paga por los turnos 1..N-1.

```
costo_total  ≈  Σ  contexto(i)      donde contexto(i) crece con i
                i=1..n
```

Medido: costo marginal por turno según el largo de la sesión.

| turnos | contexto promedio | USD/turno | costo total |
|-------:|------------------:|----------:|------------:|
| 21     | 33.048            | $0,041    | $0,86       |
| 98     | 116.933           | $0,191    | $18,71      |
| 220    | 204.231           | $0,297    | $65,38      |
| 373    | 256.919           | $0,337    | $125,54     |
| 517    | 324.057           | $0,347    | $179,23     |
| 584    | 313.863           | $0,440    | $257,06     |
| 1.072  | 373.897           | $0,444    | $476,07     |
| 1.578  | 325.118           | $0,402    | $634,75     |
| 2.350  | 341.385           | $0,416    | $978,25     |

**El mismo turno cuesta 10,8× más en una sesión de 1.072 turnos que en una de 21.**

El sistema tiene dos regímenes:

- **Crecimiento** (hasta ~600 turnos): el contexto crece con cada turno, así que
  el costo acumulado crece de forma cuadrática.
- **Saturación** (más de ~600): la compactación tapa el contexto alrededor de
  340k tokens y el costo pasa a ser lineal, pero anclado en una meseta alta de
  ~$0,42 por turno.

No hay un tercer régimen donde se abarate. Una sesión larga nunca se recupera.

### El cálculo que importa

Los mismos 2.350 turnos, repartidos:

```
1 sesión  × 2.350 turnos  →  $978,25
24 sesiones × ~98 turnos  →  24 × $18,71  =  $449,04     (54% menos)
```

Mismo trabajo. La diferencia es sólo dónde se cortó.

---

## 4. La delegación rompe la curva

Un subagente arranca con contexto vacío, trabaja con contexto chico y devuelve
sólo el resumen. Su contexto es **descartable**: nunca vuelve al hilo principal.

```
                turnos      % turnos    cacheRead        USD      USD/turno
principal       16.684        57,0 %    4.261.682.170   $4.690,47   $0,2811
subagentes      12.585        43,0 %      975.692.096   $  325,05   $0,0258
```

**Los subagentes hicieron el 43% de los turnos por el 6,5% del costo.**
Un turno de subagente sale **10,9× más barato** que uno del hilo principal.

Dos factores, multiplicativos:

1. **Contexto por turno**: 77.500 tokens en subagente contra 255.400 en el
   principal. 3,3× menos.
2. **Modelo**: los subagentes corren modelos más baratos por rol.

Aritmética del reparto, asumiendo régimen cuadrático:

```
1 sesión  × 160 turnos  →  160²        = 25.600 unidades
8 agentes ×  20 turnos  →  8 × 20²     =  3.200 unidades     (8× menos)
```

Cada subagente paga su propio n² chico en vez de sumar a un n² grande. Y como
corren simultáneos, además termina antes en tiempo de reloj.

---

## 5. Costo efectivo por modelo

```
modelo                 turnos    USD/turno    input      output    cacheRead   cacheWrite    total
deepseek-v4-pro         5.800     $0,0061    $ 19,85    $ 10,17    $    5,43    $  0,00    $  35,45
gpt-5.4-mini              165     $0,0146    $  0,80    $  0,85    $    0,76    $  0,00    $   2,41
claude-sonnet-5         4.825     $0,0422    $  1,35    $ 46,34    $  116,05    $ 39,15    $ 203,53
gpt-5.6-sol             3.419     $0,0817    $ 95,63    $ 21,03    $  162,55    $  0,00    $ 279,22
gpt-5.5                 2.150     $0,1018    $ 83,30    $ 21,76    $  113,77    $  0,00    $ 218,82
glm-5.2                   452     $0,1462    $ 51,88    $  0,49    $   13,70    $  0,00    $  66,07
claude-opus-5             437     $0,1667    $  0,24    $  8,82    $   49,28    $ 14,25    $  72,85
claude-opus-4-8         1.196     $0,1897    $  1,02    $ 40,07    $  128,00    $ 57,74    $ 226,82
claude-fable-5          9.870     $0,3955    $  6,10    $355,38    $2.964,87    $577,58    $3.903,93
```

### Hallazgo 1: un solo modelo concentró el 78% del gasto

`claude-fable-5` costó USD 3.903,93 de USD 5.011,31. De eso, USD 2.964,87 fue
`cacheRead` y USD 577,58 `cacheWrite`: **el 91% de su costo fue gestión de
contexto**, no generación. Su output fueron USD 355,38.

### Hallazgo 2: el precio de lista no predice el costo efectivo

`glm-5.2` tiene precio de lista de $1,40/$4,40 por millón — 3,5× más barato en
input que `gpt-5.6-sol` ($5/$30). Pero su costo efectivo fue **1,8× más alto por
turno** ($0,1462 vs $0,0817).

La razón está en la composición: de los USD 66,07 de glm-5.2, USD 51,88 fueron
input y sólo USD 13,70 cacheRead. Corrió en sesiones cortas que nunca
amortizaron el caché. `gpt-5.6-sol`, con sesiones largas, movió la mayor parte
de su contexto por caché.

**Conclusión operativa**: lo que determina el costo efectivo no es el precio del
modelo sino la tasa de acierto de caché, y ésa depende de la forma de la sesión.

### Hallazgo 3: asimetría de `cacheWrite` entre proveedores

```
Anthropic     fable-5 $577,58 · opus-4-8 $57,74 · sonnet-5 $39,15 · opus-5 $14,25
OpenAI        gpt-5.6-sol $0,00 · gpt-5.5 $0,00 · gpt-5.4-mini $0,00
opencode-go   glm-5.2 $0,00 · deepseek-v4-pro $0,00
```

Anthropic factura la escritura de caché (aproximadamente 1,25× el precio de
input). OpenAI y los proveedores compatibles no la cobran por separado.

En este entorno, `cacheWrite` fueron USD 689,31 — el 13,8% del total — y
**el 100% se generó en modelos Anthropic**. Es un sobrecosto estructural del
proveedor que no aparece en ninguna tabla de precios comparativa.

### Hallazgo 4: 5.800 turnos por USD 35

`deepseek-v4-pro` hizo más turnos que `gpt-5.6-sol` (5.800 vs 3.419) y costó 8×
menos. Contra `claude-fable-5` es **65× más barato por turno**. Ese es el
argumento de la delegación reducido a un número: el trabajo de exploración y
lectura no necesita el modelo caro.

---

## 6. Variables de configuración

Éstas son las variables concretas que gobiernan lo anterior, con los valores
antes y después de la optimización de este entorno.

### 6.1 Asignación de modelo por rol

```yaml
modelRoles:
  default:  anthropic/claude-opus-5:high        # antes: claude-fable-5:high
  smol:     openai-codex/gpt-5.6-terra:high     # antes: cliproxy/... (endpoint caído)
  plan:     openai-codex/gpt-5.6-sol:high       # antes: :medium
  slow:     opencode-go/kimi-k3:max             # antes: claude-fable-5:high
  task:     opencode-go/glm-5.2:high            # antes: anthropic/claude-sonnet-5:high
  designer: openai-codex/gpt-5.6-sol:high
  tiny:     opencode-go/deepseek-v4-flash:high  # antes: sin definir (caía a smol)
  commit:   "@tiny"                             # antes: sin definir
  advisor:  anthropic/claude-sonnet-5:high      # antes: sin definir
```

El rol `tiny` gobierna las tareas de fondo — títulos de sesión, memoria,
clasificación de dificultad, detección de parada inesperada — que disparan
constantemente. Sin definir, caen al rol `smol`. Definirlo por separado saca ese
tráfico de alta frecuencia de la cuota cara.

El sufijo `:high` es el nivel de esfuerzo de razonamiento, y **su significado
cambia por modelo**:

| modelo | escalera de esfuerzo | dónde cae `high` |
|---|---|---|
| `claude-opus-5` | low · medium · high · xhigh · max | 3 de 5 |
| `gpt-5.6-sol` | none · low · medium · high · xhigh · max | 4 de 6 |
| `glm-5.2` | high · max | **el piso** |
| `deepseek-v4-pro` | high · max | **el piso** |
| `grok-4.5` | low · medium · high | **el techo** |
| `kimi-k3` | max | único valor |

Escribir `:high` en todos los roles no aplica el mismo esfuerzo: en unos es el
mínimo posible y en otros el máximo. La configuración no valida esto — un valor
inválido falla en tiempo de request, no al cargar.

### 6.2 Modelo por subagente

```yaml
task:
  agentModelOverrides:            # antes: {} — todos heredaban un mismo modelo
    scout:     opencode-go/deepseek-v4-pro:high
    librarian: opencode-go/deepseek-v4-pro:high
    sonic:     opencode-go/deepseek-v4-flash:high
    reviewer:  anthropic/claude-opus-5:high
    task:      opencode-go/glm-5.2:high
```

Precedencia: `agentModelOverrides` → frontmatter del agente → modelo de la sesión
padre. Con el record vacío, todos los subagentes corren el modelo del padre y se
pierde el ahorro del punto 4.

Distribución medida de invocaciones sobre 324 spawns:

```
task        263  (81,2 %)      sonic         8  (2,5 %)
reviewer     28  ( 8,6 %)      designer      6  (1,9 %)
scout        16  ( 4,9 %)      librarian     3  (0,9 %)
```

El agente genérico `task` concentra el volumen. Es el único override con impacto
material; los demás son correctos pero marginales.

### 6.3 Lectura de archivos

```yaml
read:
  summarize:
    enabled: false      # default true
    minTotalLines: 100
    unfoldLimit: 100
  defaultLimit: 800     # default 300
```

Con `summarize.enabled: true` el agente recibe resúmenes estructurales —
declaraciones con los cuerpos elididos — en vez del código. Afecta directamente
la calidad del razonamiento: un modelo que no vio el cuerpo de una función no
puede evaluarla.

Contrapartida: leer verbatim infla el contexto, y ese contexto se reenvía en
cada turno. Es el intercambio calidad/costo más directo de toda la configuración.

Advertencia medida: el summarizer interviene menos de lo esperado. Un archivo de
540 líneas con 90 funciones se devolvió verbatim **con `summarize` activado**,
porque `unfoldLimit: 100` despliega hasta 100 declaraciones. El interruptor pesa
menos que su nombre sugiere.

### 6.4 Compactación

```yaml
compaction:
  enabled: true
  strategy: snapcompact       # context-full | handoff | shake | snapcompact | off
  thresholdPercent: -1        # -1 = contextWindow - max(15%, reserveTokens)
  keepRecentTokens: 20000
  midTurnEnabled: true
  idleEnabled: false          # ← apagado por defecto
  idleThresholdTokens: 200000
  idleTimeoutSeconds: 300
```

La compactación reescribe la historia vieja en un resumen para que la sesión
siga. Con una ventana de 1M tokens, el umbral por defecto dispara alrededor de
850k.

`snapcompact` no llama a ningún modelo: renderiza la historia descartada como
imágenes PNG con fuentes de píxel y las pasa por el canal de visión. Requiere un
modelo con visión; si no, cae a `context-full`.

**Contraintuición importante**: compactar más seguido no es automáticamente más
barato. Reescribir la historia invalida el prefijo cacheado, y el turno siguiente
relee todo a precio de input completo. Dado que el `cacheRead` es el 71% del
gasto *y a la vez* lo que evita pagar precio de input, bajar el umbral de
compactación puede aumentar el costo.

`idleEnabled` es la excepción útil: compacta tras 5 minutos de inactividad,
cuando el caché ya expiró y la invalidación no cuesta nada.

### 6.5 Traspaso a modelo barato

```yaml
prewalk:
  enabled: false      # destino: el rol smol; por corrida con --prewalk-into
task:
  prewalk: false      # equivalente para el subagente genérico
  agentPrewalk: {}    # por agente
```

Arranca en el modelo activo y traspasa a uno barato **en el primer edit/write
posterior a que exista la lista de tareas**. Separa las dos fases con perfiles de
costo distintos: leer y planificar (pocos turnos, alto valor por turno) contra
editar y verificar (muchos turnos, bajo valor por turno).

### 6.6 Revisor continuo y respaldo

```yaml
advisor:
  enabled: true
  subagents: false          # evita que se multiplique por subagente
retry:
  modelFallback: true
  fallbackRevertPolicy: cooldown-expiry
  fallbackChains:
    default:
      - anthropic/claude-opus-5:high
      - openai-codex/gpt-5.6-sol:high
```

El `advisor` es un segundo modelo que revisa cada turno completado e inyecta
advertencias. Tiene costo por turno: con `subagents: false` se limita al hilo
principal.

Las cadenas de respaldo son por rol y aceptan sufijo de esfuerzo. Cubren el
agotamiento de cuota: cuando el modelo primario entra en enfriamiento, se
degrada al siguiente y vuelve al expirar.

### 6.7 Presupuestos de razonamiento

```yaml
defaultThinkingLevel: high
thinkingBudgets:
  minimal: 1024
  low:     2048
  medium:  8192
  high:   16384
  xhigh:  32768
  max:    32768     # ← idéntico a xhigh
```

Para modelos que reciben presupuesto en tokens, `max` no otorga nada por encima
de `xhigh`. Subir de uno a otro no compra razonamiento adicional salvo que se
modifique el presupuesto.

---

## 7. Reparto de cuota por proveedor

Con proveedores por suscripción, el costo en dólares deja de ser la restricción
y pasa a serlo la cuota. Estado medido de los límites:

```
límite                        actual    pico histórico
openai-codex 7d primario       46 %         100 %
openai-codex 7d secundario     19 %         100 %
anthropic 5h                   17 %         100 %
anthropic 7d                    6 %          84 %
```

La ventana de 5 horas de Anthropic llegó al 100% mientras la de 7 días se quedó
en 84%. **El cuello de botella es la ráfaga, no el volumen semanal**: no se
consume demasiado en total, se concentra. Los subagentes en paralelo golpean
todos a la vez y son exactamente el patrón que satura una ventana corta.

De ahí el criterio de reparto: el trabajo de alto volumen va a la suscripción
con más aire, y las cuotas ajustadas se reservan para los roles que las
justifican.

---

## 8. Conclusiones

1. **El gasto está en releer, no en producir.** 71% `cacheRead` contra 10%
   `output`. Optimizar la calidad de las respuestas no mueve la aguja; optimizar
   cuántas veces se relee el contexto, sí.

2. **La longitud de sesión es la variable dominante.** El mismo turno cuesta
   10,8× más en una sesión de 1.072 turnos que en una de 21. Cortar y rearrancar
   con un traspaso reduce el costo a la mitad para el mismo trabajo.

3. **La delegación rompe la curva cuadrática.** 43% de los turnos por 6,5% del
   costo. Cada subagente paga su propio n² chico en vez de sumar a uno grande.

4. **El precio de lista no predice el costo efectivo.** La tasa de acierto de
   caché domina, y depende de la forma de la sesión, no del modelo.

5. **Cambiar de modelo no arregla un patrón de uso malo.** La proporción
   cacheRead:output se mantuvo entre 379:1 y 592:1 en todas las sesiones largas,
   independientemente del modelo. La forma del pedido es la palanca real.
