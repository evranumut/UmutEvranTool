# =============================================================================
# UMUT EVRAN TOOL v3.0 - TEK DOSYA / UZAKTAN CALISTIRMA SURUMU (100% ASCII)
# Komut: irm evrantool.evranumut.workers.dev | iex
# =============================================================================
$ErrorActionPreference = 'Continue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
$isSta   = ([System.Threading.Thread]::CurrentThread.GetApartmentState() -eq 'STA')

if ((-not $isAdmin) -or (-not $isSta)) {
    $tempRunner = Join-Path $env:TEMP "UmutEvranTools_Runtime.ps1"
    if ($PSCommandPath -and (Test-Path $PSCommandPath)) {
        Copy-Item -Path $PSCommandPath -Destination $tempRunner -Force
    } elseif ($MyInvocation.MyCommand.Definition -and ($MyInvocation.MyCommand.Definition.Length -gt 200)) {
        [System.IO.File]::WriteAllText($tempRunner, $MyInvocation.MyCommand.Definition, [System.Text.Encoding]::ASCII)
    } else {
        Invoke-RestMethod -Uri "https://evrantool.evranumut.workers.dev" -OutFile $tempRunner
    }
    $argList = "-NoProfile -STA -ExecutionPolicy Bypass -File `"$tempRunner`""
    if ($args.Count -gt 0) {
        $argList += " " + ($args -join " ")
    }
    Start-Process powershell.exe -ArgumentList $argList -Verb RunAs
    return
}

$sync = [Hashtable]::Synchronized(@{})

$sync.AppsConfig = @'
[
  {
    "Category": "Taray\u0131c\u0131lar",
    "Apps": [
      {
        "Name": "Arc Browser",
        "Id": "TheBrowserCompany.Arc",
        "Description": "Modern ve \u00e7al\u0131\u015fma alan\u0131 odakl\u0131 yeni nesil taray\u0131c\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=arc.net&sz=128"
      },
      {
        "Name": "Google Chrome",
        "Id": "Google.Chrome",
        "Description": "D\u00fcnyan\u0131n en pop\u00fcler, h\u0131zl\u0131 ve g\u00fcvenli web taray\u0131c\u0131s\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=google.com/chrome&sz=128"
      },
      {
        "Name": "Brave Browser",
        "Id": "Brave.Brave",
        "Description": "Reklamlar\u0131 ve izleyicileri varsay\u0131lan olarak engelleyen gizlilik taray\u0131c\u0131s\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=brave.com&sz=128"
      },
      {
        "Name": "Mozilla Firefox",
        "Id": "Mozilla.Firefox",
        "Description": "Gizlilik odakl\u0131, a\u00e7\u0131k kaynakl\u0131 ve \u00f6zelle\u015ftirilebilir taray\u0131c\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=mozilla.org/firefox&sz=128"
      },
      {
        "Name": "Microsoft Edge",
        "Id": "Microsoft.Edge",
        "Description": "Windows ile tam uyumlu, d\u00fc\u015f\u00fck kaynak t\u00fcketen modern taray\u0131c\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=microsoft.com/edge&sz=128"
      },
      {
        "Name": "Opera",
        "Id": "Opera.Opera",
        "Description": "Dahili VPN ve reklam engelleyici i\u00e7eren modern taray\u0131c\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=opera.com&sz=128"
      },
      {
        "Name": "Opera GX",
        "Id": "Opera.OperaGX",
        "Description": "Oyuncular i\u00e7in RAM ve CPU s\u0131n\u0131rland\u0131r\u0131c\u0131 \u00f6zellikli taray\u0131c\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=opera.com/gx&sz=128"
      },
      {
        "Name": "Vivaldi",
        "Id": "Vivaldi.Vivaldi",
        "Description": "Uzman kullan\u0131c\u0131lar i\u00e7in y\u00fcksek d\u00fczeyde \u00f6zelle\u015ftirilebilir taray\u0131c\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=vivaldi.com&sz=128"
      },
      {
        "Name": "LibreWolf",
        "Id": "LibreWolf.LibreWolf",
        "Description": "Telemetri ar\u0131nd\u0131r\u0131lm\u0131\u015f, maksimum gizlilik odakl\u0131 Firefox \u00e7atal\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=librewolf.net&sz=128"
      },
      {
        "Name": "Tor Browser",
        "Id": "TorProject.TorBrowser",
        "Description": "Anonim internet gezintisi ve \u00fcst d\u00fczey gizlilik sa\u011flayan taray\u0131c\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=torproject.org&sz=128"
      }
    ]
  },
  {
    "Category": "Geli\u015ftirici Ara\u00e7lar\u0131",
    "Apps": [
      {
        "Name": "Visual Studio Code",
        "Id": "Microsoft.VisualStudioCode",
        "Description": "Hafif, g\u00fc\u00e7l\u00fc ve eklenti destekli pop\u00fcler kod edit\u00f6r\u00fc.",
        "Icon": "https://www.google.com/s2/favicons?domain=code.visualstudio.com&sz=128"
      },
      {
        "Name": "Git",
        "Id": "Git.Git",
        "Description": "Da\u011f\u0131t\u0131k versiyon kontrol sistemi ve Git Bash terminali.",
        "Icon": "https://www.google.com/s2/favicons?domain=git-scm.com&sz=128"
      },
      {
        "Name": "GitHub Desktop",
        "Id": "GitHub.GitHubDesktop",
        "Description": "Git ve GitHub depolar\u0131n\u0131 g\u00f6rsel aray\u00fczle y\u00f6netme arac\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=desktop.github.com&sz=128"
      },
      {
        "Name": "Node.js (LTS)",
        "Id": "OpenJS.NodeJS.LTS",
        "Description": "JavaScript \u00e7al\u0131\u015fma zaman\u0131 ortam\u0131 ve npm paket y\u00f6neticisi.",
        "Icon": "https://www.google.com/s2/favicons?domain=nodejs.org&sz=128"
      },
      {
        "Name": "Python 3.12",
        "Id": "Python.Python.3.12",
        "Description": "Genel ama\u00e7l\u0131, g\u00fc\u00e7l\u00fc ve yayg\u0131n programlama dili.",
        "Icon": "https://www.google.com/s2/favicons?domain=python.org&sz=128"
      },
      {
        "Name": "Windows Terminal",
        "Id": "Microsoft.WindowsTerminal",
        "Description": "Sekmeli, modern ve \u00f6zelle\u015ftirilebilir komut sat\u0131r\u0131 uygulamas\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=microsoft.com/windows&sz=128"
      },
      {
        "Name": "PowerShell 7",
        "Id": "Microsoft.PowerShell",
        "Description": "Platformlar aras\u0131 modern PowerShell s\u00fcr\u00fcm\u00fc.",
        "Icon": "https://www.google.com/s2/favicons?domain=microsoft.com/powershell&sz=128"
      },
      {
        "Name": "Docker Desktop",
        "Id": "Docker.DockerDesktop",
        "Description": "Konteyner taban\u0131 uygulama geli\u015ftirme ve y\u00f6netim platformu.",
        "Icon": "https://www.google.com/s2/favicons?domain=docker.com&sz=128"
      },
      {
        "Name": "Postman",
        "Id": "Postman.Postman",
        "Description": "API geli\u015ftirme, test etme ve dok\u00fcmantasyon platformu.",
        "Icon": "https://www.google.com/s2/favicons?domain=postman.com&sz=128"
      },
      {
        "Name": "Notepad++",
        "Id": "Notepad++.Notepad++",
        "Description": "H\u0131zl\u0131 ve \u00e7ok dilli geli\u015fmi\u015f metin/kod d\u00fczenleyici.",
        "Icon": "https://www.google.com/s2/favicons?domain=notepad-plus-plus.org&sz=128"
      }
    ]
  },
  {
    "Category": "Oyun ve Oyuncu Ara\u00e7lar\u0131",
    "Apps": [
      {
        "Name": "Steam",
        "Id": "Valve.Steam",
        "Description": "En b\u00fcy\u00fck PC oyun ma\u011fazas\u0131 ve topluluk platformu.",
        "Icon": "https://www.google.com/s2/favicons?domain=steampowered.com&sz=128"
      },
      {
        "Name": "Epic Games Launcher",
        "Id": "EpicGames.EpicGamesLauncher",
        "Description": "Epic Games oyunlar\u0131 ve Unreal Engine ba\u015flat\u0131c\u0131s\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=epicgames.com&sz=128"
      },
      {
        "Name": "EA App",
        "Id": "ElectronicArts.EADesktop",
        "Description": "Electronic Arts (EA FC, Battlefield vb.) oyun platformu.",
        "Icon": "https://www.google.com/s2/favicons?domain=ea.com&sz=128"
      },
      {
        "Name": "Ubisoft Connect",
        "Id": "Ubisoft.Connect",
        "Description": "Ubisoft oyunlar\u0131 i\u00e7in k\u00fct\u00fcphane ve ba\u015flat\u0131c\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=ubisoft.com&sz=128"
      },
      {
        "Name": "GOG Galaxy",
        "Id": "GOG.Galaxy",
        "Description": "DRM-siz oyunlar ve birle\u015fik oyun k\u00fct\u00fcphanesi y\u00f6neticisi.",
        "Icon": "https://www.google.com/s2/favicons?domain=gog.com&sz=128"
      },
      {
        "Name": "SteelSeries GG",
        "Id": "SteelSeries.GG",
        "Description": "SteelSeries kulakl\u0131k/ekipman y\u00f6netimi ve Sonar ses motoru.",
        "Icon": "https://www.google.com/s2/favicons?domain=steelseries.com&sz=128"
      },
      {
        "Name": "Logitech G HUB",
        "Id": "Logitech.GHUB",
        "Description": "Logitech G oyuncu ekipmanlar\u0131 i\u00e7in yaz\u0131l\u0131m ve makro y\u00f6netimi.",
        "Icon": "https://www.google.com/s2/favicons?domain=logitechg.com&sz=128"
      },
      {
        "Name": "MSI Afterburner",
        "Id": "Guru3D.Afterburner",
        "Description": "Ekran kart\u0131 h\u0131z a\u015f\u0131rtma (OC), fan kontrol\u00fc ve oyun i\u00e7i FPS g\u00f6stergesi.",
        "Icon": "https://www.google.com/s2/favicons?domain=msi.com&sz=128"
      },
      {
        "Name": "Prism Launcher",
        "Id": "PrismLauncher.PrismLauncher",
        "Description": "Modlu Minecraft (Forge, NeoForge, Fabric) i\u00e7in geli\u015fmi\u015f ba\u015flat\u0131c\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=prismlauncher.org&sz=128"
      }
    ]
  },
  {
    "Category": "\u0130leti\u015fim ve Medya",
    "Apps": [
      {
        "Name": "Discord",
        "Id": "Discord.Discord",
        "Description": "Oyuncular ve topluluklar i\u00e7in sesli, g\u00f6r\u00fcnt\u00fcl\u00fc ve yaz\u0131l\u0131 sohbet.",
        "Icon": "https://www.google.com/s2/favicons?domain=discord.com&sz=128"
      },
      {
        "Name": "Spotify",
        "Id": "Spotify.Spotify",
        "Description": "Dijital m\u00fczik ve podcast dinleme platformu.",
        "Icon": "https://www.google.com/s2/favicons?domain=spotify.com&sz=128"
      },
      {
        "Name": "VLC Media Player",
        "Id": "VideoLAN.VLC",
        "Description": "T\u00fcm video ve ses formatlar\u0131n\u0131 kodeksiz oynatan medya oynat\u0131c\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=videolan.org&sz=128"
      },
      {
        "Name": "OBS Studio",
        "Id": "OBSProject.OBSStudio",
        "Description": "Profesyonel ekran kayd\u0131 ve canl\u0131 yay\u0131n yaz\u0131l\u0131m\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=obsproject.com&sz=128"
      },
      {
        "Name": "WhatsApp",
        "Id": "9NKSQGP7F2NH",
        "Description": "Masa\u00fcst\u00fc i\u00e7in resmi WhatsApp mesajla\u015fma uygulamas\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=whatsapp.com&sz=128"
      },
      {
        "Name": "Telegram Desktop",
        "Id": "Telegram.TelegramDesktop",
        "Description": "H\u0131zl\u0131 ve bulut tabanl\u0131 masa\u00fcst\u00fc mesajla\u015fma uygulamas\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=telegram.org&sz=128"
      },
      {
        "Name": "HandBrake",
        "Id": "HandBrake.HandBrake",
        "Description": "A\u00e7\u0131k kaynakl\u0131 video d\u00f6n\u00fc\u015ft\u00fcrme ve s\u0131k\u0131\u015ft\u0131rma arac\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=handbrake.fr&sz=128"
      }
    ]
  },
  {
    "Category": "Sistem ve Yard\u0131mc\u0131 Ara\u00e7lar",
    "Apps": [
      {
        "Name": "7-Zip",
        "Id": "7zip.7zip",
        "Description": "Y\u00fcksek s\u0131k\u0131\u015ft\u0131rma oran\u0131na sahip \u00fccretsiz ar\u015fiv y\u00f6neticisi.",
        "Icon": "https://www.google.com/s2/favicons?domain=7-zip.org&sz=128"
      },
      {
        "Name": "WinRAR",
        "Id": "RARLab.WinRAR",
        "Description": "RAR ve ZIP ar\u015fivleri i\u00e7in klasik s\u0131k\u0131\u015ft\u0131rma program\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=rarlab.com&sz=128"
      },
      {
        "Name": "Microsoft PowerToys",
        "Id": "Microsoft.PowerToys",
        "Description": "Windows i\u00e7in geli\u015fmi\u015f pencere, k\u0131sayol ve verimlilik ara\u00e7lar\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=microsoft.com&sz=128"
      },
      {
        "Name": "Everything",
        "Id": "voidtools.Everything",
        "Description": "Dosya ve klas\u00f6rleri saliseler i\u00e7inde bulan ultra h\u0131zl\u0131 arama arac\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=voidtools.com&sz=128"
      },
      {
        "Name": "WizTree",
        "Id": "AntibodySoftware.WizTree",
        "Description": "Diskte yer kaplayan dosya ve klas\u00f6rleri saniyeler i\u00e7inde analiz eder.",
        "Icon": "https://www.google.com/s2/favicons?domain=diskanalyzer.com&sz=128"
      },
      {
        "Name": "Revo Uninstaller",
        "Id": "RevoUninstaller.RevoUninstaller",
        "Description": "Programlar\u0131 kal\u0131nt\u0131 ve kay\u0131t defteri izi b\u0131rakmadan kald\u0131r\u0131r.",
        "Icon": "https://www.google.com/s2/favicons?domain=revouninstaller.com&sz=128"
      },
      {
        "Name": "ShareX",
        "Id": "ShareX.ShareX",
        "Description": "Geli\u015fmi\u015f ekran g\u00f6r\u00fcnt\u00fcs\u00fc alma, GIF kaydetme ve payla\u015f\u0131m arac\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=getsharex.com&sz=128"
      },
      {
        "Name": "Lightshot",
        "Id": "Skillbrains.Lightshot",
        "Description": "Pratik ve h\u0131zl\u0131 ekran g\u00f6r\u00fcnt\u00fcs\u00fc alma arac\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=app.prntscr.com&sz=128"
      },
      {
        "Name": "CPU-Z",
        "Id": "CPUID.CPU-Z",
        "Description": "\u0130\u015flemci, anakart ve RAM donan\u0131m bilgilerini detayl\u0131 g\u00f6sterir.",
        "Icon": "https://www.google.com/s2/favicons?domain=cpuid.com&sz=128"
      },
      {
        "Name": "HWMonitor",
        "Id": "CPUID.HWMonitor",
        "Description": "Sistem s\u0131cakl\u0131klar\u0131n\u0131, voltajlar\u0131 ve fan h\u0131zlar\u0131n\u0131 canl\u0131 izleme arac\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=cpuid.com&sz=128"
      },
      {
        "Name": "Rufus",
        "Id": "Rufus.Rufus",
        "Description": "\u00d6ny\u00fcklenebilir (Bootable) USB format belle\u011fi haz\u0131rlama arac\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=rufus.ie&sz=128"
      }
    ]
  },
  {
    "Category": "Ofis, Belge ve Bulut",
    "Apps": [
      {
        "Name": "LibreOffice",
        "Id": "TheDocumentFoundation.LibreOffice",
        "Description": "\u00dccretsiz ve a\u00e7\u0131k kaynakl\u0131 tam kapsaml\u0131 ofis paketi.",
        "Icon": "https://www.google.com/s2/favicons?domain=libreoffice.org&sz=128"
      },
      {
        "Name": "Adobe Acrobat Reader DC",
        "Id": "Adobe.Acrobat.Reader.64-bit",
        "Description": "End\u00fcstri standard\u0131 PDF g\u00f6r\u00fcnt\u00fcleme ve imzalama yaz\u0131l\u0131m\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=adobe.com&sz=128"
      },
      {
        "Name": "SumatraPDF",
        "Id": "SumatraPDF.SumatraPDF",
        "Description": "\u00c7ok hafif ve ultra h\u0131zl\u0131 PDF, ePub ve \u00e7izgi roman okuyucu.",
        "Icon": "https://www.google.com/s2/favicons?domain=sumatrapdfreader.org&sz=128"
      },
      {
        "Name": "Obsidian",
        "Id": "Obsidian.Obsidian",
        "Description": "Markdown tabanl\u0131 ki\u015fisel bilgi taban\u0131 ve not alma uygulamas\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=obsidian.md&sz=128"
      },
      {
        "Name": "Notion",
        "Id": "Notion.Notion",
        "Description": "Notlar, g\u00f6revler ve projeler i\u00e7in hepsi bir arada \u00e7al\u0131\u015fma alan\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=notion.so&sz=128"
      },
      {
        "Name": "Google Drive",
        "Id": "Google.Drive",
        "Description": "Google Drive bulut dosyalar\u0131n\u0131 bilgisayarla senkronize etme arac\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=drive.google.com&sz=128"
      },
      {
        "Name": "AnyDesk",
        "Id": "AnyDeskSoftwareGmbH.AnyDesk",
        "Description": "D\u00fc\u015f\u00fck gecikmeli ve h\u0131zl\u0131 uzak masa\u00fcst\u00fc ba\u011flant\u0131 yaz\u0131l\u0131m\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=anydesk.com&sz=128"
      }
    ]
  }
]
'@ | ConvertFrom-Json

$sync.Xaml = @'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Umut Evran Tool v3.0 - Sistem Kurulum ve Optimizasyon Merkezi"
        Width="1240" Height="820" MinWidth="1024" MinHeight="680"
        WindowStartupLocation="CenterScreen" Background="{DynamicResource WindowBg}" Foreground="#F8FAFC"
        FontFamily="Segoe UI">
    <Window.Resources>
        <!-- Dinamik Renk Paletleri -->
        <SolidColorBrush x:Key="WindowBg" Color="#19221D"/>
        <SolidColorBrush x:Key="PanelBg" Color="#131C17"/>
        <SolidColorBrush x:Key="CardBg" Color="#212D26"/>
        <SolidColorBrush x:Key="BorderBrushColor" Color="#34463B"/>
        <SolidColorBrush x:Key="HoverBg" Color="#2C3C33"/>
        <SolidColorBrush x:Key="AccentColor" Color="#A3B18A"/>
        <SolidColorBrush x:Key="ActiveBtnColor" Color="#4E664A"/>
        <SolidColorBrush x:Key="TextMuted" Color="#99A799"/>
        <SolidColorBrush x:Key="TextDim" Color="#677567"/>
        <SolidColorBrush x:Key="LogBg" Color="#0E1511"/>
        <SolidColorBrush x:Key="LogFg" Color="#D8F3DC"/>
        <SolidColorBrush x:Key="BtnInstallBg" Color="#588157"/>
        <SolidColorBrush x:Key="BtnUninstallBg" Color="#8B4B4B"/>
        <SolidColorBrush x:Key="BtnUpgradeBg" Color="#3A5A40"/>

        <Style x:Key="NavButtonStyle" TargetType="Button">
            <Setter Property="Background" Value="{DynamicResource CardBg}"/>
            <Setter Property="Foreground" Value="#F1F5F9"/>
            <Setter Property="BorderBrush" Value="{DynamicResource BorderBrushColor}"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="Padding" Value="12,9"/>
            <Setter Property="Margin" Value="0,0,0,5"/>
            <Setter Property="HorizontalContentAlignment" Value="Left"/>
            <Setter Property="FontSize" Value="13"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border Background="{TemplateBinding Background}"
                                BorderBrush="{TemplateBinding BorderBrush}"
                                BorderThickness="{TemplateBinding BorderThickness}"
                                CornerRadius="6" Padding="{TemplateBinding Padding}">
                            <ContentPresenter HorizontalAlignment="{TemplateBinding HorizontalContentAlignment}" VerticalAlignment="Center"/>
                        </Border>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
            <Style.Triggers>
                <Trigger Property="IsMouseOver" Value="True">
                    <Setter Property="Background" Value="{DynamicResource HoverBg}"/>
                    <Setter Property="BorderBrush" Value="{DynamicResource AccentColor}"/>
                </Trigger>
            </Style.Triggers>
        </Style>

        <Style x:Key="ActionBtnStyle" TargetType="Button">
            <Setter Property="Foreground" Value="#FFFFFF"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="Padding" Value="14,9"/>
            <Setter Property="FontSize" Value="12.5"/>
            <Setter Property="FontWeight" Value="Bold"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border Background="{TemplateBinding Background}" CornerRadius="6" Padding="{TemplateBinding Padding}">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
            <Style.Triggers>
                <Trigger Property="IsEnabled" Value="False">
                    <Setter Property="Opacity" Value="0.5"/>
                </Trigger>
            </Style.Triggers>
        </Style>
    </Window.Resources>

    <Grid>
        <Grid.ColumnDefinitions>
            <ColumnDefinition Width="270"/>
            <ColumnDefinition Width="*"/>
            <ColumnDefinition Width="320"/>
        </Grid.ColumnDefinitions>

        <!-- SOL MENU PANELI -->
        <Border Grid.Column="0" Background="{DynamicResource PanelBg}" BorderBrush="{DynamicResource BorderBrushColor}" BorderThickness="0,0,1,0" Padding="14">
            <DockPanel LastChildFill="False">
                <StackPanel DockPanel.Dock="Top">
                    <Border Background="{DynamicResource CardBg}" BorderBrush="{DynamicResource AccentColor}" BorderThickness="1.5" CornerRadius="8" Padding="12" Margin="0,0,0,12">
                        <StackPanel>
                            <TextBlock Text="&#x1F680; UMUT EVRAN TOOL" FontSize="16.5" FontWeight="Bold" Foreground="{DynamicResource AccentColor}"/>
                            <TextBlock Text="Format Sonras&#x0131; Otomasyon v3.0" FontSize="11" Foreground="{DynamicResource TextMuted}" Margin="0,3,0,0"/>
                        </StackPanel>
                    </Border>

                    <!-- MENULER -->
                    <TextBlock Text="MEN&#x00DC;LER" FontSize="10.5" FontWeight="Bold" Foreground="{DynamicResource TextDim}" Margin="4,0,0,5"/>
                    <Button x:Name="BtnNavApps" Style="{StaticResource NavButtonStyle}" Content="&#x1F4E6;  Uygulama Kurulumu" Background="{DynamicResource ActiveBtnColor}" BorderBrush="{DynamicResource AccentColor}"/>
                    <Button x:Name="BtnNavTweaks" Style="{StaticResource NavButtonStyle}" Content="&#x26A1;  Sistem &#x0130;nce Ayarlar&#x0131;"/>
                    <Button x:Name="BtnNavBloatware" Style="{StaticResource NavButtonStyle}" Content="&#x1F9F9;  Bloatware Temizli&#x011F;i"/>
                    <Button x:Name="BtnNavConfig" Style="{StaticResource NavButtonStyle}" Content="&#x1F4BE;  Yedekleme &amp; Config"/>

                    <!-- TEMA SECIMI BOLUMU (G&#x00D6;RSELLERDEKI 3 TEMA) -->
                    <TextBlock Text="TEMA SE&#x00C7;&#x0130;M&#x0130; (CANLI GE&#x00C7;&#x0130;&#x015E;)" FontSize="10.5" FontWeight="Bold" Foreground="{DynamicResource TextDim}" Margin="4,10,0,5"/>
                    <UniformGrid Columns="3" Margin="0,0,0,8">
                        <Button x:Name="BtnThemeOlive" Style="{StaticResource ActionBtnStyle}" Background="#4E664A" Content="&#x1F33F; Ye&#x015F;il" ToolTip="Askeri Ada&#x00E7;ay&#x0131; Ye&#x015F;ili" Padding="4,6" Margin="0,0,2,0" FontSize="11"/>
                        <Button x:Name="BtnThemeAmber" Style="{StaticResource ActionBtnStyle}" Background="#EA580C" Content="&#x26A1; Turuncu" ToolTip="Karbon &amp; Kehribar Turuncu" Padding="4,6" Margin="2,0,2,0" FontSize="11"/>
                        <Button x:Name="BtnThemeNeon" Style="{StaticResource ActionBtnStyle}" Background="#BE185D" Content="&#x1F52E; Neon" ToolTip="Siberpunk Neon Pembe" Padding="4,6" Margin="2,0,0,0" FontSize="11"/>
                    </UniformGrid>

                    <!-- HAZIR PAKETLER -->
                    <TextBlock Text="HAZIR PAKETLER (PRESETS)" FontSize="10.5" FontWeight="Bold" Foreground="{DynamicResource TextDim}" Margin="4,6,0,5"/>
                    <Button x:Name="BtnPresetUmut" Style="{StaticResource NavButtonStyle}" Content="&#x1F451;  Umut &#x00D6;zel Paketi Se&#x00E7;" BorderBrush="{DynamicResource AccentColor}"/>
                    <Button x:Name="BtnPresetGamer" Style="{StaticResource NavButtonStyle}" Content="&#x1F3AE;  Oyuncu Paketi Se&#x00E7;"/>
                    <Button x:Name="BtnPresetDev" Style="{StaticResource NavButtonStyle}" Content="&#x1F4BB;  Geli&#x015F;tirici Paketi Se&#x00E7;"/>
                    <Button x:Name="BtnPresetStandard" Style="{StaticResource NavButtonStyle}" Content="&#x2728;  Standart Kurulum Se&#x00E7;"/>
                    <Button x:Name="BtnClearSelection" Style="{StaticResource NavButtonStyle}" Content="&#x1F504;  T&#x00FC;m Se&#x00E7;imleri Temizle"/>
                </StackPanel>

                <StackPanel DockPanel.Dock="Bottom">
                    <Button x:Name="BtnRestorePoint" Style="{StaticResource ActionBtnStyle}" Background="{DynamicResource HoverBg}" Content="&#x1F6E1;&#xFE0F; Geri Y&#x00FC;kleme Noktas&#x0131; Olu&#x015F;tur" Margin="0,0,0,8"/>
                    <TextBlock x:Name="TxtSysInfo" Text="Y&#x00F6;netici Olarak &#x00C7;al&#x0131;&#x015F;&#x0131;yor" FontSize="11" Foreground="{DynamicResource TextDim}" HorizontalAlignment="Center"/>
                </StackPanel>
            </DockPanel>
        </Border>

        <!-- ORTA ANA ICERIK PANELI -->
        <Grid Grid.Column="1" Margin="14">
            <!-- SEKME 1: UYGULAMA KURULUMU -->
            <Grid x:Name="ViewApps" Visibility="Visible">
                <Grid.RowDefinitions>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="*"/>
                    <RowDefinition Height="Auto"/>
                </Grid.RowDefinitions>

                <!-- Arama Bar -->
                <Border Grid.Row="0" Background="{DynamicResource CardBg}" BorderBrush="{DynamicResource BorderBrushColor}" BorderThickness="1" CornerRadius="8" Padding="10,6" Margin="0,0,0,10">
                    <DockPanel>
                        <TextBlock Text="&#x1F50D; Ara:" Foreground="{DynamicResource TextMuted}" VerticalAlignment="Center" FontWeight="SemiBold" Margin="4,0,10,0"/>
                        <Button x:Name="BtnClearSearch" DockPanel.Dock="Right" Content="Temizle" Background="{DynamicResource HoverBg}" Foreground="#E2E8F0" BorderThickness="0" Padding="10,4" Cursor="Hand"/>
                        <TextBox x:Name="TxtSearch" Background="Transparent" Foreground="#F8FAFC" BorderThickness="0" FontSize="14" VerticalContentAlignment="Center" CaretBrush="{DynamicResource AccentColor}"/>
                    </DockPanel>
                </Border>

                <!-- Kategori Filtre Butonlari -->
                <WrapPanel x:Name="CategoryButtonPanel" Grid.Row="1" Margin="0,0,0,10"/>

                <!-- Uygulama Listesi -->
                <Border Grid.Row="2" Background="{DynamicResource PanelBg}" BorderBrush="{DynamicResource BorderBrushColor}" BorderThickness="1" CornerRadius="8" Padding="10">
                    <ScrollViewer VerticalScrollBarVisibility="Auto">
                        <StackPanel x:Name="MainStackPanel"/>
                    </ScrollViewer>
                </Border>

                <!-- Alt Butonlar -->
                <Border Grid.Row="3" Background="{DynamicResource CardBg}" BorderBrush="{DynamicResource BorderBrushColor}" BorderThickness="1" CornerRadius="8" Padding="12" Margin="0,10,0,0">
                    <DockPanel>
                        <TextBlock x:Name="TxtSelectedCount" Text="0 uygulama se&#x00E7;ildi" FontSize="14" FontWeight="Bold" Foreground="{DynamicResource AccentColor}" VerticalAlignment="Center"/>
                        <StackPanel Orientation="Horizontal" HorizontalAlignment="Right" DockPanel.Dock="Right">
                            <Button x:Name="BtnInstall" Style="{StaticResource ActionBtnStyle}" Background="{DynamicResource BtnInstallBg}" Content="&#x1F680; Se&#x00E7;ilenleri Kur (Winget)" Margin="0,0,8,0"/>
                            <Button x:Name="BtnUninstall" Style="{StaticResource ActionBtnStyle}" Background="{DynamicResource BtnUninstallBg}" Content="&#x1F5D1;&#xFE0F; Se&#x00E7;ilenleri Kald&#x0131;r" Margin="0,0,8,0"/>
                            <Button x:Name="BtnUpgradeAll" Style="{StaticResource ActionBtnStyle}" Background="{DynamicResource BtnUpgradeBg}" Content="&#x1F504; T&#x00FC;m&#x00FC;n&#x00FC; G&#x00FC;ncelle"/>
                        </StackPanel>
                    </DockPanel>
                </Border>
            </Grid>

            <!-- SEKME 2: SISTEM INCE AYARLARI (TWEAKS) -->
            <Grid x:Name="ViewTweaks" Visibility="Collapsed">
                <Grid.RowDefinitions>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="*"/>
                    <RowDefinition Height="Auto"/>
                </Grid.RowDefinitions>

                <Border Grid.Row="0" Background="{DynamicResource CardBg}" BorderBrush="{DynamicResource BorderBrushColor}" BorderThickness="1" CornerRadius="8" Padding="14" Margin="0,0,0,10">
                    <StackPanel>
                        <TextBlock Text="&#x26A1; Sistem &#x0130;nce Ayarlar&#x0131; ve Performans Optimizasyonu" FontSize="16" FontWeight="Bold" Foreground="{DynamicResource AccentColor}"/>
                        <TextBlock Text="Windows 10/11 i&#x00E7;in oyun performans&#x0131;, gizlilik ve aray&#x00FC;z iyile&#x015F;tirmelerini se&#x00E7;ip tek t&#x0131;kla uygulayabilirsiniz." FontSize="12.5" Foreground="{DynamicResource TextMuted}" Margin="0,4,0,0"/>
                    </StackPanel>
                </Border>

                <Border Grid.Row="1" Background="{DynamicResource PanelBg}" BorderBrush="{DynamicResource BorderBrushColor}" BorderThickness="1" CornerRadius="8" Padding="12">
                    <ScrollViewer VerticalScrollBarVisibility="Auto">
                        <StackPanel x:Name="TweaksStackPanel"/>
                    </ScrollViewer>
                </Border>

                <Border Grid.Row="2" Background="{DynamicResource CardBg}" BorderBrush="{DynamicResource BorderBrushColor}" BorderThickness="1" CornerRadius="8" Padding="12" Margin="0,10,0,0">
                    <WrapPanel HorizontalAlignment="Right">
                        <Button x:Name="BtnSelectRecTweaks" Style="{StaticResource ActionBtnStyle}" Background="{DynamicResource HoverBg}" Content="&#x2728; &#x00D6;nerilenleri Se&#x00E7;" Margin="0,0,8,0"/>
                        <Button x:Name="BtnApplyTweaks" Style="{StaticResource ActionBtnStyle}" Background="{DynamicResource BtnInstallBg}" Content="&#x26A1; Se&#x00E7;ili Ayarlar&#x0131; Uygula" Margin="0,0,8,0"/>
                        <Button x:Name="BtnRevertContextMenu" Style="{StaticResource ActionBtnStyle}" Background="#D97706" Content="&#x267B;&#xFE0F; Sa&#x011F; T&#x0131;k Men&#x00FC;s&#x00FC;n&#x00FC; Varsay&#x0131;lana D&#x00F6;nd&#x00FC;r" Margin="0,0,8,0"/>
                        <Button x:Name="BtnCleanTemp" Style="{StaticResource ActionBtnStyle}" Background="{DynamicResource BtnUpgradeBg}" Content="&#x1F9F9; Temp &amp; DNS Temizle"/>
                    </WrapPanel>
                </Border>
            </Grid>

            <!-- SEKME 3: BLOATWARE TEMIZLIGI -->
            <Grid x:Name="ViewBloatware" Visibility="Collapsed">
                <Grid.RowDefinitions>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="*"/>
                    <RowDefinition Height="Auto"/>
                </Grid.RowDefinitions>

                <Border Grid.Row="0" Background="{DynamicResource CardBg}" BorderBrush="{DynamicResource BorderBrushColor}" BorderThickness="1" CornerRadius="8" Padding="14" Margin="0,0,0,10">
                    <StackPanel>
                        <TextBlock Text="&#x1F9F9; Windows Gereksiz Uygulama (Bloatware) Temizli&#x011F;i" FontSize="16" FontWeight="Bold" Foreground="{DynamicResource AccentColor}"/>
                        <TextBlock Text="Windows ile birlikte y&#x00FC;kl&#x00FC; gelen ve arka planda kaynak t&#x00FC;keten gereksiz paketleri kald&#x0131;r&#x0131;n." FontSize="12.5" Foreground="{DynamicResource TextMuted}" Margin="0,4,0,0"/>
                    </StackPanel>
                </Border>

                <Border Grid.Row="1" Background="{DynamicResource PanelBg}" BorderBrush="{DynamicResource BorderBrushColor}" BorderThickness="1" CornerRadius="8" Padding="12">
                    <ScrollViewer VerticalScrollBarVisibility="Auto">
                        <UniformGrid x:Name="BloatwareGrid" Columns="2"/>
                    </ScrollViewer>
                </Border>

                <Border Grid.Row="2" Background="{DynamicResource CardBg}" BorderBrush="{DynamicResource BorderBrushColor}" BorderThickness="1" CornerRadius="8" Padding="12" Margin="0,10,0,0">
                    <DockPanel>
                        <StackPanel Orientation="Horizontal">
                            <Button x:Name="BtnSelectAllBloat" Style="{StaticResource ActionBtnStyle}" Background="{DynamicResource HoverBg}" Content="T&#x00FC;m&#x00FC;n&#x00FC; Se&#x00E7;" Margin="0,0,8,0"/>
                            <Button x:Name="BtnClearBloat" Style="{StaticResource ActionBtnStyle}" Background="{DynamicResource BorderBrushColor}" Content="Se&#x00E7;imi Temizle"/>
                        </StackPanel>
                        <Button x:Name="BtnRemoveBloatware" DockPanel.Dock="Right" HorizontalAlignment="Right" Style="{StaticResource ActionBtnStyle}" Background="{DynamicResource BtnUninstallBg}" Content="&#x1F5D1;&#xFE0F; Se&#x00E7;ili Bloatware Uygulamalar&#x0131;n&#x0131; Kald&#x0131;r"/>
                    </DockPanel>
                </Border>
            </Grid>

            <!-- SEKME 4: YEDEKLEME & CONFIG -->
            <Grid x:Name="ViewConfig" Visibility="Collapsed">
                <StackPanel>
                    <Border Background="{DynamicResource CardBg}" BorderBrush="{DynamicResource BorderBrushColor}" BorderThickness="1" CornerRadius="8" Padding="16" Margin="0,0,0,12">
                        <StackPanel>
                            <TextBlock Text="&#x1F4BE; Yap&#x0131;land&#x0131;rma Yedekleme (JSON D&#x0131;&#x015F;a / &#x0130;&#x00E7;e Aktar)" FontSize="16" FontWeight="Bold" Foreground="{DynamicResource AccentColor}"/>
                            <TextBlock Text="Se&#x00E7;ti&#x011F;iniz uygulama ve ince ayar listesini JSON dosyas&#x0131; olarak kaydedebilir, ba&#x015F;ka bir bilgisayarda tek t&#x0131;kla geri y&#x00FC;kleyebilirsiniz." FontSize="13" Foreground="{DynamicResource TextMuted}" Margin="0,6,0,14" TextWrapping="Wrap"/>
                            <StackPanel Orientation="Horizontal">
                                <Button x:Name="BtnExportConfig" Style="{StaticResource ActionBtnStyle}" Background="{DynamicResource BtnInstallBg}" Content="&#x1F4E4; Se&#x00E7;imleri JSON Olarak Kaydet" Margin="0,0,10,0"/>
                                <Button x:Name="BtnImportConfig" Style="{StaticResource ActionBtnStyle}" Background="{DynamicResource BtnUpgradeBg}" Content="&#x1F4C2; JSON Dosyas&#x0131;ndan Y&#x00FC;kle"/>
                            </StackPanel>
                        </StackPanel>
                    </Border>

                    <Border Background="{DynamicResource CardBg}" BorderBrush="{DynamicResource BorderBrushColor}" BorderThickness="1" CornerRadius="8" Padding="16">
                        <StackPanel>
                            <TextBlock Text="&#x1F4BB; Uzaktan Tek Sat&#x0131;rla &#x00C7;al&#x0131;&#x015F;t&#x0131;rma Komutu" FontSize="16" FontWeight="Bold" Foreground="{DynamicResource AccentColor}"/>
                            <TextBlock Text="PowerShell'de arac&#x0131; kurulum yapmadan do&#x011F;rudan a&#x00E7;mak i&#x00E7;in a&#x015F;a&#x011F;&#x0131;daki komutu kullanabilirsiniz:" FontSize="13" Foreground="{DynamicResource TextMuted}" Margin="0,6,0,10"/>
                            <Border Background="{DynamicResource WindowBg}" BorderBrush="{DynamicResource BorderBrushColor}" BorderThickness="1" CornerRadius="6" Padding="12" Margin="0,0,0,10">
                                <TextBox x:Name="TxtRemoteCmd" Text="irm evrantool.evranumut.workers.dev | iex" IsReadOnly="True" Background="Transparent" Foreground="{DynamicResource AccentColor}" BorderThickness="0" FontFamily="Consolas" FontSize="14" FontWeight="Bold"/>
                            </Border>
                            <Button x:Name="BtnCopyCmd" Style="{StaticResource ActionBtnStyle}" Background="{DynamicResource HoverBg}" Content="&#x1F4CB; Komutu Panoya Kopyala" HorizontalAlignment="Left"/>
                        </StackPanel>
                    </Border>
                </StackPanel>
            </Grid>
        </Grid>

        <!-- SAG CANLI LOG VE ISLEM DURUM PANELI -->
        <Border Grid.Column="2" Background="{DynamicResource PanelBg}" BorderBrush="{DynamicResource BorderBrushColor}" BorderThickness="1,0,0,0" Padding="14">
            <Grid>
                <Grid.RowDefinitions>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="*"/>
                    <RowDefinition Height="Auto"/>
                </Grid.RowDefinitions>

                <TextBlock Grid.Row="0" Text="&#x1F4DF; CANLI &#x0130;&#x015E;LEM KAYITLARI (LOG)" FontSize="13" FontWeight="Bold" Foreground="{DynamicResource AccentColor}" Margin="0,0,0,8"/>

                <StackPanel Grid.Row="1" Margin="0,0,0,10">
                    <TextBlock x:Name="TxtStatus" Text="Haz&#x0131;r - &#x0130;&#x015F;lem bekleniyor..." FontSize="12.5" Foreground="#E2E8F0" Margin="0,0,0,6" TextWrapping="Wrap"/>
                    <ProgressBar x:Name="ProgressBarMain" Height="10" Minimum="0" Maximum="100" Value="0" Background="{DynamicResource CardBg}" Foreground="{DynamicResource AccentColor}" BorderThickness="0"/>
                </StackPanel>

                <Border Grid.Row="2" Background="{DynamicResource LogBg}" BorderBrush="{DynamicResource BorderBrushColor}" BorderThickness="1" CornerRadius="6" Padding="8">
                    <TextBox x:Name="TxtLog" Background="Transparent" Foreground="{DynamicResource LogFg}" BorderThickness="0"
                             FontFamily="Consolas" FontSize="11.5" IsReadOnly="True" TextWrapping="Wrap"
                             VerticalScrollBarVisibility="Auto" AcceptsReturn="True"/>
                </Border>

                <Button x:Name="BtnClearLog" Grid.Row="3" Style="{StaticResource ActionBtnStyle}" Background="{DynamicResource CardBg}" Content="Kay&#x0131;tlar&#x0131; Temizle" Margin="0,10,0,0"/>
            </Grid>
        </Border>
    </Grid>
</Window>
'@

# =============================================================================
# UMUT EVRAN TOOL v3.0 - CANLI TEMA DESTEKLI ANA KOD (100% PURE ASCII)
# =============================================================================

function Decode-U([string]$text) {
    if ([string]::IsNullOrEmpty($text)) { return "" }
    return [regex]::Replace($text, '\\u([0-9a-fA-F]{4})', { param($m) [char][int]("0x" + $m.Groups[1].Value) })
}

# --- CLI / KOMUT SATIRI PRESET MODU ---
if ($args.Count -gt 0 -and $args[0]) {
    $presetArg = $args[0].ToLower()
    $cliIds = @()
    if ($presetArg -match "umut") {
        $cliIds = @("TheBrowserCompany.Arc", "Brave.Brave", "Discord.Discord", "Valve.Steam", "EpicGames.EpicGamesLauncher", "ElectronicArts.EADesktop", "SteelSeries.GG", "PrismLauncher.PrismLauncher", "VideoLAN.VLC", "OBSProject.OBSStudio", "Spotify.Spotify", "Microsoft.VisualStudioCode", "Git.Git", "7zip.7zip", "RARLab.WinRAR", "voidtools.Everything", "Microsoft.PowerToys", "Google.Drive", "AnyDeskSoftwareGmbH.AnyDesk")
    } elseif ($presetArg -match "gamer|oyuncu") {
        $cliIds = @("TheBrowserCompany.Arc", "Brave.Brave", "Discord.Discord", "Valve.Steam", "EpicGames.EpicGamesLauncher", "SteelSeries.GG", "VideoLAN.VLC", "7zip.7zip")
    } elseif ($presetArg -match "dev|gelistirici") {
        $cliIds = @("TheBrowserCompany.Arc", "Microsoft.VisualStudioCode", "Git.Git", "OpenJS.NodeJS.LTS", "Python.Python.3.12", "Microsoft.WindowsTerminal", "Postman.Postman", "7zip.7zip")
    } elseif ($presetArg -match "standart|standard") {
        $cliIds = @("Google.Chrome", "7zip.7zip", "RARLab.WinRAR", "VideoLAN.VLC", "Spotify.Spotify", "Discord.Discord", "voidtools.Everything")
    }
    if ($cliIds.Count -gt 0) {
        Write-Host "[+] CLI Preset Kurulumu Baslatiliyor: $presetArg" -ForegroundColor Cyan
        foreach ($id in $cliIds) {
            Write-Host " -> Kuruluyor: $id" -ForegroundColor Yellow
            winget install --id $id -e --silent --accept-package-agreements --accept-source-agreements
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

# --- Gomulu Veriler ---
$script:ThemesData = @'
{
  "olive": {
    "Name": "Askeri Adacayi Yesili",
    "WindowBg": "#19221D",
    "PanelBg": "#131C17",
    "CardBg": "#212D26",
    "BorderBrushColor": "#34463B",
    "HoverBg": "#2C3C33",
    "AccentColor": "#A3B18A",
    "ActiveBtnColor": "#4E664A",
    "TextMuted": "#99A799",
    "TextDim": "#677567",
    "LogBg": "#0E1511",
    "LogFg": "#D8F3DC",
    "BtnInstall": "#588157",
    "BtnUninstall": "#8B4B4B",
    "BtnUpgrade": "#3A5A40"
  },
  "amber": {
    "Name": "Karbon Kehribar Turuncu",
    "WindowBg": "#16161A",
    "PanelBg": "#111114",
    "CardBg": "#1F1F24",
    "BorderBrushColor": "#383842",
    "HoverBg": "#2A2A32",
    "AccentColor": "#F97316",
    "ActiveBtnColor": "#EA580C",
    "TextMuted": "#A1A1AA",
    "TextDim": "#71717A",
    "LogBg": "#0A0A0C",
    "LogFg": "#FED7AA",
    "BtnInstall": "#10B981",
    "BtnUninstall": "#EF4444",
    "BtnUpgrade": "#EA580C"
  },
  "neon": {
    "Name": "Siberpunk Neon Pembe",
    "WindowBg": "#0C0A17",
    "PanelBg": "#080611",
    "CardBg": "#171329",
    "BorderBrushColor": "#322754",
    "HoverBg": "#241D3F",
    "AccentColor": "#EC4899",
    "ActiveBtnColor": "#BE185D",
    "TextMuted": "#C084FC",
    "TextDim": "#7E22CE",
    "LogBg": "#05030A",
    "LogFg": "#FBCFE8",
    "BtnInstall": "#10B981",
    "BtnUninstall": "#EF4444",
    "BtnUpgrade": "#7C3AED"
  }
}
'@ | ConvertFrom-Json

$TweaksData = @'
[
  {
    "Group": "Performans ve Oyun Optimizasyonlar\u0131",
    "Items": [
      {
        "Id": "Tweak_UltimatePerf",
        "Recommended": true,
        "Title": "Nihai Performans (Ultimate Performance) G\u00fc\u00e7 Plan\u0131n\u0131 Etkinle\u015ftir",
        "Desc": "\u0130\u015flemci frekans d\u00fc\u015f\u00fc\u015flerini ve mikro gecikmeleri \u00f6nleyen en y\u00fcksek g\u00fc\u00e7 plan\u0131n\u0131 a\u00e7ar."
      },
      {
        "Id": "Tweak_MouseAccel",
        "Recommended": true,
        "Title": "Fare \u0130vmesini (Enhance Pointer Precision) Kapat (FPS / CS2 \u0130\u00e7in)",
        "Desc": "Windows fare ivmesini kapatarak oyunlarda 1:1 ham fare hassasiyeti sa\u011flar."
      },
      {
        "Id": "Tweak_GameDVR",
        "Recommended": true,
        "Title": "Xbox GameDVR Arka Plan Kayd\u0131n\u0131 Kapat ve Oyun Modunu A\u00e7",
        "Desc": "Oyunlarda FPS d\u00fc\u015f\u00fc\u015f\u00fcne sebep olan arka plan video kayd\u0131n\u0131 kapat\u0131r, Game Mode'u a\u00e7ar."
      },
      {
        "Id": "Tweak_BgApps",
        "Recommended": true,
        "Title": "Gereksiz Arka Plan Uygulamalar\u0131n\u0131 Kapat",
        "Desc": "Ma\u011faza uygulamalar\u0131n\u0131n arka planda RAM ve a\u011f t\u00fcketmesini engeller."
      },
      {
        "Id": "Tweak_VisualFX",
        "Recommended": false,
        "Title": "Men\u00fc Ge\u00e7i\u015flerini H\u0131zland\u0131r (MenuShowDelay = 10ms)",
        "Desc": "Sa\u011f t\u0131k ve men\u00fc a\u00e7\u0131l\u0131\u015f gecikmesini 400ms'den 10ms'ye d\u00fc\u015f\u00fcr\u00fcr."
      },
      {
        "Id": "Tweak_Hibernation",
        "Recommended": false,
        "Title": "Haz\u0131rda Bekletmeyi (Hibernation) Kapat (Diskte 10-30 GB Yer A\u00e7ar)",
        "Desc": "hiberfil.sys dosyas\u0131n\u0131 silerek SSD \u00fczerinde ciddi depolama alan\u0131 kazand\u0131r\u0131r."
      }
    ]
  },
  {
    "Group": "Gizlilik ve Telemetri Ayarlar\u0131",
    "Items": [
      {
        "Id": "Tweak_Telemetry",
        "Recommended": true,
        "Title": "Windows Telemetri ve Veri Toplama Servislerini S\u0131n\u0131rla",
        "Desc": "DiagTrack servisini ve tan\u0131 verisi g\u00f6nderimini devre d\u0131\u015f\u0131 b\u0131rak\u0131r."
      },
      {
        "Id": "Tweak_AdvertisingId",
        "Recommended": true,
        "Title": "Reklam Kimli\u011fi (Advertising ID) ve \u00d6nerilen \u0130pu\u00e7lar\u0131n\u0131 Kapat",
        "Desc": "Ki\u015fiselle\u015ftirilmi\u015f reklam takibini ve Ba\u015flat men\u00fcs\u00fc \u00f6nerilerini kapat\u0131r."
      },
      {
        "Id": "Tweak_BingSearch",
        "Recommended": true,
        "Title": "Ba\u015flat Men\u00fcs\u00fcnde Bing Web Aramalar\u0131n\u0131 Kapat",
        "Desc": "Ba\u015flat men\u00fcs\u00fcnde arama yaparken internet sonu\u00e7lar\u0131n\u0131n \u00e7\u0131kmas\u0131n\u0131 engeller, aramay\u0131 h\u0131zland\u0131r\u0131r."
      },
      {
        "Id": "Tweak_ActivityHistory",
        "Recommended": true,
        "Title": "Etkinlik Ge\u00e7mi\u015fi (Timeline) Kayd\u0131n\u0131 Kapat",
        "Desc": "Windows'un a\u00e7t\u0131\u011f\u0131n\u0131z dosya ve uygulama ge\u00e7mi\u015fini buluta senkronize etmesini durdurur."
      }
    ]
  },
  {
    "Group": "Windows 11 / 10 Aray\u00fcz ve Kullan\u0131m Kolayl\u0131\u011f\u0131",
    "Items": [
      {
        "Id": "Tweak_ClassicContext",
        "Recommended": true,
        "Title": "Windows 11 Klasik Sa\u011f T\u0131k Men\u00fcs\u00fcn\u00fc Etkinle\u015ftir",
        "Desc": "'Daha fazla se\u00e7enek g\u00f6ster'e basmadan do\u011frudan tam sa\u011f t\u0131k men\u00fcs\u00fcn\u00fc a\u00e7ar."
      },
      {
        "Id": "Tweak_FileExt",
        "Recommended": true,
        "Title": "Bilinen Dosya Uzant\u0131lar\u0131n\u0131 (.exe, .ps1, .txt) G\u00f6ster",
        "Desc": "Dosya Gezgini'nde t\u00fcm dosyalar\u0131n ger\u00e7ek uzant\u0131lar\u0131n\u0131 g\u00f6r\u00fcn\u00fcr yapar."
      },
      {
        "Id": "Tweak_HiddenFiles",
        "Recommended": false,
        "Title": "Gizli Dosya ve Klas\u00f6rleri G\u00f6ster (AppData vb.)",
        "Desc": "Dosya Gezgini'nde gizli klas\u00f6rleri g\u00f6r\u00fcn\u00fcr hale getirir."
      },
      {
        "Id": "Tweak_DarkMode",
        "Recommended": true,
        "Title": "Sistem ve Uygulamalar \u0130\u00e7in Koyu Temay\u0131 (Dark Mode) Etkinle\u015ftir",
        "Desc": "Windows kabu\u011funu ve destekleyen uygulamalar\u0131 koyu temaya ge\u00e7irir."
      },
      {
        "Id": "Tweak_HideTaskbarJunk",
        "Recommended": true,
        "Title": "G\u00f6rev \u00c7ubu\u011fundaki Widget (Hava Durumu) ve G\u00f6rev G\u00f6r\u00fcn\u00fcm\u00fc Butonlar\u0131n\u0131 Gizle",
        "Desc": "G\u00f6rev \u00e7ubu\u011funu sadele\u015ftirir ve arka planda \u00e7al\u0131\u015fan Widget s\u00fcrecini kapat\u0131r."
      }
    ]
  }
]
'@ | ConvertFrom-Json

$BloatwareData = @'
[
  {
    "Name": "Cortana Asistan",
    "Pkg": "*Microsoft.549981C3F5F10*"
  },
  {
    "Name": "Microsoft Haberler (News)",
    "Pkg": "*Microsoft.BingNews*"
  },
  {
    "Name": "MSN Hava Durumu",
    "Pkg": "*Microsoft.BingWeather*"
  },
  {
    "Name": "Microsoft Yard\u0131m Al (GetHelp)",
    "Pkg": "*Microsoft.GetHelp*"
  },
  {
    "Name": "Windows \u0130pu\u00e7lar\u0131 (Tips)",
    "Pkg": "*Microsoft.Getstarted*"
  },
  {
    "Name": "Microsoft Solitaire Collection",
    "Pkg": "*Microsoft.MicrosoftSolitaireCollection*"
  },
  {
    "Name": "Microsoft \u0130nsanlar (People)",
    "Pkg": "*Microsoft.People*"
  },
  {
    "Name": "Windows Haritalar (Maps)",
    "Pkg": "*Microsoft.WindowsMaps*"
  },
  {
    "Name": "Geri Bildirim Merkezi (Feedback Hub)",
    "Pkg": "*Microsoft.WindowsFeedbackHub*"
  },
  {
    "Name": "3D G\u00f6r\u00fcnt\u00fcleyici (3D Viewer)",
    "Pkg": "*Microsoft.Microsoft3DViewer*"
  },
  {
    "Name": "Mixed Reality Portal",
    "Pkg": "*Microsoft.MixedReality.Portal*"
  },
  {
    "Name": "Skype (UWP)",
    "Pkg": "*Microsoft.SkypeApp*"
  },
  {
    "Name": "Clipchamp Video Edit\u00f6r",
    "Pkg": "*Clipchamp.Clipchamp*"
  },
  {
    "Name": "Microsoft To-Do",
    "Pkg": "*Microsoft.Todos*"
  },
  {
    "Name": "Power Automate",
    "Pkg": "*Microsoft.PowerAutomateDesktop*"
  },
  {
    "Name": "Zune M\u00fczik & Film (Groove / Movies)",
    "Pkg": "*Microsoft.Zune*"
  },
  {
    "Name": "Telefon Ba\u011flant\u0131s\u0131 (Your Phone)",
    "Pkg": "*Microsoft.YourPhone*"
  },
  {
    "Name": "Microsoft Aile (Family Safety)",
    "Pkg": "*MicrosoftCorporationII.MicrosoftFamily*"
  }
]
'@ | ConvertFrom-Json

$AppCategories = $sync.AppsConfig

# --- XAML Penceresini Yukle ---
$cleanXaml = $sync.Xaml.TrimStart([char]0xFEFF).Trim()
$window = [System.Windows.Markup.XamlReader]::Parse($cleanXaml)
$sync.Window = $window

# --- Kontrolleri Bagla ---
$ViewApps      = $window.FindName("ViewApps")
$ViewTweaks    = $window.FindName("ViewTweaks")
$ViewBloatware = $window.FindName("ViewBloatware")
$ViewConfig    = $window.FindName("ViewConfig")

$BtnNavApps      = $window.FindName("BtnNavApps")
$BtnNavTweaks    = $window.FindName("BtnNavTweaks")
$BtnNavBloatware = $window.FindName("BtnNavBloatware")
$BtnNavConfig    = $window.FindName("BtnNavConfig")

# Tema Butonlari
$BtnThemeOlive = $window.FindName("BtnThemeOlive")
$BtnThemeAmber = $window.FindName("BtnThemeAmber")
$BtnThemeNeon  = $window.FindName("BtnThemeNeon")

$BtnPresetUmut     = $window.FindName("BtnPresetUmut")
$BtnPresetGamer    = $window.FindName("BtnPresetGamer")
$BtnPresetDev      = $window.FindName("BtnPresetDev")
$BtnPresetStandard = $window.FindName("BtnPresetStandard")
$BtnClearSelection = $window.FindName("BtnClearSelection")
$BtnRestorePoint   = $window.FindName("BtnRestorePoint")

$TxtSearch           = $window.FindName("TxtSearch")
$BtnClearSearch      = $window.FindName("BtnClearSearch")
$CategoryButtonPanel = $window.FindName("CategoryButtonPanel")
$MainStackPanel      = $window.FindName("MainStackPanel")
$TxtSelectedCount    = $window.FindName("TxtSelectedCount")
$BtnInstall          = $window.FindName("BtnInstall")
$BtnUninstall        = $window.FindName("BtnUninstall")
$BtnUpgradeAll       = $window.FindName("BtnUpgradeAll")

$TweaksStackPanel     = $window.FindName("TweaksStackPanel")
$BtnSelectRecTweaks   = $window.FindName("BtnSelectRecTweaks")
$BtnApplyTweaks       = $window.FindName("BtnApplyTweaks")
$BtnRevertContextMenu = $window.FindName("BtnRevertContextMenu")
$BtnCleanTemp         = $window.FindName("BtnCleanTemp")

$BloatwareGrid      = $window.FindName("BloatwareGrid")
$BtnSelectAllBloat  = $window.FindName("BtnSelectAllBloat")
$BtnClearBloat      = $window.FindName("BtnClearBloat")
$BtnRemoveBloatware = $window.FindName("BtnRemoveBloatware")

$BtnExportConfig = $window.FindName("BtnExportConfig")
$BtnImportConfig = $window.FindName("BtnImportConfig")
$TxtRemoteCmd    = $window.FindName("TxtRemoteCmd")
$BtnCopyCmd      = $window.FindName("BtnCopyCmd")

$TxtStatus       = $window.FindName("TxtStatus")
$ProgressBarMain = $window.FindName("ProgressBarMain")
$TxtLog          = $window.FindName("TxtLog")
$BtnClearLog     = $window.FindName("BtnClearLog")
$TxtSysInfo      = $window.FindName("TxtSysInfo")

$sync.TxtLog          = $TxtLog
$sync.TxtStatus       = $TxtStatus
$sync.ProgressBarMain = $ProgressBarMain
$sync.BtnInstall      = $BtnInstall
$sync.BtnUninstall    = $BtnUninstall
$sync.BtnUpgradeAll   = $BtnUpgradeAll
$sync.IsBusy          = $false

function Write-UiLog([string]$msg) {
    $time = (Get-Date).ToString("HH:mm:ss")
    $decoded = Decode-U $msg
    $window.Dispatcher.Invoke([action]{
        $TxtLog.AppendText("[$time] $decoded`r`n")
        $TxtLog.ScrollToEnd()
    })
}

function Set-UiStatus([string]$msg, [double]$progress = -1) {
    $decoded = Decode-U $msg
    $window.Dispatcher.Invoke([action]{
        $TxtStatus.Text = $decoded
        if ($progress -ge 0) {
            $ProgressBarMain.Value = $progress
        }
    })
}

try {
    $osInfo = Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue
    if ($osInfo) {
        $TxtSysInfo.Text = "$($osInfo.Caption)"
    }
} catch {}

# =============================================================================
# CANLI TEMA SISTEMI (REAL-TIME THEME SWITCHER)
# =============================================================================
$script:dynamicThemedItems = @()
$script:currentThemeKey = "olive"
$script:currentActiveNavBtn = $BtnNavApps

function Set-Theme([string]$key) {
    $t = $script:ThemesData.$key
    if (-not $t) { return }
    $script:currentThemeKey = $key

    # XAML DynamicResource fircalarini aninda guncelle
    $resKeys = @("WindowBg", "PanelBg", "CardBg", "BorderBrushColor", "HoverBg", "AccentColor", "ActiveBtnColor", "TextMuted", "TextDim", "LogBg", "LogFg", "BtnInstallBg", "BtnUninstallBg", "BtnUpgradeBg")
    foreach ($rk in $resKeys) {
        if ($t.$rk) {
            $window.Resources[$rk] = Get-Brush $t.$rk
        }
    }

    # Kod tarafinda dinamik uretilen kart ve basliklari aninda boya
    foreach ($item in $script:dynamicThemedItems) {
        if ($item.Type -eq "CatHeader") {
            $item.Element.Foreground = Get-Brush $t.AccentColor
        } elseif ($item.Type -eq "Card") {
            $item.Element.Background = Get-Brush $t.CardBg
            $item.Element.BorderBrush = Get-Brush $t.BorderBrushColor
        } elseif ($item.Type -eq "IconBox") {
            $item.Element.Background = Get-Brush $t.HoverBg
            $item.Element.BorderBrush = Get-Brush $t.BorderBrushColor
        } elseif ($item.Type -eq "Desc") {
            $item.Element.Foreground = Get-Brush $t.TextMuted
        } elseif ($item.Type -eq "Id") {
            $item.Element.Foreground = Get-Brush $t.TextDim
        }
    }

    # Sol menudeki secili aktif butonun rengini guncelle
    if ($script:currentActiveNavBtn) {
        $script:currentActiveNavBtn.Background  = Get-Brush $t.ActiveBtnColor
        $script:currentActiveNavBtn.BorderBrush = Get-Brush $t.AccentColor
    }

    # Ust kategori secili butonunun rengini guncelle
    if ($script:currentActiveCatBtn) {
        $script:currentActiveCatBtn.Background = Get-Brush $t.ActiveBtnColor
    }

    # Tema butonlarinin kenarlik vurgulari
    $BtnThemeOlive.BorderThickness = New-Object System.Windows.Thickness(0)
    $BtnThemeAmber.BorderThickness = New-Object System.Windows.Thickness(0)
    $BtnThemeNeon.BorderThickness  = New-Object System.Windows.Thickness(0)

    if ($key -eq "olive") {
        $BtnThemeOlive.BorderThickness = New-Object System.Windows.Thickness(2)
        $BtnThemeOlive.BorderBrush = Get-Brush "#FFFFFF"
    } elseif ($key -eq "amber") {
        $BtnThemeAmber.BorderThickness = New-Object System.Windows.Thickness(2)
        $BtnThemeAmber.BorderBrush = Get-Brush "#FFFFFF"
    } elseif ($key -eq "neon") {
        $BtnThemeNeon.BorderThickness = New-Object System.Windows.Thickness(2)
        $BtnThemeNeon.BorderBrush = Get-Brush "#FFFFFF"
    }

    Write-UiLog (Decode-U "Tema de\u011Fi\u015Ftirildi: $($t.Name)")
}

$BtnThemeOlive.Add_Click({ Set-Theme "olive" })
$BtnThemeAmber.Add_Click({ Set-Theme "amber" })
$BtnThemeNeon.Add_Click({ Set-Theme "neon" })

# =============================================================================
# 1. SEKME GECISLERI (NAVIGASYON)
# =============================================================================
$navButtons = @($BtnNavApps, $BtnNavTweaks, $BtnNavBloatware, $BtnNavConfig)
$views      = @($ViewApps, $ViewTweaks, $ViewBloatware, $ViewConfig)

function Switch-Tab($activeBtn, $activeView) {
    $t = $script:ThemesData.$($script:currentThemeKey)
    foreach ($v in $views) { $v.Visibility = "Collapsed" }
    foreach ($b in $navButtons) {
        $b.Background  = Get-Brush $t.CardBg
        $b.BorderBrush = Get-Brush $t.BorderBrushColor
    }
    $activeView.Visibility = "Visible"
    $activeBtn.Background  = Get-Brush $t.ActiveBtnColor
    $activeBtn.BorderBrush = Get-Brush $t.AccentColor
    $script:currentActiveNavBtn = $activeBtn
}

$BtnNavApps.Add_Click({ Switch-Tab $BtnNavApps $ViewApps })
$BtnNavTweaks.Add_Click({ Switch-Tab $BtnNavTweaks $ViewTweaks })
$BtnNavBloatware.Add_Click({ Switch-Tab $BtnNavBloatware $ViewBloatware })
$BtnNavConfig.Add_Click({ Switch-Tab $BtnNavConfig $ViewConfig })

$BtnClearLog.Add_Click({ $TxtLog.Clear() })
$BtnCopyCmd.Add_Click({
    [System.Windows.Clipboard]::SetText($TxtRemoteCmd.Text)
    Write-UiLog (Decode-U "Uzaktan \u00E7al\u0131\u015Ft\u0131rma komutu panoya kopyaland\u0131.")
})

# =============================================================================
# 2. UYGULAMA KARTLARI, ARAMA VE KATEGORI FILTRELEME
# =============================================================================
$script:appCheckboxes  = @()
$script:categoryBlocks = @{}
$script:selectedCategory = "ALL"
$script:catButtons = @()
$script:currentActiveCatBtn = $null

$updateCounter = {
    $cnt = ($script:appCheckboxes | Where-Object { $_.IsChecked -eq $true }).Count
    $TxtSelectedCount.Text = (Decode-U "$cnt uygulama se\u00E7ildi")
}

function Apply-AppFilter {
    $q = $TxtSearch.Text.Trim().ToLower()
    foreach ($cat in $AppCategories) {
        $catName = $cat.Category
        $catBorder = $script:categoryBlocks[$catName]
        $catMatch = ($script:selectedCategory -eq "ALL") -or ($script:selectedCategory -eq $catName)
        if (-not $catMatch) {
            $catBorder.Visibility = "Collapsed"
            continue
        }
        $visibleCount = 0
        foreach ($cb in $script:appCheckboxes) {
            if ($cb.Tag.Category -eq $catName) {
                $textMatch = [string]::IsNullOrEmpty($q) -or
                             $cb.Tag.Name.ToLower().Contains($q) -or
                             $cb.Tag.Id.ToLower().Contains($q) -or
                             $cb.Tag.Description.ToLower().Contains($q)
                if ($textMatch) {
                    $cb.Tag.Card.Visibility = "Visible"
                    $visibleCount++
                } else {
                    $cb.Tag.Card.Visibility = "Collapsed"
                }
            }
        }
        if ($visibleCount -gt 0) {
            $catBorder.Visibility = "Visible"
        } else {
            $catBorder.Visibility = "Collapsed"
        }
    }
}

function Set-CategoryButtonActive($clickedBtn) {
    $t = $script:ThemesData.$($script:currentThemeKey)
    foreach ($b in $script:catButtons) {
        $b.Background = Get-Brush $t.CardBg
        $b.Foreground = Get-Brush $t.TextMuted
    }
    $clickedBtn.Background = Get-Brush $t.ActiveBtnColor
    $clickedBtn.Foreground = Get-Brush "#FFFFFF"
    $script:currentActiveCatBtn = $clickedBtn
}

$initTheme = $script:ThemesData.olive

$btnAll = New-Object System.Windows.Controls.Button
$btnAll.Content = (Decode-U "T\u00FCm\u00FC")
$btnAll.Padding = "12,6"
$btnAll.Margin  = "0,0,6,6"
$btnAll.Background = Get-Brush $initTheme.ActiveBtnColor
$btnAll.Foreground = Get-Brush "#FFFFFF"
$btnAll.BorderThickness = "0"
$btnAll.FontWeight = "SemiBold"
$btnAll.Cursor = "Hand"
$btnAll.Add_Click({
    $script:selectedCategory = "ALL"
    Set-CategoryButtonActive $btnAll
    Apply-AppFilter
})
[void]$CategoryButtonPanel.Children.Add($btnAll)
$script:catButtons += $btnAll
$script:currentActiveCatBtn = $btnAll

foreach ($cat in $AppCategories) {
    $catName = $cat.Category

    $cBtn = New-Object System.Windows.Controls.Button
    $cBtn.Content = $catName
    $cBtn.Tag     = $catName
    $cBtn.Padding = "12,6"
    $cBtn.Margin  = "0,0,6,6"
    $cBtn.Background = Get-Brush $initTheme.CardBg
    $cBtn.Foreground = Get-Brush $initTheme.TextMuted
    $cBtn.BorderThickness = "0"
    $cBtn.FontWeight = "SemiBold"
    $cBtn.Cursor = "Hand"
    $cBtn.Add_Click({
        param($sender, $e)
        $script:selectedCategory = $sender.Tag
        Set-CategoryButtonActive $sender
        Apply-AppFilter
    })
    [void]$CategoryButtonPanel.Children.Add($cBtn)
    $script:catButtons += $cBtn

    $catContainer = New-Object System.Windows.Controls.StackPanel
    $catContainer.Margin = "0,0,0,16"

    $catHeader = New-Object System.Windows.Controls.TextBlock
    $catHeader.Text = $catName.ToUpper()
    $catHeader.FontSize = 13
    $catHeader.FontWeight = "Bold"
    $catHeader.Foreground = Get-Brush $initTheme.AccentColor
    $catHeader.Margin = "4,0,0,8"
    [void]$catContainer.Children.Add($catHeader)
    $script:dynamicThemedItems += [PSCustomObject]@{ Type = "CatHeader"; Element = $catHeader }

    $uGrid = New-Object System.Windows.Controls.Primitives.UniformGrid
    $uGrid.Columns = 2

    foreach ($app in $cat.Apps) {
        $card = New-Object System.Windows.Controls.Border
        $card.Background = Get-Brush $initTheme.CardBg
        $card.BorderBrush = Get-Brush $initTheme.BorderBrushColor
        $card.BorderThickness = "1"
        $card.CornerRadius = "6"
        $card.Padding = "10"
        $card.Margin = "4"
        $card.Cursor = "Hand"
        $script:dynamicThemedItems += [PSCustomObject]@{ Type = "Card"; Element = $card }

        $dock = New-Object System.Windows.Controls.DockPanel
        $dock.LastChildFill = $true

        # Sol taraf: Logo / Resmi Simge Kutusu
        $iconBorder = New-Object System.Windows.Controls.Border
        $iconBorder.Width = 40
        $iconBorder.Height = 40
        $iconBorder.CornerRadius = New-Object System.Windows.CornerRadius(6)
        $iconBorder.Background = Get-Brush $initTheme.HoverBg
        $iconBorder.BorderBrush = Get-Brush $initTheme.BorderBrushColor
        $iconBorder.BorderThickness = New-Object System.Windows.Thickness(1)
        $iconBorder.Margin = New-Object System.Windows.Thickness(0, 0, 10, 0)
        $iconBorder.VerticalAlignment = "Center"
        [System.Windows.Controls.DockPanel]::SetDock($iconBorder, [System.Windows.Controls.Dock]::Left)
        $script:dynamicThemedItems += [PSCustomObject]@{ Type = "IconBox"; Element = $iconBorder }

        $img = New-Object System.Windows.Controls.Image
        $img.Width = 28
        $img.Height = 28
        $img.VerticalAlignment = "Center"
        $img.HorizontalAlignment = "Center"
        [System.Windows.Media.RenderOptions]::SetBitmapScalingMode($img, [System.Windows.Media.BitmapScalingMode]::HighQuality)

        if ($app.Icon) {
            try {
                $bi = New-Object System.Windows.Media.Imaging.BitmapImage
                $bi.BeginInit()
                $bi.UriSource = New-Object System.Uri($app.Icon, [System.UriKind]::Absolute)
                $bi.DecodePixelWidth = 64
                $bi.CacheOption = [System.Windows.Media.Imaging.BitmapCacheOption]::OnLoad
                $bi.EndInit()
                $img.Source = $bi
            } catch {}
        }
        $iconBorder.Child = $img
        [void]$dock.Children.Add($iconBorder)

        $sp = New-Object System.Windows.Controls.StackPanel
        $sp.VerticalAlignment = "Center"

        $cb = New-Object System.Windows.Controls.CheckBox
        $cb.Foreground = Get-Brush "#F8FAFC"
        $cb.FontWeight = "Bold"
        $cb.FontSize = 13.5
        $cb.Content = $app.Name
        $cb.Tag = [PSCustomObject]@{
            Name        = $app.Name
            Id          = $app.Id
            Description = $app.Description
            Category    = $catName
            Card        = $card
        }
        $cb.Add_Checked($updateCounter)
        $cb.Add_Unchecked($updateCounter)

        $descBlock = New-Object System.Windows.Controls.TextBlock
        $descBlock.Text = $app.Description
        $descBlock.FontSize = 11.5
        $descBlock.Foreground = Get-Brush $initTheme.TextMuted
        $descBlock.TextWrapping = "Wrap"
        $descBlock.Margin = "0,3,0,2"
        $script:dynamicThemedItems += [PSCustomObject]@{ Type = "Desc"; Element = $descBlock }

        $idBlock = New-Object System.Windows.Controls.TextBlock
        $idBlock.Text = $app.Id
        $idBlock.FontSize = 10
        $idBlock.FontFamily = "Consolas"
        $idBlock.Foreground = Get-Brush $initTheme.TextDim
        $idBlock.Margin = "0,0,0,0"
        $script:dynamicThemedItems += [PSCustomObject]@{ Type = "Id"; Element = $idBlock }

        [void]$sp.Children.Add($cb)
        [void]$sp.Children.Add($descBlock)
        [void]$sp.Children.Add($idBlock)

        [void]$dock.Children.Add($sp)
        $card.Child = $dock

        $card.Tag = $cb
        $card.Add_MouseLeftButtonUp({
            param($sender, $e)
            if ($e.OriginalSource -isnot [System.Windows.Controls.CheckBox]) {
                $targetCb = $sender.Tag
                $targetCb.IsChecked = -not $targetCb.IsChecked
            }
        })

        [void]$uGrid.Children.Add($card)
        $script:appCheckboxes += $cb
    }

    [void]$catContainer.Children.Add($uGrid)
    [void]$MainStackPanel.Children.Add($catContainer)
    $script:categoryBlocks[$catName] = $catContainer
}

$TxtSearch.Add_TextChanged({ Apply-AppFilter })
$BtnClearSearch.Add_Click({
    $TxtSearch.Text = ""
    Apply-AppFilter
})

# =============================================================================
# 3. HAZIR PAKETLER (PRESETS)
# =============================================================================
function Select-PresetByIds([string[]]$ids, [string]$presetTitle) {
    Switch-Tab $BtnNavApps $ViewApps
    foreach ($cb in $script:appCheckboxes) {
        $cb.IsChecked = ($ids -contains $cb.Tag.Id)
    }
    Write-UiLog (Decode-U "$presetTitle se\u00E7ildi ($($ids.Count) uygulama).")
}

$BtnPresetUmut.Add_Click({
    $umutIds = @(
        "TheBrowserCompany.Arc", "Brave.Brave", "Discord.Discord", "Valve.Steam",
        "EpicGames.EpicGamesLauncher", "ElectronicArts.EADesktop", "SteelSeries.GG",
        "PrismLauncher.PrismLauncher", "VideoLAN.VLC", "OBSProject.OBSStudio",
        "Spotify.Spotify", "Microsoft.VisualStudioCode", "Git.Git", "7zip.7zip",
        "RARLab.WinRAR", "voidtools.Everything", "Microsoft.PowerToys",
        "Google.Drive", "AnyDeskSoftwareGmbH.AnyDesk"
    )
    Select-PresetByIds $umutIds (Decode-U "\uD83D\uDC51 Umut \u00D6zel Paketi")
})

$BtnPresetGamer.Add_Click({
    $gamerIds = @(
        "TheBrowserCompany.Arc", "Brave.Brave", "Discord.Discord", "Valve.Steam",
        "EpicGames.EpicGamesLauncher", "ElectronicArts.EADesktop", "SteelSeries.GG",
        "VideoLAN.VLC", "OBSProject.OBSStudio", "7zip.7zip", "Spotify.Spotify",
        "PrismLauncher.PrismLauncher"
    )
    Select-PresetByIds $gamerIds "Oyuncu Paketi"
})

$BtnPresetDev.Add_Click({
    $devIds = @(
        "TheBrowserCompany.Arc", "Microsoft.VisualStudioCode", "Git.Git", "GitHub.GitHubDesktop",
        "OpenJS.NodeJS.LTS", "Python.Python.3.12", "Microsoft.WindowsTerminal", "Microsoft.PowerShell",
        "Postman.Postman", "Notepad++.Notepad++", "7zip.7zip", "Microsoft.PowerToys"
    )
    Select-PresetByIds $devIds (Decode-U "Geli\u015Ftirici Paketi")
})

$BtnPresetStandard.Add_Click({
    $stdIds = @(
        "Google.Chrome", "7zip.7zip", "RARLab.WinRAR", "VideoLAN.VLC",
        "Spotify.Spotify", "Discord.Discord", "voidtools.Everything",
        "Skillbrains.Lightshot", "Adobe.Acrobat.Reader.64-bit"
    )
    Select-PresetByIds $stdIds "Standart Format Sonrasi Paketi"
})

$BtnClearSelection.Add_Click({
    foreach ($cb in $script:appCheckboxes) { $cb.IsChecked = $false }
    Write-UiLog (Decode-U "T\u00FCm uygulama se\u00E7imleri temizlendi.")
})

# =============================================================================
# 4. ARKA PLAN RUNSPACE ILE WINGET KURULUM / KALDIRMA / GUNCELLEME
# =============================================================================
function Start-WingetJob([array]$appsList, [string]$mode) {
    if ($sync.IsBusy) {
        Write-UiLog (Decode-U "[!] \u015Eu anda devam eden bir i\u015Flem var, l\u00FCtfen bitmesini bekleyin.")
        return
    }
    $sync.IsBusy = $true
    $BtnInstall.IsEnabled    = $false
    $BtnUninstall.IsEnabled  = $false
    $BtnUpgradeAll.IsEnabled = $false

    $rs = [runspacefactory]::CreateRunspace()
    $rs.ApartmentState = "STA"
    $rs.ThreadOptions  = "ReuseThread"
    $rs.Open()
    $rs.SessionStateProxy.SetVariable("sync", $sync)
    $rs.SessionStateProxy.SetVariable("appsList", $appsList)
    $rs.SessionStateProxy.SetVariable("mode", $mode)

    $ps = [powershell]::Create()
    $ps.Runspace = $rs
    [void]$ps.AddScript({
        function Log-Bg([string]$m) {
            $t = (Get-Date).ToString("HH:mm:ss")
            $sync.Window.Dispatcher.Invoke([action]{
                $sync.TxtLog.AppendText("[$t] $m`r`n")
                $sync.TxtLog.ScrollToEnd()
            })
        }
        function Status-Bg([string]$s, [double]$p) {
            $sync.Window.Dispatcher.Invoke([action]{
                $sync.TxtStatus.Text = $s
                if ($p -ge 0) { $sync.ProgressBarMain.Value = $p }
            })
        }

        try {
            if ($mode -eq "upgrade_all") {
                Status-Bg "Tum sistem uygulamalariniz Winget ile guncelleniyor..." 20
                Log-Bg ">>> Baslatiliyor: winget upgrade --all"
                $proc = Start-Process -FilePath "winget.exe" -ArgumentList "upgrade --all --silent --accept-package-agreements --accept-source-agreements" -NoNewWindow -Wait -PassThru
                Log-Bg ">>> Tum guncellemeler tamamlandi (Cikis Kodu: $($proc.ExitCode))."
                Status-Bg "Guncelleme islemi tamamlandi!" 100
            } else {
                $total = $appsList.Count
                $idx = 0
                foreach ($item in $appsList) {
                    $idx++
                    $pct = [math]::Round(($idx / $total) * 100)
                    if ($mode -eq "install") {
                        Status-Bg "($idx/$total) Kuruluyor: $($item.Name)..." $pct
                        Log-Bg "[$idx/$total] Kuruluyor: $($item.Name) ($($item.Id))"
                        $p = Start-Process -FilePath "winget.exe" -ArgumentList "install --id `"$($item.Id)`" -e --silent --accept-package-agreements --accept-source-agreements" -NoNewWindow -Wait -PassThru
                        if ($p.ExitCode -eq 0) {
                            Log-Bg "  [OK] $($item.Name) basariyla kuruldu."
                        } else {
                            Log-Bg "  [!] $($item.Name) cikis kodu: $($p.ExitCode)"
                        }
                    } elseif ($mode -eq "uninstall") {
                        Status-Bg "($idx/$total) Kaldiriliyor: $($item.Name)..." $pct
                        Log-Bg "[$idx/$total] Kaldiriliyor: $($item.Name) ($($item.Id))"
                        $p = Start-Process -FilePath "winget.exe" -ArgumentList "uninstall --id `"$($item.Id)`" -e --silent --accept-source-agreements" -NoNewWindow -Wait -PassThru
                        if ($p.ExitCode -eq 0) {
                            Log-Bg "  [OK] $($item.Name) kaldirildi."
                        } else {
                            Log-Bg "  [!] $($item.Name) cikis kodu: $($p.ExitCode)"
                        }
                    }
                }
                Status-Bg "Secili islemler tamamlandi ($total / $total)!" 100
                Log-Bg "=== TUM WINGET ISLEMLERI TAMAMLANDI ==="
            }
        } catch {
            Log-Bg "[HATA] $($_.Exception.Message)"
        } finally {
            $sync.Window.Dispatcher.Invoke([action]{
                $sync.BtnInstall.IsEnabled    = $true
                $sync.BtnUninstall.IsEnabled  = $true
                $sync.BtnUpgradeAll.IsEnabled = $true
                $sync.IsBusy = $false
            })
        }
    })
    [void]$ps.BeginInvoke()
}

$BtnInstall.Add_Click({
    $selected = @($script:appCheckboxes | Where-Object { $_.IsChecked -eq $true } | ForEach-Object { $_.Tag })
    if ($selected.Count -eq 0) {
        Write-UiLog (Decode-U "[!] L\u00FCtfen kurmak i\u00E7in en az bir uygulama se\u00E7in.")
        return
    }
    Start-WingetJob $selected "install"
})

$BtnUninstall.Add_Click({
    $selected = @($script:appCheckboxes | Where-Object { $_.IsChecked -eq $true } | ForEach-Object { $_.Tag })
    if ($selected.Count -eq 0) {
        Write-UiLog (Decode-U "[!] L\u00FCtfen kald\u0131rmak i\u00E7in en az bir uygulama se\u00E7in.")
        return
    }
    Start-WingetJob $selected "uninstall"
})

$BtnUpgradeAll.Add_Click({
    Start-WingetJob @() "upgrade_all"
})

# =============================================================================
# 5. SEKME 2: SISTEM INCE AYARLARI (TWEAKS)
# =============================================================================
$script:tweakCheckboxes = @()

foreach ($grp in $TweaksData) {
    $gHeader = New-Object System.Windows.Controls.TextBlock
    $gHeader.Text = $grp.Group.ToUpper()
    $gHeader.FontSize = 13
    $gHeader.FontWeight = "Bold"
    $gHeader.Foreground = Get-Brush $initTheme.AccentColor
    $gHeader.Margin = "4,8,0,8"
    [void]$TweaksStackPanel.Children.Add($gHeader)
    $script:dynamicThemedItems += [PSCustomObject]@{ Type = "CatHeader"; Element = $gHeader }

    foreach ($tw in $grp.Items) {
        $card = New-Object System.Windows.Controls.Border
        $card.Background = Get-Brush $initTheme.CardBg
        $card.BorderBrush = Get-Brush $initTheme.BorderBrushColor
        $card.BorderThickness = "1"
        $card.CornerRadius = "6"
        $card.Padding = "10"
        $card.Margin = "0,0,0,6"
        $script:dynamicThemedItems += [PSCustomObject]@{ Type = "Card"; Element = $card }

        $sp = New-Object System.Windows.Controls.StackPanel
        $cb = New-Object System.Windows.Controls.CheckBox
        $cb.Content = $tw.Title
        $cb.Foreground = Get-Brush "#F8FAFC"
        $cb.FontWeight = "SemiBold"
        $cb.FontSize = 13
        $cb.IsChecked = [bool]$tw.Recommended
        $cb.Tag = $tw

        $d = New-Object System.Windows.Controls.TextBlock
        $d.Text = $tw.Desc
        $d.FontSize = 11.5
        $d.Foreground = Get-Brush $initTheme.TextMuted
        $d.Margin = "22,3,0,0"
        $d.TextWrapping = "Wrap"
        $script:dynamicThemedItems += [PSCustomObject]@{ Type = "Desc"; Element = $d }

        [void]$sp.Children.Add($cb)
        [void]$sp.Children.Add($d)
        $card.Child = $sp
        [void]$TweaksStackPanel.Children.Add($card)
        $script:tweakCheckboxes += $cb
    }
}

$BtnSelectRecTweaks.Add_Click({
    foreach ($cb in $script:tweakCheckboxes) {
        $cb.IsChecked = [bool]$cb.Tag.Recommended
    }
    Write-UiLog (Decode-U "\u00D6nerilen sistem ince ayarlar\u0131 i\u015Faretlendi.")
})

$BtnApplyTweaks.Add_Click({
    $selectedTweaks = @($script:tweakCheckboxes | Where-Object { $_.IsChecked -eq $true } | ForEach-Object { $_.Tag })
    if ($selectedTweaks.Count -eq 0) {
        Write-UiLog (Decode-U "[!] Uygulanacak ince ayar se\u00E7ilmedi.")
        return
    }
    Write-UiLog (Decode-U ">>> Se\u00E7ili $($selectedTweaks.Count) sistem ince ayar\u0131 uygulan\u0131yor...")
    $done = 0
    foreach ($tw in $selectedTweaks) {
        $done++
        Set-UiStatus "Uygulaniyor: $($tw.Title)" (($done / $selectedTweaks.Count) * 100)
        try {
            switch ($tw.Id) {
                "Tweak_UltimatePerf" {
                    powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 | Out-Null
                    Write-UiLog "[OK] Nihai Performans guc plani aktif edildi."
                }
                "Tweak_MouseAccel" {
                    Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSpeed" -Value "0" -Force
                    Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold1" -Value "0" -Force
                    Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold2" -Value "0" -Force
                    Write-UiLog "[OK] Fare ivmesi (Mouse Acceleration) kapatildi."
                }
                "Tweak_GameDVR" {
                    if (!(Test-Path "HKCU:\System\GameConfigStore")) { New-Item "HKCU:\System\GameConfigStore" -Force | Out-Null }
                    Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Type DWord -Value 0 -Force
                    if (!(Test-Path "HKCU:\Software\Microsoft\GameBar")) { New-Item "HKCU:\Software\Microsoft\GameBar" -Force | Out-Null }
                    Set-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar" -Name "AutoGameModeEnabled" -Type DWord -Value 1 -Force
                    Write-UiLog "[OK] GameDVR arka plan kaydi kapatildi, Oyun Modu acildi."
                }
                "Tweak_BgApps" {
                    if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications")) {
                        New-Item "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" -Force | Out-Null
                    }
                    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" -Name "GlobalUserDisabled" -Type DWord -Value 1 -Force
                    Write-UiLog "[OK] Arka plan uygulamalari sinirlandirildi."
                }
                "Tweak_VisualFX" {
                    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -Value "10" -Force
                    Write-UiLog "[OK] Menu acilis gecikmesi 10ms yapildi."
                }
                "Tweak_Hibernation" {
                    powercfg -h off | Out-Null
                    Write-UiLog "[OK] Hazirda bekletme (Hibernation) kapatildi."
                }
                "Tweak_Telemetry" {
                    if (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection")) {
                        New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Force | Out-Null
                    }
                    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0 -Force
                    Stop-Service "DiagTrack" -ErrorAction SilentlyContinue
                    Set-Service "DiagTrack" -StartupType Disabled -ErrorAction SilentlyContinue
                    Write-UiLog "[OK] Windows Telemetri ve DiagTrack devre disi birakildi."
                }
                "Tweak_AdvertisingId" {
                    if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo")) {
                        New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Force | Out-Null
                    }
                    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -Type DWord -Value 0 -Force
                    Write-UiLog "[OK] Reklam Kimligi (Advertising ID) kapatildi."
                }
                "Tweak_BingSearch" {
                    if (!(Test-Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer")) {
                        New-Item -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Force | Out-Null
                    }
                    Set-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Name "DisableSearchBoxSuggestions" -Type DWord -Value 1 -Force
                    Write-UiLog "[OK] Baslat menusu Bing web aramalari kapatildi."
                }
                "Tweak_ActivityHistory" {
                    if (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System")) {
                        New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Force | Out-Null
                    }
                    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "PublishUserActivities" -Type DWord -Value 0 -Force
                    Write-UiLog "[OK] Etkinlik gecmisi (Timeline) kapatildi."
                }
                "Tweak_ClassicContext" {
                    New-Item -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" -Value "" -Force | Out-Null
                    Write-UiLog "[OK] Windows 11 klasik sag tik menusu aktif edildi."
                }
                "Tweak_FileExt" {
                    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Type DWord -Value 0 -Force
                    Write-UiLog "[OK] Dosya uzantilari gorunur yapildi."
                }
                "Tweak_HiddenFiles" {
                    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Type DWord -Value 1 -Force
                    Write-UiLog "[OK] Gizli dosya ve klasorler gorunur yapildi."
                }
                "Tweak_DarkMode" {
                    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Type DWord -Value 0 -Force
                    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Type DWord -Value 0 -Force
                    Write-UiLog "[OK] Sistem ve uygulama Koyu Tema (Dark Mode) aktif edildi."
                }
                "Tweak_HideTaskbarJunk" {
                    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Type DWord -Value 0 -Force
                    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDa" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
                    Write-UiLog "[OK] Gorev cubugu gereksiz simgeleri gizlendi."
                }
            }
        } catch {
            Write-UiLog "[!] $($tw.Id) uygulanirken uyari: $($_.Exception.Message)"
        }
    }
    Set-UiStatus "Secili sistem ince ayarlari uygulandi!" 100
})

$BtnRevertContextMenu.Add_Click({
    Remove-Item -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" -Recurse -Force -ErrorAction SilentlyContinue
    Write-UiLog "[OK] Windows 11 varsayilan sag tik menusune donuldu (Explorer yeniden baslatildiginda aktif olur)."
})

$BtnCleanTemp.Add_Click({
    Write-UiLog ">>> Temp klasorleri ve DNS onbellegi temizleniyor..."
    Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
    ipconfig /flushdns | Out-Null
    Set-UiStatus "Temp dosyalari ve DNS onbellegi temizlendi!" 100
    Write-UiLog "[OK] Gecici dosyalar ve DNS onbellegi basariyla temizlendi."
})

# =============================================================================
# 6. SEKME 3: BLOATWARE TEMIZLIGI
# =============================================================================
$script:bloatCheckboxes = @()

foreach ($bl in $BloatwareData) {
    $card = New-Object System.Windows.Controls.Border
    $card.Background = Get-Brush $initTheme.CardBg
    $card.BorderBrush = Get-Brush $initTheme.BorderBrushColor
    $card.BorderThickness = "1"
    $card.CornerRadius = "6"
    $card.Padding = "10"
    $card.Margin = "4"
    $script:dynamicThemedItems += [PSCustomObject]@{ Type = "Card"; Element = $card }

    $sp = New-Object System.Windows.Controls.StackPanel
    $cb = New-Object System.Windows.Controls.CheckBox
    $cb.Content = $bl.Name
    $cb.Foreground = Get-Brush "#F8FAFC"
    $cb.FontWeight = "SemiBold"
    $cb.FontSize = 13
    $cb.Tag = $bl

    $pkgTxt = New-Object System.Windows.Controls.TextBlock
    $pkgTxt.Text = $bl.Pkg
    $pkgTxt.FontSize = 10.5
    $pkgTxt.FontFamily = "Consolas"
    $pkgTxt.Foreground = Get-Brush $initTheme.TextDim
    $pkgTxt.Margin = "22,3,0,0"
    $script:dynamicThemedItems += [PSCustomObject]@{ Type = "Id"; Element = $pkgTxt }

    [void]$sp.Children.Add($cb)
    [void]$sp.Children.Add($pkgTxt)
    $card.Child = $sp
    [void]$BloatwareGrid.Children.Add($card)
    $script:bloatCheckboxes += $cb
}

$BtnSelectAllBloat.Add_Click({
    foreach ($cb in $script:bloatCheckboxes) { $cb.IsChecked = $true }
})

$BtnClearBloat.Add_Click({
    foreach ($cb in $script:bloatCheckboxes) { $cb.IsChecked = $false }
})

$BtnRemoveBloatware.Add_Click({
    $selBloat = @($script:bloatCheckboxes | Where-Object { $_.IsChecked -eq $true } | ForEach-Object { $_.Tag })
    if ($selBloat.Count -eq 0) {
        Write-UiLog "[!] Lutfen kaldirmak icin en az bir Bloatware uygulamasi secin."
        return
    }
    Write-UiLog ">>> $($selBloat.Count) Bloatware paketi sistemden kaldiriliyor..."
    $i = 0
    foreach ($b in $selBloat) {
        $i++
        Set-UiStatus "Kaldiriliyor: $($b.Name)..." (($i / $selBloat.Count) * 100)
        Get-AppxPackage -Name $b.Pkg -AllUsers -ErrorAction SilentlyContinue | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
        Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Where-Object DisplayName -like $b.Pkg | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Out-Null
        Write-UiLog "[OK] Kaldirildi: $($b.Name)"
    }
    Set-UiStatus "Secili Bloatware paketleri kaldirildi!" 100
})

# =============================================================================
# 7. SEKME 4: YEDEKLEME (CONFIG EXPORT / IMPORT) & GERI YUKLEME NOKTASI
# =============================================================================
$BtnExportConfig.Add_Click({
    $sfd = New-Object System.Windows.Forms.SaveFileDialog
    $sfd.Filter = "JSON Config (*.json)|*.json"
    $sfd.FileName = "UmutEvranTool_Secimler.json"
    if ($sfd.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $exportObj = [PSCustomObject]@{
            Theme  = $script:currentThemeKey
            Apps   = @($script:appCheckboxes | Where-Object { $_.IsChecked -eq $true } | ForEach-Object { $_.Tag.Id })
            Tweaks = @($script:tweakCheckboxes | Where-Object { $_.IsChecked -eq $true } | ForEach-Object { $_.Tag.Id })
        }
        $jsonOut = $exportObj | ConvertTo-Json -Depth 3
        [System.IO.File]::WriteAllText($sfd.FileName, $jsonOut, [System.Text.Encoding]::UTF8)
        Write-UiLog "[OK] Secimler kaydedildi: $($sfd.FileName)"
    }
})

$BtnImportConfig.Add_Click({
    $ofd = New-Object System.Windows.Forms.OpenFileDialog
    $ofd.Filter = "JSON Config (*.json)|*.json"
    if ($ofd.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        try {
            $imported = [System.IO.File]::ReadAllText($ofd.FileName, [System.Text.Encoding]::UTF8) | ConvertFrom-Json
            if ($imported.Theme) {
                Set-Theme $imported.Theme
            }
            foreach ($cb in $script:appCheckboxes) {
                $cb.IsChecked = ($imported.Apps -contains $cb.Tag.Id)
            }
            foreach ($cb in $script:tweakCheckboxes) {
                $cb.IsChecked = ($imported.Tweaks -contains $cb.Tag.Id)
            }
            Switch-Tab $BtnNavApps $ViewApps
            Write-UiLog "[OK] Yapilandirma basariyla yuklendi: $($ofd.FileName)"
        } catch {
            Write-UiLog "[HATA] JSON dosyasi okunamadi: $($_.Exception.Message)"
        }
    }
})

$BtnRestorePoint.Add_Click({
    try {
        Write-UiLog ">>> Sistem Geri Yukleme Noktasi olusturuluyor..."
        Enable-ComputerRestore -Drive "$env:SystemDrive\" -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\SystemRestore" -Name "SystemRestorePointCreationFrequency" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
        Checkpoint-Computer -Description "UmutEvranTool_Oncesi" -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop
        Write-UiLog "[OK] Sistem Geri Yukleme Noktasi basariyla olusturuldu!"
        Set-UiStatus "Geri yukleme noktasi olusturuldu!" 100
    } catch {
        Write-UiLog "[!] Geri yukleme noktasi olusturulamadi (Sistem Korumasi kapali olabilir): $($_.Exception.Message)"
    }
})

# Baslangic temasini aktif et (Varsayilan Askeri Adacayi Yesili)
Set-Theme "olive"
Write-UiLog (Decode-U "Umut Evran Tool v3.0 Canl\u0131 Tema Sistemi ile ba\u015Flat\u0131ld\u0131.")

[void]$window.ShowDialog()
