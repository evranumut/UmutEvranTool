# --- WINGET ID DOGRULAMA VE OTOMATIK DUZELTME HARITASI ---
$script:WingetIdFixMap = @{
    "RubyInstallerTeam.Ruby.4.0"             = "RubyInstallerTeam.RubyWithDevKit.3.3"
    "Microsoft.VisualStudio.Community"       = "Microsoft.VisualStudio.2022.Community"
    "Python.Python.3.14"                     = "Python.Python.3.13"
    "TeamSpeakSystems.TeamSpeakClient.Beta.6"= "TeamSpeakSystems.TeamSpeakClient.Beta"
    "rjpcomputing.luaforwindows"             = "DEVCOM.Lua"
}

function Resolve-WingetId([string]$pkgId) {
    if ([string]::IsNullOrWhiteSpace($pkgId)) { return $pkgId }
    $clean = $pkgId.Trim()
    $fixKey = Get-OrdinalIgnoreCaseKey $script:WingetIdFixMap $clean
    if ($fixKey) {
        return $script:WingetIdFixMap[$fixKey]
    }
    return $clean
}

function Test-WingetAvailable {
    return [bool](Get-Command "winget" -ErrorAction SilentlyContinue)
}

# Microsoft Store urun kimlikleri (or. 9NKSQGP7F2NH) 12-20 karakter buyuk harf/rakamdir.
# Not: -match varsayilan olarak kultur-duyarli ve buyuk/kucuk harf yok sayar; Turkce
# kulturunde "I" harfi bu yuzden yanlis eslesebilir. Bu yuzden -cmatch kullanilir.
function Test-StoreProductId([string]$pkgId) {
    if ([string]::IsNullOrWhiteSpace($pkgId)) { return $false }
    return ($pkgId.Trim() -cmatch '^[0-9A-Z]{12,20}$')
}

$script:WingetMissingMessage = "[!] winget bulunamadi. Microsoft Store'dan 'App Installer' paketini guncelleyin ve tekrar deneyin."