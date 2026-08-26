# Сборка Android APK (release). Требуется Android SDK.
. "$PSScriptRoot\_common.ps1"

# Архитектуры те же, что оставляет abiFilters в build.gradle.kts. Флаг ничего
# не меняет в самом файле — он избавляет от компиляции третьей архитектуры,
# которую фильтр всё равно выбросит.
Write-Host '== flutter build apk --release ==' -ForegroundColor Cyan
flutter build apk --release --target-platform android-arm,android-arm64
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

$apk = Join-Path $script:ProjectRoot 'build\app\outputs\flutter-apk\app-release.apk'
Write-Host "Готово. APK: $apk" -ForegroundColor Green
exit 0
