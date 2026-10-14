# muestreo.R — Parte B: población vs. muestra (RetailAndina).
#
# La población es la base completa de fidelización: data/clientes_400.csv (N = 400).
# La pregunta de negocio: ¿cuál es el ingreso mensual promedio de los clientes?
# Se estima con tres diseños de muestreo y se compara cada estimación con el
# parámetro real, que aquí sí se conoce porque la población es pequeña y visible.
#
# Uso (desde la raíz del repositorio):  Rscript scripts/muestreo.R

%load_ext rpy2.ipython #esto permite ejecutar R dentro de collab usando la cabecera %%R en una celda

%%R

poblacion <- read.csv("data/clientes_400.csv")

reporte <- function(nombre, muestra, parametro) {
  # Imprime n, media estimada y composición por ciudad de una muestra.
  # La composición por ciudad es la pista que delata un sesgo de selección.
  if (is.null(muestra)) {
    cat(sprintf("[%s] pendiente de completar (TODO)\n", nombre))
    return(invisible(NULL))
  }
  media <- mean(muestra$ingresos_mensuales)
  cat(sprintf("[%s] n=%d  media=%.2f USD  (parámetro %.2f, diferencia %+.2f)\n",
              nombre, nrow(muestra), media, parametro, media - parametro))
  cat("    composición por ciudad: ")
  print(table(muestra$ciudad))
}

# ---------------------------------------------------------------------------
# 1. La población y su parámetro (N = 400)
# ---------------------------------------------------------------------------
# La base de fidelización completa es la población: 400 clientes. El parámetro
# es el ingreso mensual promedio real (solo calculable porque la población es
# pequeña y accesible: sirve de espejo para juzgar las muestras).
cat(sprintf("Población: %d clientes × %d columnas\n", nrow(poblacion), ncol(poblacion)))
parametro <- mean(poblacion$ingresos_mensuales)
cat(sprintf("Parámetro poblacional — ingreso medio: %.2f USD\n", parametro))
cat("Ciudades en la población: "); print(table(poblacion$ciudad))

# ---------------------------------------------------------------------------
# 2. Muestra por conveniencia: "los primeros que llegaron"
# ---------------------------------------------------------------------------
# TODO 1: toma como muestra las primeras 20 filas de la población.
#         Pista: head(poblacion, 20) — igual que la demo de clase.
#         Después de correrlo, mira la composición por ciudad que imprime el
#         reporte: ¿es un corte al azar? ¿alguna ciudad falta por completo?
muestra_conv <- head(poblacion, 20)

# ---------------------------------------------------------------------------
# 3. Muestra aleatoria simple: el sorteo de 20
# ---------------------------------------------------------------------------
# TODO 2: sortea 20 clientes con la misma probabilidad para todos (20/400 = 5 %).
#         Pista: poblacion[sample(nrow(poblacion), 20), ] con set.seed(1)
#         delante para que sea reproducible (sin set.seed cambia cada vez).
# TODO 3: repite el sorteo con las semillas 2 a 5 y anota las 5 medias en el
#         informe: la variabilidad de la estimación es parte de la lección.
#         Pista: for (semilla in 1:5) { set.seed(semilla); ... }
set.seed(1) #semilla para numeros randomicos
muestra_aas <- poblacion[sample(nrow(poblacion), 20), ]

# ---------------------------------------------------------------------------
# 4. Muestra estratificada: 5 % dentro de cada ciudad
# ---------------------------------------------------------------------------
# TODO 4: muestrea dentro de cada ciudad (el estrato), con afijación
#         proporcional: 5 % de cada una → 10 de Quito, 6 de Guayaquil y 4 de
#         Cuenca (20 en total).
#         Pista: library(dplyr); poblacion |> group_by(ciudad) |> slice_sample(prop = 0.05)
#         ¿Qué garantiza este diseño que el sorteo simple no garantiza?
library(dplyr)
set.seed(1)
muestra_est <- poblacion |> group_by(ciudad) |> slice_sample(prop = 0.05) # |> es como decir lo que tengo en la parte izq actua como un parametro de lo que esta a la derecha

# ---------------------------------------------------------------------------
# 5. Comparación final
# ---------------------------------------------------------------------------
reporte("Conveniencia", muestra_conv, parametro)
reporte("Aleatorio simple", muestra_aas, parametro)
reporte("Estratificado", muestra_est, parametro)

if (!is.null(muestra_conv) && !is.null(muestra_aas) && !is.null(muestra_est)) {
  resumen <- data.frame(
    diseno = c("Conveniencia (head)", "Aleatorio simple (sample)", "Estratificado (slice_sample)"),
    n = c(nrow(muestra_conv), nrow(muestra_aas), nrow(muestra_est)),
    media_estimada = round(c(mean(muestra_conv$ingresos_mensuales),
                             mean(muestra_aas$ingresos_mensuales),
                             mean(muestra_est$ingresos_mensuales)), 2)
  )
  cat(sprintf("Parámetro poblacional: %.2f USD\n", parametro))
  print(resumen, row.names = FALSE)
  cat("Con estas salidas responde en informe.md las preguntas P2 a P5:\n")
  cat("  P2: ¿cuál diseño quedó más cerca del parámetro y por qué un solo\n")
  cat("      número no basta para declarar un ganador?\n")
  cat("  P3: ¿qué defecto tiene la muestra por conveniencia y cómo lo delata\n")
  cat("      su composición por ciudad? ¿Se corrige con más filas?\n")
  cat("  P4: ¿qué implica la variabilidad entre semillas para una decisión\n")
  cat("      tomada con un solo estudio?\n")
  cat("  P5: ¿cuándo usarías cada diseño? (piloto · subgrupos · conclusión)\n")
} else {
  cat("Completa los TODO 1 a 4 para ver la tabla comparativa.\n")
}