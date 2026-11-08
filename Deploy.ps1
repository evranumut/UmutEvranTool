$ErrorActionPreference = "Stop"
Set-Location -Path $PSScriptRoot

function Fail([string]$message) {
    Write-Host "`n[HATA] $message" -ForegroundColor Red
    Read-Host "Kapatmak icin Enter'a basin"
    exit 1
}

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Fail "git bulunamadi. Git'i kurup tekrar deneyin: https://git-scm.com/download/win"
}

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host " 1. UmutEvranTools.ps1 Derleniyor...     " -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

powershell.exe -NoProfile -STA -ExecutionPolicy Bypass -File "$PSScriptRoot\compile.ps1"
if ($LASTEXITCODE -ne 0) {
    Fail "Derleme basarisiz oldu (exit code: $LASTEXITCODE). Eski surum korunuyor, GitHub'a hicbir sey yuklenmedi."
}

$outputFile = Join-Path $PSScriptRoot "UmutEvranTools.ps1"
if (!(Test-Path $outputFile)) {
    Fail "Derleme ciktisi bulunamadi: $outputFile"
}

$outputSize = (Get-Item $outputFile).Length
if ($outputSize -lt 100KB) {
    Fail "Derleme ciktisi beklenenden kucuk ($([math]::Round($outputSize / 1KB, 1)) KB). Yayin iptal edildi."
}

$nonAscii = 0
$bytes = [System.IO.File]::ReadAllBytes($outputFile)
foreach ($b in $bytes) { if ($b -gt 127) { $nonAscii++ } }
if ($nonAscii -gt 0) {
    Fail "Derleme ciktisi %100 ASCII degil ($nonAscii adet ASCII disi bayt). Yayin iptal edildi."
}

Write-Host "`n[OK] Cikti dogrulandi: $([math]::Round($outputSize / 1KB, 1)) KB, 100% ASCII" -ForegroundColor Green

Write-Host "`n=========================================" -ForegroundColor Yellow
Write-Host " 2. Arayuz Test Icin Aciliyor...         " -ForegroundColor Yellow
Write-Host "=========================================" -ForegroundColor Yellow

$testProcess = Start-Process powershell.exe -ArgumentList "-NoProfile -STA -ExecutionPolicy Bypass -File `"$outputFile`"" -PassThru

Write-Host "`nArayuzu kontrol edin. Test basariliysa devam edebilirsiniz." -ForegroundColor Yellow
$answer = Read-Host "Arayuz testi basarili mi? (E/H)"
if ($answer -notmatch '^(e|evet|y|yes)$') {
    Write-Host "`n[IPTAL] Test onaylanmadi. GitHub'a hicbir sey yuklenmedi." -ForegroundColor Yellow
    Read-Host "Kapatmak icin Enter'a basin"
    exit 1
}

# Test penceresini nazikce kapat (kapanmazsa zorla)
try {
    if (!$testProcess.HasExited) {
        [void]$testProcess.CloseMainWindow()
        if (!$testProcess.WaitForExit(4000)) { Stop-Process -Id $testProcess.Id -Force -ErrorAction SilentlyContinue }
    }
} catch {
    # Pencere zaten kapanmis olabilir; devam et.
}

Write-Host "`n=========================================" -ForegroundColor Cyan
Write-Host " 3. GitHub'a Yukleniyor (Git Push)...    " -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

git add .
if ($LASTEXITCODE -ne 0) {
    Fail "git add basarisiz oldu (exit code: $LASTEXITCODE)."
}

$pending = git status --porcelain
if ($LASTEXITCODE -ne 0) {
    Fail "git status basarisiz oldu (exit code: $LASTEXITCODE)."
}

if ([string]::IsNullOrWhiteSpace($pending)) {
    Write-Host "[i] Commit edilecek degisiklik yok; mevcut commit'ler gonderilecek." -ForegroundColor Yellow
} else {
    git commit -m "Petra OmniTool v4.0 Post-Install & Script Engine + DNS + DISM + CS2 Ping Tweaks ($(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'))"
    if ($LASTEXITCODE -ne 0) {
        Fail "git commit basarisiz oldu (exit code: $LASTEXITCODE)."
    }
}

git push origin main
if ($LASTEXITCODE -ne 0) {
    Fail "git push basarisiz oldu (exit code: $LASTEXITCODE). Uzak depo guncellenmedi."
}

Write-Host "`n[OK] Islem tamamlandi! 'irm evrantool.evranumut.workers.dev | iex' komutu aninda guncellendi." -ForegroundColor Green
Write-Host "[i] worker.js degistiyse Cloudflare Worker'i 'npx wrangler deploy' ile ayrica guncelleyin." -ForegroundColor DarkGray
Read-Host "Kapatmak icin Enter'a basin"
