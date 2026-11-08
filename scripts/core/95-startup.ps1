# --- BASLANGIC ILKLENDIRMESI ---
# CLI preset modunda arayuzu acma (gelistirme yukleyicisinde de ayni davranis).
if ($script:PetraCliOnly) { return }
try {
    $osInfo = Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue
    if ($osInfo -and $script:TxtSysInfo) {
        $ramGb = [math]::Round($osInfo.TotalVisibleMemorySize / 1MB, 1)
        $script:TxtSysInfo.Text = "$($osInfo.Caption) | $ramGb GB RAM"
    }
} catch {}

# Tema kaynaklarini render'lardan ONCE hazirla: kartlar renklerini bu
# kaynaklara baglar, boylece tema degisiminde yeniden cizim gerekmez.
Set-PetraThemeResources
Initialize-CategoryPills
Render-Apps
try { Start-IconPreloader } catch { $sync.IconDownloadsReady = $true }
Render-Tweaks
Render-Features
Render-Bloatware
Update-AllSelectionCounts
Initialize-ThemePopup

Write-UiLog (Decode-U "[OK] Petra OmniTool v4.0 hazir. Toplam $($script:TotalAppCount) uygulama logolariyla yuklendi.")
Write-UiLog (Decode-U ("[i] Aktif tema: " + $script:Theme.Name))
if ($script:ThemeLoadedFromSettings) {
    Write-UiLog (Decode-U "[i] Kayitli tema tercihi yuklendi (settings.json).")
}
Add-AppSearchShortcut
if ($sync.IsAdmin) {
    Write-UiLog (Decode-U "[i] Yonetici yetkisi: AKTIF")
} else {
    Write-UiLog (Decode-U "[!] Yonetici yetkisi: YOK - bazi sistem ayarlari uygulanamaz.")
}
[void]$script:window.ShowDialog()