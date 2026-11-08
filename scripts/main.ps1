# =============================================================================
# PETRA OMNITOOL - GELISTIRME YUKLEYICISI
# Tek dosya yayin surumu icin: powershell -File compile.ps1
# Bu dosya modulleri diskten dot-source eder; her degisiklikte 705 KB yeniden
# derlemeye gerek kalmaz.
# =============================================================================
$ErrorActionPreference = "Continue"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$script:PetraRoot = Split-Path $PSScriptRoot -Parent
$manifestPath = Join-Path $PSScriptRoot "modules.psd1"
if (-not (Test-Path -LiteralPath $manifestPath)) { throw "Modul manifestosu bulunamadi: $manifestPath" }
$manifest = Import-PowerShellDataFile -Path $manifestPath

$sync = [Hashtable]::Synchronized(@{})
$sync.IsAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
# CLI argumanlarini modullere tasi (dot-source sirasinda $args bos gorunur).
$script:PetraArgs = @($args)

function Read-PetraDevJson([string]$relativePath) {
    $path = Join-Path $script:PetraRoot $relativePath
    if (-not (Test-Path -LiteralPath $path)) { throw "Dosya bulunamadi: $path" }
    $raw = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)
    return ($raw | ConvertFrom-Json)
}

# Build ile ayni sekilde veri kaynaklarini yukle
$sync.AppsConfig      = Read-PetraDevJson "config\apps.json"
$sync.FeaturesConfig  = Read-PetraDevJson "config\features.json"
$sync.TweaksConfig    = Read-PetraDevJson "config\tweaks.json"
$sync.BloatwareConfig = Read-PetraDevJson "config\bloatware.json"
$sync.Xaml            = [System.IO.File]::ReadAllText((Join-Path $script:PetraRoot "xaml\input.xaml"), [System.Text.Encoding]::UTF8)

$masPath = Join-Path $script:PetraRoot "scripts\mas.aio.cmd"
$sync.MasScript = if (Test-Path -LiteralPath $masPath) { [System.IO.File]::ReadAllText($masPath, [System.Text.Encoding]::UTF8) } else { "" }

$logoPath = Join-Path $script:PetraRoot "assets\logo.ico"
$sync.LogoBase64 = if (Test-Path -LiteralPath $logoPath) { [Convert]::ToBase64String([System.IO.File]::ReadAllBytes($logoPath)) } else { "" }

# Modulleri manifestodaki sirayla yukle
foreach ($rel in $manifest.Order) {
    $modulePath = Join-Path (Join-Path $script:PetraRoot "scripts") $rel
    if (-not (Test-Path -LiteralPath $modulePath)) { throw "Modul bulunamadi: $modulePath" }
    . $modulePath
    # CLI preset modunda GUI modullerini (WPF/XAML) yuklemeye gerek yok.
    if ($script:PetraCliOnly) { return }
}
