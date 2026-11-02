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
$asciiEnc   = [System.Text.Encoding]::ASCII
$utf8NoBom  = New-Object System.Text.UTF8Encoding($false)

function Clean-SourceText([string]$t) {
    if ([string]::IsNullOrEmpty($t)) { return "" }
    $clean = $t.Replace([string][char]0xFEFF, "").Replace([string][char]0x200B, "").Replace([char]0x00A0, [char]0x0020)
    $clean = $clean -replace "\r?\n", "`r`n"
    return $clean.Trim()
}

function ConvertTo-AsciiUnicodeEscape([string]$text) {
    if ([string]::IsNullOrEmpty($text)) { return "" }
    $sb = New-Object System.Text.StringBuilder($text.Length)
    for ($i = 0; $i -lt $text.Length; $i++) {
        $ch = $text[$i]
        $code = [int][char]$ch
        if ($code -eq 0x00A0) {
            [void]$sb.Append(' ')
        } elseif ($code -gt 127) {
            [void]$sb.AppendFormat("\u{0:x4}", $code)
        } else {
            [void]$sb.Append($ch)
        }
    }
    return $sb.ToString()
}

function ConvertTo-AsciiXaml([string]$text) {
    if ([string]::IsNullOrEmpty($text)) { return "" }
    $sb = New-Object System.Text.StringBuilder($text.Length)
    for ($i = 0; $i -lt $text.Length; $i++) {
        $ch = $text[$i]
        $code = [int][char]$ch
        if ($code -eq 0x00A0) {
            [void]$sb.Append(' ')
        } elseif ([char]::IsHighSurrogate($ch) -and ($i + 1 -lt $text.Length) -and [char]::IsLowSurrogate($text[$i + 1])) {
            $codePoint = [char]::ConvertToUtf32($ch, $text[$i + 1])
            [void]$sb.AppendFormat("&#x{0:X};", $codePoint)
            $i++
        } elseif ($code -gt 127) {
            [void]$sb.AppendFormat("&#x{0:X4};", $code)
        } else {
            [void]$sb.Append($ch)
        }
    }
    return $sb.ToString()
}

Write-Host "[+] UmutEvranTools.ps1 v4.0 (Windows 11 Fluent Edition + AIO Lisans Motoru) derleniyor..." -ForegroundColor Cyan

$header = @'
# =============================================================================
# UMUT EVRAN TOOL (TEK DOSYA / UZAKTAN CALISTIRMA SURUMU)
# Komut: irm tinyurl.com/evrantool | iex (veya irm evrantool.evranumut.workers.dev | iex)
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
        [System.IO.File]::WriteAllText($tempRunner, $MyInvocation.MyCommand.Definition, (New-Object System.Text.UTF8Encoding($false)))
    } else {
        Invoke-RestMethod -Uri "https://evrantool.evranumut.workers.dev" -OutFile $tempRunner
    }
    $argList = "-NoProfile -STA -ExecutionPolicy Bypass -File `"$tempRunner`""
    if ($args.Count -gt 0) {
        $escapedArgs = $args | ForEach-Object { "`"$_`"" }
        $argList += " " + ($escapedArgs -join " ")
    }
    Start-Process powershell.exe -ArgumentList $argList -Verb RunAs
    return
}

$sync = [Hashtable]::Synchronized(@{})
'@

# 1. apps.json Okuma
$appsPath = Join-Path $baseDir "config\apps.json"
if (!(Test-Path $appsPath)) { throw "Dosya bulunamadi: $appsPath" }
$rawApps = Clean-SourceText ([System.IO.File]::ReadAllText($appsPath, [System.Text.Encoding]::UTF8))
$kirilShader = [string]([char]0x0448 + [char]0x0435 + [char]0x0439 + "der")
$rawApps = $rawApps.Replace($kirilShader, "shader")
[System.IO.File]::WriteAllText($appsPath, $rawApps, $utf8NoBom)
$appsJson = ConvertTo-AsciiUnicodeEscape $rawApps

# 2. features.json Okuma
$featuresPath = Join-Path $baseDir "config\features.json"
$featuresJson = if (Test-Path $featuresPath) {
    $rawFeat = Clean-SourceText ([System.IO.File]::ReadAllText($featuresPath, [System.Text.Encoding]::UTF8))
    [System.IO.File]::WriteAllText($featuresPath, $rawFeat, $utf8NoBom)
    ConvertTo-AsciiUnicodeEscape $rawFeat
} else { "[]" }

# 3. tweaks.json Okuma
$tweaksPath = Join-Path $baseDir "config\tweaks.json"
$tweaksJson = if (Test-Path $tweaksPath) {
    $rawTwk = Clean-SourceText ([System.IO.File]::ReadAllText($tweaksPath, [System.Text.Encoding]::UTF8))
    [System.IO.File]::WriteAllText($tweaksPath, $rawTwk, $utf8NoBom)
    ConvertTo-AsciiUnicodeEscape $rawTwk
} else { "[]" }

# 4. bloatware.json Okuma
$bloatwarePath = Join-Path $baseDir "config\bloatware.json"
$bloatwareJson = if (Test-Path $bloatwarePath) {
    $rawBloat = Clean-SourceText ([System.IO.File]::ReadAllText($bloatwarePath, [System.Text.Encoding]::UTF8))
    [System.IO.File]::WriteAllText($bloatwarePath, $rawBloat, $utf8NoBom)
    ConvertTo-AsciiUnicodeEscape $rawBloat
} else { "[]" }

# 5. mas_aio.cmd (Ozel AIO Lisans Araci) Okuma
$masCmdPath = Join-Path $baseDir "scripts\mas_aio.cmd"
$masCmdAscii = if (Test-Path $masCmdPath) {
    $rawMas = Clean-SourceText ([System.IO.File]::ReadAllText($masCmdPath, [System.Text.Encoding]::UTF8))
    [System.IO.File]::WriteAllText($masCmdPath, $rawMas, $utf8NoBom)
    ConvertTo-AsciiUnicodeEscape $rawMas
} else { "" }

# 6. input.xaml ve main.ps1 Okuma
$xamlPath = Join-Path $baseDir "xaml\input.xaml"
$mainPath = Join-Path $baseDir "scripts\main.ps1"
if (!(Test-Path $xamlPath)) { throw "Dosya bulunamadi: $xamlPath" }
if (!(Test-Path $mainPath)) { throw "Dosya bulunamadi: $mainPath" }

$rawXaml = Clean-SourceText ([System.IO.File]::ReadAllText($xamlPath, [System.Text.Encoding]::UTF8))
$rawMain = Clean-SourceText ([System.IO.File]::ReadAllText($mainPath, [System.Text.Encoding]::UTF8))
[System.IO.File]::WriteAllText($xamlPath, $rawXaml, $utf8NoBom)
[System.IO.File]::WriteAllText($mainPath, $rawMain, $utf8NoBom)

$xaml = ConvertTo-AsciiXaml $rawXaml
$main = ConvertTo-AsciiUnicodeEscape $rawMain

# 7. Tek Dosya Birlestirme
$fullScript = (Clean-SourceText $header) + "`r`n`r`n" +
    "`$sync.AppsConfig = @'`r`n" + $appsJson + "`r`n'@ | ConvertFrom-Json`r`n`r`n" +
    "`$sync.FeaturesConfig = @'`r`n" + $featuresJson + "`r`n'@ | ConvertFrom-Json`r`n`r`n" +
    "`$sync.TweaksConfig = @'`r`n" + $tweaksJson + "`r`n'@ | ConvertFrom-Json`r`n`r`n" +
    "`$sync.BloatwareConfig = @'`r`n" + $bloatwareJson + "`r`n'@ | ConvertFrom-Json`r`n`r`n" +
    "`$sync.MasScript = @'`r`n" + $masCmdAscii + "`r`n'@`r`n`r`n" +
    "`$sync.Xaml = @'`r`n" + $xaml + "`r`n'@`r`n`r`n" +
    $main + "`r`n"

[System.IO.File]::WriteAllText($outputFile, $fullScript, $asciiEnc)

# 8. AST Sozdizimi (Syntax) Dogrulamasi
$tokens = $null
$parseErrors = $null
[void][System.Management.Automation.Language.Parser]::ParseFile($outputFile, [ref]$tokens, [ref]$parseErrors)
if ($parseErrors -and $parseErrors.Count -gt 0) {
    Write-Host "[HATA] Derlenen dosyada PowerShell sozdizimi hatasi tespit edildi:" -ForegroundColor Red
    foreach ($err in $parseErrors) {
        Write-Host (" -> Satir {0}: {1}" -f $err.Extent.StartLineNumber, $err.Message) -ForegroundColor Yellow
    }
    exit 1
}

$fileSizeKb = [math]::Round((Get-Item $outputFile).Length / 1KB, 1)
Write-Host "[BASARILI] $outputFile olusturuldu! ($fileSizeKb KB | 100% Pure ASCII & AST Dogrulandi)" -ForegroundColor Green

if ($Run) {
    $runArgs = @("-NoProfile", "-STA", "-ExecutionPolicy", "Bypass", "-File", $outputFile)
    if (-not [string]::IsNullOrWhiteSpace($Preset)) {
        $runArgs += $Preset
    }
    powershell.exe @runArgs
}