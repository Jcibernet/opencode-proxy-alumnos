import platform, sys
print("hola desde ADENTRO del contenedor")
print("python:", sys.version.split()[0], "| kernel compartido:", platform.release())
print("la misma imagen corre esto igual en cualquier maquina — ese es el punto")
