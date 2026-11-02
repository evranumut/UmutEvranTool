# =============================================================================
# UMUT EVRAN TOOL v4.0 - CANLI TEMA VE TAM WINUTIL MOTORU (100% PURE ASCII)
# =============================================================================

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

function Decode-U([string]$text) {
    if ([string]::IsNullOrEmpty($text)) { return "" }
    return [regex]::Replace($text, '\\u([0-9a-fA-F]{4})', { param($m) [char][int]("0x" + $m.Groups[1].Value) })
}

# --- YEREL IKON ONBELLEK MOTORU (JPEG 0xFF 0xD9 HATASINI ENGELLEYEN SISTEM) ---
$script:IconCacheDir = Join-Path $env:TEMP "UET_IconCache"
if (!(Test-Path $script:IconCacheDir)) {
    New-Item -Path $script:IconCacheDir -ItemType Directory -Force | Out-Null
}

function Get-CachedImageSource([string]$url) {
    if ([string]::IsNullOrWhiteSpace($url)) { return $null }
    try {
        $hash = [System.BitConverter]::ToString([System.Security.Cryptography.MD5]::Create().ComputeHash([System.Text.Encoding]::UTF8.GetBytes($url))).Replace("-", "")
        $cachedFile = Join-Path $script:IconCacheDir "$hash.png"

        if (!(Test-Path $cachedFile) -or (Get-Item $cachedFile).Length -eq 0) {
            $wc = New-Object System.Net.WebClient
            $wc.Headers.Add("User-Agent", "Mozilla/5.0")
            $bytes = $wc.DownloadData($url)
            if ($bytes -and $bytes.Length -gt 100) {
                [System.IO.File]::WriteAllBytes($cachedFile, $bytes)
            } else {
                return $null
            }
        }

        $bmp = New-Object System.Windows.Media.Imaging.BitmapImage
        $bmp.BeginInit()
        $bmp.CacheOption = [System.Windows.Media.Imaging.BitmapCacheOption]::OnLoad
        $bmp.UriSource = New-Object System.Uri($cachedFile, [System.UriKind]::Absolute)
        $bmp.EndInit()
        $bmp.Freeze()
        return $bmp
    } catch {
        return $null
    }
}

# =============================================================================
# UMUT EVRAN TOOL v4.0 - PREMIUM HEADER (CYBER / FLUENT DARK)
# =============================================================================

function Show-ModernHeader {
    $Esc = [char]27
    $Reset = "$Esc[0m"

    $C_Border  = "$Esc[38;2;63;63;70m"
    $C_Guy     = "$Esc[38;2;226;232;240m"
    $C_DogDark = "$Esc[38;2;71;85;105m"
    $C_DogTan  = "$Esc[38;2;249;115;22m"
    $C_Blue    = "$Esc[38;2;96;205;255m"
    $C_DarkM   = "$Esc[38;2;0;120;212m"
    $C_Muted   = "$Esc[38;2;161;161;170m"
    $C_Green   = "$Esc[38;2;74;222;128m"

    $Top = "\u2554" + ("\u2550" * 83) + "\u2557"
    $Bot = "\u255A" + ("\u2550" * 83) + "\u255D"

    Write-Host ""
    Write-Host (Decode-U "  ${C_Border}${Top}")
    Write-Host (Decode-U "  ${C_Border}\u2551  ${C_Guy} (\u2310\u25A0_\u25A0)   ${C_DogDark}|\\_/|   ${C_DarkM}\u2588\u2591\u2588 \u2588\u2580\u2584\u2580\u2588 \u2588\u2591\u2588 \u2580\u2588\u2580   ${C_Blue}\u2580\u2588\u2580 \u2588\u2580\u2588 \u2588\u2580\u2588 \u2588\u2591\u2591                             ${C_Border}\u2551")
    Write-Host (Decode-U "  ${C_Border}\u2551  ${C_Guy} ~( \u2022 )  ${C_DogDark}(${C_DogTan} \u2022.\u2022 ${C_DogDark})  ${C_DarkM}\u2588\u2591\u2588 \u2588\u2591\u2580\u2591\u2588 \u2588\u2591\u2588 \u2591\u2588\u2591   ${C_Blue}\u2591\u2588\u2591 \u2588\u2591\u2588 \u2588\u2591\u2588 \u2588\u2591\u2591    ${C_Muted}v4.0 | Fluent Dark       ${C_Border}\u2551")
    Write-Host (Decode-U "  ${C_Border}\u2551  ${C_Guy}  / \u25B2 \\   ${C_DogDark}\\${C_Border}\u25B2${C_DogTan}\u25BC${C_Border}\u25B2${C_DogDark}/   ${C_DarkM}\u2580\u2584\u2580 \u2580\u2591\u2591\u2591\u2580 \u2580\u2584\u2580 \u2591\u2580\u2591   ${C_Blue}\u2591\u2580\u2591 \u2580\u2580\u2580 \u2580\u2580\u2580 \u2580\u2580\u2580    ${C_Blue}Edition                  ${C_Border}\u2551")
    Write-Host (Decode-U "  ${C_Border}\u2551  ${C_Guy} [PILOT]  ${C_DogDark}[DOBER]  ${C_Muted}Windows Sistem & Performans Optimizasyon Motoru                ${C_Border}\u2551")
    Write-Host (Decode-U "  ${C_Border}${Bot}")
    Write-Host (Decode-U "  ${C_Green}  \u26A1 Hazir ${C_Muted}| 100% Pure ASCII UI | Runspace Threading Aktif${Reset}")
    Write-Host ""
}

Show-ModernHeader

# --- WINGET ID DOGRULAMA VE OTOMATIK DUZELTME HARITASI ---
$script:WingetIdFixMap = @{
    "RubyInstallerTeam.Ruby.4.0"             = "RubyInstallerTeam.RubyWithDevKit.3.3"
    "Microsoft.VisualStudio.Community"       = "Microsoft.VisualStudio.2022.Community"
    "Python.Python.3.14"                     = "Python.Python.3.13"
    "TeamSpeakSystems.TeamSpeakClient.Beta.6"= "TeamSpeakSystems.TeamSpeakClient.Beta"
    "rjpcomputing.luaforwindows"             = "DEVCOM.Lua"
}

function Resolve-WingetId([string]$pkgId) {
    if ([string]::IsNullOrWhiteSpace($pkgId)) { return $pkgId }
    $clean = $pkgId.Trim()
    if ($script:WingetIdFixMap.ContainsKey($clean)) {
        return $script:WingetIdFixMap[$clean]
    }
    return $clean
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
            "Guru3D.Afterburner", "Guru3D.RTSS", "Playnite.Playnite", "PrismLauncher.PrismLauncher",
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
        foreach ($rawId in $cliIds) {
            $id = Resolve-WingetId $rawId
            Write-Host " -> Kuruluyor: $id" -ForegroundColor Yellow
            if ($id -match "^[0-9A-Z]{12}$") {
                winget install --id $id --source msstore --silent --accept-package-agreements --accept-source-agreements
            } else {
                winget install --id $id -e --silent --accept-package-agreements --accept-source-agreements
            }
            if ($LASTEXITCODE -ne 0) {
                Write-Warning "Kurulum uyarisi ($id) - Cikis Kodu: $LASTEXITCODE"
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

# AppsConfig icindeki Winget ID, Icon URL ve aciklama duzeltmelerini otomatik uygula
foreach ($cat in $script:AppCategories) {
    $cat.Category = Decode-U $cat.Category
    foreach ($app in $cat.Apps) {
        $app.Name = Decode-U $app.Name
        $app.Id   = Resolve-WingetId $app.Id
        if ($app.PSObject.Properties["Icon"] -and $app.Icon) {
            $app.Icon = Decode-U ([string]$app.Icon)
        }
        $desc     = Decode-U $app.Description
        $desc     = $desc.Replace([string]([char]0x0448 + [char]0x0435 + [char]0x0439 + "der"), "shader")
        $app.Description = $desc
        if ($app.Name -eq "Visual Studio 2026" -and $app.Id -eq "Microsoft.VisualStudio.2022.Enterprise") {
            $app.Name = "Visual Studio 2022 Enterprise"
        }
        if ($app.Name -eq "Python3" -and $app.Id -eq "Python.Python.3.13") {
            $app.Name = "Python 3.13"
        }
    }
}

# --- XAML Penceresini Yukle ---
$cleanXaml = $sync.Xaml.TrimStart([char]0xFEFF).Trim()
$script:window = [System.Windows.Markup.XamlReader]::Parse($cleanXaml)
$sync.Window = $script:window

# --- Pencere ve Sol Ust Marka Kartina Ozel Logo Entegrasyonu ---
function Initialize-CustomBrandingLogo {
    $basePaths = @()
    if ($PSScriptRoot) {
        $basePaths += $PSScriptRoot
        $basePaths += (Split-Path $PSScriptRoot -Parent)
    }
    $basePaths += (Get-Location).Path

    $logoFile = $null
    foreach ($bp in $basePaths) {
        foreach ($rel in @("logo.png", "logo.ico", "xaml\logo.png", "xaml\logo.ico", "config\logo.png")) {
            $candidate = Join-Path $bp $rel
            if (Test-Path $candidate) {
                $logoFile = (Resolve-Path $candidate).Path
                break
            }
        }
        if ($logoFile) { break }
    }

    if ($logoFile) {
        try {
            $winBmp = New-Object System.Windows.Media.Imaging.BitmapImage
            $winBmp.BeginInit()
            $winBmp.UriSource = New-Object System.Uri($logoFile, [System.UriKind]::Absolute)
            $winBmp.CacheOption = [System.Windows.Media.Imaging.BitmapCacheOption]::OnLoad
            $winBmp.EndInit()
            $script:window.Icon = $winBmp
        } catch {}
    }
}
Initialize-CustomBrandingLogo

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

# Sekme 1: Uygulama Kurulumu Kontrolleri ve Yuklu Vitrin Bari
$script:TxtSearch           = $script:window.FindName("TxtSearch")
$script:BtnClearSearch      = $script:window.FindName("BtnClearSearch")
$script:BtnCheckInstalled   = $script:window.FindName("BtnCheckInstalled")
$script:CategoryButtonPanel = $script:window.FindName("CategoryButtonPanel")
$script:InstalledAppsBar    = $script:window.FindName("InstalledAppsBar")
$script:TxtInstalledBarTitle= $script:window.FindName("TxtInstalledBarTitle")
$script:InstalledAppsStrip  = $script:window.FindName("InstalledAppsStrip")
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
$script:TxtDnsStatus           = $script:window.FindName("TxtDnsStatus")
$script:BtnDnsCloudflare       = $script:window.FindName("BtnDnsCloudflare")
$script:BtnDnsGoogle           = $script:window.FindName("BtnDnsGoogle")
$script:BtnDnsAdguard          = $script:window.FindName("BtnDnsAdguard")
$script:BtnDnsQuad9            = $script:window.FindName("BtnDnsQuad9")
$script:BtnDnsCloudflareMalware= $script:window.FindName("BtnDnsCloudflareMalware")
$script:BtnDnsOpenDns          = $script:window.FindName("BtnDnsOpenDns")
$script:BtnDnsDhcp             = $script:window.FindName("BtnDnsDhcp")

$script:BtnDeepOneDrive    = $script:window.FindName("BtnDeepOneDrive")
$script:BtnDisableCopilot  = $script:window.FindName("BtnDisableCopilot")
$script:BtnDisableEdgeBg   = $script:window.FindName("BtnDisableEdgeBg")
$script:BtnRestoreOneDrive = $script:window.FindName("BtnRestoreOneDrive")
$script:BtnEnableCopilot   = $script:window.FindName("BtnEnableCopilot")
$script:BtnEnableEdgeBg    = $script:window.FindName("BtnEnableEdgeBg")

$script:BtnWinUpdateSecurity = $script:window.FindName("BtnWinUpdateSecurity")
$script:BtnWinUpdateDisable  = $script:window.FindName("BtnWinUpdateDisable")
$script:BtnWinUpdateDefault  = $script:window.FindName("BtnWinUpdateDefault")

$script:FeaturesGrid           = $script:window.FindName("FeaturesGrid")
$script:BtnCheckFeaturesStatus = $script:window.FindName("BtnCheckFeaturesStatus")
$script:BtnApplyFeatures       = $script:window.FindName("BtnApplyFeatures")
$script:BtnDisableFeatures     = $script:window.FindName("BtnDisableFeatures")

# Sekme 4: Bloatware Kontrolleri
$script:BloatwareGrid         = $script:window.FindName("BloatwareGrid")
$script:BtnSelectDefaultBloat = $script:window.FindName("BtnSelectDefaultBloat")
$script:BtnSelectAllBloat     = $script:window.FindName("BtnSelectAllBloat")
$script:BtnClearBloat         = $script:window.FindName("BtnClearBloat")
$script:BtnReinstallBloatware = $script:window.FindName("BtnReinstallBloatware")
$script:BtnRemoveBloatware    = $script:window.FindName("BtnRemoveBloatware")

# Sekme 5: Sistem Araclari & UET Kontrolleri
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

$script:BtnPanelControl  = $script:window.FindName("BtnPanelControl")
$script:BtnPanelNetwork  = $script:window.FindName("BtnPanelNetwork")
$script:BtnPanelSystem   = $script:window.FindName("BtnPanelSystem")
$script:BtnPanelPower    = $script:window.FindName("BtnPanelPower")
$script:BtnPanelSound    = $script:window.FindName("BtnPanelSound")
$script:BtnPanelPrograms = $script:window.FindName("BtnPanelPrograms")
$script:BtnPanelComputer = $script:window.FindName("BtnPanelComputer")
$script:BtnPanelMouse    = $script:window.FindName("BtnPanelMouse")
$script:BtnPanelFirewall = $script:window.FindName("BtnPanelFirewall")
$script:BtnPanelRestore  = $script:window.FindName("BtnPanelRestore")
$script:BtnPanelTimedate = $script:window.FindName("BtnPanelTimedate")
$script:BtnPanelRegion   = $script:window.FindName("BtnPanelRegion")

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

if ($script:BtnRunMAS) {
    $script:BtnRunMAS.Content = Decode-U "\uD83D\uDD11 UET Lisans ve Sistem Yonetim Araci (HWID / Ohook / KMS)"
}

$sync.TxtLog                = $script:TxtLog
$sync.TxtStatus             = $script:TxtStatus
$sync.ProgressBarMain       = $script:ProgressBarMain
$sync.BtnInstall            = $script:BtnInstall
$sync.BtnUninstall          = $script:BtnUninstall
$sync.BtnUpgradeSelected   = $script:BtnUpgradeSelected
$sync.BtnUpgradeAll         = $script:BtnUpgradeAll
$sync.BtnApplyTweaks        = $script:BtnApplyTweaks
$sync.BtnUndoTweaks         = $script:BtnUndoTweaks
$sync.BtnApplyFeatures      = $script:BtnApplyFeatures
$sync.BtnDisableFeatures    = $script:BtnDisableFeatures
$sync.BtnRemoveBloatware    = $script:BtnRemoveBloatware
$sync.BtnReinstallBloatware = $script:BtnReinstallBloatware
$sync.InstalledApps         = @{}
$sync.AllAppIds             = @()
foreach ($c in $script:AppCategories) {
    foreach ($a in $c.Apps) { $sync.AllAppIds += $a.Id }
}
$sync.IsBusy                = $false

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
        Write-UiLog (Decode-U "[!] Su anda devam eden bir arka plan islemi var, lutfen bitmesini bekleyin.")
        return
    }
    $sync.IsBusy = $true
    $rs = [runspacefactory]::CreateRunspace()
    $rs.ApartmentState = "STA"
    $rs.ThreadOptions = "ReuseThread"
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
        function Refresh-InstalledAppsBg {
            Status-Bg "Kurulu uygulama listesi guncelleniyor..." 95
            Log-Bg "[*] Winget uzerinden sistemde kurulu uygulamalar yenileniyor..."
            $rawList = (winget list --accept-source-agreements 2>$null) -join "`n"
            $found = @{}
            foreach ($id in $sync.AllAppIds) {
                if ($rawList.IndexOf($id, [System.StringComparison]::OrdinalIgnoreCase) -ge 0) {
                    $found[$id] = $true
                }
            }
            $sync.InstalledApps = $found
            $sync.Window.Dispatcher.Invoke([action]{
                & $sync.RenderApps
            })
            Log-Bg ("[OK] Kurulu uygulama listesi yenilendi (" + $found.Count + " kurulu paket).")
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
                $propType = switch ($Type) {
                    "DWord"        { "DWord" }
                    "QWord"        { "QWord" }
                    "Binary"       { "Binary" }
                    "ExpandString" { "ExpandString" }
                    "MultiString"  { "MultiString" }
                    default        { "String" }
                }
                New-ItemProperty -Path $Path -Name $Name -PropertyType $propType -Value $Value -Force -ErrorAction SilentlyContinue | Out-Null
            } catch {
                Log-Bg ("[!] Reg Hatasi ($Path -> $Name): " + $_.Exception.Message)
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
            Status-Bg (Decode-U "Hazir") 100
        }
    })
    $null = $ps.BeginInvoke()
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

# --- SECIM VE DURUM YONETIMI (HER MENUDE SECILEN SAYISI TAKIBI) ---
$script:SelectedApps      = @{}
$script:AppCheckboxes     = @{}
$script:StripBadges       = @{}
$script:TweakCheckboxes   = @{}
$script:FeatureCheckboxes = @{}
$script:BloatCheckboxes   = @{}
$script:CategoryButtons   = @{}
$script:ActiveCategory    = "ALL"
$script:ActiveTab         = "Apps"

$script:TotalAppCount = 0
foreach ($c in $script:AppCategories) {
    $script:TotalAppCount += $c.Apps.Count
}

function Update-InstalledStripSelectionVisuals {
    foreach ($id in $script:StripBadges.Keys) {
        $badge = $script:StripBadges[$id]
        if ($script:SelectedApps[$id] -eq $true) {
            $badge.Background  = Get-Brush "#1E293B"
            $badge.BorderBrush = Get-Brush $script:Theme.AccentColor
        } else {
            $badge.Background  = Get-Brush $script:Theme.CardBg
            $badge.BorderBrush = Get-Brush "#22543D"
        }
    }
}

function Update-AllSelectionCounts {
    $appCount = ($script:SelectedApps.Values | Where-Object { $_ -eq $true }).Count
    $script:TxtSelectedCount.Text = Decode-U "$appCount uygulama secildi"

    if ($script:CategoryButtons.ContainsKey("ALL")) {
        $allLabel = if ($appCount -gt 0) {
            Decode-U "Tumu ($appCount/$($script:TotalAppCount))"
        } else {
            Decode-U "Tumu ($($script:TotalAppCount))"
        }
        $script:CategoryButtons["ALL"].Content = $allLabel
    }

    if ($script:CategoryButtons.ContainsKey("INSTALLED")) {
        $instTotal = if ($sync.InstalledApps) { $sync.InstalledApps.Count } else { 0 }
        $btnInst = $script:CategoryButtons["INSTALLED"]
        if ($instTotal -gt 0) {
            $btnInst.Visibility = "Visible"
            $instSel = 0
            foreach ($k in $sync.InstalledApps.Keys) {
                if ($script:SelectedApps[$k] -eq $true) { $instSel++ }
            }
            $btnInst.Content = if ($instSel -gt 0) {
                Decode-U "\u2705 Yuklu ($instSel/$instTotal)"
            } else {
                Decode-U "\u2705 Yuklu ($instTotal)"
            }
        } else {
            $btnInst.Visibility = "Collapsed"
        }
    }

    foreach ($cat in $script:AppCategories) {
        $catName = $cat.Category
        if ($script:CategoryButtons.ContainsKey($catName)) {
            $catTotal = $cat.Apps.Count
            $catSel = 0
            foreach ($a in $cat.Apps) {
                if ($script:SelectedApps[$a.Id] -eq $true) { $catSel++ }
            }
            $script:CategoryButtons[$catName].Content = if ($catSel -gt 0) {
                "$catName ($catSel/$catTotal)"
            } else {
                "$catName ($catTotal)"
            }
        }
    }

    Update-InstalledStripSelectionVisuals

    $tweakCount = ($script:TweakCheckboxes.Values | Where-Object { $_.IsChecked -eq $true }).Count
    $featCount  = ($script:FeatureCheckboxes.Values | Where-Object { $_.IsChecked -eq $true }).Count
    $bloatCount = ($script:BloatCheckboxes.Values | Where-Object { $_.IsChecked -eq $true }).Count

    $script:BtnNavApps.Content = if ($appCount -gt 0) {
        Decode-U "\uD83D\uDCE6 Uygulama Kurulumu ($appCount/$($script:TotalAppCount))"
    } else {
        Decode-U "\uD83D\uDCE6 Uygulama Kurulumu ($($script:TotalAppCount))"
    }

    $script:BtnNavTweaks.Content = if ($tweakCount -gt 0) {
        Decode-U "\u26A1 Sistem & Gelismis Tweaks ($tweakCount secili)"
    } else {
        Decode-U "\u26A1 Sistem & Gelismis Tweaks"
    }

    $script:BtnNavFeatures.Content = if ($featCount -gt 0) {
        Decode-U "\uD83D\uDEE0\uFE0F Windows Ozellikleri & DNS ($featCount secili)"
    } else {
        Decode-U "\uD83D\uDEE0\uFE0F Windows Ozellikleri & DNS"
    }

    $script:BtnNavBloatware.Content = if ($bloatCount -gt 0) {
        Decode-U "\uD83D\uDDD1\uFE0F Bloatware & UWP Tasfiyesi ($bloatCount secili)"
    } else {
        Decode-U "\uD83D\uDDD1\uFE0F Bloatware & UWP Tasfiyesi"
    }
}

# --- SEKME GECIS MOTORU ---
function Switch-Tab([string]$tabName) {
    $script:ActiveTab = $tabName
    $script:ViewApps.Visibility      = if ($tabName -eq "Apps")      { "Visible" } else { "Collapsed" }
    $script:ViewTweaks.Visibility    = if ($tabName -eq "Tweaks")    { "Visible" } else { "Collapsed" }
    $script:ViewFeatures.Visibility  = if ($tabName -eq "Features")  { "Visible" } else { "Collapsed" }
    $script:ViewBloatware.Visibility = if ($tabName -eq "Bloatware") { "Visible" } else { "Collapsed" }
    $script:ViewTools.Visibility     = if ($tabName -eq "Tools")     { "Visible" } else { "Collapsed" }
    $script:ViewConfig.Visibility    = if ($tabName -eq "Config")    { "Visible" } else { "Collapsed" }

    $navMap = @{
        "Apps"      = $script:BtnNavApps
        "Tweaks"    = $script:BtnNavTweaks
        "Features"  = $script:BtnNavFeatures
        "Bloatware" = $script:BtnNavBloatware
        "Tools"     = $script:BtnNavTools
        "Config"    = $script:BtnNavConfig
    }
    foreach ($k in $navMap.Keys) {
        $btn = $navMap[$k]
        if ($k -eq $tabName) {
            $btn.Background  = Get-Brush $script:Theme.ActiveBtnColor
            $btn.BorderBrush = Get-Brush $script:Theme.AccentColor
        } else {
            $btn.Background  = Get-Brush $script:Theme.CardBg
            $btn.BorderBrush = Get-Brush $script:Theme.BorderBrushColor
        }
    }
}

$script:BtnNavApps.Add_Click({ Switch-Tab "Apps" })
$script:BtnNavTweaks.Add_Click({ Switch-Tab "Tweaks" })
$script:BtnNavFeatures.Add_Click({ Switch-Tab "Features" })
$script:BtnNavBloatware.Add_Click({ Switch-Tab "Bloatware" })
$script:BtnNavTools.Add_Click({ Switch-Tab "Tools" })
$script:BtnNavConfig.Add_Click({ Switch-Tab "Config" })

# --- SEKME 1: UYGULAMA KATEGORILERI, UST VITRIN VE LOGOLU LISTE RENDER ---
function Update-CategoryPillStyles {
    foreach ($key in $script:CategoryButtons.Keys) {
        $b = $script:CategoryButtons[$key]
        if ($key -eq $script:ActiveCategory) {
            $b.Background  = Get-Brush $script:Theme.ActiveBtnColor
            $b.Foreground  = Get-Brush "#FFFFFF"
            $b.BorderBrush = Get-Brush $script:Theme.AccentColor
        } elseif ($key -eq "INSTALLED") {
            $b.Background  = Get-Brush "#143326"
            $b.Foreground  = Get-Brush "#4ADE80"
            $b.BorderBrush = Get-Brush "#22543D"
        } else {
            $b.Background  = Get-Brush $script:Theme.CardBg
            $b.Foreground  = Get-Brush $script:Theme.TextMuted
            $b.BorderBrush = Get-Brush $script:Theme.BorderBrushColor
        }
    }
}

function Initialize-CategoryPills {
    $script:CategoryButtonPanel.Children.Clear()
    $script:CategoryButtons.Clear()

    $btnAll = New-Object System.Windows.Controls.Button
    $btnAll.Style = $script:window.FindResource("CatPillStyle")
    $btnAll.Content = Decode-U "Tumu ($($script:TotalAppCount))"
    $btnAll.Tag = "ALL"
    $btnAll.Add_Click({
        $script:ActiveCategory = "ALL"
        Update-CategoryPillStyles
        Render-Apps
    })
    [void]$script:CategoryButtonPanel.Children.Add($btnAll)
    $script:CategoryButtons["ALL"] = $btnAll

    $btnInst = New-Object System.Windows.Controls.Button
    $btnInst.Style = $script:window.FindResource("CatPillStyle")
    $btnInst.Content = Decode-U "\u2705 Yuklu (0)"
    $btnInst.Tag = "INSTALLED"
    $btnInst.Visibility = "Collapsed"
    $btnInst.Add_Click({
        $script:ActiveCategory = "INSTALLED"
        Update-CategoryPillStyles
        Render-Apps
    })
    [void]$script:CategoryButtonPanel.Children.Add($btnInst)
    $script:CategoryButtons["INSTALLED"] = $btnInst

    foreach ($cat in $script:AppCategories) {
        $cName = $cat.Category
        $btn = New-Object System.Windows.Controls.Button
        $btn.Style = $script:window.FindResource("CatPillStyle")
        $btn.Content = "$cName ($($cat.Apps.Count))"
        $btn.Tag = $cName
        $btn.Add_Click({
            param($sender, $e)
            $script:ActiveCategory = [string]$sender.Tag
            Update-CategoryPillStyles
            Render-Apps
        })
        [void]$script:CategoryButtonPanel.Children.Add($btn)
        $script:CategoryButtons[$cName] = $btn
    }
    Update-CategoryPillStyles
}

function Render-InstalledStrip {
    if (-not $script:InstalledAppsBar -or -not $script:InstalledAppsStrip) { return }
    $script:InstalledAppsStrip.Children.Clear()
    $script:StripBadges.Clear()

    if (-not $sync.InstalledApps -or $sync.InstalledApps.Count -eq 0) {
        $script:InstalledAppsBar.Visibility = "Collapsed"
        return
    }

    $installedItems = @()
    $seenIds = @{}
    foreach ($cat in $script:AppCategories) {
        foreach ($app in $cat.Apps) {
            if ($sync.InstalledApps[$app.Id] -eq $true -and -not $seenIds.ContainsKey($app.Id)) {
                $seenIds[$app.Id] = $true
                $installedItems += $app
            }
        }
    }

    if ($installedItems.Count -eq 0) {
        $script:InstalledAppsBar.Visibility = "Collapsed"
        return
    }

    $script:InstalledAppsBar.Visibility = "Visible"
    if ($script:TxtInstalledBarTitle) {
        $script:TxtInstalledBarTitle.Text = Decode-U "\u2705 Sistemde Kurulu Uygulamalar ($($installedItems.Count))"
    }

    foreach ($app in $installedItems) {
        $tile = New-Object System.Windows.Controls.Border
        $tile.Width = 84
        $tile.CornerRadius = New-Object System.Windows.CornerRadius(6)
        $tile.BorderThickness = New-Object System.Windows.Thickness(1)
        $tile.Padding = New-Object System.Windows.Thickness(6, 6, 6, 5)
        $tile.Margin = New-Object System.Windows.Thickness(0, 0, 6, 0)
        $tile.Cursor = [System.Windows.Input.Cursors]::Hand
        $tile.ToolTip = "$($app.Name)`n$($app.Id)`n" + (Decode-U "(Secime eklemek/cikarmak icin tiklayin)")

        if ($script:SelectedApps[$app.Id] -eq $true) {
            $tile.Background  = Get-Brush "#1E293B"
            $tile.BorderBrush = Get-Brush $script:Theme.AccentColor
        } else {
            $tile.Background  = Get-Brush $script:Theme.CardBg
            $tile.BorderBrush = Get-Brush "#22543D"
        }

        $sp = New-Object System.Windows.Controls.StackPanel
        $sp.HorizontalAlignment = "Center"

        $iconHost = New-Object System.Windows.Controls.Grid
        $iconHost.Width = 28
        $iconHost.Height = 28
        $iconHost.HorizontalAlignment = "Center"
        $iconHost.Margin = New-Object System.Windows.Thickness(0, 0, 0, 4)

        $fbBorder = New-Object System.Windows.Controls.Border
        $fbBorder.Background = Get-Brush $script:Theme.HoverBg
        $fbBorder.BorderBrush = Get-Brush "#22543D"
        $fbBorder.BorderThickness = New-Object System.Windows.Thickness(1)
        $fbBorder.CornerRadius = New-Object System.Windows.CornerRadius(6)

        $cleanName = $app.Name.TrimStart('.')
        $initChar = if ($cleanName.Length -gt 0) { $cleanName.Substring(0, 1).ToUpper() } else { "A" }
        $fbTxt = New-Object System.Windows.Controls.TextBlock
        $fbTxt.Text = $initChar
        $fbTxt.FontSize = 12
        $fbTxt.FontWeight = "Bold"
        $fbTxt.Foreground = Get-Brush "#4ADE80"
        $fbTxt.HorizontalAlignment = "Center"
        $fbTxt.VerticalAlignment = "Center"
        $fbBorder.Child = $fbTxt
        [void]$iconHost.Children.Add($fbBorder)

        if ($app.PSObject.Properties["Icon"] -and -not [string]::IsNullOrWhiteSpace($app.Icon)) {
            $cachedSource = Get-CachedImageSource $app.Icon
            if ($cachedSource) {
                $img = New-Object System.Windows.Controls.Image
                $img.Width = 24
                $img.Height = 24
                $img.Stretch = [System.Windows.Media.Stretch]::Uniform
                $img.HorizontalAlignment = "Center"
                $img.VerticalAlignment = "Center"
                [System.Windows.Media.RenderOptions]::SetBitmapScalingMode($img, [System.Windows.Media.BitmapScalingMode]::HighQuality)
                $img.Source = $cachedSource
                $fbBorder.Visibility = "Collapsed"
                [void]$iconHost.Children.Add($img)
            } else {
                $fbBorder.Visibility = "Visible"
            }
        }
        [void]$sp.Children.Add($iconHost)

        $nameTxt = New-Object System.Windows.Controls.TextBlock
        $nameTxt.Text = $app.Name
        $nameTxt.FontSize = 10
        $nameTxt.FontWeight = "SemiBold"
        $nameTxt.Foreground = Get-Brush "#F8FAFC"
        $nameTxt.HorizontalAlignment = "Center"
        $nameTxt.TextAlignment = "Center"
        $nameTxt.TextTrimming = "CharacterEllipsis"
        $nameTxt.MaxWidth = 74
        [void]$sp.Children.Add($nameTxt)

        $statusTxt = New-Object System.Windows.Controls.TextBlock
        $statusTxt.Text = Decode-U "\u25CF Yuklu"
        $statusTxt.FontSize = 9.5
        $statusTxt.FontWeight = "Bold"
        $statusTxt.Foreground = Get-Brush "#4ADE80"
        $statusTxt.HorizontalAlignment = "Center"
        $statusTxt.Margin = New-Object System.Windows.Thickness(0, 1, 0, 0)
        [void]$sp.Children.Add($statusTxt)

        $tile.Child = $sp
        $tile.Tag = $app.Id
        $tile.Add_MouseLeftButtonUp({
            param($sender, $e)
            $pkgId = [string]$sender.Tag
            $newState = -not ($script:SelectedApps[$pkgId] -eq $true)
            $script:SelectedApps[$pkgId] = $newState
            if ($script:AppCheckboxes.ContainsKey($pkgId)) {
                $script:AppCheckboxes[$pkgId].IsChecked = $newState
            }
            Update-AllSelectionCounts
        })

        [void]$script:InstalledAppsStrip.Children.Add($tile)
        $script:StripBadges[$app.Id] = $tile
    }
}

function Render-Apps {
    Render-InstalledStrip
    $script:MainStackPanel.Children.Clear()
    $script:AppCheckboxes.Clear()
    $query = $script:TxtSearch.Text.Trim().ToLower()

    foreach ($cat in $script:AppCategories) {
        $catName = $cat.Category
        if ($script:ActiveCategory -ne "ALL" -and $script:ActiveCategory -ne "INSTALLED" -and $script:ActiveCategory -ne $catName) {
            continue
        }

        $filteredApps = @()
        foreach ($app in $cat.Apps) {
            if ($script:ActiveCategory -eq "INSTALLED" -and (-not $sync.InstalledApps -or $sync.InstalledApps[$app.Id] -ne $true)) {
                continue
            }
            if ([string]::IsNullOrEmpty($query) -or
                $app.Name.ToLower().Contains($query) -or
                $app.Id.ToLower().Contains($query) -or
                $app.Description.ToLower().Contains($query)) {
                $filteredApps += $app
            }
        }
        if ($filteredApps.Count -eq 0) { continue }

        $catHeader = New-Object System.Windows.Controls.TextBlock
        $catHeader.Text = "$catName ($($filteredApps.Count))"
        $catHeader.FontSize = 14
        $catHeader.FontWeight = "Bold"
        $catHeader.Foreground = Get-Brush $script:Theme.AccentColor
        $catHeader.Margin = New-Object System.Windows.Thickness(4, 10, 4, 6)
        [void]$script:MainStackPanel.Children.Add($catHeader)

        $wrap = New-Object System.Windows.Controls.Primitives.UniformGrid
        $wrap.Columns = 2

        foreach ($app in $filteredApps) {
            $isInstalled = ($sync.InstalledApps -and $sync.InstalledApps[$app.Id] -eq $true)

            $card = New-Object System.Windows.Controls.Border
            $card.Background = Get-Brush $script:Theme.CardBg
            $card.BorderBrush = if ($isInstalled) { Get-Brush "#22543D" } else { Get-Brush $script:Theme.BorderBrushColor }
            $card.BorderThickness = New-Object System.Windows.Thickness(1)
            $card.CornerRadius = New-Object System.Windows.CornerRadius(6)
            $card.Padding = New-Object System.Windows.Thickness(10, 8, 10, 8)
            $card.Margin = New-Object System.Windows.Thickness(4)
            $card.Cursor = [System.Windows.Input.Cursors]::Hand

            $rowGrid = New-Object System.Windows.Controls.Grid
            $colIcon = New-Object System.Windows.Controls.ColumnDefinition
            $colIcon.Width = New-Object System.Windows.GridLength(48)
            $colText = New-Object System.Windows.Controls.ColumnDefinition
            $colText.Width = New-Object System.Windows.GridLength(1, [System.Windows.GridUnitType]::Star)
            [void]$rowGrid.ColumnDefinitions.Add($colIcon)
            [void]$rowGrid.ColumnDefinitions.Add($colText)

            $leftStack = New-Object System.Windows.Controls.StackPanel
            $leftStack.HorizontalAlignment = "Center"
            $leftStack.VerticalAlignment = "Top"
            $leftStack.Margin = New-Object System.Windows.Thickness(0, 1, 8, 0)

            $iconHost = New-Object System.Windows.Controls.Grid
            $iconHost.Width = 36
            $iconHost.Height = 36
            $iconHost.HorizontalAlignment = "Center"

            $fallbackBorder = New-Object System.Windows.Controls.Border
            $fallbackBorder.Background = Get-Brush $script:Theme.HoverBg
            $fallbackBorder.BorderBrush = if ($isInstalled) { Get-Brush "#22543D" } else { Get-Brush $script:Theme.BorderBrushColor }
            $fallbackBorder.BorderThickness = New-Object System.Windows.Thickness(1)
            $fallbackBorder.CornerRadius = New-Object System.Windows.CornerRadius(6)

            $cleanName = $app.Name.TrimStart('.')
            $initialChar = if ($cleanName.Length -gt 0) { $cleanName.Substring(0, 1).ToUpper() } else { "A" }
            $fallbackText = New-Object System.Windows.Controls.TextBlock
            $fallbackText.Text = $initialChar
            $fallbackText.FontSize = 14
            $fallbackText.FontWeight = "Bold"
            $fallbackText.Foreground = if ($isInstalled) { Get-Brush "#4ADE80" } else { Get-Brush $script:Theme.AccentColor }
            $fallbackText.HorizontalAlignment = "Center"
            $fallbackText.VerticalAlignment = "Center"
            $fallbackBorder.Child = $fallbackText
            [void]$iconHost.Children.Add($fallbackBorder)

            if ($app.PSObject.Properties["Icon"] -and -not [string]::IsNullOrWhiteSpace($app.Icon)) {
                $cachedSource = Get-CachedImageSource $app.Icon
                if ($cachedSource) {
                    $logoImg = New-Object System.Windows.Controls.Image
                    $logoImg.Width = 28
                    $logoImg.Height = 28
                    $logoImg.Stretch = [System.Windows.Media.Stretch]::Uniform
                    $logoImg.HorizontalAlignment = "Center"
                    $logoImg.VerticalAlignment = "Center"
                    [System.Windows.Media.RenderOptions]::SetBitmapScalingMode($logoImg, [System.Windows.Media.BitmapScalingMode]::HighQuality)
                    $logoImg.Source = $cachedSource
                    $fallbackBorder.Visibility = "Collapsed"
                    [void]$iconHost.Children.Add($logoImg)
                } else {
                    $fallbackBorder.Visibility = "Visible"
                }
            }
            [void]$leftStack.Children.Add($iconHost)

            if ($isInstalled) {
                $instBadge = New-Object System.Windows.Controls.Border
                $instBadge.Background = Get-Brush "#143326"
                $instBadge.BorderBrush = Get-Brush "#22543D"
                $instBadge.BorderThickness = New-Object System.Windows.Thickness(1)
                $instBadge.CornerRadius = New-Object System.Windows.CornerRadius(3)
                $instBadge.Padding = New-Object System.Windows.Thickness(3, 1, 3, 1)
                $instBadge.Margin = New-Object System.Windows.Thickness(0, 4, 0, 0)
                $instBadge.HorizontalAlignment = "Center"

                $instBadgeTxt = New-Object System.Windows.Controls.TextBlock
                $instBadgeTxt.Text = Decode-U "Y\u00FCkl\u00FC"
                $instBadgeTxt.FontSize = 9
                $instBadgeTxt.FontWeight = "Bold"
                $instBadgeTxt.Foreground = Get-Brush "#4ADE80"
                $instBadgeTxt.HorizontalAlignment = "Center"
                $instBadge.Child = $instBadgeTxt
                [void]$leftStack.Children.Add($instBadge)
            }

            [System.Windows.Controls.Grid]::SetColumn($leftStack, 0)
            [void]$rowGrid.Children.Add($leftStack)

            # Sag Metin ve CheckBox Alani
            $sp = New-Object System.Windows.Controls.StackPanel
            [System.Windows.Controls.Grid]::SetColumn($sp, 1)

            $cb = New-Object System.Windows.Controls.CheckBox
            $cb.Tag = $app.Id
            $cb.IsChecked = ($script:SelectedApps[$app.Id] -eq $true)
            $cb.Foreground = if ($isInstalled) { Get-Brush "#4ADE80" } else { Get-Brush "#F8FAFC" }
            $cb.FontWeight = "SemiBold"
            $cb.FontSize = 13
            $cb.Content = $app.Name

            $cb.Add_Checked({
                param($s, $e)
                $script:SelectedApps[[string]$s.Tag] = $true
                Update-AllSelectionCounts
            })
            $cb.Add_Unchecked({
                param($s, $e)
                $script:SelectedApps[[string]$s.Tag] = $false
                Update-AllSelectionCounts
            })

            $descBlock = New-Object System.Windows.Controls.TextBlock
            $descBlock.Text = $app.Description
            $descBlock.FontSize = 11
            $descBlock.Foreground = Get-Brush $script:Theme.TextMuted
            $descBlock.TextWrapping = "Wrap"
            $descBlock.Margin = New-Object System.Windows.Thickness(22, 2, 0, 0)

            $idBlock = New-Object System.Windows.Controls.TextBlock
            $idBlock.Text = $app.Id
            $idBlock.FontSize = 10
            $idBlock.Foreground = Get-Brush $script:Theme.TextDim
            $idBlock.Margin = New-Object System.Windows.Thickness(22, 2, 0, 0)

            [void]$sp.Children.Add($cb)
            [void]$sp.Children.Add($descBlock)
            [void]$sp.Children.Add($idBlock)
            [void]$rowGrid.Children.Add($sp)

            $card.Child = $rowGrid
            $card.Tag = $cb

            $card.Add_MouseLeftButtonUp({
                param($sender, $e)
                if ($e.OriginalSource -isnot [System.Windows.Controls.Primitives.ToggleButton]) {
                    $innerCb = $sender.Tag
                    if ($innerCb) {
                        $innerCb.IsChecked = -not $innerCb.IsChecked
                    }
                }
            })

            [void]$wrap.Children.Add($card)
            $script:AppCheckboxes[$app.Id] = $cb
        }
        [void]$script:MainStackPanel.Children.Add($wrap)
    }
    Update-AllSelectionCounts
}

# Arka plan Runspace icinden Render-Apps cagirabilmek icin senkronize referans
$sync.RenderApps = ${function:Render-Apps}

$script:TxtSearch.Add_TextChanged({ Render-Apps })
$script:BtnClearSearch.Add_Click({
    $script:TxtSearch.Text = ""
    Render-Apps
})

# --- PRESET SECIM FONKSIYONU (ESKI SECIMLERI SILMEDEN EKLER) ---
function Select-AppPreset([string[]]$ids, [string]$presetTitle) {
    $added = 0
    foreach ($rawId in $ids) {
        $id = Resolve-WingetId $rawId
        if ($script:SelectedApps[$id] -ne $true) {
            $script:SelectedApps[$id] = $true
            $added++
        }
        if ($script:AppCheckboxes.ContainsKey($id)) {
            $script:AppCheckboxes[$id].IsChecked = $true
        }
    }
    Update-AllSelectionCounts
    Switch-Tab "Apps"
    Write-UiLog (Decode-U "[+] $presetTitle secime eklendi (+$added yeni paket, mevcut secimler korundu).")
}

$script:BtnPresetUmut.Add_Click({
    Select-AppPreset @(
        "TheBrowserCompany.Arc", "Brave.Brave", "Discord.Discord", "Valve.Steam",
        "EpicGames.EpicGamesLauncher", "ElectronicArts.EADesktop", "SteelSeries.GG",
        "PrismLauncher.PrismLauncher", "VideoLAN.VLC", "OBSProject.OBSStudio",
        "Spotify.Spotify", "Microsoft.VisualStudioCode", "Git.Git", "7zip.7zip",
        "RARLab.WinRAR", "voidtools.Everything", "Microsoft.PowerToys",
        "Google.Drive", "AnyDeskSoftwareGmbH.AnyDesk", "TechPowerUp.NVCleanstall",
        "WinsiderSS.SystemInformer", "AntibodySoftware.WizTree"
    ) (Decode-U "Umut Ozel Paketi")
})

$script:BtnPresetGamer.Add_Click({
    Select-AppPreset @(
        "TheBrowserCompany.Arc", "Brave.Brave", "Discord.Discord", "Valve.Steam",
        "EpicGames.EpicGamesLauncher", "ElectronicArts.EADesktop", "GOG.Galaxy",
        "Ubisoft.Connect", "Blizzard.BattleNet", "SteelSeries.GG", "Logitech.GHUB",
        "Guru3D.Afterburner", "Guru3D.RTSS", "Playnite.Playnite", "PrismLauncher.PrismLauncher",
        "Modrinth.ModrinthApp", "VideoLAN.VLC", "OBSProject.OBSStudio", "7zip.7zip",
        "Spotify.Spotify", "TechPowerUp.NVCleanstall", "BitSum.ProcessLasso"
    ) "Oyuncu Paketi"
})

$script:BtnPresetDev.Add_Click({
    Select-AppPreset @(
        "TheBrowserCompany.Arc", "Microsoft.VisualStudioCode", "Anysphere.Cursor",
        "Git.Git", "GitHub.GitHubDesktop", "GitHub.cli", "OpenJS.NodeJS.LTS",
        "Python.Python.3.12", "Microsoft.WindowsTerminal", "Microsoft.PowerShell",
        "Docker.DockerDesktop", "Postman.Postman", "Bruno.Bruno", "Notepad++.Notepad++",
        "JetBrains.Toolbox", "7zip.7zip", "Microsoft.PowerToys", "WinSCP.WinSCP", "PuTTY.PuTTY"
    ) (Decode-U "Gelistirici Paketi")
})

$script:BtnPresetStandard.Add_Click({
    Select-AppPreset @(
        "Google.Chrome", "Brave.Brave", "7zip.7zip", "RARLab.WinRAR", "VideoLAN.VLC",
        "Spotify.Spotify", "Discord.Discord", "voidtools.Everything", "Skillbrains.Lightshot",
        "ShareX.ShareX", "Adobe.Acrobat.Reader.64-bit", "SumatraPDF.SumatraPDF",
        "TheDocumentFoundation.LibreOffice", "Microsoft.VCRedist.2015+.x64", "Microsoft.VCRedist.2015+.x86"
    ) "Standart Kurulum Paketi"
})

$script:BtnClearSelection.Add_Click({
    $script:SelectedApps.Clear()
    foreach ($cb in $script:AppCheckboxes.Values) { $cb.IsChecked = $false }
    foreach ($cb in $script:TweakCheckboxes.Values) { $cb.IsChecked = $false }
    foreach ($cb in $script:FeatureCheckboxes.Values) { $cb.IsChecked = $false }
    foreach ($cb in $script:BloatCheckboxes.Values) { $cb.IsChecked = $false }
    Update-AllSelectionCounts
    Write-UiLog (Decode-U "[i] Tum menulerdeki secimler temizlendi.")
})

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
    $targets = Get-SelectedAppList
    if ($targets.Count -eq 0) {
        Write-UiLog (Decode-U "[!] Lutfen kurulacak en az 1 uygulama secin.")
        return
    }
    Start-BackgroundTask (Decode-U "Secilen uygulamalar kuruluyor...") @{ Apps = $targets } {
        param($p)
        $total = $p.Apps.Count
        $idx = 0
        foreach ($item in $p.Apps) {
            $idx++; $pct = [math]::Round(($idx / $total) * 90)
            Status-Bg ("Kuruluyor ($idx/$total): " + $item.Name) $pct
            Log-Bg ("[+] Kuruluyor ($idx/$total): " + $item.Name + " [" + $item.Id + "]")
            if ($item.Id -match "^[0-9A-Z]{12}$") {
                winget install --id $item.Id --source msstore --silent --accept-package-agreements --accept-source-agreements
            } else {
                winget install --id $item.Id -e --silent --accept-package-agreements --accept-source-agreements
            }
            if ($LASTEXITCODE -eq 0) {
                $sync.InstalledApps[$item.Id] = $true
                Log-Bg ("[OK] Kuruldu: " + $item.Name)
            } else {
                Log-Bg ("[!] Uyari/Cikis Kodu ($LASTEXITCODE): " + $item.Name)
            }
        }
        Log-Bg "[OK] Secilen tum uygulamalar icin kurulum islemi tamamlandi."
        Refresh-InstalledAppsBg
    }
})

$script:BtnUninstall.Add_Click({
    $targets = Get-SelectedAppList
    if ($targets.Count -eq 0) {
        Write-UiLog (Decode-U "[!] Lutfen kaldirilacak en az 1 uygulama secin.")
        return
    }
    Start-BackgroundTask (Decode-U "Secilen uygulamalar kaldiriliyor...") @{ Apps = $targets } {
        param($p)
        $total = $p.Apps.Count
        $idx = 0
        foreach ($item in $p.Apps) {
            $idx++; $pct = [math]::Round(($idx / $total) * 90)
            Status-Bg ("Kaldiriliyor ($idx/$total): " + $item.Name) $pct
            Log-Bg ("[-] Kaldiriliyor ($idx/$total): " + $item.Name + " [" + $item.Id + "]")
            if ($item.Id -match "^[0-9A-Z]{12}$") {
                winget uninstall --id $item.Id --silent --accept-source-agreements
            } else {
                winget uninstall --id $item.Id -e --silent --accept-source-agreements
            }
            if ($LASTEXITCODE -eq 0) {
                $sync.InstalledApps.Remove($item.Id)
            }
            Log-Bg ("[OK] Kaldirma tamamlandi: " + $item.Name)
        }
        Refresh-InstalledAppsBg
    }
})

$script:BtnUpgradeSelected.Add_Click({
    $targets = Get-SelectedAppList
    if ($targets.Count -eq 0) {
        Write-UiLog (Decode-U "[!] Lutfen guncellenecek en az 1 uygulama secin.")
        return
    }
    Start-BackgroundTask (Decode-U "Secilen uygulamalar guncelleniyor...") @{ Apps = $targets } {
        param($p)
        $total = $p.Apps.Count
        $idx = 0
        foreach ($item in $p.Apps) {
            $idx++; $pct = [math]::Round(($idx / $total) * 90)
            Status-Bg ("Guncelleniyor ($idx/$total): " + $item.Name) $pct
            Log-Bg ("[^] Guncelleniyor: " + $item.Name)
            if ($item.Id -match "^[0-9A-Z]{12}$") {
                winget upgrade --id $item.Id --source msstore --silent --accept-package-agreements --accept-source-agreements
            } else {
                winget upgrade --id $item.Id -e --silent --accept-package-agreements --accept-source-agreements
            }
        }
        Log-Bg "[OK] Secili uygulamalar guncellendi."
        Refresh-InstalledAppsBg
    }
})

$script:BtnUpgradeAll.Add_Click({
    Start-BackgroundTask (Decode-U "Tum sistem uygulamalari guncelleniyor...") @{} {
        Log-Bg "[*] Winget Upgrade --all baslatildi..."
        winget upgrade --all --include-unknown --silent --accept-package-agreements --accept-source-agreements
        Log-Bg "[OK] Tum guncellemeler tamamlandi."
        Refresh-InstalledAppsBg
    }
})

# --- SEKME 2: TWEAKS RENDER VE UYGULA / GERI AL MOTORU ---
function Render-Tweaks {
    $script:TweaksStackPanel.Children.Clear()
    $script:TweakCheckboxes.Clear()

    foreach ($grp in $script:TweaksData) {
        $grpTitle = New-Object System.Windows.Controls.TextBlock
        $grpTitle.Text = Decode-U $grp.Group
        $grpTitle.FontSize = 14
        $grpTitle.FontWeight = "Bold"
        $grpTitle.Foreground = Get-Brush $script:Theme.AccentColor
        $grpTitle.Margin = New-Object System.Windows.Thickness(4, 10, 4, 6)
        [void]$script:TweaksStackPanel.Children.Add($grpTitle)

        foreach ($item in $grp.Items) {
            $card = New-Object System.Windows.Controls.Border
            $card.Background = Get-Brush $script:Theme.CardBg
            $card.BorderBrush = Get-Brush $script:Theme.BorderBrushColor
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
            $cb.Add_Checked({ Update-AllSelectionCounts })
            $cb.Add_Unchecked({ Update-AllSelectionCounts })

            $desc = New-Object System.Windows.Controls.TextBlock
            $desc.Text = Decode-U $item.Desc
            $desc.FontSize = 11
            $desc.Foreground = Get-Brush $script:Theme.TextMuted
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

            [void]$script:TweaksStackPanel.Children.Add($card)
            $script:TweakCheckboxes[$item.Id] = $cb
        }
    }
}

$script:BtnSelectRecTweaks.Add_Click({
    foreach ($cb in $script:TweakCheckboxes.Values) {
        if ($cb.Tag.Recommended -eq $true) { $cb.IsChecked = $true }
    }
    Update-AllSelectionCounts
    Write-UiLog (Decode-U "[+] Onerilen (Recommended) Tweaks secime eklendi.")
})

function Select-TweakPreset([string]$presetName) {
    foreach ($cb in $script:TweakCheckboxes.Values) {
        if ($cb.Tag.Preset -contains $presetName) { $cb.IsChecked = $true }
    }
    Update-AllSelectionCounts
    Write-UiLog (Decode-U "[+] WinUtil '$presetName' profili secime eklendi (mevcut secimler korundu).")
}

$script:BtnTweakPresetStandard.Add_Click({ Select-TweakPreset "Standard" })
$script:BtnTweakPresetMinimal.Add_Click({ Select-TweakPreset "Minimal" })
$script:BtnTweakPresetAdvanced.Add_Click({ Select-TweakPreset "Advanced" })
$script:BtnClearTweaks.Add_Click({
    foreach ($cb in $script:TweakCheckboxes.Values) { $cb.IsChecked = $false }
    Update-AllSelectionCounts
})

function Invoke-SelectedTweaks([bool]$UndoMode) {
    $selectedIds = @()
    foreach ($id in $script:TweakCheckboxes.Keys) {
        if ($script:TweakCheckboxes[$id].IsChecked -eq $true) {
            $selectedIds += $id
        }
    }
    if ($selectedIds.Count -eq 0) {
        Write-UiLog (Decode-U "[!] Lutfen uygulanacak veya geri alinacak en az 1 ayar secin.")
        return
    }
    $taskTitle = if ($UndoMode) { "Secili Tweaks geri aliniyor..." } else { "Secili Tweaks uygulaniyor..." }
    Start-BackgroundTask $taskTitle @{ Ids = $selectedIds; Undo = $UndoMode } {
        param($p)
        $undo = $p.Undo
        $total = $p.Ids.Count
        $idx = 0
        foreach ($id in $p.Ids) {
            $idx++
            $pct = [math]::Round(($idx / $total) * 100)
            Status-Bg ("Islem ($idx/$total): $id") $pct
            Log-Bg ((if ($undo) { "[UNDO] " } else { "[APPLY] " }) + $id)

            switch ($id) {
                "Tweak_RestorePoint" {
                    if (-not $undo) {
                        Enable-ComputerRestore -Drive "$env:SystemDrive\" -ErrorAction SilentlyContinue
                        Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore" "SystemRestorePointCreationFrequency" "DWord" 0
                        Checkpoint-Computer -Description "UmutEvranTool_RestorePoint" -RestorePointType "MODIFY_SETTINGS" -ErrorAction SilentlyContinue
                    }
                }
                "Tweak_Telemetry" {
                    $val = if ($undo) { 1 } else { 0 }
                    Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" "AllowTelemetry" "DWord" $val
                    Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" "AllowTelemetry" "DWord" $val
                    Set-RegSafe "HKCU:\Software\Microsoft\Siuf\Rules" "NumberOfSIUFInPeriod" "DWord" (if ($undo) { "<RemoveEntry>" } else { 0 })
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
                    Set-Service -Name "lfsvc" -StartupType (if ($undo) { "Manual" } else { "Disabled" }) -ErrorAction SilentlyContinue
                }
                "Tweak_AdvertisingId" {
                    $val = if ($undo) { 1 } else { 0 }
                    Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" "Enabled" "DWord" $val
                    Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy" "TailoredExperiencesWithDiagnosticDataEnabled" "DWord" $val
                }
                "Tweak_BingSearch" {
                    $val = if ($undo) { 0 } else { 1 }
                    Set-RegSafe "HKCU:\Software\Policies\Microsoft\Windows\Explorer" "DisableSearchBoxSuggestions" "DWord" $val
                    Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" "BingSearchEnabled" "DWord" (if ($undo) { 1 } else { 0 })
                }
                "Tweak_ConsumerFeatures" {
                    $val = if ($undo) { 0 } else { 1 }
                    Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" "DisableWindowsConsumerFeatures" "DWord" $val
                    Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "RotatingLockScreenOverlayEnabled" "DWord" (if ($undo) { 1 } else { 0 })
                    Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SubscribedContent-338387Enabled" "DWord" (if ($undo) { 1 } else { 0 })
                }
                "Tweak_ErrorReporting" {
                    $val = if ($undo) { 0 } else { 1 }
                    Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting" "Disabled" "DWord" $val
                    Set-Service -Name "WerSvc" -StartupType (if ($undo) { "Manual" } else { "Disabled" }) -ErrorAction SilentlyContinue
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
                        powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 | Out-Null
                        powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c | Out-Null
                    } else {
                        powercfg -setactive 381b4222-f694-41f0-9685-ff5bb260df2e | Out-Null
                    }
                }
                "Tweak_HAGS" {
                    Set-RegSafe "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" "HwSchMode" "DWord" (if ($undo) { 1 } else { 2 })
                }
                "Tweak_PowerThrottling" {
                    Set-RegSafe "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" "PowerThrottlingOff" "DWord" (if ($undo) { 0 } else { 1 })
                }
                "Tweak_MouseAccel" {
                    Set-RegSafe "HKCU:\Control Panel\Mouse" "MouseSpeed" "String" (if ($undo) { "1" } else { "0" })
                    Set-RegSafe "HKCU:\Control Panel\Mouse" "MouseThreshold1" "String" (if ($undo) { "6" } else { "0" })
                    Set-RegSafe "HKCU:\Control Panel\Mouse" "MouseThreshold2" "String" (if ($undo) { "10" } else { "0" })
                }
                "Tweak_GameDVR" {
                    Set-RegSafe "HKCU:\System\GameConfigStore" "GameDVR_Enabled" "DWord" (if ($undo) { 1 } else { 0 })
                    Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" "AllowGameDVR" "DWord" (if ($undo) { 1 } else { 0 })
                    Set-RegSafe "HKCU:\Software\Microsoft\GameBar" "AutoGameModeEnabled" "DWord" 1
                }
                "Tweak_NetworkThrottling" {
                    Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" "NetworkThrottlingIndex" "DWord" (if ($undo) { 10 } else { 0xFFFFFFFF })
                }
                "Tweak_SystemResponsiveness" {
                    Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" "SystemResponsiveness" "DWord" (if ($undo) { 20 } else { 0 })
                    Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" "GPU Priority" "DWord" (if ($undo) { 2 } else { 8 })
                    Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" "Priority" "DWord" (if ($undo) { 2 } else { 6 })
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
                            Set-RegSafe $nc.PSPath "PnPCapabilities" "DWord" (if ($undo) { 0 } else { 24 })
                        }
                    }
                }
                "Tweak_Hibernation" {
                    if ($undo) { powercfg -h on | Out-Null } else { powercfg -h off | Out-Null }
                }
                "Tweak_FastStartup" {
                    Set-RegSafe "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" "HiberbootEnabled" "DWord" (if ($undo) { 1 } else { 0 })
                }
                "Tweak_BgApps" {
                    Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" "GlobalUserDisabled" "DWord" (if ($undo) { 0 } else { 1 })
                    Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" "LetAppsRunInBackground" "DWord" (if ($undo) { "<RemoveEntry>" } else { 2 })
                }
                "Tweak_MultiplaneOverlay" {
                    Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows\Dwm" "OverlayTestMode" "DWord" (if ($undo) { "<RemoveEntry>" } else { 5 })
                }
                "Tweak_VisualFX" {
                    Set-RegSafe "HKCU:\Control Panel\Desktop" "MenuShowDelay" "String" (if ($undo) { "400" } else { "10" })
                    Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "TaskbarAnimations" "DWord" (if ($undo) { 1 } else { 0 })
                }
                "Tweak_SSDTrim" {
                    fsutil behavior set DisableDeleteNotify (if ($undo) { 1 } else { 0 }) | Out-Null
                }
                "Tweak_Services" {
                    $svcs = @("MapsBroker", "Fax", "RetailDemo", "WMPNetworkSvc", "RemoteRegistry", "CscService")
                    foreach ($s in $svcs) {
                        Set-Service -Name $s -StartupType (if ($undo) { "Manual" } else { "Disabled" }) -ErrorAction SilentlyContinue
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
                    Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" "01" "DWord" (if ($undo) { 1 } else { 0 })
                }
                "Tweak_ReservedStorage" {
                    DISM.exe /Online /Set-ReservedStorageState /State:(if ($undo) { "Enabled" } else { "Disabled" }) | Out-Null
                }
                "Tweak_SvcHostSplitting" {
                    if ($undo) {
                        Set-RegSafe "HKLM:\SYSTEM\CurrentControlSet\Control" "SvcHostSplitThresholdInKB" "DWord" 3670016
                    } else {
                        $ramKb = (Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum).Sum / 1KB
                        if ($ramKb -gt 0) {
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
                    Set-RegSafe "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" "LongPathsEnabled" "DWord" (if ($undo) { 0 } else { 1 })
                }
                "Tweak_UTC" {
                    Set-RegSafe "HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation" "RealTimeIsUniversal" "DWord" (if ($undo) { 0 } else { 1 })
                }
                "Tweak_S0StandbyFix" {
                    Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Power\PowerSettings\f15576e8-98b7-4186-b944-eafa664402d9" "ACSettingIndex" "DWord" (if ($undo) { 1 } else { 0 })
                    Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Power\PowerSettings\f15576e8-98b7-4186-b944-eafa664402d9" "DCSettingIndex" "DWord" (if ($undo) { 1 } else { 0 })
                }
                "Tweak_S3Sleep" {
                    Set-RegSafe "HKLM:\SYSTEM\CurrentControlSet\Control\Power" "PlatformAoAcOverride" "DWord" (if ($undo) { "<RemoveEntry>" } else { 0 })
                }
                "Tweak_ClassicContext" {
                    $clsidPath = "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32"
                    if ($undo) {
                        Remove-Item -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" -Recurse -Force -ErrorAction SilentlyContinue
                    } else {
                        New-Item -Path $clsidPath -Force -ErrorAction SilentlyContinue | Out-Null
                        Set-ItemProperty -Path $clsidPath -Name "(Default)" -Value "" -Force -ErrorAction SilentlyContinue
                    }
                }
                "Tweak_FileExt" {
                    Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "HideFileExt" "DWord" (if ($undo) { 1 } else { 0 })
                }
                "Tweak_HiddenFiles" {
                    Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "Hidden" "DWord" (if ($undo) { 2 } else { 1 })
                }
                "Tweak_HideTaskbarJunk" {
                    Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" "SearchboxTaskbarMode" "DWord" (if ($undo) { 1 } else { 0 })
                    Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "ShowTaskViewButton" "DWord" (if ($undo) { 1 } else { 0 })
                    Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Dsh" "AllowNewsAndInterests" "DWord" (if ($undo) { 1 } else { 0 })
                }
                "Tweak_DarkMode" {
                    $v = if ($undo) { 1 } else { 0 }
                    Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" "AppsUseLightTheme" "DWord" $v
                    Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" "SystemUsesLightTheme" "DWord" $v
                }
                "Tweak_StickyKeys" {
                    Set-RegSafe "HKCU:\Control Panel\Accessibility\StickyKeys" "Flags" "String" (if ($undo) { "510" } else { "506" })
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
                    Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "LaunchTo" "DWord" (if ($undo) { 2 } else { 1 })
                    $galleryClsid = "HKCU:\Software\Classes\CLSID\{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}"
                    $homeClsid    = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{f874310e-b6b7-47dc-bc84-b9e6b38f5903}"
                    Set-RegSafe $galleryClsid "System.IsPinnedToNameSpaceTree" "DWord" (if ($undo) { 1 } else { 0 })
                    if (-not $undo) {
                        Remove-Item -Path $homeClsid -Recurse -Force -ErrorAction SilentlyContinue
                    }
                }
                "Tweak_TaskbarLeft" {
                    Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "TaskbarAl" "DWord" (if ($undo) { 1 } else { 0 })
                }
                "Tweak_RevertStartMenu" {
                    $v = if ($undo) { "<RemoveEntry>" } else { 1 }
                    Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" "HideRecommendedSection" "DWord" $v
                    Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "Start_TrackDocs" "DWord" (if ($undo) { 1 } else { 0 })
                }
                "Tweak_NumLock" {
                    Set-RegSafe "Registry::HKEY_USERS\.DEFAULT\Control Panel\Keyboard" "InitialKeyboardIndicators" "String" (if ($undo) { "0" } else { "2" })
                }
                "Tweak_DetailedBSoD" {
                    Set-RegSafe "HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl" "DisplayParameters" "DWord" (if ($undo) { 0 } else { 1 })
                    Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "VerboseStatus" "DWord" (if ($undo) { 0 } else { 1 })
                }
                "Tweak_BatteryPct" {
                    Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "ShowBatteryPercentage" "DWord" (if ($undo) { 0 } else { 1 })
                    Set-RegSafe "HKCU:\Control Panel\Accessibility" "DynamicScrollbars" "DWord" (if ($undo) { 1 } else { 0 })
                }
                "Tweak_HideSettingsHome" {
                    Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" "SettingsPageVisibility" "String" (if ($undo) { "<RemoveEntry>" } else { "hide:home" })
                    Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "DisableAcrylicBackgroundOnLogon" "DWord" (if ($undo) { 0 } else { 1 })
                }
                "Tweak_DeepOneDrive" {
                    if ($undo) {
                        winget install --id Microsoft.OneDrive -e --silent --accept-package-agreements --accept-source-agreements
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
                    Set-RegSafe "HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot" "TurnOffWindowsCopilot" "DWord" (if ($undo) { 0 } else { 1 })
                    Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" "TurnOffWindowsCopilot" "DWord" (if ($undo) { 0 } else { 1 })
                    Set-RegSafe "HKCU:\Software\Policies\Microsoft\Windows\WindowsAI" "DisableAIDataAnalysis" "DWord" (if ($undo) { 0 } else { 1 })
                    Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" "DisableAIDataAnalysis" "DWord" (if ($undo) { 0 } else { 1 })
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
                    Set-RegSafe "HKLM:\SOFTWARE\Policies\BraveSoftware\Brave" "BraveAIChatEnabled" "DWord" (if ($undo) { 1 } else { 0 })
                }
                "Tweak_PeripheralBlock" {
                    Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching" "SearchOrderConfig" "DWord" (if ($undo) { 1 } else { 0 })
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
                    Set-RegSafe "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" "DisabledComponents" "DWord" (if ($undo) { 0 } else { 32 })
                    netsh interface teredo set state (if ($undo) { "default" } else { "disabled" }) | Out-Null
                }
                "Tweak_DisableIPv6" {
                    Set-RegSafe "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" "DisabledComponents" "DWord" (if ($undo) { 0 } else { 255 })
                    if ($undo) {
                        Enable-NetAdapterBinding -Name "*" -ComponentID ms_tcpip6 -ErrorAction SilentlyContinue
                    } else {
                        Disable-NetAdapterBinding -Name "*" -ComponentID ms_tcpip6 -ErrorAction SilentlyContinue
                    }
                }
                "Tweak_DisableNotifications" {
                    $v = if ($undo) { 0 } else { 1 }
                    Set-RegSafe "HKCU:\Software\Policies\Microsoft\Windows\Explorer" "DisableNotificationCenter" "DWord" $v
                    Set-RegSafe "HKCU:\Software\Microsoft\Terminal Server Client" "AuthenticationLevelOverride" "DWord" (if ($undo) { "<RemoveEntry>" } else { 0 })
                }
                "Tweak_NewOutlookBlock" {
                    Set-RegSafe "HKCU:\Software\Microsoft\Office\16.0\Outlook\Preferences" "UseNewOutlook" "DWord" (if ($undo) { 1 } else { 0 })
                    Set-RegSafe "HKCU:\Software\Policies\Microsoft\office\16.0\outlook\preferences" "NewOutlookMigrationUserSetting" "DWord" (if ($undo) { "<RemoveEntry>" } else { 0 })
                }
            }
        }
        Log-Bg "[OK] Secili Tweaks islemleri tamamlandi."
    }
}

$script:BtnApplyTweaks.Add_Click({ Invoke-SelectedTweaks $false })
$script:BtnUndoTweaks.Add_Click({ Invoke-SelectedTweaks $true })

$script:BtnRevertContextMenu.Add_Click({
    Remove-Item -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" -Recurse -Force -ErrorAction SilentlyContinue
    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
    Write-UiLog (Decode-U "[OK] Windows 11 sag tik menusu varsayilana donduruldu ve Explorer yeniden baslatildi.")
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

# --- SEKME 3: WINDOWS OZELLIKLERI (DISM) VE DNS ---
function Render-Features {
    $script:FeaturesGrid.Children.Clear()
    $script:FeatureCheckboxes.Clear()

    foreach ($feat in $script:FeaturesData) {
        $card = New-Object System.Windows.Controls.Border
        $card.Background = Get-Brush $script:Theme.CardBg
        $card.BorderBrush = Get-Brush $script:Theme.BorderBrushColor
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
        $cb.Add_Checked({ Update-AllSelectionCounts })
        $cb.Add_Unchecked({ Update-AllSelectionCounts })

        $desc = New-Object System.Windows.Controls.TextBlock
        $desc.Text = Decode-U $feat.Desc
        $desc.FontSize = 11
        $desc.Foreground = Get-Brush $script:Theme.TextMuted
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

        [void]$script:FeaturesGrid.Children.Add($card)
        $script:FeatureCheckboxes[$feat.Feature] = $cb
    }
}

function Set-QuickDns([string[]]$v4, [string]$label) {
    Start-BackgroundTask "DNS Ayarlaniyor: $label" @{ V4 = $v4; Label = $label } {
        param($p)
        $adapters = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' }
        foreach ($a in $adapters) {
            if ($p.V4.Count -eq 0) {
                Set-DnsClientServerAddress -InterfaceIndex $a.ifIndex -ResetServerAddresses -ErrorAction SilentlyContinue
            } else {
                Set-DnsClientServerAddress -InterfaceIndex $a.ifIndex -ServerAddresses $p.V4 -ErrorAction SilentlyContinue
            }
        }
        ipconfig /flushdns | Out-Null
        Log-Bg ("[OK] DNS guncellendi: " + $p.Label)
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
    if ($sel.Count -eq 0) {
        Write-UiLog (Decode-U "[!] Etkinlestirilecek en az 1 Windows ozelligi secin.")
        return
    }
    Start-BackgroundTask "Windows Ozellikleri etkinlestiriliyor..." @{ Items = $sel } {
        param($p)
        foreach ($f in $p.Items) {
            Log-Bg ("[+] DISM Etkinlestiriliyor: " + $f.Feature)
            Enable-WindowsOptionalFeature -Online -FeatureName $f.Feature -All -NoRestart -ErrorAction SilentlyContinue | Out-Null
            if ($f.ExtraFeatures) {
                foreach ($ex in $f.ExtraFeatures) {
                    Enable-WindowsOptionalFeature -Online -FeatureName $ex -All -NoRestart -ErrorAction SilentlyContinue | Out-Null
                }
            }
        }
        Log-Bg "[OK] Secili Windows Ozellikleri etkinlestirildi."
    }
})

$script:BtnDisableFeatures.Add_Click({
    $sel = @()
    foreach ($cb in $script:FeatureCheckboxes.Values) {
        if ($cb.IsChecked -eq $true) { $sel += $cb.Tag }
    }
    if ($sel.Count -eq 0) {
        Write-UiLog (Decode-U "[!] Devre disi birakilacak en az 1 Windows ozelligi secin.")
        return
    }
    Start-BackgroundTask "Windows Ozellikleri kapatiliyor..." @{ Items = $sel } {
        param($p)
        foreach ($f in $p.Items) {
            Log-Bg ("[-] DISM Devre Disi Birakiliyor: " + $f.Feature)
            Disable-WindowsOptionalFeature -Online -FeatureName $f.Feature -NoRestart -ErrorAction SilentlyContinue | Out-Null
        }
        Log-Bg "[OK] Secili Windows Ozellikleri devre disi birakildi."
    }
})

$script:BtnDeepOneDrive.Add_Click({
    Start-BackgroundTask "OneDrive kaldiriliyor..." @{} {
        Stop-Process -Name "OneDrive" -Force -ErrorAction SilentlyContinue
        $od = "$env:SystemRoot\SysWOW64\OneDriveSetup.exe"
        if (!(Test-Path $od)) { $od = "$env:SystemRoot\System32\OneDriveSetup.exe" }
        if (Test-Path $od) { Start-Process $od -ArgumentList "/uninstall" -Wait -NoNewWindow }
        Log-Bg "[OK] OneDrive sistemden kaldirildi."
    }
})
$script:BtnRestoreOneDrive.Add_Click({
    Start-BackgroundTask "OneDrive geri yukleniyor..." @{} {
        winget install --id Microsoft.OneDrive -e --silent --accept-package-agreements --accept-source-agreements
        Log-Bg "[OK] OneDrive tekrar kuruldu."
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

# --- SEKME 4: BLOATWARE RENDER VE KALDIR / GERI YUKLE ---
function Render-Bloatware {
    $script:BloatwareGrid.Children.Clear()
    $script:BloatCheckboxes.Clear()

    foreach ($b in $script:BloatwareData) {
        $card = New-Object System.Windows.Controls.Border
        $card.Background = Get-Brush $script:Theme.CardBg
        $card.BorderBrush = Get-Brush $script:Theme.BorderBrushColor
        $card.BorderThickness = New-Object System.Windows.Thickness(1)
        $card.CornerRadius = New-Object System.Windows.CornerRadius(6)
        $card.Padding = New-Object System.Windows.Thickness(10, 8, 10, 8)
        $card.Margin = New-Object System.Windows.Thickness(4)
        $card.Cursor = [System.Windows.Input.Cursors]::Hand

        $sp = New-Object System.Windows.Controls.StackPanel
        $cb = New-Object System.Windows.Controls.CheckBox
        $cb.Tag = $b
        $cb.Content = Decode-U $b.Name
        $cb.IsChecked = ($b.DefaultCheck -eq $true)
        $cb.Foreground = Get-Brush "#F8FAFC"
        $cb.FontWeight = "SemiBold"
        $cb.FontSize = 12.5
        $cb.Add_Checked({ Update-AllSelectionCounts })
        $cb.Add_Unchecked({ Update-AllSelectionCounts })

        $pkgTxt = New-Object System.Windows.Controls.TextBlock
        $pkgTxt.Text = $b.Pkg
        $pkgTxt.FontSize = 10.5
        $pkgTxt.Foreground = Get-Brush $script:Theme.TextDim
        $pkgTxt.Margin = New-Object System.Windows.Thickness(22, 2, 0, 0)

        [void]$sp.Children.Add($cb)
        [void]$sp.Children.Add($pkgTxt)
        $card.Child = $sp
        $card.Tag = $cb

        $card.Add_MouseLeftButtonUp({
            param($sender, $e)
            if ($e.OriginalSource -isnot [System.Windows.Controls.Primitives.ToggleButton]) {
                $innerCb = $sender.Tag
                if ($innerCb) { $innerCb.IsChecked = -not $innerCb.IsChecked }
            }
        })

        [void]$script:BloatwareGrid.Children.Add($card)
        $script:BloatCheckboxes[$b.Pkg] = $cb
    }
}

$script:BtnSelectDefaultBloat.Add_Click({
    foreach ($cb in $script:BloatCheckboxes.Values) {
        if ($cb.Tag.DefaultCheck -eq $true) { $cb.IsChecked = $true }
    }
    Update-AllSelectionCounts
})
$script:BtnSelectAllBloat.Add_Click({
    foreach ($cb in $script:BloatCheckboxes.Values) { $cb.IsChecked = $true }
    Update-AllSelectionCounts
})
$script:BtnClearBloat.Add_Click({
    foreach ($cb in $script:BloatCheckboxes.Values) { $cb.IsChecked = $false }
    Update-AllSelectionCounts
})

$script:BtnRemoveBloatware.Add_Click({
    $sel = @()
    foreach ($cb in $script:BloatCheckboxes.Values) {
        if ($cb.IsChecked -eq $true) { $sel += $cb.Tag }
    }
    if ($sel.Count -eq 0) {
        Write-UiLog (Decode-U "[!] Kaldirilacak en az 1 UWP paketi secin.")
        return
    }
    Start-BackgroundTask "Secili Bloatware paketleri kaldiriliyor..." @{ Items = $sel } {
        param($p)
        foreach ($item in $p.Items) {
            Log-Bg ("[-] UWP Kaldiriliyor: " + (Decode-Bg $item.Name))
            Get-AppxPackage -AllUsers $item.Pkg -ErrorAction SilentlyContinue | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
            Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -like $item.Pkg } | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Out-Null
        }
        Log-Bg "[OK] Secili UWP Bloatware paketleri sistemden temizlendi."
    }
})

$script:BtnReinstallBloatware.Add_Click({
    $sel = @()
    foreach ($cb in $script:BloatCheckboxes.Values) {
        if ($cb.IsChecked -eq $true -and -not [string]::IsNullOrWhiteSpace($cb.Tag.StoreId)) {
            $sel += $cb.Tag
        }
    }
    if ($sel.Count -eq 0) {
        Write-UiLog (Decode-U "[!] Geri yuklenecek StoreId destekli en az 1 paket secin.")
        return
    }
    Start-BackgroundTask "Secili UWP paketleri Microsoft Store uzerinden kuruluyor..." @{ Items = $sel } {
        param($p)
        foreach ($item in $p.Items) {
            Log-Bg ("[+] Yeniden Kuruluyor: " + (Decode-Bg $item.Name))
            winget install --id $item.StoreId --source msstore --silent --accept-package-agreements --accept-source-agreements
        }
        Log-Bg "[OK] Secili UWP paketleri geri yuklendi."
    }
})

# =============================================================================
# GOMULU UET_TOOL.CMD (HARICI DOSYA GEREKTIRMEYEN DOGRUDAN ENTEGRE MOTOR)
# =============================================================================
$script:EmbeddedUetToolCmd = @'
@setlocal DisableDelayedExpansion
@echo off

:: ============================================================================
:: PROJE: UMUT EVRAN TOOL - GELISMIS WINDOWS & OFFICE SISTEM YONETIM ARACI (UET)
:: DURUM: FAZ 1 - FAZ 6 FINAL SURUM (HWID / OHOOK / TSFORGE CRASH FIX)
:: ============================================================================

:: [1] KOMUT SATIRI PARAMETRELERINI YAKALA
set "_args="
set "_args=%*"
if defined _args set "_args=%_args:"=%"
set "_unattended=0"
if defined _args (
    for %%A in (%_args%) do (
        if /i "%%A"=="/S" set "_unattended=1"
        if /i "%%A"=="/Silent" set "_unattended=1"
    )
)

:: [2] SISTEM YOLU (PATH) VE ORTAM DEGISKENLERINI GARANTIYE AL
set "SysPath=%SystemRoot%\System32"
if exist "%SystemRoot%\Sysnative\reg.exe" set "SysPath=%SystemRoot%\Sysnative"
set "Path=%SysPath%;%SystemRoot%;%SysPath%\Wbem;%SysPath%\WindowsPowerShell\v1.0\;%LocalAppData%\Microsoft\WindowsApps\"

:: [3] 32-BIT CMD ICINDEN 64-BIT SISTEMDE CALISMA KONTROLU (SYSNATIVE RELAUNCH)
set "_cmdf=%~f0"
if exist "%SystemRoot%\Sysnative\cmd.exe" if not defined _rel1 (
    set "_rel1=1"
    start "" "%SystemRoot%\Sysnative\cmd.exe" /c ""%_cmdf%" %*"
    exit /b
)

:: [4] TURKCE KARAKTER (UTF-8) VE GECICI KLASOR AYARLARI
chcp 65001 >nul 2>&1
set "_work=%~dp0"
if "%_work:~-1%"=="\" set "_work=%_work:~0,-1%"
set "_temp=%Temp%"
set "psc=powershell.exe -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass"

:: [5] POWERSHELL VE WMI VARLIK KONTROLU
set "_pstest=1"
%psc% "$ExecutionContext.SessionState.LanguageMode" >nul 2>&1 || set "_pstest=0"

:: [6] YONETICI HAKLARI (UAC ELEVATION) KONTROLU VE OTOMATIK YUKSELTME
reg query "HKU\S-1-5-19" >nul 2>&1 && goto :Passed_UAC

if "%_unattended%"=="1" (
    echo [HATA] Katilimsiz mod icin betigi Yonetici olarak calistirmalisiniz.
    exit /b 1
)

echo.
echo  ====================================================================
echo   [i] Yonetici yetkileri gerekiyor, UAC penceresi baslatiliyor...
echo  ====================================================================
if "%_pstest%"=="1" (
    %psc% "$q = [char]34; Start-Process -FilePath $env:COMSPEC -ArgumentList ('/c ' + $q + $q + $env:_cmdf + $q + ' ' + $env:_args + $q) -Verb RunAs" >nul 2>&1 && exit /b
)
set "_vbs=%_temp%\uac_elevate_%random%.vbs"
(
    echo Set UAC = CreateObject^("Shell.Application"^)
    echo UAC.ShellExecute "%COMSPEC%", "/c """"%_cmdf%"" %_args%""", "", "runas", 1
) > "%_vbs%"
cscript //nologo "%_vbs%" >nul 2>&1
del /f /q "%_vbs%" >nul 2>&1
exit /b

:Passed_UAC
setlocal EnableDelayedExpansion
pushd "%_work%"

:: [7] MIMARI, WINDOWS BUILD VE SURUM TESPITI
set "os_arch=x86"
if /i "%PROCESSOR_ARCHITECTURE%"=="AMD64" set "os_arch=x64"
if /i "%PROCESSOR_ARCHITECTURE%"=="ARM64" set "os_arch=ARM64"
if defined PROCESSOR_ARCHITEW6432 set "os_arch=%PROCESSOR_ARCHITEW6432%"

set "winbuild=0"
for /f "tokens=2*" %%a in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v CurrentBuildNumber 2^>nul') do set "winbuild=%%b"
if "%winbuild%"=="0" (
    for /f "tokens=2 delims=[]" %%G in ('ver') do for /f "tokens=4 delims=. " %%H in ("%%G") do set "winbuild=%%H"
)

set "win_edition=Bilinmiyor"
set "edition_id=Bilinmiyor"
for /f "tokens=2*" %%a in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v ProductName 2^>nul') do set "win_edition=%%b"
for /f "tokens=2*" %%a in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v EditionID 2^>nul') do set "edition_id=%%b"
set "edition_id=!edition_id: =!"

if %winbuild% GEQ 22000 (
    set "win_edition=!win_edition:Windows 10=Windows 11!"
)

:: [8] ANSI ESCAPE (RENK MOTORU) KURULUMU
set "_ansi=0"
if %winbuild% GEQ 10586 (
    reg add "HKCU\Console" /v VirtualTerminalLevel /t REG_DWORD /d 1 /f >nul 2>&1
    for /f %%A in ('echo prompt $E^| cmd') do set "_esc=%%A"
    set "_ansi=1"
)

if "%_ansi%"=="1" (
    set "_Red=!_esc![91m"
    set "_Green=!_esc![92m"
    set "_Yellow=!_esc![93m"
    set "_Blue=!_esc![94m"
    set "_Magenta=!_esc![95m"
    set "_Cyan=!_esc![96m"
    set "_White=!_esc![97m"
    set "_Gray=!_esc![90m"
    set "_Reset=!_esc![0m"
) else (
    set "_Red=" & set "_Green=" & set "_Yellow=" & set "_Blue="
    set "_Magenta=" & set "_Cyan=" & set "_White=" & set "_Gray=" & set "_Reset="
)

:: [9] KRITIK SERVIS VE SISTEM SAGLIK KONTROLU (SELF-CHECK)
set "_serv_ok=1"
set "_wmi_ok=1"
sc query Winmgmt | find /i "RUNNING" >nul 2>&1
if errorlevel 1 (
    net start Winmgmt /y >nul 2>&1
    sc query Winmgmt | find /i "RUNNING" >nul 2>&1
    if errorlevel 1 set "_wmi_ok=0"
)
sc query sppsvc >nul 2>&1
if errorlevel 1 set "_serv_ok=0"

:: [10] KOMUT SATIRI PARAMETRE YONLENDIRICISI (CLI SWITCHES)
if defined _args (
    for %%A in (%_args%) do (
        if /i "%%A"=="/?"           call :CLI_Help & goto :End_Unattended
        if /i "%%A"=="/help"        call :CLI_Help & goto :End_Unattended
        if /i "%%A"=="/HWID"        call :HWID_Run & goto :End_Unattended
        if /i "%%A"=="/Ohook"       call :Ohook_Install & goto :End_Unattended
        if /i "%%A"=="/TSforge"     call :TSforge_Run_Win & goto :End_Unattended
        if /i "%%A"=="/KMS"         call :KMS_Act_All & goto :End_Unattended
        if /i "%%A"=="/KMS-Windows" call :KMS_Act_Win & goto :End_Unattended
        if /i "%%A"=="/KMS-Office"  call :KMS_Act_Off & goto :End_Unattended
        if /i "%%A"=="/KMS-Task"    call :KMS_InstallTask & goto :End_Unattended
        if /i "%%A"=="/Status"      call :Mod_CheckStatus & goto :End_Unattended
    )
)

:: ============================================================================
:: ANA MENU (TUI)
:: ============================================================================
:MainMenu
for /f "tokens=2*" %%a in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v EditionID 2^>nul') do set "edition_id=%%b"
set "edition_id=!edition_id: =!"
if "%_unattended%"=="0" mode con cols=98 lines=32 >nul 2>&1
title UET - Gelismis Sistem ve Lisans Yonetim Araci v4.0 [Mimari: %os_arch% ^| Build: %winbuild%]
cls
echo.
echo   !_Cyan!==============================================================================================!_Reset!
echo      !_White!UMUT EVRAN TOOL (UET) - GELISMIS WINDOWS ^& OFFICE SISTEM YONETIM ARACI!_Reset!
echo      !_Gray!Sistem: %win_edition% [%edition_id%] ^| Mimari: %os_arch% ^| Yapim: %winbuild%!_Reset!
echo   !_Cyan!==============================================================================================!_Reset!
if "%_wmi_ok%"=="0" echo      !_Red![UYARI] WMI Servisi [Winmgmt] yanit vermiyor. Sorun Giderme [8] menusunu kullanin.!_Reset!
if "%_pstest%"=="0" echo      !_Yellow![UYARI] PowerShell kisitlanmis veya calismiyor. Bazi gelismis moduller etkilenebilir.!_Reset!
echo.
echo      !_White!Ana Moduller:!_Reset!
echo.
echo       !_Green![1] HWID Yonetimi!_Reset!               ^| Windows 10-11                   (Kalici Dijital Lisans)
echo       !_Green![2] Ohook Yonetimi!_Reset!              ^| Microsoft Office                (Kalici Yerel SPPC Lisans)
echo       !_Green![3] TSforge Yonetimi!_Reset!            ^| Windows / ESU / Office          (Kalici Guvenilir Depolama)
echo       !_Green![4] Online KMS Yonetimi!_Reset!         ^| Windows / Office                (180 Gun + Otomatik Yenileme)
echo.
echo      !_White!Sistem ve Yonetim Araclari:!_Reset!
echo.
echo       !_Cyan![5] Lisans Durumu Kontrolu!_Reset!      ^| Detayli WMI, Slmgr, OSPP, BIOS OEM ve vNext Dokumu
echo       !_Cyan![6] Windows Surum Degistir!_Reset!      ^| Home / Pro / Enterprise CBS ^& DISM Surum Gecisi
echo       !_Cyan![7] Office Surum Degistir!_Reset!       ^| Click-to-Run (C2R) Kanal ve Lisans Surumu Yonetimi
echo       !_Yellow![8] Gelismis Sorun Giderme!_Reset!      ^| WMI, Token, ClipSVC, sppsvc ve Sistem Onarimi
echo       !_Magenta![9] Ekstra Araclar ($OEM$)!_Reset!      ^| $OEM$ Klasoru Cikartma, Base64 Motoru ve CLI Rehberi
echo.
echo       !_Red![0] Cikis!_Reset!
echo.
echo   !_Cyan!==============================================================================================!_Reset!
echo.

choice /C:1234567890 /N /M "   >> Lutfen yapmak istediginiz islemi secin [1-9, Cikis icin 0]: "
set "_erl=%errorlevel%"

if %_erl%==10 goto :Exit_Script
if %_erl%==9  call :Mod_Extras       & goto :MainMenu
if %_erl%==8  call :Mod_Troubleshoot & goto :MainMenu
if %_erl%==7  call :Mod_ChangeOffice & goto :MainMenu
if %_erl%==6  call :Mod_ChangeWin    & goto :MainMenu
if %_erl%==5  call :Mod_CheckStatus  & goto :MainMenu
if %_erl%==4  call :Mod_OnlineKMS    & goto :MainMenu
if %_erl%==3  call :Mod_TSforge      & goto :MainMenu
if %_erl%==2  call :Mod_Ohook        & goto :MainMenu
if %_erl%==1  call :Mod_HWID         & goto :MainMenu
goto :MainMenu

:: ============================================================================
:: YARDIMCI FONKSIYONLAR VE ANAHTAR VERITABANLARI (HELPER SUBROUTINES)
:: ============================================================================
:dk_start_service
set "_srv=%~1"
sc query "%_srv%" | find /i "RUNNING" >nul 2>&1 && exit /b 0
sc config "%_srv%" start= demand >nul 2>&1
net start "%_srv%" /y >nul 2>&1
sc query "%_srv%" | find /i "RUNNING" >nul 2>&1 && exit /b 0
exit /b 1

:dk_check_perm_win
set "_win_perm_ok=0"
%psc% "$p = Get-CimInstance SoftwareLicensingProduct -ErrorAction SilentlyContinue | Where-Object {$_.PartialProductKey -and $_.ApplicationID -eq '55c92734-d682-4d71-983e-d6ec3f16059f' -and $_.LicenseStatus -eq 1 -and $_.GracePeriodRemaining -eq 0}; if ($p) { exit 0 } else { exit 1 }" >nul 2>&1
if !errorlevel! equ 0 set "_win_perm_ok=1"
exit /b 0

:dk_check_act_win
set "_win_act_ok=0"
%psc% "$p = Get-CimInstance SoftwareLicensingProduct -ErrorAction SilentlyContinue | Where-Object {$_.PartialProductKey -and $_.ApplicationID -eq '55c92734-d682-4d71-983e-d6ec3f16059f' -and $_.LicenseStatus -eq 1}; if ($p) { exit 0 } else { exit 1 }" >nul 2>&1
if !errorlevel! equ 0 set "_win_act_ok=1"
exit /b 0

:dk_extract_b64
set "_b64_tag=%~1"
set "_b64_out=%~2"
findstr /i /c:"::B64_START_%_b64_tag%" "%_cmdf%" >nul 2>&1 || exit /b 1
%psc% "$c = Get-Content -LiteralPath $env:_cmdf; $s = $false; $b = New-Object System.Text.StringBuilder; foreach ($l in $c) { if ($l -match ('^::B64_END_' + $env:_b64_tag)) { break }; if ($s -and $l.StartsWith('::')) { [void]$b.Append($l.Substring(2).Trim()) }; if ($l -match ('^::B64_START_' + $env:_b64_tag)) { $s = $true } }; if ($b.Length -gt 0) { [IO.File]::WriteAllBytes($env:_b64_out, [Convert]::FromBase64String($b.ToString())); exit 0 } else { exit 1 }" >nul 2>&1
exit /b %errorlevel%

:dk_invoke_core_engine
set "_eng_arg=%~1"
set "_found_local_mas="

if exist "%_work%\UET_Tool.cmd" set "_found_local_mas=%_work%\UET_Tool.cmd"
if not defined _found_local_mas if exist "%_work%\MAS_AIO.cmd" set "_found_local_mas=%_work%\MAS_AIO.cmd"

if defined _found_local_mas (
    echo   !_Cyan![i] Yerel cekirdek modul bulundu, izole alt islemde calistiriliyor: !_found_local_mas!!_Reset!
    "%ComSpec%" /c ""!_found_local_mas!" %_eng_arg%"
    exit /b 0
)

echo   !_Yellow![*] Yerel klasorde ikili bilet dosyasi bulunamadi, Bellek Ici [RAM] Cekirdek Motoru baslatiliyor...!_Reset!
%psc% "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; $s = $null; try { $s = Invoke-RestMethod -Uri 'https://get.activated.win' -TimeoutSec 15 } catch {}; if (-not $s) { Write-Host '   [i] Standart baglanti engellendi, Cloudflare DoH [1.1.1.1] deneniyor...' -ForegroundColor Yellow; $s = (curl.exe -s -L --doh-url https://1.1.1.1/dns-query https://get.activated.win | Out-String) }; if ($s -and $s.Length -gt 500) { & ([ScriptBlock]::Create($s)) $env:_eng_arg; exit 0 } else { exit 1 }"
if !errorlevel! neq 0 (
    echo   !_Red![HATA] Cekirdek motor indirilemedi. Lutfen internet baglantinizi kontrol edin.!_Reset!
    exit /b 1
)
exit /b 0

:Get_Edition_Key
set "%~2="
if /i "%~1"=="Core"                        set "%~2=YTMG3-N6DKC-DKB77-7M9GH-8HVX7"
if /i "%~1"=="CoreN"                       set "%~2=4CPRK-NM3K3-X6XXQ-RXX86-WXCHW"
if /i "%~1"=="CoreSingleLanguage"          set "%~2=BT79Q-G7N6G-PGBYW-4YWX6-6F4BT"
if /i "%~1"=="CoreCountrySpecific"         set "%~2=N2434-X9D7W-8PF6X-8DV9T-8TYMD"
if /i "%~1"=="Professional"                set "%~2=VK7JG-NPHTM-C97JM-9MPGT-3V66T"
if /i "%~1"=="ProfessionalN"               set "%~2=2B87N-8KFHP-DKV6R-Y2C8J-PKCKT"
if /i "%~1"=="ProfessionalWorkstation"     set "%~2=DXG7C-N36C4-C4HTG-X4T3X-2YV77"
if /i "%~1"=="ProfessionalWorkstationN"    set "%~2=WYPNQ-8C467-V2W6J-TX4WX-WT2RQ"
if /i "%~1"=="ProfessionalEducation"       set "%~2=8PTT6-RNW4C-6V7J2-C2D3X-MHBPB"
if /i "%~1"=="ProfessionalEducationN"      set "%~2=GJTYN-HDMQY-FRR76-HVGC7-QPF8P"
if /i "%~1"=="ProfessionalSingleLanguage"  set "%~2=G3KNM-CHG6T-R36X3-9QDG6-8M8K9"
if /i "%~1"=="Education"                   set "%~2=YNMGQ-8RYV3-4PGQ3-C8XTP-7CFBY"
if /i "%~1"=="EducationN"                  set "%~2=84NGF-MHBT6-FXBX8-QWJK7-DRR8H"
if /i "%~1"=="Enterprise"                  set "%~2=XGVPP-NMH47-7TTHJ-W3FW7-8HV2C"
if /i "%~1"=="EnterpriseN"                 set "%~2=3V6Q6-NQXCX-V8YXR-9QCYV-QPFCT"
if /i "%~1"=="IoTEnterprise"               set "%~2=XQQYW-NFFMW-XJPBH-K8732-CKFFD"
if /i "%~1"=="IoTEnterpriseS"              set "%~2=QPM6N-7J2WJ-P88HH-P3YRH-YY74H"
if /i "%~1"=="EnterpriseS"                 set "%~2=NK96Y-D9CD8-W44CQ-R8YTK-DYJWX"
if /i "%~1"=="EnterpriseSN"                set "%~2=2DBW3-N2PJG-MVHW3-G7TDK-9HKR4"
if /i "%~1"=="ServerRdsh"                  set "%~2=NJCF7-PW8QT-3324D-688JX-2YV66"
if /i "%~1"=="ServerStandard"              set "%~2=VDYBN-27WPP-V4HQT-9VMD4-VMK7H"
if /i "%~1"=="ServerDatacenter"            set "%~2=W3GGN-FT8W3-Y4M27-J84CP-Q3VJ9"
exit /b 0

:Get_GVLK_Key
set "%~2="
if /i "%~1"=="Core"                        set "%~2=TX9XD-98N7V-6WMQ6-BX7FG-H8Q99"
if /i "%~1"=="CoreN"                       set "%~2=3KHY7-WNT83-DGQKR-F7HPR-844BM"
if /i "%~1"=="CoreSingleLanguage"          set "%~2=7HNRX-D7KGG-3K4RQ-4WPJ4-YTDFH"
if /i "%~1"=="CoreCountrySpecific"         set "%~2=PVMJN-6DFY6-9CCP6-7BKTT-D3WVR"
if /i "%~1"=="Professional"                set "%~2=W269N-WFGWX-YVC9B-4J6C9-T83GX"
if /i "%~1"=="ProfessionalN"               set "%~2=MH37W-N47XK-V7XM9-C7227-GCQG9"
if /i "%~1"=="ProfessionalWorkstation"     set "%~2=NRG8B-VKK3Q-CXVCJ-9G2XF-6Q84J"
if /i "%~1"=="ProfessionalWorkstationN"    set "%~2=9FNHH-K3HBT-3W4TD-6383H-6XYWF"
if /i "%~1"=="ProfessionalEducation"       set "%~2=6TP4R-GNPTD-KYYHQ-7B7DP-J447Y"
if /i "%~1"=="ProfessionalEducationN"      set "%~2=YVWGF-BXNMC-HTQYQ-CPQ99-66QFC"
if /i "%~1"=="Education"                   set "%~2=NW6C2-QMPVW-D7KKK-3GKT6-VCFB2"
if /i "%~1"=="EducationN"                  set "%~2=2WH4N-8QGBV-H22JP-CT43Q-MDWWJ"
if /i "%~1"=="Enterprise"                  set "%~2=NPPR9-FWDCX-D2C8J-H872K-2YT43"
if /i "%~1"=="EnterpriseN"                 set "%~2=DPH2V-TTNVB-4X9Q3-TJR4H-KHJW4"
if /i "%~1"=="EnterpriseG"                 set "%~2=YYVX9-NTFWV-6MDM3-9PT4T-4M68B"
if /i "%~1"=="EnterpriseS"                 set "%~2=M7XTQ-FN8P6-TTKYV-9D4CC-J462D"
if /i "%~1"=="EnterpriseSN"                set "%~2=92NFX-8DJQP-P6BBQ-THF9C-7CG2H"
if /i "%~1"=="IoTEnterprise"               set "%~2=NPPR9-FWDCX-D2C8J-H872K-2YT43"
if /i "%~1"=="IoTEnterpriseS"              set "%~2=KBN8V-HFGQ4-MGXVD-347P6-PDQGT"
if /i "%~1"=="ServerRdsh"                  set "%~2=CPWHC-NT2C7-VYW78-DHDB2-PG3GK"
if /i "%~1"=="ServerStandard"              set "%~2=VDYBN-27WPP-V4HQT-9VMD4-VMK7H"
if /i "%~1"=="ServerDatacenter"            set "%~2=W3GGN-FT8W3-Y4M27-J84CP-Q3VJ9"
exit /b 0

:Get_Office_GVLK
set "%~2="
if /i "%~1"=="ProPlus2024Volume"       set "%~2=XJ2XN-FW8RK-P4HMP-DKDBV-GCVGB"
if /i "%~1"=="Standard2024Volume"      set "%~2=V28N4-JG22K-W66P8-VTMGK-H6HGR"
if /i "%~1"=="ProjectPro2024Volume"    set "%~2=FQQ23-N4YCY-73HQ3-FM9WC-76HF4"
if /i "%~1"=="VisioPro2024Volume"      set "%~2=B7TN8-FJ8V3-7QYCP-HQPMV-YY89G"
if /i "%~1"=="ProPlus2021Volume"       set "%~2=FXYTK-NJJ8C-GB6DW-3DYQT-6F7TH"
if /i "%~1"=="Standard2021Volume"      set "%~2=KDX7X-BNVR8-TKW4D-TKFF7-86B6F"
if /i "%~1"=="ProjectPro2021Volume"    set "%~2=FTNWT-C6WBT-8HMGF-K9PRX-QV9H8"
if /i "%~1"=="VisioPro2021Volume"      set "%~2=KNH8D-FGHT4-T8RK3-CTDYJ-K2HT4"
if /i "%~1"=="ProPlus2019Volume"       set "%~2=NMMKJ-6RK4F-KMJVX-8D9MJ-6MWKP"
if /i "%~1"=="Standard2019Volume"      set "%~2=6NWWJ-YQWMR-QKGCB-6TMB3-9D9HK"
if /i "%~1"=="ProjectPro2019Volume"    set "%~2=B4NPR-3FKK7-T2MBV-FRQ4W-PKD2B"
if /i "%~1"=="VisioPro2019Volume"      set "%~2=9BGNQ-K37YR-RQHF2-38RQ3-7VCBB"
if /i "%~1"=="MondoVolume"             set "%~2=HFTND-W9MK4-8B7MJ-B6C4G-XQBR2"
exit /b 0

:: ============================================================================
:: FAZ 2: LISANS VE AKTIVASYON DURUMU KONTROL MODULU (CHECK ACTIVATION STATUS)
:: ============================================================================
:Mod_CheckStatus
cls
if "%_unattended%"=="0" mode con cols=105 lines=45 >nul 2>&1
title Lisans ve Aktivasyon Durumu Kontrolu [Mimari: %os_arch% ^| Build: %winbuild%]

echo.
echo   !_Cyan!====================================================================================================!_Reset!
echo      !_White!DETAYLI WINDOWS VE OFFICE LISANS DURUMU RAPORU!_Reset!
echo      !_Gray!Lutfen bekleyin, WMI / SPPSVC / OSPP / BIOS OEM ve vNext kayitlari taraniyor...!_Reset!
echo   !_Cyan!====================================================================================================!_Reset!
echo.

call :dk_start_service sppsvc >nul 2>&1
call :dk_start_service Winmgmt >nul 2>&1

if "%_pstest%"=="0" (
    echo   !_Red![HATA] PowerShell kullanilamiyor. Standart slmgr ciktisina geciliyor...!_Reset!
    echo.
    cscript //nologo "%SysPath%\slmgr.vbs" /dlv
    echo.
    if "%_unattended%"=="0" pause
    exit /b
)

%psc% "$ErrorActionPreference = 'SilentlyContinue'; " ^
  "$os = Get-CimInstance -ClassName Win32_OperatingSystem; " ^
  "$sls = Get-CimInstance -ClassName SoftwareLicensingService; " ^
  "Write-Host '  === [1] SISTEM, SPPSVC VE BIOS OEM ANAHTAR BILGILERI ===' -ForegroundColor Cyan; " ^
  "Write-Host ('   Isletim Sistemi   : ' + $os.Caption + ' (' + $os.OSArchitecture + ')') -ForegroundColor White; " ^
  "Write-Host ('   Surum / Build     : ' + $os.Version + ' / ' + $os.BuildNumber) -ForegroundColor Gray; " ^
  "Write-Host ('   Istemci CMID      : ' + $sls.ClientMachineID) -ForegroundColor Gray; " ^
  "$oemKey = $sls.OA3xOriginalProductKey; " ^
  "if ($oemKey) { Write-Host ('   BIOS OEM Anahtari : ' + $oemKey + ' (' + $sls.OA3xOriginalProductKeyDescription + ')') -ForegroundColor Green } else { Write-Host '   BIOS OEM Anahtari : Anakart uzerinde gomulu OA3 OEM anahtari bulunamadi.' -ForegroundColor DarkGray }; " ^
  "Write-Host ''; " ^
  "Write-Host '  === [2] WINDOWS LISANS DURUMU (WMI / SoftwareLicensingProduct) ===' -ForegroundColor Cyan; " ^
  "$winProds = Get-CimInstance -ClassName SoftwareLicensingProduct | Where-Object { $_.PartialProductKey -ne $null -and $_.ApplicationID -eq '55c92734-d682-4d71-983e-d6ec3f16059f' }; " ^
  "if (-not $winProds) { Write-Host '   [-] Yuklu Windows urun anahtari bulunamadi.' -ForegroundColor Red } " ^
  "foreach ($p in $winProds) { " ^
  "  $statusText = switch ($p.LicenseStatus) { " ^
  "    0 {'Lisanssiz (Unlicensed)'} " ^
  "    1 {'Lisansli (Licensed)'} " ^
  "    2 {'OOB Grace (Ilk Kullanim Suresi)'} " ^
  "    3 {'OOT Grace (Donanim Degisikligi)'} " ^
  "    4 {'Non-Genuine Grace (Orijinal Degil)'} " ^
  "    5 {'Bildirim Modu (Notification)'} " ^
  "    6 {'Uzatilmis Sure (Extended Grace)'} " ^
  "    default {'Bilinmiyor (' + $p.LicenseStatus + ')'} " ^
  "  }; " ^
  "  $color = if ($p.LicenseStatus -eq 1) {'Green'} elseif ($p.LicenseStatus -in 2,3,6) {'Yellow'} else {'Red'}; " ^
  "  $graceDays = [math]::Round($p.GracePeriodRemaining / 1440, 1); " ^
  "  $expireMsg = if ($p.LicenseStatus -eq 1 -and $p.GracePeriodRemaining -eq 0) {'Kalici (Permanent)'} elseif ($p.GracePeriodRemaining -gt 0) { $graceDays.ToString() + ' Gun (' + $p.GracePeriodRemaining + ' dk) kaldi' } else {'Suresi Dolmus / Yok'}; " ^
  "  Write-Host ('   Urun Adi          : ' + $p.Name) -ForegroundColor White; " ^
  "  Write-Host ('   Aciklama / Kanal  : ' + $p.Description) -ForegroundColor Gray; " ^
  "  Write-Host ('   SKU ID            : ' + $p.ID) -ForegroundColor Gray; " ^
  "  Write-Host ('   Kismi Anahtar     : XXXXX-XXXXX-XXXXX-XXXXX-' + $p.PartialProductKey) -ForegroundColor Gray; " ^
  "  Write-Host ('   Lisans Durumu     : ' + $statusText) -ForegroundColor $color; " ^
  "  Write-Host ('   Gecerlilik Suresi : ' + $expireMsg) -ForegroundColor $color; " ^
  "  if ($p.Description -match 'KMS') { " ^
  "    $kmsHost = if ($p.DiscoveredKeyManagementServiceMachineName) {$p.DiscoveredKeyManagementServiceMachineName} else {$sls.KeyManagementServiceMachine}; " ^
  "    $kmsPort = if ($p.DiscoveredKeyManagementServiceMachinePort -ne 0) {$p.DiscoveredKeyManagementServiceMachinePort} else {$sls.KeyManagementServicePort}; " ^
  "    Write-Host ('   KMS Sunucu / Port : ' + $kmsHost + ' : ' + $kmsPort) -ForegroundColor Yellow; " ^
  "  } " ^
  "  Write-Host '   --------------------------------------------------------------------------------------' -ForegroundColor DarkGray; " ^
  "}; " ^
  "Write-Host ''; " ^
  "Write-Host '  === [3] MICROSOFT OFFICE LISANS DURUMU (SPP / OSPP / OHOOK) ===' -ForegroundColor Cyan; " ^
  "$offProds = Get-CimInstance -ClassName SoftwareLicensingProduct | Where-Object { $_.PartialProductKey -ne $null -and $_.ApplicationID -eq '0ff1ce15-a989-479d-af46-f275c6370663' }; " ^
  "$osppProds = Get-CimInstance -ClassName OfficeSoftwareProtectionProduct; " ^
  "$allOff = @($offProds) + @($osppProds) | Where-Object { $_ -ne $null }; " ^
  "if ($allOff.Count -eq 0) { Write-Host '   [i] WMI/OSPP uzerinde aktif geleneksel Office anahtari tespit edilmedi.' -ForegroundColor Yellow } " ^
  "foreach ($o in $allOff) { " ^
  "  $oStatus = switch ($o.LicenseStatus) { 1 {'Lisansli (Licensed)'} 0 {'Lisanssiz'} 5 {'Bildirim Modu (Notification)'} default {'Grace / Diger (' + $o.LicenseStatus + ')'} }; " ^
  "  $oColor = if ($o.LicenseStatus -eq 1) {'Green'} else {'Yellow'}; " ^
  "  $oDays = [math]::Round($o.GracePeriodRemaining / 1440, 1); " ^
  "  $oExp = if ($o.LicenseStatus -eq 1 -and $o.GracePeriodRemaining -eq 0) {'Kalici (Permanent / Ohook)'} elseif ($o.GracePeriodRemaining -gt 0) { $oDays.ToString() + ' Gun kaldi' } else {'Suresi Dolmus / Yok'}; " ^
  "  Write-Host ('   Office Urunu      : ' + $o.Name) -ForegroundColor White; " ^
  "  Write-Host ('   Aciklama          : ' + $o.Description) -ForegroundColor Gray; " ^
  "  Write-Host ('   Kismi Anahtar     : XXXXX-' + $o.PartialProductKey) -ForegroundColor Gray; " ^
  "  Write-Host ('   Durum / Sure      : ' + $oStatus + ' | ' + $oExp) -ForegroundColor $oColor; " ^
  "  Write-Host '   --------------------------------------------------------------------------------------' -ForegroundColor DarkGray; " ^
  "}; " ^
  "Write-Host ''; " ^
  "Write-Host '  === [4] OHOOK VE OFFICE C2R / vNEXT KONTROLU ===' -ForegroundColor Cyan; " ^
  "$c2rPath = 'HKLM:\SOFTWARE\Microsoft\Office\ClickToRun\Configuration'; " ^
  "if (Test-Path $c2rPath) { " ^
  "  $c2r = Get-ItemProperty -Path $c2rPath; " ^
  "  Write-Host ('   C2R Surum / Mimari: ' + $c2r.VersionToReport + ' (' + $c2r.Platform + ')') -ForegroundColor White; " ^
  "  Write-Host ('   Yuklu Urunler     : ' + $c2r.ProductReleaseIds) -ForegroundColor Gray; " ^
  "  Write-Host ('   Guncelleme Kanali : ' + $c2r.CDNBaseUrl) -ForegroundColor Gray; " ^
  "} else { Write-Host '   [i] Office Click-to-Run (C2R) kurulumu bulunamadi.' -ForegroundColor DarkGray }; " ^
  "$ohookFound = $false; " ^
  "$pfPaths = @($env:ProgramFiles, ${env:ProgramFiles(x86)}) | Where-Object { $_ } | Select-Object -Unique; " ^
  "foreach ($pf in $pfPaths) { " ^
  "  $sppcFiles = Get-ChildItem -Path ($pf + '\Microsoft Office\root\vfs\System*') -Filter 'sppc*.dll' -ErrorAction SilentlyContinue; " ^
  "  if ($sppcFiles) { $ohookFound = $true; foreach ($f in $sppcFiles) { Write-Host ('   [Ohook Tespit]    : ' + $f.FullName) -ForegroundColor Green } } " ^
  "}; " ^
  "if (-not $ohookFound) { Write-Host '   Ohook Durumu      : Sistemde ozel sppc.dll kancasi bulunamadi.' -ForegroundColor Gray }"

echo.
echo   !_Cyan!====================================================================================================!_Reset!
echo      !_Green![Tamamlandi]!_Reset! Raporu Masaustune kaydetmek icin !_Yellow![K]!_Reset!, Ana Menuye donmek icin !_White![M]!_Reset! tusuna basin.
echo   !_Cyan!====================================================================================================!_Reset!
echo.

if "%_unattended%"=="1" exit /b 0

choice /C:KM0 /N /M "   >> Seciminiz [K: Masaustune Rapor Kaydet | M / 0: Ana Menu]: "
set "_st_choice=%errorlevel%"

if %_st_choice%==1 (
    set "_repfile=%UserProfile%\Desktop\Lisans_Durum_Raporu.txt"
    echo.
    echo   !_Yellow![i] Rapor Masaustune kaydediliyor, lutfen bekleyin...!_Reset!
    cscript //nologo "%SysPath%\slmgr.vbs" /dlv > "!_repfile!" 2>&1
    echo   !_Green![+] Rapor basariyla kaydedildi:!_Reset! !_repfile!
    echo.
    pause
)
exit /b 0

:: ============================================================================
:: FAZ 3: GELISMIS SORUN GIDERME VE ONARIM MODULU (TROUBLESHOOT)
:: ============================================================================
:Mod_Troubleshoot
cls
if "%_unattended%"=="0" mode con cols=98 lines=34 >nul 2>&1
title Gelismis Sorun Giderme ve Sistem Onarim Araclari
echo.
echo   !_Cyan!==============================================================================================!_Reset!
echo      !_White!GELISMIS SORUN GIDERME VE LISANS ONARIM MERKEZI (TROUBLESHOOT)!_Reset!
echo      !_Gray!Lisans hatalarini, bozuk WMI havuzunu ve durmus sistem servislerini onarir.!_Reset!
echo   !_Cyan!==============================================================================================!_Reset!
echo.
echo       !_Green![1] Lisans ve Aktivasyon Depolarini Yeniden Olustur (Rebuild Licensing Tokens ^& Rearm)!_Reset!
echo           !_Gray!Bozuk tokens.dat, data.dat ve ClipSVC onbellegini sifirlayip yeniden olusturur.!_Reset!
echo.
echo       !_Green![2] Kritik Lisans Servislerini ve Izinlerini Onar (Fix sppsvc, ClipSVC, Winmgmt, wuauserv)!_Reset!
echo           !_Gray!Devre disi birakilmis veya kilitlenmis lisans servislerini varsayilana dondurur.!_Reset!
echo.
echo       !_Yellow![3] WMI Havuzunu Dogrula ve Onar (Repair / Salvage WMI Repository)!_Reset!
echo           !_Gray!Sorgu hatalarina yol acan bozuk WMI (Winmgmt) veritabanini onarir ve MOF derler.!_Reset!
echo.
echo       !_Yellow![4] KMS Kalintilarini, Gorev Zamanlayiciyi ve Ohook Kancalarini Temizle!_Reset!
echo           !_Gray!Eski KMS sunucu kayitlarini, yenileme gorevlerini ve ozel sppc.dll dosyalarini siler.!_Reset!
echo.
echo       !_Cyan![5] Sistem Dosyalarini ve Imajini Onar (DISM RestoreHealth + SFC /SCANNOW)!_Reset!
echo           !_Gray!Bozuk Windows sistem dosyalarini ve CBS bilesen deposunu denetler ve onarir.!_Reset!
echo.
echo       !_Red![0] Ana Menuye Don!_Reset!
echo.
echo   !_Cyan!==============================================================================================!_Reset!
echo.

choice /C:123450 /N /M "   >> Onarim islemini secin [1-5, Ana Menu icin 0]: "
set "_tb_erl=%errorlevel%"

if %_tb_erl%==6 exit /b 0
if %_tb_erl%==5 call :TB_SystemRepair & goto :Mod_Troubleshoot
if %_tb_erl%==4 call :TB_CleanKMSOhook & goto :Mod_Troubleshoot
if %_tb_erl%==3 call :TB_RepairWMI & goto :Mod_Troubleshoot
if %_tb_erl%==2 call :TB_FixServices & goto :Mod_Troubleshoot
if %_tb_erl%==1 call :TB_RebuildTokens & goto :Mod_Troubleshoot
goto :Mod_Troubleshoot

:TB_RebuildTokens
cls
echo.
echo   !_Cyan!=== [1] LISANS VE TOKEN DEPOLARI YENIDEN OLUSTURULUYOR ===!_Reset!
echo.
echo   !_Yellow![*] Yazilim Koruma Servisi (sppsvc) ve ClipSVC durduruluyor...!_Reset!
net stop sppsvc /y >nul 2>&1
net stop ClipSVC /y >nul 2>&1

set "_spp_store=%SystemRoot%\System32\spp\store"
if exist "%SystemRoot%\System32\spp\store\2.0" set "_spp_store=%SystemRoot%\System32\spp\store\2.0"

echo   !_Yellow![*] Eski tokens.dat ve cache.dat yedeklenip temizleniyor...!_Reset!
if exist "!_spp_store!\tokens.dat" (
    takeown /f "!_spp_store!\*" /a >nul 2>&1
    icacls "!_spp_store!\*" /grant administrators:F >nul 2>&1
    del /f /q "!_spp_store!\tokens.dat.bak" >nul 2>&1
    ren "!_spp_store!\tokens.dat" "tokens.dat.bak" >nul 2>&1
    if exist "!_spp_store!\cache\cache.dat" del /f /q "!_spp_store!\cache\cache.dat" >nul 2>&1
)

echo   !_Yellow![*] Servisler baslatiliyor ve lisans motoru tetikleniyor (slmgr /rilc)...!_Reset!
call :dk_start_service ClipSVC
call :dk_start_service sppsvc
cscript //nologo "%SysPath%\slmgr.vbs" /rilc >nul 2>&1

echo.
echo   !_Green![+] Lisans ve Token depolari basariyla yeniden olusturuldu.!_Reset!
echo.
pause
exit /b

:TB_FixServices
cls
echo.
echo   !_Cyan!=== [2] KRITIK LISANS SERVISLERI ONARILIYOR ===!_Reset!
echo.
for %%S in (RpcSs DcomLaunch sppsvc ClipSVC Winmgmt LicenseManager wuauserv KeyIso) do (
    echo   !_Gray![*] %%S servisi kontrol ediliyor ve yapilandiriliyor...!_Reset!
    sc config "%%S" start= demand >nul 2>&1
    if /i "%%S"=="RpcSs" sc config "%%S" start= auto >nul 2>&1
    if /i "%%S"=="DcomLaunch" sc config "%%S" start= auto >nul 2>&1
    if /i "%%S"=="Winmgmt" sc config "%%S" start= auto >nul 2>&1
    if /i "%%S"=="sppsvc" sc config "%%S" start= delayed-auto >nul 2>&1
    net start "%%S" /y >nul 2>&1
)
echo.
echo   !_Green![+] Tum kritik servisler basariyla yapilandirildi ve baslatildi.!_Reset!
echo.
pause
exit /b

:TB_RepairWMI
cls
echo.
echo   !_Cyan!=== [3] WMI HAVUZU DOGRULANIYOR VE ONARILIYOR ===!_Reset!
echo.
echo   !_Yellow![*] WMI Tutarlilik kontrolu yapiliyor (winmgmt /verifyrepository)...!_Reset!
winmgmt /verifyrepository
echo.
echo   !_Yellow![*] WMI Havuzu kurtarma islemi baslatiliyor (winmgmt /salvagerepository)...!_Reset!
net stop Winmgmt /y >nul 2>&1
winmgmt /salvagerepository
net start Winmgmt /y >nul 2>&1

echo   !_Yellow![*] SPPSVC ve Lisans MOF dosyalari yeniden kaydediliyor...!_Reset!
if exist "%SysPath%\wbem\sppwmi.mof" mofcomp "%SysPath%\wbem\sppwmi.mof" >nul 2>&1
set "_wmi_ok=1"
echo.
echo   !_Green![+] WMI Havuzu onarimi tamamlandi.!_Reset!
echo.
pause
exit /b

:TB_CleanKMSOhook
cls
echo.
echo   !_Cyan!=== [4] KMS KALINTILARI VE OHOOK KANCALARI TEMIZLENIYOR ===!_Reset!
echo.
echo   !_Yellow![*] KMS sunucu onbellegi ve port ayarlari temizleniyor...!_Reset!
cscript //nologo "%SysPath%\slmgr.vbs" /ckms >nul 2>&1
cscript //nologo "%SysPath%\slmgr.vbs" /cpky >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform" /v KeyManagementServiceName /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform" /v KeyManagementServicePort /f >nul 2>&1

echo   !_Yellow![*] Bilinen KMS zamanlanmis gorevleri kontrol edilip siliniyor...!_Reset!
schtasks /query /tn "Online_KMS_Activation_Script-Renewal" >nul 2>&1 && schtasks /delete /tn "Online_KMS_Activation_Script-Renewal" /f >nul 2>&1
schtasks /query /tn "Online_KMS_Activation_Script-Run_Once" >nul 2>&1 && schtasks /delete /tn "Online_KMS_Activation_Script-Run_Once" /f >nul 2>&1

echo   !_Yellow![*] Office vfs\System dizinlerindeki ozel Ohook (sppc.dll) kancalari kontrol ediliyor...!_Reset!
%psc% "$pfPaths = @($env:ProgramFiles, ${env:ProgramFiles(x86)}) | Where-Object { $_ } | Select-Object -Unique; foreach ($pf in $pfPaths) { foreach ($d in @('System', 'SystemX86')) { $v = Join-Path $pf ('Microsoft Office\root\vfs\' + $d); foreach ($f in @('sppc.dll', 'sppcs.dll')) { $fp = Join-Path $v $f; if (Test-Path $fp) { Write-Host ('   [-] Kaldiriliyor: ' + $fp) -ForegroundColor Red; Remove-Item -LiteralPath $fp -Force -ErrorAction SilentlyContinue } } } }"
reg delete "HKLM\SOFTWARE\Microsoft\Office\ClickToRun\Configuration" /v "OhookInstalled" /f >nul 2>&1
echo.
echo   !_Green![+] KMS ayarlari ve Ohook kancalari basariyla temizlendi.!_Reset!
echo.
pause
exit /b

:TB_SystemRepair
cls
echo.
echo   !_Cyan!=== [5] SISTEM DOSYALARI VE BILESEN DEPOSU ONARILIYOR (DISM ^& SFC) ===!_Reset!
echo.
echo   !_Yellow![1/2] DISM /Online /Cleanup-Image /RestoreHealth calistiriliyor (Bu islem birkac dakika surebilir)...!_Reset!
dism.exe /Online /Cleanup-Image /RestoreHealth
echo.
echo   !_Yellow![2/2] SFC /SCANNOW calistiriliyor...!_Reset!
sfc.exe /scannow
echo.
echo   !_Green![+] Sistem dosyalari tarama ve onarim islemi tamamlandi.!_Reset!
echo.
pause
exit /b

:: ============================================================================
:: FAZ 4A: WINDOWS SURUM DEGISTIRME MODULU (CHANGE WINDOWS EDITION)
:: ============================================================================
:Mod_ChangeWin
cls
if "%_unattended%"=="0" mode con cols=98 lines=36 >nul 2>&1
title Windows Surum Degistirme Araci [Mevcut: %edition_id%]

for /f "tokens=2*" %%a in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v EditionID 2^>nul') do set "edition_id=%%b"
set "edition_id=!edition_id: =!"

echo.
echo   !_Cyan!==============================================================================================!_Reset!
echo      !_White!WINDOWS SURUM DEGISTIRME MERKEZI (CBS / DISM / CHANGEPK)!_Reset!
echo      !_Gray!Mevcut Surum: %win_edition% [EditionID: %edition_id%] ^| Yapim: %winbuild%!_Reset!
echo   !_Cyan!==============================================================================================!_Reset!
echo.
echo   !_Yellow![*] Sisteminizden gecis yapilabilecek resmi hedef surumler (Target Editions) sorgulaniyor...!_Reset!
echo.

set "_ed_count=0"
for /f "tokens=4" %%E in ('dism /online /English /Get-TargetEditions 2^>nul ^| findstr /i /c:"Target Edition : "') do (
    set /a _ed_count+=1
    set "_target_!_ed_count!=%%E"
    call :Get_Edition_Key "%%E" _tkey
    echo       !_Green![!_ed_count!] %%E!_Reset! !_Gray![Genel Kurulum Anahtari: !_tkey!]!_Reset!
)

echo.
echo   !_White!Dogrudan Hizli Gecis Secenekleri (Genel CBS / Changepk Yontemi):!_Reset!
echo       !_Cyan![P] Professional!_Reset!               (VK7JG-NPHTM-C97JM-9MPGT-3V66T)
echo       !_Cyan![E] Enterprise!_Reset!                 (XGVPP-NMH47-7TTHJ-W3FW7-8HV2C)
echo       !_Cyan![I] IoT Enterprise!_Reset!             (XQQYW-NFFMW-XJPBH-K8732-CKFFD)
echo       !_Cyan![W] ProfessionalWorkstation!_Reset!    (DXG7C-N36C4-C4HTG-X4T3X-2YV77)
echo       !_Cyan![D] Education!_Reset!                  (YNMGQ-8RYV3-4PGQ3-C8XTP-7CFBY)
echo       !_Cyan![S] Enterprise LTSC 2021/2024!_Reset!  (NK96Y-D9CD8-W44CQ-R8YTK-DYJWX)
echo.
echo       !_Red![0] Ana Menuye Don!_Reset!
echo   !_Cyan!==============================================================================================!_Reset!
echo.

set "_win_sel="
set /p "_win_sel=   >> Hedef surum numarasini veya harfini girin [1-%_ed_count%, P/E/I/W/D/S, Cikis: 0]: "
if not defined _win_sel goto :Mod_ChangeWin
if "%_win_sel%"=="0" exit /b 0

set "_chosen_ed="
if /i "%_win_sel%"=="P" set "_chosen_ed=Professional"
if /i "%_win_sel%"=="E" set "_chosen_ed=Enterprise"
if /i "%_win_sel%"=="I" set "_chosen_ed=IoTEnterprise"
if /i "%_win_sel%"=="W" set "_chosen_ed=ProfessionalWorkstation"
if /i "%_win_sel%"=="D" set "_chosen_ed=Education"
if /i "%_win_sel%"=="S" set "_chosen_ed=EnterpriseS"

if not defined _chosen_ed (
    if defined _target_%_win_sel% (
        set "_chosen_ed=!_target_%_win_sel%!"
    )
)

if not defined _chosen_ed (
    echo.
    echo   !_Red![HATA] Gecersiz secim yaptiniz. Lutfen listeden bir secenek girin.!_Reset!
    timeout /t 2 >nul
    goto :Mod_ChangeWin
)

call :Get_Edition_Key "!_chosen_ed!" _upgrade_key
if not defined _upgrade_key (
    echo.
    echo   !_Red![HATA] !_chosen_ed! surumu icin uygun gecis anahtari bulunamadi.!_Reset!
    pause
    goto :Mod_ChangeWin
)

echo.
echo   !_Yellow!==============================================================================================!_Reset!
echo    Hedef Surum     : !_Green!!_chosen_ed!!_Reset!
echo    Kurulum Anahtari: !_White!!_upgrade_key!!_Reset!
echo   !_Yellow!==============================================================================================!_Reset!
echo.
echo   !_White!Gecis Yontemini Secin:!_Reset!
echo    !_Green![1] Standart DISM / Changepk Yontemi!_Reset! (Onerilen - Resmi CBS gecisi, yeniden baslatma gerekir)
echo    !_Cyan![2] Hizli SLMGR Anahtar Enjeksiyonu!_Reset!  (Ayni cekirdek ailesi icinde aninda gecis - Orn: Pro -^> Ent)
echo    !_Red![0] Iptal!_Reset!
echo.
choice /C:120 /N /M "   >> Yontem seciminiz [1, 2 veya 0]: "
set "_up_meth=%errorlevel%"
if %_up_meth%==3 goto :Mod_ChangeWin

if %_up_meth%==2 (
    echo.
    echo   !_Yellow![*] Urun anahtari slmgr.vbs /ipk ile sisteme yukleniyor...!_Reset!
    cscript //nologo "%SysPath%\slmgr.vbs" /ipk !_upgrade_key!
    echo.
    echo   !_Green![+] Anahtar islemi tamamlandi. Yeni surumu Ana Menuden veya Durum Kontrolunden dogrulayabilirsiniz.!_Reset!
    pause
    exit /b 0
)

if %_up_meth%==1 (
    echo.
    echo   !_Yellow![*] DISM /Set-Edition veya Changepk ile surum yukseltmesi baslatiliyor...!_Reset!
    echo   !_Gray!Not: Islem sirasinda ekran %%100 seviyesine geldiginde sistem yeniden baslatma isteyebilir.!_Reset!
    echo.
    dism /online /Set-Edition:!_chosen_ed! /ProductKey:!_upgrade_key! /NoRestart
    if !errorlevel! neq 0 if !errorlevel! neq 3010 (
        echo.
        echo   !_Yellow![i] DISM dogrudan gecisi desteklemedi, Changepk.exe motoru devreye aliniyor...!_Reset!
        changepk.exe /ProductKey !_upgrade_key!
    ) else (
        echo.
        echo   !_Green![+] Surum gecis paketi basariyla uygulandi. Degisikligin tamamlanmasi icin bilgisayari yeniden baslatin.!_Reset!
    )
    echo.
    pause
    exit /b 0
)
goto :Mod_ChangeWin

:: ============================================================================
:: FAZ 4B: OFFICE SURUM VE KANAL DEGISTIRME MODULU (CHANGE OFFICE EDITION)
:: ============================================================================
:Mod_ChangeOffice
cls
if "%_unattended%"=="0" mode con cols=102 lines=36 >nul 2>&1
title Microsoft Office C2R Surum ve Kanal Yonetimi

set "_c2r_reg=HKLM\SOFTWARE\Microsoft\Office\ClickToRun\Configuration"
set "_c2r_ver=Bulunamadi"
set "_c2r_prods=Bulunamadi"
set "_c2r_cdn=Bulunamadi"
set "_c2r_plat=x64"

reg query "%_c2r_reg%" >nul 2>&1 && goto :C2R_Installed
echo.
echo   !_Red!==============================================================================================!_Reset!
echo      !_White![HATA] Sistemde Microsoft Office Click-to-Run [C2R] kurulumu tespit edilemedi.!_Reset!
echo      !_Gray!Bu modul yalnizca Office 2016 / 2019 / 2021 / 2024 / 365 C2R kurulumlari icindir.!_Reset!
echo   !_Red!==============================================================================================!_Reset!
echo.
pause
exit /b 0

:C2R_Installed
for /f "tokens=2*" %%a in ('reg query "%_c2r_reg%" /v VersionToReport 2^>nul') do set "_c2r_ver=%%b"
for /f "tokens=2*" %%a in ('reg query "%_c2r_reg%" /v ProductReleaseIds 2^>nul') do set "_c2r_prods=%%b"
for /f "tokens=2*" %%a in ('reg query "%_c2r_reg%" /v CDNBaseUrl 2^>nul') do set "_c2r_cdn=%%b"
for /f "tokens=2*" %%a in ('reg query "%_c2r_reg%" /v Platform 2^>nul') do set "_c2r_plat=%%b"

echo.
echo   !_Cyan!==================================================================================================!_Reset!
echo      !_White!MICROSOFT OFFICE (C2R) SURUM VE GUNCELLEME KANALI YONETIMI!_Reset!
echo      !_Gray!Mevcut Surum: %_c2r_ver% [%_c2r_plat%] ^| Yuklu Urunler: %_c2r_prods%!_Reset!
echo      !_Gray!Mevcut CDN  : %_c2r_cdn%!_Reset!
echo   !_Cyan!==================================================================================================!_Reset!
echo.
echo      !_White![A] Guncelleme Kanalini (Update Channel) Degistir:!_Reset!
echo       !_Green![1] Current (Retail / Perakende)!_Reset!         - En guncel ozellik guncellemeleri
echo       !_Green![2] Monthly Enterprise (Aylik Kurumsal)!_Reset!  - Ayda bir kararli ozellik ve guvenlik
echo       !_Green![3] Semi-Annual (6 Aylik Kurumsal)!_Reset!       - Maksimum kararlilik (Yilda 2 kez)
echo       !_Green![4] PerpetualVL2021 (Office LTSC 2021)!_Reset!   - Office 2021 Volume resmi kanali
echo       !_Green![5] PerpetualVL2024 (Office LTSC 2024)!_Reset!   - Office 2024 Volume resmi kanali
echo.
echo      !_White![B] Office Urun / Lisans Kimligi (ProductReleaseId) Ekle veya Degistir:!_Reset!
echo       !_Cyan![6] ProPlus2024Volume Ekle/Donustur!_Reset!      - Office LTSC Professional Plus 2024
echo       !_Cyan![7] ProPlus2021Volume Ekle/Donustur!_Reset!      - Office LTSC Professional Plus 2021
echo       !_Cyan![8] O365ProPlusRetail Ekle/Donustur!_Reset!      - Microsoft 365 Apps for Enterprise
echo       !_Cyan![9] MondoVolume (Tum Office Paketleri)!_Reset!   - Project, Visio ve tum yetkileri iceren paket
echo.
echo       !_Red![0] Ana Menuye Don!_Reset!
echo   !_Cyan!==================================================================================================!_Reset!
echo.

choice /C:1234567890 /N /M "   >> Seciminizi yapin [1-9, Ana Menu icin 0]: "
set "_off_erl=%errorlevel%"

if %_off_erl%==10 exit /b 0

set "_new_cdn="
if %_off_erl%==1 set "_new_cdn=http://officecdn.microsoft.com/pr/492350f6-3a01-4f97-b9c0-c7c6ddf67d60"
if %_off_erl%==2 set "_new_cdn=http://officecdn.microsoft.com/pr/55336b82-a18d-4dd6-b5f6-9e5095c314a6"
if %_off_erl%==3 set "_new_cdn=http://officecdn.microsoft.com/pr/7ffbc6bf-bc32-4f92-8982-f9dd17fd3114"
if %_off_erl%==4 set "_new_cdn=http://officecdn.microsoft.com/pr/f2e724c1-748f-4b47-8fb8-8e0d210e9208"
if %_off_erl%==5 set "_new_cdn=http://officecdn.microsoft.com/pr/7983bac0-e531-40cf-be00-fd24fe66619c"

if defined _new_cdn (
    echo.
    echo   !_Yellow![*] Office C2R Guncelleme Kanali yapilandiriliyor...!_Reset!
    reg add "%_c2r_reg%" /v CDNBaseUrl /t REG_SZ /d "!_new_cdn!" /f >nul 2>&1
    reg add "%_c2r_reg%" /v UpdateChannel /t REG_SZ /d "!_new_cdn!" /f >nul 2>&1
    reg delete "%_c2r_reg%" /v UpdateUrl /f >nul 2>&1
    reg delete "HKLM\SOFTWARE\Policies\Microsoft\office\16.0\common\officeupdate" /v updatebranch /f >nul 2>&1
    echo   !_Yellow![*] OfficeC2RClient ile kanal senkronizasyonu tetikleniyor...!_Reset!
    if exist "%CommonProgramFiles%\microsoft shared\ClickToRun\OfficeC2RClient.exe" (
        "%CommonProgramFiles%\microsoft shared\ClickToRun\OfficeC2RClient.exe" /changesetting Channel=!_new_cdn! >nul 2>&1
        "%CommonProgramFiles%\microsoft shared\ClickToRun\OfficeC2RClient.exe" /update user >nul 2>&1
    )
    echo   !_Green![+] Guncelleme kanali basariyla degistirildi ve Office guncelleyici baslatildi.!_Reset!
    echo.
    pause
    goto :Mod_ChangeOffice
)

set "_add_prod="
if %_off_erl%==6 set "_add_prod=ProPlus2024Volume"
if %_off_erl%==7 set "_add_prod=ProPlus2021Volume"
if %_off_erl%==8 set "_add_prod=O365ProPlusRetail"
if %_off_erl%==9 set "_add_prod=MondoVolume"

if defined _add_prod (
    echo.
    echo   !_Yellow![*] ProductReleaseIds kaydina !_add_prod! ekleniyor...!_Reset!
    echo "%_c2r_prods%" | find /i "!_add_prod!" >nul 2>&1
    if errorlevel 1 (
        set "_updated_prods=%_c2r_prods%,!_add_prod!"
        reg add "%_c2r_reg%" /v ProductReleaseIds /t REG_SZ /d "!_updated_prods!" /f >nul 2>&1
    )
    echo   !_Green![+] Office urun kimligi [!_add_prod!] kayit defterine basariyla islendi.!_Reset!
    echo   !_Gray!Not: Ilgili urun lisansini aktif etmek icin Ana Menudeki Ohook [2] veya KMS [4] modulunu kullanabilirsiniz.!_Reset!
    echo.
    pause
    goto :Mod_ChangeOffice
)
goto :Mod_ChangeOffice

:: ============================================================================
:: FAZ 5A: HWID (DIJITAL LISANS VE DONANIM KIMLIGI YONETIM MODULU)
:: ============================================================================
:Mod_HWID
cls
if "%_unattended%"=="0" mode con cols=98 lines=32 >nul 2>&1
title HWID Dijital Lisans Yonetim Modulu [Surum: %edition_id%]

echo.
echo   !_Cyan!==============================================================================================!_Reset!
echo      !_White!HWID (WINDOWS 10 / 11 KALICI DIJITAL LISANS VE CLIPSVC YONETIMI)!_Reset!
echo      !_Gray!Mevcut Surum: %win_edition% [%edition_id%] ^| Mimari: %os_arch% ^| Yapim: %winbuild%!_Reset!
echo   !_Cyan!==============================================================================================!_Reset!
echo.
if %winbuild% LSS 10240 (
    echo   !_Red![HATA] HWID Dijital Lisans mimarisi yalnizca Windows 10 ve Windows 11 [Build 10240+] destekler.!_Reset!
    echo.
    pause
    exit /b 1
)
echo       !_Green![1] HWID Kalici Dijital Lisans Etkinlestirmesini Baslat (Tam Otomatik Motor)!_Reset!
echo       !_Cyan![2] Sadece Varsayilan Genel Retail/OEM Anahtarini Yukle (Install Default Key Only)!_Reset!
echo       !_Yellow![3] BIOS/UEFI Gomulu Orijinal OEM Anahtarini (OA3x) Algila ve Etkinlestir!_Reset!
echo       !_Red![0] Ana Menuye Don!_Reset!
echo.
echo   !_Cyan!==============================================================================================!_Reset!
echo.

choice /C:1230 /N /M "   >> Seciminiz [1-3, Ana Menu icin 0]: "
set "_hw_erl=%errorlevel%"
if %_hw_erl%==4 exit /b 0
if %_hw_erl%==3 call :HWID_ApplyOEM & goto :Mod_HWID
if %_hw_erl%==2 call :HWID_KeyOnly & goto :Mod_HWID
if %_hw_erl%==1 call :HWID_Run & goto :Mod_HWID
goto :Mod_HWID

:HWID_KeyOnly
echo.
call :Get_Edition_Key "%edition_id%" _hwid_key
if not defined _hwid_key (
    echo   !_Red![HATA] %edition_id% surumu icin varsayilan HWID anahtari tablosunda eslesme bulunamadi.!_Reset!
    if "%_unattended%"=="0" pause
    exit /b 1
)
echo   !_Yellow![*] %edition_id% icin genel anahtar yukleniyor: !_hwid_key!...!_Reset!
cscript //nologo "%SysPath%\slmgr.vbs" /ipk !_hwid_key!
if "%_unattended%"=="0" pause
exit /b 0

:HWID_ApplyOEM
echo.
echo   !_Yellow![*] Anakart BIOS/UEFI MSDM tablosundan OA3x anahtari sorgulaniyor...!_Reset!
%psc% "$k = (Get-CimInstance -ClassName SoftwareLicensingService -ErrorAction SilentlyContinue).OA3xOriginalProductKey; if ($k) { Write-Host ('   [+] BIOS OEM Anahtari bulundu: ' + $k) -ForegroundColor Green; cscript.exe //nologo \"$env:SysPath\slmgr.vbs\" /ipk $k; cscript.exe //nologo \"$env:SysPath\slmgr.vbs\" /ato } else { Write-Host '   [HATA] Anakart uzerinde gomulu bir OEM anahtari bulunamadi.' -ForegroundColor Red }"
echo.
if "%_unattended%"=="0" pause
exit /b 0

:HWID_Run
echo.
echo   !_Cyan!=== HWID KALICI DIJITAL LISANS YAPILANDIRMASI BASLATILIYOR ===!_Reset!
echo.
echo   !_Yellow![1/4] Kritik lisans ve kimlik dogrulama servisleri baslatiliyor...!_Reset!
for %%S in (ClipSVC sppsvc wuauserv LicenseManager Winmgmt) do (
    call :dk_start_service %%S >nul 2>&1
)
sc query wuauserv | find /i "RUNNING" >nul 2>&1
if errorlevel 1 echo   !_Red![UYARI] Windows Update [wuauserv] servisi baslatilamadi. Dijital lisans dogrulamasi icin gereklidir.!_Reset!

echo   !_Yellow![2/4] Sistemdeki eski KMS sunucu kilitleri temizleniyor...!_Reset!
cscript //nologo "%SysPath%\slmgr.vbs" /ckms >nul 2>&1

call :Get_Edition_Key "%edition_id%" _hwid_key
if not defined _hwid_key (
    echo   !_Red![HATA] Mevcut Windows surumu [%edition_id%] HWID anahtar tablosunda bulunamadi.!_Reset!
    if "%_unattended%"=="0" pause
    exit /b 1
)
echo   !_Yellow![3/4] %edition_id% genel urun anahtari [!_hwid_key!] yukleniyor...!_Reset!
cscript //nologo "%SysPath%\slmgr.vbs" /ipk !_hwid_key!

echo   !_Yellow![4/4] Microsoft Dijital Lisans sunuculari ve Bilet Motoru kontrol ediliyor...!_Reset!
cscript //nologo "%SysPath%\slmgr.vbs" /ato >nul 2>&1
call :dk_check_perm_win
if "!_win_perm_ok!"=="1" (
    echo.
    echo   !_Green![BASARILI] Windows zaten anakartta kayitli Dijital Lisans ile Kalici olarak etkinlestirildi.!_Reset!
    echo.
    if "%_unattended%"=="0" pause
    exit /b 0
)

set "_local_hwid="
if exist "%_work%\HWID_Activation.cmd" set "_local_hwid=%_work%\HWID_Activation.cmd"
if not defined _local_hwid if exist "%_work%\Activators\HWID_Activation.cmd" set "_local_hwid=%_work%\Activators\HWID_Activation.cmd"
if not defined _local_hwid if exist "%_work%\Separate-Files-Version\Activators\HWID_Activation.cmd" set "_local_hwid=%_work%\Separate-Files-Version\Activators\HWID_Activation.cmd"
if not defined _local_hwid if exist "%_work%\MAS\Separate-Files-Version\Activators\HWID_Activation.cmd" set "_local_hwid=%_work%\MAS\Separate-Files-Version\Activators\HWID_Activation.cmd"

if defined _local_hwid (
    echo   !_Cyan![i] Yerel HWID_Activation.cmd modulu tespit edildi, izole alt islemde calistiriliyor...!_Reset!
    "%ComSpec%" /c ""!_local_hwid!" /HWID"
    call :dk_check_perm_win
    if "!_win_perm_ok!"=="1" echo   !_Green![BASARILI] Windows Kalici Dijital Lisans [Permanent] ile etkinlestirildi.!_Reset!
    if "%_unattended%"=="0" pause
    exit /b 0
)

set "_gt_dir=%ProgramData%\Microsoft\Windows\ClipSVC\GenuineTicket"
if not exist "!_gt_dir!" mkdir "!_gt_dir!" >nul 2>&1
call :dk_extract_b64 "GENUINETICKET_XML" "!_gt_dir!\GenuineTicket.xml" >nul 2>&1
if exist "!_gt_dir!\*.xml" (
    echo   !_Green![+] GenuineTicket XML bileti bulundu, ClipUp.exe -v -o uygulaniyor...!_Reset!
    clipup.exe -v -o >nul 2>&1
    cscript //nologo "%SysPath%\slmgr.vbs" /ato >nul 2>&1
)

call :dk_check_perm_win
if "!_win_perm_ok!"=="1" (
    echo.
    echo   !_Green![BASARILI] Windows Kalici Dijital Lisans [Permanent] ile etkinlestirildi.!_Reset!
    echo.
    if "%_unattended%"=="0" pause
    exit /b 0
)

call :dk_invoke_core_engine "/HWID"
call :dk_check_perm_win
if "!_win_perm_ok!"=="1" (
    echo.
    echo   !_Green![BASARILI] Windows Kalici Dijital Lisans [Permanent] ile etkinlestirildi.!_Reset!
) else (
    echo.
    echo   !_Yellow![UYARI] HWID islemi tamamlandi ancak kalici lisans dogrulanamadi. [3] TSforge veya [4] Online KMS deneyin.!_Reset!
)
echo.
if "%_unattended%"=="0" pause
exit /b 0

:: ============================================================================
:: FAZ 5B: OHOOK (MICROSOFT OFFICE YEREL SPPC YAPILANDIRMA MODULU)
:: ============================================================================
:Mod_Ohook
cls
if "%_unattended%"=="0" mode con cols=98 lines=34 >nul 2>&1
title Ohook Microsoft Office Yonetim Modulu

echo.
echo   !_Cyan!==============================================================================================!_Reset!
echo      !_White!OHOOK (MICROSOFT OFFICE YEREL SPPC KANCASI VE GVLK YONETIMI)!_Reset!
echo      !_Gray!Office C2R kurulumlarinda yerel sppc.dll sembolik bagi ve Volume GVLK anahtari yapilandirir.!_Reset!
echo   !_Cyan!==============================================================================================!_Reset!
echo.
echo       !_Green![1] Ohook Kalici Office Etkinlestirmesini ve GVLK Anahtarlarini Kur!_Reset!
echo       !_Yellow![2] Sadece Yuklu Office Urunleri Icin GVLK Anahtarlarini Yukle (DLL Dokunmadan)!_Reset!
echo       !_Red![3] Ohook Kancasini (sppc.dll / sppcs.dll) Sistemden Tamamen Kaldir!_Reset!
echo       !_Red![0] Ana Menuye Don!_Reset!
echo.
echo   !_Cyan!==============================================================================================!_Reset!
echo.

choice /C:1230 /N /M "   >> Seciminiz [1-3, Ana Menu icin 0]: "
set "_oh_erl=%errorlevel%"
if %_oh_erl%==4 exit /b 0
if %_oh_erl%==3 call :TB_CleanKMSOhook & goto :Mod_Ohook
if %_oh_erl%==2 call :Ohook_KeysOnly & goto :Mod_Ohook
if %_oh_erl%==1 call :Ohook_Install & goto :Mod_Ohook
goto :Mod_Ohook

:Ohook_KeysOnly
echo.
echo   !_Yellow![*] Yuklu Office Click-to-Run urunleri taranip uygun GVLK anahtarlari yukleniyor...!_Reset!
set "_c2r_reg=HKLM\SOFTWARE\Microsoft\Office\ClickToRun\Configuration"
set "_c2r_prods="
for /f "tokens=2*" %%a in ('reg query "%_c2r_reg%" /v ProductReleaseIds 2^>nul') do set "_c2r_prods=%%b"
if not defined _c2r_prods (
    echo   !_Red![HATA] Sistemde Office Click-to-Run ProductReleaseIds kaydi bulunamadi.!_Reset!
    if "%_unattended%"=="0" pause
    exit /b 1
)
for %%I in (ProPlus2024Volume Standard2024Volume ProjectPro2024Volume VisioPro2024Volume ProPlus2021Volume Standard2021Volume ProjectPro2021Volume VisioPro2021Volume ProPlus2019Volume Standard2019Volume ProjectPro2019Volume VisioPro2019Volume MondoVolume) do (
    echo "%_c2r_prods%" | find /i "%%I" >nul 2>&1 && (
        call :Get_Office_GVLK "%%I" _ok
        if defined _ok (
            echo   !_Green![+] %%I tespit edildi, GVLK yukleniyor: !_ok!!_Reset!
            cscript //nologo "%SysPath%\slmgr.vbs" /ipk !_ok! >nul 2>&1
        )
    )
)
echo   !_Green![+] Office GVLK anahtar kurulumu tamamlandi.!_Reset!
if "%_unattended%"=="0" pause
exit /b 0

:Ohook_Install
echo.
echo   !_Cyan!=== OHOOK OFFICE YAPILANDIRMASI BASLATILIYOR ===!_Reset!
echo.
call :dk_invoke_core_engine "/Ohook"
echo.
if "%_unattended%"=="0" pause
exit /b 0

:: ============================================================================
:: FAZ 5C: TSFORGE (GUVENILIR DEPOLAMA / ESU / PHYSICAL STORE YONETIMI)
:: ============================================================================
:Mod_TSforge
cls
if "%_unattended%"=="0" mode con cols=98 lines=34 >nul 2>&1
title TSforge Guvenilir Depolama ve ESU Yonetim Modulu

echo.
echo   !_Cyan!==============================================================================================!_Reset!
echo      !_White!TSFORGE (TRUSTED STORAGE / PHYSICAL STORE ^& ESU YONETIM MODULU)!_Reset!
echo      !_Gray!SPP Physical Store (data.dat / tokens.dat) analizi, yedeklemesi ve ESU/Lisans dogrulamasi.!_Reset!
echo   !_Cyan!==============================================================================================!_Reset!
echo.
echo       !_Green![1] TSforge Windows / ESU Kalici Etkinlestirmesini Calistir!_Reset!
echo       !_Green![2] TSforge Office Kalici Etkinlestirmesini Calistir!_Reset!
echo       !_Cyan![3] SPP Trusted Store (data.dat ^& tokens.dat) Yedegini Al (Masaustune Yedekle)!_Reset!
echo       !_Yellow![4] SPP Trusted Store Yedegini Geri Yukle (Restore Backup)!_Reset!
echo       !_Red![0] Ana Menuye Don!_Reset!
echo.
echo   !_Cyan!==============================================================================================!_Reset!
echo.

choice /C:12340 /N /M "   >> Seciminiz [1-4, Ana Menu icin 0]: "
set "_ts_erl=%errorlevel%"
if %_ts_erl%==5 exit /b 0
if %_ts_erl%==4 call :TSforge_Restore & goto :Mod_TSforge
if %_ts_erl%==3 call :TSforge_Backup & goto :Mod_TSforge
if %_ts_erl%==2 call :TSforge_Run_Off & goto :Mod_TSforge
if %_ts_erl%==1 call :TSforge_Run_Win & goto :Mod_TSforge
goto :Mod_TSforge

:TSforge_Run_Win
echo.
call :dk_invoke_core_engine "/Z-Windows"
if "%_unattended%"=="0" pause
exit /b 0

:TSforge_Run_Off
echo.
call :dk_invoke_core_engine "/Z-Office"
if "%_unattended%"=="0" pause
exit /b 0

:TSforge_Backup
echo.
set "_spp_store=%SystemRoot%\System32\spp\store\2.0"
if not exist "!_spp_store!" set "_spp_store=%SystemRoot%\System32\spp\store"
set "_bk_dir=%UserProfile%\Desktop\SPP_TrustedStore_Backup"
if not exist "!_bk_dir!" mkdir "!_bk_dir!" >nul 2>&1
echo   !_Yellow![*] sppsvc durduruluyor ve data.dat / tokens.dat Masaustune yedekleniyor...!_Reset!
net stop sppsvc /y >nul 2>&1
xcopy "!_spp_store!\*" "!_bk_dir!\" /E /H /C /I /Y >nul 2>&1
net start sppsvc /y >nul 2>&1
echo   !_Green![+] Trusted Store yedegi basariyla alindi: !_bk_dir!!_Reset!
echo.
pause
exit /b 0

:TSforge_Restore
echo.
set "_spp_store=%SystemRoot%\System32\spp\store\2.0"
if not exist "!_spp_store!" set "_spp_store=%SystemRoot%\System32\spp\store"
set "_bk_dir=%UserProfile%\Desktop\SPP_TrustedStore_Backup"
if not exist "!_bk_dir!\tokens.dat" (
    echo   !_Red![HATA] Masaustunde SPP_TrustedStore_Backup klasorunde gecerli bir yedek bulunamadi.!_Reset!
    pause
    exit /b 1
)
echo   !_Yellow![*] Yedek geri yukleniyor...!_Reset!
net stop sppsvc /y >nul 2>&1
xcopy "!_bk_dir!\*" "!_spp_store!\" /E /H /C /I /Y >nul 2>&1
net start sppsvc /y >nul 2>&1
cscript //nologo "%SysPath%\slmgr.vbs" /rilc >nul 2>&1
echo   !_Green![+] Trusted Store yedegi basariyla geri yuklendi.!_Reset!
echo.
pause
exit /b 0

:: ============================================================================
:: FAZ 5D: ONLINE KMS (180 GUN + OTOMATIK FAILOVER + GOREV ZAMANLAYICI)
:: ============================================================================
:Mod_OnlineKMS
cls
if "%_unattended%"=="0" mode con cols=100 lines=36 >nul 2>&1
title Online KMS Lisans ve Gorev Zamanlayici Yonetimi

echo.
echo   !_Cyan!================================================================================================!_Reset!
echo      !_White!ONLINE KMS YONETIMI (WINDOWS ^& OFFICE 180 GUN + OTOMATIK FAILOVER)!_Reset!
echo      !_Gray!Sistem: %win_edition% [%edition_id%] ^| Port: 1688 ^| 8 Sunuculu Otomatik Yedekli KMS Havuzu!_Reset!
echo   !_Cyan!================================================================================================!_Reset!
echo.
echo       !_Green![1] Windows ve Office Icin Online KMS Etkinlestir (Hepsi Bir Arada)!_Reset!
echo       !_Green![2] Sadece Windows Icin Online KMS Etkinlestir!_Reset!
echo       !_Green![3] Sadece Microsoft Office Icin Online KMS Etkinlestir!_Reset!
echo.
echo       !_Cyan![4] Otomatik Yenileme Gorevi Olustur (Gorev Zamanlayici - Her Hafta Otomatik Yeniler)!_Reset!
echo       !_Yellow![5] Ozel KMS Sunucu Adresi Belirle ve Baglanti Testi Yap (Port 1688 TCP Test)!_Reset!
echo       !_Red![6] KMS Yapilandirmasini ve Yenileme Gorevlerini Tamamen Kaldir (Uninstall KMS)!_Reset!
echo.
echo       !_Red![0] Ana Menuye Don!_Reset!
echo.
echo   !_Cyan!================================================================================================!_Reset!
echo.

choice /C:1234560 /N /M "   >> Seciminiz [1-6, Ana Menu icin 0]: "
set "_kms_erl=%errorlevel%"
if %_kms_erl%==7 exit /b 0
if %_kms_erl%==6 call :TB_CleanKMSOhook & goto :Mod_OnlineKMS
if %_kms_erl%==5 call :KMS_CustomHost & goto :Mod_OnlineKMS
if %_kms_erl%==4 call :KMS_InstallTask & goto :Mod_OnlineKMS
if %_kms_erl%==3 call :KMS_Act_Off & goto :Mod_OnlineKMS
if %_kms_erl%==2 call :KMS_Act_Win & goto :Mod_OnlineKMS
if %_kms_erl%==1 call :KMS_Act_All & goto :Mod_OnlineKMS
goto :Mod_OnlineKMS

:KMS_Act_Win
echo.
echo   !_Cyan!=== WINDOWS ONLINE KMS ETKINLESTIRME BASLATILIYOR ===!_Reset!
call :dk_start_service sppsvc >nul 2>&1
call :dk_start_service wuauserv >nul 2>&1

for /f "tokens=2*" %%a in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v EditionID 2^>nul') do set "edition_id=%%b"
set "edition_id=!edition_id: =!"

if /i "%edition_id%"=="IoTEnterprise" (
    echo   !_Yellow![i] IoTEnterprise surumu KMS desteklemedigi icin KMS uyumlu Enterprise anahtari yukleniyor...!_Reset!
)

call :Get_GVLK_Key "%edition_id%" _win_gvlk
if not defined _win_gvlk (
    echo   !_Red![HATA] Mevcut Windows surumu [%edition_id%] KMS GVLK tablosunda bulunamadi.!_Reset!
    echo   !_Yellow![i] Lutfen Ana Menuden [1] HWID veya [3] TSforge modullerini kullanin.!_Reset!
    if "%_unattended%"=="0" pause
    exit /b 1
)

echo   !_Yellow![1/3] %edition_id% KMS Istemci Anahtari [GVLK] yukleniyor: !_win_gvlk!...!_Reset!
cscript //nologo "%SysPath%\slmgr.vbs" /ipk !_win_gvlk!

set "_kms_list=kms.loli.best kms.03k.org kms8.MSGuides.com kms9.MSGuides.com kms.sixyin.com kms.loli.beer kms.cangshui.net kms.cin.org.cn"
if defined _custom_kms_host set "_kms_list=%_custom_kms_host%"

set "_kms_win_success=0"
echo   !_Yellow![2/3] KMS sunucu havuzu uzerinden etkinlestirme deneniyor...!_Reset!
for %%H in (!_kms_list!) do (
    if "!_kms_win_success!"=="0" (
        echo.
        echo   !_Cyan![*] Denenen KMS Sunucusu: %%H:1688!_Reset!
        cscript //nologo "%SysPath%\slmgr.vbs" /skms %%H:1688
        cscript //nologo "%SysPath%\slmgr.vbs" /ato
        call :dk_check_act_win
        if "!_win_act_ok!"=="1" (
            set "_kms_win_success=1"
            set "_alive_kms=%%H"
            echo.
            echo   !_Green![BASARILI] Windows, %%H sunucusu uzerinden 180 Gunluk KMS ile etkinlestirildi.!_Reset!
        ) else (
            echo   !_Yellow![-] %%H yanit vermedi, siradaki yedek sunucuya geciliyor...!_Reset!
        )
    )
)

if "!_kms_win_success!"=="0" (
    echo.
    echo   !_Red![HATA] KMS sunucularina Port 1688 uzerinden ulasilamadi [ISP veya Guvenlik Duvari engeli olabilir].!_Reset!
    echo   !_Yellow![i] Port 1688 gerektirmeyen [1] HWID veya [3] TSforge modullerini kullanmaniz onerilir.!_Reset!
)
echo.
if "%_unattended%"=="0" pause
exit /b 0

:KMS_Act_Off
echo.
echo   !_Cyan!=== MICROSOFT OFFICE ONLINE KMS ETKINLESTIRME BASLATILIYOR ===!_Reset!
call :dk_start_service sppsvc >nul 2>&1
call :Ohook_KeysOnly
set "_kms_off_host=kms.loli.best"
if defined _alive_kms set "_kms_off_host=!_alive_kms!"
if defined _custom_kms_host set "_kms_off_host=%_custom_kms_host%"

echo   !_Yellow![*] KMS sunucu adresi [!_kms_off_host!] kayit defterine ve SPP havuzuna isleniyor...!_Reset!
cscript //nologo "%SysPath%\slmgr.vbs" /skms !_kms_off_host!:1688 >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform" /v KeyManagementServiceName /t REG_SZ /d "!_kms_off_host!" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform" /v KeyManagementServicePort /t REG_SZ /d "1688" /f >nul 2>&1

echo   !_Yellow![*] Tum yuklu Office Volume urunleri etkinlestiriliyor...!_Reset!
%psc% "$off = Get-CimInstance SoftwareLicensingProduct | Where-Object {$_.PartialProductKey -and $_.ApplicationID -eq '0ff1ce15-a989-479d-af46-f275c6370663'}; if (-not $off) { Write-Host '   [-] Yuklu Office Volume GVLK urunu bulunamadi.' -ForegroundColor Red } else { foreach ($o in $off) { Write-Host ('   [*] Etkinlestiriliyor: ' + $o.Name) -ForegroundColor Cyan; try { Invoke-CimMethod -InputObject $o -MethodName Activate | Out-Null; $u = Get-CimInstance SoftwareLicensingProduct | Where-Object { $_.ID -eq $o.ID }; if ($u.LicenseStatus -eq 1) { Write-Host '      [+] Basariyla Etkinlestirildi (180 Gun).' -ForegroundColor Green } else { Write-Host ('      [i] Durum Kodu: ' + $u.LicenseStatus) -ForegroundColor Yellow } } catch { Write-Host '      [-] KMS sunucu baglanti hatasi.' -ForegroundColor Red } } }"
echo.
if "%_unattended%"=="0" pause
exit /b 0

:KMS_Act_All
call :KMS_Act_Win
call :KMS_Act_Off
exit /b 0

:KMS_InstallTask
echo.
echo   !_Cyan!=== KMS OTOMATIK YENILEME GOREVI (SCHEDULED TASK) KURULUYOR ===!_Reset!
set "_kms_dir=%ProgramData%\UET_KMS_Renewal"
if not exist "!_kms_dir!" mkdir "!_kms_dir!" >nul 2>&1
copy /y "%_cmdf%" "!_kms_dir!\UET_KMS_Renew.cmd" >nul 2>&1
schtasks /delete /tn "Online_KMS_Activation_Script-Renewal" /f >nul 2>&1
schtasks /create /tn "Online_KMS_Activation_Script-Renewal" /tr "'!_kms_dir!\UET_KMS_Renew.cmd' /KMS /S" /sc WEEKLY /d SUN /st 12:00 /ru "SYSTEM" /rl HIGHEST /f >nul 2>&1
if !errorlevel! equ 0 (
    echo   !_Green![+] Gorev Zamanlayici kaydi basariyla olusturuldu:!_Reset!
    echo   !_Gray!    Gorev Adi : Online_KMS_Activation_Script-Renewal!_Reset!
    echo   !_Gray!    Periyot   : Her Hafta Pazar 12:00 [SYSTEM Yetkisiyle Katilimsiz]!_Reset!
) else (
    echo   !_Red![HATA] Gorev Zamanlayici olusturulurken hata meydana geldi.!_Reset!
)
echo.
if "%_unattended%"=="0" pause
exit /b 0

:KMS_CustomHost
echo.
set "_custom_kms_host="
set /p "_custom_kms_host=   >> Ozel KMS Sunucu Adresi veya IP girin (Varsayilan havuz icin bos birakin): "
if not defined _custom_kms_host (
    echo   !_Yellow![i] Ozel sunucu sifirlandi, otomatik KMS havuzu kullanilacak.!_Reset!
    pause
    exit /b 0
)
echo   !_Yellow![*] !_custom_kms_host!:1688 TCP baglantisi test ediliyor...!_Reset!
%psc% "$t = New-Object Net.Sockets.TcpClient; try { $c = $t.BeginConnect($env:_custom_kms_host, 1688, $null, $null); $w = $c.AsyncWaitHandle.WaitOne(2500, $false); if ($w -and $t.Connected) { $t.Close(); Write-Host '   [+] Sunucu ERISILEBILIR (Port 1688 Acik).' -ForegroundColor Green } else { Write-Host '   [-] Sunucuya ulasilamadi (Port 1688 Kapali veya Zaman Asimi).' -ForegroundColor Red } } catch { Write-Host '   [-] Sunucu adresi cozulemedi.' -ForegroundColor Red }"
echo.
pause
exit /b 0

:: ============================================================================
:: FAZ 6: EKSTRA ARACLAR ($OEM$ KLASORU CIKARTICI, BASE64 MOTORU VE CLI REHBERI)
:: ============================================================================
:Mod_Extras
cls
if "%_unattended%"=="0" mode con cols=100 lines=36 >nul 2>&1
title Ekstra Araclar: $OEM$ Katilimsiz Kurulum, Base64 Motoru ve Yardim

echo.
echo   !_Cyan!================================================================================================!_Reset!
echo      !_White!EKSTRA ARACLAR ($OEM$ KATILIMSIZ KURULUM KLASORU ^& BASE64 GOMULU VERI MOTORU)!_Reset!
echo      !_Gray!Windows ISO entegrasyonu icin $OEM$ uretir ve ikili (binary) dosyalari betige gomer.!_Reset!
echo   !_Cyan!================================================================================================!_Reset!
echo.
echo       !_Green![1] Masaustune $OEM$ Klasoru Cikart (Windows ISO Format Sonrasi Otomatik Kurulum)!_Reset!
echo           !_Gray!SetupComplete.cmd ve Home/Core surumleri icin ei.cfg dosyasini otomatik olusturur.!_Reset!
echo.
echo       !_Cyan![2] Harici Bir Dosyayi (DLL / EXE / XML) Bu Betigin Icine Base64 Olarak Gom!_Reset!
echo           !_Gray!Secilen dosyayi Base64'e kodlayip tek dosya (UET) tasinabilirligi icin betigin altina ekler.!_Reset!
echo.
echo       !_Yellow![3] Betik Icindeki Gomulu Base64 Verilerini Kontrol Et ve Listele!_Reset!
echo           !_Gray!Betigin sonuna gomulmus OHOOK_SPPC64, OHOOK_SPPC32 veya GENUINETICKET_XML bloklarini listeler.!_Reset!
echo.
echo       !_Magenta![4] Komut Satiri (CLI) Katilimsiz Parametreler Rehberini Goruntule (/?)!_Reset!
echo           !_Gray!Betigi arayuz acmadan (sessiz/katilimsiz) scriptlerden calistirma komutlarini gosterir.!_Reset!
echo.
echo       !_Red![0] Ana Menuye Don!_Reset!
echo.
echo   !_Cyan!================================================================================================!_Reset!
echo.

choice /C:12340 /N /M "   >> Seciminiz [1-4, Ana Menu icin 0]: "
set "_ex_erl=%errorlevel%"
if %_ex_erl%==5 exit /b 0
if %_ex_erl%==4 call :CLI_Help & goto :Mod_Extras
if %_ex_erl%==3 call :B64_VerifyMenu & goto :Mod_Extras
if %_ex_erl%==2 call :B64_EmbedMenu & goto :Mod_Extras
if %_ex_erl%==1 call :OEM_ExtractMenu & goto :Mod_Extras
goto :Mod_Extras

:OEM_ExtractMenu
cls
echo.
echo   !_Cyan!================================================================================================!_Reset!
echo      !_White!MASAUSTUNE $OEM$ KLASORU CIKARTMA ARACI (ISO ENTEGRASYONU)!_Reset!
echo      !_Gray!Olusturulan $OEM$ klasorunu Windows ISO'nuzun "sources" klasoru icine kopyalamaniz yeterlidir.!_Reset!
echo   !_Cyan!================================================================================================!_Reset!
echo.
echo      !_White!Format Sonrasi Otomatik Calisacak Yapilandirma Turunu Secin:!_Reset!
echo.
echo       !_Green![1] HWID (Kalici Dijital Lisans)!_Reset!
echo       !_Green![2] HWID (Windows) + Ohook (Office)!_Reset!
echo       !_Green![3] Online KMS (Windows + Office 180 Gun + Haftalik Otomatik Yenileme Gorevi)!_Reset!
echo       !_Green![4] TSforge (Windows / ESU + Office)!_Reset!
echo       !_Red![0] Iptal / Geri Don!_Reset!
echo.
choice /C:12340 /N /M "   >> Seciminiz [1-4, Geri icin 0]: "
set "_oem_opt=%errorlevel%"
if %_oem_opt%==5 exit /b 0

set "_oem_root=%UserProfile%\Desktop\$OEM$"
set "_oem_scripts=!_oem_root!\$$\Setup\Scripts"

if exist "!_oem_root!" (
    echo.
    echo   !_Yellow![i] Masaustunde zaten bir $OEM$ klasoru mevcut. Silinip yeniden olusturuluyor...!_Reset!
    rmdir /s /q "!_oem_root!" >nul 2>&1
)

mkdir "!_oem_scripts!" >nul 2>&1
copy /y "%_cmdf%" "!_oem_scripts!\UET_Tool.cmd" >nul 2>&1

set "_sc_cmd=call "%%~dp0UET_Tool.cmd" /HWID /S"
if %_oem_opt%==2 set "_sc_cmd=call "%%~dp0UET_Tool.cmd" /HWID /Ohook /S"
if %_oem_opt%==3 set "_sc_cmd=call "%%~dp0UET_Tool.cmd" /KMS /KMS-Task /S"
if %_oem_opt%==4 set "_sc_cmd=call "%%~dp0UET_Tool.cmd" /TSforge /S"

echo @echo off> "!_oem_scripts!\SetupComplete.cmd"
echo :: Windows Kurulum Sonrasi Otomatik Yapilandirma Betigi>> "!_oem_scripts!\SetupComplete.cmd"
echo !_sc_cmd!>> "!_oem_scripts!\SetupComplete.cmd"
echo cd /d "%%SystemRoot%%\Setup">> "!_oem_scripts!\SetupComplete.cmd"
echo if exist "%%SystemRoot%%\Setup\Scripts" @rd /s /q "%%SystemRoot%%\Setup\Scripts">> "!_oem_scripts!\SetupComplete.cmd"
echo exit /b 0>> "!_oem_scripts!\SetupComplete.cmd"

echo [Channel]> "!_oem_root!\ei.cfg"
echo _Default>> "!_oem_root!\ei.cfg"
echo [VL]>> "!_oem_root!\ei.cfg"
echo 0>> "!_oem_root!\ei.cfg"

echo.
echo   !_Green!================================================================================================!_Reset!
echo      !_White![+] $OEM$ Klasoru Masaustunde Basariyla Olusturuldu.!_Reset!
echo   !_Green!================================================================================================!_Reset!
echo.
echo    !_Cyan!Klasor Yolu :!_Reset! !_oem_root!
echo    !_Cyan!Kurulum Kodu:!_Reset! !_sc_cmd!
echo.
echo    !_Yellow!Nasil Kullanilir?!_Reset!
echo    1. Masaustundeki !_White!$OEM$!_Reset! klasorunu ve icindeki !_White!ei.cfg!_Reset! dosyasini USB/ISO icindeki
echo       !_Green!sources!_Reset! klasorunun icine atin.
echo    2. Windows kurulumu bittiginde ilk masaustu acilisinda betik sessizce calisip kendini temizler.
echo.
pause
exit /b 0

:B64_EmbedMenu
cls
echo.
echo   !_Cyan!================================================================================================!_Reset!
echo      !_White!BASE64 GOMULU VERI MOTORU (DOSYAYI BETIGIN ICINE GOMME ARACI)!_Reset!
echo      !_Gray!Harici DLL, EXE veya XML dosyalarini bu .cmd dosyasinin en altina Base64 olarak gomer.!_Reset!
echo   !_Cyan!================================================================================================!_Reset!
echo.
echo      !_White!Hangi Etiket Icin Dosya Gommek Istiyorsunuz?!_Reset!
echo       !_Green![1] OHOOK_SPPC64!_Reset!       (64-bit Office Ohook sppc64.dll dosyasi)
echo       !_Green![2] OHOOK_SPPC32!_Reset!       (32-bit Office Ohook sppc32.dll dosyasi)
echo       !_Green![3] GENUINETICKET_XML!_Reset!  (HWID ozel GenuineTicket.xml dosyasi)
echo       !_Cyan![4] OZEL_ETIKET!_Reset!        (Kendi belirleyeceginiz herhangi bir dosya/etiket)
echo       !_Red![0] Geri Don!_Reset!
echo.
choice /C:12340 /N /M "   >> Seciminiz [1-4, Geri icin 0]: "
set "_b_sel=%errorlevel%"
if %_b_sel%==5 exit /b 0

set "_tag_name="
if %_b_sel%==1 set "_tag_name=OHOOK_SPPC64"
if %_b_sel%==2 set "_tag_name=OHOOK_SPPC32"
if %_b_sel%==3 set "_tag_name=GENUINETICKET_XML"
if %_b_sel%==4 (
    echo.
    set /p "_tag_name=   >> Ozel etiket adini girin (Orn: ARAC_EXE): "
)
if not defined _tag_name exit /b 0

echo.
set "_src_file="
set /p "_src_file=   >> Gomulecek dosyanin tam yolunu girin (veya surukleyip birakin): "
if not defined _src_file exit /b 0
set "_src_file=!_src_file:"=!"

if not exist "!_src_file!" (
    echo.
    echo   !_Red![HATA] Belirtilen dosya bulunamadi: !_src_file!!_Reset!
    pause
    exit /b 1
)

echo.
echo   !_Yellow![*] Dosya Base64 formatina kodlanip %~nx0 dosyasinin sonuna ekleniyor...!_Reset!
%psc% "$bytes = [IO.File]::ReadAllBytes($env:_src_file); $b64 = [Convert]::ToBase64String($bytes, 'InsertLineBreaks'); $lines = $b64 -split [Environment]::NewLine; $out = New-Object System.Collections.Generic.List[string]; $out.Add(''); $out.Add('::B64_START_' + $env:_tag_name); foreach ($l in $lines) { $out.Add('::' + $l) }; $out.Add('::B64_END_' + $env:_tag_name); [IO.File]::AppendAllLines($env:_cmdf, $out)"

if !errorlevel! equ 0 (
    echo   !_Green![+] Dosya [!_tag_name!] basariyla betigin sonuna Base64 olarak gomuldu.!_Reset!
    echo   !_Gray!Artik harici dosyaya ihtiyac duymadan betigi tek basina tasiyabilirsiniz.!_Reset!
) else (
    echo   !_Red![HATA] Kodlama sirasinda bir hata olustu.!_Reset!
)
echo.
pause
exit /b 0

:B64_VerifyMenu
cls
echo.
echo   !_Cyan!=== BETIK ICINDEKI GOMULU BASE64 VERILERI ===!_Reset!
echo.
set "_found_b64=0"
for /f "tokens=1 delims=" %%L in ('findstr /i "^::B64_START_" "%_cmdf%" 2^>nul') do (
    set /a _found_b64+=1
    set "_line_tag=%%L"
    set "_line_tag=!_line_tag:::B64_START_=!"
    echo   !_Green![!_found_b64!] Gomulu Veri Etiketi Bulundu:!_Reset! !_White!!_line_tag!!_Reset!
)
if "!_found_b64!"=="0" (
    echo   !_Yellow![i] Su anda betigin icinde gomulu herhangi bir Base64 blogu bulunmuyor.!_Reset!
    echo   !_Gray!Gommek icin bir onceki menude [2] numarali secenegi kullanabilirsiniz.!_Reset!
)
echo.
pause
exit /b 0

:CLI_Help
cls
echo.
echo   !_Cyan!================================================================================================!_Reset!
echo      !_White!KOMUT SATIRI (CLI) KATILIMSIZ KULLANIM PARAMETRELERI!_Reset!
echo   !_Cyan!================================================================================================!_Reset!
echo.
echo    Bu betigi PowerShell veya CMD uzerinden hicbir menuye tiklamadan katilimsiz calistirabilirsiniz:
echo.
echo    !_Green!%~nx0 /HWID /S!_Reset!          - Windows 10/11 HWID yapilandirmasini sessizce calistirir ve cikar.
echo    !_Green!%~nx0 /Ohook /S!_Reset!         - Office Ohook ve Volume GVLK kurulumunu sessizce yapar.
echo    !_Green!%~nx0 /TSforge /S!_Reset!       - TSforge Guvenilir Depolama kontrolunu calistirir.
echo    !_Green!%~nx0 /KMS /S!_Reset!           - Hem Windows hem Office icin Online KMS (180 Gun) etkinlestirir.
echo    !_Green!%~nx0 /KMS-Windows /S!_Reset!   - Sadece Windows icin Online KMS etkinlestirir.
echo    !_Green!%~nx0 /KMS-Office /S!_Reset!    - Sadece Office icin Online KMS etkinlestirir.
echo    !_Green!%~nx0 /KMS-Task /S!_Reset!      - Haftalik otomatik KMS yenileme gorevini (SYSTEM) kurar.
echo    !_Green!%~nx0 /Status!_Reset!           - Dogrudan detayli lisans durumu raporunu acar.
echo.
echo   !_Cyan!================================================================================================!_Reset!
echo.
if "%_unattended%"=="0" pause
exit /b 0

:End_Unattended
if "%_unattended%"=="0" pause
:Exit_Script
popd
echo.
echo   !_Cyan!Cikis yapiliyor...!_Reset!
timeout /t 1 >nul 2>&1
exit /b 0

:: ============================================================================
:: GOMULU BASE64 VERI DEPOSU (BU SATIRIN ALTINA OTOMATIK EKLENIR)
:: ============================================================================
'@

# --- SEKME 5: SISTEM ARACLARI, ONARIM & UET LISANS ARACI ---
$script:BtnRestorePoint.Add_Click({
    Start-BackgroundTask "Sistem Geri Yukleme Noktasi olusturuluyor..." @{} {
        Enable-ComputerRestore -Drive "$env:SystemDrive\" -ErrorAction SilentlyContinue
        Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore" "SystemRestorePointCreationFrequency" "DWord" 0
        Checkpoint-Computer -Description "UmutEvranTool_ManualRestore" -RestorePointType "MODIFY_SETTINGS" -ErrorAction SilentlyContinue
        Log-Bg "[OK] Sistem Geri Yukleme Noktasi olusturuldu."
    }
})

$script:BtnRunMAS.Add_Click({
    Write-UiLog (Decode-U "[*] UET Lisans ve Sistem Yonetim Araci baslatiliyor...")
    try {
        $uetCmdPath = Join-Path $env:TEMP "UET_Tool.cmd"
        $rawCmd = if ($sync.MasScript -and $sync.MasScript.Length -gt 100) {
            Decode-U $sync.MasScript
        } else {
            Decode-U $script:EmbeddedUetToolCmd
        }
        $normalizedCmd = ($rawCmd -replace "\r?\n", "`r`n").Trim() + "`r`n"
        [System.IO.File]::WriteAllText($uetCmdPath, $normalizedCmd, [System.Text.Encoding]::ASCII)
        Start-Process -FilePath "cmd.exe" -ArgumentList "/c `"`"$uetCmdPath`"`"" -WorkingDirectory $env:TEMP
        Write-UiLog (Decode-U "[OK] UET_Tool.cmd yeni konsol penceresinde baslatildi.")
    } catch {
        Write-UiLog ("[HATA] UET_Tool baslatilamadi: " + $_.Exception.Message)
    }
})

$script:BtnCreateGodMode.Add_Click({
    $desktop = [Environment]::GetFolderPath("Desktop")
    $godPath = Join-Path $desktop "GodMode.{ED7BA470-8E54-465E-825C-99712043E01C}"
    New-Item -Path $godPath -ItemType Directory -Force | Out-Null
    Write-UiLog (Decode-U "[OK] Masaustunde GodMode klasoru olusturuldu.")
})

$script:BtnRunOOSU.Add_Click({
    Start-BackgroundTask "O&O ShutUp10++ indiriliyor ve baslatiliyor..." @{} {
        $ooPath = Join-Path $env:TEMP "OOSU10.exe"
        Invoke-WebRequest -Uri "https://dl5.oo-software.com/files/ooshutup10/OOSU10.exe" -OutFile $ooPath -UseBasicParsing
        Start-Process $ooPath
        Log-Bg "[OK] O&O ShutUp10++ acildi."
    }
})

$script:BtnFixSystemCorruption.Add_Click({
    Start-BackgroundTask "DISM ve SFC Sistem Onarimi calisiyor..." @{} {
        Log-Bg "[*] DISM /RestoreHealth baslatildi..."
        DISM.exe /Online /Cleanup-Image /RestoreHealth
        Log-Bg "[*] sfc /scannow baslatildi..."
        sfc /scannow
        Log-Bg "[OK] Sistem dosyalari onarimi tamamlandi."
    }
})

$script:BtnFixWinUpdate.Add_Click({
    Start-BackgroundTask "Windows Update bilesenleri sifirlaniyor..." @{} {
        $svcs = @("bits", "wuauserv", "cryptsvc")
        foreach ($s in $svcs) { Stop-Service -Name $s -Force -ErrorAction SilentlyContinue }
        Remove-Item "$env:SystemRoot\SoftwareDistribution\*" -Recurse -Force -ErrorAction SilentlyContinue
        foreach ($s in $svcs) { Start-Service -Name $s -ErrorAction SilentlyContinue }
        Log-Bg "[OK] Windows Update onbellegi ve servisleri sifirlandi."
    }
})

$script:BtnFixNetwork.Add_Click({
    Start-BackgroundTask "Ag yigini sifirlaniyor..." @{} {
        ipconfig /release | Out-Null
        ipconfig /flushdns | Out-Null
        ipconfig /renew | Out-Null
        netsh int ip reset | Out-Null
        netsh winsock reset | Out-Null
        Log-Bg "[OK] Ag ayarlari, IP ve Winsock sifirlandi."
    }
})

$script:BtnFixWinget.Add_Click({
    Start-BackgroundTask "Winget kaynaklari onariliyor..." @{} {
        winget source reset --force
        winget source update
        Log-Bg "[OK] Winget kaynaklari sifirlandi ve guncellendi."
    }
})

$script:BtnFixNTP.Add_Click({
    Start-BackgroundTask "Sistem saati senkronize ediliyor..." @{} {
        Start-Service w32time -ErrorAction SilentlyContinue
        w32tm /resync /force | Out-Null
        Log-Bg "[OK] Windows saat senkronizasyonu tamamlandi."
    }
})

$script:BtnRunAutologon.Add_Click({
    Start-BackgroundTask "Sysinternals Autologon indiriliyor..." @{} {
        $alPath = Join-Path $env:TEMP "Autologon64.exe"
        Invoke-WebRequest -Uri "https://live.sysinternals.com/Autologon64.exe" -OutFile $alPath -UseBasicParsing
        Start-Process $alPath
        Log-Bg "[OK] Sysinternals Autologon baslatildi."
    }
})

$script:BtnEnableOpenSSH.Add_Click({
    Start-BackgroundTask "OpenSSH Sunucusu etkinlestiriliyor..." @{} {
        Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0 -ErrorAction SilentlyContinue | Out-Null
        Set-Service -Name sshd -StartupType Automatic -ErrorAction SilentlyContinue
        Start-Service sshd -ErrorAction SilentlyContinue
        Log-Bg "[OK] OpenSSH Sunucusu etkinlestirildi."
    }
})

$script:BtnEnableRegBackup.Add_Click({
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Configuration Manager" -Name "EnablePeriodicBackup" -Type DWord -Value 1 -Force -ErrorAction SilentlyContinue
    Write-UiLog "[OK] Otomatik Kayit Defteri Yedeklemesi (RegBack) etkinlestirildi."
})

$script:BtnRestartExplorer.Add_Click({
    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
    Write-UiLog "[OK] Windows Gezgini (Explorer.exe) yeniden baslatildi."
})

$script:BtnEnableF8Boot.Add_Click({
    bcdedit /set `{current`} bootmenupolicy Legacy | Out-Null
    Write-UiLog "[OK] Klasik F8 Guvenli Mod Onyukleme Menusu etkinlestirildi."
})
$script:BtnDisableF8Boot.Add_Click({
    bcdedit /set `{current`} bootmenupolicy Standard | Out-Null
    Write-UiLog "[OK] Standart Windows Onyukleme Menusu geri yuklendi."
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

# --- SEKME 6: YEDEKLEME & CONFIG DISA/ICE AKTARIM ---
$script:BtnExportConfig.Add_Click({
    $dlg = New-Object Microsoft.Win32.SaveFileDialog
    $dlg.Filter = "JSON Config (*.json)|*.json"
    $dlg.FileName = "UmutEvranTool_Config.json"
    if ($dlg.ShowDialog() -eq $true) {
        $exportObj = @{
            Apps      = @($script:SelectedApps.Keys | Where-Object { $script:SelectedApps[$_] -eq $true })
            Tweaks    = @($script:TweakCheckboxes.Keys | Where-Object { $script:TweakCheckboxes[$_].IsChecked -eq $true })
            Features  = @($script:FeatureCheckboxes.Keys | Where-Object { $script:FeatureCheckboxes[$_].IsChecked -eq $true })
            Bloatware = @($script:BloatCheckboxes.Keys | Where-Object { $script:BloatCheckboxes[$_].IsChecked -eq $true })
        }
        $exportObj | ConvertTo-Json -Depth 5 | Set-Content -Path $dlg.FileName -Encoding UTF8
        Write-UiLog ("[OK] Yapilandirma kaydedildi: " + $dlg.FileName)
    }
})

$script:BtnImportConfig.Add_Click({
    $dlg = New-Object Microsoft.Win32.OpenFileDialog
    $dlg.Filter = "JSON Config (*.json)|*.json"
    if ($dlg.ShowDialog() -eq $true) {
        $imp = Get-Content -Path $dlg.FileName -Raw -Encoding UTF8 | ConvertFrom-Json
        if ($imp.Apps) {
            foreach ($id in $imp.Apps) {
                $fixedId = Resolve-WingetId $id
                $script:SelectedApps[$fixedId] = $true
            }
        }
        if ($imp.Tweaks) {
            foreach ($t in $imp.Tweaks) {
                if ($script:TweakCheckboxes.ContainsKey($t)) { $script:TweakCheckboxes[$t].IsChecked = $true }
            }
        }
        if ($imp.Features) {
            foreach ($f in $imp.Features) {
                if ($script:FeatureCheckboxes.ContainsKey($f)) { $script:FeatureCheckboxes[$f].IsChecked = $true }
            }
        }
        if ($imp.Bloatware) {
            foreach ($b in $imp.Bloatware) {
                if ($script:BloatCheckboxes.ContainsKey($b)) { $script:BloatCheckboxes[$b].IsChecked = $true }
            }
        }
        Render-Apps
        Update-AllSelectionCounts
        Write-UiLog ("[OK] Yapilandirma yuklendi (mevcut secimlere eklendi): " + $dlg.FileName)
    }
})

$script:BtnExportSysReport.Add_Click({
    $dlg = New-Object Microsoft.Win32.SaveFileDialog
    $dlg.Filter = "Metin Dosyasi (*.txt)|*.txt"
    $dlg.FileName = "Sistem_Raporu.txt"
    if ($dlg.ShowDialog() -eq $true) {
        $os  = Get-CimInstance Win32_OperatingSystem
        $cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
        $gpu = Get-CimInstance Win32_VideoController | Select-Object -ExpandProperty Name
        $rep = @(
            "=== UMUT EVRAN TOOL v4.0 SISTEM RAPORU ===",
            "Tarih: $(Get-Date)",
            "Isletim Sistemi: $($os.Caption) ($($os.Version))",
            "Islemci: $($cpu.Name)",
            "Ekran Karti: $($gpu -join ', ')",
            "Toplam RAM: $([math]::Round($os.TotalVisibleMemorySize / 1MB, 2)) GB"
        ) -join "`r`n"
        Set-Content -Path $dlg.FileName -Value $rep -Encoding UTF8
        Write-UiLog ("[OK] Sistem raporu kaydedildi: " + $dlg.FileName)
    }
})

$script:BtnCopyCmd.Add_Click({
    if ($script:TxtRemoteCmd -and -not [string]::IsNullOrWhiteSpace($script:TxtRemoteCmd.Text)) {
        [System.Windows.Clipboard]::SetText($script:TxtRemoteCmd.Text)
    } else {
        [System.Windows.Clipboard]::SetText("irm evrantool.evranumut.workers.dev | iex")
    }
    Write-UiLog (Decode-U "[OK] Uzaktan calistirma komutu panoya kopyalandi.")
})

$script:BtnClearLog.Add_Click({
    $script:TxtLog.Clear()
})

# --- BASLANGIC ILKLENDIRMESI ---
try {
    $osInfo = Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue
    if ($osInfo -and $script:TxtSysInfo) {
        $ramGb = [math]::Round($osInfo.TotalVisibleMemorySize / 1MB, 1)
        $script:TxtSysInfo.Text = "$($osInfo.Caption) | $ramGb GB RAM"
    }
} catch {}

Initialize-CategoryPills
Render-Apps
Render-Tweaks
Render-Features
Render-Bloatware
Update-AllSelectionCounts

Write-UiLog (Decode-U "[OK] Umut Evran Tool v4.0 hazir. Toplam $($script:TotalAppCount) uygulama logolariyla yuklendi.")
[void]$script:window.ShowDialog()