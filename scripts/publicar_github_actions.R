# Despliegue desde GitHub Actions. No escribas tokens en los archivos del repositorio.
requeridas <- c('SHINYAPPS_ACCOUNT', 'SHINYAPPS_TOKEN', 'SHINYAPPS_SECRET')
faltantes <- requeridas[!nzchar(Sys.getenv(requeridas, unset = ''))]
if (length(faltantes)) {
  stop('Faltan secretos de GitHub Actions: ', paste(faltantes, collapse = ', '))
}

if (!requireNamespace('rsconnect', quietly = TRUE)) {
  stop('Falta rsconnect; instala el paquete antes de ejecutar.')
}

archivos <- c(
  'app.R',
  'www/styles.css',
  'data/human-development-index.csv',
  'data/inequality-adjusted-human-development-index.csv',
  'data/augmented-human-development-index.csv',
  'data/nombres_es.csv'
)
faltan <- archivos[!file.exists(archivos)]
if (length(faltan)) stop('Faltan archivos de la aplicación: ', paste(faltan, collapse = ', '))

visibilidad <- Sys.getenv('SHINYAPPS_VISIBILITY', unset = 'public')
if (!nzchar(visibilidad)) visibilidad <- 'public'
if (!visibilidad %in% c('public', 'private')) {
  stop('SHINYAPPS_VISIBILITY debe ser public o private.')
}

cuenta <- Sys.getenv('SHINYAPPS_ACCOUNT')
rsconnect::setAccountInfo(
  name = cuenta,
  token = Sys.getenv('SHINYAPPS_TOKEN'),
  secret = Sys.getenv('SHINYAPPS_SECRET')
)

message('Publicando indicadores de desarrollo humano en shinyapps.io')
message('Cuenta: ', cuenta, ' | visibilidad: ', visibilidad)

rsconnect::deployApp(
  appDir = '.',
  appFiles = archivos,
  appName = 'desarrollo-humano-mexico',
  appTitle = 'Indicadores de desarrollo humano | Comparación internacional',
  account = cuenta,
  server = 'shinyapps.io',
  appVisibility = visibilidad,
  forceUpdate = TRUE,
  launch.browser = FALSE,
  logLevel = 'normal'
)

message('Despliegue finalizado; revisa el enlace desde shinyapps.io.')
