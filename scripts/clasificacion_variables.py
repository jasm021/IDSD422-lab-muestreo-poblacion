# clasificacion_variables.py — Parte A: clasificación de las variables de clientes.csv.
#
# El archivo data/clientes.csv tiene 12 clientes y 7 variables (más el id).
# El objetivo: clasificar cada variable (numérica continua/discreta, categórica
# binaria/ordinal/nominal) y verificar la clasificación en código.
#
# Regla del capítulo 3: el dtype es una pista, no la clasificación — el criterio
# (¿tiene sentido la mitad del valor? ¿hay orden entre las categorías?) decide.
#
# Uso (desde la raíz del repositorio):  python scripts/clasificacion_variables.py

import pandas as pd

clientes = pd.read_csv("data/clientes.csv")

# ---------------------------------------------------------------------------
# 1. Estructura del archivo
# ---------------------------------------------------------------------------
print(f"Dimensiones: {clientes.shape[0]} filas × {clientes.shape[1]} columnas")
print()
print("Primeras filas:")
print(clientes.to_string(index=False))
print()

# ---------------------------------------------------------------------------
# 2. Tipos inferidos (dtype) — la pista que da el lenguaje
# ---------------------------------------------------------------------------
print("Tipos inferidos (dtype):")
print(clientes.dtypes)
print()
# TODO 1: ¿qué columnas llegan como número y cuáles como texto? Anótalo para el
#         informe. Ojo con satisfaccion: llega como número y es ordinal
#         ("4 no es el doble de 2") — la justificación va en el informe.

# ---------------------------------------------------------------------------
# 3. Valores únicos — ¿cuántas categorías hay y cuáles son?
# ---------------------------------------------------------------------------
# TODO 2: completa el bucle para imprimir, por columna, cuántos valores únicos
#         hay y cuáles son. Pista: for columna in clientes.columns: ...  con
#         clientes[columna].unique() y len(). ¿Cuántas categorías tiene genero?
print("Valores únicos por columna:")
for columna in clientes.columns:
    valores = clientes[columna].unique()
    print(f"  {columna:20s} {len(valores):3d} únicos -> {valores.tolist()}")
print()

# ---------------------------------------------------------------------------
# 4. Declarar el orden de las variables ordinales
# ---------------------------------------------------------------------------
# Una ordinal se guarda como texto (o como número) y su orden natural se pierde:
# alfabéticamente "Posgrado" iría antes que "Primaria", que no tiene sentido.
#
# TODO 3: convierte nivel_educacion a categoría ordenada.
#         Pista: astype(pd.CategoricalDtype(categories=[...], ordered=True)).
#         Comprueba con .min(): debe devolver "Primaria".
orden_educacion = ["Primaria", "Secundaria", "Universidad", "Posgrado"]
clientes["nivel_educacion"] = clientes["nivel_educacion"].astype(
    pd.CategoricalDtype(categories=orden_educacion, ordered=True))
print("nivel_educacion — orden declarado:", clientes["nivel_educacion"].cat.categories.tolist())
print("  min:", clientes["nivel_educacion"].min(), "| max:", clientes["nivel_educacion"].max())

# TODO 4: haz lo mismo con satisfaccion (escala 1–5 como etiquetas ordenadas).
#         Prueba extra: ¿qué pasa si en la lista de categorías escribes
#         "Postgrado" (con t) para nivel_educacion? Cuenta los faltantes con
#         .isna().sum() — la trampa del typo es silenciosa.
clientes["satisfaccion"] = clientes["satisfaccion"].astype(
    pd.CategoricalDtype(categories=[1, 2, 3, 4, 5], ordered=True))
print("satisfaccion — orden declarado:", clientes["satisfaccion"].cat.categories.tolist())
print("  min:", clientes["satisfaccion"].min(), "| max:", clientes["satisfaccion"].max())

original = pd.read_csv("data/clientes.csv")
con_typo = original["nivel_educacion"].astype(
    pd.CategoricalDtype(categories=["Primaria", "Secundaria", "Universidad", "Postgrado"],
                        ordered=True))
print("Faltantes con el typo 'Postgrado':", con_typo.isna().sum())
print()

# ---------------------------------------------------------------------------
# 5. Resumen de la clasificación (para el informe)
# ---------------------------------------------------------------------------
# TODO 5: completa el resumen con el tipo de cada variable (el criterio que
#         justifica cada clasificación va en el informe).
clasificacion = {
    "cliente_id": "Identificador (categórica nominal, no se analiza)",
    "edad": "Numérica continua (registrada en años cumplidos)",
    "numero_hijos": "Numérica discreta",
    "genero": "Categórica nominal (3 categorías)",
    "nivel_educacion": "Categórica ordinal",
    "ciudad": "Categórica nominal",
    "ingresos_mensuales": "Numérica continua",
    "satisfaccion": "Categórica ordinal (escala 1–5)",
}
print("Resumen de la clasificación (para el informe):")
for variable, tipo in clasificacion.items():
    print(f"  {variable:20s} {tipo}")