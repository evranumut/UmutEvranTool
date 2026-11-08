# --- TEMA KATALOGU (Solar Eclipse varsayilan / Deep Ocean alternatif) ---
$script:Themes = @{}

$script:Themes["SolarEclipse"] = @'
{
    "Name": "Solar Eclipse",
    "WindowBg": "#0B0A09",
    "PanelBg": "#141110",
    "CardBg": "#1B1715",
    "BorderBrushColor": "#2E2723",
    "HoverBg": "#241E1A",
    "AccentColor": "#FBBF6B",
    "ActiveBtnColor": "#F97316",
    "PrimaryHover": "#C2410C",
    "TextMuted": "#A8A29E",
    "TextDim": "#7C7269",
    "LogBg": "#090807",
    "LogFg": "#E7E0D8",
    "BtnInstallBg": "#F97316",
    "BtnUninstallBg": "#4A1D1D",
    "BtnUpgradeBg": "#241D18",
    "SuccessFg": "#86EFAC",
    "SuccessBg": "#17251B",
    "SuccessBorder": "#2F5C41",
    "WarnFg": "#FBBF24",
    "ErrorFg": "#FCA5A5",
    "SelectedBg": "#2C2115",
    "SelectedBorder": "#F97316"
}
'@ | ConvertFrom-Json

$script:Themes["DeepOcean"] = @'
{
    "Name": "Deep Ocean",
    "WindowBg": "#07121B",
    "PanelBg": "#0A1A26",
    "CardBg": "#0F2434",
    "BorderBrushColor": "#1B4358",
    "HoverBg": "#142F44",
    "AccentColor": "#67E8F9",
    "ActiveBtnColor": "#0891B2",
    "PrimaryHover": "#0E7490",
    "TextMuted": "#94A3B8",
    "TextDim": "#64748B",
    "LogBg": "#05101A",
    "LogFg": "#D6E6F0",
    "BtnInstallBg": "#0891B2",
    "BtnUninstallBg": "#4A1F2E",
    "BtnUpgradeBg": "#0E2A3D",
    "SuccessFg": "#5EEAD4",
    "SuccessBg": "#0A2B2C",
    "SuccessBorder": "#17606A",
    "WarnFg": "#FCD34D",
    "ErrorFg": "#FCA5A5",
    "SelectedBg": "#0E3348",
    "SelectedBorder": "#22D3EE"
}
'@ | ConvertFrom-Json

# --- TEMA TERCIHI KALICILIGI (%LOCALAPPDATA%\PetraOmniTool\settings.json) ---
function Get-PetraSettingsDir {
    $base = $env:LOCALAPPDATA
    if ([string]::IsNullOrWhiteSpace($base)) { $base = $env:TEMP }
    return (Join-Path $base "PetraOmniTool")
}

function Get-PetraSettingsPath {
    return (Join-Path (Get-PetraSettingsDir) "settings.json")
}

function Read-PetraSettings {
    try {
        $path = Get-PetraSettingsPath
        if (Test-Path -LiteralPath $path) {
            $raw = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)
            if (-not [string]::IsNullOrWhiteSpace($raw)) { return ($raw | ConvertFrom-Json) }
        }
    } catch {}
    return $null
}

function Save-PetraSettings($settings) {
    try {
        $dir = Get-PetraSettingsDir
        if (-not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
        $path = Get-PetraSettingsPath
        $tmp = "$path.tmp"
        $json = $settings | ConvertTo-Json -Depth 5
        [System.IO.File]::WriteAllText($tmp, $json, (New-Object System.Text.UTF8Encoding($false)))
        Move-Item -LiteralPath $tmp -Destination $path -Force
        return $true
    } catch {
        return $false
    }
}

function Save-PetraThemePreference([string]$name) {
    if ([string]::IsNullOrWhiteSpace($name)) { return }
    $settings = Read-PetraSettings
    if ($null -eq $settings) { $settings = [pscustomobject]@{} }
    try {
        $settings | Add-Member -NotePropertyName "Theme" -NotePropertyValue $name -Force
        [void](Save-PetraSettings $settings)
    } catch {}
}

$script:ThemeName = "SolarEclipse"
$script:ThemeLoadedFromSettings = $false
try {
    $savedSettings = Read-PetraSettings
    if ($savedSettings -and $savedSettings.PSObject.Properties["Theme"]) {
        $savedTheme = [string]$savedSettings.Theme
        $savedThemeKey = Get-OrdinalIgnoreCaseKey $script:Themes $savedTheme
        if ($savedThemeKey) {
            $script:ThemeName = $savedThemeKey
            $script:ThemeLoadedFromSettings = $true
        }
    }
} catch {}
$script:Theme = $script:Themes[$script:ThemeName]

# --- TEMA MOTORU ---
# Bir elemanin rengini pencere kaynagina baglar; tema degisince eleman
# yeniden olusturulmadan otomatik guncellenir (UI donmasini engeller).
function Get-ThemeDependencyProperty($element, [string]$property) {
    if ($null -eq $element -or [string]::IsNullOrWhiteSpace($property)) { return $null }
    $fieldName = $property + "Property"
    $t = $element.GetType()
    while ($t) {
        $flags = [System.Reflection.BindingFlags]::Public -bor [System.Reflection.BindingFlags]::Static -bor [System.Reflection.BindingFlags]::FlattenHierarchy
        $field = $t.GetField($fieldName, $flags)
        if ($field) {
            try { return $field.GetValue($null) } catch { return $null }
        }
        $t = $t.BaseType
    }
    return $null
}

function Set-ThemeRef($element, $property, [string]$key) {
    if ($null -eq $element -or -not $key) { return }
    try {
        $dp = Get-ThemeDependencyProperty $element $property
        if ($dp) { $element.SetResourceReference($dp, $key) }
    } catch { }
}

function Set-PetraThemeResources {
    if (-not $script:window -or -not $script:Theme) { return }
    foreach ($prop in $script:Theme.PSObject.Properties) {
        if ($prop.Name -eq "Name") { continue }
        try { $script:window.Resources[$prop.Name] = Get-Brush ([string]$prop.Value) } catch {}
    }
}

function Update-ThemeButtonVisual {
    $icon = if ($script:ThemeName -eq "DeepOcean") { Decode-U "\uD83C\uDF0A" } else { Decode-U "\uD83C\uDF11" }
    $tip  = "Tema: " + $script:Theme.Name + " - degistirmek icin tikla"
    foreach ($b in @($script:BtnTheme, $script:BtnThemeCollapsed)) {
        if ($b) {
            $b.Content  = $icon
            $b.ToolTip  = $tip
        }
    }
}

function Find-PanelScrollViewer($panel) {
    if (-not $panel) { return $null }
    $node = $panel
    while ($node) {
        if ($node -is [System.Windows.Controls.ScrollViewer]) { return $node }
        try {
            $node = [System.Windows.Media.VisualTreeHelper]::GetParent($node)
        } catch {
            return $null
        }
    }
    return $null
}

function Get-PanelScrollOffset($panel) {
    $sv = Find-PanelScrollViewer $panel
    if ($sv) { return $sv.VerticalOffset }
    return 0
}

function Set-PanelScrollOffset($panel, [double]$offset) {
    $sv = Find-PanelScrollViewer $panel
    if ($sv -and $offset -ge 0) { $sv.ScrollToVerticalOffset($offset) }
}

function Update-LogColors {
    if (-not $script:TxtLog) { return }
    foreach ($block in $script:TxtLog.Document.Blocks) {
        if ($block -is [System.Windows.Documents.Paragraph]) {
            foreach ($inline in $block.Inlines) {
                if ($inline -is [System.Windows.Documents.Run]) {
                    try { $inline.Foreground = Get-Brush (Get-LogLineColor $inline.Text) } catch {}
                }
            }
        }
    }
}

function Apply-PetraTheme([string]$name) {
    $themeKey = Get-OrdinalIgnoreCaseKey $script:Themes $name
    if (-not $themeKey) { return }
    $name = $themeKey

    $script:ThemeName = $name
    $script:Theme = $script:Themes[$name]
    # Pencere kaynaklarini guncelle: listelerdeki elemanlar bu kaynaklara
    # bagli oldugu icin yeniden olusturmaya (ve donmaya) gerek kalmaz.
    Set-PetraThemeResources

    try { Update-CategoryPillStyles } catch {}
    try { Switch-Tab $script:ActiveTab } catch {}
    Update-LogColors
    Update-ThemeButtonVisual

    # Durum cubugu metni son islemin rengini korur; tema rengine gore yenile.
    if ($script:TxtStatus) {
        $statusText = [string]$script:TxtStatus.Text
        $statusColor = if ($statusText -match '\[(HATA|!)\]|Hata|hata') { $script:Theme.ErrorFg } else { $script:Theme.LogFg }
        try { $script:TxtStatus.Foreground = Get-Brush $statusColor } catch {}
    }

    Save-PetraThemePreference $name
    Write-UiLog ("[i] Tema degistirildi: " + $script:Theme.Name)
}

function New-ThemeMenuRow([string]$key) {
    $t = $script:Themes[$key]

    $row = New-Object System.Windows.Controls.Border
    $row.Tag = $key
    $row.CornerRadius = New-Object System.Windows.CornerRadius(6)
    $row.Padding = New-Object System.Windows.Thickness(8, 7, 8, 7)
    $row.Background = Get-Brush "Transparent"
    $row.Cursor = [System.Windows.Input.Cursors]::Hand

    $grid = New-Object System.Windows.Controls.Grid
    $c1 = New-Object System.Windows.Controls.ColumnDefinition
    $c1.Width = New-Object System.Windows.GridLength(18)
    $c2 = New-Object System.Windows.Controls.ColumnDefinition
    $c2.Width = New-Object System.Windows.GridLength(1, [System.Windows.GridUnitType]::Star)
    $c3 = New-Object System.Windows.Controls.ColumnDefinition
    $c3.Width = New-Object System.Windows.GridLength(18)
    [void]$grid.ColumnDefinitions.Add($c1)
    [void]$grid.ColumnDefinitions.Add($c2)
    [void]$grid.ColumnDefinitions.Add($c3)

    $swatch = New-Object System.Windows.Controls.Border
    $swatch.Width = 11
    $swatch.Height = 11
    $swatch.CornerRadius = New-Object System.Windows.CornerRadius(3)
    $swatch.Background = Get-Brush $t.ActiveBtnColor
    $swatch.BorderBrush = Get-Brush $t.AccentColor
    $swatch.BorderThickness = New-Object System.Windows.Thickness(1)
    $swatch.VerticalAlignment = "Center"
    [System.Windows.Controls.Grid]::SetColumn($swatch, 0)
    [void]$grid.Children.Add($swatch)

    $label = New-Object System.Windows.Controls.TextBlock
    $label.Text = $t.Name
    Set-ThemeRef $label "Foreground" "LogFg"
    $label.VerticalAlignment = "Center"
    $label.Margin = New-Object System.Windows.Thickness(8, 0, 10, 0)
    [System.Windows.Controls.Grid]::SetColumn($label, 1)
    [void]$grid.Children.Add($label)

    $check = New-Object System.Windows.Controls.TextBlock
    $check.Text = Decode-U "\u2713"
    $check.FontWeight = "Bold"
    $check.Foreground = Get-Brush $t.AccentColor
    $check.VerticalAlignment = "Center"
    $check.HorizontalAlignment = "Right"
    $check.Margin = New-Object System.Windows.Thickness(0, 0, 2, 0)
    $check.Visibility = if ($key -eq $script:ThemeName) { "Visible" } else { "Hidden" }
    [System.Windows.Controls.Grid]::SetColumn($check, 2)
    [void]$grid.Children.Add($check)

    $row.Child = $grid
    $row.Add_MouseEnter({ param($s, $e) $s.Background = Get-Brush $script:Theme.HoverBg })
    $row.Add_MouseLeave({ param($s, $e) $s.Background = Get-Brush "Transparent" })
    $row.Add_MouseLeftButtonUp({
        param($s, $e)
        $script:ThemePopup.IsOpen = $false
        Apply-PetraTheme ([string]$s.Tag)
    })
    return $row
}

function Show-ThemePopup {
    $panel = New-Object System.Windows.Controls.StackPanel
    foreach ($key in @("SolarEclipse", "DeepOcean")) {
        [void]$panel.Children.Add((New-ThemeMenuRow $key))
    }

    $card = New-Object System.Windows.Controls.Border
    Set-ThemeRef $card "Background" "PanelBg"
    Set-ThemeRef $card "BorderBrush" "BorderBrushColor"
    $card.BorderThickness = New-Object System.Windows.Thickness(1)
    $card.CornerRadius = New-Object System.Windows.CornerRadius(8)
    $card.Padding = New-Object System.Windows.Thickness(5)
    $card.MinWidth = 192
    $card.Margin = New-Object System.Windows.Thickness(10)
    $card.Child = $panel

    try {
        $shadow = New-Object System.Windows.Media.Effects.DropShadowEffect
        $shadow.BlurRadius = 14
        $shadow.ShadowDepth = 3
        $shadow.Opacity = 0.55
        $shadow.Color = [System.Windows.Media.Colors]::Black
        $card.Effect = $shadow
    } catch {}

    $script:ThemePopupCard = $card
    $script:ThemePopup.Child = $card
}

function Show-ThemePopupFor($button) {
    Show-ThemePopup
    $script:ThemePopup.PlacementTarget = $button
    $popupWidth = 0
    try {
        $script:ThemePopupCard.Measure((New-Object System.Windows.Size([double]::PositiveInfinity, [double]::PositiveInfinity)))
        $popupWidth = $script:ThemePopupCard.DesiredSize.Width
    } catch {}
    if ($popupWidth -gt $button.ActualWidth) {
        $script:ThemePopup.HorizontalOffset = -($popupWidth - $button.ActualWidth)
    } else {
        $script:ThemePopup.HorizontalOffset = 0
    }
    $script:ThemePopup.IsOpen = $true
}

function Initialize-ThemePopup {
    $popup = New-Object System.Windows.Controls.Primitives.Popup
    $popup.Placement = [System.Windows.Controls.Primitives.PlacementMode]::Bottom
    $popup.StaysOpen = $true
    $popup.AllowsTransparency = $true
    $popup.PopupAnimation = [System.Windows.Controls.Primitives.PopupAnimation]::Fade
    $popup.VerticalOffset = 2
    $script:ThemePopup = $popup
    $popup.Add_Opened({
        $target = $script:ThemePopup.PlacementTarget
        if (-not $target) { return }
        $popupWidth = 0
        try { $popupWidth = $script:ThemePopupCard.DesiredSize.Width } catch {}
        if ($popupWidth -gt $target.ActualWidth) {
            $script:ThemePopup.HorizontalOffset = -($popupWidth - $target.ActualWidth)
        } else {
            $script:ThemePopup.HorizontalOffset = 0
        }
    })

    foreach ($b in @($script:BtnTheme, $script:BtnThemeCollapsed)) {
        if (-not $b) { continue }
        $b.Add_Click({
            if ($script:ThemePopup.IsOpen) { $script:ThemePopup.IsOpen = $false }
            else { Show-ThemePopupFor $this }
        })
    }

    $script:window.Add_PreviewMouseDown({
        param($s, $e)
        if (-not $script:ThemePopup.IsOpen) { return }
        if ($script:BtnTheme -and $script:BtnTheme.IsMouseOver) { return }
        if ($script:BtnThemeCollapsed -and $script:BtnThemeCollapsed.IsMouseOver) { return }
        $script:ThemePopup.IsOpen = $false
    })
    $script:window.Add_PreviewKeyDown({
        param($s, $e)
        if ($e.Key -eq [System.Windows.Input.Key]::Escape -and $script:ThemePopup.IsOpen) {
            $script:ThemePopup.IsOpen = $false
            $e.Handled = $true
        }
    })
    $script:window.Add_Deactivated({ $script:ThemePopup.IsOpen = $false })
    Update-ThemeButtonVisual
}

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