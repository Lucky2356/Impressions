# Сборка Windows release.
# Требуется Visual Studio с компонентами Desktop C++ и включённый Developer Mode.
. "$PSScriptRoot\_common.ps1"

Write-Host '== flutter build windows --release ==' -ForegroundColor Cyan
flutter build windows --release
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

$exe = Join-Path $script:ProjectRoot 'build\windows\x64\runner\Release'
Write-Host "Готово. Сборка: $exe" -ForegroundColor Green
exit 0
