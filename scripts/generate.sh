#!/usr/bin/env bash
# То же, что scripts/generate.ps1, для Linux и Codespaces.
set -euo pipefail
cd "$(dirname "$0")/.."

flutter gen-l10n
dart run build_runner build --delete-conflicting-outputs
python3 scripts/changelog_asset.py
