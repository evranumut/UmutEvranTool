# --- SEKME 5: SISTEM ARACLARI, ONARIM & PETRA LISANS ARACI ---
$script:BtnRestorePoint.Add_Click({
    Start-BackgroundTask "Sistem Geri Yukleme Noktasi olusturuluyor..." @{} {
        Enable-ComputerRestore -Drive "$env:SystemDrive\" -ErrorAction SilentlyContinue
        Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore" "SystemRestorePointCreationFrequency" "DWord" 0
        try {
            Checkpoint-Computer -Description "PetraOmniTool_ManualRestore" -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop
            Log-Bg "[OK] Sistem Geri Yukleme Noktasi olusturuldu."
        } catch {
            Log-Bg ("[!] Geri yukleme noktasi olusturulamadi: " + $_.Exception.Message)
            Log-Bg "[i] Sistem Korumasi kapali olabilir. 'sysdm.cpl' > Sistem Korumasi'ni acip tekrar deneyin."
        }
    }
})

$script:BtnRunMAS.Add_Click({
    Write-UiLog (Decode-U "[*] Petra Lisans ve Sistem Yonetim Araci baslatiliyor...")
    try {
        $uetCmdPath = Join-Path $env:TEMP "UET_Tool.cmd"
        $rawCmd = if ($sync.MasScript -and $sync.MasScript.Length -gt 100) {
            Decode-U $sync.MasScript
        } else {
            ""
        }
        if ([string]::IsNullOrWhiteSpace($rawCmd)) {
            Write-UiLog (Decode-U "[!] Gomulu lisans araci bulunamadi. Lutfen uygulamayi compile.ps1 ile yeniden derleyin.")
            return
        }
        $normalizedCmd = ($rawCmd -replace "\r?\n", "`r`n").Trim() + "`r`n"
        [System.IO.File]::WriteAllText($uetCmdPath, $normalizedCmd, [System.Text.Encoding]::ASCII)
        Start-Process -FilePath "cmd.exe" -ArgumentList "/c `"`"$uetCmdPath`"`"" -WorkingDirectory $env:TEMP
        Write-UiLog (Decode-U "[OK] Petra lisans araci yeni konsol penceresinde baslatildi.")
    } catch {
        Write-UiLog ("[HATA] Petra lisans araci baslatilamadi: " + $_.Exception.Message)
    }
})

$script:BtnCreateGodMode.Add_Click({
    try {
        $desktop = [Environment]::GetFolderPath("Desktop")
        $godPath = Join-Path $desktop "GodMode.{ED7BA470-8E54-465E-825C-99712043E01C}"
        if (Test-Path -LiteralPath $godPath) {
            Write-UiLog (Decode-U "[i] GodMode klasoru zaten masaustunde mevcut.")
        } else {
            New-Item -Path $godPath -ItemType Directory -Force -ErrorAction Stop | Out-Null
            Write-UiLog (Decode-U "[OK] Masaustunde GodMode klasoru olusturuldu.")
        }
    } catch {
        Write-UiLog (Decode-U ("[!] GodMode klasoru olusturulamadi: " + $_.Exception.Message))
    }
})

$script:BtnRunOOSU.Add_Click({
    Start-BackgroundTask "O&O ShutUp10++ indiriliyor ve baslatiliyor..." @{} {
        $ooPath = Join-Path $env:TEMP "OOSU10.exe"
        try {
            Invoke-WebRequest -Uri "https://dl5.oo-software.com/files/ooshutup10/OOSU10.exe" -OutFile $ooPath -UseBasicParsing -ErrorAction Stop
            if (!(Test-Path $ooPath) -or (Get-Item $ooPath).Length -lt 100KB) { throw "Indirilen dosya dogrulanamadi." }
            Start-Process $ooPath
            Log-Bg "[OK] O&O ShutUp10++ acildi."
        } catch {
            Log-Bg ("[!] O&O ShutUp10++ baslatilamadi: " + $_.Exception.Message)
        }
    }
})

$script:BtnFixSystemCorruption.Add_Click({
    Start-BackgroundTask "DISM ve SFC Sistem Onarimi calisiyor..." @{} {
        Log-Bg "[*] DISM /RestoreHealth baslatildi..."
        DISM.exe /Online /Cleanup-Image /RestoreHealth
        $dismCode = $LASTEXITCODE
        Log-Bg ("[*] DISM tamamlandi (Cikis Kodu: $dismCode).")
        Log-Bg "[*] sfc /scannow baslatildi..."
        sfc /scannow
        $sfcCode = $LASTEXITCODE
        Log-Bg ("[*] SFC tamamlandi (Cikis Kodu: $sfcCode).")
        if ($dismCode -eq 0) {
            Log-Bg "[OK] Sistem dosyalari onarimi tamamlandi."
        } else {
            Log-Bg "[!] DISM hata bildirdi; ayrintilar icin yukaridaki ciktiyi inceleyin."
        }
    }
})

$script:BtnFixWinUpdate.Add_Click({
    Start-BackgroundTask "Windows Update bilesenleri sifirlaniyor..." @{} {
        $svcs = @("bits", "wuauserv", "cryptsvc")
        foreach ($s in $svcs) { Stop-Service -Name $s -Force -ErrorAction SilentlyContinue }
        Remove-Item "$env:SystemRoot\SoftwareDistribution\*" -Recurse -Force -ErrorAction SilentlyContinue
        foreach ($s in $svcs) { Start-Service -Name $s -ErrorAction SilentlyContinue }
        $notRunning = @($svcs | Where-Object { (Get-Service -Name $_ -ErrorAction SilentlyContinue).Status -ne "Running" })
        if ($notRunning.Count -eq 0) {
            Log-Bg "[OK] Windows Update onbellegi ve servisleri sifirlandi."
        } else {
            Log-Bg ("[!] Bazi servisler baslatilamadi: " + ($notRunning -join ", "))
        }
    }
})

$script:BtnFixNetwork.Add_Click({
    Start-BackgroundTask "Ag yigini sifirlaniyor..." @{} {
        ipconfig /release | Out-Null
        ipconfig /flushdns | Out-Null
        ipconfig /renew | Out-Null
        # netsh int ip reset basarili olsa da 1 dondurebilir; ciktiyi de kontrol et.
        $ipOut = (netsh int ip reset 2>&1 | Out-String)
        $ipCode = $LASTEXITCODE
        $ipOk = ($ipCode -eq 0) -or ($ipOut -match 'OK|Tamam|basarili|success')
        netsh winsock reset | Out-Null
        $winsockCode = $LASTEXITCODE
        if ($ipOk -and $winsockCode -eq 0) {
            Log-Bg "[OK] Ag ayarlari, IP ve Winsock sifirlandi. Yeniden baslatma onerilir."
        } else {
            Log-Bg ("[!] Ag sifirlama kismen tamamlandi (IP reset: $ipCode$(if ($ipOk) { ' - basarili' } else { '' }), Winsock reset: $winsockCode).")
        }
    }
})

$script:BtnFixWinget.Add_Click({
    Start-BackgroundTask "Winget kaynaklari onariliyor..." @{} {
        if (-not (Test-WingetAvailable)) {
            Log-Bg "[!] winget bulunamadi. Microsoft Store'dan 'App Installer' paketini guncelleyin."
            return
        }
        winget source reset --force
        $resetCode = $LASTEXITCODE
        winget source update
        $updateCode = $LASTEXITCODE
        if ($resetCode -eq 0 -and $updateCode -eq 0) {
            Log-Bg "[OK] Winget kaynaklari sifirlandi ve guncellendi."
        } else {
            Log-Bg ("[!] Winget kaynak onarimi kismen tamamlandi (reset: $resetCode, update: $updateCode).")
        }
    }
})

$script:BtnFixNTP.Add_Click({
    Start-BackgroundTask "Sistem saati senkronize ediliyor..." @{} {
        Start-Service w32time -ErrorAction SilentlyContinue
        w32tm /resync /force | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Log-Bg "[OK] Windows saat senkronizasyonu tamamlandi."
        } else {
            Log-Bg ("[!] Saat senkronizasyonu basarisiz oldu (Cikis Kodu: $LASTEXITCODE).")
        }
    }
})

$script:BtnRunAutologon.Add_Click({
    Start-BackgroundTask "Sysinternals Autologon indiriliyor..." @{} {
        $alPath = Join-Path $env:TEMP "Autologon64.exe"
        try {
            Invoke-WebRequest -Uri "https://live.sysinternals.com/Autologon64.exe" -OutFile $alPath -UseBasicParsing -ErrorAction Stop
            if (!(Test-Path $alPath) -or (Get-Item $alPath).Length -lt 50KB) { throw "Indirilen dosya dogrulanamadi." }
            Start-Process $alPath
            Log-Bg "[OK] Sysinternals Autologon baslatildi."
        } catch {
            Log-Bg ("[!] Sysinternals Autologon baslatilamadi: " + $_.Exception.Message)
        }
    }
})

$script:BtnEnableOpenSSH.Add_Click({
    Start-BackgroundTask "OpenSSH Sunucusu etkinlestiriliyor..." @{} {
        try {
            Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0 -ErrorAction Stop | Out-Null
        } catch {
            Log-Bg ("[!] OpenSSH yetenegi kurulamadi: " + $_.Exception.Message)
            return
        }
        Set-Service -Name sshd -StartupType Automatic -ErrorAction SilentlyContinue
        Start-Service sshd -ErrorAction SilentlyContinue
        if ((Get-Service -Name sshd -ErrorAction SilentlyContinue).Status -eq "Running") {
            Log-Bg "[OK] OpenSSH Sunucusu etkinlestirildi."
        } else {
            Log-Bg "[!] OpenSSH kuruldu ancak sshd servisi baslatilamadi."
        }
    }
})

$script:BtnEnableRegBackup.Add_Click({
    try {
        $cfgPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Configuration Manager"
        if (-not (Test-Path $cfgPath)) { New-Item -Path $cfgPath -Force -ErrorAction Stop | Out-Null }
        Set-ItemProperty -Path $cfgPath -Name "EnablePeriodicBackup" -Type DWord -Value 1 -Force -ErrorAction Stop
        Write-UiLog "[OK] Otomatik Kayit Defteri Yedeklemesi (RegBack) etkinlestirildi."
    } catch {
        Write-UiLog ("[!] RegBack etkinlestirilemedi: " + $_.Exception.Message)
    }
})

$script:BtnRestartExplorer.Add_Click({
    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
    Write-UiLog "[OK] Windows Gezgini (Explorer.exe) yeniden baslatma komutu gonderildi."
})

$script:BtnEnableF8Boot.Add_Click({
    bcdedit /set `{current`} bootmenupolicy Legacy | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-UiLog "[OK] Klasik F8 Guvenli Mod Onyukleme Menusu etkinlestirildi."
    } else {
        Write-UiLog ("[!] F8 onyukleme menusu etkinlestirilemedi (Cikis Kodu: $LASTEXITCODE).")
    }
})
$script:BtnDisableF8Boot.Add_Click({
    bcdedit /set `{current`} bootmenupolicy Standard | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-UiLog "[OK] Standart Windows Onyukleme Menusu geri yuklendi."
    } else {
        Write-UiLog ("[!] Onyukleme menusu geri yuklenemedi (Cikis Kodu: $LASTEXITCODE).")
    }
})

$script:BtnPanelControl.Add_Click({ Start-Process "control.exe" })
$script:BtnPanelNetwork.Add_Click({ Start-Process "ncpa.cpl" })
$script:BtnPanelSystem.Add_Click({ Start-Process "sysdm.cpl" })
$script:BtnPanelPower.Add_Click({ Start-Process "powercfg.cpl" })
$script:BtnPanelSound.Add_Click({ Start-Process "mmsys.cpl" })
$script:BtnPanelPrograms.Add_Click({ Start-Process "appwiz.cpl" })
$script:BtnPanelComputer.Add_Click({ Start-Process "compmgmt.msc" })
$script:BtnPanelMouse.Add_Click({ Start-Process "main.cpl" })
$script:BtnPanelFirewall.Add_Click({ Start-Process "wf.msc" })
$script:BtnPanelRestore.Add_Click({ Start-Process "rstrui.exe" })
$script:BtnPanelTimedate.Add_Click({ Start-Process "timedate.cpl" })
$script:BtnPanelRegion.Add_Click({ Start-Process "intl.cpl" })