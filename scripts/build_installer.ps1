# Сборка установщика Windows (.exe) из релизной сборки Flutter.
#
# Flutter выдаёт папку с impressions.exe, библиотеками движка, плагинами и
# каталогом data. Отдельный exe из неё не работает, поэтому распространяется
# установщик: он кладёт всё вместе, создаёт ярлыки и регистрирует удаление.
#
# Требуется Inno Setup 6: winget install JRSoftware.InnoSetup
param(
    # Номер версии; по умолчанию берётся из pubspec.yaml.
    [string]$Version,
    # Пропустить пересборку приложения и использовать готовый build/.
    [switch]$SkipBuild
)

. "$PSScriptRoot\_common.ps1"

$root = $script:ProjectRoot

if (-not $Version) {
    $line = Select-String -Path (Join-Path $root 'pubspec.yaml') -Pattern '^version:\s*(.+)$' | Select-Object -First 1
    if (-not $line) { Write-Error 'Не удалось прочитать версию из pubspec.yaml'; exit 1 }
    $Version = ($line.Matches[0].Groups[1].Value -split '\+')[0].Trim()
}
Write-Host "== Версия: $Version ==" -ForegroundColor Cyan

if (-not $SkipBuild) {
    Write-Host '== flutter build windows --release ==' -ForegroundColor Cyan
    flutter build windows --release
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}

$releaseDir = Join-Path $root 'build\windows\x64\runner\Release'
if (-not (Test-Path (Join-Path $releaseDir 'impressions.exe'))) {
    Write-Error "Не найдена сборка в $releaseDir. Запустите без -SkipBuild."
    exit 1
}

$searchPaths = @(
    (Join-Path $env:LOCALAPPDATA 'Programs\Inno Setup 6'),
    'C:\Program Files (x86)\Inno Setup 6',
    'C:\Program Files\Inno Setup 6'
) | Where-Object { Test-Path $_ }

$iscc = $null
if ($searchPaths) {
    $iscc = Get-ChildItem -Path $searchPaths -Filter 'ISCC.exe' -ErrorAction SilentlyContinue | Select-Object -First 1
}
if (-not $iscc) {
    Write-Error 'ISCC.exe не найден. Установите Inno Setup: winget install JRSoftware.InnoSetup'
    exit 1
}

$distDir = Join-Path $root 'dist'
if (-not (Test-Path $distDir)) { New-Item -ItemType Directory -Path $distDir | Out-Null }

Write-Host '== Сборка установщика ==' -ForegroundColor Cyan
& $iscc.FullName "/DAppVersion=$Version" "/DSourceDir=$releaseDir" "/DOutputDir=$distDir" (Join-Path $root 'installer\impressions.iss')
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

$setup = Join-Path $distDir "Impressions-$Version-windows-x64-setup.exe"
$size = [math]::Round((Get-Item $setup).Length / 1MB, 1)
Write-Host "Готово: $setup ($size МБ)" -ForegroundColor Green
exit 0
