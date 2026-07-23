# Запуск всех тестов.
. "$PSScriptRoot\_common.ps1"

Write-Host '== flutter test ==' -ForegroundColor Cyan
flutter test @args
exit $LASTEXITCODE
