# --- SECIM VE DURUM YONETIMI (HER MENUDE SECILEN SAYISI TAKIBI) ---
$script:SelectedApps      = @{}
$script:AppCheckboxes     = @{}   # Sadece o an gorunen (filtreye uyan) uygulamalar
$script:AllAppCheckboxes  = @{}   # Tum uygulamalar (filtre disi secimler icin)
$script:AppCards          = @{}
$script:AppCardMeta       = @{}
$script:AppCategoryGroups = @()
$script:AppsBuilt         = $false
$script:StripBadges       = @{}
$script:TweakCheckboxes   = @{}
$script:FeatureCheckboxes = @{}
$script:BloatCheckboxes   = @{}
$script:TweakCards        = @{}
$script:FeatureCards      = @{}
$script:BloatCards        = @{}
$script:CategoryButtons   = @{}
$script:ActiveCategory    = "ALL"
$script:ActiveTab         = "Apps"
$script:ActiveAppPresetIds = @()

$script:TotalAppCount = 0
foreach ($c in $script:AppCategories) {
    $script:TotalAppCount += $c.Apps.Count
}

function Update-InstalledStripSelectionVisuals {
    foreach ($id in $script:StripBadges.Keys) {
        $badge = $script:StripBadges[$id]
        if ($script:SelectedApps[$id] -eq $true) {
            Set-ThemeRef $badge "Background" "SelectedBg"
            Set-ThemeRef $badge "BorderBrush" "AccentColor"
        } else {
            Set-ThemeRef $badge "Background" "CardBg"
            Set-ThemeRef $badge "BorderBrush" "SuccessBorder"
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
            Set-ThemeRef $btn "Background" "ActiveBtnColor"
            $btn.Foreground  = Get-Brush "#FFFFFF"
            $btn.FontWeight  = "SemiBold"
        } else {
            $btn.Background  = Get-Brush "Transparent"
            $btn.Foreground  = Get-Brush "#E4E4E7"
            $btn.FontWeight  = "Normal"
        }
    }
}

# --- SOL MENU AKORDEON GRUPLARI ---
function Set-NavGroupState([string]$group, [bool]$expanded) {
    if ($group -eq "Modules") {
        if ($script:NavGroupModules) { $script:NavGroupModules.Visibility = if ($expanded) { "Visible" } else { "Collapsed" } }
        if ($script:BtnNavGroupModules) { $script:BtnNavGroupModules.Content = if ($expanded) { Decode-U "\u25BE MOD\u00DCLLER" } else { Decode-U "\u25B8 MOD\u00DCLLER" } }
    } else {
        if ($script:NavGroupPresets) { $script:NavGroupPresets.Visibility = if ($expanded) { "Visible" } else { "Collapsed" } }
        if ($script:BtnNavGroupPresets) { $script:BtnNavGroupPresets.Content = if ($expanded) { Decode-U "\u25BE HAZIR PAKETLER" } else { Decode-U "\u25B8 HAZIR PAKETLER" } }
    }
}
if ($script:BtnNavGroupModules) {
    $script:BtnNavGroupModules.Add_Click({
        $isOpen = ($script:NavGroupModules.Visibility -eq "Visible")
        Set-NavGroupState "Modules" (-not $isOpen)
    })
}
if ($script:BtnNavGroupPresets) {
    $script:BtnNavGroupPresets.Add_Click({
        $isOpen = ($script:NavGroupPresets.Visibility -eq "Visible")
        Set-NavGroupState "Presets" (-not $isOpen)
    })
}

# --- KONSOL DARALT / GENISLET ---
$script:LogExpanded = $true
function Set-LogPanelState([bool]$expanded) {
    $script:LogExpanded = $expanded
    if ($script:LogColumn) {
        $script:LogColumn.Width = New-Object System.Windows.GridLength($(if ($expanded) { 344 } else { 58 }))
    }
    if ($script:LogExpandedPanel) { $script:LogExpandedPanel.Visibility = if ($expanded) { "Visible" } else { "Collapsed" } }
    if ($script:LogCollapsedBar)  { $script:LogCollapsedBar.Visibility  = if ($expanded) { "Collapsed" } else { "Visible" } }
}
if ($script:BtnToggleLog) { $script:BtnToggleLog.Add_Click({ Set-LogPanelState $false }) }
if ($script:BtnExpandLog) { $script:BtnExpandLog.Add_Click({ Set-LogPanelState $true }) }

$script:BtnNavApps.Add_Click({ Switch-Tab "Apps" })
$script:BtnNavTweaks.Add_Click({ Switch-Tab "Tweaks" })
$script:BtnNavFeatures.Add_Click({ Switch-Tab "Features" })
$script:BtnNavBloatware.Add_Click({ Switch-Tab "Bloatware" })
$script:BtnNavTools.Add_Click({ Switch-Tab "Tools" })
$script:BtnNavConfig.Add_Click({ Switch-Tab "Config" })