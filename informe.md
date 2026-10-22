# Informe — Clasificación de variables y población vs. muestra

**Para:** Gerencia de RetailAndina S.A. · **De:** Equipo de Business Intelligence
**Fecha:** 21/10/2026 · **Asunto:** Base de fidelización: tipos de variables y estimación por muestreo

---

## Resumen ejecutivo

Clasificamos las 7 variables de la base de fidelización: 3 son numéricas (edad, número de hijos, ingresos) y 4 son categóricas, de las cuales 2 son ordinales (nivel de educación y satisfacción). Después estimamos el ingreso mensual promedio de los clientes con muestras de 20 tomadas de tres formas distintas, y comparamos cada resultado con el valor real de la base completa: **1330.72 USD**. La muestra por conveniencia (las primeras 20 filas) solo tomó clientes de Quito, y el sorteo aleatorio dio una cifra distinta en cada repetición (entre 1235 y 1491.50 USD). Antes de decidir con una muestra, la gerencia debe exigir que esté bien diseñada (por sorteo y, si importan las ciudades, estratificada) y que se reporte con su margen de error. Que la muestra tenga muchas filas no basta.

## Parte A — Clasificación de las variables

La verificación se hizo en Python (`dtypes`, `unique()`, `CategoricalDtype`) y en R (`str()`, `unique()`, `factor(..., ordered = TRUE)`), con los mismos resultados.

| Variable | Tipo | Justificación (criterio) | Verificación en código |
|---|---|---|---|
| `cliente_id` | Identificador (categórica nominal, no se analiza) | Es una etiqueta única por cliente: no tiene sentido sumarla, promediarla ni ordenarla. Solo sirve para distinguir filas. | `object` / `chr`; 12 valores únicos en 12 filas (uno por cliente). |
| `edad` | Numérica continua (registrada como entera) | Es tiempo vivido: "34 años y medio" tiene sentido, así que la variable es continua. El archivo la guarda en años cumplidos, por eso se ve como entera, pero esa es una decisión del registro, no de la variable. Se puede promediar. | `int64` / `int`; 12 valores únicos (22 a 48). |
| `numero_hijos` | Numérica discreta | Es un conteo: "medio hijo" no tiene sentido. Solo toma valores enteros, aunque sí se puede promediar. | `int64` / `int`; 5 valores únicos (0, 1, 2, 3, 4). |
| `genero` | Categórica nominal | Sus categorías no tienen orden entre sí. Tiene 3 categorías, por lo que **no es binaria**. | `object` / `chr`; 3 valores únicos: Femenino, Masculino, Otro. |
| `nivel_educacion` | Categórica ordinal | Hay un orden natural (Primaria < Secundaria < Universidad < Posgrado), pero la distancia entre niveles no es medible. | `object` / `chr`; 4 valores únicos. Orden declarado con `CategoricalDtype(ordered=True)` / `factor(ordered = TRUE)`: `min` = Primaria y `max` = Posgrado. |
| `ciudad` | Categórica nominal | Quito, Guayaquil y Cuenca no tienen un orden entre sí. | `object` / `chr`; 3 valores únicos. |
| `ingresos_mensuales` | Numérica continua | Es dinero: 1450.50 USD tiene sentido, así que la mitad de un valor existe. Los enteros del archivo son redondeo del registro. | `int64` / `int`; 12 valores únicos (760 a 2450). |
| `satisfaccion` | Categórica ordinal (escala 1–5) | Las respuestas tienen orden, pero no son cantidades: un 4 no es el doble de satisfecho que un 2 y un 3.5 no existe en la escala. | `int64` / `int` (el lenguaje la lee como número); 4 valores únicos (2, 3, 4, 5). Orden declarado con niveles 1 a 5: `min` = 2. |

**P1.** ¿Qué te dijo el dtype de `satisfaccion` y por qué no basta para clasificarla? ¿Qué pasa si una ordinal queda como texto sin declarar el orden?

El dtype de `satisfaccion` fue `int64` en Python e `int` en R: el lenguaje la trató como un número entero, igual que a `edad` o `ingresos_mensuales`. Eso no basta para clasificarla, porque el dtype solo describe cómo vienen escritos los datos, no qué miden. Las respuestas 2, 3, 4 y 5 son posiciones en una escala, no cantidades, así que calcular su media o decir que un 4 "vale el doble" que un 2 sería un análisis inválido. Por eso la declaramos como categoría ordenada con niveles 1 a 5. El nivel 1 queda en la escala aunque nadie lo haya marcado, y la verificación devolvió `min` = 2.

Si una ordinal queda como texto sin declarar el orden, el lenguaje la ordena alfabéticamente. En nuestra ejecución el orden alfabético de `nivel_educacion` fue Posgrado, Primaria, Secundaria, Universidad, que no tiene sentido. Además, al declarar el orden con un nivel mal escrito ("Postgrado" con t), los 2 clientes con Posgrado (C003 y C010) se convirtieron en faltantes: `isna().sum()` en Python y `sum(is.na(...))` en R devolvieron **2**. R no dio ningún aviso; Python solo mostró un *warning* de versión. La pérdida de datos es silenciosa, así que siempre hay que contar los faltantes después de declarar los niveles.

## Parte B — Población vs. muestra

### La población y su parámetro

| Concepto | Valor |
|---|---|
| Población (N) | 400 clientes (Quito 200 · Guayaquil 120 · Cuenca 80) |
| Variable de interés | `ingresos_mensuales` (ingreso mensual en USD) |
| Parámetro poblacional (media) | **1330.72 USD** |

*¿Por qué se muestrea si aquí el parámetro existe y se calculó?*

En este laboratorio la población es pequeña y está completa, así que el parámetro se puede calcular. Lo usamos como espejo para juzgar qué tan bien estima cada diseño. En la práctica, recorrer a todos los clientes suele ser caro o lento (por ejemplo, una encuesta), o la población cambia todo el tiempo, y por eso se trabaja con muestras. Este ejercicio muestra qué diseño de muestra confiar cuando no se tiene el valor real para comparar.

### Los tres diseños

Python y R usan generadores de números aleatorios distintos, así que con la misma semilla sortean clientes diferentes. Por eso se reportan ambos resultados (R entre paréntesis).

| Diseño | n | Media estimada | Composición por ciudad | Diferencia vs. parámetro |
|---|---|---|---|---|
| Conveniencia (`head`) | 20 | 1348.50 USD (R: 1348.50) | Quito 20 · Guayaquil 0 · Cuenca 0 | +17.78 (R: +17.78) |
| Aleatorio simple (`sample`, semilla 1) | 20 | 1336.00 USD (R: 1318.00) | Quito 8 · Cuenca 8 · Guayaquil 4 (R: Quito 8 · Guayaquil 7 · Cuenca 5) | +5.28 (R: −12.72) |
| Estratificado (`groupby` + 5 %) | 20 | 1287.50 USD (R: 1226.00) | Quito 10 · Guayaquil 6 · Cuenca 4 (igual en R) | −43.22 (R: −104.72) |

*Medias de 5 sorteos distintos del aleatorio simple (semillas 1 a 5):*

| Semilla | 1 | 2 | 3 | 4 | 5 |
|---|---|---|---|---|---|
| Media (Python) | 1336.00 | 1405.00 | 1235.00 | 1491.50 | 1288.00 |
| Media (R) | 1318.00 | 1287.50 | 1233.00 | 1385.50 | 1283.00 |

**P2.** ¿Cuánto vale el parámetro poblacional y cuánto estimó cada diseño? ¿Cuál quedó más cerca y por qué eso **no** alcanza para declarar un ganador?

El parámetro es 1330.72 USD. En Python, la conveniencia estimó 1348.50 (+17.78), el aleatorio simple 1336.00 (+5.28) y el estratificado 1287.50 (−43.22). El más cercano fue el aleatorio simple con la semilla 1. Eso no alcanza para declarar un ganador por dos razones. Primero, es un solo sorteo: con las semillas 2 a 5 el mismo diseño dio 1405.00, 1235.00, 1491.50 y 1288.00, a veces mucho más lejos que el estratificado. Segundo, la muestra por conveniencia quedó más cerca que la estratificada aunque sus 20 clientes son todos de Quito; quedó cerca por coincidencia, no porque represente a la base. Un diseño se juzga por cómo se comporta en muchas repeticiones (si falla siempre hacia el mismo lado y cuánto varía), no por una sola cifra.

**P3.** La muestra por conveniencia también tiene 20 filas. ¿Qué defecto tiene y cómo lo delatas en la composición por ciudad? ¿Se corrige tomando más filas?

Su defecto es el **sesgo de selección**. La composición por ciudad salió 20 de 20 de Quito, sin un solo cliente de Guayaquil ni de Cuenca, aunque esas ciudades son 200 de los 400 clientes (50 % de la población). El archivo está ordenado por ciudad, así que `head(20)` no es un corte al azar: toma "los primeros que llegaron". Esa muestra estima el ingreso de los clientes de Quito, no el de toda la base. No se corrige tomando más filas: las primeras 200 filas son todas de Quito, así que con `head(50)` o `head(100)` solo se agregan más clientes de Quito y el error se mantiene. El problema es la forma de elegir, no el tamaño.

**P4.** El sorteo aleatorio dio un número distinto en cada semilla. ¿Qué implica esa variabilidad para una empresa que va a decidir con un solo estudio?

En Python las cinco medias fueron de 1235.00 a 1491.50 USD (diferencias de −95.72 a +160.78), y en R de 1233.00 a 1385.50 USD. Es el mismo diseño y el mismo tamaño; solo cambió el azar del sorteo. Esa es la **variabilidad muestral**: no es un error sistemático como el sesgo, porque unas veces la estimación queda por encima del parámetro y otras por debajo. Para una empresa que decide con un solo estudio, eso significa que la cifra obtenida puede ser una de las "afortunadas" o de las "desafortunadas", y no lo sabrá. Por eso un resultado muestral debe venir con su margen de error (o intervalo de confianza), y si la decisión es importante conviene aumentar n, que reduce la variabilidad, o estratificar.

**P5.** ¿Cuándo usarías cada diseño en la práctica? Relaciona cada uno con un uso real (piloto, subgrupos que deben aparecer, conclusión sobre toda la población).

- **Conveniencia:** para un **piloto**. Sirve para probar un cuestionario o revisar que el flujo de datos funcione con los primeros clientes disponibles, sin sacar conclusiones sobre la base.
- **Aleatorio simple:** para una **conclusión sobre toda la población** cuando hay un listado completo de clientes y no interesa reportar por grupos. Cada cliente tiene la misma probabilidad de salir, así que no hay sesgo de selección.
- **Estratificado:** cuando hay **subgrupos que deben aparecer** sí o sí, por ejemplo para reportar o comparar ingresos por ciudad. Garantiza la proporción de cada ciudad (10 de Quito, 6 de Guayaquil y 4 de Cuenca), algo que el sorteo simple no asegura: en la semilla 1 de Python salieron 8 de Cuenca, el doble de lo que le corresponde.

## Conclusiones

1. **El tipo que asigna el lenguaje es una pista, no la clasificación.** `satisfaccion` llegó como `int64`/`int` y es ordinal, y `edad` llegó como entero y es continua. Al declarar el orden de las ordinales comprobamos que un nivel mal escrito borra datos sin dar error (2 clientes con Posgrado perdidos), así que hay que verificar los faltantes después de cada conversión.
2. **El diseño decide la representatividad; el tamaño no.** Las tres muestras tenían 20 clientes, pero la de conveniencia tomó 20 de 20 de Quito y dejó fuera al 50 % de la base. Tomar más filas del inicio del archivo no corrige ese sesgo, mientras que el sorteo y el estratificado sí dan a todas las ciudades la oportunidad de aparecer.
3. **Una sola muestra no basta para elegir un diseño ni para decidir.** El aleatorio simple quedó a +5.28 USD del parámetro con la semilla 1, pero entre semillas varió de 1235.00 a 1491.50 USD. Recomendamos a la gerencia aceptar estimaciones solo de muestras aleatorias (estratificadas por ciudad si los resultados por ciudad importan) y que siempre vengan con su margen de error. Estas conclusiones aplican a esta base de 400 clientes y a muestras de 20.
