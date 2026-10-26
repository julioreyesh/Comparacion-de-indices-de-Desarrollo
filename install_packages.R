# Ejecutar solo la primera vez desde el directorio del dashboard:
# source("/Users/julioreyes/Desktop/IndicesDesarrollo/install_packages.R")
paquetes <- c("shiny", "bslib", "dplyr", "plotly", "DT")
faltantes <- setdiff(paquetes, rownames(installed.packages()))
if (length(faltantes)) {
  install.packages(faltantes, repos = "https://cloud.r-project.org")
}
cat("Paquetes necesarios instalados o ya disponibles.\n")
