# Skills: procedimientos que tu agente ejecuta igual todas las veces

Una **skill** es una carpeta con un `SKILL.md` adentro: instrucciones en
markdown que el agente carga **cuando la tarea lo pide** (no siempre — por eso
no infla el contexto). Si el `AGENTS.md` es la constitución del proyecto, una
skill es un **procedimiento operativo**: "así se hace X acá, paso a paso".

## Cuándo usar cada herramienta

| Herramienta | Qué guarda | Ejemplo |
|---|---|---|
| `AGENTS.md` | Reglas que aplican **siempre** | "corré tsc y eslint tras cada cambio" |
| **Skill** | Procedimiento que aplica **a veces**, repetible | "cómo publicar un post del blog", "cómo hacer un release" |
| **Subagente** | Delegación de una subtarea con contexto propio | "explorá este módulo y resumí" |

La prueba del pato: si te encontrás pegando las mismas instrucciones en el
chat por tercera vez, eso es una skill. Escribila una vez, versionala en Git,
y el agente la ejecuta igual la décima vez que la primera.

## Anatomía mínima

```
mi-skill/
└── SKILL.md      # frontmatter (name + description) + instrucciones
```

El frontmatter necesita solo dos campos — y la `description` es la parte más
importante: **es lo que el agente lee para decidir si la skill aplica** a la
tarea que tiene enfrente. Escribila pensando en eso: qué hace + cuándo usarla.

Mirá [`plantilla/SKILL.md`](./plantilla/SKILL.md) para arrancar la tuya,
[`git-flow/SKILL.md`](./git-flow/SKILL.md) como ejemplo real completo (el
flujo de ramas que usamos en el programa, escrito como skill) y
[`orquestacion-inteligente/SKILL.md`](./orquestacion-inteligente/SKILL.md) como
ejemplo de "skill de criterio": no automatiza nada, enseña a formular el pedido.
Esa última trae al lado
[`economia-multiagente.md`](./orquestacion-inteligente/economia-multiagente.md),
la medición que la respalda — el patrón de recurso pesado junto al `SKILL.md`.

## Dónde se instalan

| Harness | Ubicación |
|---|---|
| Claude Code | `.claude/skills/` (proyecto) o `~/.claude/skills/` (global) |
| Droid (Factory) | `.factory/skills/` en el repo |
| Claude.ai / API | se suben como archivos (ver links abajo) |

En opencode todavía no hay skills nativas: el equivalente es referenciar el
archivo desde tu `AGENTS.md` ("para releases, seguí `skills/git-flow/SKILL.md`").

## Los referentes — a quién copiarle

- **[agentskills.io](https://agentskills.io)** — la **especificación** del formato, corta y legible; leela una vez para saber qué es estándar y qué es de cada harness
- **[anthropics/skills](https://github.com/anthropics/skills)** — EL repo de referencia: los ejemplos oficiales de Anthropic + las skills reales que Claude usa en producción para documentos. Skills concretas para estudiar:
  - **[template](https://github.com/anthropics/skills/tree/main/template)** — el esqueleto oficial para arrancar
  - **[pdf](https://github.com/anthropics/skills/tree/main/skills/pdf)** / **[docx](https://github.com/anthropics/skills/tree/main/skills/docx)** / **[xlsx](https://github.com/anthropics/skills/tree/main/skills/xlsx)** / **[pptx](https://github.com/anthropics/skills/tree/main/skills/pptx)** — las skills de producción de Claude: mirá cómo mezclan instrucciones + scripts + recursos; es el patrón "skill compleja" hecho por los autores del formato
  - **[brand-guidelines](https://github.com/anthropics/skills/tree/main/skills/brand-guidelines)** — el patrón "skill de criterio": no automatiza nada, le enseña gusto al agente
  - **[canvas-design](https://github.com/anthropics/skills/tree/main/skills/canvas-design)** — skill con recursos pesados (fuentes) al lado del SKILL.md
- **[Claude Code — Skills](https://docs.claude.com/en/docs/claude-code/skills)** — la doc oficial de cómo el harness las descubre y carga
- **[Creating custom skills](https://support.claude.com/en/articles/12512198-creating-custom-skills)** — la guía paso a paso oficial para escribir la tuya
- **[Equipping agents for the real world](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills)** — el post de ingeniería que explica el **porqué** del diseño (progressive disclosure); leelo cuando quieras entender qué problema resuelven de verdad
- **[skills.sh](https://skills.sh)** — directorio comunitario: para ver qué está construyendo la gente y robar ideas

## La regla de oro

Una skill se escribe **después** de hacer la tarea a mano al menos dos veces
con éxito. Primero verificás que el procedimiento funciona; recién ahí lo
congelás. Skill escrita antes de validar = bug documentado.
