# =============================================================================
# PETRA OMNITOOL v4.0 - ORANGE CONSOLE BANNER (PURE ASCII / 90 KOLON)
# =============================================================================

function Show-ModernHeader {
    $Esc = [char]27
    $Reset = "$Esc[0m"

    $C_Orange = "$Esc[38;5;208m"
    $C_LightO = "$Esc[38;5;214m"
    $C_Green  = "$Esc[32m"
    $C_Gray   = "$Esc[90m"
    $C_White  = "$Esc[97m"

    $Top = "\u250C" + ("\u2500" * 88) + "\u2510"
    $Mid = "\u251C" + ("\u2500" * 88) + "\u2524"
    $Bot = "\u2514" + ("\u2500" * 88) + "\u2518"

    Write-Host ""
    Write-Host (Decode-U "  ${C_Orange}${Top}${Reset}")
    Write-Host (Decode-U "  ${C_Orange}\u2502${Reset}${C_LightO}   \u2588\u2588\u2588\u2588\u2588\u2588\u2557 \u2588\u2588\u2588\u2588\u2588\u2588\u2588\u2557\u2588\u2588\u2588\u2588\u2588\u2588\u2588\u2588\u2557\u2588\u2588\u2588\u2588\u2588\u2588\u2557  \u2588\u2588\u2588\u2588\u2588\u2557   ${C_Orange}\u2502${Reset}  ${C_White}v4.0${Reset}                                   ${C_Orange}\u2502${Reset}")
    Write-Host (Decode-U "  ${C_Orange}\u2502${Reset}${C_LightO}   \u2588\u2588\u2554\u2550\u2550\u2588\u2588\u2557\u2588\u2588\u2554\u2550\u2550\u2550\u2550\u255D\u255A\u2550\u2550\u2588\u2588\u2554\u2550\u2550\u255D\u2588\u2588\u2554\u2550\u2550\u2588\u2588\u2557\u2588\u2588\u2554\u2550\u2550\u2588\u2588\u2557  ${C_Orange}\u2502${Reset}  ${C_LightO}Windows 10 / 11${Reset}                        ${C_Orange}\u2502${Reset}")
    Write-Host (Decode-U "  ${C_Orange}\u2502${Reset}${C_LightO}   \u2588\u2588\u2588\u2588\u2588\u2588\u2554\u255D\u2588\u2588\u2588\u2588\u2588\u2557     \u2588\u2588\u2551   \u2588\u2588\u2588\u2588\u2588\u2588\u2554\u255D\u2588\u2588\u2588\u2588\u2588\u2588\u2588\u2551  ${C_Orange}\u2502${Reset}  ${C_LightO}PowerShell + WPF${Reset}                       ${C_Orange}\u2502${Reset}")
    Write-Host (Decode-U "  ${C_Orange}\u2502${Reset}${C_LightO}   \u2588\u2588\u2554\u2550\u2550\u2550\u255D \u2588\u2588\u2554\u2550\u2550\u255D     \u2588\u2588\u2551   \u2588\u2588\u2554\u2550\u2550\u2588\u2588\u2557\u2588\u2588\u2554\u2550\u2550\u2588\u2588\u2551  ${C_Orange}\u2502${Reset}  ${C_Gray}100% Pure ASCII UI${Reset}                     ${C_Orange}\u2502${Reset}")
    Write-Host (Decode-U "  ${C_Orange}\u2502${Reset}${C_LightO}   \u2588\u2588\u2551     \u2588\u2588\u2588\u2588\u2588\u2588\u2588\u2557   \u2588\u2588\u2551   \u2588\u2588\u2551  \u2588\u2588\u2551\u2588\u2588\u2551  \u2588\u2588\u2551  ${C_Orange}\u2502${Reset}  ${C_Gray}Runspace Threading${Reset}                     ${C_Orange}\u2502${Reset}")
    Write-Host (Decode-U "  ${C_Orange}\u2502${Reset}${C_LightO}   \u255A\u2550\u255D     \u255A\u2550\u2550\u2550\u2550\u2550\u2550\u255D   \u255A\u2550\u255D   \u255A\u2550\u255D  \u255A\u2550\u255D\u255A\u2550\u255D  \u255A\u2550\u255D  ${C_Orange}\u2502${Reset}  ${C_Gray}by Umut Evran${Reset}                          ${C_Orange}\u2502${Reset}")
    Write-Host (Decode-U "  ${C_Orange}\u2502${Reset}    ${C_Gray}Post-Install & Script Automation Engine                                             ${C_Orange}\u2502${Reset}")
    Write-Host (Decode-U "  ${C_Orange}${Mid}${Reset}")
    Write-Host (Decode-U ("  ${C_Orange}\u2502${Reset}   ${C_Green}\u26A1${Reset} ${C_White}Petra Haz\u0131r${Reset}${C_Gray}  |  ${Reset}${C_White}Pure ASCII UI${Reset}${C_Gray}  |  ${Reset}${C_White}Runspace Threading Aktif${Reset}" + (" " * 25) + "${C_Orange}\u2502${Reset}"))
    Write-Host (Decode-U "  ${C_Orange}${Bot}${Reset}")
    Write-Host ""
    try { $Host.UI.RawUI.WindowTitle = "Petra OmniTool v4.0 - Post-Install & Script Engine" } catch {}
}
Show-ModernHeader