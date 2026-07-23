# Первичная настройка: зависимости + кодогенерация.
. "$PSScriptRoot\_common.ps1"

Write-Host '== flutter pub get ==' -ForegroundColor Cyan
flutter pub get
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

& "$PSScriptRoot\generate.ps1"
exit $LASTEXITCODE
