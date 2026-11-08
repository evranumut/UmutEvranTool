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

# Sekme 5: Sistem Araclari & Petra Kontrolleri
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
$script:BtnSaveLog      = $script:window.FindName("BtnSaveLog")
$script:TxtSysInfo      = $script:window.FindName("TxtSysInfo")

# Konsol daraltma / genisletme ve sol menu akordeon kontrolleri
$script:LogColumn         = $script:window.FindName("LogColumn")
$script:LogExpandedPanel  = $script:window.FindName("LogExpandedPanel")
$script:LogCollapsedBar   = $script:window.FindName("LogCollapsedBar")
$script:BtnToggleLog      = $script:window.FindName("BtnToggleLog")
$script:BtnExpandLog      = $script:window.FindName("BtnExpandLog")
$script:BtnTheme          = $script:window.FindName("BtnTheme")
$script:BtnThemeCollapsed = $script:window.FindName("BtnThemeCollapsed")
$script:BtnNavGroupModules = $script:window.FindName("BtnNavGroupModules")
$script:NavGroupModules    = $script:window.FindName("NavGroupModules")
$script:BtnNavGroupPresets = $script:window.FindName("BtnNavGroupPresets")
$script:NavGroupPresets    = $script:window.FindName("NavGroupPresets")

# LogColumn FindName ile bulunamazsa ana Grid'in 3. sutununu kullan.
if (-not $script:LogColumn) {
    try {
        $rootGrid = $script:window.Content
        if ($rootGrid -and $rootGrid.ColumnDefinitions.Count -gt 2) {
            $script:LogColumn = $rootGrid.ColumnDefinitions[2]
        }
    } catch {}
}

if ($script:TxtLog) { $script:TxtLog.Document.PagePadding = New-Object System.Windows.Thickness(0) }

if ($script:BtnRunMAS) {
    $script:BtnRunMAS.Content = Decode-U "\uD83D\uDD11 Petra Lisans ve Sistem Yonetim Araci (HWID / Ohook / KMS)"
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
$sync.InstalledApps         = [Hashtable]::Synchronized(@{})
$sync.AllAppIds             = @()
foreach ($c in $script:AppCategories) {
    foreach ($a in $c.Apps) { $sync.AllAppIds += $a.Id }
}
$sync.IsBusy                = $false

# Log satirini durumuna gore renklendirir (basari yesil, uyari sari, hata kirmizi).
function Get-LogLineColor([string]$line) {
    if ($line -match '\[(HATA|!)\]') { return $script:Theme.ErrorFg }
    if ($line -match '\[(OK|\+)\]') { return $script:Theme.SuccessFg }
    if ($line -match '\[(UNDO|-)\]') { return $script:Theme.WarnFg }
    if ($line -match '\[(APPLY)\]') { return $script:Theme.AccentColor }
    if ($line -match '\[(i|\*)\]') { return $script:Theme.TextMuted }
    return $script:Theme.LogFg
}

function Add-UiLogLine([string]$line) {
    if (-not $script:TxtLog) { return }
    $doc = $script:TxtLog.Document
    $para = New-Object System.Windows.Documents.Paragraph
    $para.Margin = New-Object System.Windows.Thickness(0)
    $para.LineHeight = 16
    $run = New-Object System.Windows.Documents.Run($line)
    try { $run.Foreground = Get-Brush (Get-LogLineColor $line) } catch { }
    [void]$para.Inlines.Add($run)
    [void]$doc.Blocks.Add($para)
    if ($doc.Blocks.Count -gt 1500) { $doc.Blocks.Remove($doc.Blocks.FirstBlock) }
    $script:TxtLog.ScrollToEnd()
}

function Write-UiLog([string]$msg) {
    $time = (Get-Date).ToString("HH:mm:ss")
    $decoded = Decode-U $msg
    if ($script:window.Dispatcher.CheckAccess()) {
        Add-UiLogLine "[$time] $decoded"
    } else {
        $script:window.Dispatcher.Invoke([action]{ Add-UiLogLine "[$time] $decoded" })
    }
}

function Set-UiStatus([string]$msg, [double]$progress = -1) {
    $decoded = Decode-U $msg
    $color = if ($msg -match '\[(HATA|!)\]|Hata|hata') { $script:Theme.ErrorFg }
             elseif ($msg -match ('^\s*(Hazir|Haz' + [char]0x0131 + 'r)\s*$')) { "#FAFAFA" }
             else { $script:Theme.LogFg }
    $script:window.Dispatcher.Invoke([action]{
        $script:TxtStatus.Text = $decoded
        try { $script:TxtStatus.Foreground = Get-Brush $color } catch { }
        if ($progress -ge 0) {
            $script:ProgressBarMain.Value = $progress
        }
    })
}