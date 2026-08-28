#!/usr/bin/env bash
# То же, что scripts/check.ps1, для Linux и Codespaces.
# 1) pub get 2) генерация 3) проверка формата 4) analyze 5) тесты
set -euo pipefail
cd "$(dirname "$0")/.."

echo "== [1/5] flutter pub get =="
flutter pub get

echo "== [2/5] кодогенерация =="
./scripts/generate.sh

echo "== [3/5] проверка форматирования =="
dart format --output=none --set-exit-if-changed .

echo "== [4/5] flutter analyze =="
flutter analyze

echo "== [5/5] flutter test =="
flutter test

echo "Все проверки пройдены."
