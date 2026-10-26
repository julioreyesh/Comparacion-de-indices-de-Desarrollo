# Publicar el dashboard: guía paso a paso

**Plataforma propuesta:** shinyapps.io de Posit. Permite consultar el tablero desde una URL web sin necesidad de instalar R ni RStudio en los equipos de quienes lo visitan. GitHub es opcional y NO se requiere para publicar.

## 1. Preparar el proyecto en tu Mac

Descomprime el ZIP. Copia el contenido de `IndicesDesarrollo` a:

`/Users/julioreyes/Desktop/IndicesDesarrollo`

Asegúrate de que en esa ruta se encuentren directamente `app.R`, `publicar_shinyapps.R`, `install_packages.R`, `data/` y `www/`.

Abre en RStudio el proyecto `IndicesDesarrollo.Rproj` y comprueba el funcionamiento local:

```r
source("/Users/julioreyes/Desktop/IndicesDesarrollo/install_packages.R")
shiny::runApp("/Users/julioreyes/Desktop/IndicesDesarrollo", launch.browser = TRUE)
```

Revisa las pestañas **Panorama**, **Mapas interactivos**, **Clasificación**, **Comparador**, **Evolución histórica**, **Selección de 30 casos** y **Fuentes y método**. Es importante comprobar que el mapa funcione con conexión a Internet.

## 2. Crear y vincular tu cuenta

1. Abre https://www.shinyapps.io/ y crea tu cuenta o inicia sesión.
2. En RStudio, ejecuta `install.packages("rsconnect")` si no está instalado.
3. En tu cuenta de shinyapps.io abre **Account > Tokens**, o entra a https://www.shinyapps.io/admin/#/tokens .
4. Pulsa **Add Token**; copia en **tu propia consola privada de RStudio** el comando `rsconnect::setAccountInfo(...)` que muestra el servicio.
5. **No guardes el token ni el secret en app.R, en el ZIP, en GitHub ni en un chat.** Solo necesitas hacer este paso la primera vez en el equipo.

## 3. Publicar la aplicación

En la consola de RStudio ejecuta:

```r
source("/Users/julioreyes/Desktop/IndicesDesarrollo/publicar_shinyapps.R")
```

El script verifica los archivos y utiliza `rsconnect::deployApp()` para subir el código, los estilos y las tres CSV necesarias. No exige GitHub. La primera publicación puede instalar dependencias en el servidor.

Cuando el despliegue termine correctamente, el enlace tendrá una forma parecida a:

`https://TU-CUENTA.shinyapps.io/desarrollo-humano-mexico/`

Esta es **solo una plantilla**, no un enlace ya publicado. Copia la dirección real que aparezca en tu cuenta y pruébala desde otra computadora o una ventana de navegación privada.

## 4. Privacidad y acceso del equipo

- **Aplicación pública:** la opción predeterminada en el script. Quien tenga el enlace puede verla; no requiere cuenta para consultar. Dado que los datos de los CSV proceden de fuentes públicas, puede ser apropiado para una versión no confidencial.
- **Acceso restringido:** shinyapps.io permite habilitar autenticación y usuarios invitados en sus planes **Standard y Professional** (consulta condiciones vigentes). En ese caso, configura `Users > Application Visibility > Private` y añade los correos autorizados. Si necesitas que nunca sea visible públicamente, no ejecutes el script con `appVisibility="public"`; edita esa línea a `appVisibility="private"` *solo con un plan que admita apps privadas* o publica mediante una solución institucional como Posit Connect.
- **No subas información confidencial:** antes de publicar en un servicio externo, revisa las políticas de tu organización. El proyecto incluye solo bases públicas, pero el entorno de trabajo podría tener otras restricciones.

Documentación oficial: https://docs.posit.co/shinyapps.io/guide/authentication_and_user_management/

## 5. Actualizar la publicación

Edita los archivos locales, prueba con `shiny::runApp(...)` y ejecuta nuevamente `source(".../publicar_shinyapps.R")` para desplegar una nueva versión en la misma cuenta y con el mismo nombre. No se necesita cambiar la URL. **Atención:** el script usa visibilidad pública; para una app privada mantenida por la organización, ajusta también ese parámetro antes de re-publicar.

## 6. Resolución de problemas

- **Faltan paquetes:** `source(".../install_packages.R")` e instala `rsconnect`.
- **No hay cuenta registrada:** copia el comando de autorización de la sección `Tokens` en tu consola RStudio.
- **El mapa no aparece:** confirma conexión a Internet y prueba con otro navegador. Plotly puede requerir descargar la cartografía base; no debe suponerse visualización fuera de línea.
- **Error durante despliegue:** consulta el registro del deploy en RStudio y los logs de la aplicación en shinyapps.io. Si se necesitara diagnosticar, comparte los mensajes de error, **nunca las credenciales**.
- **Límites del plan:** consulta los recursos, horas de funcionamiento, número de aplicaciones y acceso de tu plan; no se presupone disponibilidad ilimitada.

## 7. GitHub, opcional

Puedes alojar el proyecto en un repositorio privado de GitHub para control de cambios del equipo. Esto no reemplaza el alojamiento en shinyapps.io. El archivo `.gitignore` excluye credenciales locales y el directorio de despliegues. Antes de publicar el código, revisa los permisos y las reglas de uso de la identidad gráfica institucional.

## Fuente y aspectos institucionales

Datos: PNUD / Our World in Data (IDH e IDH-D, hasta 2023); Prados de la Escosura (AHDI, hasta 2020). Las referencias completas están en el tablero y en `README.md`.

La interfaz usa colores de referencia de la guía de identidad del Gobierno de México 2024–2030 (p. 17), pero **no incluye el escudo ni el imagotipo oficial** y **no implica validación institucional**. Para circularlo como producto formal, somételo a la revisión correspondiente.
