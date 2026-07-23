# Полная проверка проекта (§33). Завершается ненулевым кодом при любой ошибке.
# 1) pub get 2) генерация 3) проверка формата 4) analyze 5) тесты
. "$PSScriptRoot\_common.ps1"

Write-Host '== [1/5] flutter pub get ==' -ForegroundColor Cyan
flutter pub get
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host '== [2/5] кодогенерация ==' -ForegroundColor Cyan
& "$PSScriptRoot\generate.ps1"
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host '== [3/5] проверка форматирования ==' -ForegroundColor Cyan
dart format --output=none --set-exit-if-changed .
if ($LASTEXITCODE -ne 0) {
    Write-Error 'Код не отформатирован. Запустите: dart format .'
    exit $LASTEXITCODE
}

Write-Host '== [4/5] flutter analyze ==' -ForegroundColor Cyan
flutter analyze
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host '== [5/5] flutter test ==' -ForegroundColor Cyan
flutter test
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host 'Все проверки пройдены.' -ForegroundColor Green
exit 0
