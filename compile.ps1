param (
    [switch]$Run,
    [string]$Preset
)

$ErrorActionPreference = "Stop"
$baseDir = $PSScriptRoot
if ([string]::IsNullOrEmpty($baseDir)) {
    $baseDir = (Get-Location).Path
}

$outputFile = Join-Path $baseDir "UmutEvranTools.ps1"
$asciiEnc = [System.Text.Encoding]::ASCII

function Remove-Bom([string]$t) {
    if ([string]::IsNullOrEmpty($t)) { return "" }
    return $t.Replace([string][char]0xFEFF, "").Trim()
}

Write-Host "[+] UmutEvranTools.ps1 v4.0 (WinUtil %100 Tam Entegre + Canli Tema) derleniyor..." -ForegroundColor Cyan

$header = @'
# =============================================================================
# UMUT EVRAN TOOL (TEK DOSYA / UZAKTAN CALISTIRMA SURUMU)
# Komut: irm evrantool.evranumut.workers.dev | iex
# Mimari: 100% Pure ASCII + Decode-U + WPF XamlReader + Runspace Multithreading
# =============================================================================
$ErrorActionPreference = 'Continue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
$isSta   = ([System.Threading.Thread]::CurrentThread.GetApartmentState() -eq 'STA')

if ((-not $isAdmin) -or (-not $isSta)) {
    $tempRunner = Join-Path $env:TEMP "UmutEvranTools_Runtime.ps1"
    if ($PSCommandPath -and (Test-Path $PSCommandPath)) {
        Copy-Item -Path $PSCommandPath -Destination $tempRunner -Force
    } elseif ($MyInvocation.MyCommand.Definition -and ($MyInvocation.MyCommand.Definition.Length -gt 200)) {
        [System.IO.File]::WriteAllText($tempRunner, $MyInvocation.MyCommand.Definition, [System.Text.Encoding]::ASCII)
    } else {
        Invoke-RestMethod -Uri "https://evrantool.evranumut.workers.dev" -OutFile $tempRunner
    }
    $argList = "-NoProfile -STA -ExecutionPolicy Bypass -File `"$tempRunner`""
    if ($args.Count -gt 0) {
        $argList += " " + ($args -join " ")
    }
    Start-Process powershell.exe -ArgumentList $argList -Verb RunAs
    return
}

$sync = [Hashtable]::Synchronized(@{})
'@

$appsJson      = Remove-Bom ([System.IO.File]::ReadAllText((Join-Path $baseDir "config\apps.json"), [System.Text.Encoding]::UTF8))
$featuresPath  = Join-Path $baseDir "config\features.json"
$featuresJson  = if (Test-Path $featuresPath) { Remove-Bom ([System.IO.File]::ReadAllText($featuresPath, [System.Text.Encoding]::UTF8)) } else { "[]" }
$tweaksPath    = Join-Path $baseDir "config\tweaks.json"
$tweaksJson    = if (Test-Path $tweaksPath) { Remove-Bom ([System.IO.File]::ReadAllText($tweaksPath, [System.Text.Encoding]::UTF8)) } else { "[]" }
$bloatwarePath = Join-Path $baseDir "config\bloatware.json"
$bloatwareJson = if (Test-Path $bloatwarePath) { Remove-Bom ([System.IO.File]::ReadAllText($bloatwarePath, [System.Text.Encoding]::UTF8)) } else { "[]" }
$xaml          = Remove-Bom ([System.IO.File]::ReadAllText((Join-Path $baseDir "xaml\input.xaml"), [System.Text.Encoding]::UTF8))
$main          = Remove-Bom ([System.IO.File]::ReadAllText((Join-Path $baseDir "scripts\main.ps1"), [System.Text.Encoding]::UTF8))

$fullScript = $header.Trim() + "`r`n`r`n" +
              "`$sync.AppsConfig = @'`r`n" + $appsJson + "`r`n'@ | ConvertFrom-Json`r`n`r`n" +
              "`$sync.FeaturesConfig = @'`r`n" + $featuresJson + "`r`n'@ | ConvertFrom-Json`r`n`r`n" +
              "`$sync.TweaksConfig = @'`r`n" + $tweaksJson + "`r`n'@ | ConvertFrom-Json`r`n`r`n" +
              "`$sync.BloatwareConfig = @'`r`n" + $bloatwareJson + "`r`n'@ | ConvertFrom-Json`r`n`r`n" +
              "`$sync.Xaml = @'`r`n" + $xaml + "`r`n'@`r`n`r`n" +
              $main + "`r`n"

[System.IO.File]::WriteAllText($outputFile, $fullScript, $asciiEnc)
Write-Host "[BASARILI] $outputFile olusturuldu!" -ForegroundColor Green

if ($Run) {
    powershell.exe -NoProfile -STA -ExecutionPolicy Bypass -File $outputFile
}
