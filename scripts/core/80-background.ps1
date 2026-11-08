# --- Genel Arka Plan Runspace Yurutucu (Donmayan Arayuz Motoru) ---
function Start-BackgroundTask([string]$TaskName, [hashtable]$Params, [scriptblock]$WorkBlock) {
    if ($sync.IsBusy) {
        Write-UiLog (Decode-U "[!] Su anda devam eden bir arka plan islemi var, lutfen bitmesini bekleyin.")
        return
    }
    $sync.IsBusy = $true
    try {
        $rs = [runspacefactory]::CreateRunspace()
        $rs.ApartmentState = "STA"
        $rs.ThreadOptions = "ReuseThread"
        $rs.Open()
    } catch {
        $sync.IsBusy = $false
        Write-UiLog ("[HATA] Arka plan runspace acilamadi: " + $_.Exception.Message)
        return
    }
    $rs.SessionStateProxy.SetVariable("sync", $sync)
    $rs.SessionStateProxy.SetVariable("TaskName", $TaskName)
    $workStr = $WorkBlock.ToString()
    $rs.SessionStateProxy.SetVariable("Params", $Params)
    $rs.SessionStateProxy.SetVariable("WorkStr", $workStr)

    $ps = [powershell]::Create()
    $ps.Runspace = $rs
    [void]$ps.AddScript({
        function Decode-Bg([string]$text) {
            if ([string]::IsNullOrEmpty($text)) { return "" }
            return [regex]::Replace($text, '\\u([0-9a-fA-F]{4})', { param($m) [char][int]("0x" + $m.Groups[1].Value) })
        }
        function Log-Bg([string]$m) {
            $t = (Get-Date).ToString("HH:mm:ss")
            $dec = Decode-Bg $m
            $sync.UiQueue.Enqueue([pscustomobject]@{ Kind = "log"; Text = "[$t] $dec" })
        }
        function Status-Bg([string]$s, [double]$p = -1) {
            $dec = Decode-Bg $s
            $sync.UiQueue.Enqueue([pscustomobject]@{ Kind = "status"; Text = $dec; Progress = $p })
        }
        function Test-WingetAvailable {
            return [bool](Get-Command "winget" -ErrorAction SilentlyContinue)
        }
        # Store urun kimligi testi arka plan runspace'inde de gerekli
        # (kaldirma/guncelleme islemleri burada calisir).
        function Test-StoreProductId([string]$pkgId) {
            if ([string]::IsNullOrWhiteSpace($pkgId)) { return $false }
            return ($pkgId.Trim() -cmatch '^[0-9A-Z]{12,20}$')
        }
        function Refresh-InstalledAppsBg {
            Status-Bg "Kurulu uygulama listesi guncelleniyor..." 95
            if (-not (Test-WingetAvailable)) {
                Log-Bg "[!] winget bulunamadi. Microsoft Store'dan 'App Installer' paketini guncelleyin."
                Status-Bg "winget bulunamadi" 100
                return
            }
            Log-Bg "[*] Winget uzerinden sistemde kurulu uygulamalar yenileniyor..."
            $rawList = (winget list --accept-source-agreements 2>$null) -join "`n"
            $found = @{}
            $boundaryOpts = [System.Text.RegularExpressions.RegexOptions]::IgnoreCase -bor [System.Text.RegularExpressions.RegexOptions]::CultureInvariant
            foreach ($id in $sync.AllAppIds) {
                $escapedId = [regex]::Escape($id)
                $pattern = "(?<![A-Za-z0-9._+\-])$escapedId(?![A-Za-z0-9._+\-])"
                if ([regex]::IsMatch($rawList, $pattern, $boundaryOpts)) {
                    $found[$id] = $true
                }
            }
            # Paylasilan tabloyu yerinde guncelle (runspace'ler arasi referans yarisi olmasin).
            $sync.InstalledApps.Clear()
            foreach ($foundId in $found.Keys) { $sync.InstalledApps[$foundId] = $true }
            $sync.RenderRequested = $true
            Log-Bg ("[OK] Kurulu uygulama listesi yenilendi (" + $found.Count + " kurulu paket).")
        }
        function Set-RegSafe([string]$Path, [string]$Name, [string]$Type, $Value) {
            # Get-ChildItem'in dondurdugu PSPath ("Microsoft.PowerShell.Core\Registry::HKEY_...")
            # veya ham "HKEY_..." yollari da desteklensin; aksi halde New-ItemProperty
            # calisir gibi gorunup deger yazilmaz.
            if ($Path -and $Path.StartsWith("Microsoft.PowerShell.Core\Registry::")) {
                $Path = $Path.Substring("Microsoft.PowerShell.Core\Registry::".Length)
            }
            if ($Path -and $Path.StartsWith("Registry::")) {
                $Path = $Path.Substring("Registry::".Length)
            }
            if ($Path -and $Path.StartsWith("HKEY_LOCAL_MACHINE")) { $Path = "HKLM:" + $Path.Substring(18) }
            elseif ($Path -and $Path.StartsWith("HKEY_CURRENT_USER")) { $Path = "HKCU:" + $Path.Substring(17) }
            elseif ($Path -and $Path.StartsWith("HKEY_CLASSES_ROOT")) { $Path = "HKCR:" + $Path.Substring(17) }
            elseif ($Path -and $Path.StartsWith("HKEY_USERS")) { $Path = "HKU:" + $Path.Substring(10) }
            try {
                if ($Path.StartsWith("HKU:\") -and !(Test-Path "HKU:\")) {
                    New-PSDrive -PSProvider Registry -Name HKU -Root HKEY_USERS -ErrorAction SilentlyContinue | Out-Null
                }
                if ($Path.StartsWith("HKCR:\") -and !(Test-Path "HKCR:\")) {
                    New-PSDrive -PSProvider Registry -Name HKCR -Root HKEY_CLASSES_ROOT -ErrorAction SilentlyContinue | Out-Null
                }
                if ($Value -eq "<RemoveEntry>") {
                    if (Test-Path $Path) {
                        Remove-ItemProperty -Path $Path -Name $Name -Force -ErrorAction SilentlyContinue
                    }
                    return
                }
                if (!(Test-Path $Path)) {
                    New-Item -Path $Path -Force -ErrorAction SilentlyContinue | Out-Null
                }
                $propType = switch ($Type) {
                    "DWord"        { "DWord" }
                    "QWord"        { "QWord" }
                    "Binary"       { "Binary" }
                    "ExpandString" { "ExpandString" }
                    "MultiString"  { "MultiString" }
                    default        { "String" }
                }
                New-ItemProperty -Path $Path -Name $Name -PropertyType $propType -Value $Value -Force -ErrorAction Stop | Out-Null
            } catch {
                # Ikinci sans: bazi sistemlerde .NET kayit defteri saglayicisi engellenir,
                # reg.exe ile ayni degeri yazmayi dene.
                $regRoot = switch -Regex ($Path) {
                    '^HKLM:\\' { "HKLM" }
                    '^HKCU:\\' { "HKCU" }
                    '^HKCR:\\' { "HKCR" }
                    '^HKU:\\'  { "HKU" }
                    default    { $null }
                }
                $regOk = $false
                if ($regRoot) {
                    $subKey = $Path -creplace '^[A-Z]+:\\', ''
                    $regKey = "$regRoot\$subKey"
                    if ($Value -eq "<RemoveEntry>") {
                        # Deger zaten yoksa silme komutu hata dondurur; bunu basari say
                        # (yanlis "[!] Reg Hatasi" logu olusmasin).
                        reg query "$regKey" /v "$Name" 2>&1 | Out-Null
                        if ($LASTEXITCODE -ne 0) {
                            $regOk = $true
                        } else {
                            reg delete "$regKey" /v "$Name" /f 2>&1 | Out-Null
                            $regOk = ($LASTEXITCODE -eq 0)
                        }
                    } else {
                        $regType = switch ($Type) {
                            "DWord"        { "REG_DWORD" }
                            "QWord"        { "REG_QWORD" }
                            "Binary"       { "REG_BINARY" }
                            "ExpandString" { "REG_EXPAND_SZ" }
                            "MultiString"  { "REG_MULTI_SZ" }
                            default        { "REG_SZ" }
                        }
                        reg add "$regKey" /v "$Name" /t $regType /d "$Value" /f 2>&1 | Out-Null
                        $regOk = ($LASTEXITCODE -eq 0)
                    }
                }
                if (-not $regOk) {
                    $protectedNames = @("ShellFeedsTaskbarViewMode", "TaskbarDa", "AllowNewsAndInterests")
                    $isDenied = ($_.Exception -is [System.UnauthorizedAccessException]) -or ($_.Exception -is [System.Security.SecurityException])
                    if ($isDenied -and ($protectedNames -contains $Name)) {
                        if ($sync.IsAdmin) {
                            Log-Bg ("[i] Sistem korumali ayar atlandi ($Name). Bu surumde Windows bu degeri salt okunur tutuyor; Ayarlar > Kisisellestirme > Gorev cubugu uzerinden kapatabilirsiniz.")
                        } else {
                            Log-Bg ("[i] Yonetici yetkisi gerektigi icin atlandi ($Name). Araci yonetici olarak calistirin: Ayarlar > Kisisellestirme > Gorev cubugu.")
                        }
                    } else {
                        $hint = ""
                        if ($isDenied) {
                            $hint = " (anahtar sistem tarafindan korumali; manuel ayar gerekebilir)"
                        }
                        Log-Bg ("[!] Reg Hatasi ($Path -> $Name): " + $_.Exception.Message + $hint)
                    }
                }
            }
        }

        try {
            Status-Bg $TaskName 5
            $sb = [scriptblock]::Create($WorkStr)
            & $sb $Params
        } catch {
            Log-Bg ("[HATA] " + $_.Exception.Message)
        } finally {
            $sync.IsBusy = $false
            Status-Bg "Hazir" 100
        }
    })
    try {
        $null = $ps.BeginInvoke()
    } catch {
        $sync.IsBusy = $false
        Write-UiLog ("[HATA] Arka plan gorevi baslatilamadi: " + $_.Exception.Message)
        try { $rs.Close(); $rs.Dispose() } catch {}
        try { $ps.Dispose() } catch {}
        return
    }
    $null = Register-ObjectEvent -InputObject $ps -EventName InvocationStateChanged -Action {
        if ($EventArgs.InvocationStateInfo.State -in @('Completed', 'Failed', 'Stopped')) {
            try {
                if ($Sender.Runspace) {
                    $Sender.Runspace.Close()
                    $Sender.Runspace.Dispose()
                }
                $Sender.Dispose()
            } catch {}
            Unregister-Event -SubscriptionId $EventSubscriber.SubscriptionId -ErrorAction SilentlyContinue
        }
    }
}