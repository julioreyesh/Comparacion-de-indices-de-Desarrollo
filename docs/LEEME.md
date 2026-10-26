# Publicación directa en GitHub Pages

Esta carpeta `docs/` contiene una versión web **estática e interactiva** del dashboard. Mantiene los datos de IDH, IDH-D y AHDI, junto con mapas, filtros, rankings, comparación histórica, selección de 30 países y descarga de CSV, **sin Shiny ni shinyapps.io**. Se ejecuta en el navegador utilizando HTML, JavaScript, CSS y Plotly.

## Activación inicial (una sola vez)

1. En GitHub, abre `Settings > Pages` de este repositorio.
2. En **Build and deployment**, selecciona **Deploy from a branch**.
3. Selecciona **main** y la carpeta **/docs**; pulsa **Save**.
4. Cuando finalice la publicación, GitHub mostrará el enlace público del sitio.

La dirección esperada es `https://julioreyesh.github.io/Comparacion-de-indices-de-Desarrollo/`, pero no se debe dar por activada hasta que GitHub muestre el sitio publicado.

## Cambios y mantenimiento

Los archivos que GitHub Pages publica son `docs/index.html`, `docs/styles.css`, `docs/app.js` y `docs/data/indices.json`. Las bases CSV originales permanecen en `data/`. Si actualizas las bases de origen, **también tendrás que regenerar `docs/data/indices.json`**; no se actualiza automáticamente.

La visualización utiliza Plotly desde una CDN, por lo que las gráficas y mapas requieren conexión a Internet. Los datos del portal se sirven como JSON estático junto con la página; no se envían a un servidor R.

**Visibilidad:** una página publicada con GitHub Pages puede ser accesible al público. No subas información confidencial. El sitio utiliza datos públicos proporcionados en la conversación. La paleta institucional no implica que sea un sitio oficial.

Si en el futuro necesitas el motor R de Shiny por funcionalidades especiales, conserva `app.R` y publícalo en un servidor compatible; GitHub Pages no ejecuta procesos R persistentes.
