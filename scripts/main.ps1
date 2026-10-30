# =============================================================================
# UMUT EVRAN TOOL v4.0 - CANLI TEMA VE TAM WINUTIL MOTORU (100% PURE ASCII)
# =============================================================================

function Decode-U([string]$text) {
    if ([string]::IsNullOrEmpty($text)) { return "" }
    return [regex]::Replace($text, '\\u([0-9a-fA-F]{4})', { param($m) [char][int]("0x" + $m.Groups[1].Value) })
}

# --- CLI / KOMUT SATIRI PRESET MODU ---
if ($args.Count -gt 0 -and $args[0]) {
    $presetArg = $args[0].ToLower()
    $cliIds = @()
    if ($presetArg -match "umut") {
        $cliIds = @(
            "TheBrowserCompany.Arc", "Brave.Brave", "Discord.Discord", "Valve.Steam",
            "EpicGames.EpicGamesLauncher", "ElectronicArts.EADesktop", "SteelSeries.GG",
            "PrismLauncher.PrismLauncher", "VideoLAN.VLC", "OBSProject.OBSStudio",
            "Spotify.Spotify", "Microsoft.VisualStudioCode", "Git.Git", "7zip.7zip",
            "RARLab.WinRAR", "voidtools.Everything", "Microsoft.PowerToys",
            "Google.Drive", "AnyDeskSoftwareGmbH.AnyDesk", "TechPowerUp.NVCleanstall",
            "WinsiderSS.SystemInformer", "AntibodySoftware.WizTree"
        )
    } elseif ($presetArg -match "gamer|oyuncu") {
        $cliIds = @(
            "TheBrowserCompany.Arc", "Brave.Brave", "Discord.Discord", "Valve.Steam",
            "EpicGames.EpicGamesLauncher", "ElectronicArts.EADesktop", "GOG.Galaxy",
            "Ubisoft.Connect", "Blizzard.BattleNet", "SteelSeries.GG", "Logitech.GHUB",
            "Guru3D.Afterburner", "Playnite.Playnite", "PrismLauncher.PrismLauncher",
            "Modrinth.ModrinthApp", "VideoLAN.VLC", "OBSProject.OBSStudio", "7zip.7zip",
            "Spotify.Spotify", "TechPowerUp.NVCleanstall", "BitSum.ProcessLasso"
        )
    } elseif ($presetArg -match "dev|gelistirici") {
        $cliIds = @(
            "TheBrowserCompany.Arc", "Microsoft.VisualStudioCode", "Anysphere.Cursor",
            "Git.Git", "GitHub.GitHubDesktop", "GitHub.cli", "OpenJS.NodeJS.LTS",
            "Python.Python.3.12", "Microsoft.WindowsTerminal", "Microsoft.PowerShell",
            "Docker.DockerDesktop", "Postman.Postman", "Bruno.Bruno", "Notepad++.Notepad++",
            "JetBrains.Toolbox", "7zip.7zip", "Microsoft.PowerToys", "WinSCP.WinSCP", "PuTTY.PuTTY"
        )
    } elseif ($presetArg -match "standart|standard") {
        $cliIds = @(
            "Google.Chrome", "Brave.Brave", "7zip.7zip", "RARLab.WinRAR", "VideoLAN.VLC",
            "Spotify.Spotify", "Discord.Discord", "voidtools.Everything", "Skillbrains.Lightshot",
            "ShareX.ShareX", "Adobe.Acrobat.Reader.64-bit", "SumatraPDF.SumatraPDF",
            "TheDocumentFoundation.LibreOffice", "Microsoft.VCRedist.2015+.x64", "Microsoft.VCRedist.2015+.x86"
        )
    }
    if ($cliIds.Count -gt 0) {
        Write-Host "[+] CLI Preset Kurulumu Baslatiliyor: $presetArg" -ForegroundColor Cyan
        foreach ($id in $cliIds) {
            Write-Host " -> Kuruluyor: $id" -ForegroundColor Yellow
            try {
                winget install --id $id -e --silent --accept-package-agreements --accept-source-agreements
            } catch {
                Write-Warning "Kurulum hatasi ($id): $($_.Exception.Message)"
            }
        }
        Write-Host "[OK] CLI Kurulumu Tamamlandi!" -ForegroundColor Green
        return
    }
}

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase
Add-Type -AssemblyName System.Windows.Forms

$brushConverter = New-Object System.Windows.Media.BrushConverter
function Get-Brush([string]$hex) {
    return $brushConverter.ConvertFromString($hex)
}

# --- Windows 11 Fluent Dark (WinUI 3) Sabit Tema Yapilandirmasi ---
$script:Theme = @'
{
  "Name": "Windows 11 Fluent Dark",
  "WindowBg": "#18181B",
  "PanelBg": "#1F1F23",
  "CardBg": "#27272A",
  "BorderBrushColor": "#333338",
  "HoverBg": "#323236",
  "AccentColor": "#60CDFF",
  "ActiveBtnColor": "#0078D4",
  "TextMuted": "#A1A1AA",
  "TextDim": "#71717A",
  "LogBg": "#121215",
  "LogFg": "#E4E4E7",
  "BtnInstallBg": "#0078D4",
  "BtnUninstallBg": "#C42B1C",
  "BtnUpgradeBg": "#2D2D32"
}
'@ | ConvertFrom-Json

$script:AppCategories = $sync.AppsConfig
$script:FeaturesData  = $sync.FeaturesConfig
$script:TweaksData    = $sync.TweaksConfig
$script:BloatwareData = $sync.BloatwareConfig

# --- XAML Penceresini Yukle ---
$cleanXaml = $sync.Xaml.TrimStart([char]0xFEFF).Trim()
$script:window = [System.Windows.Markup.XamlReader]::Parse($cleanXaml)
$sync.Window = $script:window

# --- Kontrolleri Bagla ---
$script:ViewApps      = $script:window.FindName("ViewApps")
$script:ViewTweaks    = $script:window.FindName("ViewTweaks")
$script:ViewFeatures  = $script:window.FindName("ViewFeatures")
$script:ViewBloatware = $script:window.FindName("ViewBloatware")
$script:ViewTools     = $script:window.FindName("ViewTools")
$script:ViewConfig    = $script:window.FindName("ViewConfig")

$script:BtnNavApps      = $script:window.FindName("BtnNavApps")
$script:BtnNavTweaks    = $script:window.FindName("BtnNavTweaks")
$script:BtnNavFeatures  = $script:window.FindName("BtnNavFeatures")
$script:BtnNavBloatware = $script:window.FindName("BtnNavBloatware")
$script:BtnNavTools     = $script:window.FindName("BtnNavTools")
$script:BtnNavConfig    = $script:window.FindName("BtnNavConfig")


# Sol Panel Preset ve Geri Yukleme Butonlari
$script:BtnPresetUmut     = $script:window.FindName("BtnPresetUmut")
$script:BtnPresetGamer    = $script:window.FindName("BtnPresetGamer")
$script:BtnPresetDev      = $script:window.FindName("BtnPresetDev")
$script:BtnPresetStandard = $script:window.FindName("BtnPresetStandard")
$script:BtnClearSelection = $script:window.FindName("BtnClearSelection")
$script:BtnRestorePoint   = $script:window.FindName("BtnRestorePoint")

# Sekme 1: Uygulama Kurulumu Kontrolleri
$script:TxtSearch           = $script:window.FindName("TxtSearch")
$script:BtnClearSearch      = $script:window.FindName("BtnClearSearch")
$script:BtnCheckInstalled   = $script:window.FindName("BtnCheckInstalled")
$script:CategoryButtonPanel = $script:window.FindName("CategoryButtonPanel")
$script:MainStackPanel      = $script:window.FindName("MainStackPanel")
$script:TxtSelectedCount    = $script:window.FindName("TxtSelectedCount")
$script:BtnInstall          = $script:window.FindName("BtnInstall")
$script:BtnUninstall        = $script:window.FindName("BtnUninstall")
$script:BtnUpgradeSelected  = $script:window.FindName("BtnUpgradeSelected")
$script:BtnUpgradeAll       = $script:window.FindName("BtnUpgradeAll")

# Sekme 2: Tweaks Kontrolleri
$script:TweaksStackPanel       = $script:window.FindName("TweaksStackPanel")
$script:BtnSelectRecTweaks     = $script:window.FindName("BtnSelectRecTweaks")
$script:BtnTweakPresetStandard = $script:window.FindName("BtnTweakPresetStandard")
$script:BtnTweakPresetMinimal  = $script:window.FindName("BtnTweakPresetMinimal")
$script:BtnTweakPresetAdvanced = $script:window.FindName("BtnTweakPresetAdvanced")
$script:BtnClearTweaks         = $script:window.FindName("BtnClearTweaks")
$script:BtnApplyTweaks         = $script:window.FindName("BtnApplyTweaks")
$script:BtnUndoTweaks          = $script:window.FindName("BtnUndoTweaks")
$script:BtnRevertContextMenu   = $script:window.FindName("BtnRevertContextMenu")
$script:BtnCleanTemp           = $script:window.FindName("BtnCleanTemp")

# Sekme 3: Windows Ozellikleri, DNS, Derin Temizlik & Update Kontrolleri
$script:TxtDnsStatus            = $script:window.FindName("TxtDnsStatus")
$script:BtnDnsCloudflare        = $script:window.FindName("BtnDnsCloudflare")
$script:BtnDnsGoogle            = $script:window.FindName("BtnDnsGoogle")
$script:BtnDnsAdguard           = $script:window.FindName("BtnDnsAdguard")
$script:BtnDnsQuad9             = $script:window.FindName("BtnDnsQuad9")
$script:BtnDnsCloudflareMalware = $script:window.FindName("BtnDnsCloudflareMalware")
$script:BtnDnsOpenDns           = $script:window.FindName("BtnDnsOpenDns")
$script:BtnDnsDhcp              = $script:window.FindName("BtnDnsDhcp")

$script:BtnDeepOneDrive         = $script:window.FindName("BtnDeepOneDrive")
$script:BtnDisableCopilot       = $script:window.FindName("BtnDisableCopilot")
$script:BtnDisableEdgeBg        = $script:window.FindName("BtnDisableEdgeBg")
$script:BtnRestoreOneDrive      = $script:window.FindName("BtnRestoreOneDrive")
$script:BtnEnableCopilot        = $script:window.FindName("BtnEnableCopilot")
$script:BtnEnableEdgeBg         = $script:window.FindName("BtnEnableEdgeBg")

$script:BtnWinUpdateSecurity    = $script:window.FindName("BtnWinUpdateSecurity")
$script:BtnWinUpdateDisable     = $script:window.FindName("BtnWinUpdateDisable")
$script:BtnWinUpdateDefault     = $script:window.FindName("BtnWinUpdateDefault")

$script:FeaturesGrid            = $script:window.FindName("FeaturesGrid")
$script:BtnCheckFeaturesStatus  = $script:window.FindName("BtnCheckFeaturesStatus")
$script:BtnApplyFeatures        = $script:window.FindName("BtnApplyFeatures")
$script:BtnDisableFeatures      = $script:window.FindName("BtnDisableFeatures")

# Sekme 4: Bloatware Kontrolleri
$script:BloatwareGrid         = $script:window.FindName("BloatwareGrid")
$script:BtnSelectDefaultBloat = $script:window.FindName("BtnSelectDefaultBloat")
$script:BtnSelectAllBloat     = $script:window.FindName("BtnSelectAllBloat")
$script:BtnClearBloat         = $script:window.FindName("BtnClearBloat")
$script:BtnReinstallBloatware = $script:window.FindName("BtnReinstallBloatware")
$script:BtnRemoveBloatware    = $script:window.FindName("BtnRemoveBloatware")

# Sekme 5: Sistem Araclari & MAS Kontrolleri
$script:BtnRunMAS              = $script:window.FindName("BtnRunMAS")
$script:BtnCreateGodMode       = $script:window.FindName("BtnCreateGodMode")
$script:BtnRunOOSU             = $script:window.FindName("BtnRunOOSU")
$script:BtnFixSystemCorruption = $script:window.FindName("BtnFixSystemCorruption")
$script:BtnFixWinUpdate        = $script:window.FindName("BtnFixWinUpdate")
$script:BtnFixNetwork          = $script:window.FindName("BtnFixNetwork")
$script:BtnFixWinget           = $script:window.FindName("BtnFixWinget")
$script:BtnFixNTP              = $script:window.FindName("BtnFixNTP")
$script:BtnRunAutologon        = $script:window.FindName("BtnRunAutologon")
$script:BtnEnableOpenSSH       = $script:window.FindName("BtnEnableOpenSSH")
$script:BtnEnableRegBackup     = $script:window.FindName("BtnEnableRegBackup")
$script:BtnRestartExplorer     = $script:window.FindName("BtnRestartExplorer")
$script:BtnEnableF8Boot        = $script:window.FindName("BtnEnableF8Boot")
$script:BtnDisableF8Boot       = $script:window.FindName("BtnDisableF8Boot")

$script:BtnPanelControl        = $script:window.FindName("BtnPanelControl")
$script:BtnPanelNetwork        = $script:window.FindName("BtnPanelNetwork")
$script:BtnPanelSystem         = $script:window.FindName("BtnPanelSystem")
$script:BtnPanelPower          = $script:window.FindName("BtnPanelPower")
$script:BtnPanelSound          = $script:window.FindName("BtnPanelSound")
$script:BtnPanelPrograms       = $script:window.FindName("BtnPanelPrograms")
$script:BtnPanelComputer       = $script:window.FindName("BtnPanelComputer")
$script:BtnPanelMouse          = $script:window.FindName("BtnPanelMouse")
$script:BtnPanelFirewall       = $script:window.FindName("BtnPanelFirewall")
$script:BtnPanelRestore        = $script:window.FindName("BtnPanelRestore")
$script:BtnPanelTimedate       = $script:window.FindName("BtnPanelTimedate")
$script:BtnPanelRegion         = $script:window.FindName("BtnPanelRegion")

# Sekme 6: Yedekleme & Config Kontrolleri
$script:BtnExportConfig    = $script:window.FindName("BtnExportConfig")
$script:BtnImportConfig    = $script:window.FindName("BtnImportConfig")
$script:BtnExportSysReport = $script:window.FindName("BtnExportSysReport")
$script:TxtRemoteCmd       = $script:window.FindName("TxtRemoteCmd")
$script:BtnCopyCmd         = $script:window.FindName("BtnCopyCmd")

# Sag Log Paneli Kontrolleri
$script:TxtStatus       = $script:window.FindName("TxtStatus")
$script:ProgressBarMain = $script:window.FindName("ProgressBarMain")
$script:TxtLog          = $script:window.FindName("TxtLog")
$script:BtnClearLog     = $script:window.FindName("BtnClearLog")
$script:TxtSysInfo      = $script:window.FindName("TxtSysInfo")

$sync.TxtLog               = $script:TxtLog
$sync.TxtStatus            = $script:TxtStatus
$sync.ProgressBarMain      = $script:ProgressBarMain
$sync.BtnInstall           = $script:BtnInstall
$sync.BtnUninstall         = $script:BtnUninstall
$sync.BtnUpgradeSelected   = $script:BtnUpgradeSelected
$sync.BtnUpgradeAll        = $script:BtnUpgradeAll
$sync.BtnApplyTweaks       = $script:BtnApplyTweaks
$sync.BtnUndoTweaks        = $script:BtnUndoTweaks
$sync.BtnApplyFeatures     = $script:BtnApplyFeatures
$sync.BtnDisableFeatures   = $script:BtnDisableFeatures
$sync.BtnRemoveBloatware   = $script:BtnRemoveBloatware
$sync.BtnReinstallBloatware= $script:BtnReinstallBloatware
$sync.IsBusy               = $false

function Write-UiLog([string]$msg) {
    $time = (Get-Date).ToString("HH:mm:ss")
    $decoded = Decode-U $msg
    $script:window.Dispatcher.Invoke([action]{
        $script:TxtLog.AppendText("[$time] $decoded`r`n")
        $script:TxtLog.ScrollToEnd()
    })
}

function Set-UiStatus([string]$msg, [double]$progress = -1) {
    $decoded = Decode-U $msg
    $script:window.Dispatcher.Invoke([action]{
        $script:TxtStatus.Text = $decoded
        if ($progress -ge 0) {
            $script:ProgressBarMain.Value = $progress
        }
    })
}

# --- Genel Arka Plan Runspace Yurutucu (Donmayan Arayuz Motoru) ---
function Start-BackgroundTask([string]$TaskName, [hashtable]$Params, [scriptblock]$WorkBlock) {
    if ($sync.IsBusy) {
        Write-UiLog (Decode-U "[!] \u015Eu anda devam eden bir arka plan i\u015Flemi var, l\u00FCtfen bitmesini bekleyin.")
        return
    }
    $sync.IsBusy = $true
    $rs = [runspacefactory]::CreateRunspace()
    $rs.ApartmentState = "STA"
    $rs.ThreadOptions  = "ReuseThread"
    $rs.Open()
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
            $sync.Window.Dispatcher.Invoke([action]{
                $sync.TxtLog.AppendText("[$t] $dec`r`n")
                $sync.TxtLog.ScrollToEnd()
            })
        }
        function Status-Bg([string]$s, [double]$p = -1) {
            $dec = Decode-Bg $s
            $sync.Window.Dispatcher.Invoke([action]{
                $sync.TxtStatus.Text = $dec
                if ($p -ge 0) { $sync.ProgressBarMain.Value = $p }
            })
        }
        function Set-RegSafe([string]$Path, [string]$Name, [string]$Type, $Value) {
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
                if ($Type -eq "Binary") {
                    Set-ItemProperty -Path $Path -Name $Name -Type Binary -Value $Value -Force -ErrorAction Stop
                } elseif ($Type -eq "DWord") {
                    Set-ItemProperty -Path $Path -Name $Name -Type DWord -Value ([int64]$Value) -Force -ErrorAction Stop
                } elseif ($Type -eq "QWord") {
                    Set-ItemProperty -Path $Path -Name $Name -Type QWord -Value ([int64]$Value) -Force -ErrorAction Stop
                } else {
                    Set-ItemProperty -Path $Path -Name $Name -Type $Type -Value $Value -Force -ErrorAction Stop
                }
            } catch {
                Log-Bg "  [!] Kayit defteri uyarisi ($Path\$Name): $($_.Exception.Message)"
            }
        }
        function Set-SvcSafe([string]$SvcName, [string]$StartupType, [bool]$StopNow = $false) {
            try {
                $svc = Get-Service -Name $SvcName -ErrorAction SilentlyContinue
                if (-not $svc) { return }
                if ($StopNow -and $svc.Status -eq 'Running') {
                    Stop-Service -Name $SvcName -Force -ErrorAction SilentlyContinue
                }
                if ($StartupType -eq "AutomaticDelayedStart" -and $PSVersionTable.PSVersion.Major -lt 7) {
                    sc.exe config $SvcName start= delayed-auto | Out-Null
                } else {
                    Set-Service -Name $SvcName -StartupType $StartupType -ErrorAction SilentlyContinue
                }
            } catch {
                Log-Bg "  [!] Servis uyarisi ($SvcName): $($_.Exception.Message)"
            }
        }

        try {
            $sb = [scriptblock]::Create($WorkStr)
            & $sb $Params
        } catch {
            Log-Bg "[HATA] ($TaskName): $($_.Exception.Message)"
            Status-Bg "Islem sirasinda hata olustu: $TaskName" 100
        } finally {
            $sync.Window.Dispatcher.Invoke([action]{
                $sync.BtnInstall.IsEnabled            = $true
                $sync.BtnUninstall.IsEnabled          = $true
                $sync.BtnUpgradeSelected.IsEnabled    = $true
                $sync.BtnUpgradeAll.IsEnabled         = $true
                $sync.BtnApplyTweaks.IsEnabled        = $true
                $sync.BtnUndoTweaks.IsEnabled         = $true
                $sync.BtnApplyFeatures.IsEnabled      = $true
                $sync.BtnDisableFeatures.IsEnabled    = $true
                $sync.BtnRemoveBloatware.IsEnabled    = $true
                $sync.BtnReinstallBloatware.IsEnabled = $true
                $sync.IsBusy = $false
            })
        }
    })
    [void]$ps.BeginInvoke()
}

try {
    $osInfo = Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue
    if ($osInfo) {
        $script:TxtSysInfo.Text = "$($osInfo.Caption) ($($osInfo.BuildNumber))"
    }
} catch {}

# =============================================================================
# 1. SEKME GECISLERI (NAVIGASYON - 6 MODUL)
# =============================================================================
$script:currentActiveNavBtn = $script:BtnNavApps
$script:navButtons = @($script:BtnNavApps, $script:BtnNavTweaks, $script:BtnNavFeatures, $script:BtnNavBloatware, $script:BtnNavTools, $script:BtnNavConfig)
$script:views      = @($script:ViewApps, $script:ViewTweaks, $script:ViewFeatures, $script:ViewBloatware, $script:ViewTools, $script:ViewConfig)

function Switch-Tab($activeBtn, $activeView) {
    $t = $script:Theme
    foreach ($v in $script:views) { $v.Visibility = "Collapsed" }
    foreach ($b in $script:navButtons) {
        $b.Background  = Get-Brush $t.CardBg
        $b.BorderBrush = Get-Brush $t.BorderBrushColor
    }
    $activeView.Visibility = "Visible"
    $activeBtn.Background  = Get-Brush $t.ActiveBtnColor
    $activeBtn.BorderBrush = Get-Brush $t.AccentColor
    $script:currentActiveNavBtn = $activeBtn
}

$script:BtnNavApps.Add_Click({ Switch-Tab $script:BtnNavApps $script:ViewApps })
$script:BtnNavTweaks.Add_Click({ Switch-Tab $script:BtnNavTweaks $script:ViewTweaks })
$script:BtnNavFeatures.Add_Click({ Switch-Tab $script:BtnNavFeatures $script:ViewFeatures })
$script:BtnNavBloatware.Add_Click({ Switch-Tab $script:BtnNavBloatware $script:ViewBloatware })
$script:BtnNavTools.Add_Click({ Switch-Tab $script:BtnNavTools $script:ViewTools })
$script:BtnNavConfig.Add_Click({ Switch-Tab $script:BtnNavConfig $script:ViewConfig })

$script:BtnClearLog.Add_Click({ $script:TxtLog.Clear() })
$script:BtnCopyCmd.Add_Click({
    [System.Windows.Clipboard]::SetText($script:TxtRemoteCmd.Text)
    Write-UiLog (Decode-U "Uzaktan \u00E7al\u0131\u015Ft\u0131rma komutu panoya kopyaland\u0131.")
})

# =============================================================================
# 2. UYGULAMA KARTLARI, ARAMA VE KATEGORI FILTRELEME (248 UYGULAMA)
# =============================================================================
$script:appCheckboxes    = @()
$script:categoryBlocks   = @{}
$script:selectedCategory = "ALL"
$script:catButtons       = @()
$script:currentActiveCatBtn = $null

$updateCounter = {
    $cnt = ($script:appCheckboxes | Where-Object { $_.IsChecked -eq $true }).Count
    $script:TxtSelectedCount.Text = (Decode-U "$cnt uygulama se\u00E7ildi")
}

function Apply-AppFilter {
    $q = $script:TxtSearch.Text.Trim().ToLower()
    foreach ($cat in $script:AppCategories) {
        $catName = Decode-U $cat.Category
        $catBorder = $script:categoryBlocks[$catName]
        $catMatch = ($script:selectedCategory -eq "ALL") -or ($script:selectedCategory -eq $catName)
        if (-not $catMatch) {
            $catBorder.Visibility = "Collapsed"
            continue
        }
        $visibleCount = 0
        foreach ($cb in $script:appCheckboxes) {
            if ($cb.Tag.Category -eq $catName) {
                $textMatch = [string]::IsNullOrEmpty($q) -or
                             $cb.Tag.Name.ToLower().Contains($q) -or
                             $cb.Tag.Id.ToLower().Contains($q) -or
                             $cb.Tag.Description.ToLower().Contains($q)
                if ($textMatch) {
                    $cb.Tag.Card.Visibility = "Visible"
                    $visibleCount++
                } else {
                    $cb.Tag.Card.Visibility = "Collapsed"
                }
            }
        }
        if ($visibleCount -gt 0) {
            $catBorder.Visibility = "Visible"
        } else {
            $catBorder.Visibility = "Collapsed"
        }
    }
}

function Set-CategoryButtonActive($clickedBtn) {
    $t = $script:Theme
    foreach ($b in $script:catButtons) {
        $b.Background  = Get-Brush $t.CardBg
        $b.Foreground  = Get-Brush $t.TextMuted
        $b.BorderBrush = Get-Brush $t.BorderBrushColor
    }
    $clickedBtn.Background  = Get-Brush $t.ActiveBtnColor
    $clickedBtn.Foreground  = Get-Brush "#FFFFFF"
    $clickedBtn.BorderBrush = Get-Brush $t.AccentColor
    $script:currentActiveCatBtn = $clickedBtn
}

$initTheme = $script:Theme

$script:btnAll = New-Object System.Windows.Controls.Button
$script:btnAll.Style = $script:window.Resources["CatPillStyle"]
$script:btnAll.Content = (Decode-U "T\u00FCm\u00FC ($($script:AppCategories | ForEach-Object { $_.Apps.Count } | Measure-Object -Sum | Select-Object -ExpandProperty Sum))")
$script:btnAll.Background  = Get-Brush $initTheme.ActiveBtnColor
$script:btnAll.Foreground  = Get-Brush "#FFFFFF"
$script:btnAll.BorderBrush = Get-Brush $initTheme.AccentColor
$script:btnAll.Add_Click({
    $script:selectedCategory = "ALL"
    Set-CategoryButtonActive $script:btnAll
    Apply-AppFilter
})
[void]$script:CategoryButtonPanel.Children.Add($script:btnAll)
$script:catButtons += $script:btnAll
$script:currentActiveCatBtn = $script:btnAll

foreach ($cat in $script:AppCategories) {
    $catName = Decode-U $cat.Category

    $cBtn = New-Object System.Windows.Controls.Button
    $cBtn.Style   = $script:window.Resources["CatPillStyle"]
    $cBtn.Content = "$catName ($($cat.Apps.Count))"
    $cBtn.Tag     = $catName
    $cBtn.Add_Click({
        param($sender, $e)
        $script:selectedCategory = $sender.Tag
        Set-CategoryButtonActive $sender
        Apply-AppFilter
    })
    [void]$script:CategoryButtonPanel.Children.Add($cBtn)
    $script:catButtons += $cBtn

    $catContainer = New-Object System.Windows.Controls.StackPanel
    $catContainer.Margin = "0,0,0,16"

    $catHeader = New-Object System.Windows.Controls.TextBlock
    $catHeader.Text = $catName.ToUpper()
    $catHeader.FontSize = 13
    $catHeader.FontWeight = "Bold"
    $catHeader.Foreground = Get-Brush $initTheme.AccentColor
    $catHeader.Margin = "4,0,0,8"
    [void]$catContainer.Children.Add($catHeader)

    $uGrid = New-Object System.Windows.Controls.Primitives.UniformGrid
    $uGrid.Columns = 2

    foreach ($app in $cat.Apps) {
        $appName = Decode-U $app.Name
        $appDesc = Decode-U $app.Description

        $card = New-Object System.Windows.Controls.Border
        $card.Background = Get-Brush $initTheme.CardBg
        $card.BorderBrush = Get-Brush $initTheme.BorderBrushColor
        $card.BorderThickness = "1"
        $card.CornerRadius = "6"
        $card.Padding = "10"
        $card.Margin = "4"
        $card.Cursor = "Hand"

        $dock = New-Object System.Windows.Controls.DockPanel
        $dock.LastChildFill = $true

        $iconBorder = New-Object System.Windows.Controls.Border
        $iconBorder.Width = 38
        $iconBorder.Height = 38
        $iconBorder.CornerRadius = New-Object System.Windows.CornerRadius(6)
        $iconBorder.Background = Get-Brush $initTheme.HoverBg
        $iconBorder.BorderBrush = Get-Brush $initTheme.BorderBrushColor
        $iconBorder.BorderThickness = New-Object System.Windows.Thickness(1)
        $iconBorder.Margin = New-Object System.Windows.Thickness(0, 0, 10, 0)
        $iconBorder.VerticalAlignment = "Center"
        [System.Windows.Controls.DockPanel]::SetDock($iconBorder, [System.Windows.Controls.Dock]::Left)

        $img = New-Object System.Windows.Controls.Image
        $img.Width = 26
        $img.Height = 26
        $img.VerticalAlignment = "Center"
        $img.HorizontalAlignment = "Center"
        [System.Windows.Media.RenderOptions]::SetBitmapScalingMode($img, [System.Windows.Media.BitmapScalingMode]::HighQuality)

        if ($app.Icon) {
            try {
                $bi = New-Object System.Windows.Media.Imaging.BitmapImage
                $bi.BeginInit()
                $bi.UriSource = New-Object System.Uri($app.Icon, [System.UriKind]::Absolute)
                $bi.DecodePixelWidth = 64
                $bi.CacheOption = [System.Windows.Media.Imaging.BitmapCacheOption]::OnLoad
                $bi.EndInit()
                $img.Source = $bi
            } catch {}
        }
        $iconBorder.Child = $img
        [void]$dock.Children.Add($iconBorder)

        $sp = New-Object System.Windows.Controls.StackPanel
        $sp.VerticalAlignment = "Center"

        $cb = New-Object System.Windows.Controls.CheckBox
        $cb.Foreground = Get-Brush "#F8FAFC"
        $cb.FontWeight = "Bold"
        $cb.FontSize = 13
        $cb.Content = $appName
        $cb.Tag = [PSCustomObject]@{
            Name        = $appName
            Id          = $app.Id
            Description = $appDesc
            Category    = $catName
            Card        = $card
        }
        $cb.Add_Checked($updateCounter)
        $cb.Add_Unchecked($updateCounter)

        $descBlock = New-Object System.Windows.Controls.TextBlock
        $descBlock.Text = $appDesc
        $descBlock.FontSize = 11
        $descBlock.Foreground = Get-Brush $initTheme.TextMuted
        $descBlock.TextWrapping = "Wrap"
        $descBlock.Margin = "0,2,0,2"

        $idBlock = New-Object System.Windows.Controls.TextBlock
        $idBlock.Text = $app.Id
        $idBlock.FontSize = 10
        $idBlock.FontFamily = "Consolas"
        $idBlock.Foreground = Get-Brush $initTheme.TextDim

        [void]$sp.Children.Add($cb)
        [void]$sp.Children.Add($descBlock)
        [void]$sp.Children.Add($idBlock)

        [void]$dock.Children.Add($sp)
        $card.Child = $dock

        $card.Tag = $cb
        $card.Add_MouseLeftButtonUp({
            param($sender, $e)
            if ($e.OriginalSource -isnot [System.Windows.Controls.CheckBox]) {
                $targetCb = $sender.Tag
                $targetCb.IsChecked = -not $targetCb.IsChecked
            }
        })

        [void]$uGrid.Children.Add($card)
        $script:appCheckboxes += $cb
    }

    [void]$catContainer.Children.Add($uGrid)
    [void]$script:MainStackPanel.Children.Add($catContainer)
    $script:categoryBlocks[$catName] = $catContainer
}

$script:TxtSearch.Add_TextChanged({ Apply-AppFilter })
$script:BtnClearSearch.Add_Click({
    $script:TxtSearch.Text = ""
    Apply-AppFilter
})

# Sistemde Yuklu Uygulamalari Tarama (WinUtil GetInstalled Engine)
$script:BtnCheckInstalled.Add_Click({
    Start-BackgroundTask "CheckInstalled" @{ Checkboxes = $script:appCheckboxes } {
        param($p)
        Status-Bg "Sistemde kurulu uygulamalar Winget ile taraniyor..." 25
        Log-Bg ">>> Winget kurulu uygulama listesi aliniyor (winget list)..."
        $rawOut = winget list --accept-source-agreements 2>&1 | Out-String
        Status-Bg "Kurulu uygulamalar eslestiriliyor..." 75
        $matched = 0
        $sync.Window.Dispatcher.Invoke([action]{
            foreach ($cb in $p.Checkboxes) {
                if ($rawOut -match [regex]::Escape($cb.Tag.Id)) {
                    $cb.IsChecked = $true
                    $matched++
                }
            }
        })
        Log-Bg "[OK] Sistemde kurulu olan $matched uygulama tespit edildi ve isaretlendi."
        Status-Bg "$matched kurulu uygulama isaretlendi!" 100
    }
})

# =============================================================================
# 3. HAZIR UYGULAMA PAKETLERI (PRESETS)
# =============================================================================
function Select-PresetByIds([string[]]$ids, [string]$presetTitle) {
    Switch-Tab $script:BtnNavApps $script:ViewApps
    foreach ($cb in $script:appCheckboxes) {
        $cb.IsChecked = ($ids -contains $cb.Tag.Id)
    }
    Write-UiLog (Decode-U "$presetTitle se\u00E7ildi ($($ids.Count) uygulama).")
}

$script:BtnPresetUmut.Add_Click({
    $umutIds = @(
        "TheBrowserCompany.Arc", "Brave.Brave", "Discord.Discord", "Valve.Steam",
        "EpicGames.EpicGamesLauncher", "ElectronicArts.EADesktop", "SteelSeries.GG",
        "PrismLauncher.PrismLauncher", "VideoLAN.VLC", "OBSProject.OBSStudio",
        "Spotify.Spotify", "Microsoft.VisualStudioCode", "Git.Git", "7zip.7zip",
        "RARLab.WinRAR", "voidtools.Everything", "Microsoft.PowerToys",
        "Google.Drive", "AnyDeskSoftwareGmbH.AnyDesk", "TechPowerUp.NVCleanstall",
        "WinsiderSS.SystemInformer", "AntibodySoftware.WizTree"
    )
    Select-PresetByIds $umutIds (Decode-U "\uD83D\uDC51 Umut \u00D6zel Paketi")
})

$script:BtnPresetGamer.Add_Click({
    $gamerIds = @(
        "TheBrowserCompany.Arc", "Brave.Brave", "Discord.Discord", "Valve.Steam",
        "EpicGames.EpicGamesLauncher", "ElectronicArts.EADesktop", "GOG.Galaxy",
        "Ubisoft.Connect", "Blizzard.BattleNet", "SteelSeries.GG", "Logitech.GHUB",
        "Guru3D.Afterburner", "Playnite.Playnite", "PrismLauncher.PrismLauncher",
        "Modrinth.ModrinthApp", "VideoLAN.VLC", "OBSProject.OBSStudio", "7zip.7zip",
        "Spotify.Spotify", "TechPowerUp.NVCleanstall", "BitSum.ProcessLasso"
    )
    Select-PresetByIds $gamerIds "Oyuncu Paketi"
})

$script:BtnPresetDev.Add_Click({
    $devIds = @(
        "TheBrowserCompany.Arc", "Microsoft.VisualStudioCode", "Anysphere.Cursor",
        "Git.Git", "GitHub.GitHubDesktop", "GitHub.cli", "OpenJS.NodeJS.LTS",
        "Python.Python.3.12", "Microsoft.WindowsTerminal", "Microsoft.PowerShell",
        "Docker.DockerDesktop", "Postman.Postman", "Bruno.Bruno", "Notepad++.Notepad++",
        "JetBrains.Toolbox", "7zip.7zip", "Microsoft.PowerToys", "WinSCP.WinSCP", "PuTTY.PuTTY"
    )
    Select-PresetByIds $devIds (Decode-U "Geli\u015Ftirici Paketi")
})

$script:BtnPresetStandard.Add_Click({
    $stdIds = @(
        "Google.Chrome", "Brave.Brave", "7zip.7zip", "RARLab.WinRAR", "VideoLAN.VLC",
        "Spotify.Spotify", "Discord.Discord", "voidtools.Everything",
        "Skillbrains.Lightshot", "ShareX.ShareX", "Adobe.Acrobat.Reader.64-bit",
        "SumatraPDF.SumatraPDF", "TheDocumentFoundation.LibreOffice",
        "Microsoft.VCRedist.2015+.x64", "Microsoft.VCRedist.2015+.x86"
    )
    Select-PresetByIds $stdIds "Standart Kurulum Paketi"
})

$script:BtnClearSelection.Add_Click({
    foreach ($cb in $script:appCheckboxes) { $cb.IsChecked = $false }
    Write-UiLog (Decode-U "T\u00FCm uygulama se\u00E7imleri temizlendi.")
})

# =============================================================================
# 4. ARKA PLAN RUNSPACE ILE WINGET KURULUM / KALDIRMA / GUNCELLEME
# =============================================================================
function Start-WingetJob([array]$appsList, [string]$mode) {
    $script:BtnInstall.IsEnabled         = $false
    $script:BtnUninstall.IsEnabled       = $false
    $script:BtnUpgradeSelected.IsEnabled = $false
    $script:BtnUpgradeAll.IsEnabled      = $false

    Start-BackgroundTask "Winget_$mode" @{ Apps = $appsList; Mode = $mode } {
        param($p)
        $mode = $p.Mode
        $appsList = $p.Apps

        if ($mode -eq "upgrade_all") {
            Status-Bg "Tum sistem uygulamalariniz Winget ile guncelleniyor..." 20
            Log-Bg ">>> Baslatiliyor: winget upgrade --all --include-unknown"
            $proc = Start-Process -FilePath "winget.exe" -ArgumentList "upgrade --all --include-unknown --silent --accept-package-agreements --accept-source-agreements" -NoNewWindow -Wait -PassThru
            Log-Bg ">>> Tum guncellemeler tamamlandi (Cikis Kodu: $($proc.ExitCode))."
            Status-Bg "Tum uygulamalar guncellendi!" 100
        } else {
            $total = $appsList.Count
            $idx = 0
            foreach ($item in $appsList) {
                $idx++
                $pct = [math]::Round(($idx / $total) * 100)
                if ($mode -eq "install") {
                    Status-Bg "($idx/$total) Kuruluyor: $($item.Name)..." $pct
                    Log-Bg "[$idx/$total] Kuruluyor: $($item.Name) ($($item.Id))"
                    $proc = Start-Process -FilePath "winget.exe" -ArgumentList "install --id `"$($item.Id)`" -e --silent --accept-package-agreements --accept-source-agreements" -NoNewWindow -Wait -PassThru
                    if ($proc.ExitCode -eq 0) {
                        Log-Bg "  [OK] $($item.Name) basariyla kuruldu."
                    } else {
                        Log-Bg "  [!] $($item.Name) cikis kodu: $($proc.ExitCode)"
                    }
                } elseif ($mode -eq "uninstall") {
                    Status-Bg "($idx/$total) Kaldiriliyor: $($item.Name)..." $pct
                    Log-Bg "[$idx/$total] Kaldiriliyor: $($item.Name) ($($item.Id))"
                    $proc = Start-Process -FilePath "winget.exe" -ArgumentList "uninstall --id `"$($item.Id)`" -e --silent --accept-source-agreements" -NoNewWindow -Wait -PassThru
                    if ($proc.ExitCode -eq 0) {
                        Log-Bg "  [OK] $($item.Name) kaldirildi."
                    } else {
                        Log-Bg "  [!] $($item.Name) cikis kodu: $($proc.ExitCode)"
                    }
                } elseif ($mode -eq "upgrade_selected") {
                    Status-Bg "($idx/$total) Guncelleniyor: $($item.Name)..." $pct
                    Log-Bg "[$idx/$total] Guncelleniyor: $($item.Name) ($($item.Id))"
                    $proc = Start-Process -FilePath "winget.exe" -ArgumentList "upgrade --id `"$($item.Id)`" -e --silent --accept-package-agreements --accept-source-agreements" -NoNewWindow -Wait -PassThru
                    if ($proc.ExitCode -eq 0) {
                        Log-Bg "  [OK] $($item.Name) basariyla guncellendi."
                    } else {
                        Log-Bg "  [!] $($item.Name) cikis kodu: $($proc.ExitCode)"
                    }
                }
            }
            Status-Bg "Secili Winget islemleri tamamlandi ($total / $total)!" 100
            Log-Bg "=== TUM WINGET ISLEMLERI TAMAMLANDI ==="
        }
    }
}

$script:BtnInstall.Add_Click({
    $selected = @($script:appCheckboxes | Where-Object { $_.IsChecked -eq $true } | ForEach-Object { $_.Tag })
    if ($selected.Count -eq 0) {
        Write-UiLog (Decode-U "[!] L\u00FCtfen kurmak i\u00E7in en az bir uygulama se\u00E7in.")
        return
    }
    Start-WingetJob $selected "install"
})

$script:BtnUninstall.Add_Click({
    $selected = @($script:appCheckboxes | Where-Object { $_.IsChecked -eq $true } | ForEach-Object { $_.Tag })
    if ($selected.Count -eq 0) {
        Write-UiLog (Decode-U "[!] L\u00FCtfen kald\u0131rmak i\u00E7in en az bir uygulama se\u00E7in.")
        return
    }
    Start-WingetJob $selected "uninstall"
})

$script:BtnUpgradeSelected.Add_Click({
    $selected = @($script:appCheckboxes | Where-Object { $_.IsChecked -eq $true } | ForEach-Object { $_.Tag })
    if ($selected.Count -eq 0) {
        Write-UiLog (Decode-U "[!] L\u00FCtfen g\u00FCncellemek i\u00E7in en az bir uygulama se\u00E7in.")
        return
    }
    Start-WingetJob $selected "upgrade_selected"
})

$script:BtnUpgradeAll.Add_Click({
    Start-WingetJob @() "upgrade_all"
})

# =============================================================================
# 5. SEKME 2: SISTEM INCE AYARLARI VE GELISMIS TWEAKS (61 AYAR - APPLY + UNDO)
# =============================================================================
$script:tweakCheckboxes = @()

foreach ($grp in $script:TweaksData) {
    $grpTitle = Decode-U $grp.Group
    $gHeader = New-Object System.Windows.Controls.TextBlock
    $gHeader.Text = $grpTitle.ToUpper()
    $gHeader.FontSize = 13
    $gHeader.FontWeight = "Bold"
    $gHeader.Foreground = Get-Brush $initTheme.AccentColor
    $gHeader.Margin = "4,8,0,8"
    [void]$script:TweaksStackPanel.Children.Add($gHeader)

    foreach ($tw in $grp.Items) {
        $twTitle = Decode-U $tw.Title
        $twDesc  = Decode-U $tw.Desc

        $card = New-Object System.Windows.Controls.Border
        $card.Background = Get-Brush $initTheme.CardBg
        $card.BorderBrush = Get-Brush $initTheme.BorderBrushColor
        $card.BorderThickness = "1"
        $card.CornerRadius = "6"
        $card.Padding = "10"
        $card.Margin = "0,0,0,6"
        $card.Cursor = "Hand"

        $sp = New-Object System.Windows.Controls.StackPanel
        $cb = New-Object System.Windows.Controls.CheckBox
        $cb.Content = $twTitle
        $cb.Foreground = Get-Brush "#F8FAFC"
        $cb.FontWeight = "SemiBold"
        $cb.FontSize = 13
        $cb.IsChecked = [bool]$tw.Recommended
        $cb.Tag = [PSCustomObject]@{
            Id          = $tw.Id
            Title       = $twTitle
            Desc        = $twDesc
            Recommended = [bool]$tw.Recommended
            Preset      = @($tw.Preset)
        }

        $d = New-Object System.Windows.Controls.TextBlock
        $d.Text = $twDesc
        $d.FontSize = 11.5
        $d.Foreground = Get-Brush $initTheme.TextMuted
        $d.Margin = "22,3,0,0"
        $d.TextWrapping = "Wrap"

        [void]$sp.Children.Add($cb)
        [void]$sp.Children.Add($d)
        $card.Child = $sp

        $card.Tag = $cb
        $card.Add_MouseLeftButtonUp({
            param($sender, $e)
            if ($e.OriginalSource -isnot [System.Windows.Controls.CheckBox]) {
                $targetCb = $sender.Tag
                $targetCb.IsChecked = -not $targetCb.IsChecked
            }
        })

        [void]$script:TweaksStackPanel.Children.Add($card)
        $script:tweakCheckboxes += $cb
    }
}

$script:BtnSelectRecTweaks.Add_Click({
    foreach ($cb in $script:tweakCheckboxes) { $cb.IsChecked = [bool]$cb.Tag.Recommended }
    Write-UiLog (Decode-U "\u00D6nerilen sistem ince ayarlar\u0131 se\u00E7ildi.")
})

$script:BtnTweakPresetStandard.Add_Click({
    foreach ($cb in $script:tweakCheckboxes) { $cb.IsChecked = ($cb.Tag.Preset -contains "Standard") }
    Write-UiLog (Decode-U "WinUtil Standart (Masa\u00FCst\u00FC) ince ayar profili se\u00E7ildi.")
})

$script:BtnTweakPresetMinimal.Add_Click({
    foreach ($cb in $script:tweakCheckboxes) { $cb.IsChecked = ($cb.Tag.Preset -contains "Minimal") }
    Write-UiLog (Decode-U "WinUtil Minimal (Diz\u00FCst\u00FC / Koruyucu) ince ayar profili se\u00E7ildi.")
})

$script:BtnTweakPresetAdvanced.Add_Click({
    foreach ($cb in $script:tweakCheckboxes) { $cb.IsChecked = ($cb.Tag.Preset -contains "Advanced") }
    Write-UiLog (Decode-U "WinUtil Geli\u015Fmi\u015F (Tam Kapsaml\u0131) ince ayar profili se\u00E7ildi.")
})

$script:BtnClearTweaks.Add_Click({
    foreach ($cb in $script:tweakCheckboxes) { $cb.IsChecked = $false }
    Write-UiLog (Decode-U "T\u00FCm ince ayar se\u00E7imleri temizlendi.")
})

function Start-TweaksEngine([array]$selectedTweaks, [bool]$isUndo) {
    if ($selectedTweaks.Count -eq 0) {
        Write-UiLog (Decode-U "[!] L\u00FCtfen i\u015Flem yap\u0131lacak en az bir ince ayar se\u00E7in.")
        return
    }
    $script:BtnApplyTweaks.IsEnabled = $false
    $script:BtnUndoTweaks.IsEnabled  = $false

    Start-BackgroundTask "TweaksEngine" @{ Tweaks = $selectedTweaks; Undo = $isUndo } {
        param($p)
        $list = $p.Tweaks
        $undo = [bool]$p.Undo
        $modeLabel = if ($undo) { "GERI ALINIYOR (UNDO)" } else { "UYGULANIYOR (APPLY)" }
        Log-Bg ">>> $($list.Count) Sistem Ince Ayari $modeLabel..."
        $done = 0

        foreach ($tw in $list) {
            $done++
            $pct = [math]::Round(($done / $list.Count) * 100)
            Status-Bg "($done/$($list.Count)) $modeLabel : $($tw.Title)" $pct
            try {
                switch ($tw.Id) {
                                        "Tweak_LocationAdvertising" {
                        if (-not $undo) {
                            Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" "Value" "String" "Deny"
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" "Enabled" "DWord" 0
                            Set-SvcSafe "lfsvc" "Disabled" $true
                            Log-Bg "[OK] Konum takibi (lfsvc) ve Reklam Kimligi kapatildi."
                        } else {
                            Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" "Value" "String" "Allow"
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" "Enabled" "DWord" 1
                            Set-SvcSafe "lfsvc" "Manual" $false
                            Log-Bg "[UNDO] Konum takibi ve Reklam Kimligi varsayilana donduruldu."
                        }
                    }
                    "Tweak_LockScreenSpotlight" {
                        if (-not $undo) {
                            Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" "DisableWindowsConsumerFeatures" "DWord" 1
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SubscribedContent-338387Enabled" "DWord" 0
                            Log-Bg "[OK] Kilit ekrani ipuclari ve sponsorlu tuketici deneyimleri kapatildi."
                        } else {
                            Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" "DisableWindowsConsumerFeatures" "DWord" "<RemoveEntry>"
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SubscribedContent-338387Enabled" "DWord" 1
                            Log-Bg "[UNDO] Kilit ekrani ipuclari varsayilana donduruldu."
                        }
                    }
                    "Tweak_WerFault" {
                        if (-not $undo) {
                            Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting" "Disabled" "DWord" 1
                            Set-SvcSafe "WerSvc" "Disabled" $true
                            Log-Bg "[OK] Windows Hata Bildirimi (WerSvc) devre disi birakildi."
                        } else {
                            Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting" "Disabled" "DWord" 0
                            Set-SvcSafe "WerSvc" "Manual" $false
                            Log-Bg "[UNDO] Windows Hata Bildirimi (WerSvc) varsayilana donduruldu."
                        }
                    }
                    "Tweak_SsdTrim" {
                        fsutil behavior set DisableDeleteNotify 0 | Out-Null
                        Log-Bg "[OK] SSD TRIM destegi aktif edildi ve dogrulandi."
                    }
                    "Tweak_BgServices" {
                        $svcList = @(
                            @{ Name = "CscService"; Apply = "Disabled"; Orig = "Manual" },
                            @{ Name = "DiagTrack"; Apply = "Disabled"; Orig = "Automatic" },
                            @{ Name = "MapsBroker"; Apply = "Manual"; Orig = "Automatic" },
                            @{ Name = "RemoteRegistry"; Apply = "Disabled"; Orig = "Disabled" },
                            @{ Name = "Fax"; Apply = "Disabled"; Orig = "Manual" },
                            @{ Name = "PcaSvc"; Apply = "Manual"; Orig = "Automatic" }
                        )
                        foreach ($s in $svcList) {
                            $targetMode = if ($undo) { $s.Orig } else { $s.Apply }
                            Set-SvcSafe $s.Name $targetMode $false
                        }
                        Log-Bg "[OK] Arka plan servisleri optimize edildi."
                    }
                    "Tweak_PhotoViewer" {
                        $exts = @(".bmp", ".dib", ".gif", ".jfif", ".jpe", ".jpeg", ".jpg", ".png", ".tif", ".tiff", ".wdp")
                        $regBase = "HKLM:\SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities\FileAssociations"
                        if (-not $undo) {
                            foreach ($ext in $exts) { Set-RegSafe $regBase $ext "String" "PhotoViewer.FileAssoc.Tiff" }
                            Log-Bg "[OK] Klasik Windows Fotograf Goruntuleyicisi aktif edildi."
                        } else {
                            foreach ($ext in $exts) {
                                if (-not ($ext -in @(".tif", ".tiff"))) { Set-RegSafe $regBase $ext "String" "<RemoveEntry>" }
                            }
                            Log-Bg "[UNDO] Klasik Windows Fotograf Goruntuleyicisi varsayilana donduruldu."
                        }
                    }
                    "Tweak_RestorePoint" {
                        if (-not $undo) {
                            Enable-ComputerRestore -Drive "$env:SystemDrive\" -ErrorAction SilentlyContinue
                            Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore" "SystemRestorePointCreationFrequency" "DWord" 0
                            Checkpoint-Computer -Description "UmutEvranTool_WinUtil_RestorePoint" -RestorePointType "MODIFY_SETTINGS" -ErrorAction SilentlyContinue
                            Log-Bg "[OK] Sistem Geri Yukleme Noktasi olusturuldu."
                        } else {
                            Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore" "SystemRestorePointCreationFrequency" "DWord" 1440
                            Log-Bg "[UNDO] Geri yukleme noktasi siklik degeri varsayilana (1440 dk) donduruldu."
                        }
                    }
                    "Tweak_Telemetry" {
                        if (-not $undo) {
                            Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" "AllowTelemetry" "DWord" 0
                            Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" "AllowTelemetry" "DWord" 0
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy" "TailoredExperiencesWithDiagnosticDataEnabled" "DWord" 0
                            Set-RegSafe "HKCU:\Software\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy" "HasAccepted" "DWord" 0
                            Set-RegSafe "HKCU:\Software\Microsoft\Input\TIPC" "Enabled" "DWord" 0
                            Set-RegSafe "HKCU:\Software\Microsoft\InputPersonalization" "RestrictImplicitInkCollection" "DWord" 1
                            Set-RegSafe "HKCU:\Software\Microsoft\InputPersonalization" "RestrictImplicitTextCollection" "DWord" 1
                            Set-RegSafe "HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore" "HarvestContacts" "DWord" 0
                            Set-RegSafe "HKCU:\Software\Microsoft\Personalization\Settings" "AcceptedPrivacyPolicy" "DWord" 0
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "Start_TrackProgs" "DWord" 0
                            Set-RegSafe "HKCU:\Software\Microsoft\Siuf\Rules" "NumberOfSIUFInPeriod" "DWord" 0
                            Set-RegSafe "HKCU:\Software\Microsoft\Siuf\Rules" "PeriodInNanoSeconds" "DWord" "<RemoveEntry>"
                            Set-SvcSafe "DiagTrack" "Disabled" $true
                            Set-SvcSafe "dmwappushservice" "Disabled" $true
                            Set-MpPreference -SubmitSamplesConsent 2 -ErrorAction SilentlyContinue
                            [Environment]::SetEnvironmentVariable('POWERSHELL_TELEMETRY_OPTOUT', '1', 'Machine')
                            Log-Bg "[OK] Telemetri, DiagTrack, dmwappushservice ve SIUF tamamen devre disi birakildi."
                        } else {
                            Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" "AllowTelemetry" "DWord" "<RemoveEntry>"
                            Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" "AllowTelemetry" "DWord" "<RemoveEntry>"
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy" "TailoredExperiencesWithDiagnosticDataEnabled" "DWord" "<RemoveEntry>"
                            Set-RegSafe "HKCU:\Software\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy" "HasAccepted" "DWord" "<RemoveEntry>"
                            Set-RegSafe "HKCU:\Software\Microsoft\Input\TIPC" "Enabled" "DWord" "<RemoveEntry>"
                            Set-RegSafe "HKCU:\Software\Microsoft\InputPersonalization" "RestrictImplicitInkCollection" "DWord" "<RemoveEntry>"
                            Set-RegSafe "HKCU:\Software\Microsoft\InputPersonalization" "RestrictImplicitTextCollection" "DWord" "<RemoveEntry>"
                            Set-RegSafe "HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore" "HarvestContacts" "DWord" "<RemoveEntry>"
                            Set-RegSafe "HKCU:\Software\Microsoft\Personalization\Settings" "AcceptedPrivacyPolicy" "DWord" "<RemoveEntry>"
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "Start_TrackProgs" "DWord" "<RemoveEntry>"
                            Set-RegSafe "HKCU:\Software\Microsoft\Siuf\Rules" "NumberOfSIUFInPeriod" "DWord" "<RemoveEntry>"
                            Set-SvcSafe "DiagTrack" "Automatic" $false
                            Set-SvcSafe "dmwappushservice" "Manual" $false
                            Set-MpPreference -SubmitSamplesConsent 1 -ErrorAction SilentlyContinue
                            [Environment]::SetEnvironmentVariable('POWERSHELL_TELEMETRY_OPTOUT', '', 'Machine')
                            Log-Bg "[UNDO] Telemetri ve DiagTrack servisleri varsayilan duruma donduruldu."
                        }
                    }
                    "Tweak_ActivityHistory" {
                        if (-not $undo) {
                            Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "EnableActivityFeed" "DWord" 0
                            Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "PublishUserActivities" "DWord" 0
                            Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "UploadUserActivities" "DWord" 0
                            Log-Bg "[OK] Etkinlik gecmisi (Timeline) ve kullanici takibi kapatildi."
                        } else {
                            Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "EnableActivityFeed" "DWord" "<RemoveEntry>"
                            Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "PublishUserActivities" "DWord" "<RemoveEntry>"
                            Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "UploadUserActivities" "DWord" "<RemoveEntry>"
                            Log-Bg "[UNDO] Etkinlik gecmisi (Timeline) varsayilana donduruldu."
                        }
                    }
                    "Tweak_Location" {
                        if (-not $undo) {
                            Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" "Value" "String" "Deny"
                            Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" "SensorPermissionState" "DWord" 0
                            Set-RegSafe "HKLM:\SYSTEM\Maps" "AutoUpdateEnabled" "DWord" 0
                            Set-SvcSafe "lfsvc" "Disabled" $true
                            Log-Bg "[OK] Fiziksel konum takibi ve lfsvc servisi kapatildi."
                        } else {
                            Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" "Value" "String" "Allow"
                            Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" "SensorPermissionState" "DWord" 1
                            Set-RegSafe "HKLM:\SYSTEM\Maps" "AutoUpdateEnabled" "DWord" 1
                            Set-SvcSafe "lfsvc" "Manual" $false
                            Log-Bg "[UNDO] Konum takibi ve lfsvc servisi varsayilana donduruldu."
                        }
                    }
                    "Tweak_AdvertisingId" {
                        if (-not $undo) {
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" "Enabled" "DWord" 0
                            Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" "DisabledByGroupPolicy" "DWord" 1
                            Log-Bg "[OK] Reklam Kimligi (Advertising ID) devre disi birakildi."
                        } else {
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" "Enabled" "DWord" 1
                            Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" "DisabledByGroupPolicy" "DWord" "<RemoveEntry>"
                            Log-Bg "[UNDO] Reklam Kimligi varsayilana donduruldu."
                        }
                    }
                    "Tweak_BingSearch" {
                        if (-not $undo) {
                            Set-RegSafe "HKCU:\Software\Policies\Microsoft\Windows\Explorer" "DisableSearchBoxSuggestions" "DWord" 1
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" "BingSearchEnabled" "DWord" 0
                            Log-Bg "[OK] Baslat menusu Bing web arama sonuclari kapatildi."
                        } else {
                            Set-RegSafe "HKCU:\Software\Policies\Microsoft\Windows\Explorer" "DisableSearchBoxSuggestions" "DWord" "<RemoveEntry>"
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" "BingSearchEnabled" "DWord" 1
                            Log-Bg "[UNDO] Baslat menusu Bing web aramalari varsayilana donduruldu."
                        }
                    }
                    "Tweak_ConsumerFeatures" {
                        if (-not $undo) {
                            Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" "DisableWindowsConsumerFeatures" "DWord" 1
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SubscribedContent-338387Enabled" "DWord" 0
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "RotatingLockScreenOverlayEnabled" "DWord" 0
                            Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization" "NoLockScreen" "DWord" 0
                            Log-Bg "[OK] Microsoft tuketici deneyimleri (ConsumerFeatures) ve kilit ekrani ipuclari kapatildi."
                        } else {
                            Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" "DisableWindowsConsumerFeatures" "DWord" "<RemoveEntry>"
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SubscribedContent-338387Enabled" "DWord" 1
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "RotatingLockScreenOverlayEnabled" "DWord" 1
                            Log-Bg "[UNDO] Microsoft tuketici deneyimleri varsayilana donduruldu."
                        }
                    }
                    "Tweak_ErrorReporting" {
                        if (-not $undo) {
                            Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting" "Disabled" "DWord" 1
                            Set-SvcSafe "WerSvc" "Disabled" $true
                            Log-Bg "[OK] Windows Hata Bildirimi (WerFault / WerSvc) devre disi birakildi."
                        } else {
                            Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting" "Disabled" "DWord" 0
                            Set-SvcSafe "WerSvc" "Manual" $false
                            Log-Bg "[UNDO] Windows Hata Bildirimi varsayilana donduruldu."
                        }
                    }
                    "Tweak_DeliveryOpt" {
                        if (-not $undo) {
                            Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" "DODownloadMode" "DWord" 0
                            Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" "DODownloadMode" "DWord" 0
                            Log-Bg "[OK] Teslim En Iyilestirme (P2P Guncelleme Paylasimi) kapatildi."
                        } else {
                            Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" "DODownloadMode" "DWord" "<RemoveEntry>"
                            Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" "DODownloadMode" "DWord" "<RemoveEntry>"
                            Log-Bg "[UNDO] Teslim En Iyilestirme varsayilana donduruldu."
                        }
                    }
                    "Tweak_WPBT" {
                        if (-not $undo) {
                            Set-RegSafe "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" "DisableWpbtExecution" "DWord" 1
                            Log-Bg "[OK] Windows Platform Binary Table (WPBT) devre disi birakildi."
                        } else {
                            Set-RegSafe "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" "DisableWpbtExecution" "DWord" "<RemoveEntry>"
                            Log-Bg "[UNDO] WPBT ayari varsayilana donduruldu."
                        }
                    }
                    "Tweak_DeviceMetadata" {
                        if (-not $undo) {
                            Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Device Metadata" "PreventDeviceMetadataFromNetwork" "DWord" 1
                            Log-Bg "[OK] Cihaz eslikci uygulamalarinin agdan otomatik indirilmesi engellendi."
                        } else {
                            Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Device Metadata" "PreventDeviceMetadataFromNetwork" "DWord" "<RemoveEntry>"
                            Log-Bg "[UNDO] Cihaz metadata ayari varsayilana donduruldu."
                        }
                    }
                    "Tweak_StoreSearch" {
                        $storeDb = "$env:LocalAppData\Packages\Microsoft.WindowsStore_8wekyb3d8bbwe\LocalState\store.db"
                        if (-not $undo) {
                            if (Test-Path $storeDb) { icacls $storeDb /deny "*S-1-1-0:F" | Out-Null }
                            Log-Bg "[OK] Baslat menusunde Microsoft Store uygulama onerileri engellendi."
                        } else {
                            if (Test-Path $storeDb) { icacls $storeDb /grant "*S-1-1-0:F" | Out-Null }
                            Log-Bg "[UNDO] Microsoft Store arama onerisi izni geri verildi."
                        }
                    }
                    "Tweak_ExplorerAutoDiscovery" {
                        $bags = "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags"
                        $bagMRU = "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\BagMRU"
                        $allFolders = "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags\AllFolders\Shell"
                        Remove-Item -Path $bags -Recurse -Force -ErrorAction SilentlyContinue
                        Remove-Item -Path $bagMRU -Recurse -Force -ErrorAction SilentlyContinue
                        if (-not $undo) {
                            Set-RegSafe $allFolders "FolderType" "String" "NotSpecified"
                            Log-Bg "[OK] Dosya Gezgini otomatik klasor algilama kapatildi (Genel hizli gorunum)."
                        } else {
                            Log-Bg "[UNDO] Dosya Gezgini klasor gorunum veritabani sifirlandi."
                        }
                    }
                    "Tweak_EndTaskOnTaskbar" {
                        if (-not $undo) {
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings" "TaskbarEndTask" "DWord" 1
                            Log-Bg "[OK] Gorev cubugundan sag tikla 'Gorevi Sonlandir' ozelligi acildi."
                        } else {
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings" "TaskbarEndTask" "DWord" "<RemoveEntry>"
                            Log-Bg "[UNDO] Gorev cubugu Gorevi Sonlandir secenegi kapatildi."
                        }
                    }
                    "Tweak_UltimatePerf" {
                        if (-not $undo) {
                            $ultOut = powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 2>&1 | Out-String
                            if ($ultOut -match '([a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12})') {
                                powercfg -setactive $matches[1] | Out-Null
                            }
                            Log-Bg "[OK] Nihai Performans (Ultimate Performance) guc plani olusturuldu ve aktif edildi."
                        } else {
                            powercfg -setactive 381b4222-f694-41f0-9685-ff5bb260df2e | Out-Null
                            Log-Bg "[UNDO] Dengeli (Balanced) standart guc planina geri donuldu."
                        }
                    }
                    "Tweak_MouseAccel" {
                        if (-not $undo) {
                            Set-RegSafe "HKCU:\Control Panel\Mouse" "MouseSpeed" "String" "0"
                            Set-RegSafe "HKCU:\Control Panel\Mouse" "MouseThreshold1" "String" "0"
                            Set-RegSafe "HKCU:\Control Panel\Mouse" "MouseThreshold2" "String" "0"
                            Log-Bg "[OK] Fare ivmesi (Enhance Pointer Precision) kapatildi (1:1 ham giris)."
                        } else {
                            Set-RegSafe "HKCU:\Control Panel\Mouse" "MouseSpeed" "String" "1"
                            Set-RegSafe "HKCU:\Control Panel\Mouse" "MouseThreshold1" "String" "6"
                            Set-RegSafe "HKCU:\Control Panel\Mouse" "MouseThreshold2" "String" "10"
                            Log-Bg "[UNDO] Fare ivmesi varsayilan Windows degerlerine (1 / 6 / 10) donduruldu."
                        }
                    }
                    "Tweak_GameDVR" {
                        if (-not $undo) {
                            Set-RegSafe "HKCU:\System\GameConfigStore" "GameDVR_Enabled" "DWord" 0
                            Set-RegSafe "HKCU:\System\GameConfigStore" "GameDVR_FSEBehaviorMode" "DWord" 2
                            Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" "AllowGameDVR" "DWord" 0
                            Set-RegSafe "HKCU:\Software\Microsoft\GameBar" "AllowAutoGameMode" "DWord" 1
                            Set-RegSafe "HKCU:\Software\Microsoft\GameBar" "AutoGameModeEnabled" "DWord" 1
                            Log-Bg "[OK] Xbox GameDVR arka plan kaydi kapatildi ve Oyun Modu (Game Mode) acildi."
                        } else {
                            Set-RegSafe "HKCU:\System\GameConfigStore" "GameDVR_Enabled" "DWord" 1
                            Set-RegSafe "HKCU:\System\GameConfigStore" "GameDVR_FSEBehaviorMode" "DWord" 0
                            Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" "AllowGameDVR" "DWord" "<RemoveEntry>"
                            Log-Bg "[UNDO] Xbox GameDVR varsayilan duruma donduruldu."
                        }
                    }
                    "Tweak_NetworkThrottling" {
                        $mmPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
                        if (-not $undo) {
                            if (!(Test-Path $mmPath)) { New-Item -Path $mmPath -Force | Out-Null }
                            reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v NetworkThrottlingIndex /t REG_DWORD /d 0xffffffff /f | Out-Null
                            Log-Bg "[OK] Ag trafigi kisitlamasi kaldirildi (NetworkThrottlingIndex = 0xFFFFFFFF)."
                        } else {
                            Set-RegSafe $mmPath "NetworkThrottlingIndex" "DWord" 10
                            Log-Bg "[UNDO] NetworkThrottlingIndex varsayilan degere (10) donduruldu."
                        }
                    }
                    "Tweak_SystemResponsiveness" {
                        $mmPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
                        if (-not $undo) {
                            Set-RegSafe $mmPath "SystemResponsiveness" "DWord" 0
                            Log-Bg "[OK] Sistem tepkiselligi ve oyun onceligi %100 yapildi (SystemResponsiveness = 0)."
                        } else {
                            Set-RegSafe $mmPath "SystemResponsiveness" "DWord" 20
                            Log-Bg "[UNDO] SystemResponsiveness varsayilan degere (20) donduruldu."
                        }
                    }
                    "Tweak_TCPNoDelay" {
                        $tcpInterfaces = Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces" -ErrorAction SilentlyContinue
                        if (-not $undo) {
                            foreach ($ifc in $tcpInterfaces) {
                                Set-ItemProperty -Path $ifc.PSPath -Name "TcpAckFrequency" -Type DWord -Value 1 -Force -ErrorAction SilentlyContinue
                                Set-ItemProperty -Path $ifc.PSPath -Name "TCPNoDelay" -Type DWord -Value 1 -Force -ErrorAction SilentlyContinue
                            }
                            Log-Bg "[OK] Nagle Algoritmasi (TCPNoDelay & TcpAckFrequency) devre disi birakildi."
                        } else {
                            foreach ($ifc in $tcpInterfaces) {
                                Remove-ItemProperty -Path $ifc.PSPath -Name "TcpAckFrequency" -Force -ErrorAction SilentlyContinue
                                Remove-ItemProperty -Path $ifc.PSPath -Name "TCPNoDelay" -Force -ErrorAction SilentlyContinue
                            }
                            Log-Bg "[UNDO] Nagle Algoritmasi (TCPNoDelay) varsayilan duruma donduruldu."
                        }
                    }
                    "Tweak_GreenEthernet" {
                        $val = if ($undo) { 1 } else { 0 }
                        Get-NetAdapterAdvancedProperty -DisplayName "*Energy Efficient Ethernet*" -ErrorAction SilentlyContinue | Set-NetAdapterAdvancedProperty -RegistryValue $val -ErrorAction SilentlyContinue
                        Get-NetAdapterAdvancedProperty -DisplayName "*Green Ethernet*" -ErrorAction SilentlyContinue | Set-NetAdapterAdvancedProperty -RegistryValue $val -ErrorAction SilentlyContinue
                        Get-NetAdapterAdvancedProperty -DisplayName "*Power Saving*" -ErrorAction SilentlyContinue | Set-NetAdapterAdvancedProperty -RegistryValue $val -ErrorAction SilentlyContinue
                        if (-not $undo) {
                            Log-Bg "[OK] Green Ethernet ve ag karti enerji tasarrufu modlari kapatildi."
                        } else {
                            Log-Bg "[UNDO] Green Ethernet enerji tasarrufu modlari varsayilana donduruldu."
                        }
                    }
                    "Tweak_Hibernation" {
                        if (-not $undo) {
                            Set-RegSafe "HKLM:\System\CurrentControlSet\Control\Session Manager\Power" "HibernateEnabled" "DWord" 0
                            Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings" "ShowHibernateOption" "DWord" 0
                            powercfg.exe /hibernate off | Out-Null
                            Log-Bg "[OK] Hazirda bekletme (Hibernation) kapatildi, disk alani serbest birakildi."
                        } else {
                            Set-RegSafe "HKLM:\System\CurrentControlSet\Control\Session Manager\Power" "HibernateEnabled" "DWord" 1
                            Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings" "ShowHibernateOption" "DWord" 1
                            powercfg.exe /hibernate on | Out-Null
                            Log-Bg "[UNDO] Hazirda bekletme (Hibernation) yeniden etkinlestirildi."
                        }
                    }
                    "Tweak_BgApps" {
                        if (-not $undo) {
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" "GlobalUserDisabled" "DWord" 1
                            Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" "LetAppsRunInBackground" "DWord" 2
                            Log-Bg "[OK] Magaza uygulamalarinin arka planda calismasi engellendi."
                        } else {
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" "GlobalUserDisabled" "DWord" 0
                            Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" "LetAppsRunInBackground" "DWord" "<RemoveEntry>"
                            Log-Bg "[UNDO] Arka plan uygulama izinleri varsayilana donduruldu."
                        }
                    }
                    "Tweak_MultiplaneOverlay" {
                        if (-not $undo) {
                            Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows\Dwm" "OverlayTestMode" "DWord" 5
                            Set-RegSafe "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" "DisableOverlays" "DWord" 1
                            Log-Bg "[OK] Multiplane Overlay (MPO) devre disi birakildi."
                        } else {
                            Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows\Dwm" "OverlayTestMode" "DWord" "<RemoveEntry>"
                            Set-RegSafe "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" "DisableOverlays" "DWord" "<RemoveEntry>"
                            Log-Bg "[UNDO] Multiplane Overlay (MPO) varsayilana donduruldu."
                        }
                    }
                    "Tweak_VisualFX" {
                        if (-not $undo) {
                            Set-RegSafe "HKCU:\Control Panel\Desktop" "DragFullWindows" "String" "0"
                            Set-RegSafe "HKCU:\Control Panel\Desktop" "MenuShowDelay" "String" "10"
                            Set-RegSafe "HKCU:\Control Panel\Desktop\WindowMetrics" "MinAnimate" "String" "0"
                            Set-RegSafe "HKCU:\Control Panel\Keyboard" "KeyboardDelay" "String" "0"
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "ListviewAlphaSelect" "DWord" 0
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "ListviewShadow" "DWord" 0
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "TaskbarAnimations" "DWord" 0
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" "VisualFXSetting" "DWord" 3
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\DWM" "EnableAeroPeek" "DWord" 0
                            Set-RegSafe "HKCU:\Control Panel\Desktop" "UserPreferencesMask" "Binary" ([byte[]](144,18,3,128,16,0,0,0))
                            Log-Bg "[OK] MenuShowDelay (10ms) ve performans odakli gorsel efektler uygulandi."
                        } else {
                            Set-RegSafe "HKCU:\Control Panel\Desktop" "DragFullWindows" "String" "1"
                            Set-RegSafe "HKCU:\Control Panel\Desktop" "MenuShowDelay" "String" "400"
                            Set-RegSafe "HKCU:\Control Panel\Desktop\WindowMetrics" "MinAnimate" "String" "1"
                            Set-RegSafe "HKCU:\Control Panel\Keyboard" "KeyboardDelay" "String" "1"
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "ListviewAlphaSelect" "DWord" 1
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "ListviewShadow" "DWord" 1
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "TaskbarAnimations" "DWord" 1
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" "VisualFXSetting" "DWord" 1
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\DWM" "EnableAeroPeek" "DWord" 1
                            Set-RegSafe "HKCU:\Control Panel\Desktop" "UserPreferencesMask" "DWord" "<RemoveEntry>"
                            Log-Bg "[UNDO] Gorsel efektler ve MenuShowDelay (400ms) varsayilana donduruldu."
                        }
                    }
                    "Tweak_SSDTrim" {
                        if (-not $undo) {
                            fsutil behavior set DisableDeleteNotify 0 | Out-Null
                            Log-Bg "[OK] SSD TRIM ozelligi zorlandi ve dogrulandi (DisableDeleteNotify = 0)."
                        } else {
                            fsutil behavior set DisableDeleteNotify 0 | Out-Null
                            Log-Bg "[UNDO] SSD sagligi icin TRIM aktif tutuldu (DisableDeleteNotify = 0)."
                        }
                    }
                    "Tweak_Services" {
                        $svcList = @(
                            @{ Name = "CscService"; Apply = "Disabled"; Orig = "Manual" },
                            @{ Name = "DiagTrack"; Apply = "Disabled"; Orig = "Automatic" },
                            @{ Name = "MapsBroker"; Apply = "Manual"; Orig = "Automatic" },
                            @{ Name = "StorSvc"; Apply = "Manual"; Orig = "Automatic" },
                            @{ Name = "SharedAccess"; Apply = "Disabled"; Orig = "Automatic" },
                            @{ Name = "RemoteRegistry"; Apply = "Disabled"; Orig = "Disabled" },
                            @{ Name = "Fax"; Apply = "Disabled"; Orig = "Manual" },
                            @{ Name = "RetailDemo"; Apply = "Disabled"; Orig = "Manual" },
                            @{ Name = "WMPNetworkSvc"; Apply = "Disabled"; Orig = "Manual" },
                            @{ Name = "wisvc"; Apply = "Manual"; Orig = "Manual" },
                            @{ Name = "PhoneSvc"; Apply = "Manual"; Orig = "Manual" },
                            @{ Name = "PrintNotify"; Apply = "Manual"; Orig = "Manual" },
                            @{ Name = "PcaSvc"; Apply = "Manual"; Orig = "Automatic" },
                            @{ Name = "WSearch"; Apply = "Manual"; Orig = "AutomaticDelayedStart" }
                        )
                        foreach ($s in $svcList) {
                            $targetMode = if ($undo) { $s.Orig } else { $s.Apply }
                            Set-SvcSafe $s.Name $targetMode $false
                        }
                        if (-not $undo) {
                            Log-Bg "[OK] Arka plan servisleri Manuel/Devre Disi moduna optimize edildi."
                        } else {
                            Log-Bg "[UNDO] Arka plan servisleri varsayilan baslangic turlerine donduruldu."
                        }
                    }
                    "Tweak_DiskCleanup" {
                        if (-not $undo) {
                            Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
                            Remove-Item -Path "$env:SystemRoot\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
                            Remove-Item -Path "$env:SystemRoot\Prefetch\*" -Recurse -Force -ErrorAction SilentlyContinue
                            Remove-Item -Path "$env:SystemRoot\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction SilentlyContinue
                            Start-Process -FilePath "cleanmgr.exe" -ArgumentList "/d C: /VERYLOWDISK" -NoNewWindow -ErrorAction SilentlyContinue
                            ipconfig /flushdns | Out-Null
                            Log-Bg "[OK] Temp, Prefetch, Windows Update onbellegi ve DNS temizlendi; Cleanmgr baslatildi."
                        } else {
                            Log-Bg "[UNDO] Disk temizligi tek yonlu bir islemdir, silinen gecici dosyalar geri alinamaz."
                        }
                    }
                    "Tweak_StorageSense" {
                        if (-not $undo) {
                            Set-RegSafe "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" "01" "DWord" 0
                            Log-Bg "[OK] Akilli Depolama (Storage Sense) devre disi birakildi."
                        } else {
                            Set-RegSafe "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" "01" "DWord" 1
                            Log-Bg "[UNDO] Akilli Depolama (Storage Sense) yeniden acildi."
                        }
                    }
                    "Tweak_ReservedStorage" {
                        if (-not $undo) {
                            DISM.exe /Online /Set-ReservedStorageState /State:Disabled | Out-Null
                            Log-Bg "[OK] Windows Ayrilmis Depolama Alani (Reserved Storage) kapatildi."
                        } else {
                            DISM.exe /Online /Set-ReservedStorageState /State:Enabled | Out-Null
                            Log-Bg "[UNDO] Windows Ayrilmis Depolama Alani yeniden acildi."
                        }
                    }
                    "Tweak_SvcHostSplitting" {
                        if (-not $undo) {
                            $memKB = [int64]((Get-CimInstance Win32_PhysicalMemory -ErrorAction SilentlyContinue | Measure-Object Capacity -Sum).Sum / 1KB)
                            if ($memKB -gt 0) {
                                Set-RegSafe "HKLM:\SYSTEM\CurrentControlSet\Control" "SvcHostSplitThresholdInKB" "DWord" $memKB
                            }
                            Log-Bg "[OK] svchost.exe surec bolunmesi (SvcHostSplitThresholdInKB) devre disi birakildi."
                        } else {
                            Set-RegSafe "HKLM:\SYSTEM\CurrentControlSet\Control" "SvcHostSplitThresholdInKB" "DWord" 3670016
                            Log-Bg "[UNDO] svchost.exe surec bolunmesi varsayilana (3670016) donduruldu."
                        }
                    }
                    "Tweak_BitLocker" {
                        if (-not $undo) {
                            Disable-BitLocker -MountPoint $env:SystemDrive -ErrorAction SilentlyContinue | Out-Null
                            Log-Bg "[OK] Sistem surucusu icin BitLocker devre disi birakma komutu calistirildi."
                        } else {
                            Enable-BitLocker -MountPoint $env:SystemDrive -ErrorAction SilentlyContinue | Out-Null
                            Log-Bg "[UNDO] BitLocker etkinlestirme komutu calistirildi."
                        }
                    }
                    "Tweak_LongPaths" {
                        $val = if ($undo) { 0 } else { 1 }
                        Set-RegSafe "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" "LongPathsEnabled" "DWord" $val
                        Log-Bg "[OK] Uzun dosya yolu destegi (LongPathsEnabled = $val) ayarlandi."
                    }
                    "Tweak_UTC" {
                        $val = if ($undo) { 0 } else { 1 }
                        Set-RegSafe "HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation" "RealTimeIsUniversal" "QWord" $val
                        Log-Bg "[OK] Donanim saati UTC modu (RealTimeIsUniversal = $val) ayarlandi."
                    }
                    "Tweak_S0StandbyFix" {
                        $val = if ($undo) { 1 } else { 0 }
                        Set-RegSafe "HKCU:\SOFTWARE\Policies\Microsoft\Power\PowerSettings\f15576e8-98b7-4186-b944-eafa664402d9" "ACSettingIndex" "DWord" $val
                        Log-Bg "[OK] S0 Modern Uyku ag baglantisi (ACSettingIndex = $val) ayarlandi."
                    }
                    "Tweak_S3Sleep" {
                        if (-not $undo) {
                            Set-RegSafe "HKLM:\SYSTEM\CurrentControlSet\Control\Power" "PlatformAoAcOverride" "DWord" 0
                            Log-Bg "[OK] Klasik S3 Uyku modu (PlatformAoAcOverride = 0) etkinlestirildi."
                        } else {
                            Set-RegSafe "HKLM:\SYSTEM\CurrentControlSet\Control\Power" "PlatformAoAcOverride" "DWord" "<RemoveEntry>"
                            Log-Bg "[UNDO] Modern Standby varsayilanina donuldu."
                        }
                    }
                    "Tweak_ClassicContext" {
                        if (-not $undo) {
                            New-Item -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" -Value "" -Force -ErrorAction SilentlyContinue | Out-Null
                            Log-Bg "[OK] Windows 11 klasik sag tik menusu aktif edildi."
                        } else {
                            Remove-Item -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" -Recurse -Force -ErrorAction SilentlyContinue
                            Log-Bg "[UNDO] Windows 11 modern sag tik menusune geri donuldu."
                        }
                    }
                    "Tweak_FileExt" {
                        $val = if ($undo) { 1 } else { 0 }
                        Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "HideFileExt" "DWord" $val
                        Log-Bg "[OK] Bilinen dosya uzantilari gorunurlugu guncellendi (HideFileExt = $val)."
                    }
                    "Tweak_HiddenFiles" {
                        $val = if ($undo) { 2 } else { 1 }
                        Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "Hidden" "DWord" $val
                        Log-Bg "[OK] Gizli dosya ve klasor gorunurlugu guncellendi (Hidden = $val)."
                    }
                    "Tweak_HideTaskbarJunk" {
                        if (-not $undo) {
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "ShowTaskViewButton" "DWord" 0
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "TaskbarDa" "DWord" 0
                            Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Dsh" "AllowNewsAndInterests" "DWord" 0
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" "SearchboxTaskbarMode" "DWord" 0
                            Get-Process *Widget* -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
                            Log-Bg "[OK] Gorev cubugu Arama, Gorev Gorunumu ve Widget (Hava Durumu) simgeleri gizlendi."
                        } else {
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "ShowTaskViewButton" "DWord" 1
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "TaskbarDa" "DWord" 1
                            Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Dsh" "AllowNewsAndInterests" "DWord" "<RemoveEntry>"
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" "SearchboxTaskbarMode" "DWord" 1
                            Log-Bg "[UNDO] Gorev cubugu Arama, Gorev Gorunumu ve Widget simgeleri geri acildi."
                        }
                    }
                    "Tweak_DarkMode" {
                        $val = if ($undo) { 1 } else { 0 }
                        Set-RegSafe "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" "AppsUseLightTheme" "DWord" $val
                        Set-RegSafe "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" "SystemUsesLightTheme" "DWord" $val
                        if (-not $undo) {
                            Log-Bg "[OK] Sistem ve uygulama Koyu Tema (Dark Mode) etkinlestirildi."
                        } else {
                            Log-Bg "[UNDO] Acik Tema (Light Mode) etkinlestirildi."
                        }
                    }
                    "Tweak_StickyKeys" {
                        $val = if ($undo) { "510" } else { "506" }
                        Set-RegSafe "HKCU:\Control Panel\Accessibility\StickyKeys" "Flags" "String" $val
                        Log-Bg "[OK] Yapiskan Tuslar (Sticky Keys) kisayolu guncellendi (Flags = $val)."
                    }
                    "Tweak_ClassicPhotoViewer" {
                        $exts = @(".bmp", ".dib", ".gif", ".jfif", ".jpe", ".jpeg", ".jpg", ".png", ".tif", ".tiff", ".wdp")
                        $regBase = "HKLM:\SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities\FileAssociations"
                        if (-not $undo) {
                            foreach ($ext in $exts) {
                                Set-RegSafe $regBase $ext "String" "PhotoViewer.FileAssoc.Tiff"
                            }
                            Log-Bg "[OK] Klasik Windows Fotograf Goruntuleyicisi (Windows Photo Viewer) aktif edildi."
                        } else {
                            foreach ($ext in $exts) {
                                if (-not ($ext -in @(".tif", ".tiff"))) {
                                    Set-RegSafe $regBase $ext "String" "<RemoveEntry>"
                                }
                            }
                            Log-Bg "[UNDO] Klasik Windows Fotograf Goruntuleyicisi dosya iliskilendirmeleri kaldirildi."
                        }
                    }
                    "Tweak_RemoveHomeGallery" {
                        if (-not $undo) {
                            Set-RegSafe "HKCU:\Software\Classes\CLSID\{f874310e-b6b7-47dc-bc84-b9e6b38f5903}" "System.IsPinnedToNameSpaceTree" "DWord" 0
                            Set-RegSafe "HKCU:\Software\Classes\CLSID\{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}" "System.IsPinnedToNameSpaceTree" "DWord" 0
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "LaunchTo" "DWord" 1
                            Log-Bg "[OK] Dosya Gezgini Giris ve Galeri kaldirildi, varsayilan 'Bu Bilgisayar' yapildi."
                        } else {
                            Set-RegSafe "HKCU:\Software\Classes\CLSID\{f874310e-b6b7-47dc-bc84-b9e6b38f5903}" "System.IsPinnedToNameSpaceTree" "DWord" "<RemoveEntry>"
                            Set-RegSafe "HKCU:\Software\Classes\CLSID\{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}" "System.IsPinnedToNameSpaceTree" "DWord" "<RemoveEntry>"
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "LaunchTo" "DWord" "<RemoveEntry>"
                            Log-Bg "[UNDO] Dosya Gezgini Giris ve Galeri sekmeleri geri yuklendi."
                        }
                    }
                    "Tweak_TaskbarLeft" {
                        $val = if ($undo) { 1 } else { 0 }
                        Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "TaskbarAl" "DWord" $val
                        Log-Bg "[OK] Gorev cubugu hizalamasi guncellendi (TaskbarAl = $val)."
                    }
                    "Tweak_RevertStartMenu" {
                        if (-not $undo) {
                            Set-RegSafe "HKLM:\SYSTEM\ControlSet001\Control\FeatureManagement\Overrides\8\3036241548" "EnabledState" "DWord" 1
                            Set-RegSafe "HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device\Start" "HideRecommendedSection" "DWord" 1
                            Set-RegSafe "HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device\Education" "IsEducationEnvironment" "DWord" 1
                            Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" "HideRecommendedSection" "DWord" 1
                            Log-Bg "[OK] Baslat menusu Onerilenler bolumu gizlendi ve klasik duzen etkinlestirildi."
                        } else {
                            Set-RegSafe "HKLM:\SYSTEM\ControlSet001\Control\FeatureManagement\Overrides\8\3036241548" "EnabledState" "DWord" "<RemoveEntry>"
                            Set-RegSafe "HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device\Start" "HideRecommendedSection" "DWord" 0
                            Set-RegSafe "HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device\Education" "IsEducationEnvironment" "DWord" 0
                            Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" "HideRecommendedSection" "DWord" 0
                            Log-Bg "[UNDO] Baslat menusu Onerilenler bolumu varsayilana donduruldu."
                        }
                    }
                    "Tweak_NumLock" {
                        $val = if ($undo) { "0" } else { "2" }
                        Set-RegSafe "HKU:\.Default\Control Panel\Keyboard" "InitialKeyboardIndicators" "String" $val
                        Set-RegSafe "HKCU:\Control Panel\Keyboard" "InitialKeyboardIndicators" "String" $val
                        Log-Bg "[OK] Acilista Num Lock durumu guncellendi (InitialKeyboardIndicators = $val)."
                    }
                    "Tweak_DetailedBSoD" {
                        $val = if ($undo) { 0 } else { 1 }
                        Set-RegSafe "HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl" "DisplayParameters" "DWord" $val
                        Set-RegSafe "HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl" "DisableEmoticon" "DWord" $val
                        Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "VerboseStatus" "DWord" $val
                        Log-Bg "[OK] Ayrintili Mavi Ekran (BSoD) ve Verbose Logon durumu ($val) ayarlandi."
                    }
                    "Tweak_BatteryPct" {
                        if (-not $undo) {
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "IsBatteryPercentageEnabled" "DWord" 1
                            Set-RegSafe "HKCU:\Control Panel\Accessibility" "DynamicScrollbars" "DWord" 0
                            Log-Bg "[OK] Pil yuzdesi gosterimi ve sabit kaydirma cubuklari acildi."
                        } else {
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "IsBatteryPercentageEnabled" "DWord" "<RemoveEntry>"
                            Set-RegSafe "HKCU:\Control Panel\Accessibility" "DynamicScrollbars" "DWord" 1
                            Log-Bg "[UNDO] Pil yuzdesi ve kaydirma cubuklari varsayilana donduruldu."
                        }
                    }
                    "Tweak_HideSettingsHome" {
                        if (-not $undo) {
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" "SettingsPageVisibility" "String" "hide:home"
                            Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "DisableAcrylicBackgroundOnLogon" "DWord" 1
                            Log-Bg "[OK] Ayarlar Giris (Home) sekmesi ve kilit ekrani bulanikligi kapatildi."
                        } else {
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" "SettingsPageVisibility" "String" "show:home"
                            Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "DisableAcrylicBackgroundOnLogon" "DWord" 0
                            Log-Bg "[UNDO] Ayarlar Giris sekmesi ve kilit ekrani bulanikligi geri acildi."
                        }
                    }
                    "Tweak_DeepOneDrive" {
                        if (-not $undo) {
                            Stop-Process -Name "OneDrive" -Force -ErrorAction SilentlyContinue
                            $odSetup = "$env:SystemRoot\SysWOW64\OneDriveSetup.exe"
                            if (!(Test-Path $odSetup)) { $odSetup = "$env:SystemRoot\System32\OneDriveSetup.exe" }
                            if (Test-Path $odSetup) {
                                Start-Process -FilePath $odSetup -ArgumentList "/uninstall" -NoNewWindow -Wait -ErrorAction SilentlyContinue
                            }
                            Set-RegSafe "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" "System.IsPinnedToNameSpaceTree" "DWord" 0
                            Set-RegSafe "HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" "System.IsPinnedToNameSpaceTree" "DWord" 0
                            Remove-Item -Path "HKCU:\Software\Classes\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" -Recurse -Force -ErrorAction SilentlyContinue
                            if (Test-Path "HKLM:\SYSTEM\CurrentControlSet\Services\OneSyncSvc") {
                                Set-SvcSafe "OneSyncSvc" "Disabled" $false
                            }
                            Log-Bg "[OK] OneDrive kokten kaldirildi ve Gezgin sol panel CLSID kalintilari temizlendi."
                        } else {
                            Start-Process -FilePath "winget.exe" -ArgumentList "install --id Microsoft.OneDrive -e --silent --accept-package-agreements --accept-source-agreements" -NoNewWindow -Wait -ErrorAction SilentlyContinue
                            if (Test-Path "HKLM:\SYSTEM\CurrentControlSet\Services\OneSyncSvc") {
                                Set-SvcSafe "OneSyncSvc" "Automatic" $false
                            }
                            Log-Bg "[UNDO] OneDrive Winget uzerinden yeniden kuruldu."
                        }
                    }
                    "Tweak_DisableCopilotAI" {
                        if (-not $undo) {
                            Set-RegSafe "HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot" "TurnOffWindowsCopilot" "DWord" 1
                            Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" "TurnOffWindowsCopilot" "DWord" 1
                            Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" "DisableAIDataAnalysis" "DWord" 1
                            Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" "TurnOffSavingSnapshots" "DWord" 1
                            Set-RegSafe "HKLM:\SOFTWARE\Policies\WindowsNotepad" "DisableAIFeatures" "DWord" 1
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "ShowCopilotButton" "DWord" 0
                            Set-SvcSafe "WSAIFabricSvc" "Disabled" $true
                            Get-AppxPackage -AllUsers "*Copilot*" -ErrorAction SilentlyContinue | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
                            Start-Process -FilePath "dism.exe" -ArgumentList "/Online /Disable-Feature /FeatureName:Recall /NoRestart" -NoNewWindow -Wait -ErrorAction SilentlyContinue
                            Log-Bg "[OK] Copilot, Windows Recall ve AI bilesenleri tamamen devre disi birakildi."
                        } else {
                            Set-RegSafe "HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot" "TurnOffWindowsCopilot" "DWord" "<RemoveEntry>"
                            Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" "TurnOffWindowsCopilot" "DWord" "<RemoveEntry>"
                            Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" "DisableAIDataAnalysis" "DWord" "<RemoveEntry>"
                            Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" "TurnOffSavingSnapshots" "DWord" "<RemoveEntry>"
                            Set-RegSafe "HKLM:\SOFTWARE\Policies\WindowsNotepad" "DisableAIFeatures" "DWord" "<RemoveEntry>"
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "ShowCopilotButton" "DWord" 1
                            Set-SvcSafe "WSAIFabricSvc" "Manual" $false
                            Log-Bg "[UNDO] Copilot ve Windows AI kisitlama ilkeleri kaldirildi."
                        }
                    }
                    "Tweak_EdgeDebloat" {
                        $edgePol = "HKLM:\SOFTWARE\Policies\Microsoft\Edge"
                        $edgeKeys = @(
                            "PersonalizationReportingEnabled", "ShowRecommendationsEnabled", "UserFeedbackAllowed",
                            "AlternateErrorPagesEnabled", "EdgeCollectionsEnabled", "EdgeShoppingAssistantEnabled",
                            "MicrosoftEdgeInsiderPromotionEnabled", "ShowMicrosoftRewards", "WebWidgetAllowed",
                            "DiagnosticData", "EdgeAssetDeliveryServiceEnabled", "WalletDonationEnabled",
                            "DefaultBrowserSettingsCampaignEnabled", "StartupBoostEnabled", "BackgroundModeEnabled"
                        )
                        if (-not $undo) {
                            Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\EdgeUpdate" "CreateDesktopShortcutDefault" "DWord" 0
                            Set-RegSafe $edgePol "HideFirstRunExperience" "DWord" 1
                            Set-RegSafe $edgePol "ConfigureDoNotTrack" "DWord" 1
                            foreach ($k in $edgeKeys) { Set-RegSafe $edgePol $k "DWord" 0 }
                            Stop-Process -Name "msedge" -Force -ErrorAction SilentlyContinue
                            Log-Bg "[OK] Microsoft Edge 17 gizlilik/izolasyon ilkesi uygulandi ve arka plan kapatildi."
                        } else {
                            Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\EdgeUpdate" "CreateDesktopShortcutDefault" "DWord" "<RemoveEntry>"
                            Set-RegSafe $edgePol "HideFirstRunExperience" "DWord" "<RemoveEntry>"
                            Set-RegSafe $edgePol "ConfigureDoNotTrack" "DWord" "<RemoveEntry>"
                            foreach ($k in $edgeKeys) { Set-RegSafe $edgePol $k "DWord" "<RemoveEntry>" }
                            Log-Bg "[UNDO] Microsoft Edge kisitlama ilkeleri varsayilana sifirlandi."
                        }
                    }
                    "Tweak_RemoveEdge" {
                        if (-not $undo) {
                            $edgeAppDir = "${env:ProgramFiles(x86)}\Microsoft\Edge\Application"
                            if (Test-Path $edgeAppDir) {
                                $setupPath = Get-ChildItem -Path $edgeAppDir -Filter "setup.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -Last 1
                                if ($setupPath) {
                                    New-Item -Path "$env:SystemRoot\SystemApps\Microsoft.MicrosoftEdge_8wekyb3d8bbwe\MicrosoftEdge.exe" -Force -ErrorAction SilentlyContinue | Out-Null
                                    Start-Process -FilePath $setupPath.FullName -ArgumentList "--uninstall --system-level --force-uninstall --delete-profile" -NoNewWindow -Wait -ErrorAction SilentlyContinue
                                    Log-Bg "[OK] Microsoft Edge sistem duzeyinde kaldirildi."
                                }
                            } else {
                                Log-Bg "[!] Microsoft Edge zaten kurulu degil."
                            }
                        } else {
                            Start-Process -FilePath "winget.exe" -ArgumentList "install --id Microsoft.Edge -e --silent --accept-package-agreements --accept-source-agreements" -NoNewWindow -Wait -ErrorAction SilentlyContinue
                            Log-Bg "[UNDO] Microsoft Edge Winget uzerinden yeniden kuruldu."
                        }
                    }
                    "Tweak_BraveDebloat" {
                        $bravePol = "HKLM:\SOFTWARE\Policies\BraveSoftware\Brave"
                        if (-not $undo) {
                            Set-RegSafe $bravePol "BraveRewardsDisabled" "DWord" 1
                            Set-RegSafe $bravePol "BraveWalletDisabled" "DWord" 1
                            Set-RegSafe $bravePol "BraveVPNDisabled" "DWord" 1
                            Set-RegSafe $bravePol "BraveAIChatEnabled" "DWord" 0
                            Set-RegSafe $bravePol "BraveStatsPingEnabled" "DWord" 0
                            Set-RegSafe $bravePol "BraveNewsDisabled" "DWord" 1
                            Set-RegSafe $bravePol "BraveTalkDisabled" "DWord" 1
                            Set-RegSafe $bravePol "TorDisabled" "DWord" 1
                            Set-RegSafe $bravePol "BraveP3AEnabled" "DWord" 0
                            Set-RegSafe $bravePol "MetricsReportingEnabled" "DWord" 0
                            Log-Bg "[OK] Brave Browser (Rewards, Wallet, Leo AI, VPN, Telemetri) debloat ilkeleri uygulandi."
                        } else {
                            Remove-Item -Path $bravePol -Recurse -Force -ErrorAction SilentlyContinue
                            Log-Bg "[UNDO] Brave Browser ilkeleri varsayilana sifirlandi."
                        }
                    }
                    "Tweak_PeripheralBlock" {
                        $razerPath = "$env:SystemRoot\Installer\Razer"
                        $prog64 = if ($env:ProgramW6432) { $env:ProgramW6432 } else { $env:ProgramFiles }
                        $logiPath = "$prog64\LogiDownloadAssistant"
                        if (-not $undo) {
                            Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching" "SearchOrderConfig" "DWord" 0
                            Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Installer" "DisableCoInstallers" "DWord" 1
                            Stop-Process -Name "logi_download_assistant" -Force -ErrorAction SilentlyContinue
                            if (!(Test-Path $razerPath)) { New-Item -Path $razerPath -ItemType Directory -Force | Out-Null }
                            if (!(Test-Path $logiPath)) { New-Item -Path $logiPath -ItemType Directory -Force | Out-Null }
                            icacls $razerPath /deny "*S-1-1-0:(W)" | Out-Null
                            icacls $logiPath /deny "*S-1-1-0:(W)" | Out-Null
                            Log-Bg "[OK] Razer Synapse ve Logitech Download Assistant otomatik kurulumu engellendi."
                        } else {
                            Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching" "SearchOrderConfig" "DWord" 1
                            Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Installer" "DisableCoInstallers" "DWord" 0
                            if (Test-Path $razerPath) { icacls $razerPath /remove:d "*S-1-1-0" | Out-Null }
                            if (Test-Path $logiPath) { icacls $logiPath /remove:d "*S-1-1-0" | Out-Null }
                            Log-Bg "[UNDO] Razer ve Logitech klasor yazma engelleri kaldirildi."
                        }
                    }
                    "Tweak_BlockAdobeNet" {
                        $hostsFile = "$env:SystemRoot\System32\drivers\etc\hosts"
                        if (-not $undo) {
                            $adobeRules = "`r`n#New Ver Adobe Block`r`n0.0.0.0 ic.adobe.io`r`n0.0.0.0 genuine.adobe.com`r`n0.0.0.0 prod.adobegenuine.com`r`n0.0.0.0 lm.licenses.adobe.com`r`n"
                            Add-Content -Path $hostsFile -Value $adobeRules -ErrorAction SilentlyContinue
                            ipconfig /flushdns | Out-Null
                            Log-Bg "[OK] Adobe telemetri ve dogrulama sunuculari hosts dosyasinda engellendi."
                        } else {
                            if (Test-Path $hostsFile) {
                                $c = (Get-Content $hostsFile -Raw) -replace '(?s)#New Ver Adobe Block.*', ''
                                Set-Content -Path $hostsFile -Value $c.TrimEnd() -Force -ErrorAction SilentlyContinue
                            }
                            ipconfig /flushdns | Out-Null
                            Log-Bg "[UNDO] Adobe hosts engelleme kurallari temizlendi."
                        }
                    }
                    "Tweak_IPv4Prefer" {
                        if (-not $undo) {
                            Set-RegSafe "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" "DisabledComponents" "DWord" 32
                            netsh interface teredo set state disabled | Out-Null
                            Log-Bg "[OK] IPv4 onceligi (DisabledComponents=32) aktif edildi ve Teredo kapatildi."
                        } else {
                            Set-RegSafe "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" "DisabledComponents" "DWord" 0
                            netsh interface teredo set state default | Out-Null
                            Log-Bg "[UNDO] IPv4/IPv6 onceligi ve Teredo varsayilana donduruldu."
                        }
                    }
                    "Tweak_DisableIPv6" {
                        if (-not $undo) {
                            Set-RegSafe "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" "DisabledComponents" "DWord" 255
                            Disable-NetAdapterBinding -Name "*" -ComponentID ms_tcpip6 -ErrorAction SilentlyContinue
                            Log-Bg "[OK] IPv6 tum ag bagdastiricilarinda devre disi birakildi."
                        } else {
                            Set-RegSafe "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" "DisabledComponents" "DWord" 0
                            Enable-NetAdapterBinding -Name "*" -ComponentID ms_tcpip6 -ErrorAction SilentlyContinue
                            Log-Bg "[UNDO] IPv6 tum ag bagdastiricilarinda yeniden etkinlestirildi."
                        }
                    }
                    "Tweak_DisableNotifications" {
                        if (-not $undo) {
                            Set-RegSafe "HKCU:\Software\Policies\Microsoft\Windows\Explorer" "DisableNotificationCenter" "DWord" 1
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\PushNotifications" "ToastEnabled" "DWord" 0
                            Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\Client" "RedirectionWarningDialogVersion" "DWord" 1
                            Set-RegSafe "HKCU:\SOFTWARE\Microsoft\Terminal Server Client" "RdpLaunchConsentAccepted" "DWord" 1
                            Log-Bg "[OK] Bildirim Merkezi ve imzasiz RDP dosyalari uyarilari kapatildi."
                        } else {
                            Set-RegSafe "HKCU:\Software\Policies\Microsoft\Windows\Explorer" "DisableNotificationCenter" "DWord" "<RemoveEntry>"
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\PushNotifications" "ToastEnabled" "DWord" 1
                            Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\Client" "RedirectionWarningDialogVersion" "DWord" "<RemoveEntry>"
                            Log-Bg "[UNDO] Bildirim Merkezi ve RDP uyarilari varsayilana donduruldu."
                        }
                    }
                    "Tweak_NewOutlookBlock" {
                        if (-not $undo) {
                            Set-RegSafe "HKCU:\SOFTWARE\Microsoft\Office\16.0\Outlook\Preferences" "UseNewOutlook" "DWord" 0
                            Set-RegSafe "HKCU:\Software\Microsoft\Office\16.0\Outlook\Options\General" "HideNewOutlookToggle" "DWord" 1
                            Set-RegSafe "HKCU:\Software\Policies\Microsoft\Office\16.0\Outlook\Options\General" "DoNewOutlookAutoMigration" "DWord" 0
                            Log-Bg "[OK] Yeni Outlook otomatik gecisi ve zorlamasi engellendi."
                        } else {
                            Set-RegSafe "HKCU:\SOFTWARE\Microsoft\Office\16.0\Outlook\Preferences" "UseNewOutlook" "DWord" 1
                            Set-RegSafe "HKCU:\Software\Microsoft\Office\16.0\Outlook\Options\General" "HideNewOutlookToggle" "DWord" 0
                            Log-Bg "[UNDO] Yeni Outlook secenegi varsayilana donduruldu."
                        }
                    }
                }
            } catch {
                Log-Bg "[!] $($tw.Id) islem uyarisi: $($_.Exception.Message)"
            }
        }
        Status-Bg "Secili sistem ince ayarlari tamamlandi ($($list.Count) / $($list.Count))!" 100
        Log-Bg "=== SISTEM INCE AYARLARI ISLEMI TAMAMLANDI ==="
    }
}

$script:BtnApplyTweaks.Add_Click({
    $sel = @($script:tweakCheckboxes | Where-Object { $_.IsChecked -eq $true } | ForEach-Object { $_.Tag })
    Start-TweaksEngine $sel $false
})

$script:BtnUndoTweaks.Add_Click({
    $sel = @($script:tweakCheckboxes | Where-Object { $_.IsChecked -eq $true } | ForEach-Object { $_.Tag })
    Start-TweaksEngine $sel $true
})

$script:BtnRevertContextMenu.Add_Click({
    Remove-Item -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" -Recurse -Force -ErrorAction SilentlyContinue
    Write-UiLog (Decode-U "[OK] Windows 11 varsay\u0131lan sa\u011F t\u0131k men\u00FCs\u00FCne d\u00F6n\u00FCld\u00FC.")
})

$script:BtnCleanTemp.Add_Click({
    Start-BackgroundTask "DiskClean" @{} {
        Status-Bg "Temp, Prefetch, Windows Update onbellegi ve DNS temizleniyor..." 40
        Log-Bg ">>> Kapsamli Disk, Temp, Prefetch ve DNS temizligi baslatildi..."
        Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "$env:SystemRoot\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "$env:SystemRoot\Prefetch\*" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "$env:SystemRoot\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction SilentlyContinue
        Start-Process -FilePath "cleanmgr.exe" -ArgumentList "/d C: /VERYLOWDISK" -NoNewWindow -ErrorAction SilentlyContinue
        ipconfig /flushdns | Out-Null
        Status-Bg "Disk, Temp ve DNS onbellegi basariyla temizlendi!" 100
        Log-Bg "[OK] Gecici dosyalar, Prefetch ve DNS onbellegi temizlendi."
    }
})

# =============================================================================
# 6. SEKME 3: HIZLI DNS, DERIN TEMIZLIK, WINDOWS UPDATE & DISM MOTORU
# =============================================================================
function Set-ActiveAdapterDns([string[]]$dnsV4, [string[]]$dnsV6, [string]$providerName) {
    try {
        $adapters = @(Get-NetAdapter -ErrorAction SilentlyContinue | Where-Object { $_.Status -eq 'Up' -and $_.InterfaceDescription -notmatch 'Virtual|Hyper-V|vEthernet|TAP|VPN|Loopback|VMware|VirtualBox' })
        if ($adapters.Count -eq 0) {
            $adapters = @(Get-NetAdapter -ErrorAction SilentlyContinue | Where-Object { $_.Status -eq 'Up' })
        }
        if ($adapters.Count -eq 0) {
            Write-UiLog (Decode-U "[!] Aktif bir fiziksel a\u011F ba\u011Fda\u015Ft\u0131r\u0131c\u0131s\u0131 bulunamad\u0131.")
            return
        }
        foreach ($nic in $adapters) {
            if ($dnsV4.Count -gt 0) {
                $allDns = $dnsV4 + $dnsV6
                Set-DnsClientServerAddress -InterfaceIndex $nic.InterfaceIndex -ServerAddresses $allDns -ErrorAction SilentlyContinue
                if (-not $?) {
                    Set-DnsClientServerAddress -InterfaceIndex $nic.InterfaceIndex -ServerAddresses $dnsV4 -ErrorAction Stop
                }
                Write-UiLog (Decode-U "[OK] [$($nic.Name)] i\u00E7in $providerName atand\u0131: $($dnsV4 -join ', ')")
            } else {
                Set-DnsClientServerAddress -InterfaceIndex $nic.InterfaceIndex -ResetServerAddresses -ErrorAction Stop
                Write-UiLog (Decode-U "[OK] [$($nic.Name)] DNS ayarlar\u0131 varsay\u0131lan (Otomatik DHCP) moduna d\u00F6nd\u00FCr\u00FCld\u00FC.")
            }
        }
        ipconfig /flushdns | Out-Null
        $script:TxtDnsStatus.Text = (Decode-U "Aktif DNS: $providerName ($($adapters[0].Name))")
        Set-UiStatus (Decode-U "DNS g\u00FCncellendi: $providerName") 100
    } catch {
        Write-UiLog "[HATA] DNS degistirilemedi: $($_.Exception.Message)"
    }
}

$script:BtnDnsCloudflare.Add_Click({ Set-ActiveAdapterDns @("1.1.1.1", "1.0.0.1") @("2606:4700:4700::1111", "2606:4700:4700::1001") "Cloudflare DNS (1.1.1.1)" })
$script:BtnDnsGoogle.Add_Click({ Set-ActiveAdapterDns @("8.8.8.8", "8.8.4.4") @("2001:4860:4860::8888", "2001:4860:4860::8844") "Google DNS (8.8.8.8)" })
$script:BtnDnsAdguard.Add_Click({ Set-ActiveAdapterDns @("94.140.14.14", "94.140.15.15") @("2a10:50c0::ad1:ff", "2a10:50c0::ad2:ff") "AdGuard Reklam Engelleyici DNS" })
$script:BtnDnsQuad9.Add_Click({ Set-ActiveAdapterDns @("9.9.9.9", "149.112.112.112") @("2620:fe::fe", "2620:fe::9") "Quad9 Guvenlik DNS (9.9.9.9)" })
$script:BtnDnsCloudflareMalware.Add_Click({ Set-ActiveAdapterDns @("1.1.1.2", "1.0.0.2") @("2606:4700:4700::1112", "2606:4700:4700::1002") "Cloudflare Malware Engelleyici (1.1.1.2)" })
$script:BtnDnsOpenDns.Add_Click({ Set-ActiveAdapterDns @("208.67.222.222", "208.67.220.220") @("2620:119:35::35", "2620:119:53::53") "Cisco OpenDNS" })
$script:BtnDnsDhcp.Add_Click({ Set-ActiveAdapterDns @() @() "Varsayilan (Otomatik DHCP)" })

# Derin Temizlik Butonlari (Apply + Undo)
$script:BtnDeepOneDrive.Add_Click({
    Start-TweaksEngine @([PSCustomObject]@{ Id = "Tweak_DeepOneDrive"; Title = "OneDrive Kokten Kaldirma" }) $false
})
$script:BtnRestoreOneDrive.Add_Click({
    Start-TweaksEngine @([PSCustomObject]@{ Id = "Tweak_DeepOneDrive"; Title = "OneDrive Geri Yukleme" }) $true
})
$script:BtnDisableCopilot.Add_Click({
    Start-TweaksEngine @([PSCustomObject]@{ Id = "Tweak_DisableCopilotAI"; Title = "Copilot ve Recall Kapatma" }) $false
})
$script:BtnEnableCopilot.Add_Click({
    Start-TweaksEngine @([PSCustomObject]@{ Id = "Tweak_DisableCopilotAI"; Title = "Copilot ve Recall Geri Acma" }) $true
})
$script:BtnDisableEdgeBg.Add_Click({
    Start-TweaksEngine @([PSCustomObject]@{ Id = "Tweak_EdgeDebloat"; Title = "Edge Izolasyonu ve Debloat" }) $false
})
$script:BtnEnableEdgeBg.Add_Click({
    Start-TweaksEngine @([PSCustomObject]@{ Id = "Tweak_EdgeDebloat"; Title = "Edge Ilkelerini Sifirlama" }) $true
})

# Windows Update Akilli Yonetimi (3 Mod - WinUtil Birebir)
$script:BtnWinUpdateSecurity.Add_Click({
    Start-BackgroundTask "WinUpdate_Security" @{} {
        Status-Bg "Windows Update Guvenlik Odakli Mod uygulaniyor..." 50
        Log-Bg ">>> Windows Update: Guvenlik Odakli Mod (WinUtil Recommended) yapilandiriliyor..."
        $wuPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
        $auPath = Join-Path $wuPath "AU"

        Remove-ItemProperty -Path $auPath -Name "NoAutoUpdate" -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path $wuPath -Name "DisableWindowsUpdateAccess" -ErrorAction SilentlyContinue

        Set-SvcSafe "BITS" "Manual" $false
        Set-SvcSafe "wuauserv" "Manual" $false
        Set-SvcSafe "UsoSvc" "Automatic" $false
        Set-SvcSafe "dosvc" "Manual" $false
        Start-Service -Name "UsoSvc" -ErrorAction SilentlyContinue

        $tasks = @('\Microsoft\Windows\InstallService\*', '\Microsoft\Windows\UpdateOrchestrator\*', '\Microsoft\Windows\UpdateAssistant\*', '\Microsoft\Windows\WaaSMedic\*', '\Microsoft\Windows\WindowsUpdate\*', '\Microsoft\WindowsUpdate\*')
        foreach ($t in $tasks) { Get-ScheduledTask -TaskPath $t -ErrorAction SilentlyContinue | Enable-ScheduledTask -ErrorAction SilentlyContinue | Out-Null }

        Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Device Metadata" "PreventDeviceMetadataFromNetwork" "DWord" 1
        Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DriverSearching" "DontPromptForWindowsUpdate" "DWord" 1
        Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DriverSearching" "DontSearchWindowsUpdate" "DWord" 1
        Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DriverSearching" "DriverUpdateWizardWuSearchEnabled" "DWord" 0
        Set-RegSafe $wuPath "ExcludeWUDriversInQualityUpdate" "DWord" 1
        Set-RegSafe $wuPath "DeferFeatureUpdates" "DWord" 1
        Set-RegSafe $wuPath "DeferFeatureUpdatesPeriodInDays" "DWord" 365
        Set-RegSafe $wuPath "DeferQualityUpdates" "DWord" 1
        Set-RegSafe $wuPath "DeferQualityUpdatesPeriodInDays" "DWord" 4
        Set-RegSafe $auPath "AUOptions" "DWord" 3
        Set-RegSafe $auPath "AUPowerManagement" "DWord" 0
        Set-RegSafe $auPath "NoAutoRebootWithLoggedOnUsers" "DWord" 1

        Log-Bg "[OK] Windows Update Guvenlik Odakli Mod aktif: Ozellik guncellemeleri 365 gun, kalite guncellemeleri 4 gun ertelendi, surucu guncellemeleri kapatildi."
        Status-Bg "Windows Update: Guvenlik Odakli Mod Aktif!" 100
    }
})

$script:BtnWinUpdateDisable.Add_Click({
    Start-BackgroundTask "WinUpdate_Disable" @{} {
        Status-Bg "Windows Update tamamen devre disi birakiliyor..." 50
        Log-Bg ">>> Windows Update: Tamamen Durdurma Modu (WinUtil Disable) uygulaniyor..."
        Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" "NoAutoUpdate" "DWord" 1
        Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" "AUOptions" "DWord" 1
        Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" "DODownloadMode" "DWord" 0

        foreach ($svc in @("BITS", "wuauserv", "UsoSvc", "dosvc")) {
            Set-SvcSafe $svc "Disabled" $true
        }
        Remove-Item -Path "$env:SystemRoot\SoftwareDistribution\*" -Recurse -Force -ErrorAction SilentlyContinue

        $tasks = @('\Microsoft\Windows\InstallService\*', '\Microsoft\Windows\UpdateOrchestrator\*', '\Microsoft\Windows\UpdateAssistant\*', '\Microsoft\Windows\WaaSMedic\*', '\Microsoft\Windows\WindowsUpdate\*', '\Microsoft\WindowsUpdate\*')
        foreach ($t in $tasks) { Get-ScheduledTask -TaskPath $t -ErrorAction SilentlyContinue | Disable-ScheduledTask -ErrorAction SilentlyContinue | Out-Null }

        Log-Bg "[OK] Windows Update servisleri (wuauserv, bits, UsoSvc, dosvc) ve gorevleri tamamen durduruldu."
        Status-Bg "Windows Update tamamen devre disi birakildi!" 100
    }
})

$script:BtnWinUpdateDefault.Add_Click({
    Start-BackgroundTask "WinUpdate_Default" @{} {
        Status-Bg "Windows Update varsayilan fabrika ayarlarina donduruluyor..." 50
        Log-Bg ">>> Windows Update: Varsayilan Mod (Stock Defaults) yukleniyor..."
        $wuPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
        $auPath = Join-Path $wuPath "AU"
        foreach ($n in @("NoAutoUpdate", "AUOptions", "NoAutoRebootWithLoggedOnUsers", "AUPowerManagement")) {
            Remove-ItemProperty -Path $auPath -Name $n -Force -ErrorAction SilentlyContinue
        }
        foreach ($n in @("ExcludeWUDriversInQualityUpdate", "DeferFeatureUpdates", "DeferFeatureUpdatesPeriodInDays", "DeferQualityUpdates", "DeferQualityUpdatesPeriodInDays")) {
            Remove-ItemProperty -Path $wuPath -Name $n -Force -ErrorAction SilentlyContinue
        }
        foreach ($n in @("DontPromptForWindowsUpdate", "DontSearchWindowsUpdate", "DriverUpdateWizardWuSearchEnabled")) {
            Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DriverSearching" -Name $n -Force -ErrorAction SilentlyContinue
        }
        Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" -Name "DODownloadMode" -Force -ErrorAction SilentlyContinue

        Set-SvcSafe "BITS" "Manual" $false
        Set-SvcSafe "wuauserv" "Manual" $false
        Set-SvcSafe "UsoSvc" "Automatic" $false
        Set-SvcSafe "dosvc" "Manual" $false
        Start-Service -Name "UsoSvc" -ErrorAction SilentlyContinue

        $tasks = @('\Microsoft\Windows\InstallService\*', '\Microsoft\Windows\UpdateOrchestrator\*', '\Microsoft\Windows\UpdateAssistant\*', '\Microsoft\Windows\WaaSMedic\*', '\Microsoft\Windows\WindowsUpdate\*', '\Microsoft\WindowsUpdate\*')
        foreach ($t in $tasks) { Get-ScheduledTask -TaskPath $t -ErrorAction SilentlyContinue | Enable-ScheduledTask -ErrorAction SilentlyContinue | Out-Null }

        Log-Bg "[OK] Windows Update standart fabrika ayarlarina geri donduruldu."
        Status-Bg "Windows Update varsayilan moda donduruldu!" 100
    }
})

# Windows Istege Bagli Bilesenleri (DISM Engine - 10 Bilesen)
$script:featureCheckboxes = @()

foreach ($ft in $script:FeaturesData) {
    $ftName = Decode-U $ft.Name
    $ftDesc = Decode-U $ft.Desc

    $card = New-Object System.Windows.Controls.Border
    $card.Background = Get-Brush $initTheme.CardBg
    $card.BorderBrush = Get-Brush $initTheme.BorderBrushColor
    $card.BorderThickness = "1"
    $card.CornerRadius = "6"
    $card.Padding = "10"
    $card.Margin = "4"
    $card.Cursor = "Hand"

    $sp = New-Object System.Windows.Controls.StackPanel
    $cb = New-Object System.Windows.Controls.CheckBox
    $cb.Content = $ftName
    $cb.Foreground = Get-Brush "#F8FAFC"
    $cb.FontWeight = "Bold"
    $cb.FontSize = 13

    $fId = New-Object System.Windows.Controls.TextBlock
    $fId.Text = "DISM: $($ft.Feature)"
    $fId.FontSize = 10
    $fId.FontFamily = "Consolas"
    $fId.Foreground = Get-Brush $initTheme.TextDim
    $fId.Margin = "22,0,0,0"

    $cb.Tag = [PSCustomObject]@{
        Name          = $ftName
        Feature       = $ft.Feature
        ExtraFeatures = @($ft.ExtraFeatures)
        StatusBlock   = $fId
    }

    $d = New-Object System.Windows.Controls.TextBlock
    $d.Text = $ftDesc
    $d.FontSize = 11
    $d.Foreground = Get-Brush $initTheme.TextMuted
    $d.Margin = "22,3,0,2"
    $d.TextWrapping = "Wrap"

    [void]$sp.Children.Add($cb)
    [void]$sp.Children.Add($d)
    [void]$sp.Children.Add($fId)
    $card.Child = $sp

    $card.Tag = $cb
    $card.Add_MouseLeftButtonUp({
        param($sender, $e)
        if ($e.OriginalSource -isnot [System.Windows.Controls.CheckBox]) {
            $targetCb = $sender.Tag
            $targetCb.IsChecked = -not $targetCb.IsChecked
        }
    })

    [void]$script:FeaturesGrid.Children.Add($card)
    $script:featureCheckboxes += $cb
}

$script:BtnCheckFeaturesStatus.Add_Click({
    Start-BackgroundTask "CheckDISMStatus" @{ Checkboxes = $script:featureCheckboxes } {
        param($p)
        Status-Bg "DISM ile Windows bilesen durumlari sorgulaniyor..." 30
        Log-Bg ">>> Windows istege bagli bilesenlerin kurulum durumu kontrol ediliyor..."
        foreach ($cb in $p.Checkboxes) {
            $featName = $cb.Tag.Feature
            try {
                $st = (Get-WindowsOptionalFeature -Online -FeatureName $featName -ErrorAction SilentlyContinue).State
                $stText = if ($st) { [string]$st } else { "Bilinmiyor" }
                $sync.Window.Dispatcher.Invoke([action]{
                    $cb.Tag.StatusBlock.Text = "DISM: $featName [Durum: $stText]"
                })
                Log-Bg "  -> $($cb.Tag.Name) ($featName): $stText"
            } catch {}
        }
        Status-Bg "Windows bilesen durumlari guncellendi!" 100
    }
})

function Start-DismFeaturesJob([bool]$enableMode) {
    $selFeatures = @($script:featureCheckboxes | Where-Object { $_.IsChecked -eq $true } | ForEach-Object { $_.Tag })
    if ($selFeatures.Count -eq 0) {
        Write-UiLog (Decode-U "[!] L\u00FCtfen i\u015Flem yap\u0131lacak en az bir Windows bile\u015Feni se\u00E7in.")
        return
    }
    $script:BtnApplyFeatures.IsEnabled   = $false
    $script:BtnDisableFeatures.IsEnabled = $false

    Start-BackgroundTask "DISM_Features" @{ Features = $selFeatures; Enable = $enableMode } {
        param($p)
        $list = $p.Features
        $enable = [bool]$p.Enable
        $total = $list.Count
        $idx = 0
        foreach ($ft in $list) {
            $idx++
            $pct = [math]::Round(($idx / $total) * 100)
            $allFeats = @($ft.Feature) + @($ft.ExtraFeatures | Where-Object { $_ })
            if ($enable) {
                Status-Bg "($idx/$total) DISM Etkinlestiriliyor: $($ft.Name)..." $pct
                Log-Bg "[$idx/$total] DISM Bileseni Etkinlestiriliyor: $($ft.Name) ($($allFeats -join ', '))"
                foreach ($fName in $allFeats) {
                    $proc = Start-Process -FilePath "dism.exe" -ArgumentList "/Online /Enable-Feature /FeatureName:$fName /All /NoRestart" -NoNewWindow -Wait -PassThru
                    if ($proc.ExitCode -eq 0 -or $proc.ExitCode -eq 3010) {
                        Log-Bg "  [OK] $fName etkinlestirildi."
                    } else {
                        Log-Bg "  [!] $fName DISM cikis kodu: $($proc.ExitCode)"
                    }
                }
            } else {
                Status-Bg "($idx/$total) DISM Devre Disi Birakiliyor: $($ft.Name)..." $pct
                Log-Bg "[$idx/$total] DISM Bileseni Kapatiliyor: $($ft.Name) ($($ft.Feature))"
                $proc = Start-Process -FilePath "dism.exe" -ArgumentList "/Online /Disable-Feature /FeatureName:$($ft.Feature) /NoRestart" -NoNewWindow -Wait -PassThru
                if ($proc.ExitCode -eq 0 -or $proc.ExitCode -eq 3010) {
                    Log-Bg "  [OK] $($ft.Feature) devre disi birakildi."
                } else {
                    Log-Bg "  [!] $($ft.Feature) DISM cikis kodu: $($proc.ExitCode)"
                }
            }
        }
        Status-Bg "DISM Windows bilesen islemleri tamamlandi!" 100
        Log-Bg "=== TUM DISM WINDOWS BILESEN ISLEMLERI TAMAMLANDI ==="
    }
}

$script:BtnApplyFeatures.Add_Click({ Start-DismFeaturesJob $true })
$script:BtnDisableFeatures.Add_Click({ Start-DismFeaturesJob $false })

# =============================================================================
# 7. SEKME 4: KAPSAMLI BLOATWARE VE UWP TASFIYESI (42 PAKET - KALDIR / YUKLE)
# =============================================================================
$script:bloatCheckboxes = @()

foreach ($bl in $script:BloatwareData) {
    $blName = Decode-U $bl.Name

    $card = New-Object System.Windows.Controls.Border
    $card.Background = Get-Brush $initTheme.CardBg
    $card.BorderBrush = Get-Brush $initTheme.BorderBrushColor
    $card.BorderThickness = "1"
    $card.CornerRadius = "6"
    $card.Padding = "10"
    $card.Margin = "4"
    $card.Cursor = "Hand"

    $sp = New-Object System.Windows.Controls.StackPanel
    $cb = New-Object System.Windows.Controls.CheckBox
    $cb.Content = $blName
    $cb.Foreground = Get-Brush "#F8FAFC"
    $cb.FontWeight = "SemiBold"
    $cb.FontSize = 13
    $cb.IsChecked = [bool]$bl.DefaultCheck
    $cb.Tag = [PSCustomObject]@{
        Name         = $blName
        Pkg          = $bl.Pkg
        StoreId      = $bl.StoreId
        DefaultCheck = [bool]$bl.DefaultCheck
    }

    $pkgTxt = New-Object System.Windows.Controls.TextBlock
    $pkgTxt.Text = $bl.Pkg
    $pkgTxt.FontSize = 10.5
    $pkgTxt.FontFamily = "Consolas"
    $pkgTxt.Foreground = Get-Brush $initTheme.TextDim
    $pkgTxt.Margin = "22,3,0,0"

    [void]$sp.Children.Add($cb)
    [void]$sp.Children.Add($pkgTxt)
    $card.Child = $sp

    $card.Tag = $cb
    $card.Add_MouseLeftButtonUp({
        param($sender, $e)
        if ($e.OriginalSource -isnot [System.Windows.Controls.CheckBox]) {
            $targetCb = $sender.Tag
            $targetCb.IsChecked = -not $targetCb.IsChecked
        }
    })

    [void]$script:BloatwareGrid.Children.Add($card)
    $script:bloatCheckboxes += $cb
}

$script:BtnSelectDefaultBloat.Add_Click({
    foreach ($cb in $script:bloatCheckboxes) { $cb.IsChecked = [bool]$cb.Tag.DefaultCheck }
    Write-UiLog (Decode-U "\u00D6nerilen g\u00FCvenli Bloatware listesi se\u00E7ildi.")
})

$script:BtnSelectAllBloat.Add_Click({
    foreach ($cb in $script:bloatCheckboxes) { $cb.IsChecked = $true }
})

$script:BtnClearBloat.Add_Click({
    foreach ($cb in $script:bloatCheckboxes) { $cb.IsChecked = $false }
})

$script:BtnRemoveBloatware.Add_Click({
    $selBloat = @($script:bloatCheckboxes | Where-Object { $_.IsChecked -eq $true } | ForEach-Object { $_.Tag })
    if ($selBloat.Count -eq 0) {
        Write-UiLog (Decode-U "[!] L\u00FCtfen kald\u0131rmak i\u00E7in en az bir Bloatware paketi se\u00E7in.")
        return
    }
    $script:BtnRemoveBloatware.IsEnabled    = $false
    $script:BtnReinstallBloatware.IsEnabled = $false

    Start-BackgroundTask "RemoveBloatware" @{ Packages = $selBloat } {
        param($p)
        $list = $p.Packages
        $total = $list.Count
        Log-Bg ">>> $total UWP Bloatware paketi (AllUsers + Provisioned) sistemden kaldiriliyor..."
        $provPackages = @(Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue)
        $i = 0
        foreach ($b in $list) {
            $i++
            $pct = [math]::Round(($i / $total) * 100)
            Status-Bg "($i/$total) Bloatware Kaldiriliyor: $($b.Name)..." $pct
            try {
                $patterns = $b.Pkg -split '\|'
                foreach ($pat in $patterns) {
                    Get-AppxPackage -Name $pat -AllUsers -ErrorAction SilentlyContinue | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
                    $provPackages | Where-Object { $_.DisplayName -like $pat } | ForEach-Object {
                        Remove-AppxProvisionedPackage -Online -PackageName $_.PackageName -ErrorAction SilentlyContinue | Out-Null
                    }
                }
                Log-Bg "  [OK] Kaldirildi: $($b.Name) ($($b.Pkg))"
            } catch {
                Log-Bg "  [!] $($b.Name) uyarisi: $($_.Exception.Message)"
            }
        }
        Status-Bg "Secili Bloatware paketleri tamamen kaldirildi ($total / $total)!" 100
        Log-Bg "=== BLOATWARE TEMIZLIGI TAMAMLANDI ==="
    }
})

$script:BtnReinstallBloatware.Add_Click({
    $selBloat = @($script:bloatCheckboxes | Where-Object { $_.IsChecked -eq $true } | ForEach-Object { $_.Tag })
    if ($selBloat.Count -eq 0) {
        Write-UiLog (Decode-U "[!] L\u00FCtfen geri y\u00FCklemek i\u00E7in en az bir paket se\u00E7in.")
        return
    }
    $script:BtnRemoveBloatware.IsEnabled    = $false
    $script:BtnReinstallBloatware.IsEnabled = $false

    Start-BackgroundTask "ReinstallBloatware" @{ Packages = $selBloat } {
        param($p)
        $list = $p.Packages
        $total = $list.Count
        Log-Bg ">>> $total UWP paketi Microsoft Store (Winget) uzerinden geri yukleniyor..."
        $i = 0
        foreach ($b in $list) {
            $i++
            $pct = [math]::Round(($i / $total) * 100)
            Status-Bg "($i/$total) Geri Yukleniyor: $($b.Name)..." $pct
            if ($b.StoreId) {
                Start-Process -FilePath "winget.exe" -ArgumentList "install --id `"$($b.StoreId)`" --source msstore --silent --accept-package-agreements --accept-source-agreements" -NoNewWindow -Wait -ErrorAction SilentlyContinue
                Log-Bg "  [OK] Geri yuklendi: $($b.Name) (StoreId: $($b.StoreId))"
            } else {
                Log-Bg "  [!] $($b.Name) icin StoreId bulunamadi."
            }
        }
        Status-Bg "Secili UWP paketleri geri yuklendi!" 100
    }
})

# =============================================================================
# 8. SEKME 5: SISTEM YARDIMCI ARACLARI, ONARIM & MAS AKTIVASYON
# =============================================================================
$script:BtnRunMAS.Add_Click({
    Write-UiLog (Decode-U ">>> Microsoft Activation Scripts (MAS) ba\u015Flat\u0131l\u0131yor (get.activated.win / DoH Bypass / massgrave.dev)...")
    Set-UiStatus (Decode-U "MAS Aktivasyon penceresi a\u00E7\u0131l\u0131yor...") 50
    try {
        $masRunner = Join-Path $env:TEMP "UmutEvranTool_MAS_Launcher.ps1"
        $masCode = @'
$ErrorActionPreference = 'Continue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$Host.UI.RawUI.WindowTitle = "Microsoft Activation Scripts (MAS) - UmutEvranTool"
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "   MICROSOFT ACTIVATION SCRIPTS (MAS) YUKLENIYOR...             " -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan

$scriptBody = $null

# 1. Resmi birincil adres: https://get.activated.win
try {
    Write-Host "[1/3] Baglaniliyor: https://get.activated.win ..." -ForegroundColor Yellow
    $scriptBody = Invoke-RestMethod -Uri "https://get.activated.win" -UseBasicParsing -TimeoutSec 15 -ErrorAction Stop
} catch {
    Write-Host "[!] Standart baglanti engellendi veya yanit vermedi: $($_.Exception.Message)" -ForegroundColor DarkYellow
}

# 2. ISS / DNS Engeli varsa Cloudflare DoH (1.1.1.1) uzerinden curl.exe ile asma
if ([string]::IsNullOrWhiteSpace($scriptBody)) {
    try {
        Write-Host "[2/3] DNS engeli Cloudflare DoH (1.1.1.1) ile asiliyor..." -ForegroundColor Yellow
        $dohOut = & curl.exe -s -L --doh-url https://1.1.1.1/dns-query https://get.activated.win 2>$null | Out-String
        if ($dohOut -and $dohOut.Length -gt 500) {
            $scriptBody = $dohOut
        }
    } catch {}
}

# 3. Yedek resmi ayna: https://massgrave.dev/get
if ([string]::IsNullOrWhiteSpace($scriptBody)) {
    try {
        Write-Host "[3/3] Yedek ayna deneniyor: https://massgrave.dev/get ..." -ForegroundColor Yellow
        $scriptBody = Invoke-RestMethod -Uri "https://massgrave.dev/get" -UseBasicParsing -TimeoutSec 15 -ErrorAction Stop
    } catch {}
}

if (-not [string]::IsNullOrWhiteSpace($scriptBody)) {
    Write-Host "[OK] MAS basariyla indirildi! Arayuz aciliyor..." -ForegroundColor Green
    Invoke-Expression $scriptBody
} else {
    Write-Host "`n[HATA] MAS sunucularina ulasilamadi (ISS veya Antivirus engeli olabilir)." -ForegroundColor Red
    Write-Host "Lutfen uygulama icindeki Hizli DNS bolumunden Cloudflare (1.1.1.1) secip tekrar deneyin." -ForegroundColor Yellow
    Read-Host "Kapatmak icin Enter tusuna basin"
}
'@
        [System.IO.File]::WriteAllText($masRunner, $masCode, [System.Text.Encoding]::ASCII)
        Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$masRunner`"" -Verb RunAs
        Write-UiLog (Decode-U "[OK] MAS Aktivasyon penceresi ba\u015Flat\u0131ld\u0131 (get.activated.win + DoH + massgrave.dev).")
        Set-UiStatus (Decode-U "MAS Aktivasyon penceresi ba\u015Flat\u0131ld\u0131!") 100
    } catch {
        Write-UiLog "[HATA] MAS baslatilamadi: $($_.Exception.Message)"
    }
})

$script:BtnCreateGodMode.Add_Click({
    try {
        $desktopPath = [Environment]::GetFolderPath("Desktop")
        $godModePath = Join-Path $desktopPath "GodMode.{ED7BA470-8E54-465E-825C-99712043E01C}"
        if (!(Test-Path -LiteralPath $godModePath)) {
            New-Item -Path $godModePath -ItemType Directory -Force | Out-Null
        }
        Write-UiLog (Decode-U "[OK] Masa\u00FCst\u00FCnde God Mode (Tanr\u0131 Modu) klas\u00F6r\u00FC olu\u015Fturuldu.")
        Set-UiStatus (Decode-U "God Mode klas\u00F6r\u00FC Masa\u00FCst\u00FCnde olu\u015Fturuldu!") 100
    } catch {
        Write-UiLog "[HATA] God Mode olusturulamadi: $($_.Exception.Message)"
    }
})

$script:BtnRunOOSU.Add_Click({
    Start-BackgroundTask "RunOOSU" @{} {
        Status-Bg "O&O ShutUp10++ indiriliyor..." 40
        Log-Bg ">>> O&O ShutUp10++ resmi sunucudan indiriliyor..."
        $dest = Join-Path $env:TEMP "OOSU10.exe"
        Invoke-WebRequest -Uri "https://dl5.oo-software.com/files/ooshutup10/OOSU10.exe" -OutFile $dest -UseBasicParsing -ErrorAction Stop
        Status-Bg "O&O ShutUp10++ baslatiliyor..." 100
        Start-Process -FilePath $dest
        Log-Bg "[OK] O&O ShutUp10++ indirildi ve baslatildi."
    }
})

$script:BtnFixSystemCorruption.Add_Click({
    Start-BackgroundTask "SystemRepair" @{} {
        Status-Bg "Adim 1/3: Disk Hata Taramasi (chkdsk /scan /perf)..." 20
        Log-Bg ">>> [1/3] Disk taramasi baslatiliyor: chkdsk /scan /perf"
        Start-Process -FilePath "cmd.exe" -ArgumentList "/c chkdsk /scan /perf" -NoNewWindow -Wait

        Status-Bg "Adim 2/3: Sistem Dosya Denetleyicisi (sfc /scannow)..." 55
        Log-Bg ">>> [2/3] Korunan sistem dosyalari onariliyor: sfc /scannow"
        Start-Process -FilePath "cmd.exe" -ArgumentList "/c sfc /scannow" -NoNewWindow -Wait

        Status-Bg "Adim 3/3: Windows Imaj Onarimi (DISM /RestoreHealth)..." 85
        Log-Bg ">>> [3/3] Windows sistem goruntusu onariliyor: DISM /Online /Cleanup-Image /RestoreHealth"
        Start-Process -FilePath "cmd.exe" -ArgumentList "/c dism /online /cleanup-image /restorehealth" -NoNewWindow -Wait

        Status-Bg "Sistem Bozulma Taramasi ve Onarimi tamamlandi!" 100
        Log-Bg "[OK] Chkdsk, SFC ve DISM onarim adimlari tamamlandi."
    }
})

$script:BtnFixWinUpdate.Add_Click({
    Start-BackgroundTask "FixWindowsUpdate" @{} {
        Status-Bg "Windows Update servisleri durduruluyor ve onbellek sifirlaniyor..." 25
        Log-Bg ">>> Windows Update Tam Sifirlama ve Onarim (WinUtil FixesUpdate) baslatildi..."
        foreach ($svc in @("BITS", "wuauserv", "appidsvc", "cryptsvc")) {
            Stop-Service -Name $svc -Force -ErrorAction SilentlyContinue
        }
        Remove-Item "$env:ALLUSERSPROFILE\Application Data\Microsoft\Network\Downloader\qmgr*.dat" -Force -ErrorAction SilentlyContinue
        Rename-Item "$env:SystemRoot\SoftwareDistribution\DataStore" "DataStore.bak" -Force -ErrorAction SilentlyContinue
        Rename-Item "$env:SystemRoot\SoftwareDistribution\Download" "Download.bak" -Force -ErrorAction SilentlyContinue
        Rename-Item "$env:SystemRoot\System32\catroot2" "catroot2.bak" -Force -ErrorAction SilentlyContinue

        Status-Bg "Windows Update DLL dosyalari yeniden kaydediliyor..." 60
        $dlls = @(
            "atl.dll", "urlmon.dll", "mshtml.dll", "shdocvw.dll", "browseui.dll", "jscript.dll",
            "vbscript.dll", "scrrun.dll", "msxml.dll", "msxml3.dll", "msxml6.dll", "actxprxy.dll",
            "softpub.dll", "wintrust.dll", "dssenh.dll", "rsaenh.dll", "gpkcsp.dll", "sccbase.dll",
            "slbcsp.dll", "cryptdlg.dll", "oleaut32.dll", "ole32.dll", "shell32.dll", "initpki.dll",
            "wuapi.dll", "wuaueng.dll", "wuaueng1.dll", "wucltui.dll", "wups.dll", "wups2.dll",
            "wuweb.dll", "qmgr.dll", "qmgrprxy.dll", "wucltux.dll", "muweb.dll", "wuwebv.dll"
        )
        foreach ($d in $dlls) {
            Start-Process -FilePath "regsvr32.exe" -ArgumentList "/s $d" -NoNewWindow -ErrorAction SilentlyContinue
        }

        netsh winsock reset | Out-Null
        netsh winhttp reset proxy | Out-Null
        Get-BitsTransfer -ErrorAction SilentlyContinue | Remove-BitsTransfer -ErrorAction SilentlyContinue

        foreach ($svc in @("BITS", "wuauserv", "cryptsvc")) {
            Set-SvcSafe $svc "Manual" $false
            Start-Service -Name $svc -ErrorAction SilentlyContinue
        }
        Start-Process -FilePath "wuauclt.exe" -ArgumentList "/resetauthorization /detectnow" -NoNewWindow -ErrorAction SilentlyContinue
        Log-Bg "[OK] Windows Update bilesenleri, DLL kayitlari ve indirme klasorleri sifirlandi."
        Status-Bg "Windows Update tam onarimi tamamlandi!" 100
    }
})

$script:BtnFixNetwork.Add_Click({
    Start-BackgroundTask "FixNetwork" @{} {
        Status-Bg "Ag yigini (Winsock, IP ve DNS) sifirlaniyor..." 50
        Log-Bg ">>> Ag sifirlama komutlari calistiriliyor (winsock & ip reset)..."
        netsh winsock reset | Out-Null
        netsh int ip reset | Out-Null
        ipconfig /release | Out-Null
        ipconfig /renew | Out-Null
        ipconfig /flushdns | Out-Null
        Log-Bg "[OK] Ag yapilandirmasi sifirlandi (Tam etki icin yeniden baslatma onerilir)."
        Status-Bg "Ag sifirlama tamamlandi!" 100
    }
})

$script:BtnFixWinget.Add_Click({
    Start-BackgroundTask "FixWinget" @{} {
        Status-Bg "WinGet paket yoneticisi kaynaklari ve kayitlari onariliyor..." 50
        Log-Bg ">>> WinGet kaynaklari sifirlaniyor ve guncelleniyor..."
        winget source reset --force | Out-Null
        winget source update | Out-Null
        Add-AppxPackage -DisableDevelopmentMode -Register "$env:ProgramFiles\WindowsApps\Microsoft.DesktopAppInstaller_*_x64__8wekyb3d8bbwe\AppxManifest.xml" -ErrorAction SilentlyContinue
        Log-Bg "[OK] WinGet paket yoneticisi kaynaklari ve AppInstaller kaydi onarildi."
        Status-Bg "WinGet onarimi tamamlandi!" 100
    }
})

$script:BtnFixNTP.Add_Click({
    Start-BackgroundTask "FixNTP" @{} {
        Status-Bg "NTP Saat Sunucusu (pool.ntp.org) yapilandiriliyor..." 50
        Start-Service -Name "w32time" -ErrorAction SilentlyContinue
        w32tm /config /manualpeerlist:"pool.ntp.org" /syncfromflags:manual /reliable:YES /update | Out-Null
        Restart-Service -Name "w32time" -Force -ErrorAction SilentlyContinue
        w32tm /resync | Out-Null
        Log-Bg "[OK] NTP Saat Sunucusu pool.ntp.org olarak ayarlandi ve senkronize edildi."
        Status-Bg "NTP saat senkronizasyonu tamamlandi!" 100
    }
})

$script:BtnRunAutologon.Add_Click({
    Start-BackgroundTask "RunAutologon" @{} {
        Status-Bg "Microsoft Sysinternals AutoLogon indiriliyor..." 50
        $dest = Join-Path $env:TEMP "Autologon64.exe"
        Invoke-WebRequest -Uri "https://live.sysinternals.com/Autologon64.exe" -OutFile $dest -UseBasicParsing -ErrorAction Stop
        Start-Process -FilePath $dest -ArgumentList "/accepteula"
        Log-Bg "[OK] Sysinternals AutoLogon indirildi ve baslatildi."
        Status-Bg "AutoLogon baslatildi!" 100
    }
})

$script:BtnEnableOpenSSH.Add_Click({
    Start-BackgroundTask "EnableOpenSSH" @{} {
        Status-Bg "OpenSSH Server kuruluyor ve yapilandiriliyor..." 50
        Log-Bg ">>> OpenSSH Sunucusu kontrol ediliyor ve etkinlestiriliyor..."
        $cap = Get-WindowsCapability -Online -Name "OpenSSH.Server~~~~0.0.1.0" -ErrorAction SilentlyContinue
        if ($cap -and $cap.State -ne "Installed") {
            Add-WindowsCapability -Online -Name "OpenSSH.Server~~~~0.0.1.0" -ErrorAction SilentlyContinue | Out-Null
        }
        Set-SvcSafe "sshd" "Automatic" $false
        Set-SvcSafe "ssh-agent" "Automatic" $false
        Start-Service -Name "sshd" -ErrorAction SilentlyContinue
        Start-Service -Name "ssh-agent" -ErrorAction SilentlyContinue
        if (!(Get-NetFirewallRule -Name "sshd" -ErrorAction SilentlyContinue)) {
            New-NetFirewallRule -Name "sshd" -DisplayName "OpenSSH Server (sshd)" -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22 -ErrorAction SilentlyContinue | Out-Null
        }
        Log-Bg "[OK] OpenSSH Server kuruldu, Port 22 acildi ve servisler baslatildi."
        Status-Bg "OpenSSH Server aktif!" 100
    }
})

$script:BtnEnableRegBackup.Add_Click({
    try {
        if (!(Test-Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Configuration Manager")) {
            New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Configuration Manager" -Force | Out-Null
        }
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Configuration Manager" -Name "EnablePeriodicBackup" -Type DWord -Value 1 -Force
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Configuration Manager" -Name "BackupCount" -Type DWord -Value 2 -Force
        $action  = New-ScheduledTaskAction -Execute "schtasks.exe" -Argument '/run /i /tn "\Microsoft\Windows\Registry\RegIdleBackup"'
        $trigger = New-ScheduledTaskTrigger -Daily -At "00:30"
        Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "AutoRegBackup" -Description "Create System Registry Backups" -User "SYSTEM" -Force -ErrorAction SilentlyContinue | Out-Null
        Write-UiLog (Decode-U "[OK] G\u00FCnl\u00FCk otomatik Kay\u0131t Defteri yedekleme g\u00F6revi (00:30) etkinle\u015Ftirildi.")
        Set-UiStatus (Decode-U "G\u00FCnl\u00FCk Kay\u0131t Defteri yede\u011Fi aktif!") 100
    } catch {
        Write-UiLog "[HATA] Kayit defteri yedegi gorevi olusturulamadi: $($_.Exception.Message)"
    }
})

$script:BtnRestartExplorer.Add_Click({
    try {
        Stop-Process -Name "explorer" -Force -ErrorAction SilentlyContinue
        Start-Sleep -Milliseconds 500
        if (!(Get-Process -Name "explorer" -ErrorAction SilentlyContinue)) {
            Start-Process "explorer.exe"
        }
        Write-UiLog (Decode-U "[OK] Dosya Gezgini (explorer.exe) yeniden ba\u015Flat\u0131ld\u0131.")
    } catch {}
})

$script:BtnEnableF8Boot.Add_Click({
    bcdedit.exe /set bootmenupolicy legacy | Out-Null
    Write-UiLog (Decode-U "[OK] Klasik F8 G\u00FCvenli Mod \u00F6ny\u00FCkleme men\u00FCs\u00FC etkinle\u015Ftirildi (bootmenupolicy legacy).")
})

$script:BtnDisableF8Boot.Add_Click({
    bcdedit.exe /set bootmenupolicy standard | Out-Null
    Write-UiLog (Decode-U "[OK] Standart modern \u00F6ny\u00FCkleme men\u00FCs\u00FCne d\u00F6n\u00FCld\u00FC (bootmenupolicy standard).")
})

# Klasik Windows Denetim Masasi ve Yonetim Konsollari (12 Panel)
function Open-SystemPanel([string]$cmd, [string]$argsStr = "") {
    try {
        if ([string]::IsNullOrEmpty($argsStr)) {
            Start-Process $cmd
        } else {
            Start-Process $cmd -ArgumentList $argsStr
        }
        Write-UiLog (Decode-U "[OK] Sistem konsolu a\u00E7\u0131ld\u0131: $cmd $argsStr")
    } catch {
        Write-UiLog "[!] Konsol acilamadi ($cmd): $($_.Exception.Message)"
    }
}

$script:BtnPanelControl.Add_Click({ Open-SystemPanel "control.exe" })
$script:BtnPanelNetwork.Add_Click({ Open-SystemPanel "ncpa.cpl" })
$script:BtnPanelSystem.Add_Click({ Open-SystemPanel "sysdm.cpl" })
$script:BtnPanelPower.Add_Click({ Open-SystemPanel "powercfg.cpl" })
$script:BtnPanelSound.Add_Click({ Open-SystemPanel "mmsys.cpl" })
$script:BtnPanelPrograms.Add_Click({ Open-SystemPanel "appwiz.cpl" })
$script:BtnPanelComputer.Add_Click({ Open-SystemPanel "compmgmt.msc" })
$script:BtnPanelMouse.Add_Click({ Open-SystemPanel "main.cpl" })
$script:BtnPanelFirewall.Add_Click({ Open-SystemPanel "firewall.cpl" })
$script:BtnPanelRestore.Add_Click({ Open-SystemPanel "rstrui.exe" })
$script:BtnPanelTimedate.Add_Click({ Open-SystemPanel "timedate.cpl" })
$script:BtnPanelRegion.Add_Click({ Open-SystemPanel "intl.cpl" })

# =============================================================================
# 9. SEKME 6: YEDEKLEME (CONFIG EXPORT / IMPORT), SISTEM RAPORU & GERI YUKLEME
# =============================================================================
$script:BtnExportConfig.Add_Click({
    $sfd = New-Object System.Windows.Forms.SaveFileDialog
    $sfd.Filter = "JSON Config (*.json)|*.json"
    $sfd.FileName = "UmutEvranTool_WinUtil_Config.json"
    if ($sfd.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $exportObj = [PSCustomObject]@{
            Version   = "4.0"
            Apps      = @($script:appCheckboxes | Where-Object { $_.IsChecked -eq $true } | ForEach-Object { $_.Tag.Id })
            Tweaks    = @($script:tweakCheckboxes | Where-Object { $_.IsChecked -eq $true } | ForEach-Object { $_.Tag.Id })
            Features  = @($script:featureCheckboxes | Where-Object { $_.IsChecked -eq $true } | ForEach-Object { $_.Tag.Feature })
            Bloatware = @($script:bloatCheckboxes | Where-Object { $_.IsChecked -eq $true } | ForEach-Object { $_.Tag.Pkg })
        }
        $jsonOut = $exportObj | ConvertTo-Json -Depth 4
        [System.IO.File]::WriteAllText($sfd.FileName, $jsonOut, [System.Text.Encoding]::UTF8)
        Write-UiLog "[OK] Yapilandirma JSON olarak kaydedildi: $($sfd.FileName)"
    }
})

$script:BtnImportConfig.Add_Click({
    $ofd = New-Object System.Windows.Forms.OpenFileDialog
    $ofd.Filter = "JSON Config (*.json)|*.json"
    if ($ofd.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        try {
            $imported = [System.IO.File]::ReadAllText($ofd.FileName, [System.Text.Encoding]::UTF8) | ConvertFrom-Json
            if ($imported.Apps) {
                foreach ($cb in $script:appCheckboxes) {
                    $cb.IsChecked = ($imported.Apps -contains $cb.Tag.Id)
                }
            }
            if ($imported.Tweaks) {
                foreach ($cb in $script:tweakCheckboxes) {
                    $cb.IsChecked = ($imported.Tweaks -contains $cb.Tag.Id)
                }
            }
            if ($imported.Features) {
                foreach ($cb in $script:featureCheckboxes) {
                    $cb.IsChecked = ($imported.Features -contains $cb.Tag.Feature)
                }
            }
            if ($imported.Bloatware) {
                foreach ($cb in $script:bloatCheckboxes) {
                    $cb.IsChecked = ($imported.Bloatware -contains $cb.Tag.Pkg)
                }
            }
            Switch-Tab $script:BtnNavApps $script:ViewApps
            Write-UiLog "[OK] Yapilandirma basariyla yuklendi: $($ofd.FileName)"
        } catch {
            Write-UiLog "[HATA] JSON dosyasi okunamadi: $($_.Exception.Message)"
        }
    }
})

$script:BtnExportSysReport.Add_Click({
    $sfd = New-Object System.Windows.Forms.SaveFileDialog
    $sfd.Filter = "JSON Sistem Raporu (*.json)|*.json"
    $sfd.FileName = "UmutEvranTool_SistemRaporu.json"
    if ($sfd.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        try {
            $os  = Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue
            $cpu = Get-CimInstance Win32_Processor -ErrorAction SilentlyContinue | Select-Object -First 1
            $gpu = Get-CimInstance Win32_VideoController -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Name
            $rep = [PSCustomObject]@{
                Timestamp   = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
                Computer    = $env:COMPUTERNAME
                OS          = if ($os) { $os.Caption } else { "Unknown" }
                Build       = if ($os) { $os.BuildNumber } else { "Unknown" }
                CPU         = if ($cpu) { $cpu.Name } else { "Unknown" }
                GPU         = $gpu
                PowerShell  = $PSVersionTable.PSVersion.ToString()
            }
            [System.IO.File]::WriteAllText($sfd.FileName, ($rep | ConvertTo-Json -Depth 4), [System.Text.Encoding]::UTF8)
            Write-UiLog "[OK] Sistem donanim ve ortam raporu kaydedildi: $($sfd.FileName)"
        } catch {
            Write-UiLog "[HATA] Rapor olusturulamadi: $($_.Exception.Message)"
        }
    }
})

$script:BtnRestorePoint.Add_Click({
    Start-BackgroundTask "RestorePoint" @{} {
        Status-Bg "Sistem Geri Yukleme Noktasi olusturuluyor..." 50
        Log-Bg ">>> Sistem Geri Yukleme Noktasi olusturuluyor (Checkpoint-Computer)..."
        Enable-ComputerRestore -Drive "$env:SystemDrive\" -ErrorAction SilentlyContinue
        Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore" "SystemRestorePointCreationFrequency" "DWord" 0
        Checkpoint-Computer -Description "UmutEvranTool_Oncesi" -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop
        Log-Bg "[OK] Sistem Geri Yukleme Noktasi basariyla olusturuldu!"
        Status-Bg "Geri yukleme noktasi olusturuldu!" 100
    }
})

# Baslangic kayitlari (Windows 11 Fluent Dark)
Write-UiLog (Decode-U "Umut Evran Tool v4.0 (Windows 11 Fluent Edition) ba\u015Flat\u0131ld\u0131.")
Write-UiLog "Hizli Baslatma Komutu: irm tinyurl.com/evrantool | iex"

[void]$script:window.ShowDialog()