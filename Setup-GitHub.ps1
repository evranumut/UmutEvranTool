# =============================================================================
# UMUT EVRAN TOOL - SIFIRDAN GITHUB KURULUM VE BAGLANTI ARACI
# =============================================================================
$ErrorActionPreference = "Continue"
Set-Location -Path $PSScriptRoot

Clear-Host
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "       UMUT EVRAN TOOL - SIFIRDAN GITHUB ENTEGRASYONU     " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# 1. Git yuklu mu kontrol et
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "`n[!] Git sisteminizde yuklu degil!" -ForegroundColor Red
    Write-Host "[+] Winget ile Git kuruluyor, lutfen bekleyin..." -ForegroundColor Yellow
    winget install --id Git.Git -e --silent --accept-package-agreements --accept-source-agreements
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}

# 2. Repo Linkini Al
Write-Host "`nGitHub'da olusturdugunuz Public repo linkini yapistirin:" -ForegroundColor White
Write-Host "Ornek: https://github.com/kullaniciadi/UmutEvranTool.git" -ForegroundColor DarkGray
$repoUrl = Read-Host "Repo URL"

if ([string]::IsNullOrWhiteSpace($repoUrl)) {
    Write-Host "[HATA] Gecerli bir repo URL'si girmediniz!" -ForegroundColor Red
    pause
    exit 1
}

# 3. Once compile.ps1 calistirarak guncel UmutEvranTools.ps1 olustur
Write-Host "`n[1/5] Proje dosyalari derleniyor..." -ForegroundColor Cyan
if (Test-Path "$PSScriptRoot\compile.ps1") {
    powershell.exe -NoProfile -STA -ExecutionPolicy Bypass -File "$PSScriptRoot\compile.ps1"
}

# 4. Git yapilandirmasini sifirla ve ilklendir
Write-Host "`n[2/5] Git reposu sifirdan olusturuluyor..." -ForegroundColor Cyan
if (Test-Path "$PSScriptRoot\.git") {
    Remove-Item -Path "$PSScriptRoot\.git" -Recurse -Force -ErrorAction SilentlyContinue
}

git init
git branch -M main

# 5. Remote baglantisini ekle
Write-Host "[3/5] GitHub baglantisi ayarlaniyor..." -ForegroundColor Cyan
git remote add origin $repoUrl.Trim()

# 6. Dosyalari ekle ve commit yap
Write-Host "[4/5] Dosyalar paketleniyor..." -ForegroundColor Cyan
git add .
git commit -m "Initial commit - UmutEvranTool v3.0"

# 7. GitHub'a Gonder
Write-Host "[5/5] GitHub'a yukleniyor (Gerekirse tarayicida giris ekrani acilacaktir)..." -ForegroundColor Yellow
git push -u origin main --force

if ($LASTEXITCODE -eq 0) {
    # Raw URL'yi otomatik hesapla
    $cleanUrl = $repoUrl.Trim().Replace(".git", "")
    $rawUrl = $cleanUrl.Replace("github.com", "raw.githubusercontent.com") + "/main/UmutEvranTools.ps1"

    Write-Host "`n==========================================================" -ForegroundColor Green
    Write-Host "   TEBRIKLER! GITHUB ENTEGRASYONU BASARIYLA TAMAMLANDI   " -ForegroundColor Green
    Write-Host "==========================================================" -ForegroundColor Green
    Write-Host "`nDosyanizin dogrudan calisma linki (Raw URL):" -ForegroundColor White
    Write-Host $rawUrl -ForegroundColor Cyan

    Write-Host "`nSimdi yapilacak son adim:" -ForegroundColor Yellow
    Write-Host "1) tinyurl.com adresine girin." -ForegroundColor White
    Write-Host "2) 'Enter a long URL to make tiny' kismina yukaridaki Raw linkini yapistirin." -ForegroundColor White
    Write-Host "3) Kisa link olarak 'evrantool' belirleyin." -ForegroundColor White
    Write-Host "4) Artik 'irm tinyurl.com/evrantool | iex' komutunuz calisacaktir!" -ForegroundColor Green
} else {
    Write-Host "`n[!] GitHub'a yukleme basarisiz oldu. Lutfen repo linkini ve internet baglantinizi kontrol edin." -ForegroundColor Red
}

pause