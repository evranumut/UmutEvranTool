# --- CLI / KOMUT SATIRI PRESET MODU ---
# Dot-source edildiginde $args bos olabilir; ana yukleyici argumanlari
# $script:PetraArgs icine koyar (tek dosya build'de $args dogrudan dolu gelir).
$cliArgs = @($args)
if ($cliArgs.Count -eq 0 -and $script:PetraArgs) { $cliArgs = @($script:PetraArgs) }
if ($cliArgs.Count -gt 0 -and $cliArgs[0]) {
    $presetArg = ([string]$cliArgs[0]).ToLowerInvariant()
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
        $script:PetraCliOnly = $true
        if (-not (Test-WingetAvailable)) {
            Write-Host "[HATA] winget bulunamadi. Microsoft Store'dan 'App Installer' paketini guncelleyin." -ForegroundColor Red
            return
        }
        Write-Host "[+] CLI Preset Kurulumu Baslatiliyor: $presetArg" -ForegroundColor Cyan
        foreach ($rawId in $cliIds) {
            $id = Resolve-WingetId $rawId
            Write-Host " -> Kuruluyor: $id" -ForegroundColor Yellow
            if (Test-StoreProductId $id) {
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