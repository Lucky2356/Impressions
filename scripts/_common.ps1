# Общие настройки для скриптов проекта «Впечатления».
# Гарантирует наличие flutter в PATH (fallback на C:\src\flutter\bin).

$ErrorActionPreference = 'Stop'

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    $fallback = 'C:\src\flutter\bin'
    if (Test-Path (Join-Path $fallback 'flutter.bat')) {
        $env:Path = "$fallback;$env:Path"
    } else {
        Write-Error 'flutter не найден в PATH. Установите Flutter или добавьте C:\src\flutter\bin в PATH.'
        exit 1
    }
}

# Корень проекта = родительская папка каталога scripts.
$script:ProjectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $script:ProjectRoot
