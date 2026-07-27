---
name: orquestacion-inteligente
description: Usar cuando haya que decidir CÓMO pedirle el trabajo a un agente — una orden completa vs muchos pedidos chicos, cuándo delegar en subagentes, cuándo cortar la sesión, o para diagnosticar por qué una sesión salió cara o el resultado se degradó. Aplica antes de mandar el pedido, no después.
---

# Orquestación inteligente

Objetivo: que el trabajo salga mejor y cueste menos, cambiando la **forma** del
pedido en vez del modelo.

Una orden completa vale más que 300 pedidos sueltos. No es estilo: es la
estructura del costo. Los números que lo respaldan están en
[`economia-multiagente.md`](./economia-multiagente.md) — medición real sobre
29.226 turnos y USD 5.011 de consumo.

El resumen de esa medición en una línea: **el 71% del gasto es releer contexto,
el 10% es producir la respuesta**.

## Pasos

1. **Escribí el brief completo antes de mandar nada.** Tiene que llevar:
   - Objetivo: qué tiene que ser verdad cuando termine.
   - Alcance: archivos y funciones exactas, y qué NO tocar.
   - Restricciones: convenciones, librerías permitidas, patrones a seguir.
   - Criterio de aceptación: observable, no "que funcione".
   - Verificación: el comando concreto que lo prueba.

   Lo que no está en el brief, el modelo lo inventa. Y lo inventa distinto
   cada vez.

2. **Separá lo independiente de lo secuencial.** Escribí la lista de subtareas
   y marcá cuáles necesitan la salida de otra. Solo esas van en orden; el resto
   va junto. Si dos subtareas comparten una interfaz, **definila vos en el brief**:
   que dos agentes negocien un contrato a mitad de camino es una falla de diseño.

3. **Mandá una sola orden que abra las independientes en paralelo.** Un subagente
   arranca con contexto vacío, trabaja chico y devuelve solo el resumen. En la
   medición, los subagentes hicieron el **43% de los turnos por el 6,5% del costo**:
   USD 0,026 por turno contra USD 0,281 del hilo principal.

4. **No interrumpas hasta la verificación.** Cada confirmación a mitad es un turno
   que arrastra todo el contexto acumulado. Definí el criterio al principio y dejá
   que llegue hasta el final.

5. **Cortá la sesión cuando la tarea terminó.** Rearrancar es gratis; seguir no.

## Verificación

Antes de mandar, revisá que el brief pase estas tres:

- ¿Puede alguien que no estuvo en la conversación ejecutarlo sin preguntar nada?
- ¿Está escrito el comando que prueba que quedó bien?
- ¿Lo que puede correr en paralelo está agrupado en un solo pedido?

Si alguna da que no, el pedido todavía no está listo: te va a costar más en
turnos de aclaración que lo que tardás en completarlo ahora.

Después de trabajar, la señal de que lo hiciste bien es la cantidad de turnos.
Una tarea que resolviste en 40 turnos y antes te llevaba 300 no es suerte:
es que el brief hizo el trabajo.

## Límites

- **No aplica a exploración.** Si todavía no sabés qué querés, conversá corto y
  después escribí el brief. El anti-patrón es conversar 300 turnos y nunca
  escribirlo.
- **No fuerces paralelismo donde hay dependencia real.** Si B necesita lo que
  produce A, va en orden. Abrir en paralelo lo que depende genera retrabajo, que
  es más caro que la serialización.
- **No optimices peleándole a la compactación.** Compactar más seguido invalida
  el caché y puede salir más caro. La palanca es mandar menos turnos, no
  comprimir más.
- **Cuándo parar y preguntar**: si el alcance toca algo destructivo (borrar datos,
  reescribir historia de Git, tocar producción), eso no va en un brief autónomo.
  Eso se confirma.
