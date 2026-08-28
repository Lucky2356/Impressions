#!/usr/bin/env bash
# Установка Flutter в Codespaces. Версия закреплена: тесты с золотыми
# снимками зависят от отрисовки текста, а она меняется между версиями движка.
# Здесь и в .github/workflows должна стоять одна и та же.
set -euo pipefail

FLUTTER_VERSION=3.44.7
FLUTTER_ROOT=/usr/local/flutter

sudo apt-get update
sudo apt-get install -y --no-install-recommends curl git unzip xz-utils zip libglu1-mesa

if [ ! -d "$FLUTTER_ROOT" ]; then
  sudo git clone --depth 1 --branch "$FLUTTER_VERSION" \
    https://github.com/flutter/flutter.git "$FLUTTER_ROOT"
  sudo chown -R "$(id -u):$(id -g)" "$FLUTTER_ROOT"
fi

git config --global --add safe.directory "$FLUTTER_ROOT"
export PATH="$FLUTTER_ROOT/bin:$PATH"

flutter --version
flutter config --no-analytics >/dev/null
