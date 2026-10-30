$ErrorActionPreference = "Continue"
Set-Location -Path $PSScriptRoot

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host " 1. UmutEvranTools.ps1 Derleniyor...     " -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

powershell.exe -NoProfile -STA -ExecutionPolicy Bypass -File "$PSScriptRoot\compile.ps1"

Write-Host "`n=========================================" -ForegroundColor Yellow
Write-Host " 2. Arayuz Test Icin Aciliyor...         " -ForegroundColor Yellow
Write-Host "=========================================" -ForegroundColor Yellow

Start-Process powershell.exe -ArgumentList "-NoProfile -STA -ExecutionPolicy Bypass -File `"$PSScriptRoot\UmutEvranTools.ps1`""

Write-Host "`n=========================================" -ForegroundColor Cyan
Write-Host " 3. GitHub'a Yukleniyor (Git Push)...    " -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

git add .
git commit -m "UmutEvranTool v3.0 WinUtil Edition + DNS + DISM + CS2 Ping Tweaks ($(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'))"
git push origin main

Write-Host "`n[OK] Islem tamamlandi! 'irm evrantool.evranumut.workers.dev | iex' komutu aninda guncellendi." -ForegroundColor Green
Read-Host "Kapatmak icin Enter'a basin"
