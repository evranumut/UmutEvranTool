# --- YEREL IKON ONBELLEK MOTORU (JPEG 0xFF 0xD9 HATASINI ENGELLEYEN SISTEM) ---
$script:IconCacheDir = Join-Path $env:TEMP "UET_IconCache"
if (!(Test-Path $script:IconCacheDir)) {
    New-Item -Path $script:IconCacheDir -ItemType Directory -Force | Out-Null
}
$script:IconMemoryCache = @{}
$script:IconTargets = New-Object System.Collections.ArrayList
$sync.IconDownloadsReady = $false
$sync.IconFailures = [Hashtable]::Synchronized(@{})
# Arka plan runspace'leri UI'ye dogrudan Dispatcher.Invoke ile degil, bu kuyruk uzerinden yazar.
$sync.UiQueue = [System.Collections.Queue]::Synchronized((New-Object System.Collections.Queue))

function Get-CachedImageSource([string]$url) {
    if ([string]::IsNullOrWhiteSpace($url)) { return $null }
    if ($script:IconMemoryCache.ContainsKey($url)) { return $script:IconMemoryCache[$url] }
    if ($sync.IconFailures.ContainsKey($url)) { return $null }
    try {
        $hash = [System.BitConverter]::ToString([System.Security.Cryptography.MD5]::Create().ComputeHash([System.Text.Encoding]::UTF8.GetBytes($url))).Replace("-", "")
        $cachedFile = Join-Path $script:IconCacheDir "$hash.png"
        $hasCachedFile = (Test-Path $cachedFile) -and ((Get-Item $cachedFile).Length -gt 0)

        # Indirme islemi yalnizca arka plan onbelleginde yapilir; UI thread'i asla beklemez.
        if (-not $hasCachedFile) { return $null }

        $bmp = New-Object System.Windows.Media.Imaging.BitmapImage
        $bmp.BeginInit()
        $bmp.CacheOption = [System.Windows.Media.Imaging.BitmapCacheOption]::OnLoad
        $bmp.DecodePixelWidth = 64
        $bmp.UriSource = New-Object System.Uri($cachedFile, [System.UriKind]::Absolute)
        $bmp.EndInit()
        $bmp.Freeze()
        $script:IconMemoryCache[$url] = $bmp
        return $bmp
    } catch {
        $script:IconMemoryCache[$url] = $null
        return $null
    }
}

function Start-IconPreloader {
    $urls = New-Object System.Collections.Generic.List[string]
    $seen = @{}
    foreach ($cat in $script:AppCategories) {
        foreach ($app in $cat.Apps) {
            if (-not [string]::IsNullOrWhiteSpace($app.Icon) -and -not $seen.ContainsKey($app.Icon)) {
                $seen[$app.Icon] = $true
                $urls.Add($app.Icon)
            }
        }
    }
    if ($urls.Count -eq 0) { $sync.IconDownloadsReady = $true; return }

    try {
        $rs = [runspacefactory]::CreateRunspace()
        $rs.ApartmentState = "MTA"
        $rs.ThreadOptions = "ReuseThread"
        $rs.Open()
    } catch {
        # Ikon onbellegi acilamazsa uygulama yer tutucu harflerle calismaya devam eder.
        $sync.IconDownloadsReady = $true
        return
    }
    $rs.SessionStateProxy.SetVariable("sync", $sync)
    $rs.SessionStateProxy.SetVariable("IconUrls", $urls.ToArray())
    $rs.SessionStateProxy.SetVariable("IconDir", $script:IconCacheDir)

    $ps = [powershell]::Create()
    $ps.Runspace = $rs
    [void]$ps.AddScript({
        foreach ($u in $IconUrls) {
            try {
                $hash = [System.BitConverter]::ToString([System.Security.Cryptography.MD5]::Create().ComputeHash([System.Text.Encoding]::UTF8.GetBytes($u))).Replace("-", "")
                $file = Join-Path $IconDir "$hash.png"
                if ((Test-Path $file) -and ((Get-Item $file).Length -gt 0)) { continue }
                $wc = New-Object System.Net.WebClient
                try {
                    $wc.Headers.Add("User-Agent", "Mozilla/5.0")
                    $bytes = $wc.DownloadData($u)
                    if ($bytes -and $bytes.Length -gt 100) {
                        [System.IO.File]::WriteAllBytes($file, $bytes)
                        $sync.IconFailures.Remove($u)
                    } else {
                        $sync.IconFailures[$u] = $true
                    }
                } finally {
                    $wc.Dispose()
                }
            } catch {
                $sync.IconFailures[$u] = $true
            }
        }
        # UI thread'ini Dispatcher.Invoke ile bloklamadan sadece bayrak set edilir.
        # Ana runspace'teki DispatcherTimer bayragi gorup ikonlari parca parca gunceller.
        $sync.IconDownloadsReady = $true
    })
    try {
        $null = $ps.BeginInvoke()
    } catch {
        $sync.IconDownloadsReady = $true
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