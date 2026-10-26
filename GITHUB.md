# Publicación del Observatorio mediante GitHub y shinyapps.io

Repositorio existente: **https://github.com/julioreyesh/Comparacion-de-indices-de-Desarrollo**

## Arquitectura

- **GitHub:** guarda código, bases públicas, documentación y el historial de modificaciones.
- **GitHub Actions:** valida las CSV y la sintaxis de R, y despliega cuando hay cambios en `main`.
- **shinyapps.io:** ejecuta R Shiny y genera la URL que las personas consultarán.
- **GitHub Pages NO ejecuta este `app.R`** (necesita una sesión activa de R).

**Importante:** el repositorio de GitHub identificado es **público**. El código y los tres CSV serán públicos cuando se suban. Los secretos NO se suben al repositorio; el equipo que consulte la app no necesitará acceso a GitHub.

## 1. Subir los archivos al repositorio (desde tu Mac)

1. Descomprime el ZIP y asegúrate de que en `/Users/julioreyes/Desktop/IndicesDesarrollo` se encuentran directamente `app.R`, `.github/`, `data/`, `www/`, `scripts/` y `GITHUB.md`.
2. Abre Terminal y ejecuta:

```bash
cd /Users/julioreyes/Desktop/IndicesDesarrollo
bash subir_a_github.sh
```

3. Si Git solicita configurar nombre y correo, sigue las instrucciones de Terminal. Para autenticación, usa **GitHub Desktop** o `gh auth login` (si tienes GitHub CLI). No pegues tu contraseña como token en comandos del proyecto.
4. Confirma en el navegador que el repositorio contiene `app.R`, `data/`, `www/` y `.github/workflows/publicar-dashboard.yml`.

Si aparece `non-fast-forward`, **no uses `git push --force`**. Probablemente se agregó un archivo nuevo desde la web. Clona el repositorio, copia el proyecto dentro, crea el commit y vuelve a subir.

## 2. Crear la cuenta de alojamiento

1. Abre https://www.shinyapps.io y crea una cuenta o inicia sesión.
2. En la sección **Account > Tokens**, crea un token. El servicio mostrará el nombre de cuenta, el token y el secret.
3. No compartas esos valores por mensajes ni los guardes en un archivo del proyecto.

## 3. Configurar secretos del repositorio

En el repositorio GitHub abre **Settings > Secrets and variables > Actions**.

En **Repository secrets**, crea exactamente estos tres:

| Nombre | Qué contiene |
|---|---|
| `SHINYAPPS_ACCOUNT` | Nombre de la cuenta de shinyapps.io (no necesariamente el usuario de GitHub) |
| `SHINYAPPS_TOKEN` | Token generado por shinyapps.io |
| `SHINYAPPS_SECRET` | Secret generado por shinyapps.io |

Los secretos son distintos de las credenciales para iniciar sesión en GitHub. Es esencial mantenerlos privados.

En **Repository variables** puedes agregar `SHINYAPPS_VISIBILITY` con `public` o `private`. Si no la agregas, el script usa `public`. `private` requiere un plan compatible con autenticación en shinyapps.io. **Un repositorio privado y una aplicación privada son configuraciones independientes.**

## 4. Publicar usando GitHub Actions

1. Abre la pestaña **Actions** del repositorio y selecciona **Comprobar y publicar dashboard Shiny**.
2. Presiona **Run workflow**, elige `main` y ejecuta.
3. El proceso comprueba datos, verifica sintaxis e intenta desplegar la app en shinyapps.io. Si faltan secretos, muestra un aviso y omite la publicación.
4. Cuando finalice sin errores, abre tu cuenta en https://www.shinyapps.io para obtener la URL real de `desarrollo-humano-mexico`.
5. Comparte esa URL con el equipo (no la del repositorio GitHub).

Después, cada cambio enviado a `main` en los archivos de la app, datos, estilos o scripts dispara la verificación y publicación automática. `README.md` y documentación, por sí solos, no vuelven a desplegarla.

## 5. Cómo actualizar la aplicación

- Edita localmente `app.R`, `www/styles.css` o alguna de las CSV dentro de `data/`.
- Prueba localmente con `shiny::runApp('.', launch.browser=TRUE)`.
- Ejecuta `bash subir_a_github.sh` de nuevo para guardar el cambio en GitHub.
- Revisa el resultado en **Actions**; si el despliegue se completa, se mantiene la misma URL de shinyapps.io.

## 6. Permisos y seguridad

- El repositorio vinculado es público; **no incluyas datos internos, contraseñas, tokens, expedientes ni información personal.**
- Si el dashboard debe ser privado, configura ambas cosas: repositorio privado en GitHub y acceso restringido en la plataforma de hosting, de acuerdo con el plan y las políticas institucionales.
- Los datos originales incluidos aquí proceden de fuentes públicas. El diseño utiliza colores de referencia de la guía 2024–2030, sin representar una autorización formal de publicación gubernamental.
- GitHub Actions puede tener límites de uso; revisa el plan de tu organización.

## Comprobaciones y límites

El proyecto incluye la comprobación `python3 scripts/comprobar_datos.py`, sintaxis de `app.R` y despliegue mediante `rsconnect`. Se verificó la estructura y las CSV. **No se ha ejecutado la aplicación en R ni se ha realizado todavía un despliegue real:** son pasos que requieren R y las credenciales de shinyapps.io.

Fuentes oficiales para los procedimientos: https://docs.posit.co/shinyapps.io/guide/getting_started/ ; https://rstudio.github.io/rsconnect/reference/deployApp.html ; https://docs.github.com/en/actions/security-guides/using-secrets-in-github-actions .
