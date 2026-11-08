# --- SEKME 1: UYGULAMA KATEGORILERI, UST VITRIN VE LOGOLU LISTE RENDER ---
function Update-CategoryPillStyles {
    foreach ($key in $script:CategoryButtons.Keys) {
        $b = $script:CategoryButtons[$key]
        if ($key -eq $script:ActiveCategory) {
            Set-ThemeRef $b "Background" "ActiveBtnColor"
            $b.Foreground  = Get-Brush "#FFFFFF"
            Set-ThemeRef $b "BorderBrush" "AccentColor"
        } elseif ($key -eq "INSTALLED") {
            Set-ThemeRef $b "Background" "SuccessBg"
            Set-ThemeRef $b "Foreground" "SuccessFg"
            Set-ThemeRef $b "BorderBrush" "SuccessBorder"
        } else {
            Set-ThemeRef $b "Background" "CardBg"
            Set-ThemeRef $b "Foreground" "TextMuted"
            Set-ThemeRef $b "BorderBrush" "BorderBrushColor"
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
    $installedItems = @($installedItems)

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
            Set-ThemeRef $tile "Background" "SelectedBg"
            Set-ThemeRef $tile "BorderBrush" "SelectedBorder"
        } else {
            Set-ThemeRef $tile "Background" "CardBg"
            Set-ThemeRef $tile "BorderBrush" "SuccessBorder"
        }

        $sp = New-Object System.Windows.Controls.StackPanel
        $sp.HorizontalAlignment = "Center"

        $iconHost = New-Object System.Windows.Controls.Grid
        $iconHost.Width = 28
        $iconHost.Height = 28
        $iconHost.HorizontalAlignment = "Center"
        $iconHost.Margin = New-Object System.Windows.Thickness(0, 0, 0, 4)

        $fbBorder = New-Object System.Windows.Controls.Border
        Set-ThemeRef $fbBorder "Background" "HoverBg"
        Set-ThemeRef $fbBorder "BorderBrush" "SuccessBorder"
        $fbBorder.BorderThickness = New-Object System.Windows.Thickness(1)
        $fbBorder.CornerRadius = New-Object System.Windows.CornerRadius(6)

        $cleanName = $app.Name.TrimStart('.')
        $initChar = if ($cleanName.Length -gt 0) { $cleanName.Substring(0, 1).ToUpperInvariant() } else { "A" }
        $fbTxt = New-Object System.Windows.Controls.TextBlock
        $fbTxt.Text = $initChar
        $fbTxt.FontSize = 12
        $fbTxt.FontWeight = "Bold"
        Set-ThemeRef $fbTxt "Foreground" "SuccessFg"
        $fbTxt.HorizontalAlignment = "Center"
        $fbTxt.VerticalAlignment = "Center"
        $fbBorder.Child = $fbTxt
        [void]$iconHost.Children.Add($fbBorder)

        if ($app.PSObject.Properties["Icon"] -and -not [string]::IsNullOrWhiteSpace($app.Icon)) {
            $img = New-Object System.Windows.Controls.Image
            $img.Width = 24
            $img.Height = 24
            $img.Stretch = [System.Windows.Media.Stretch]::Uniform
            $img.HorizontalAlignment = "Center"
            $img.VerticalAlignment = "Center"
            [System.Windows.Media.RenderOptions]::SetBitmapScalingMode($img, [System.Windows.Media.BitmapScalingMode]::HighQuality)
            $img.Visibility = "Collapsed"
            [void]$iconHost.Children.Add($img)

            $cachedSource = Get-CachedImageSource $app.Icon
            if ($cachedSource) {
                $img.Source = $cachedSource
                $img.Visibility = "Visible"
                $fbBorder.Visibility = "Collapsed"
            } else {
                $fbBorder.Visibility = "Visible"
            }
            [void]$script:IconTargets.Add(@{ Url = $app.Icon; Image = $img; Fallback = $fbBorder })
        }
        [void]$sp.Children.Add($iconHost)

        $nameTxt = New-Object System.Windows.Controls.TextBlock
        $nameTxt.Text = $app.Name
        $nameTxt.FontSize = 10
        $nameTxt.FontWeight = "SemiBold"
        $nameTxt.Foreground = Get-Brush "#F4F4F5"
        $nameTxt.HorizontalAlignment = "Center"
        $nameTxt.TextAlignment = "Center"
        $nameTxt.TextTrimming = "CharacterEllipsis"
        $nameTxt.MaxWidth = 74
        [void]$sp.Children.Add($nameTxt)

        $statusTxt = New-Object System.Windows.Controls.TextBlock
        $statusTxt.Text = Decode-U "\u25CF Yuklu"
        $statusTxt.FontSize = 9.5
        $statusTxt.FontWeight = "Bold"
        Set-ThemeRef $statusTxt "Foreground" "SuccessFg"
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
            if ($script:AllAppCheckboxes.ContainsKey($pkgId)) {
                $script:AllAppCheckboxes[$pkgId].IsChecked = $newState
            }
            Update-AllSelectionCounts
        })

        [void]$script:InstalledAppsStrip.Children.Add($tile)
        $script:StripBadges[$app.Id] = $tile
    }
}

# Kart secim/hover durumuna gore arka plan ve kenarligi gunceller.
function Update-AppCardVisual([string]$appId) {
    $card = $script:AppCards[$appId]
    if ($null -eq $card) { return }
    $isSel = ($script:SelectedApps[$appId] -eq $true)
    $isInst = ($sync.InstalledApps -and $sync.InstalledApps[$appId] -eq $true)
    if ($isSel) {
        Set-ThemeRef $card "Background" "SelectedBg"
        Set-ThemeRef $card "BorderBrush" "SelectedBorder"
        $card.BorderThickness = New-Object System.Windows.Thickness(1.5)
    } elseif ($isInst) {
        Set-ThemeRef $card "Background" "CardBg"
        Set-ThemeRef $card "BorderBrush" "SuccessBorder"
        $card.BorderThickness = New-Object System.Windows.Thickness(1)
    } else {
        Set-ThemeRef $card "Background" "CardBg"
        Set-ThemeRef $card "BorderBrush" "BorderBrushColor"
        $card.BorderThickness = New-Object System.Windows.Thickness(1)
    }
}

function Render-Apps {
    # Kartlar bir kez olusturulur; arama/kategori filtreleri artik sadece
    # gorunurlugu degistirir. Boylece her arama tusunda 280 kart yeniden
    # cizilmez ve arayuz donmaz.
    if (-not $script:AppsBuilt) {
        Build-AppsUI
        $script:AppsBuilt = $true
    }
    Apply-AppFilter
}

# Tum uygulama kartlarini bir kez olusturur (filtre uygulamaz).
function Build-AppsUI {
    $script:IconTargets = New-Object System.Collections.ArrayList
    $script:IconRefreshIndex = 0
    Render-InstalledStrip
    $script:MainStackPanel.Children.Clear()
    $script:AppCheckboxes.Clear()
    $script:AllAppCheckboxes.Clear()
    $script:AppCards.Clear()
    $script:AppCardMeta.Clear()
    $script:AppCategoryGroups = @()

    foreach ($cat in $script:AppCategories) {
        $catName = $cat.Category

        $catHeader = New-Object System.Windows.Controls.TextBlock
        $catHeader.Text = $catName
        $catHeader.FontSize = 14
        $catHeader.FontWeight = "Bold"
        Set-ThemeRef $catHeader "Foreground" "AccentColor"
        $catHeader.Margin = New-Object System.Windows.Thickness(6, 18, 6, 8)
        [void]$script:MainStackPanel.Children.Add($catHeader)

        $wrap = New-Object System.Windows.Controls.Primitives.UniformGrid
        $wrap.Columns = 2

        $groupCards = @()
        foreach ($app in $cat.Apps) {
            $isInstalled = ($sync.InstalledApps -and $sync.InstalledApps[$app.Id] -eq $true)

            $card = New-Object System.Windows.Controls.Border
            Set-ThemeRef $card "Background" "CardBg"
            if ($isInstalled) { Set-ThemeRef $card "BorderBrush" "SuccessBorder" }
            else { Set-ThemeRef $card "BorderBrush" "BorderBrushColor" }
            $card.BorderThickness = New-Object System.Windows.Thickness(1)
            $card.CornerRadius = New-Object System.Windows.CornerRadius(8)
            $card.Padding = New-Object System.Windows.Thickness(12, 10, 12, 10)
            $card.Margin = New-Object System.Windows.Thickness(5)
            $card.Cursor = [System.Windows.Input.Cursors]::Hand
            $script:AppCards[$app.Id] = $card
            if ($script:SelectedApps[$app.Id] -eq $true) {
                Set-ThemeRef $card "Background" "SelectedBg"
                Set-ThemeRef $card "BorderBrush" "SelectedBorder"
                $card.BorderThickness = New-Object System.Windows.Thickness(1.5)
            }

            $rowGrid = New-Object System.Windows.Controls.Grid
            $colIcon = New-Object System.Windows.Controls.ColumnDefinition
            $colIcon.Width = New-Object System.Windows.GridLength(54)
            $colText = New-Object System.Windows.Controls.ColumnDefinition
            $colText.Width = New-Object System.Windows.GridLength(1, [System.Windows.GridUnitType]::Star)
            [void]$rowGrid.ColumnDefinitions.Add($colIcon)
            [void]$rowGrid.ColumnDefinitions.Add($colText)

            $leftStack = New-Object System.Windows.Controls.StackPanel
            $leftStack.HorizontalAlignment = "Center"
            $leftStack.VerticalAlignment = "Top"
            $leftStack.Margin = New-Object System.Windows.Thickness(0, 1, 8, 0)

            $iconHost = New-Object System.Windows.Controls.Grid
            $iconHost.Width = 40
            $iconHost.Height = 40
            $iconHost.HorizontalAlignment = "Center"

            $fallbackBorder = New-Object System.Windows.Controls.Border
            Set-ThemeRef $fallbackBorder "Background" "HoverBg"
            if ($isInstalled) { $fallbackBorder.BorderBrush = Get-Brush "#22543D" }
            else { Set-ThemeRef $fallbackBorder "BorderBrush" "BorderBrushColor" }
            $fallbackBorder.BorderThickness = New-Object System.Windows.Thickness(1)
            $fallbackBorder.CornerRadius = New-Object System.Windows.CornerRadius(6)

            $cleanName = $app.Name.TrimStart('.')
            $initialChar = if ($cleanName.Length -gt 0) { $cleanName.Substring(0, 1).ToUpperInvariant() } else { "A" }
            $fallbackText = New-Object System.Windows.Controls.TextBlock
            $fallbackText.Text = $initialChar
            $fallbackText.FontSize = 14
            $fallbackText.FontWeight = "Bold"
            if ($isInstalled) { Set-ThemeRef $fallbackText "Foreground" "SuccessFg" }
            else { Set-ThemeRef $fallbackText "Foreground" "AccentColor" }
            $fallbackText.HorizontalAlignment = "Center"
            $fallbackText.VerticalAlignment = "Center"
            $fallbackBorder.Child = $fallbackText
            [void]$iconHost.Children.Add($fallbackBorder)

            if ($app.PSObject.Properties["Icon"] -and -not [string]::IsNullOrWhiteSpace($app.Icon)) {
                $logoImg = New-Object System.Windows.Controls.Image
                $logoImg.Width = 30
                $logoImg.Height = 30
                $logoImg.Stretch = [System.Windows.Media.Stretch]::Uniform
                $logoImg.HorizontalAlignment = "Center"
                $logoImg.VerticalAlignment = "Center"
                [System.Windows.Media.RenderOptions]::SetBitmapScalingMode($logoImg, [System.Windows.Media.BitmapScalingMode]::HighQuality)
                $logoImg.Visibility = "Collapsed"
                [void]$iconHost.Children.Add($logoImg)

                $cachedSource = Get-CachedImageSource $app.Icon
                if ($cachedSource) {
                    $logoImg.Source = $cachedSource
                    $logoImg.Visibility = "Visible"
                    $fallbackBorder.Visibility = "Collapsed"
                } else {
                    $fallbackBorder.Visibility = "Visible"
                }
                [void]$script:IconTargets.Add(@{ Url = $app.Icon; Image = $logoImg; Fallback = $fallbackBorder })
            }
            [void]$leftStack.Children.Add($iconHost)

            $instBadge = New-Object System.Windows.Controls.Border
            Set-ThemeRef $instBadge "Background" "SuccessBg"
            Set-ThemeRef $instBadge "BorderBrush" "SuccessBorder"
            $instBadge.BorderThickness = New-Object System.Windows.Thickness(1)
            $instBadge.CornerRadius = New-Object System.Windows.CornerRadius(3)
            $instBadge.Padding = New-Object System.Windows.Thickness(3, 1, 3, 1)
            $instBadge.Margin = New-Object System.Windows.Thickness(0, 4, 0, 0)
            $instBadge.HorizontalAlignment = "Center"
            $instBadge.Visibility = if ($isInstalled) { "Visible" } else { "Collapsed" }

            $instBadgeTxt = New-Object System.Windows.Controls.TextBlock
            $instBadgeTxt.Text = Decode-U "Y\u00FCkl\u00FC"
            $instBadgeTxt.FontSize = 9
            $instBadgeTxt.FontWeight = "Bold"
            Set-ThemeRef $instBadgeTxt "Foreground" "SuccessFg"
            $instBadgeTxt.HorizontalAlignment = "Center"
            $instBadge.Child = $instBadgeTxt
            [void]$leftStack.Children.Add($instBadge)

            [System.Windows.Controls.Grid]::SetColumn($leftStack, 0)
            [void]$rowGrid.Children.Add($leftStack)

            # Sag Metin ve CheckBox Alani
            $sp = New-Object System.Windows.Controls.StackPanel
            [System.Windows.Controls.Grid]::SetColumn($sp, 1)

            $cb = New-Object System.Windows.Controls.CheckBox
            $cb.Tag = $app.Id
            $cb.IsChecked = ($script:SelectedApps[$app.Id] -eq $true)
            if ($isInstalled) { Set-ThemeRef $cb "Foreground" "SuccessFg" }
            else { $cb.Foreground = Get-Brush "#F4F4F5" }
            $cb.FontWeight = "SemiBold"
            $cb.FontSize = 13
            $cb.Content = $app.Name

            $cb.Add_Checked({
                param($s, $e)
                $script:SelectedApps[[string]$s.Tag] = $true
                Update-AppCardVisual ([string]$s.Tag)
                Update-AllSelectionCounts
            })
            $cb.Add_Unchecked({
                param($s, $e)
                $script:SelectedApps[[string]$s.Tag] = $false
                Update-AppCardVisual ([string]$s.Tag)
                Update-AllSelectionCounts
            })

            $descBlock = New-Object System.Windows.Controls.TextBlock
            $descBlock.Text = $app.Description
            $descBlock.FontSize = 11
            Set-ThemeRef $descBlock "Foreground" "TextMuted"
            $descBlock.TextWrapping = "Wrap"
            $descBlock.Margin = New-Object System.Windows.Thickness(22, 2, 0, 0)

            $idBlock = New-Object System.Windows.Controls.TextBlock
            $idBlock.Text = $app.Id
            $idBlock.FontSize = 10
            Set-ThemeRef $idBlock "Foreground" "TextDim"
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

            # Hover: yumusak yukselme/parlama hissi (arka plan + kenar rengi)
            $card.Add_MouseEnter({
                param($sender, $e)
                $cid = [string]$sender.Tag.Tag
                if ($script:SelectedApps[$cid] -ne $true) {
                    Set-ThemeRef $sender "Background" "HoverBg"
                    Set-ThemeRef $sender "BorderBrush" "AccentColor"
                }
            })
            $card.Add_MouseLeave({
                param($sender, $e)
                Update-AppCardVisual ([string]$sender.Tag.Tag)
            })

            [void]$wrap.Children.Add($card)
            $script:AllAppCheckboxes[$app.Id] = $cb
            $script:AppCardMeta[$app.Id] = @{
                Badge          = $instBadge
                Cb             = $cb
                FallbackBorder = $fallbackBorder
                FallbackText   = $fallbackText
            }
            $groupCards += @{ App = $app; Card = $card }
        }
        [void]$script:MainStackPanel.Children.Add($wrap)
        $script:AppCategoryGroups += @{
            Name   = $catName
            Header = $catHeader
            Wrap   = $wrap
            Cards  = $groupCards
        }
    }
}

# Kategori + arama filtresini sadece gorunurluk uzerinden uygular (hizli).
function Apply-AppFilter {
    $query = ""
    if ($script:TxtSearch) { $query = $script:TxtSearch.Text.Trim().ToLowerInvariant() }
    $script:AppCheckboxes.Clear()
    $active = $script:ActiveCategory

    foreach ($group in $script:AppCategoryGroups) {
        $catName = $group.Name
        $catVisible = ($active -eq "ALL" -or $active -eq "INSTALLED" -or $active -eq $catName)
        $shown = 0
        foreach ($entry in $group.Cards) {
            $app = $entry.App
            $card = $entry.Card
            $visible = $catVisible
            if ($visible -and $active -eq "INSTALLED" -and (-not $sync.InstalledApps -or $sync.InstalledApps[$app.Id] -ne $true)) {
                $visible = $false
            }
            if ($visible -and -not [string]::IsNullOrEmpty($query)) {
                $visible = ($app.Name.ToLowerInvariant().Contains($query) -or
                            $app.Id.ToLowerInvariant().Contains($query) -or
                            $app.Description.ToLowerInvariant().Contains($query))
            }
            $card.Visibility = if ($visible) { "Visible" } else { "Collapsed" }
            if ($visible) {
                $shown++
                $script:AppCheckboxes[$app.Id] = $script:AllAppCheckboxes[$app.Id]
            }
        }
        $group.Header.Text = "$catName ($shown)"
        $group.Header.Visibility = if ($shown -gt 0) { "Visible" } else { "Collapsed" }
        $group.Wrap.Visibility = if ($shown -gt 0) { "Visible" } else { "Collapsed" }
    }
    Update-AllSelectionCounts
}

# Kurulu durumu degisen kartlarin rozet/renklerini yeniden olusturmadan gunceller.
function Update-InstalledCardVisuals {
    foreach ($id in @($script:AppCards.Keys)) {
        Update-AppCardVisual $id
        $meta = $script:AppCardMeta[$id]
        if (-not $meta) { continue }
        $isInst = ($sync.InstalledApps -and $sync.InstalledApps[$id] -eq $true)
        if ($meta.Badge) { $meta.Badge.Visibility = if ($isInst) { "Visible" } else { "Collapsed" } }
        if ($isInst) {
            Set-ThemeRef $meta.Cb "Foreground" "SuccessFg"
            $meta.FallbackBorder.BorderBrush = Get-Brush "#22543D"
            Set-ThemeRef $meta.FallbackText "Foreground" "SuccessFg"
        } else {
            $meta.Cb.Foreground = Get-Brush "#F4F4F5"
            Set-ThemeRef $meta.FallbackBorder "BorderBrush" "BorderBrushColor"
            Set-ThemeRef $meta.FallbackText "Foreground" "AccentColor"
        }
    }
}

# Arka plan Runspace'ten yeniden cizim istegini guvenli sekilde iletmek icin bayrak.
# (ScriptBlock'i baska runspace icinden Dispatcher'a cagirmak kilitlenmeye yol acabilir.)
$sync.RenderRequested = $false

# Ikonlari tek seferde degil, kucuk partiler halinde guncelle (UI donmasini engeller).
function Update-RenderedIcons([int]$BatchSize = 20) {
    $targets = $script:IconTargets
    if ($null -eq $targets -or $script:IconRefreshIndex -ge $targets.Count) { return $true }
    $end = [Math]::Min($script:IconRefreshIndex + $BatchSize, $targets.Count)
    for ($i = $script:IconRefreshIndex; $i -lt $end; $i++) {
        $t = $targets[$i]
        if ($null -eq $t) { continue }
        if ($null -ne $t.Image.Source) { continue }
        $src = Get-CachedImageSource $t.Url
        if ($src) {
            $t.Image.Source = $src
            $t.Image.Visibility = "Visible"
            $t.Fallback.Visibility = "Collapsed"
        }
    }
    $script:IconRefreshIndex = $end
    return ($script:IconRefreshIndex -ge $targets.Count)
}

$script:IconRefreshIndex = 0
$script:IconRefreshTimer = New-Object System.Windows.Threading.DispatcherTimer
$script:IconRefreshTimer.Interval = [TimeSpan]::FromMilliseconds(100)
$script:IconRefreshTimer.Add_Tick({
    # Arka plan runspace'lerinden gelen log/status mesajlarini UI thread'inde uygula.
    $drain = 0
    while ($sync.UiQueue.Count -gt 0 -and $drain -lt 60) {
        $msg = $sync.UiQueue.Dequeue()
        $drain++
        if ($null -eq $msg) { continue }
        if ($msg.Kind -eq "log") {
            Add-UiLogLine ([string]$msg.Text)
        } else {
            if ($script:TxtStatus) {
                $script:TxtStatus.Text = [string]$msg.Text
                try { $script:TxtStatus.Foreground = Get-Brush (Get-LogLineColor ([string]$msg.Text)) } catch { }
            }
            if ($null -ne $msg.Progress -and [double]$msg.Progress -ge 0 -and $script:ProgressBarMain) {
                $script:ProgressBarMain.Value = [double]$msg.Progress
            }
        }
    }

    if ($sync.RenderRequested) {
        $sync.RenderRequested = $false
        # Arka plan taramasi listeyi yenilerken kullanicinin kaydirma konumunu koru.
        $refreshOffset = Get-PanelScrollOffset $script:MainStackPanel
        try { Update-InstalledCardVisuals } catch {}
        try { Render-InstalledStrip } catch {}
        Render-Apps
        $refreshSv = Find-PanelScrollViewer $script:MainStackPanel
        if ($refreshSv -and $refreshOffset -gt 0) {
            $refreshSv.UpdateLayout()
            $refreshSv.ScrollToVerticalOffset($refreshOffset)
        }
        return
    }
    if (-not $sync.IconDownloadsReady) { return }
    if ($script:IconRefreshIndex -lt $script:IconTargets.Count) {
        [void](Update-RenderedIcons 20)
    }
})
$script:IconRefreshTimer.Start()

$script:SearchDebounceTimer = New-Object System.Windows.Threading.DispatcherTimer
$script:SearchDebounceTimer.Interval = [TimeSpan]::FromMilliseconds(250)
$script:SearchDebounceTimer.Add_Tick({
    $script:SearchDebounceTimer.Stop()
    Render-Apps
})
$script:TxtSearch.Add_TextChanged({
    $script:SearchDebounceTimer.Stop()
    $script:SearchDebounceTimer.Start()
})
$script:BtnClearSearch.Add_Click({
    # Bu dugme arama kutusunun yaninda duruyor; kullanici buradan hem aramayi
    # hem de secili uygulamalari temizleyebilmeli.
    $hadSearch = ($script:TxtSearch.Text.Length -gt 0)
    $hadSelection = $false
    foreach ($id in @($script:SelectedApps.Keys)) {
        if ($script:SelectedApps[$id] -eq $true) { $hadSelection = $true; break }
    }

    $script:TxtSearch.Text = ""
    if ($hadSelection) {
        foreach ($cb in $script:AllAppCheckboxes.Values) {
            if ($cb.IsChecked -eq $true) { $cb.IsChecked = $false }
        }
        $script:SelectedApps.Clear()
        $script:ActiveAppPresetIds = @()
        Update-AllSelectionCounts
    }

    $script:SearchDebounceTimer.Stop()
    Render-Apps

    if ($hadSelection -and $hadSearch) {
        Write-UiLog (Decode-U "[i] Arama ve secili uygulamalar temizlendi.")
    } elseif ($hadSelection) {
        Write-UiLog (Decode-U "[i] Secili uygulamalar temizlendi.")
    } elseif ($hadSearch) {
        Write-UiLog (Decode-U "[i] Arama temizlendi.")
    }
})

# Ctrl+F: uygulama sekmesine gec ve arama kutusuna odaklan.
function Focus-AppSearch {
    try {
        if ($script:ActiveTab -ne "Apps") { Switch-Tab "Apps" }
        [void]$script:TxtSearch.Focus()
        $script:TxtSearch.SelectAll()
    } catch {}
}

function Add-AppSearchShortcut {
    if (-not $script:window) { return }
    $script:window.Add_PreviewKeyDown({
        param($s, $e)
        if ($e.Key -eq [System.Windows.Input.Key]::F -and
            ([System.Windows.Input.Keyboard]::Modifiers -band [System.Windows.Input.ModifierKeys]::Control)) {
            Focus-AppSearch
            $e.Handled = $true
        }
    })
}

# --- PRESET SECIM FONKSIYONU (PROFILLER ARASI GECISTE OTOMATIK DEGISIR) ---
function Select-AppPreset([string[]]$ids, [string]$presetTitle) {
    # Yeni profilin kimliklerini coz ve tekillestir.
    $newIds = @()
    foreach ($rawId in $ids) {
        $rid = Resolve-WingetId $rawId
        if (-not [string]::IsNullOrWhiteSpace($rid)) { $newIds += $rid }
    }
    $newIds = @($newIds | Select-Object -Unique)
    $newSet = @{}
    foreach ($id in $newIds) { $newSet[$id] = $true }

    # Onceki profilin ekledigi, yeni profilde olmayan secimleri kaldir.
    $removed = 0
    foreach ($oldId in @($script:ActiveAppPresetIds)) {
        if ($newSet.ContainsKey($oldId)) { continue }
        if ($script:SelectedApps[$oldId] -eq $true) { $removed++ }
        $script:SelectedApps[$oldId] = $false
        if ($script:AllAppCheckboxes.ContainsKey($oldId)) {
            $script:AllAppCheckboxes[$oldId].IsChecked = $false
        }
    }

    # Yeni profilin uygulamalarini sec (manuel secimler korunur).
    $added = 0
    foreach ($id in $newIds) {
        if ($script:SelectedApps[$id] -ne $true) { $added++ }
        $script:SelectedApps[$id] = $true
        if ($script:AllAppCheckboxes.ContainsKey($id)) {
            $script:AllAppCheckboxes[$id].IsChecked = $true
        }
    }
    $script:ActiveAppPresetIds = $newIds
    Update-AllSelectionCounts
    Switch-Tab "Apps"
    Write-UiLog (Decode-U "[+] $presetTitle uygulandi (+$added eklendi, -$removed cikarildi; manuel secimler korundu).")
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
    foreach ($cb in $script:AllAppCheckboxes.Values) { $cb.IsChecked = $false }
    foreach ($cb in $script:TweakCheckboxes.Values) { $cb.IsChecked = $false }
    foreach ($cb in $script:FeatureCheckboxes.Values) { $cb.IsChecked = $false }
    foreach ($cb in $script:BloatCheckboxes.Values) { $cb.IsChecked = $false }
    # Unchecked isleyicileri secimi tekrar false olarak ekledigi icin en sona birak.
    $script:SelectedApps.Clear()
    Update-AllSelectionCounts
    Write-UiLog (Decode-U "[i] Tum menulerdeki secimler temizlendi.")
})