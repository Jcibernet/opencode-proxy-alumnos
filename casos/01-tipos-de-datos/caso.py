"""Los 3 sustos de la mutación en Python — corré y mirá los asserts."""
import copy

# ── Susto 1: el alias ────────────────────────────────────────────
a = [1, 2, 3]
b = a                      # NO es copia: misma lista, dos etiquetas
b.append(4)
assert a == [1, 2, 3, 4], "a cambió aunque tocaste b"
print("susto 1 (alias): a =", a)

b = a.copy()               # defensa: copia explícita
b.append(99)
assert a == [1, 2, 3, 4]
print("defensa 1: a intacta tras mutar la copia")

# ── Susto 2: la función que muta lo prestado ─────────────────────
def limpiar_mal(filas):
    filas.pop(0)           # muta el original del que llamó
    return filas

def limpiar_bien(filas):
    return filas[1:]       # devuelve NUEVO, el original queda

datos = [["header"], ["fila1"], ["fila2"]]
limpiar_mal(datos)
assert len(datos) == 2, "perdiste una fila del original"
print("susto 2: el 'dataset' original quedó en", len(datos), "filas")

datos2 = [["header"], ["fila1"], ["fila2"]]
limpio = limpiar_bien(datos2)
assert len(datos2) == 3 and len(limpio) == 2
print("defensa 2: original intacto, limpio nuevo")

# ── Susto 3: el default mutable ──────────────────────────────────
def acumular_mal(valor, bolsa=[]):      # el default se crea UNA vez
    bolsa.append(valor)
    return bolsa

def acumular_bien(valor, bolsa=None):
    bolsa = bolsa if bolsa is not None else []
    bolsa.append(valor)
    return bolsa

assert acumular_mal(1) == [1]
assert acumular_mal(2) == [1, 2], "la bolsa 'nueva' venía usada"
print("susto 3: segunda llamada devolvió", acumular_mal(3))

assert acumular_bien(1) == [1] and acumular_bien(2) == [2]
print("defensa 3: cada llamada, bolsa nueva")

# ── Bonus: copia profunda ────────────────────────────────────────
anidada = [[1, 2], [3, 4]]
superficial = anidada.copy()
superficial[0].append(99)          # ¡la sublista sigue compartida!
assert anidada[0] == [1, 2, 99]
profunda = copy.deepcopy(anidada)
profunda[0].append(7)
assert anidada[0] == [1, 2, 99]
print("bonus: .copy() comparte sublistas; deepcopy no")

print("\n✔ todos los sustos y defensas verificados")
