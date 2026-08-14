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

$releaseDir = Join-Path $root 'build\windows\x64\runner\Release'

if (-not $SkipBuild) {
    # Папка сборки очищается перед сборкой: Flutter в неё только докладывает и
    # ничего оттуда не убирает, а установщик берёт её содержимое целиком
    # (`Source: {#SourceDir}\*`). Файл от удалённой зависимости так и остаётся
    # лежать и уезжает к пользователю. Так случилось со старой sqlite3.dll,
    # оставшейся после перехода на сборку с шифрованием: в лучшем случае лишние
    # полтора мегабайта, в худшем — приложение берёт не ту библиотеку.
    # Промежуточные файлы CMake лежат уровнем выше и не удаляются, поэтому
    # пересборка остаётся быстрой.
    if (Test-Path $releaseDir) {
        Write-Host '== Очистка папки сборки ==' -ForegroundColor Cyan
        Remove-Item -Recurse -Force $releaseDir
    }

    # Промежуточные ресурсы отладочной сборки: оттуда Flutter копирует в релиз
    # kernel_blob.bin на 74 МБ, который релизу не нужен. Очистка самой папки
    # сборки его не убирает — он возвращается отсюда при каждой сборке.
    $staleAssets = Join-Path $root 'build\flutter_assets'
    if (Test-Path $staleAssets) { Remove-Item -Recurse -Force $staleAssets }

    Write-Host '== flutter build windows --release ==' -ForegroundColor Cyan
    flutter build windows --release
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}

if (-not (Test-Path (Join-Path $releaseDir 'impressions.exe'))) {
    Write-Error "Не найдена сборка в $releaseDir. Запустите без -SkipBuild."
    exit 1
}

# Что уезжает к пользователю — видно до упаковки, а не после жалоб. С
# -SkipBuild очистки не было, и здесь может всплыть чужой файл.
$packed = Get-ChildItem -Path $releaseDir -Recurse -File |
    Where-Object { $_.Name -ne 'kernel_blob.bin' } |
    Measure-Object -Property Length -Sum
Write-Host ('== Уезжает в установщик: {0:N1} МБ в {1} файлах ==' -f ($packed.Sum / 1MB), $packed.Count) -ForegroundColor Cyan

Get-ChildItem -Path $releaseDir -Filter '*.dll' |
    ForEach-Object { Write-Host ('  {0,-34} {1,6:N2} МБ' -f $_.Name, ($_.Length / 1MB)) }

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
