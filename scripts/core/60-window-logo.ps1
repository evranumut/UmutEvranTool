# --- XAML Penceresini Yukle ---
$cleanXaml = $sync.Xaml.TrimStart([char]0xFEFF).Trim()
$script:window = [System.Windows.Markup.XamlReader]::Parse($cleanXaml)
$sync.Window = $script:window

# --- Pencere ve Sol Ust Marka Kartina Ozel Logo Entegrasyonu ---
function Get-IcoLogoFrame([string]$path) {
    $stream = [System.IO.File]::OpenRead($path)
    try {
        $decoder = New-Object System.Windows.Media.Imaging.IconBitmapDecoder($stream, [System.Windows.Media.Imaging.BitmapCreateOptions]::PreservePixelFormat, [System.Windows.Media.Imaging.BitmapCacheOption]::OnLoad)
        return ($decoder.Frames | Sort-Object PixelWidth -Descending | Select-Object -First 1)
    } finally {
        $stream.Dispose()
    }
}

function Initialize-CustomBrandingLogo {
    $logoFrame = $null

    # 1) Tek dosya build icine gomulu ICO (base64) - asil kaynak
    if ($sync.LogoBase64) {
        try {
            $logoBytes = [Convert]::FromBase64String([string]$sync.LogoBase64)
            $logoStream = New-Object System.IO.MemoryStream
            try {
                $logoStream.Write($logoBytes, 0, $logoBytes.Length)
                $logoStream.Position = 0
                $decoder = New-Object System.Windows.Media.Imaging.IconBitmapDecoder($logoStream, [System.Windows.Media.Imaging.BitmapCreateOptions]::PreservePixelFormat, [System.Windows.Media.Imaging.BitmapCacheOption]::OnLoad)
                $logoFrame = $decoder.Frames | Sort-Object PixelWidth -Descending | Select-Object -First 1
            } finally {
                $logoStream.Dispose()
            }
        } catch {}
    }

    # 2) Gelistirme ortami: script yanindaki logo dosyasi
    if (-not $logoFrame) {
        $basePaths = @()
        if ($PSScriptRoot) {
            $basePaths += $PSScriptRoot
            $basePaths += (Split-Path $PSScriptRoot -Parent)
        }
        $basePaths += (Get-Location).Path

        $logoFile = $null
        foreach ($bp in $basePaths) {
            foreach ($rel in @("assets\logo.ico", "logo.ico", "logo.png", "xaml\logo.ico", "xaml\logo.png", "config\logo.png")) {
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
                if ($logoFile -match '\.ico$') {
                    $logoFrame = Get-IcoLogoFrame $logoFile
                } else {
                    $winBmp = New-Object System.Windows.Media.Imaging.BitmapImage
                    $winBmp.BeginInit()
                    $winBmp.UriSource = New-Object System.Uri($logoFile, [System.UriKind]::Absolute)
                    $winBmp.CacheOption = [System.Windows.Media.Imaging.BitmapCacheOption]::OnLoad
                    $winBmp.EndInit()
                    $logoFrame = $winBmp
                }
            } catch {}
        }
    }

    if (-not $logoFrame) { return }

    try { $logoFrame.Freeze() } catch {}
    $script:LogoFrame = $logoFrame
    try { $script:window.Icon = $logoFrame } catch {}

    $logoImage = $script:window.FindName("ImgLogo")
    if ($logoImage) {
        $logoImage.Source = $logoFrame
        $logoImage.Visibility = "Visible"
    }
    $logoFallback = $script:window.FindName("TxtLogoFallback")
    if ($logoFallback) { $logoFallback.Visibility = "Collapsed" }
}
Initialize-CustomBrandingLogo