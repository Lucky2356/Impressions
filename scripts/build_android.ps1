# Сборка Android APK (release). Требуется Android SDK.
. "$PSScriptRoot\_common.ps1"

Write-Host '== flutter build apk --release ==' -ForegroundColor Cyan
flutter build apk --release
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

$apk = Join-Path $script:ProjectRoot 'build\app\outputs\flutter-apk\app-release.apk'
Write-Host "Готово. APK: $apk" -ForegroundColor Green
exit 0
