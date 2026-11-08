# --- SEKME 3: WINDOWS OZELLIKLERI (DISM) VE DNS ---
function Render-Features {
    $script:FeaturesGrid.Children.Clear()
    $script:FeatureCheckboxes.Clear()
    $script:FeatureCards.Clear()

    foreach ($feat in $script:FeaturesData) {
        $card = New-Object System.Windows.Controls.Border
        Set-ThemeRef $card "Background" "CardBg"
        Set-ThemeRef $card "BorderBrush" "BorderBrushColor"
        $card.BorderThickness = New-Object System.Windows.Thickness(1)
        $card.CornerRadius = New-Object System.Windows.CornerRadius(6)
        $card.Padding = New-Object System.Windows.Thickness(10, 8, 10, 8)
        $card.Margin = New-Object System.Windows.Thickness(4)
        $card.Cursor = [System.Windows.Input.Cursors]::Hand

        $sp = New-Object System.Windows.Controls.StackPanel
        $cb = New-Object System.Windows.Controls.CheckBox
        $cb.Tag = $feat
        $cb.Content = Decode-U $feat.Name
        $cb.Foreground = Get-Brush "#F8FAFC"
        $cb.FontWeight = "SemiBold"
        $cb.FontSize = 12.5
        $cb.Add_Checked({
            param($s, $e)
            Update-SelectionCardVisual $script:FeatureCards[[string]$s.Tag.Feature] $true
            Update-AllSelectionCounts
        })
        $cb.Add_Unchecked({
            param($s, $e)
            Update-SelectionCardVisual $script:FeatureCards[[string]$s.Tag.Feature] $false
            Update-AllSelectionCounts
        })

        $desc = New-Object System.Windows.Controls.TextBlock
        $desc.Text = Decode-U $feat.Desc
        $desc.FontSize = 11
        Set-ThemeRef $desc "Foreground" "TextMuted"
        $desc.TextWrapping = "Wrap"
        $desc.Margin = New-Object System.Windows.Thickness(22, 2, 0, 0)

        [void]$sp.Children.Add($cb)
        [void]$sp.Children.Add($desc)
        $card.Child = $sp
        $card.Tag = $cb

        $card.Add_MouseLeftButtonUp({
            param($sender, $e)
            if ($e.OriginalSource -isnot [System.Windows.Controls.Primitives.ToggleButton]) {
                $innerCb = $sender.Tag
                if ($innerCb) { $innerCb.IsChecked = -not $innerCb.IsChecked }
            }
        })

        Add-SelectionCardHover $card
        $script:FeatureCards[$feat.Feature] = $card
        [void]$script:FeaturesGrid.Children.Add($card)
        $script:FeatureCheckboxes[$feat.Feature] = $cb
    }
}

function Set-QuickDns([string[]]$v4, [string]$label) {
    Start-BackgroundTask "DNS Ayarlaniyor: $label" @{ V4 = $v4; Label = $label } {
        param($p)
        $adapters = @(Get-NetAdapter -ErrorAction SilentlyContinue | Where-Object { $_.Status -eq 'Up' })
        $ok = 0
        $fail = 0
        foreach ($a in $adapters) {
            try {
                if ($p.V4.Count -eq 0) {
                    Set-DnsClientServerAddress -InterfaceIndex $a.ifIndex -ResetServerAddresses -ErrorAction Stop
                } else {
                    Set-DnsClientServerAddress -InterfaceIndex $a.ifIndex -ServerAddresses $p.V4 -ErrorAction Stop
                }
                $ok++
            } catch {
                $fail++
            }
        }
        ipconfig /flushdns | Out-Null
        if ($ok -gt 0) {
            Log-Bg ("[OK] DNS guncellendi: " + $p.Label + " (" + $ok + " adaptor)")
            if ($fail -gt 0) { Log-Bg ("[!] $fail adaptorde DNS ayarlanamadi (yonetici yetkisi gerekebilir).") }
        } else {
            Log-Bg ("[!] DNS guncellenemedi: " + $p.Label + " (etkin adaptor bulunamadi veya yetki yetersiz).")
        }
    }
    if ($script:TxtDnsStatus) { $script:TxtDnsStatus.Text = "Aktif DNS: $label" }
}

$script:BtnDnsCloudflare.Add_Click({ Set-QuickDns @("1.1.1.1", "1.0.0.1") "Cloudflare (1.1.1.1)" })
$script:BtnDnsGoogle.Add_Click({ Set-QuickDns @("8.8.8.8", "8.8.4.4") "Google (8.8.8.8)" })
$script:BtnDnsAdguard.Add_Click({ Set-QuickDns @("94.140.14.14", "94.140.15.15") "AdGuard DNS" })
$script:BtnDnsQuad9.Add_Click({ Set-QuickDns @("9.9.9.9", "149.112.112.112") "Quad9 (9.9.9.9)" })
$script:BtnDnsCloudflareMalware.Add_Click({ Set-QuickDns @("1.1.1.2", "1.0.0.2") "Cloudflare Malware Block" })
$script:BtnDnsOpenDns.Add_Click({ Set-QuickDns @("208.67.222.222", "208.67.220.220") "OpenDNS" })
$script:BtnDnsDhcp.Add_Click({ Set-QuickDns @() "Otomatik (DHCP)" })

$script:BtnCheckFeaturesStatus.Add_Click({
    Start-BackgroundTask "DISM ozellik durumlari kontrol ediliyor..." @{} {
        foreach ($feat in $sync.FeaturesConfig) {
            $st = Get-WindowsOptionalFeature -Online -FeatureName $feat.Feature -ErrorAction SilentlyContinue
            if ($st) {
                Log-Bg ("[DISM] " + $feat.Feature + " -> " + $st.State)
            }
        }
    }
})

$script:BtnApplyFeatures.Add_Click({
    $sel = @()
    foreach ($cb in $script:FeatureCheckboxes.Values) {
        if ($cb.IsChecked -eq $true) { $sel += $cb.Tag }
    }
    $sel = @($sel)
    if ($sel.Count -eq 0) {
        Write-UiLog (Decode-U "[!] Etkinlestirilecek en az 1 Windows ozelligi secin.")
        return
    }
    $msg = "$($sel.Count) Windows ozelligi etkinlestirilecek. Bazi ozellikler icin yeniden baslatma gerekebilir.`n`nDevam etmek istiyor musunuz?"
    if (-not (Confirm-Action $msg)) { return }
    Start-BackgroundTask "Windows Ozellikleri etkinlestiriliyor..." @{ Items = $sel } {
        param($p)
        $okCount = 0
        $failCount = 0
        foreach ($f in $p.Items) {
            Log-Bg ("[+] DISM Etkinlestiriliyor: " + $f.Feature)
            try {
                Enable-WindowsOptionalFeature -Online -FeatureName $f.Feature -All -NoRestart -ErrorAction Stop | Out-Null
                if ($f.ExtraFeatures) {
                    foreach ($ex in $f.ExtraFeatures) {
                        Enable-WindowsOptionalFeature -Online -FeatureName $ex -All -NoRestart -ErrorAction Stop | Out-Null
                    }
                }
                $okCount++
                Log-Bg ("[OK] Etkinlestirildi: " + $f.Feature)
            } catch {
                $failCount++
                Log-Bg ("[!] Etkinlestirilemedi ($($f.Feature)): " + $_.Exception.Message)
            }
        }
        if ($failCount -eq 0) {
            Log-Bg "[OK] Secili Windows Ozellikleri etkinlestirildi."
        } else {
            Log-Bg ("[!] Islem tamamlandi: $okCount basarili, $failCount basarisiz.")
        }
    }
})

$script:BtnDisableFeatures.Add_Click({
    $sel = @()
    foreach ($cb in $script:FeatureCheckboxes.Values) {
        if ($cb.IsChecked -eq $true) { $sel += $cb.Tag }
    }
    $sel = @($sel)
    if ($sel.Count -eq 0) {
        Write-UiLog (Decode-U "[!] Devre disi birakilacak en az 1 Windows ozelligi secin.")
        return
    }
    $msg = "$($sel.Count) Windows ozelligi devre disi birakilacak. Bu islem bazi uygulamalari/ozellikleri kullanilamaz hale getirebilir ve yeniden baslatma gerektirebilir.`n`nDevam etmek istiyor musunuz?"
    if (-not (Confirm-Action $msg)) { return }
    Start-BackgroundTask "Windows Ozellikleri kapatiliyor..." @{ Items = $sel } {
        param($p)
        $okCount = 0
        $failCount = 0
        foreach ($f in $p.Items) {
            Log-Bg ("[-] DISM Devre Disi Birakiliyor: " + $f.Feature)
            try {
                Disable-WindowsOptionalFeature -Online -FeatureName $f.Feature -NoRestart -ErrorAction Stop | Out-Null
                $okCount++
                Log-Bg ("[OK] Devre disi birakildi: " + $f.Feature)
            } catch {
                $failCount++
                Log-Bg ("[!] Devre disi birakilamadi ($($f.Feature)): " + $_.Exception.Message)
            }
        }
        if ($failCount -eq 0) {
            Log-Bg "[OK] Secili Windows Ozellikleri devre disi birakildi."
        } else {
            Log-Bg ("[!] Islem tamamlandi: $okCount basarili, $failCount basarisiz.")
        }
    }
})

$script:BtnDeepOneDrive.Add_Click({
    $msg = "OneDrive sistemden kaldirilacak.`n`nBu islem geri alinamaz; 'OneDrive Geri Yukle' ile yeniden kurulabilir. Dosyalariniz OneDrive klasorunde kalirsa erisim icin yeniden kurulum gerekebilir.`n`nDevam etmek istiyor musunuz?"
    if (-not (Confirm-Action $msg)) { return }
    Start-BackgroundTask "OneDrive kaldiriliyor..." @{} {
        Stop-Process -Name "OneDrive" -Force -ErrorAction SilentlyContinue
        $od = "$env:SystemRoot\SysWOW64\OneDriveSetup.exe"
        if (!(Test-Path $od)) { $od = "$env:SystemRoot\System32\OneDriveSetup.exe" }
        if (Test-Path $od) {
            try {
                Start-Process $od -ArgumentList "/uninstall" -Wait -NoNewWindow -ErrorAction Stop
                Log-Bg "[OK] OneDrive sistemden kaldirildi."
            } catch {
                Log-Bg ("[!] OneDrive kaldirilamadi: " + $_.Exception.Message)
            }
        } else {
            Log-Bg "[!] OneDriveSetup.exe bulunamadi; kaldirma atlandi."
        }
    }
})
$script:BtnRestoreOneDrive.Add_Click({
    Start-BackgroundTask "OneDrive geri yukleniyor..." @{} {
        if (-not (Test-WingetAvailable)) {
            Log-Bg "[!] winget bulunamadi. Microsoft Store'dan 'App Installer' paketini guncelleyin."
            return
        }
        winget install --id Microsoft.OneDrive -e --silent --accept-package-agreements --accept-source-agreements
        if ($LASTEXITCODE -eq 0) {
            Log-Bg "[OK] OneDrive tekrar kuruldu."
        } else {
            Log-Bg ("[!] OneDrive kurulamadi (Cikis Kodu: $LASTEXITCODE).")
        }
    }
})
$script:BtnDisableCopilot.Add_Click({
    Start-BackgroundTask "Copilot kapatiliyor..." @{} {
        Set-RegSafe "HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot" "TurnOffWindowsCopilot" "DWord" 1
        Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" "TurnOffWindowsCopilot" "DWord" 1
        Log-Bg "[OK] Windows Copilot devre disi birakildi."
    }
})
$script:BtnEnableCopilot.Add_Click({
    Start-BackgroundTask "Copilot aciliyor..." @{} {
        Set-RegSafe "HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot" "TurnOffWindowsCopilot" "DWord" "<RemoveEntry>"
        Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" "TurnOffWindowsCopilot" "DWord" "<RemoveEntry>"
        Log-Bg "[OK] Windows Copilot etkinlestirildi."
    }
})
$script:BtnDisableEdgeBg.Add_Click({
    Start-BackgroundTask "Edge arka plan kapatiliyor..." @{} {
        Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Edge" "BackgroundModeEnabled" "DWord" 0
        Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Edge" "StartupBoostEnabled" "DWord" 0
        Log-Bg "[OK] Edge arka plan calismasi kapatildi."
    }
})
$script:BtnEnableEdgeBg.Add_Click({
    Start-BackgroundTask "Edge arka plan varsayilana aliniyor..." @{} {
        Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Edge" "BackgroundModeEnabled" "DWord" "<RemoveEntry>"
        Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Edge" "StartupBoostEnabled" "DWord" "<RemoveEntry>"
        Log-Bg "[OK] Edge arka plan ayarlari varsayilana donduruldu."
    }
})

$script:BtnWinUpdateSecurity.Add_Click({
    Start-BackgroundTask "Windows Update Guvenlik Modu..." @{} {
        Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" "NoAutoUpdate" "DWord" 0
        Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" "DeferFeatureUpdates" "DWord" 1
        Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" "DeferFeatureUpdatesPeriodInDays" "DWord" 365
        Log-Bg "[OK] Windows Update yalnizca guvenlik yamalarini alacak sekilde ayarlandi."
    }
})
$script:BtnWinUpdateDisable.Add_Click({
    Start-BackgroundTask "Windows Update Durduruluyor..." @{} {
        Stop-Service -Name "wuauserv" -Force -ErrorAction SilentlyContinue
        Set-Service -Name "wuauserv" -StartupType Disabled -ErrorAction SilentlyContinue
        Log-Bg "[OK] Windows Update servisi devre disi birakildi."
    }
})
$script:BtnWinUpdateDefault.Add_Click({
    Start-BackgroundTask "Windows Update Varsayilana Aliniyor..." @{} {
        Set-Service -Name "wuauserv" -StartupType Manual -ErrorAction SilentlyContinue
        Start-Service -Name "wuauserv" -ErrorAction SilentlyContinue
        Remove-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Recurse -Force -ErrorAction SilentlyContinue
        Log-Bg "[OK] Windows Update varsayilan ayarlara donduruldu."
    }
})