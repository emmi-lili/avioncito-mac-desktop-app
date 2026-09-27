#!/bin/bash
# Compila Avioncito.app. Uso:
#   ./build.sh           → crea build/Avioncito.app
#   ./build.sh install   → además lo copia a /Applications y lo abre
set -euo pipefail
cd "$(dirname "$0")"

APP="build/Avioncito.app"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"

echo "✈️  Compilando..."
swiftc -O -swift-version 5 \
  -target "$(uname -m)-apple-macos13.0" \
  Sources/*.swift \
  -o "$APP/Contents/MacOS/Avioncito"

cp Info.plist "$APP/Contents/Info.plist"
if [ -d Resources ]; then cp -R Resources/. "$APP/Contents/Resources/"; fi

codesign --force --sign - "$APP" >/dev/null
echo "✅ Listo: $APP"

if [ "${1:-}" = "install" ]; then
  pkill -x Avioncito 2>/dev/null || true
  rm -rf /Applications/Avioncito.app
  cp -R "$APP" /Applications/
  open /Applications/Avioncito.app
  echo "🛫 Instalado en /Applications y abierto. Busca el avión en la barra de menú."
fi
