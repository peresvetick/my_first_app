#!/usr/bin/env bash
# Сборка Flutter Web на Vercel CI (Flutter SDK в окружении нет — клонируем).
set -euo pipefail

if [ ! -d flutter/bin ]; then
  git clone https://github.com/flutter/flutter.git -b stable --depth 1
fi
export PATH="$PATH:$(pwd)/flutter/bin"

flutter config --enable-web
flutter pub get
flutter build web --release
