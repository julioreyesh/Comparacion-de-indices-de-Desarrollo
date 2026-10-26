# Observatorio de Desarrollo Humano — Dashboard Shiny para publicación

Aplicación interactiva íntegramente en español, con **IDH, IDH ajustado por desigualdad (IDH-D) e IDH ampliado (AHDI)**. Diseñada para analizar países y regiones, con México como punto de referencia y una apariencia inspirada en la paleta oficial del Gobierno de México 2024–2030.

**Para colaborar y publicar con GitHub, sigue primero [`GITHUB.md`](GITHUB.md).** Repositorio: https://github.com/julioreyesh/Comparacion-de-indices-de-Desarrollo

## Uso local

Copia el contenido de esta carpeta a `/Users/julioreyes/Desktop/IndicesDesarrollo`, abre `IndicesDesarrollo.Rproj` en RStudio y ejecuta:

```r
source("/Users/julioreyes/Desktop/IndicesDesarrollo/install_packages.R")
shiny::runApp("/Users/julioreyes/Desktop/IndicesDesarrollo", launch.browser = TRUE)
```

Para publicar después de configurar la cuenta de shinyapps.io con `rsconnect::setAccountInfo()`:

```r
install.packages("rsconnect") # solo si no está instalado
source("/Users/julioreyes/Desktop/IndicesDesarrollo/publicar_shinyapps.R")
```

## Funciones del dashboard

1. **Panorama:** valor de México, países por debajo, mediana y comparación de medias y conteos regionales.
2. **Mapas interactivos:** mapa mundial por indicador/año/región; cambio de capa entre valor, diferencia con México y países seleccionados (30); mapa independiente de pérdida por desigualdad al comparar IDH e IDH-D para el mismo año, con escalas cromáticas fijas para facilitar comparaciones entre regiones y años; fichas por clic en el mapa, enlace al comparador y exportación CSV de datos del mapa.
3. **Clasificación:** ranking descendente, selección de países con valor inferior o superior al de México, los 30 inmediatamente inferiores, tabla ordenable y CSV.
4. **Comparador:** hasta ocho países; dispersión IDH vs IDH-D y pérdida por desigualdad (solo años comunes).
5. **Evolución histórica:** curvas por país para cada índice, respetando observaciones originales, sin interpolación.
6. **Selección de 30 casos:** comparación de grupos de 30 países según IDH e IDH-D y desglose de intersecciones.
7. **Fuentes y método:** definiciones, cobertura, criterios de inclusión y referencias originales, con enlaces archivados.

## Conceptos, años y referencias

| Índice | Definición resumida | Cobertura de CSV | Referencia |
|---|---|---|---|
| IDH (HDI) | Vida larga y saludable, educación y nivel de vida digno. | 1990–2023 | PNUD, HDR 2025, distribuido por Our World in Data; consulta 26/10/2026. |
| IDH-D (IHDI) | Las mismas tres dimensiones, ajustadas por desigualdades en su distribución. Valores altos indican desarrollo humano mayor y más igualitario. | 2010–2023 | PNUD, HDR 2025, distribuido por Our World in Data; consulta 26/10/2026. |
| AHDI | Vida larga y saludable, conocimientos, libertad y nivel de vida digno. | 1870–2020 (años irregulares) | Prados de la Escosura (2022). |

**Referencias completas:**

- **IDH:** UNDP, Human Development Report (2025), con procesamiento menor de Our World in Data. *Human Development Index – UNDP* [dataset]. Archivo del 12/08/2026, consultado el 26/10/2026: https://archive.ourworldindata.org/20260812-103058/grapher/human-development-index.html
- **IDH-D:** UNDP, Human Development Report (2025), con procesamiento menor de Our World in Data. *Inequality-adjusted Human Development Index – UNDP* [dataset]. Archivo del 26/08/2026, consultado el 26/10/2026: https://archive.ourworldindata.org/20260826-181749/grapher/inequality-adjusted-human-development-index.html
- **AHDI:** Leandro Prados de la Escosura (2022). *Human Development and the Path to Freedom: 1870 to the Present*. Cambridge: Cambridge University Press. https://doi.org/10.1017/9781108769655

Las bases originales y sus metadatos se conservan en `data/`. No hay imputación ni mezcla de años para rankings o pérdidas por desigualdad. Los mapas geográficos de Plotly emplean códigos de tres letras: territorios especiales y algunos países insulares pequeños podrían no colorearse aun cuando figuren en los CSV. Las consultas numéricas y las tablas son la referencia para estos casos.

## Identidad gráfica y distribución institucional

Colores tomados como referencia de la página 17 de la *Guía de Identidad Gráfica del Gobierno de México 2024–2030*: `#611232`, `#9B2247`, `#1E5B4F`, `#002F2A`, `#A57F2C`, `#E6D194`, `#161A1D` y `#98989A`.

Este tablero no contiene imágenes oficiales y no pretende presentarse como publicación oficial autorizada. Para distribución institucional deben revisarse los lineamientos aplicables.

## Estructura del proyecto

```
IndicesDesarrollo/
├── app.R                   # Aplicación R Shiny
├── publicar_shinyapps.R    # Publicación local opcional con rsconnect
├── GITHUB.md              # Guía para subir código y automatizar publicación
├── subir_a_github.sh      # Subida a GitHub desde Mac
├── .github/workflows/      # GitHub Actions para validar y desplegar
├── install_packages.R     # Instalación de dependencias
├── PUBLICAR.md             # Procedimiento de publicación y privacidad
├── README.md               # Este archivo
├── IndicesDesarrollo.Rproj
├── .gitignore
├── data/                   # 3 CSV originales, códigos traducidos y metadatos
├── www/styles.css          # Identidad visual
└── scripts/                # Pruebas de CSV y despliegue por GitHub Actions
```

## Comprobación

Se revisaron con Python la estructura de los datos, los años, los valores de México y las selecciones originales de 30 países. Para 2023 los resultados de referencia son: **México IDH = 0.789; IDH-D = 0.646; 111 países con IDH inferior; 96 con IDH-D inferior; 17 de 30 en ambas listas**.

**Límite de verificación:** el entorno de creación no dispone de una instalación de R. Por ello el tablero no ha sido ejecutado en un servidor Shiny real ni publicado en la cuenta del destinatario; corresponde probarlo localmente y desplegarlo mediante los pasos de `PUBLICAR.md`. No se presenta ninguna URL de ejemplo como sitio activo.