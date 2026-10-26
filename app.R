# Panel de indicadores de desarrollo humano | Gobierno de México (paleta de referencia)
# Versión preparada para uso local y publicación en shinyapps.io.
# Ejecutar desde RStudio: shiny::runApp("/Users/julioreyes/Desktop/IndicesDesarrollo")

paquetes <- c("shiny", "bslib", "dplyr", "plotly", "DT")
faltantes <- paquetes[!vapply(paquetes, requireNamespace, quietly = TRUE, FUN.VALUE = logical(1))]
if (length(faltantes)) {
  stop("Faltan paquetes: ", paste(faltantes, collapse = ", "),
       ". Ejecuta source('install_packages.R') y vuelve a iniciar.")
}

library(shiny)
library(dplyr)
library(plotly)
library(DT)

# ------------ Datos originales, sin imputación ------------
base_dir <- normalizePath(getwd(), winslash = "/", mustWork = TRUE)
archivos <- c(
  "IDH" = "human-development-index.csv",
  "IDH-D" = "inequality-adjusted-human-development-index.csv",
  "AHDI" = "augmented-human-development-index.csv"
)
variables <- c(
  "IDH" = "Human Development Index",
  "IDH-D" = "Inequality-adjusted Human Development Index",
  "AHDI" = "Augmented Human Development Index (AHDI)"
)

leer_indice <- function(sigla) {
  archivo <- file.path(base_dir, "data", archivos[[sigla]])
  if (!file.exists(archivo)) stop("No se encuentra: ", archivo)
  origen <- utils::read.csv(archivo, check.names = FALSE, stringsAsFactors = FALSE,
                            fileEncoding = "UTF-8-BOM")
  campos <- c("Entity", "Code", "Year", "World region according to OWID", variables[[sigla]])
  if (!all(campos %in% names(origen))) {
    stop("El CSV no tiene las columnas esperadas: ", basename(archivo))
  }
  data.frame(
    pais_original = as.character(origen[["Entity"]]),
    codigo = as.character(origen[["Code"]]),
    anio = suppressWarnings(as.integer(origen[["Year"]])),
    region_original = as.character(origen[["World region according to OWID"]]),
    valor = suppressWarnings(as.numeric(origen[[variables[[sigla]]]])),
    indicador = sigla,
    stringsAsFactors = FALSE
  )
}

datos_raw <- dplyr::bind_rows(lapply(names(archivos), leer_indice))
nombres <- utils::read.csv(file.path(base_dir, "data", "nombres_es.csv"),
                           fileEncoding = "UTF-8-BOM", stringsAsFactors = FALSE)
regiones <- c("Africa" = "África", "Asia" = "Asia", "Europe" = "Europa",
             "North America" = "América del Norte", "South America" = "América del Sur",
             "Oceania" = "Oceanía")
colores_regiones <- c("África" = "#9B2247", "Asia" = "#1E5B4F", "Europa" = "#A57F2C",
                     "América del Norte" = "#611232", "América del Sur" = "#002F2A",
                     "Oceanía" = "#98989A")
colores_lineas <- c("#611232", "#1E5B4F", "#A57F2C", "#9B2247", "#002F2A",
                    "#777777", "#B07C5B", "#566873")

datos <- datos_raw %>%
  filter(grepl("^[A-Z]{3}$", codigo), !is.na(anio), is.finite(valor),
         !is.na(region_original), region_original %in% names(regiones)) %>%
  mutate(region = unname(regiones[region_original]),
         pais = nombres$Pais[match(codigo, nombres$Code)],
         pais = ifelse(is.na(pais) | !nzchar(pais), pais_original, pais)) %>%
  distinct(indicador, codigo, anio, .keep_all = TRUE) %>%
  arrange(indicador, anio, pais)

nombres_indicador <- c("IDH" = "Índice de Desarrollo Humano",
                       "IDH-D" = "IDH ajustado por desigualdad",
                       "AHDI" = "Índice de Desarrollo Humano Ampliado")
formatter <- function(x, decimales = 3L) {
  ifelse(is.na(x) | !is.finite(x), "Sin dato",
         formatC(x, format = "f", digits = decimales, decimal.mark = "."))
}

tema_plot <- function(p, l = 20, r = 20, t = 18, b = 40) {
  p %>% layout(
    font = list(family = "Arial, Helvetica, sans-serif", color = "#393939", size = 12),
    paper_bgcolor = "rgba(0,0,0,0)", plot_bgcolor = "rgba(0,0,0,0)",
    margin = list(l = l, r = r, t = t, b = b),
    hoverlabel = list(bgcolor = "#FFFFFF", font = list(color = "#161A1D"))
  ) %>% config(displaylogo = FALSE, responsive = TRUE)
}

# Filtra por el valor de México en el mismo indicador/año (no entre indicadores).
ordenados_bajo_mexico <- function(tabla) {
  mx <- tabla$valor[tabla$codigo == "MEX"]
  if (!length(mx)) return(tabla[0, , drop = FALSE])
  tabla %>% filter(codigo != "MEX", valor < mx[1]) %>% arrange(desc(valor), pais)
}

seleccion_30 <- function(sigla, anio) {
  sub <- datos %>% filter(indicador == sigla, .data$anio == anio)
  head(ordenados_bajo_mexico(sub), 30L)
}

indicadores_choices <- c(
  "IDH · Desarrollo humano" = "IDH",
  "IDH-D · Ajustado por desigualdad" = "IDH-D",
  "AHDI · Desarrollo ampliado (hasta 2020)" = "AHDI"
)

kpi <- function(etiqueta, valor, nota = "", cls = "") {
  div(class = paste("kpi", cls),
      div(class = "kpi-label", etiqueta),
      div(class = "kpi-value", valor),
      div(class = "kpi-caption", nota))
}

ui <- fluidPage(
  theme = bslib::bs_theme(version = 5, bg = "#F7F6F3", fg = "#161A1D",
                          primary = "#611232", base_font = "Arial"),
  tags$head(
    tags$meta(name = "viewport", content = "width=device-width, initial-scale=1"),
    tags$meta(name = "description", content = "Tablero interactivo de desarrollo humano: mapas, rankings, series históricas y comparaciones internacionales."),
    tags$link(rel = "stylesheet", type = "text/css", href = "styles.css"),
    tags$title("Observatorio de Desarrollo Humano | Dashboard")
  ),
  div(class = "top-stripe"),
  div(class = "shell",
      div(class = "topbar",
          div(class = "brand-lockup",
              div(class = "brand-mark", "MX"),
              div(class = "brand-text",
                  tags$div(class = "brand-kicker", "ANÁLISIS INTERNACIONAL"),
                  tags$div(class = "brand-name", "Observatorio de Desarrollo Humano"))),
          div(class = "topbar-tag", "Panel interactivo · PNUD / OWID / Prados de la Escosura")
      ),
      div(class = "hero",
          div(class = "hero-eyebrow", "TABLERO DE INDICADORES  /  COMPARACIÓN INTERNACIONAL"),
          tags$h1("Indicadores de desarrollo humano"),
          tags$p("Explora rankings, compara países y analiza la evolución del IDH, IDH-D y AHDI con una referencia explícita a México."),
          div(class = "hero-pills",
              span("3 indicadores"), span("6 regiones"), span("Mapas interactivos"), span("1870–2023 según la serie"))
      ),
      div(class = "toolbar",
          div(class = "toolbar-heading",
              span(class = "toolbar-title", "Parámetros de análisis"),
              span(class = "toolbar-hint", "Los filtros principales se aplican a Panorama, Mapas y Clasificación")),
          fluidRow(
            column(5, selectInput("indicador", "Indicador", choices = indicadores_choices, selected = "IDH")),
            column(3, selectInput("anio", "Año de referencia", choices = 1990:2023, selected = 2023)),
            column(4, selectInput("region", "Región geográfica", choices = c("Todas las regiones", unname(regiones)), selected = "Todas las regiones"))
          ),
          uiOutput("aviso_cobertura")
      ),
      tabsetPanel(id = "vistas", type = "tabs",
        tabPanel("Panorama",
          div(class = "section-heading", h2("Panorama general"), p("Resultados para el indicador, año y región seleccionados.")),
          uiOutput("kpis"),
          fluidRow(
            column(7, div(class = "panel",
                          div(class = "panel-header", h3("Promedio regional"), p("Promedio no ponderado de países con información disponible.")),
                          plotlyOutput("promedio_regional", height = "345px"))),
            column(5, div(class = "panel",
                          div(class = "panel-header", h3("Distribución por región"), p("Número de países con valores reportados.")),
                          plotlyOutput("conteo_regional", height = "345px")))
          ),
          div(class = "info-note", "Para el cálculo regional se excluyen agregados supranacionales. Los promedios se calculan únicamente sobre los países disponibles y no ponderan por población.")
        ),
        tabPanel("Mapas interactivos",
          div(class = "section-heading", h2("Atlas del desarrollo humano"),
              p("Explora mapas coropléticos por país, compara con México y consulta la desigualdad. Pasa el cursor sobre cada territorio y usa el zoom de Plotly.")),
          div(class = "panel filters-panel",
              fluidRow(
                column(7, selectInput("capa_mapa", "Representación del mapa principal",
                    choices = c(
                      "Valor del indicador seleccionado" = "valor",
                      "Diferencia respecto al índice de México" = "distancia",
                      "Selección de 30 países inmediatamente inferiores a México" = "casos"
                    ), selected = "valor")),
                column(5, div(class = "download-slot",
                    downloadButton("descargar_datos_mapa", "Descargar datos del mapa (CSV)", class = "btn-download")))
              ),
              tags$p(class = "map-helper", "El indicador, año y región se seleccionan arriba. Los territorios sin medición aparecen sin color temático. Las selecciones de 30 casos se calculan globalmente antes de filtrar la región."),
              textOutput("resumen_mapa")
          ),
          div(class = "panel map-panel",
              div(class = "panel-header", h3("Mapa mundial del indicador"),
                  p("Mapa interactivo: mueve el cursor para consultar el país, el valor y su relación con México.")),
              plotlyOutput("mapa_principal", height = "540px"),
              uiOutput("ficha_mapa")
          ),
          div(class = "panel map-panel",
              div(class = "panel-header", h3("Pérdida por desigualdad: IDH frente a IDH-D"),
                  p("Pérdida relativa (%) por desigualdad en un mismo país y año (2010–2023); escala fija de 0 a 60 %, independientemente del indicador seleccionado arriba.")),
              plotlyOutput("mapa_desigualdad", height = "500px")
          ),
          div(class = "info-note", "La cartografía colorea territorios mediante códigos geográficos ISO de tres letras; algunos territorios pequeños o con reconocimiento especial pueden no visualizarse. Un país ausente del mapa no necesariamente carece de datos: consulta la tabla de Clasificación. Los dos mapas usan el año común elegido arriba; para ver desigualdad selecciona 2010–2023.")
        ),
        tabPanel("Clasificación",
          div(class = "section-heading", h2("Clasificación de países"), p("Ranking descendente, filtros respecto a México y descarga de la selección.")),
          div(class = "panel filters-panel",
              fluidRow(
                column(5, selectInput("universo", "Universo de comparación", choices = c(
                  "Todos los países disponibles" = "todos",
                  "Países con índice inferior al de México" = "inferior",
                  "Los 30 más cercanos por debajo de México" = "treinta",
                  "Países con índice superior al de México" = "superior"), selected = "treinta")),
                column(4, sliderInput("n_grafico", "Países en la gráfica", min = 10, max = 50, value = 30, step = 5)),
                column(3, div(class = "download-slot", downloadButton("descargar_ranking", "Descargar CSV", class = "btn-download")))
              ),
              textOutput("resumen_clasificacion")
          ),
          div(class = "panel", div(class = "panel-header", h3("Ranking descendente"), p("Los valores mayores aparecen primero; la selección de 30 se hace globalmente antes de filtrar por región.")),
              plotlyOutput("grafico_ranking", height = "690px")),
          div(class = "panel", div(class = "panel-header", h3("Tabla detallada"), p("Ordena por columna, busca países y exporta el subconjunto filtrado.")),
              DTOutput("tabla_ranking"))
        ),
        tabPanel("Comparador",
          div(class = "section-heading", h2("Comparador de países"), p("Contrasta países en el indicador y año elegidos; consulta aparte el efecto de la desigualdad.")),
          div(class = "panel filters-panel",
              selectizeInput("paises_comp", "Países para comparar (hasta 8)",
                             choices = NULL, multiple = TRUE,
                             options = list(maxItems = 8, placeholder = "Selecciona países"))
          ),
          div(class = "panel", div(class = "panel-header", h3("Comparación directa"), p("Valores en el mismo indicador y año. Los países sin datos se excluyen del gráfico.")),
              plotlyOutput("grafico_comparador", height = "380px")),
          div(class = "section-heading sub-heading", h2("Impacto de la desigualdad"), p("Comparación del IDH y del IDH-D para un mismo año; no incluye AHDI.")),
          fluidRow(
            column(6, div(class = "panel", div(class = "panel-header", h3("IDH frente a IDH-D"), p("Cada punto representa un país con ambas mediciones.")),
                          plotlyOutput("grafico_dispersion", height = "390px"))),
            column(6, div(class = "panel", div(class = "panel-header", h3("Pérdida relativa por desigualdad"), p("(IDH − IDH-D) / IDH × 100, sobre países con ambos valores.")),
                          DTOutput("tabla_perdida")))
          ),
          div(class = "info-note", "El IDH-D ajusta las tres dimensiones del IDH por desigualdad. El AHDI es un indicador distinto, incorpora libertades civiles y políticas y no debe confundirse con el IDH-D.")
        ),
        tabPanel("Evolución histórica",
          div(class = "section-heading", h2("Evolución histórica"), p("Series de tiempo originales; el AHDI incluye observaciones en años irregulares.")),
          div(class = "panel filters-panel",
              selectizeInput("paises_hist", "Países para la evolución (hasta 8)", choices = NULL, multiple = TRUE,
                             options = list(maxItems = 8, placeholder = "Selecciona países"))
          ),
          div(class = "panel", div(class = "panel-header", h3("Trayectoria del indicador"), p("Se muestran exclusivamente los años observados en la fuente, sin interpolar datos.")),
              plotlyOutput("grafico_evolucion", height = "495px")),
          uiOutput("nota_evolucion")
        ),
        tabPanel("Selección de 30 casos",
          div(class = "section-heading", h2("Selección para análisis comparativo"), p("Identifica los 30 países inmediatamente inferiores a México y compara las listas del IDH y del IDH-D.")),
          div(class = "panel filters-panel",
              fluidRow(
                column(4, selectInput("anio_casos", "Año común entre IDH e IDH-D", choices = 2010:2023, selected = 2023)),
                column(8, div(class = "helper-inline", "Cada lista se construye de forma independiente con el valor de México del mismo indicador y año. Se respetan los datos faltantes."))
              )
          ),
          uiOutput("kpis_casos"),
          fluidRow(
            column(6, div(class = "panel", div(class = "panel-header", h3("Exclusivos del IDH"), p("Entran entre los primeros 30 por IDH, pero no por IDH-D.")), uiOutput("solo_idh"))),
            column(6, div(class = "panel", div(class = "panel-header", h3("Exclusivos del IDH-D"), p("Entran entre los primeros 30 por IDH-D, pero no por IDH.")), uiOutput("solo_idhd")))
          ),
          div(class = "panel", div(class = "panel-header", h3("Comparación de las dos listas"), p("Las posiciones se cuentan solo entre los países inferiores a México en cada indicador.")),
              DTOutput("tabla_casos")),
          div(class = "info-note", "La ausencia de un país en una lista puede deberse a que su índice es mayor o igual al mexicano, a su posición fuera de los primeros 30 o a falta de datos. No debe interpretarse automáticamente como un cambio en su desarrollo.")
        ),
        tabPanel("Fuentes y método",
          div(class = "section-heading", h2("Fuentes, cobertura y método"), p("Transparencia metodológica y límites de comparabilidad de las tres bases.")),
          div(class = "panel metodo",
              tags$h3("Qué mide cada indicador"),
              tags$p(tags$b("IDH — Índice de Desarrollo Humano"),
                     " (último año: 2023). Es una medida sintética de los logros en tres dimensiones fundamentales del desarrollo humano: una vida larga y saludable, una buena educación y un nivel de vida digno. Los valores mayores indican mayor desarrollo humano."),
              tags$p(tags$b("IDH-D — IDH ajustado por desigualdad"),
                     " (último año: 2023). Resume esas tres dimensiones del desarrollo humano, ajustadas por las desigualdades en su distribución. Los valores mayores indican un desarrollo humano mayor y más igualitario. No es el IDH convencional y no corresponde a una serie intercambiable."),
              tags$p(tags$b("AHDI — Índice de Desarrollo Humano Ampliado"),
                     " (último año: 2020). Es una medida sintética de los logros en cuatro dimensiones: una vida larga y saludable, conocimientos, libertad y un nivel de vida digno. La serie es histórica y contiene observaciones en años no uniformemente espaciados."),
              tags$div(class = "info-note", "Las tres series miden conceptos relacionados pero no idénticos. En particular, AHDI incorpora libertad como dimensión adicional; no es una versión del IDH ajustada por desigualdad. Sus últimos datos disponibles son de 2020, frente a 2023 para IDH e IDH-D."),
              tags$h3("Cobertura de las bases"),
              DTOutput("tabla_cobertura"),
              tags$h3("Criterios de tratamiento"),
              tags$ul(
                tags$li("Solo se incluyen registros de países con código de tres letras y región geográfica asignada por Our World in Data. Se excluyen agregados supranacionales."),
                tags$li("Las clasificaciones usan valores estrictamente menores al de México. Los empates no entran en la selección; las listas se ordenan de forma descendente."),
                tags$li("Los países sin medición no se consideran iguales a cero. Nunca se imputan datos faltantes ni se mezclan años diferentes."),
                tags$li("El indicador ampliado (AHDI) no tiene datos de 2023. Sus valores no son intercambiables con el IDH o el IDH-D, aunque todos estén representados en escalas próximas a 0–1."),
                tags$li("La categoría ‘América del Norte’ proviene de OWID e incluye Centroamérica y el Caribe. Los promedios regionales no ponderan por población.")
              ),
              tags$h3("Referencias bibliográficas y datos"),
              tags$p(tags$b("IDH. "), "PNUD, Informe sobre Desarrollo Humano (2025), con procesamiento menor de Our World in Data. ",
                  tags$em("Human Development Index – UNDP [dataset]"), ". Fuente original: PNUD, Human Development Report. Consultado el 26 de octubre de 2026. ",
                  tags$a("Datos archivados el 12 de agosto de 2026", href = "https://archive.ourworldindata.org/20260812-103058/grapher/human-development-index.html", target = "_blank", rel = "noopener noreferrer"), "."),
              tags$p(tags$b("IDH-D. "), "PNUD, Informe sobre Desarrollo Humano (2025), con procesamiento menor de Our World in Data. ",
                  tags$em("Inequality-adjusted Human Development Index – UNDP [dataset]"), ". Fuente original: PNUD, Human Development Report. Consultado el 26 de octubre de 2026. ",
                  tags$a("Datos archivados el 26 de agosto de 2026", href = "https://archive.ourworldindata.org/20260826-181749/grapher/inequality-adjusted-human-development-index.html", target = "_blank", rel = "noopener noreferrer"), "."),
              tags$p(tags$b("AHDI. "), "Prados de la Escosura, Leandro (2022). ",
                  tags$em("Human Development and the Path to Freedom: 1870 to the Present"),
                  ". Cambridge: Cambridge University Press. ",
                  tags$a("https://doi.org/10.1017/9781108769655", href = "https://doi.org/10.1017/9781108769655", target = "_blank", rel = "noopener noreferrer"),
                  ". Datos utilizados: archivo AHDI suministrado junto con el proyecto."),
              tags$p("Los CSV y los metadatos de origen que se utilizaron en el tablero están incluidos en la carpeta data del proyecto."),
              tags$div(class = "method-disclaimer", "Diseño cromático basado en la Guía de Identidad Gráfica del Gobierno de México 2024–2030 (p. 17). Este tablero no incorpora ni suplanta el imagotipo oficial y no presupone su aprobación institucional.")
          )
        )
      ),
      div(class = "footer",
          span("OBSERVATORIO DE DESARROLLO HUMANO"),
          span("Fuentes: PNUD / Our World in Data / Prados de la Escosura · Datos adjuntos"))
  )
)


# Cartografía Plotly basada en códigos ISO de tres letras.
# Se evita un paquete geográfico adicional para hacer más sencillo el despliegue web.
paleta_mapa <- list(list(0, "#E6D194"), list(0.35, "#A57F2C"),
                    list(0.70, "#9B2247"), list(1, "#611232"))
paleta_brecha <- list(list(0, "#9B2247"), list(0.5, "#F2EFE9"), list(1, "#1E5B4F"))
paleta_treinta <- list(list(0, "#D4D0CB"), list(0.499, "#D4D0CB"),
                       list(0.5, "#9B2247"), list(1, "#9B2247"))
mapa_geo <- list(
  scope = "world",
  projection = list(type = "natural earth"),
  showframe = FALSE, showcoastlines = FALSE,
  showland = TRUE, landcolor = "#F1EEE9",
  showcountries = TRUE, countrycolor = "#FFFFFF", countrywidth = 0.65,
  bgcolor = "rgba(0,0,0,0)"
)

construir_coro <- function(d, fuente, minimo, maximo, escala, titulo_color) {
  p <- plotly::plot_ly(data = d, source = fuente) %>%
    add_trace(type = "choropleth", locations = ~codigo, locationmode = "ISO-3",
              z = ~map_valor, text = ~map_texto, key = ~codigo, hoverinfo = "text",
              colorscale = escala, zmin = minimo, zmax = maximo,
              colorbar = list(title = list(text = titulo_color), thickness = 13,
                              tickfont = list(size = 10), len = 0.75, x = 0.99),
              marker = list(line = list(color = "#FFFFFF", width = 0.65))) %>%
    layout(geo = mapa_geo, showlegend = FALSE,
           margin = list(l = 0, r = 0, t = 12, b = 5),
           paper_bgcolor = "rgba(0,0,0,0)",
           font = list(family = "Arial, Helvetica, sans-serif", color = "#393939")) %>%
    config(displaylogo = FALSE, responsive = TRUE,
           modeBarButtonsToRemove = c("select2d", "lasso2d"))
  plotly::event_register(p, "plotly_click")
}

server <- function(input, output, session) {

  observeEvent(input$indicador, {
    req(input$indicador)
    disponibles <- sort(unique(datos$anio[datos$indicador == input$indicador]))
    actual <- isolate(input$anio)
    elegido <- if (!is.null(actual) && actual %in% disponibles) actual else max(disponibles)
    updateSelectInput(session, "anio", choices = disponibles, selected = elegido)
  }, ignoreInit = FALSE)

  observe({
    opciones <- sort(unique(datos$pais))
    preferidos <- c("México", "Colombia", "Brasil", "Vietnam", "Cuba")
    elegidos <- preferidos[preferidos %in% opciones]
    updateSelectizeInput(session, "paises_comp", choices = opciones, selected = elegidos, server = TRUE)
    updateSelectizeInput(session, "paises_hist", choices = opciones,
                         selected = elegidos[seq_len(min(length(elegidos), 4L))], server = TRUE)
  })

  filtro_indice <- reactive({
    req(input$indicador, input$anio)
    anio_elegido <- as.integer(input$anio)
    validate(need(anio_elegido %in% datos$anio[datos$indicador == input$indicador],
                  "Selecciona un año disponible para el indicador."))
    datos %>% filter(indicador == input$indicador, anio == anio_elegido)
  })

  mex_actual <- reactive({
    x <- filtro_indice()$valor[filtro_indice()$codigo == "MEX"]
    if (length(x)) x[1] else NA_real_
  })

  filtro_region <- reactive({
    d <- filtro_indice()
    if (!identical(input$region, "Todas las regiones")) d <- d %>% filter(region == input$region)
    d
  })

  output$aviso_cobertura <- renderUI({
    req(input$indicador, input$anio)
    if (input$indicador == "AHDI") {
      div(class = "coverage-note", span(class = "note-dot"),
          "AHDI: la última observación disponible es 2020 y las series históricas no son uniformemente anuales. No se presenta como dato de 2023.")
    } else {
      div(class = "coverage-note", span(class = "note-dot"),
          "Los países y regiones con valores faltantes se omiten; los indicadores se comparan solo dentro del mismo año.")
    }
  })

  # Se usan exactamente los filtros globales de indicador, año y región.
  base_mapa <- reactive({
    d <- filtro_region()
    mx <- mex_actual()
    capa <- input$capa_mapa
    req(capa)
    validate(need(nrow(d) > 0, "No hay datos geográficos con estos filtros."))
    if (identical(capa, "valor")) {
      d$map_valor <- d$valor
    } else if (identical(capa, "distancia")) {
      validate(need(is.finite(mx), "No existe valor de México para este indicador y año."))
      d$map_valor <- d$valor - mx
    } else {
      treinta <- ordenados_bajo_mexico(filtro_indice()) %>% head(30L)
      d$map_valor <- ifelse(d$codigo %in% treinta$codigo, 1, 0)
    }
    d$map_texto <- paste0("<b>", d$pais, "</b><br>Región: ", d$region,
                          "<br>", input$indicador, " (", input$anio, "): ", formatter(d$valor),
                          if (is.finite(mx)) paste0("<br>México: ", formatter(mx),
                                                    "<br>Diferencia: ", sprintf("%+.3f", d$valor - mx)) else "",
                          if (identical(capa, "casos"))
                            ifelse(d$map_valor == 1, "<br><b>Entre los 30 casos seleccionados</b>",
                                   "<br>Fuera de los 30 casos seleccionados") else "")
    d
  })

  output$resumen_mapa <- renderText({
    d <- base_mapa()
    paste0(nrow(d), " países con dato y región asignada; ",
           input$indicador, " (", input$anio, "). ",
           if (identical(input$capa_mapa, "casos"))
             paste0(sum(d$map_valor == 1), " países visibles del grupo de 30.")
           else if (identical(input$capa_mapa, "distancia"))
             "La diferencia corresponde al valor del país menos el valor mexicano."
           else "Las áreas sin dato no se imputan; las escalas permanecen fijas entre años.")
  })

  output$mapa_principal <- renderPlotly({
    d <- base_mapa()
    capa <- input$capa_mapa
    if (identical(capa, "distancia")) {
      # Escala fija para conservar la comparabilidad entre años y regiones.
      construir_coro(d, "mapa_principal", -0.55, 0.55, paleta_brecha,
                     "Diferencia")
    } else if (identical(capa, "casos")) {
      construir_coro(d, "mapa_principal", 0, 1, paleta_treinta,
                     "Casos 0/1")
    } else {
      construir_coro(d, "mapa_principal", 0, 1, paleta_mapa,
                     input$indicador)
    }
  })

  pares_mapa <- reactive({
    anio_elegido <- suppressWarnings(as.integer(input$anio))
    req(anio_elegido)
    validate(need(anio_elegido >= 2010 && anio_elegido <= 2023,
                  "Para calcular desigualdad selecciona un año entre 2010 y 2023."))
    d_idh <- datos %>% filter(indicador == "IDH", anio == anio_elegido) %>%
      select(codigo, pais, region, idh = valor)
    d_idhd <- datos %>% filter(indicador == "IDH-D", anio == anio_elegido) %>%
      select(codigo, idhd = valor)
    pares <- inner_join(d_idh, d_idhd, by = "codigo") %>%
      filter(idh > 0) %>%
      mutate(map_valor = 100 * (idh - idhd) / idh)
    if (!identical(input$region, "Todas las regiones")) {
      pares <- pares %>% filter(region == input$region)
    }
    validate(need(nrow(pares) > 0, "No hay observaciones emparejadas para esta selección."))
    pares$map_texto <- paste0("<b>", pares$pais, "</b><br>", input$anio,
                              "<br>IDH: ", formatter(pares$idh),
                              "<br>IDH-D: ", formatter(pares$idhd),
                              "<br>Pérdida por desigualdad: ", formatter(pares$map_valor, 1), "%")
    pares
  })

  output$mapa_desigualdad <- renderPlotly({
    d <- pares_mapa()
    # Escala fija 0–60 %; el máximo observado en las bases es < 60 %.
    construir_coro(d, "mapa_desigualdad", 0, 60,
                   list(list(0, "#E6D194"), list(0.5, "#9B2247"), list(1, "#611232")),
                   "Pérdida (%)")
  })

  output$ficha_mapa <- renderUI({
    clic <- plotly::event_data("plotly_click", source = "mapa_principal")
    if (is.null(clic) || is.null(clic$key) || !length(clic$key)) {
      return(div(class = "map-click-prompt",
                 "Selecciona un país en el mapa para ver su ficha y abrirlo en el comparador."))
    }
    codigo_clic <- as.character(clic$key[[1]])
    d <- filtro_indice() %>% filter(codigo == codigo_clic)
    if (!nrow(d)) return(NULL)
    mx <- mex_actual()
    div(class = "map-click-card",
        div(class = "map-click-info",
            tags$strong(d$pais[1]),
            tags$span(paste0("Región: ", d$region[1], " · ", input$indicador, " ",
                             input$anio, ": ", formatter(d$valor[1]),
                             if (is.finite(mx)) paste0(" · Diferencia frente a México: ",
                                                       sprintf("%+.3f", d$valor[1] - mx)) else ""))),
        actionButton("comparar_desde_mapa", "Abrir en comparador",
                     class = "btn-map-compare")
    )
  })

  observeEvent(input$comparar_desde_mapa, {
    clic <- plotly::event_data("plotly_click", source = "mapa_principal")
    req(clic$key)
    seleccionado <- filtro_indice() %>% filter(codigo == as.character(clic$key[[1]]))
    req(nrow(seleccionado) > 0)
    comparar <- unique(c("México", seleccionado$pais[1]))
    updateSelectizeInput(session, "paises_comp", selected = comparar,
                         choices = sort(unique(datos$pais)), server = TRUE)
    updateTabsetPanel(session, "vistas", selected = "Comparador")
  })

  output$descargar_datos_mapa <- downloadHandler(
    filename = function() paste0("mapa_", input$indicador, "_", input$anio, "_", input$capa_mapa, ".csv"),
    content = function(file) {
      d <- base_mapa()
      exportar <- data.frame(Pais = d$pais, Codigo = d$codigo, Region = d$region,
                             Indicador = d$indicador, Anio = d$anio,
                             Valor = d$valor, Valor_de_capa = d$map_valor)
      utils::write.csv(exportar, file, row.names = FALSE, fileEncoding = "UTF-8")
    }
  )

  output$kpis <- renderUI({
    d <- filtro_region()
    mx <- mex_actual()
    bajo <- if (is.finite(mx)) sum(d$codigo != "MEX" & d$valor < mx) else NA_integer_
    medio <- if (nrow(d)) stats::median(d$valor) else NA_real_
    fluidRow(
      column(3, kpi("México · valor de referencia", formatter(mx), paste(input$indicador, input$anio), "kpi-primary")),
      column(3, kpi("Países debajo de México", ifelse(is.na(bajo), "—", as.character(bajo)), "En la región seleccionada")),
      column(3, kpi("Países con datos", as.character(nrow(d)), "Cobertura del filtro")),
      column(3, kpi("Mediana del indicador", formatter(medio), "Países disponibles"))
    )
  })

  output$promedio_regional <- renderPlotly({
    d <- filtro_region() %>% group_by(region) %>% summarise(media = mean(valor), .groups = "drop") %>% arrange(media)
    validate(need(nrow(d) > 0, "No hay datos con estos filtros."))
    d$region_factor <- factor(d$region, levels = d$region)
    p <- plotly::plot_ly(data = d, x = ~media, y = ~region_factor,
                         type = "bar", orientation = "h", color = ~region,
                         colors = colores_regiones,
                         text = ~formatter(media), textposition = "outside",
                         hovertemplate = "%{y}: %{x:.3f}<extra></extra>") %>%
      layout(showlegend = FALSE, xaxis = list(title = "Valor medio", range = c(0, 1.09),
                                              gridcolor = "#EEEAE6", zeroline = FALSE),
             yaxis = list(title = "", automargin = TRUE))
    mx <- mex_actual()
    if (is.finite(mx)) {
      p <- p %>% layout(shapes = list(list(type = "line", x0 = mx, x1 = mx,
                               y0 = 0, y1 = 1, yref = "paper",
                               line = list(color = "#A57F2C", width = 2, dash = "dash"))))
    }
    tema_plot(p, l = 132, r = 24, t = 18, b = 44)
  })

  output$conteo_regional <- renderPlotly({
    d <- filtro_region() %>% count(region, name = "paises") %>% arrange(paises)
    validate(need(nrow(d) > 0, "No hay datos con estos filtros."))
    d$region_factor <- factor(d$region, levels = d$region)
    p <- plotly::plot_ly(data = d, x = ~paises, y = ~region_factor,
                         type = "bar", orientation = "h", color = ~region,
                         colors = colores_regiones,
                         text = ~as.character(paises), textposition = "outside",
                         hovertemplate = "%{y}: %{x} países<extra></extra>") %>%
      layout(showlegend = FALSE, xaxis = list(title = "Número de países", zeroline = FALSE,
                                             gridcolor = "#EEEAE6"),
             yaxis = list(title = "", automargin = TRUE))
    tema_plot(p, l = 132, r = 25, t = 18, b = 44)
  })

  ranking <- reactive({
    original <- filtro_indice()
    mx <- mex_actual()
    if (identical(input$universo, "inferior") && is.finite(mx)) {
      original <- original %>% filter(codigo != "MEX", valor < mx)
    } else if (identical(input$universo, "superior") && is.finite(mx)) {
      original <- original %>% filter(codigo != "MEX", valor > mx)
    } else if (identical(input$universo, "treinta")) {
      original <- head(ordenados_bajo_mexico(original), 30L)
    }
    if (!identical(input$region, "Todas las regiones")) {
      original <- original %>% filter(region == input$region)
    }
    original %>% arrange(desc(valor), pais)
  })

  output$resumen_clasificacion <- renderText({
    d <- ranking()
    paste0(nrow(d), " países en la selección · ", input$indicador, " (", input$anio,
           ") · orden descendente por índice.")
  })

  output$grafico_ranking <- renderPlotly({
    d <- head(ranking(), input$n_grafico)
    validate(need(nrow(d) > 0, "No hay países que cumplan los filtros."))
    d <- d %>% arrange(valor)
    barras <- ifelse(d$codigo == "MEX", "#A57F2C", "#611232")
    d$pais_factor <- factor(d$pais, levels = d$pais)
    p <- plotly::plot_ly(data = d, x = ~valor, y = ~pais_factor,
                         type = "bar", orientation = "h", marker = list(color = barras),
                         text = ~formatter(valor), textposition = "outside",
                         hovertemplate = "%{y} · %{x:.3f}<extra></extra>") %>%
      layout(xaxis = list(title = paste("Valor", input$indicador), range = c(0, 1.075),
                          gridcolor = "#EEEAE6", zeroline = FALSE),
             yaxis = list(title = "", automargin = TRUE))
    mx <- mex_actual()
    if (is.finite(mx)) {
      p <- p %>% layout(shapes = list(list(type = "line", x0 = mx, x1 = mx,
                               y0 = 0, y1 = 1, yref = "paper",
                               line = list(color = "#A57F2C", width = 2, dash = "dash"))))
    }
    tema_plot(p, l = 205, r = 36, t = 16, b = 50)
  })

  ranking_tabla <- reactive({
    d <- ranking()
    data.frame("N.º" = seq_len(nrow(d)), "País" = d$pais, "Código" = d$codigo,
               "Continente / región" = d$region, "Indicador" = d$indicador,
               "Año" = d$anio, "Índice" = round(d$valor, 4),
               check.names = FALSE)
  })

  output$tabla_ranking <- DT::renderDT({
    DT::datatable(ranking_tabla(), rownames = FALSE, filter = "top",
                  options = list(pageLength = 15, lengthMenu = c(10, 15, 30, 50, 100),
                                 scrollX = TRUE, order = list(list(0, "asc")),
                                 language = list(search = "Buscar:", lengthMenu = "Mostrar _MENU_",
                                                 info = "Mostrando _START_–_END_ de _TOTAL_",
                                                 infoEmpty = "Sin registros", zeroRecords = "No se encontraron registros",
                                                 paginate = list(previous = "Anterior", next = "Siguiente")))) %>%
      DT::formatRound(columns = "Índice", digits = 3)
  }, server = FALSE)

  output$descargar_ranking <- downloadHandler(
    filename = function() paste0("ranking_", input$indicador, "_", input$anio, ".csv"),
    content = function(file) utils::write.csv(ranking_tabla(), file, row.names = FALSE,
                                              fileEncoding = "UTF-8", na = "")
  )

  output$grafico_comparador <- renderPlotly({
    req(input$paises_comp)
    d <- filtro_indice() %>% filter(pais %in% input$paises_comp) %>% arrange(valor)
    validate(need(nrow(d) > 0, "Los países elegidos no tienen datos para este indicador y año."))
    pal <- ifelse(d$codigo == "MEX", "#A57F2C", "#1E5B4F")
    d$pais_factor <- factor(d$pais, levels = d$pais)
    p <- plotly::plot_ly(data = d, x = ~valor, y = ~pais_factor,
                         type = "bar", orientation = "h", marker = list(color = pal),
                         text = ~formatter(valor), textposition = "outside",
                         hovertemplate = "%{y}: %{x:.3f}<extra></extra>") %>%
      layout(xaxis = list(title = paste(input$indicador, input$anio), range = c(0, 1.08),
                          gridcolor = "#EEEAE6", zeroline = FALSE),
             yaxis = list(title = "", automargin = TRUE))
    tema_plot(p, l = 175, r = 22, t = 15, b = 45)
  })

  pares_indices <- reactive({
    req(input$anio)
    a <- as.integer(input$anio)
    h <- datos %>% filter(indicador == "IDH", anio == a) %>%
      select(codigo, pais, region, idh = valor)
    i <- datos %>% filter(indicador == "IDH-D", anio == a) %>%
      select(codigo, idhd = valor)
    inner_join(h, i, by = "codigo") %>%
      mutate(perdida = ifelse(idh > 0, 100 * (idh - idhd) / idh, NA_real_),
             brecha = idh - idhd)
  })

  output$grafico_dispersion <- renderPlotly({
    d <- pares_indices()
    if (!identical(input$region, "Todas las regiones")) d <- d %>% filter(region == input$region)
    validate(need(nrow(d) > 0, "No hay pares IDH / IDH-D para este año y región."))
    p <- plotly::plot_ly() %>%
      add_trace(x = c(0, 1), y = c(0, 1), type = "scatter", mode = "lines",
                line = list(color = "#D4D1CB", dash = "dash", width = 1.5),
                hoverinfo = "skip", showlegend = FALSE) %>%
      add_trace(data = d, x = ~idh, y = ~idhd, type = "scatter", mode = "markers",
                color = ~region, colors = colores_regiones,
                text = ~paste0(pais, "<br>IDH: ", formatter(idh),
                               "<br>IDH-D: ", formatter(idhd),
                               "<br>Pérdida: ", formatter(perdida, 1), "%"),
                hoverinfo = "text", marker = list(size = 9, opacity = 0.75)) %>%
      layout(xaxis = list(title = "IDH", range = c(0, 1.01), gridcolor = "#EEEAE6"),
             yaxis = list(title = "IDH-D", range = c(0, 1.01), gridcolor = "#EEEAE6"),
             legend = list(orientation = "h", y = -0.28))
    mx <- d[d$codigo == "MEX", , drop = FALSE]
    if (nrow(mx)) {
      p <- p %>% add_trace(x = mx$idh, y = mx$idhd, type = "scatter", mode = "markers+text",
                           text = "México", textposition = "top center",
                           marker = list(size = 14, color = "#A57F2C", line = list(color = "#FFFFFF", width = 2)),
                           name = "México", showlegend = FALSE,
                           hovertemplate = "México<br>IDH: %{x:.3f}<br>IDH-D: %{y:.3f}<extra></extra>")
    }
    tema_plot(p, l = 58, r = 12, t = 22, b = 54)
  })

  output$tabla_perdida <- DT::renderDT({
    d <- pares_indices()
    if (!identical(input$region, "Todas las regiones")) d <- d %>% filter(region == input$region)
    if (length(input$paises_comp)) d <- d %>% filter(pais %in% input$paises_comp)
    d <- d %>% arrange(desc(perdida))
    tabla <- data.frame("País" = d$pais, "IDH" = round(d$idh, 3),
                        "IDH-D" = round(d$idhd, 3), "Pérdida (%)" = round(d$perdida, 1),
                        check.names = FALSE)
    DT::datatable(tabla, rownames = FALSE,
                  options = list(pageLength = 8, scrollX = TRUE, dom = "tip", order = list(list(3, "desc"))))
  }, server = FALSE)

  output$grafico_evolucion <- renderPlotly({
    req(input$paises_hist, input$indicador)
    d <- datos %>% filter(indicador == input$indicador, pais %in% input$paises_hist)
    validate(need(nrow(d) > 0, "No hay datos para los países y el indicador seleccionados."))
    p <- plotly::plot_ly(data = d, x = ~anio, y = ~valor,
                         color = ~pais, colors = colores_lineas,
                         type = "scatter", mode = "lines+markers",
                         marker = list(size = 5), line = list(width = 2.5),
                         text = ~paste0(pais, " · ", anio, "<br>", input$indicador, ": ", formatter(valor)),
                         hoverinfo = "text") %>%
      layout(xaxis = list(title = "Año", gridcolor = "#EEEAE6", zeroline = FALSE),
             yaxis = list(title = input$indicador, range = c(0, 1.02),
                          gridcolor = "#EEEAE6", zeroline = FALSE),
             legend = list(orientation = "h", y = -0.24))
    tema_plot(p, l = 55, r = 25, t = 24, b = 56)
  })

  output$nota_evolucion <- renderUI({
    rango <- range(datos$anio[datos$indicador == input$indicador], na.rm = TRUE)
    div(class = "info-note", paste0("Cobertura temporal original de ", input$indicador,
                                     ": ", rango[1], "–", rango[2], ". ",
                                     if (identical(input$indicador, "AHDI"))
                                       "Sus observaciones no tienen frecuencia anual constante."
                                     else "La disponibilidad por país puede variar a lo largo de la serie."))
  })

  casos <- reactive({
    req(input$anio_casos)
    a <- as.integer(input$anio_casos)
    lista_h <- seleccion_30("IDH", a)
    lista_i <- seleccion_30("IDH-D", a)
    both <- intersect(lista_h$codigo, lista_i$codigo)
    solo_h <- setdiff(lista_h$codigo, lista_i$codigo)
    solo_i <- setdiff(lista_i$codigo, lista_h$codigo)
    todos <- unique(c(lista_h$codigo, lista_i$codigo))
    nombres_local <- datos %>% filter(codigo %in% todos) %>% distinct(codigo, pais, region)
    h <- data.frame(codigo = lista_h$codigo, puesto_idh = seq_len(nrow(lista_h)), idh = lista_h$valor)
    i <- data.frame(codigo = lista_i$codigo, puesto_idhd = seq_len(nrow(lista_i)), idhd = lista_i$valor)
    detalle <- full_join(h, i, by = "codigo") %>% left_join(nombres_local, by = "codigo") %>%
      distinct(codigo, .keep_all = TRUE) %>%
      mutate(estado = case_when(codigo %in% both ~ "En ambas",
                                codigo %in% solo_h ~ "Solo IDH", TRUE ~ "Solo IDH-D")) %>%
      arrange(is.na(puesto_idh), puesto_idh, puesto_idhd)
    list(h = lista_h, i = lista_i, both = both, solo_h = solo_h, solo_i = solo_i, detalle = detalle)
  })

  output$kpis_casos <- renderUI({
    v <- casos()
    fluidRow(
      column(4, kpi("Países que coinciden", as.character(length(v$both)), "De 30 en cada índice", "kpi-primary")),
      column(4, kpi("Solo en selección IDH", as.character(length(v$solo_h)), "No aparecen en los 30 del IDH-D")),
      column(4, kpi("Solo en selección IDH-D", as.character(length(v$solo_i)), "No aparecen en los 30 del IDH"))
    )
  })

  output$solo_idh <- renderUI({
    v <- casos()
    d <- v$detalle %>% filter(codigo %in% v$solo_h) %>% arrange(puesto_idh)
    if (!nrow(d)) return(tags$p("Ningún país."))
    tags$div(class = "country-tags", lapply(d$pais, function(x) tags$span(x)))
  })

  output$solo_idhd <- renderUI({
    v <- casos()
    d <- v$detalle %>% filter(codigo %in% v$solo_i) %>% arrange(puesto_idhd)
    if (!nrow(d)) return(tags$p("Ningún país."))
    tags$div(class = "country-tags", lapply(d$pais, function(x) tags$span(x)))
  })

  output$tabla_casos <- DT::renderDT({
    d <- casos()$detalle
    tab <- data.frame("País" = d$pais, "Región" = d$region,
                      "Puesto IDH" = d$puesto_idh, "IDH" = round(d$idh, 3),
                      "Puesto IDH-D" = d$puesto_idhd, "IDH-D" = round(d$idhd, 3),
                      "Selección" = d$estado, check.names = FALSE)
    DT::datatable(tab, rownames = FALSE, filter = "top",
                  options = list(pageLength = 15, scrollX = TRUE,
                                 lengthMenu = c(10,15,30,50),
                                 order = list(list(2, "asc"))))
  }, server = FALSE)

  output$tabla_cobertura <- DT::renderDT({
    d <- datos %>% group_by(indicador) %>% summarise(
      anio_inicial = min(anio), anio_final = max(anio),
      paises_total = n_distinct(codigo), .groups = "drop")
    cobertura_2023 <- datos %>% filter(anio == 2023) %>% count(indicador, name = "paises_2023")
    d <- left_join(d, cobertura_2023, by = "indicador")
    tabla <- data.frame("Indicador" = d$indicador, "Desde" = d$anio_inicial,
                        "Hasta" = d$anio_final, "Países en la serie" = d$paises_total,
                        "Países en 2023" = ifelse(is.na(d$paises_2023), "Sin datos", d$paises_2023),
                        check.names = FALSE)
    DT::datatable(tabla, rownames = FALSE, options = list(dom = "t", scrollX = TRUE))
  }, server = FALSE)
}

shinyApp(ui, server)
