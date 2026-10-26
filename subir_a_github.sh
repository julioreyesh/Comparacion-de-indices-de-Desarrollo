#!/usr/bin/env bash
# Subida inicial o actualización del tablero. Ejecuta con: bash subir_a_github.sh
set -euo pipefail
cd "$(dirname "$0")"
URL="https://github.com/julioreyesh/Comparacion-de-indices-de-Desarrollo.git"

if ! command -v git >/dev/null 2>&1; then
  echo "Instala Git o Xcode Command Line Tools: xcode-select --install"
  exit 1
fi

if [ ! -d .git ]; then
  git init
  git branch -M main
fi

if git remote get-url origin >/dev/null 2>&1; then
  EXISTENTE="$(git remote get-url origin)"
  if [ "$EXISTENTE" != "$URL" ] && [ "$EXISTENTE" != "git@github.com:julioreyesh/Comparacion-de-indices-de-Desarrollo.git" ]; then
    echo "El remote origin ya apunta a otro repositorio: $EXISTENTE"
    echo "Por seguridad, no se modificó. Revisa la configuración antes de continuar."
    exit 1
  fi
else
  git remote add origin "$URL"
fi

if [ -z "$(git config user.name || true)" ] || [ -z "$(git config user.email || true)" ]; then
  echo "Configura tu nombre y correo de Git en este repositorio."
  echo 'git config user.name "Tu nombre"'
  echo 'git config user.email "tu-correo@ejemplo.com"'
  exit 1
fi

git add .
if ! git diff --cached --quiet; then
  git commit -m "Publicar observatorio de desarrollo humano en Shiny"
else
  echo "No hay cambios nuevos que publicar."
fi

echo "Subiendo a $URL ..."
git push -u origin main

echo "Código actualizado: https://github.com/julioreyesh/Comparacion-de-indices-de-Desarrollo"
echo "Configura los secretos para desplegar en shinyapps.io (ver GITHUB.md)."
