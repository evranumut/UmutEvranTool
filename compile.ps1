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

Write-Host "[+] Petra OmniTool v4.0 (Post-Install & Script Engine + AIO Lisans Motoru) derleniyor..." -ForegroundColor Cyan

$header = @'
# =============================================================================
# PETRA OMNITOOL (TEK DOSYA / UZAKTAN CALISTIRMA SURUMU)
# Post-Install & Script Engine v4.0
# Komut: irm tinyurl.com/evrantool | iex (veya irm evrantool.evranumut.workers.dev | iex)
# Mimari: 100% Pure ASCII + Decode-U + WPF XamlReader + Runspace Multithreading
# =============================================================================
$ErrorActionPreference = 'Continue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
$isSta   = ([System.Threading.Thread]::CurrentThread.GetApartmentState() -eq 'STA')

if ((-not $isAdmin) -or (-not $isSta)) {
    $tempRunner = Join-Path $env:TEMP "PetraOmniTool_Runtime.ps1"
    # Once iex ile gelen gomulu betik metnini kullan (yanlis dosya kopyalanmasin),
    # sonra -File ile calistirilan gercek betik yolunu, en son uzaktan indirmeyi dene.
    if ($MyInvocation.MyCommand.Definition -and ($MyInvocation.MyCommand.Definition.Length -gt 200)) {
        [System.IO.File]::WriteAllText($tempRunner, $MyInvocation.MyCommand.Definition, (New-Object System.Text.UTF8Encoding($false)))
    } elseif ($PSCommandPath -and (Test-Path $PSCommandPath)) {
        Copy-Item -Path $PSCommandPath -Destination $tempRunner -Force
    } else {
        Invoke-RestMethod -Uri "https://evrantool.evranumut.workers.dev" -OutFile $tempRunner
    }
    $argList = "-NoProfile -STA -ExecutionPolicy Bypass -File `"$tempRunner`""
    if ($args.Count -gt 0) {
        $escapedArgs = $args | ForEach-Object { "`"$_`"" }
        $argList += " " + ($escapedArgs -join " ")
    }
    try {
        Start-Process powershell.exe -ArgumentList $argList -Verb RunAs -ErrorAction Stop
    } catch {
        Write-Host "[HATA] Yonetici olarak yeniden baslatilamadi: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "[i] PowerShell'i 'Yonetici olarak calistir' secenegiyle acip tekrar deneyin." -ForegroundColor Yellow
    }
    return
}

$sync = [Hashtable]::Synchronized(@{})
$sync.IsAdmin = $isAdmin
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

# 5. mas.aio.cmd (Ozel AIO Lisans Araci) Okuma
$masCmdPath = Join-Path $baseDir "scripts\mas.aio.cmd"
if (!(Test-Path $masCmdPath)) {
    throw "Dosya bulunamadi: $masCmdPath (scripts\mas.aio.cmd dosya adini kontrol edin)"
}
$rawMas = Clean-SourceText ([System.IO.File]::ReadAllText($masCmdPath, [System.Text.Encoding]::UTF8))
[System.IO.File]::WriteAllText($masCmdPath, $rawMas, $utf8NoBom)
$masCmdAscii = ConvertTo-AsciiUnicodeEscape $rawMas
if ($masCmdAscii.Length -lt 100) {
    throw "mas.aio.cmd okunamadi veya bos gorunuyor ($masCmdPath)."
}

# 5b. Uygulama Logosu (assets\logo.ico -> base64 gomulu, tek dosya dagitimi korunur)
$logoPath = Join-Path $baseDir "assets\logo.ico"
$logoB64 = ""
if (Test-Path $logoPath) {
    $logoBytes = [System.IO.File]::ReadAllBytes($logoPath)
    if ($logoBytes.Length -lt 100 -or $logoBytes[0] -ne 0 -or $logoBytes[1] -ne 0 -or $logoBytes[2] -ne 1 -or $logoBytes[3] -ne 0) {
        throw "assets\logo.ico gecersiz ICO dosyasi."
    }
    $logoB64 = [Convert]::ToBase64String($logoBytes)
    Write-Host "[+] Logo gomuluyor: $([math]::Round($logoBytes.Length / 1KB, 1)) KB ICO" -ForegroundColor DarkGray
} else {
    Write-Host "[!] assets\logo.ico bulunamadi; uygulama varsayilan simge ile derleniyor." -ForegroundColor Yellow
}

# 6. input.xaml ve modul listesi (scripts/modules.psd1)
$xamlPath = Join-Path $baseDir "xaml\input.xaml"
$manifestPath = Join-Path $baseDir "scripts\modules.psd1"
if (!(Test-Path $xamlPath)) { throw "Dosya bulunamadi: $xamlPath" }
if (!(Test-Path $manifestPath)) { throw "Dosya bulunamadi: $manifestPath" }

$rawXaml = Clean-SourceText ([System.IO.File]::ReadAllText($xamlPath, [System.Text.Encoding]::UTF8))
[System.IO.File]::WriteAllText($xamlPath, $rawXaml, $utf8NoBom)

$manifest = Import-PowerShellDataFile -Path $manifestPath
if (-not $manifest -or -not $manifest.Order -or $manifest.Order.Count -eq 0) {
    throw "scripts\modules.psd1 icinde Order listesi bos veya gecersiz."
}
$seenModules = @{}
$moduleParts = New-Object System.Collections.Generic.List[string]
$badIfLines = New-Object System.Collections.Generic.List[string]
$moduleBytes = 0

foreach ($rel in $manifest.Order) {
    if ($seenModules.ContainsKey($rel)) { throw "scripts\modules.psd1 icinde tekrarlanan modul: $rel" }
    $seenModules[$rel] = $true
    $modulePath = Join-Path (Join-Path $baseDir "scripts") $rel
    if (!(Test-Path $modulePath)) { throw "Modul bulunamadi: $modulePath" }

    $rawModule = Clean-SourceText ([System.IO.File]::ReadAllText($modulePath, [System.Text.Encoding]::UTF8))
    [System.IO.File]::WriteAllText($modulePath, $rawModule, $utf8NoBom)
    $moduleBytes += [System.Text.Encoding]::UTF8.GetByteCount($rawModule)

    $lineNo = 0
    foreach ($line in ($rawModule -split "\r?\n")) {
        $lineNo++
        if ($line -match '(?<!\$)\(if\s+\(') { $badIfLines.Add("$rel : satir $lineNo") }
    }
    $moduleParts.Add($rawModule)
}
$rawMain = $moduleParts -join "`r`n`r`n"

# 6b. Bilinen sozdizimi tuzagi: (if ...) gecersizdir; $(if ...) olmalidir.
if ($badIfLines.Count -gt 0) {
    Write-Host "[HATA] Modullerde gecersiz '(if ...)' ifadesi bulundu. '`$(if ...)' kullanin:" -ForegroundColor Red
    foreach ($n in $badIfLines) { Write-Host (" -> {0}" -f $n) -ForegroundColor Yellow }
    exit 1
}
Write-Host ("[+] Moduller: {0} dosya, {1} KB" -f $manifest.Order.Count, [math]::Round($moduleBytes / 1KB, 1)) -ForegroundColor DarkGray

# 6c. XAML sozdizimi dogrulamasi (bozuk arayuz yayinlanmasini engeller)
try {
    Add-Type -AssemblyName PresentationFramework -ErrorAction Stop
    [void][System.Windows.Markup.XamlReader]::Parse($rawXaml)
} catch {
    Write-Host "[HATA] xaml\input.xaml ayristirilamadi: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

$xaml = ConvertTo-AsciiXaml $rawXaml
$main = ConvertTo-AsciiUnicodeEscape $rawMain

# 7. Tek Dosya Birlestirme
$fullScript = (Clean-SourceText $header) + "`r`n`r`n" +
    "`$sync.AppsConfig = @'`r`n" + $appsJson + "`r`n'@ | ConvertFrom-Json`r`n`r`n" +
    "`$sync.FeaturesConfig = @'`r`n" + $featuresJson + "`r`n'@ | ConvertFrom-Json`r`n`r`n" +
    "`$sync.TweaksConfig = @'`r`n" + $tweaksJson + "`r`n'@ | ConvertFrom-Json`r`n`r`n" +
    "`$sync.BloatwareConfig = @'`r`n" + $bloatwareJson + "`r`n'@ | ConvertFrom-Json`r`n`r`n" +
    "`$sync.MasScript = @'`r`n" + $masCmdAscii + "`r`n'@`r`n`r`n" +
    "`$sync.LogoBase64 = '" + $logoB64 + "'`r`n`r`n" +
    "`$sync.Xaml = @'`r`n" + $xaml + "`r`n'@`r`n`r`n" +
    $main + "`r`n"

$tempOutput = "$outputFile.tmp"
[System.IO.File]::WriteAllText($tempOutput, $fullScript, $asciiEnc)

# 8. AST Sozdizimi (Syntax) Dogrulamasi
$tokens = $null
$parseErrors = $null
[void][System.Management.Automation.Language.Parser]::ParseFile($tempOutput, [ref]$tokens, [ref]$parseErrors)
if ($parseErrors -and $parseErrors.Count -gt 0) {
    Write-Host "[HATA] Derlenen dosyada PowerShell sozdizimi hatasi tespit edildi:" -ForegroundColor Red
    foreach ($err in $parseErrors) {
        Write-Host (" -> Satir {0}: {1}" -f $err.Extent.StartLineNumber, $err.Message) -ForegroundColor Yellow
    }
    Remove-Item -Path $tempOutput -Force -ErrorAction SilentlyContinue
    exit 1
}

# 9. Dogrulanmis ciktiyi atomik olarak yayinla (eski calisan surum bozulmaz)
Move-Item -Path $tempOutput -Destination $outputFile -Force

$fileSizeKb = [math]::Round((Get-Item $outputFile).Length / 1KB, 1)
Write-Host "[BASARILI] $outputFile olusturuldu! ($fileSizeKb KB | 100% Pure ASCII & AST Dogrulandi)" -ForegroundColor Green

if ($Run) {
    $runArgs = @("-NoProfile", "-STA", "-ExecutionPolicy", "Bypass", "-File", $outputFile)
    if (-not [string]::IsNullOrWhiteSpace($Preset)) {
        $runArgs += $Preset
    }
    powershell.exe @runArgs
}