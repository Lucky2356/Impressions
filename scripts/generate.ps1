# Кодогенерация: локализации + build_runner (Drift, Freezed, json_serializable).
. "$PSScriptRoot\_common.ps1"

Write-Host '== flutter gen-l10n ==' -ForegroundColor Cyan
flutter gen-l10n
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host '== build_runner ==' -ForegroundColor Cyan
dart run build_runner build --delete-conflicting-outputs
exit $LASTEXITCODE
