# =============================================================================
# PETRA OMNITOOL v4.0 - POST-INSTALL & SCRIPT ENGINE (100% PURE ASCII)
# =============================================================================

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

function Decode-U([string]$text) {
    if ([string]::IsNullOrEmpty($text)) { return "" }
    return [regex]::Replace($text, '\\u([0-9a-fA-F]{4})', { param($m) [char][int]("0x" + $m.Groups[1].Value) })
}

# Hashtable anahtarlarini Turkce kulturunden bagimsiz (ordinal) eslestirir.
# Neden: tr-TR kulturunde buyuk "I" harfinin kucuk karsiligi noktasiz "i"
# oldugundan ContainsKey/indexer bazi adlarda beklenmedik sekilde False donebilir.
function Get-OrdinalIgnoreCaseKey($table, [string]$name) {
    if ($null -eq $table -or [string]::IsNullOrWhiteSpace($name)) { return $null }
    if ($table.ContainsKey($name)) { return $name }
    foreach ($k in @($table.Keys)) {
        if ([string]::Equals([string]$k, $name, [System.StringComparison]::OrdinalIgnoreCase)) {
            return [string]$k
        }
    }
    return $null
}