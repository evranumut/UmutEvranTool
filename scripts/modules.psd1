# Petra OmniTool - modul yukleme sirasi (compile.ps1 ve scripts/main.ps1 kullanir)
@{
    Order = @(
        'core/00-preamble.ps1'
        'core/10-icon-cache.ps1'
        'core/20-banner.ps1'
        'core/30-winget-map.ps1'
        'core/40-cli-preset.ps1'
        'core/50-theme.ps1'
        'core/60-window-logo.ps1'
        'core/70-bindings.ps1'
        'core/80-background.ps1'
        'core/90-state-nav.ps1'
        'tabs/10-apps-render.ps1'
        'tabs/15-apps-engine.ps1'
        'tabs/20-tweaks.ps1'
        'tabs/30-features.ps1'
        'tabs/40-bloatware.ps1'
        'tabs/50-tools.ps1'
        'tabs/60-config.ps1'
        'core/95-startup.ps1'
    )
}
