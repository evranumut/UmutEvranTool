# --- YUKLU UYGULAMALARI TARAMA ---
$script:BtnCheckInstalled.Add_Click({
    Start-BackgroundTask (Decode-U "Yuklu uygulamalar taraniyor...") @{} {
        Refresh-InstalledAppsBg
    }
})

# --- WINGET KUR / KALDIR / GUNCELLE MOTORU ---
function Get-SelectedAppList {
    $list = @()
    foreach ($cat in $script:AppCategories) {
        foreach ($app in $cat.Apps) {
            if ($script:SelectedApps[$app.Id] -eq $true) {
                $list += [pscustomobject]@{ Name = $app.Name; Id = (Resolve-WingetId $app.Id) }
            }
        }
    }
    return $list
}

$script:BtnInstall.Add_Click({
    if (-not (Test-WingetAvailable)) { Write-UiLog $script:WingetMissingMessage; return }
    $targets = @(Get-SelectedAppList)
    if ($targets.Count -eq 0) {
        Write-UiLog (Decode-U "[!] Lutfen kurulacak en az 1 uygulama secin.")
        return
    }
    Start-BackgroundTask (Decode-U "Secilen uygulamalar kuruluyor...") @{ Apps = $targets } {
        param($p)
        $apps = @($p.Apps)
        $total = $apps.Count
        if ($total -eq 0) { Log-Bg "[!] Kurulacak uygulama bulunamadi."; return }
        $idx = 0
        $failCount = 0
        foreach ($item in $apps) {
            $idx++; $pct = [math]::Round(($idx / $total) * 90)
            Status-Bg ("Kuruluyor ($idx/$total): " + $item.Name) $pct
            Log-Bg ("[+] Kuruluyor ($idx/$total): " + $item.Name + " [" + $item.Id + "]")
            if (Test-StoreProductId $item.Id) {
                winget install --id $item.Id --source msstore --silent --accept-package-agreements --accept-source-agreements
            } else {
                winget install --id $item.Id -e --silent --accept-package-agreements --accept-source-agreements
            }
            if ($LASTEXITCODE -eq 0) {
                $sync.InstalledApps[$item.Id] = $true
                Log-Bg ("[OK] Kuruldu: " + $item.Name)
            } else {
                $failCount++
                Log-Bg ("[!] Uyari/Cikis Kodu ($LASTEXITCODE): " + $item.Name)
            }
        }
        if ($failCount -eq 0) {
            Log-Bg "[OK] Secilen tum uygulamalar kuruldu."
        } else {
            Log-Bg ("[!] Kurulum tamamlandi: $($total - $failCount) basarili, $failCount basarisiz.")
        }
        Refresh-InstalledAppsBg
    }
})

$script:BtnUninstall.Add_Click({
    if (-not (Test-WingetAvailable)) { Write-UiLog $script:WingetMissingMessage; return }
    $targets = @(Get-SelectedAppList)
    if ($targets.Count -eq 0) {
        Write-UiLog (Decode-U "[!] Lutfen kaldirilacak en az 1 uygulama secin.")
        return
    }
    Start-BackgroundTask (Decode-U "Secilen uygulamalar kaldiriliyor...") @{ Apps = $targets } {
        param($p)
        $apps = @($p.Apps)
        $total = $apps.Count
        if ($total -eq 0) { Log-Bg "[!] Kaldirilacak uygulama bulunamadi."; return }
        $idx = 0
        $failCount = 0
        foreach ($item in $apps) {
            $idx++; $pct = [math]::Round(($idx / $total) * 90)
            Status-Bg ("Kaldiriliyor ($idx/$total): " + $item.Name) $pct
            Log-Bg ("[-] Kaldiriliyor ($idx/$total): " + $item.Name + " [" + $item.Id + "]")
            if (Test-StoreProductId $item.Id) {
                winget uninstall --id $item.Id --silent --accept-source-agreements
            } else {
                winget uninstall --id $item.Id -e --silent --accept-source-agreements
            }
            if ($LASTEXITCODE -eq 0) {
                $sync.InstalledApps.Remove($item.Id)
                Log-Bg ("[OK] Kaldirildi: " + $item.Name)
            } else {
                $failCount++
                Log-Bg ("[!] Kaldirilamadi (Cikis Kodu: $LASTEXITCODE): " + $item.Name)
            }
        }
        if ($failCount -eq 0) {
            Log-Bg "[OK] Secilen uygulamalar kaldirildi."
        } else {
            Log-Bg ("[!] Kaldirma tamamlandi: $($total - $failCount) basarili, $failCount basarisiz.")
        }
        Refresh-InstalledAppsBg
    }
})

$script:BtnUpgradeSelected.Add_Click({
    if (-not (Test-WingetAvailable)) { Write-UiLog $script:WingetMissingMessage; return }
    $targets = @(Get-SelectedAppList)
    if ($targets.Count -eq 0) {
        Write-UiLog (Decode-U "[!] Lutfen guncellenecek en az 1 uygulama secin.")
        return
    }
    Start-BackgroundTask (Decode-U "Secilen uygulamalar guncelleniyor...") @{ Apps = $targets } {
        param($p)
        $apps = @($p.Apps)
        $total = $apps.Count
        if ($total -eq 0) { Log-Bg "[!] Guncellenecek uygulama bulunamadi."; return }
        $idx = 0
        $okCount = 0
        $uptodateCount = 0
        $failCount = 0
        foreach ($item in $apps) {
            $idx++; $pct = [math]::Round(($idx / $total) * 90)
            Status-Bg ("Guncelleniyor ($idx/$total): " + $item.Name) $pct
            Log-Bg ("[^] Guncelleniyor: " + $item.Name)
            if (Test-StoreProductId $item.Id) {
                winget upgrade --id $item.Id --source msstore --silent --accept-package-agreements --accept-source-agreements
            } else {
                winget upgrade --id $item.Id -e --silent --accept-package-agreements --accept-source-agreements
            }
            $code = $LASTEXITCODE
            if ($code -eq 0) {
                $okCount++
                Log-Bg ("[OK] Guncellendi: " + $item.Name)
            } elseif ($code -eq -1978335189) {
                # 0x8A15002B = APPINSTALLER_CLI_ERROR_UPDATE_NOT_APPLICABLE (zaten guncel)
                $uptodateCount++
                Log-Bg ("[i] Zaten guncel: " + $item.Name)
            } else {
                $failCount++
                Log-Bg ("[!] Guncellenemedi (Cikis Kodu: $code): " + $item.Name)
            }
        }
        if ($failCount -eq 0) {
            Log-Bg ("[OK] Guncelleme tamamlandi: $okCount guncellendi, $uptodateCount zaten guncel.")
        } else {
            Log-Bg ("[!] Guncelleme tamamlandi: $okCount guncellendi, $uptodateCount zaten guncel, $failCount basarisiz.")
        }
        Refresh-InstalledAppsBg
    }
})

$script:BtnUpgradeAll.Add_Click({
    if (-not (Test-WingetAvailable)) { Write-UiLog $script:WingetMissingMessage; return }
    Start-BackgroundTask (Decode-U "Tum sistem uygulamalari guncelleniyor...") @{} {
        Log-Bg "[*] Winget Upgrade --all baslatildi..."
        winget upgrade --all --include-unknown --silent --accept-package-agreements --accept-source-agreements
        $code = $LASTEXITCODE
        if ($code -eq 0) {
            Log-Bg "[OK] Tum guncellemeler tamamlandi."
        } elseif ($code -eq -1978335189) {
            Log-Bg "[i] Guncellenecek uygulama bulunamadi (tum paketler zaten guncel)."
        } else {
            Log-Bg ("[!] Guncelleme tamamlandi ancak bazi paketler basarisiz oldu (Cikis Kodu: $code).")
        }
        Refresh-InstalledAppsBg
    }
})