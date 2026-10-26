# Publica o actualiza el tablero en shinyapps.io.
# Nunca guardes token ni secret de shinyapps.io en este archivo.
# Antes de ejecutarlo, copia EN TU CONSOLA el comando setAccountInfo()
# que aparece en https://www.shinyapps.io/admin/#/tokens

if (!requireNamespace("rsconnect", quietly = TRUE)) {
  stop("Instala rsconnect: install.packages('rsconnect')")
}

ruta_mac <- "/Users/julioreyes/Desktop/IndicesDesarrollo"
ruta <- if (file.exists(file.path(ruta_mac, "app.R"))) ruta_mac else getwd()
ruta <- normalizePath(ruta, winslash = "/", mustWork = TRUE)
if (!file.exists(file.path(ruta, "app.R"))) {
  stop("Abre el proyecto IndicesDesarrollo en RStudio o coloca app.R en la ruta indicada.")
}

# Se revisa que los CSV incluidos sean exactamente los requeridos.
archivos_app <- c(
  "app.R",
  "www/styles.css",
  "data/human-development-index.csv",
  "data/inequality-adjusted-human-development-index.csv",
  "data/augmented-human-development-index.csv",
  "data/nombres_es.csv"
)
faltan <- archivos_app[!file.exists(file.path(ruta, archivos_app))]
if (length(faltan)) stop("Archivos faltantes: ", paste(faltan, collapse = ", "))

cuentas <- rsconnect::accounts(server = "shinyapps.io")
if (!nrow(cuentas)) {
  stop(paste(
    "No se ha vinculado una cuenta shinyapps.io.",
    "Entra a https://www.shinyapps.io/admin/#/tokens",
    "elige Add Token, copia el comando setAccountInfo()",
    "a tu consola privada de RStudio y vuelve a ejecutar el script."
  ))
}

# Si se han vinculado varias cuentas, se permite elegir la cuenta mediante el IDE.
cuenta <- if (nrow(cuentas) == 1L) cuentas$name[[1]] else {
  if (!interactive()) stop("Hay varias cuentas. Ejecuta interactivo desde RStudio.")
  seleccionar <- utils::menu(cuentas$name, title = "Elige la cuenta para publicar")
  if (seleccionar == 0L) stop("Publicación cancelada")
  cuentas$name[[seleccionar]]
}

message("Publicando desde: ", ruta)
message("Cuenta: ", cuenta)
message("La visibilidad inicial será PÚBLICA. Cualquier persona con la URL podrá consultarla.")

rsconnect::deployApp(
  appDir = ruta,
  appFiles = archivos_app,
  appName = "desarrollo-humano-mexico",
  appTitle = "Indicadores de desarrollo humano | Comparación internacional",
  account = cuenta,
  server = "shinyapps.io",
  appVisibility = "public",
  launch.browser = TRUE,
  logLevel = "normal"
)

message("Si la publicación termina correctamente, comparte la URL mostrada por shinyapps.io.")
