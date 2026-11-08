# --- SEKME 6: YEDEKLEME & CONFIG DISA/ICE AKTARIM ---
function Export-PetraConfigToPath([string]$path) {
    $exportObj = @{
        Apps      = @($script:SelectedApps.Keys | Where-Object { $script:SelectedApps[$_] -eq $true })
        Tweaks    = @($script:TweakCheckboxes.Keys | Where-Object { $script:TweakCheckboxes[$_].IsChecked -eq $true })
        Features  = @($script:FeatureCheckboxes.Keys | Where-Object { $script:FeatureCheckboxes[$_].IsChecked -eq $true })
        Bloatware = @($script:BloatCheckboxes.Keys | Where-Object { $script:BloatCheckboxes[$_].IsChecked -eq $true })
    }
    $exportObj | ConvertTo-Json -Depth 5 | Set-Content -Path $path -Encoding UTF8
    return $true
}

function Import-PetraConfigFile([string]$path) {
    try {
        $raw = Get-Content -LiteralPath $path -Raw -Encoding UTF8
        if ([string]::IsNullOrWhiteSpace($raw)) { throw "Dosya bos." }
        $imp = $raw | ConvertFrom-Json -ErrorAction Stop
        if ($null -eq $imp) { throw "Gecersiz JSON icerigi." }

        $validIds = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::OrdinalIgnoreCase)
        foreach ($knownId in @($sync.AllAppIds)) { [void]$validIds.Add([string]$knownId) }
        $validAppIds = @{}
        foreach ($id in @($imp.Apps)) {
            if ([string]::IsNullOrWhiteSpace([string]$id)) { continue }
            $fixedId = Resolve-WingetId ([string]$id).Trim()
            # Sadece gercekten config'de bulunan uygulamalari sec (hayalet secim olusmasin).
            if ($validIds.Contains($fixedId)) { $validAppIds[$fixedId] = $true }
        }
        foreach ($id in $validAppIds.Keys) {
            $script:SelectedApps[$id] = $true
            if ($script:AllAppCheckboxes.ContainsKey($id)) { $script:AllAppCheckboxes[$id].IsChecked = $true }
        }
        foreach ($t in @($imp.Tweaks)) {
            $tKey = Get-OrdinalIgnoreCaseKey $script:TweakCheckboxes ([string]$t)
            if ($tKey) { $script:TweakCheckboxes[$tKey].IsChecked = $true }
        }
        foreach ($f in @($imp.Features)) {
            $fKey = Get-OrdinalIgnoreCaseKey $script:FeatureCheckboxes ([string]$f)
            if ($fKey) { $script:FeatureCheckboxes[$fKey].IsChecked = $true }
        }
        foreach ($b in @($imp.Bloatware)) {
            $bKey = Get-OrdinalIgnoreCaseKey $script:BloatCheckboxes ([string]$b)
            if ($bKey) { $script:BloatCheckboxes[$bKey].IsChecked = $true }
        }
        # Arama filtresi aktifse ice aktarilan secimler gorunmesin; filtreyi temizle.
        if ($script:TxtSearch -and -not [string]::IsNullOrWhiteSpace($script:TxtSearch.Text)) {
            $script:SearchDebounceTimer.Stop()
            $script:TxtSearch.Text = ""
        }
        Render-Apps
        Update-AllSelectionCounts
        Write-UiLog ("[OK] Yapilandirma yuklendi (mevcut secimlere eklendi): " + $path)
        return $true
    } catch {
        Write-UiLog ("[!] Yapilandirma yuklenemedi: " + $_.Exception.Message)
        return $false
    }
}

$script:BtnExportConfig.Add_Click({
    $dlg = New-Object Microsoft.Win32.SaveFileDialog
    $dlg.Filter = "JSON Config (*.json)|*.json"
    $dlg.FileName = "PetraOmniTool_Config.json"
    if ($dlg.ShowDialog() -eq $true) {
        try {
            [void](Export-PetraConfigToPath $dlg.FileName)
            Write-UiLog ("[OK] Yapilandirma kaydedildi: " + $dlg.FileName)
        } catch {
            Write-UiLog ("[!] Yapilandirma kaydedilemedi: " + $_.Exception.Message)
        }
    }
})

$script:BtnImportConfig.Add_Click({
    $dlg = New-Object Microsoft.Win32.OpenFileDialog
    $dlg.Filter = "JSON Config (*.json)|*.json"
    if ($dlg.ShowDialog() -ne $true) { return }
    [void](Import-PetraConfigFile $dlg.FileName)
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
            "=== PETRA OMNITOOL v4.0 SISTEM RAPORU ===",
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
    try {
        if ($script:TxtRemoteCmd -and -not [string]::IsNullOrWhiteSpace($script:TxtRemoteCmd.Text)) {
            [System.Windows.Clipboard]::SetText($script:TxtRemoteCmd.Text)
        } else {
            [System.Windows.Clipboard]::SetText("irm evrantool.evranumut.workers.dev | iex")
        }
        Write-UiLog (Decode-U "[OK] Uzaktan calistirma komutu panoya kopyalandi.")
    } catch {
        Write-UiLog ("[!] Pano erisimi basarisiz: " + $_.Exception.Message)
    }
})

$script:BtnClearLog.Add_Click({
    $script:TxtLog.Document.Blocks.Clear()
})

function Save-PetraLogToFile([string]$path) {
    if (-not $script:TxtLog -or [string]::IsNullOrWhiteSpace($path)) { return $false }
    try {
        $range = New-Object System.Windows.Documents.TextRange($script:TxtLog.Document.ContentStart, $script:TxtLog.Document.ContentEnd)
        [System.IO.File]::WriteAllText($path, $range.Text, (New-Object System.Text.UTF8Encoding($true)))
        return $true
    } catch {
        return $false
    }
}

$script:BtnSaveLog.Add_Click({
    $dlg = New-Object Microsoft.Win32.SaveFileDialog
    $dlg.Filter = "Metin Dosyasi (*.txt)|*.txt|Tum Dosyalar (*.*)|*.*"
    $dlg.FileName = "Petra_Log_" + (Get-Date -Format "yyyyMMdd_HHmmss") + ".txt"
    if ($dlg.ShowDialog() -eq $true) {
        if (Save-PetraLogToFile $dlg.FileName) {
            Write-UiLog ("[OK] Konsol kaydedildi: " + $dlg.FileName)
        } else {
            Write-UiLog ("[!] Konsol kaydedilemedi: " + $dlg.FileName)
        }
    }
})