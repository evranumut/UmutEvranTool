# --- SEKME 2: TWEAKS RENDER VE UYGULA / GERI AL MOTORU ---
# Kart secim durumuna gore arka plan / kenarlik gunceller (tweak, ozellik, bloatware).
function Update-SelectionCardVisual($card, [bool]$isChecked) {
    if ($null -eq $card) { return }
    if ($isChecked) {
        Set-ThemeRef $card "Background" "SelectedBg"
        Set-ThemeRef $card "BorderBrush" "SelectedBorder"
        $card.BorderThickness = New-Object System.Windows.Thickness(1.5)
    } else {
        Set-ThemeRef $card "Background" "CardBg"
        Set-ThemeRef $card "BorderBrush" "BorderBrushColor"
        $card.BorderThickness = New-Object System.Windows.Thickness(1)
    }
}

function Add-SelectionCardHover($card) {
    $card.Add_MouseEnter({
        param($sender, $e)
        if ($sender.Tag.IsChecked -ne $true) {
            Set-ThemeRef $sender "Background" "HoverBg"
            Set-ThemeRef $sender "BorderBrush" "AccentColor"
        }
    })
    $card.Add_MouseLeave({
        param($sender, $e)
        Update-SelectionCardVisual $sender ($sender.Tag.IsChecked -eq $true)
    })
}

function Render-Tweaks {
    $script:TweaksStackPanel.Children.Clear()
    $script:TweakCheckboxes.Clear()
    $script:TweakCards.Clear()

    foreach ($grp in $script:TweaksData) {
        $grpTitle = New-Object System.Windows.Controls.TextBlock
        $grpTitle.Text = Decode-U $grp.Group
        $grpTitle.FontSize = 14
        $grpTitle.FontWeight = "Bold"
        Set-ThemeRef $grpTitle "Foreground" "AccentColor"
        $grpTitle.Margin = New-Object System.Windows.Thickness(4, 10, 4, 6)
        [void]$script:TweaksStackPanel.Children.Add($grpTitle)

        foreach ($item in $grp.Items) {
            $card = New-Object System.Windows.Controls.Border
            Set-ThemeRef $card "Background" "CardBg"
            Set-ThemeRef $card "BorderBrush" "BorderBrushColor"
            $card.BorderThickness = New-Object System.Windows.Thickness(1)
            $card.CornerRadius = New-Object System.Windows.CornerRadius(6)
            $card.Padding = New-Object System.Windows.Thickness(10, 7, 10, 7)
            $card.Margin = New-Object System.Windows.Thickness(0, 0, 0, 5)
            $card.Cursor = [System.Windows.Input.Cursors]::Hand

            $sp = New-Object System.Windows.Controls.StackPanel

            $cb = New-Object System.Windows.Controls.CheckBox
            $cb.Tag = $item
            $cb.Content = Decode-U $item.Title
            $cb.Foreground = Get-Brush "#F8FAFC"
            $cb.FontWeight = "SemiBold"
            $cb.FontSize = 12.5
            $cb.Add_Checked({
                param($s, $e)
                Update-SelectionCardVisual $script:TweakCards[[string]$s.Tag.Id] $true
                Update-AllSelectionCounts
            })
            $cb.Add_Unchecked({
                param($s, $e)
                Update-SelectionCardVisual $script:TweakCards[[string]$s.Tag.Id] $false
                Update-AllSelectionCounts
            })

            $desc = New-Object System.Windows.Controls.TextBlock
            $desc.Text = Decode-U $item.Desc
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
            $script:TweakCards[$item.Id] = $card
            [void]$script:TweaksStackPanel.Children.Add($card)
            $script:TweakCheckboxes[$item.Id] = $cb
        }
    }
}

$script:BtnSelectRecTweaks.Add_Click({
    $added = 0
    foreach ($cb in $script:TweakCheckboxes.Values) {
        if ($cb.Tag.Recommended -eq $true -and $cb.IsChecked -ne $true) {
            $cb.IsChecked = $true
            $added++
        }
    }
    Update-AllSelectionCounts
    if ($added -gt 0) {
        Write-UiLog (Decode-U "[+] Onerilen (Recommended) Tweaks secime eklendi ($added yeni).")
    } else {
        Write-UiLog (Decode-U "[i] Onerilen tweakler zaten secili.")
    }
})

function Select-TweakPreset([string]$presetName) {
    $removed = 0
    $added = 0
    foreach ($cb in $script:TweakCheckboxes.Values) {
        $presets = @($cb.Tag.Preset | Where-Object { -not [string]::IsNullOrWhiteSpace([string]$_) })
        if ($presets.Count -eq 0) { continue }   # Profil disi (manuel) tweak korunur
        $belongs = ($presets -contains $presetName)
        if (-not $belongs) {
            # Onceki profilin ekledigi secimleri kaldir; boylece profiller
            # arasinda gecerken Temizle'ye basmak gerekmez.
            if ($cb.IsChecked -eq $true) { $cb.IsChecked = $false; $removed++ }
        } elseif ($cb.IsChecked -ne $true) {
            $cb.IsChecked = $true
            $added++
        }
    }
    Update-AllSelectionCounts
    Write-UiLog (Decode-U "[+] WinUtil '$presetName' profil secimi uygulandi (+$added eklendi, -$removed cikarildi).")
}

$script:BtnTweakPresetStandard.Add_Click({ Select-TweakPreset "Standard" })
$script:BtnTweakPresetMinimal.Add_Click({ Select-TweakPreset "Minimal" })
$script:BtnTweakPresetAdvanced.Add_Click({ Select-TweakPreset "Advanced" })
$script:BtnClearTweaks.Add_Click({
    foreach ($cb in $script:TweakCheckboxes.Values) { $cb.IsChecked = $false }
    Update-AllSelectionCounts
})

function Confirm-Action([string]$message) {
    $result = [System.Windows.MessageBox]::Show(
        $script:window,
        $message,
        "Petra OmniTool - Onay",
        [System.Windows.MessageBoxButton]::YesNo,
        [System.Windows.MessageBoxImage]::Warning
    )
    return ($result -eq [System.Windows.MessageBoxResult]::Yes)
}

function Invoke-SelectedTweaks([bool]$UndoMode) {
    $selectedIds = @()
    foreach ($id in $script:TweakCheckboxes.Keys) {
        if ($script:TweakCheckboxes[$id].IsChecked -eq $true) {
            $selectedIds += $id
        }
    }
    $selectedIds = @($selectedIds)
    if ($selectedIds.Count -eq 0) {
        Write-UiLog (Decode-U "[!] Lutfen uygulanacak veya geri alinacak en az 1 ayar secin.")
        return
    }
    # Geri yukleme noktasi her zaman ilk adim olsun (diger tweaklerden once).
    $restoreIds = @($selectedIds | Where-Object { $_ -eq "Tweak_RestorePoint" })
    $otherIds   = @($selectedIds | Where-Object { $_ -ne "Tweak_RestorePoint" })
    if ($restoreIds.Count -gt 0 -and $otherIds.Count -gt 0) {
        $selectedIds = @($restoreIds + $otherIds)
    }
    $taskTitle = if ($UndoMode) { "Secili Tweaks geri aliniyor..." } else { "Secili Tweaks uygulaniyor..." }
    Start-BackgroundTask $taskTitle @{ Ids = $selectedIds; Undo = $UndoMode } {
        param($p)
        $undo = $p.Undo
        $ids = @($p.Ids)
        $total = $ids.Count
        if ($total -eq 0) { Log-Bg "[!] Uygulanacak ayar bulunamadi."; return }
        $idx = 0
        $restartExplorer = $false
        foreach ($id in $ids) {
            $idx++
            $pct = [math]::Round(($idx / $total) * 100)
            Status-Bg ("Islem ($idx/$total): $id") $pct
            Log-Bg ($(if ($undo) { "[UNDO] " } else { "[APPLY] " }) + $id)

            switch ($id) {
                "Tweak_RestorePoint" {
                    if (-not $undo) {
                        Enable-ComputerRestore -Drive "$env:SystemDrive\" -ErrorAction SilentlyContinue
                        Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore" "SystemRestorePointCreationFrequency" "DWord" 0
                        try {
                            Checkpoint-Computer -Description "PetraOmniTool_RestorePoint" -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop
                            Log-Bg "[OK] Geri yukleme noktasi olusturuldu."
                        } catch {
                            Log-Bg ("[!] Geri yukleme noktasi olusturulamadi: " + $_.Exception.Message)
                        }
                    }
                }
                "Tweak_Telemetry" {
                    $val = if ($undo) { 1 } else { 0 }
                    Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" "AllowTelemetry" "DWord" $val
                    Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" "AllowTelemetry" "DWord" $val
                    Set-RegSafe "HKCU:\Software\Microsoft\Siuf\Rules" "NumberOfSIUFInPeriod" "DWord" $(if ($undo) { "<RemoveEntry>" } else { 0 })
                    if ($undo) {
                        Set-Service -Name "DiagTrack" -StartupType Automatic -ErrorAction SilentlyContinue
                        [Environment]::SetEnvironmentVariable("POWERSHELL_TELEMETRY_OPTOUT", $null, "Machine")
                    } else {
                        Stop-Service -Name "DiagTrack" -Force -ErrorAction SilentlyContinue
                        Set-Service -Name "DiagTrack" -StartupType Disabled -ErrorAction SilentlyContinue
                        Stop-Service -Name "dmwappushservice" -Force -ErrorAction SilentlyContinue
                        Set-Service -Name "dmwappushservice" -StartupType Disabled -ErrorAction SilentlyContinue
                        [Environment]::SetEnvironmentVariable("POWERSHELL_TELEMETRY_OPTOUT", "1", "Machine")
                    }
                }
                "Tweak_ActivityHistory" {
                    $val = if ($undo) { 1 } else { 0 }
                    Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "EnableActivityFeed" "DWord" $val
                    Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "PublishUserActivities" "DWord" $val
                    Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "UploadUserActivities" "DWord" $val
                }
                "Tweak_Location" {
                    $val = if ($undo) { "Allow" } else { "Deny" }
                    Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" "Value" "String" $val
                    Set-Service -Name "lfsvc" -StartupType $(if ($undo) { "Manual" } else { "Disabled" }) -ErrorAction SilentlyContinue
                }
                "Tweak_AdvertisingId" {
                    $val = if ($undo) { 1 } else { 0 }
                    Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" "Enabled" "DWord" $val
                    Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy" "TailoredExperiencesWithDiagnosticDataEnabled" "DWord" $val
                }
                "Tweak_BingSearch" {
                    $val = if ($undo) { 0 } else { 1 }
                    Set-RegSafe "HKCU:\Software\Policies\Microsoft\Windows\Explorer" "DisableSearchBoxSuggestions" "DWord" $val
                    Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" "BingSearchEnabled" "DWord" $(if ($undo) { 1 } else { 0 })
                }
                "Tweak_ConsumerFeatures" {
                    $val = if ($undo) { 0 } else { 1 }
                    Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" "DisableWindowsConsumerFeatures" "DWord" $val
                    Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "RotatingLockScreenOverlayEnabled" "DWord" $(if ($undo) { 1 } else { 0 })
                    Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SubscribedContent-338387Enabled" "DWord" $(if ($undo) { 1 } else { 0 })
                }
                "Tweak_ErrorReporting" {
                    $val = if ($undo) { 0 } else { 1 }
                    Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting" "Disabled" "DWord" $val
                    Set-Service -Name "WerSvc" -StartupType $(if ($undo) { "Manual" } else { "Disabled" }) -ErrorAction SilentlyContinue
                }
                "Tweak_DeliveryOpt" {
                    $val = if ($undo) { 1 } else { 0 }
                    Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" "DODownloadMode" "DWord" $val
                    Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" "DODownloadMode" "DWord" $val
                }
                "Tweak_WPBT" {
                    $val = if ($undo) { 0 } else { 1 }
                    Set-RegSafe "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" "DisableWpbtExecution" "DWord" $val
                }
                "Tweak_DeviceMetadata" {
                    $val = if ($undo) { 0 } else { 1 }
                    Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Metadata" "PreventDeviceMetadataFromNetwork" "DWord" $val
                }
                "Tweak_StoreSearch" {
                    $val = if ($undo) { 1 } else { 0 }
                    Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SilentInstalledAppsEnabled" "DWord" $val
                }
                "Tweak_ExplorerAutoDiscovery" {
                    if ($undo) {
                        Set-RegSafe "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags\AllFolders\Shell" "FolderType" "String" "<RemoveEntry>"
                    } else {
                        Set-RegSafe "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags\AllFolders\Shell" "FolderType" "String" "NotSpecified"
                    }
                }
                "Tweak_EndTaskOnTaskbar" {
                    $val = if ($undo) { 0 } else { 1 }
                    Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings" "TaskbarEndTask" "DWord" $val
                }
                "Tweak_UltimatePerf" {
                    if (-not $undo) {
                        # Duplicatescheme her seferinde yeni bir GUID uretir; etkinlestirmek icin
                        # ciktidan gercek GUID'i oku (sabit High Performance GUID'i kullanma).
                        $dupOut = (powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 2>&1 | Out-String)
                        $guidMatch = [regex]::Match($dupOut, '[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}')
                        if ($guidMatch.Success) {
                            powercfg -setactive $guidMatch.Value | Out-Null
                            Log-Bg ("[OK] Nihai Performans guc plani etkinlestirildi (" + $guidMatch.Value + ").")
                        } else {
                            powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c | Out-Null
                            Log-Bg "[!] Nihai Performans plani olusturulamadi; Yuksek Performans plani etkinlestirildi."
                        }
                    } else {
                        powercfg -setactive 381b4222-f694-41f0-9685-ff5bb260df2e | Out-Null
                        Log-Bg "[UNDO] Dengeli guc planina donuldu."
                    }
                }
                "Tweak_HAGS" {
                    Set-RegSafe "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" "HwSchMode" "DWord" $(if ($undo) { 1 } else { 2 })
                }
                "Tweak_PowerThrottling" {
                    Set-RegSafe "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" "PowerThrottlingOff" "DWord" $(if ($undo) { 0 } else { 1 })
                }
                "Tweak_MouseAccel" {
                    Set-RegSafe "HKCU:\Control Panel\Mouse" "MouseSpeed" "String" $(if ($undo) { "1" } else { "0" })
                    Set-RegSafe "HKCU:\Control Panel\Mouse" "MouseThreshold1" "String" $(if ($undo) { "6" } else { "0" })
                    Set-RegSafe "HKCU:\Control Panel\Mouse" "MouseThreshold2" "String" $(if ($undo) { "10" } else { "0" })
                }
                "Tweak_GameDVR" {
                    Set-RegSafe "HKCU:\System\GameConfigStore" "GameDVR_Enabled" "DWord" $(if ($undo) { 1 } else { 0 })
                    Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" "AllowGameDVR" "DWord" $(if ($undo) { 1 } else { 0 })
                    Set-RegSafe "HKCU:\Software\Microsoft\GameBar" "AutoGameModeEnabled" "DWord" 1
                }
                "Tweak_NetworkThrottling" {
                    Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" "NetworkThrottlingIndex" "DWord" $(if ($undo) { 10 } else { 0xFFFFFFFF })
                }
                "Tweak_SystemResponsiveness" {
                    Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" "SystemResponsiveness" "DWord" $(if ($undo) { 20 } else { 0 })
                    Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" "GPU Priority" "DWord" $(if ($undo) { 2 } else { 8 })
                    Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" "Priority" "DWord" $(if ($undo) { 2 } else { 6 })
                }
                "Tweak_TCPNoDelay" {
                    $ifaces = Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces" -ErrorAction SilentlyContinue
                    foreach ($ifc in $ifaces) {
                        if ($undo) {
                            Set-RegSafe $ifc.PSPath "TcpAckFrequency" "DWord" "<RemoveEntry>"
                            Set-RegSafe $ifc.PSPath "TCPNoDelay" "DWord" "<RemoveEntry>"
                        } else {
                            Set-RegSafe $ifc.PSPath "TcpAckFrequency" "DWord" 1
                            Set-RegSafe $ifc.PSPath "TCPNoDelay" "DWord" 1
                        }
                    }
                }
                "Tweak_GreenEthernet" {
                    $netClasses = Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e972-e325-11ce-bfc1-08002be10318}" -ErrorAction SilentlyContinue
                    foreach ($nc in $netClasses) {
                        if ($nc.PSChildName -match "^\d{4}$") {
                            $v = if ($undo) { "1" } else { "0" }
                            Set-RegSafe $nc.PSPath "EEELinkAdvertisement" "String" $v
                            Set-RegSafe $nc.PSPath "GreenEthernet" "String" $v
                            Set-RegSafe $nc.PSPath "ULPMode" "String" $v
                            Set-RegSafe $nc.PSPath "PnPCapabilities" "DWord" $(if ($undo) { 0 } else { 24 })
                        }
                    }
                }
                "Tweak_Hibernation" {
                    if ($undo) { powercfg -h on | Out-Null } else { powercfg -h off | Out-Null }
                }
                "Tweak_FastStartup" {
                    Set-RegSafe "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" "HiberbootEnabled" "DWord" $(if ($undo) { 1 } else { 0 })
                }
                "Tweak_BgApps" {
                    Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" "GlobalUserDisabled" "DWord" $(if ($undo) { 0 } else { 1 })
                    Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" "LetAppsRunInBackground" "DWord" $(if ($undo) { "<RemoveEntry>" } else { 2 })
                }
                "Tweak_MultiplaneOverlay" {
                    Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows\Dwm" "OverlayTestMode" "DWord" $(if ($undo) { "<RemoveEntry>" } else { 5 })
                }
                "Tweak_VisualFX" {
                    Set-RegSafe "HKCU:\Control Panel\Desktop" "MenuShowDelay" "String" $(if ($undo) { "400" } else { "10" })
                    Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "TaskbarAnimations" "DWord" $(if ($undo) { 1 } else { 0 })
                }
                "Tweak_SSDTrim" {
                    # TRIM varsayilan olarak etkindir (DisableDeleteNotify = 0).
                    # Geri alma da TRIM'i kapatmamali; guvenli varsayilan 0'dir.
                    fsutil behavior set DisableDeleteNotify 0 | Out-Null
                    if ($undo) { Log-Bg "[UNDO] SSD TRIM varsayilan (etkin) durumda birakildi." }
                }
                "Tweak_Services" {
                    $svcs = @("MapsBroker", "Fax", "RetailDemo", "WMPNetworkSvc", "RemoteRegistry", "CscService", "StorSvc", "SharedAccess")
                    foreach ($s in $svcs) {
                        Set-Service -Name $s -StartupType $(if ($undo) { "Manual" } else { "Disabled" }) -ErrorAction SilentlyContinue
                    }
                }
                "Tweak_DiskCleanup" {
                    if (-not $undo) {
                        Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
                        Remove-Item -Path "$env:windir\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
                        Remove-Item -Path "$env:windir\Prefetch\*" -Recurse -Force -ErrorAction SilentlyContinue
                    }
                }
                "Tweak_StorageSense" {
                    Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" "01" "DWord" $(if ($undo) { 1 } else { 0 })
                }
                "Tweak_ReservedStorage" {
                    DISM.exe /Online /Set-ReservedStorageState /State:$(if ($undo) { "Enabled" } else { "Disabled" }) | Out-Null
                }
                "Tweak_SvcHostSplitting" {
                    if ($undo) {
                        Set-RegSafe "HKLM:\SYSTEM\CurrentControlSet\Control" "SvcHostSplitThresholdInKB" "DWord" 3670016
                    } else {
                        $ramKb = [double](Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum).Sum / 1KB
                        if ($ramKb -gt 0) {
                            # uint32 sinirina sikistir (cok yuksek RAM'de tasma olmasin).
                            $ramKb = [math]::Min($ramKb, [double][uint32]::MaxValue)
                            Set-RegSafe "HKLM:\SYSTEM\CurrentControlSet\Control" "SvcHostSplitThresholdInKB" "DWord" ([uint32]$ramKb)
                        }
                    }
                }
                "Tweak_BitLocker" {
                    if (-not $undo) {
                        manage-bde -off $env:SystemDrive 2>$null | Out-Null
                    }
                }
                "Tweak_LongPaths" {
                    Set-RegSafe "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" "LongPathsEnabled" "DWord" $(if ($undo) { 0 } else { 1 })
                }
                "Tweak_UTC" {
                    Set-RegSafe "HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation" "RealTimeIsUniversal" "DWord" $(if ($undo) { 0 } else { 1 })
                }
                "Tweak_S0StandbyFix" {
                    Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Power\PowerSettings\f15576e8-98b7-4186-b944-eafa664402d9" "ACSettingIndex" "DWord" $(if ($undo) { 1 } else { 0 })
                    Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Power\PowerSettings\f15576e8-98b7-4186-b944-eafa664402d9" "DCSettingIndex" "DWord" $(if ($undo) { 1 } else { 0 })
                }
                "Tweak_S3Sleep" {
                    Set-RegSafe "HKLM:\SYSTEM\CurrentControlSet\Control\Power" "PlatformAoAcOverride" "DWord" $(if ($undo) { "<RemoveEntry>" } else { 0 })
                }
                "Tweak_ClassicContext" {
                    $clsidRoot = "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}"
                    $clsidPath = "$clsidRoot\InprocServer32"
                    if ($undo) {
                        Remove-Item -Path $clsidRoot -Recurse -Force -ErrorAction SilentlyContinue
                        Log-Bg "[UNDO] Klasik sag tik menusu kaldirildi; Windows 11 menusu kullanilacak."
                    } else {
                        New-Item -Path $clsidPath -Force -ErrorAction SilentlyContinue | Out-Null
                        Set-Item -Path $clsidPath -Value "" -Force -ErrorAction SilentlyContinue
                        if (Test-Path $clsidPath) {
                            Log-Bg "[OK] Klasik sag tik menusu kayit defterine yazildi."
                        } else {
                            Log-Bg "[!] Klasik sag tik menusu kaydi yazilamadi."
                        }
                    }
                    $restartExplorer = $true
                }
                "Tweak_FileExt" {
                    Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "HideFileExt" "DWord" $(if ($undo) { 1 } else { 0 })
                }
                "Tweak_HiddenFiles" {
                    Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "Hidden" "DWord" $(if ($undo) { 2 } else { 1 })
                }
                "Tweak_HideTaskbarJunk" {
                    Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" "SearchboxTaskbarMode" "DWord" $(if ($undo) { 1 } else { 0 })
                    Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "ShowTaskViewButton" "DWord" $(if ($undo) { 1 } else { 0 })
                    # Widgets/Haber akisi kullanici ayarlari (biri engellenirse digeri uygulanir)
                    Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Feeds" "ShellFeedsTaskbarViewMode" "DWord" $(if ($undo) { 1 } else { 2 })
                    Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "TaskbarDa" "DWord" $(if ($undo) { 1 } else { 0 })
                    Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Dsh" "AllowNewsAndInterests" "DWord" $(if ($undo) { 1 } else { 0 })
                }
                "Tweak_RemoveWidgets" {
                    # Widgets'i UCPD korumali kayit defteri degerlerine dokunmadan kaldirir.
                    if ($undo) {
                        if (Test-WingetAvailable) {
                            winget install --id 9MSSGKG348SP --source msstore --accept-package-agreements --accept-source-agreements 2>&1 | Out-Null
                            if ($LASTEXITCODE -eq 0) {
                                Log-Bg "[OK] Widgets paketi (Windows Web Experience Pack) tekrar kuruldu."
                            } else {
                                Log-Bg "[!] Widgets paketi kurulamadi. Microsoft Store'dan 'Windows Web Experience Pack' kurun."
                            }
                        } else {
                            Log-Bg "[!] winget bulunamadi. Widgets paketini Microsoft Store'dan manuel kurun."
                        }
                    } else {
                        $pkgList = @()
                        $provList = @()
                        try {
                            $pkgList = @(Get-AppxPackage -AllUsers -Name "*WebExperience*" -ErrorAction Stop)
                        } catch {
                            try { $pkgList = @(Get-AppxPackage -Name "*WebExperience*" -ErrorAction Stop) } catch { $pkgList = @() }
                        }
                        try {
                            $provList = @(Get-AppxProvisionedPackage -Online -ErrorAction Stop | Where-Object { $_.DisplayName -like "*WebExperience*" })
                        } catch {
                            $provList = @()
                        }
                        if ($pkgList.Count -eq 0 -and $provList.Count -eq 0) {
                            Log-Bg "[i] Widgets paketi (Windows Web Experience Pack) zaten kurulu degil."
                        } elseif (-not $sync.IsAdmin) {
                            Log-Bg "[!] Widgets paketini kaldirmak icin yonetici yetkisi gerekir. Araci yonetici olarak calistirin."
                        } else {
                            $removedAny = $false
                            foreach ($pkg in $pkgList) {
                                try {
                                    Remove-AppxPackage -Package $pkg.PackageFullName -AllUsers -ErrorAction Stop
                                    $removedAny = $true
                                    Log-Bg ("[OK] Kaldirildi: " + $pkg.Name)
                                } catch {
                                    try {
                                        Remove-AppxPackage -Package $pkg.PackageFullName -ErrorAction Stop
                                        $removedAny = $true
                                        Log-Bg ("[OK] Kaldirildi (gecerli kullanici): " + $pkg.Name)
                                    } catch {
                                        Log-Bg ("[!] Widgets paketi kaldirilamadi (" + $pkg.Name + "): " + $_.Exception.Message)
                                    }
                                }
                            }
                            foreach ($prov in $provList) {
                                try {
                                    Remove-AppxProvisionedPackage -Online -PackageName $prov.PackageName -ErrorAction Stop | Out-Null
                                    Log-Bg ("[OK] Yeni kullanicilar icin kurulum engellendi: " + $prov.DisplayName)
                                } catch {
                                    Log-Bg ("[!] Provisioned paket kaldirilamadi: " + $_.Exception.Message)
                                }
                            }
                            if ($removedAny) {
                                Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
                                Log-Bg "[i] Explorer yeniden baslatildi. Widgets dugmesi kalkti."
                            }
                        }
                    }
                }
                "Tweak_DarkMode" {
                    $v = if ($undo) { 1 } else { 0 }
                    Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" "AppsUseLightTheme" "DWord" $v
                    Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" "SystemUsesLightTheme" "DWord" $v
                }
                "Tweak_StickyKeys" {
                    Set-RegSafe "HKCU:\Control Panel\Accessibility\StickyKeys" "Flags" "String" $(if ($undo) { "510" } else { "506" })
                }
                "Tweak_ClassicPhotoViewer" {
                    $exts = @(".bmp", ".dib", ".gif", ".jfif", ".jpe", ".jpeg", ".jpg", ".png", ".tif", ".tiff", ".wdp")
                    foreach ($ext in $exts) {
                        $regPath = "HKLM:\SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities\FileAssociations"
                        if ($undo) {
                            Set-RegSafe $regPath $ext "String" "<RemoveEntry>"
                        } else {
                            Set-RegSafe $regPath $ext "String" "PhotoViewer.FileAssoc.Tiff"
                        }
                    }
                }
                "Tweak_RemoveHomeGallery" {
                    Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "LaunchTo" "DWord" $(if ($undo) { 2 } else { 1 })
                    $galleryClsid = "HKCU:\Software\Classes\CLSID\{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}"
                    $homeClsid    = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{f874310e-b6b7-47dc-bc84-b9e6b38f5903}"
                    Set-RegSafe $galleryClsid "System.IsPinnedToNameSpaceTree" "DWord" $(if ($undo) { 1 } else { 0 })
                    if (-not $undo) {
                        Remove-Item -Path $homeClsid -Recurse -Force -ErrorAction SilentlyContinue
                    } else {
                        # Geri almada Giris (Home) ad alanini yeniden olustur.
                        if (-not (Test-Path $homeClsid)) {
                            New-Item -Path $homeClsid -Force -ErrorAction SilentlyContinue | Out-Null
                            # Varsayilan (ad) degeri "Home" olmadan kabuk ogesi gorunmez.
                            Set-Item -Path $homeClsid -Value "Home" -Force -ErrorAction SilentlyContinue
                            Log-Bg "[UNDO] Giris (Home) ad alani kaydi geri olusturuldu."
                        }
                    }
                }
                "Tweak_TaskbarLeft" {
                    Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "TaskbarAl" "DWord" $(if ($undo) { 1 } else { 0 })
                }
                "Tweak_RevertStartMenu" {
                    $v = if ($undo) { "<RemoveEntry>" } else { 1 }
                    Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" "HideRecommendedSection" "DWord" $v
                    Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "Start_TrackDocs" "DWord" $(if ($undo) { 1 } else { 0 })
                }
                "Tweak_NumLock" {
                    Set-RegSafe "Registry::HKEY_USERS\.DEFAULT\Control Panel\Keyboard" "InitialKeyboardIndicators" "String" $(if ($undo) { "0" } else { "2" })
                }
                "Tweak_DetailedBSoD" {
                    Set-RegSafe "HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl" "DisplayParameters" "DWord" $(if ($undo) { 0 } else { 1 })
                    Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "VerboseStatus" "DWord" $(if ($undo) { 0 } else { 1 })
                }
                "Tweak_BatteryPct" {
                    Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "ShowBatteryPercentage" "DWord" $(if ($undo) { 0 } else { 1 })
                    Set-RegSafe "HKCU:\Control Panel\Accessibility" "DynamicScrollbars" "DWord" $(if ($undo) { 1 } else { 0 })
                }
                "Tweak_HideSettingsHome" {
                    Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" "SettingsPageVisibility" "String" $(if ($undo) { "<RemoveEntry>" } else { "hide:home" })
                    Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "DisableAcrylicBackgroundOnLogon" "DWord" $(if ($undo) { 0 } else { 1 })
                }
                "Tweak_DeepOneDrive" {
                    if ($undo) {
                        winget install --id Microsoft.OneDrive -e --silent --accept-package-agreements --accept-source-agreements
                        Set-RegSafe "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" "System.IsPinnedToNameSpaceTree" "DWord" 1
                        Set-RegSafe "HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" "System.IsPinnedToNameSpaceTree" "DWord" 1
                    } else {
                        Stop-Process -Name "OneDrive" -Force -ErrorAction SilentlyContinue
                        $od = "$env:SystemRoot\SysWOW64\OneDriveSetup.exe"
                        if (!(Test-Path $od)) { $od = "$env:SystemRoot\System32\OneDriveSetup.exe" }
                        if (Test-Path $od) { Start-Process $od -ArgumentList "/uninstall" -Wait -NoNewWindow }
                        Set-RegSafe "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" "System.IsPinnedToNameSpaceTree" "DWord" 0
                        Set-RegSafe "HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" "System.IsPinnedToNameSpaceTree" "DWord" 0
                    }
                }
                "Tweak_DisableCopilotAI" {
                    Set-RegSafe "HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot" "TurnOffWindowsCopilot" "DWord" $(if ($undo) { 0 } else { 1 })
                    Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" "TurnOffWindowsCopilot" "DWord" $(if ($undo) { 0 } else { 1 })
                    Set-RegSafe "HKCU:\Software\Policies\Microsoft\Windows\WindowsAI" "DisableAIDataAnalysis" "DWord" $(if ($undo) { 0 } else { 1 })
                    Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" "DisableAIDataAnalysis" "DWord" $(if ($undo) { 0 } else { 1 })
                }
                "Tweak_EdgeDebloat" {
                    $v = if ($undo) { 1 } else { 0 }
                    Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Edge" "BackgroundModeEnabled" "DWord" $v
                    Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Edge" "StartupBoostEnabled" "DWord" $v
                    Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Edge" "HubsSidebarEnabled" "DWord" $v
                    Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Edge" "EdgeShoppingAssistantEnabled" "DWord" $v
                    Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Edge" "ShowMicrosoftRewards" "DWord" $v
                    Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Edge" "PersonalizationReportingEnabled" "DWord" $v
                }
                "Tweak_RemoveEdge" {
                    if ($undo) {
                        winget install --id Microsoft.Edge -e --silent --accept-package-agreements --accept-source-agreements
                    } else {
                        Set-RegSafe "HKLM:\SOFTWARE\WOW6432Node\Microsoft\EdgeUpdateDev" "AllowUninstall" "DWord" 1
                        $edgeSetups = Get-ChildItem "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\*\Installer\setup.exe" -ErrorAction SilentlyContinue
                        foreach ($es in $edgeSetups) {
                            Start-Process $es.FullName -ArgumentList "--uninstall --system-level --verbose-logging --force-uninstall" -Wait -NoNewWindow
                        }
                    }
                }
                "Tweak_BraveDebloat" {
                    $v = if ($undo) { 0 } else { 1 }
                    Set-RegSafe "HKLM:\SOFTWARE\Policies\BraveSoftware\Brave" "BraveRewardsDisabled" "DWord" $v
                    Set-RegSafe "HKLM:\SOFTWARE\Policies\BraveSoftware\Brave" "BraveWalletDisabled" "DWord" $v
                    Set-RegSafe "HKLM:\SOFTWARE\Policies\BraveSoftware\Brave" "BraveVPNDisabled" "DWord" $v
                    Set-RegSafe "HKLM:\SOFTWARE\Policies\BraveSoftware\Brave" "BraveAIChatEnabled" "DWord" $(if ($undo) { 1 } else { 0 })
                }
                "Tweak_PeripheralBlock" {
                    Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching" "SearchOrderConfig" "DWord" $(if ($undo) { 1 } else { 0 })
                }
                "Tweak_BlockAdobeNet" {
                    $hostsPath = "$env:SystemRoot\System32\drivers\etc\hosts"
                    if (Test-Path $hostsPath) {
                        $content = Get-Content $hostsPath -ErrorAction SilentlyContinue
                        $clean = $content | Where-Object { $_ -notmatch "adobe\.io|adobestats\.io" }
                        if (-not $undo) {
                            $clean += "0.0.0.0 ic.adobe.io"
                            $clean += "0.0.0.0 cc-api-data.adobe.io"
                        }
                        Set-Content -Path $hostsPath -Value $clean -Encoding ASCII -Force -ErrorAction SilentlyContinue
                    }
                }
                "Tweak_IPv4Prefer" {
                    Set-RegSafe "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" "DisabledComponents" "DWord" $(if ($undo) { 0 } else { 32 })
                    netsh interface teredo set state $(if ($undo) { "default" } else { "disabled" }) | Out-Null
                }
                "Tweak_DisableIPv6" {
                    Set-RegSafe "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" "DisabledComponents" "DWord" $(if ($undo) { 0 } else { 255 })
                    if ($undo) {
                        Enable-NetAdapterBinding -Name "*" -ComponentID ms_tcpip6 -ErrorAction SilentlyContinue
                    } else {
                        Disable-NetAdapterBinding -Name "*" -ComponentID ms_tcpip6 -ErrorAction SilentlyContinue
                    }
                }
                "Tweak_DisableNotifications" {
                    $v = if ($undo) { 0 } else { 1 }
                    Set-RegSafe "HKCU:\Software\Policies\Microsoft\Windows\Explorer" "DisableNotificationCenter" "DWord" $v
                }
                "Tweak_NewOutlookBlock" {
                    Set-RegSafe "HKCU:\Software\Microsoft\Office\16.0\Outlook\Preferences" "UseNewOutlook" "DWord" $(if ($undo) { 1 } else { 0 })
                    Set-RegSafe "HKCU:\Software\Policies\Microsoft\office\16.0\outlook\preferences" "NewOutlookMigrationUserSetting" "DWord" $(if ($undo) { "<RemoveEntry>" } else { 0 })
                }
            }
        }
        if ($restartExplorer) {
            Log-Bg "[i] Degisikligin gorunmesi icin Explorer yeniden baslatiliyor..."
            Start-Sleep -Milliseconds 700
            Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
            Log-Bg "[OK] Explorer yeniden baslatildi; sag tik menusu guncellendi."
        }
        Log-Bg "[i] Secili Tweaks islemleri tamamlandi. Basarisiz adimlar varsa yukaridaki [!] satirlarini kontrol edin."
    }
}

$script:BtnApplyTweaks.Add_Click({
    $count = @($script:TweakCheckboxes.Values | Where-Object { $_.IsChecked -eq $true }).Count
    if ($count -eq 0) { Invoke-SelectedTweaks $false; return }
    $msg = "Secili $count ayar uygulanacak.`n`nBazi ayarlar geri alinamaz veya sistem davranisini kalici olarak degistirebilir. Once 'Sistem Geri Yukleme Noktasi' olusturmaniz onerilir."
    $risky = @()
    foreach ($rid in @("Tweak_BitLocker", "Tweak_RemoveEdge", "Tweak_DeepOneDrive", "Tweak_RemoveHomeGallery")) {
        $rcb = $script:TweakCheckboxes[$rid]
        if ($rcb -and $rcb.IsChecked -eq $true) { $risky += $rid }
    }
    if ($risky.Count -gt 0) {
        $msg += "`n`nDIKKAT: Secili yikici ayarlar tam olarak geri alinamaz:`n - " + ($risky -join "`n - ")
        if ($risky -contains "Tweak_BitLocker") {
            $msg += "`n`nBitLocker'in kapatilmasi surucu sifrelemesini kaldirir ve undo ile geri getirilemez."
        }
    }
    $msg += "`n`nDevam etmek istiyor musunuz?"
    if (Confirm-Action $msg) { Invoke-SelectedTweaks $false }
})
$script:BtnUndoTweaks.Add_Click({
    $count = @($script:TweakCheckboxes.Values | Where-Object { $_.IsChecked -eq $true }).Count
    if ($count -eq 0) { Invoke-SelectedTweaks $true; return }
    $msg = "Secili $count ayarin geri alinmasi denenecek.`n`nNot: Bazi ayarlar (or. Edge/OneDrive kaldirma, BitLocker) tam olarak geri alinamaz.`n`nDevam etmek istiyor musunuz?"
    if (Confirm-Action $msg) { Invoke-SelectedTweaks $true }
})

if (-not ("PetraRegInfo" -as [type])) {
    Add-Type @"
using System;
using System.Text;
using System.Runtime.InteropServices;
public static class PetraRegInfo {
    [DllImport("advapi32.dll")]
    public static extern int RegQueryInfoKey(IntPtr hKey, StringBuilder lpClass, ref uint lpcchClass, IntPtr lpReserved,
        out uint lpcSubKeys, out uint lpcbMaxSubKeyLen, out uint lpcbMaxClassLen, out uint lpcValues,
        out uint lpcbMaxValueNameLen, out uint lpcbMaxValueLen, out uint lpcbSecurityDescriptor, out long lpftLastWriteTime);
}
"@
}

function Get-PetraRegLastWrite([string]$subKey) {
    $key = $null
    try {
        $key = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey($subKey)
        if (-not $key) { return $null }
        $class = New-Object System.Text.StringBuilder 256
        [uint32]$classLen = 256
        [uint32]$subKeys = 0; [uint32]$maxSub = 0; [uint32]$maxClass = 0; [uint32]$values = 0
        [uint32]$maxName = 0; [uint32]$maxVal = 0; [uint32]$sd = 0
        [long]$ft = 0
        $rc = [PetraRegInfo]::RegQueryInfoKey($key.Handle.DangerousGetHandle(), $class, [ref]$classLen, [IntPtr]::Zero,
            [ref]$subKeys, [ref]$maxSub, [ref]$maxClass, [ref]$values, [ref]$maxName, [ref]$maxVal, [ref]$sd, [ref]$ft)
        if ($rc -ne 0 -or $ft -le 0) { return $null }
        return [DateTime]::FromFileTime($ft)
    } catch {
        return $null
    } finally {
        if ($key) { $key.Close() }
    }
}

function Test-ClassicContextEffective {
    $sub = "Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32"
    if (-not (Test-Path "HKCU:\$sub")) { return $false }
    $keyTime = Get-PetraRegLastWrite $sub
    $exp = @(Get-Process explorer -ErrorAction SilentlyContinue) | Select-Object -First 1
    if ($keyTime -and $exp) {
        return ($exp.StartTime -gt $keyTime)
    }
    return $true
}

$script:BtnRevertContextMenu.Add_Click({
    $turnOn = -not (Test-ClassicContextEffective)
    $title = if ($turnOn) { "Klasik sag tik menusu aciliyor..." } else { "Windows 11 sag tik menusu geri getiriliyor..." }
    Start-BackgroundTask (Decode-U $title) @{ TurnOn = $turnOn } {
        param($p)
        $clsidRoot = "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}"
        $clsidPath = "$clsidRoot\InprocServer32"
        if ($p.TurnOn) {
            New-Item -Path $clsidPath -Force -ErrorAction SilentlyContinue | Out-Null
            Set-Item -Path $clsidPath -Value "" -Force -ErrorAction SilentlyContinue
            Log-Bg "[OK] Klasik sag tik menusu acildi."
        } else {
            Remove-Item -Path $clsidRoot -Recurse -Force -ErrorAction SilentlyContinue
            Log-Bg "[OK] Klasik sag tik menusu kapatildi; Windows 11 menusu kullanilacak."
        }
        Log-Bg "[i] Explorer yeniden baslatiliyor..."
        Start-Sleep -Milliseconds 700
        Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
        Log-Bg "[OK] Explorer yeniden baslatildi; sag tik menusu guncellendi."
    }
})

$script:BtnCleanTemp.Add_Click({
    Start-BackgroundTask (Decode-U "Gecici dosyalar ve DNS temizleniyor...") @{} {
        Log-Bg "[*] Temp, Prefetch ve DNS onbellegi temizleniyor..."
        Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "$env:windir\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "$env:windir\Prefetch\*" -Recurse -Force -ErrorAction SilentlyContinue
        ipconfig /flushdns | Out-Null
        Log-Bg "[OK] Disk, Temp ve DNS onbellegi temizlendi."
    }
})