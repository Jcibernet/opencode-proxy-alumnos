# Caso 8 — System Design: práctica con Excalidraw

Acá no se corre código: se dibuja y se defiende. El método completo está en la
página **System Design para datos** (track Engineering, Notion del programa).

## El ejercicio (25 minutos por pregunta)

1. Elegí una pregunta del banco de abajo.
2. Abrí [excalidraw.com](https://excalidraw.com) y seguí los 5 pasos:
   requisitos → estimación → modelo de datos → arquitectura → cuellos de botella.
3. Guardá el `.excalidraw` en este directorio (se versiona como cualquier archivo).
4. Exportá como PNG y pedile a tu agente (opencode/droid vía el proxy):
   > "Criticá este diseño: cuellos de botella, costos, puntos de falla, qué me olvidé."
5. Iterá el diagrama con la crítica. Dos rondas mínimo.

## Banco de preguntas

| # | Pregunta | Pista de escala |
|---|---|---|
| 1 | Reportes diarios de ventas para una cadena de 200 locales | ~2M tickets/día |
| 2 | El negocio quiere "ver las ventas en vivo" | picos de 500 eventos/seg |
| 3 | Warehouse para cortar ventas por cliente/producto/tiempo | 3 años de historia |
| 4 | Exponer métricas a 5 equipos internos vía API | p95 < 200ms |
| 5 | Chatbot que responde con los manuales internos de la empresa | 10k documentos |
| 6 | Detectar fraude en transacciones antes de aprobarlas | decisión < 1 seg |

## Checklist antes de dar por terminado un diseño

- [ ] ¿Definí qué NO hace el sistema?
- [ ] ¿Estimé eventos/día y GB/mes con números?
- [ ] ¿El modelo de datos (MER) está ANTES que las cajas de infra?
- [ ] ¿Sé qué componente se rompe primero al ×10?
- [ ] ¿Idempotencia: correr dos veces no duplica?
- [ ] ¿Qué pasa si la fuente llega tarde / el consumidor se cae?
