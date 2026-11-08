# =============================================================================
# PETRA OMNITOOL - SIFIRDAN GITHUB KURULUM VE BAGLANTI ARACI
# =============================================================================
$ErrorActionPreference = "Continue"
Set-Location -Path $PSScriptRoot

function Fail([string]$message) {
    Write-Host "`n[HATA] $message" -ForegroundColor Red
    pause
    exit 1
}

Clear-Host
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "       PETRA OMNITOOL - SIFIRDAN GITHUB ENTEGRASYONU      " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# 1. Git yuklu mu kontrol et
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "`n[!] Git sisteminizde yuklu degil!" -ForegroundColor Red
    Write-Host "[+] Winget ile Git kuruluyor, lutfen bekleyin..." -ForegroundColor Yellow
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Fail "winget bulunamadi. Once Git'i https://git-scm.com/download/win adresinden kurun."
    }
    winget install --id Git.Git -e --silent --accept-package-agreements --accept-source-agreements
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Fail "Git kurulumu tamamlanamadi. Konsolu kapatip yeniden acin ve tekrar deneyin."
    }
}

# 2. Repo Linkini Al
Write-Host "`nGitHub'da olusturdugunuz Public repo linkini yapistirin:" -ForegroundColor White
Write-Host "Ornek: https://github.com/kullaniciadi/UmutEvranTool.git" -ForegroundColor DarkGray
$repoUrl = (Read-Host "Repo URL").Trim()

if ([string]::IsNullOrWhiteSpace($repoUrl)) {
    Fail "Gecerli bir repo URL'si girmediniz."
}
if ($repoUrl -notmatch '^https://github\.com/[^/]+/[^/]+?(\.git)?$') {
    Fail "Gecersiz GitHub URL'si. Ornek: https://github.com/kullaniciadi/UmutEvranTool.git"
}

# 3. Once compile.ps1 calistirarak guncel UmutEvranTools.ps1 olustur
Write-Host "`n[1/5] Proje dosyalari derleniyor..." -ForegroundColor Cyan
if (!(Test-Path "$PSScriptRoot\compile.ps1")) {
    Fail "compile.ps1 bulunamadi."
}
powershell.exe -NoProfile -STA -ExecutionPolicy Bypass -File "$PSScriptRoot\compile.ps1"
if ($LASTEXITCODE -ne 0) {
    Fail "Derleme basarisiz oldu (exit code: $LASTEXITCODE). GitHub'a hicbir sey yuklenmedi."
}

# 4. Git yapilandirmasini sifirla ve ilklendir
Write-Host "`n[2/5] Git reposu sifirdan olusturuluyor..." -ForegroundColor Cyan
if (Test-Path "$PSScriptRoot\.git") {
    Write-Host "[!] Mevcut .git klasoru ve tum yerel commit gecmisi SILINECEK." -ForegroundColor Yellow
    $confirm = Read-Host "Devam etmek istiyor musunuz? (E/H)"
    if ($confirm -notmatch '^(e|evet|y|yes)$') {
        Write-Host "[IPTAL] Islem iptal edildi; mevcut git gecmisi korundu." -ForegroundColor Yellow
        pause
        exit 0
    }
    Remove-Item -Path "$PSScriptRoot\.git" -Recurse -Force
    if ($?) {
        Write-Host "[i] Eski .git klasoru silindi." -ForegroundColor DarkGray
    } else {
        Fail "Eski .git klasoru silinemedi. Dosyalari kapatip tekrar deneyin."
    }
}

git init
if ($LASTEXITCODE -ne 0) { Fail "git init basarisiz oldu." }
git branch -M main
if ($LASTEXITCODE -ne 0) { Fail "git branch -M main basarisiz oldu." }

# 5. Remote baglantisini ekle
Write-Host "[3/5] GitHub baglantisi ayarlaniyor..." -ForegroundColor Cyan
git remote add origin $repoUrl
if ($LASTEXITCODE -ne 0) { Fail "git remote add basarisiz oldu. URL'yi kontrol edin." }

# Commit icin kimlik yoksa yerel olarak ayarla
$gitName  = (git config user.name) 2>$null
$gitEmail = (git config user.email) 2>$null
if ([string]::IsNullOrWhiteSpace($gitName) -or [string]::IsNullOrWhiteSpace($gitEmail)) {
    Write-Host "[i] Git kullanici kimligi eksik; bu depo icin ayarlanacak." -ForegroundColor Yellow
    $gitName  = Read-Host "Adiniz"
    $gitEmail = Read-Host "E-posta adresiniz"
    if ([string]::IsNullOrWhiteSpace($gitName) -or [string]::IsNullOrWhiteSpace($gitEmail)) {
        Fail "Git kimligi bos olamaz."
    }
    git config user.name $gitName
    git config user.email $gitEmail
}

# 6. Dosyalari ekle ve commit yap
Write-Host "[4/5] Dosyalar paketleniyor..." -ForegroundColor Cyan
git add .
if ($LASTEXITCODE -ne 0) { Fail "git add basarisiz oldu." }

git commit -m "Initial commit - Petra OmniTool v4.0"
if ($LASTEXITCODE -ne 0) { Fail "git commit basarisiz oldu." }

# 7. GitHub'a Gonder
Write-Host "[5/5] GitHub'a yukleniyor (Gerekirse tarayicida giris ekrani acilacaktir)..." -ForegroundColor Yellow
Write-Host "[!] Remote depodaki mevcut gecmis bu islemle ezilecek (--force)." -ForegroundColor Yellow
$confirmPush = Read-Host "Devam etmek istiyor musunuz? (E/H)"
if ($confirmPush -notmatch '^(e|evet|y|yes)$') {
    Write-Host "[IPTAL] Push iptal edildi. Yerel commit olusturuldu." -ForegroundColor Yellow
    pause
    exit 0
}

git push -u origin main --force
if ($LASTEXITCODE -ne 0) {
    Fail "GitHub'a yukleme basarisiz oldu. Repo linkini ve internet baglantinizi kontrol edin."
}

$cleanUrl = $repoUrl.Replace(".git", "")
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

pause
