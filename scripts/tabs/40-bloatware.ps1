# --- SEKME 4: BLOATWARE RENDER VE KALDIR / GERI YUKLE ---
function Render-Bloatware {
    $script:BloatwareGrid.Children.Clear()
    $script:BloatCheckboxes.Clear()
    $script:BloatCards.Clear()

    foreach ($b in $script:BloatwareData) {
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
        $cb.Tag = $b
        $cb.Content = Decode-U $b.Name
        $cb.IsChecked = $false
        $cb.Foreground = Get-Brush "#F8FAFC"
        $cb.FontWeight = "SemiBold"
        $cb.FontSize = 12.5
        $cb.Add_Checked({
            param($s, $e)
            Update-SelectionCardVisual $script:BloatCards[[string]$s.Tag.Pkg] $true
            Update-AllSelectionCounts
        })
        $cb.Add_Unchecked({
            param($s, $e)
            Update-SelectionCardVisual $script:BloatCards[[string]$s.Tag.Pkg] $false
            Update-AllSelectionCounts
        })

        $pkgTxt = New-Object System.Windows.Controls.TextBlock
        $pkgTxt.Text = $b.Pkg
        $pkgTxt.FontSize = 10.5
        Set-ThemeRef $pkgTxt "Foreground" "TextDim"
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

        Add-SelectionCardHover $card
        $script:BloatCards[$b.Pkg] = $card
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
    $sel = @($sel)
    if ($sel.Count -eq 0) {
        Write-UiLog (Decode-U "[!] Kaldirilacak en az 1 UWP paketi secin.")
        return
    }
    $msg = "$($sel.Count) UWP paketi tum kullanicilar icin kaldirilacak.`n`nBazi paketler geri kurulabilir, ancak bu islem geri alinamaz. Once 'Sistem Geri Yukleme Noktasi' olusturmaniz onerilir.`n`nDevam etmek istiyor musunuz?"
    if (-not (Confirm-Action $msg)) { return }
    Start-BackgroundTask "Secili Bloatware paketleri kaldiriliyor..." @{ Items = $sel } {
        param($p)
        $okCount = 0
        $absentCount = 0
        $failCount = 0
        foreach ($item in $p.Items) {
            $present = @(Get-AppxPackage -AllUsers $item.Pkg -ErrorAction SilentlyContinue)
            if ($present.Count -eq 0) {
                $absentCount++
                Log-Bg ("[i] Zaten kurulu degil: " + (Decode-Bg $item.Name))
                continue
            }
            Log-Bg ("[-] UWP Kaldiriliyor: " + (Decode-Bg $item.Name))
            Get-AppxPackage -AllUsers $item.Pkg -ErrorAction SilentlyContinue | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
            Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -like $item.Pkg } | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Out-Null
            $remaining = @(Get-AppxPackage -AllUsers $item.Pkg -ErrorAction SilentlyContinue)
            if ($remaining.Count -eq 0) {
                $okCount++
                Log-Bg ("[OK] Kaldirildi: " + (Decode-Bg $item.Name))
            } else {
                $failCount++
                Log-Bg ("[!] Kaldirilamadi veya kismen kaldi: " + (Decode-Bg $item.Name))
            }
        }
        if ($failCount -eq 0) {
            Log-Bg ("[OK] UWP temizligi tamamlandi: $okCount kaldirildi, $absentCount zaten yoktu.")
        } else {
            Log-Bg ("[!] Bloatware temizligi tamamlandi: $okCount kaldirildi, $absentCount zaten yoktu, $failCount basarisiz.")
        }
    }
})

$script:BtnReinstallBloatware.Add_Click({
    $sel = @()
    foreach ($cb in $script:BloatCheckboxes.Values) {
        if ($cb.IsChecked -eq $true -and -not [string]::IsNullOrWhiteSpace($cb.Tag.StoreId)) {
            $sel += $cb.Tag
        }
    }
    $sel = @($sel)
    if ($sel.Count -eq 0) {
        Write-UiLog (Decode-U "[!] Geri yuklenecek StoreId destekli en az 1 paket secin.")
        return
    }
    Start-BackgroundTask "Secili UWP paketleri Microsoft Store uzerinden kuruluyor..." @{ Items = $sel } {
        param($p)
        if (-not (Test-WingetAvailable)) {
            Log-Bg "[!] winget bulunamadi. Microsoft Store'dan 'App Installer' paketini guncelleyin."
            return
        }
        $okCount = 0
        $failCount = 0
        foreach ($item in $p.Items) {
            Log-Bg ("[+] Yeniden Kuruluyor: " + (Decode-Bg $item.Name))
            winget install --id $item.StoreId --source msstore --silent --accept-package-agreements --accept-source-agreements
            if ($LASTEXITCODE -eq 0) {
                $okCount++
                Log-Bg ("[OK] Yeniden kuruldu: " + (Decode-Bg $item.Name))
            } else {
                $failCount++
                Log-Bg ("[!] Yeniden kurulamadi (Cikis Kodu: $LASTEXITCODE): " + (Decode-Bg $item.Name))
            }
        }
        if ($failCount -eq 0) {
            Log-Bg "[OK] Secili UWP paketleri geri yuklendi."
        } else {
            Log-Bg ("[!] Geri yukleme tamamlandi: $okCount basarili, $failCount basarisiz.")
        }
    }
})