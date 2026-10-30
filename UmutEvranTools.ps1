# =============================================================================
# UMUT EVRAN TOOL (TEK DOSYA / UZAKTAN CALISTIRMA SURUMU)
# Komut: irm evrantool.evranumut.workers.dev | iex
# Mimari: 100% Pure ASCII + Decode-U + WPF XamlReader + Runspace Multithreading
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
      },
      {
        "Name": "Chromium",
        "Id": "Hibbiki.Chromium",
        "Description": "Google servislerinden ar\u0131nd\u0131r\u0131lm\u0131\u015f a\u00e7\u0131k kaynakl\u0131 Chromium web taray\u0131c\u0131s\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=chromium.org&sz=128"
      },
      {
        "Name": "Firefox ESR",
        "Id": "Mozilla.Firefox.ESR",
        "Description": "Kurumsal ve uzun s\u00fcreli kararl\u0131l\u0131k odakl\u0131 Mozilla Firefox Geni\u015fletilmi\u015f Destek S\u00fcr\u00fcm\u00fc.",
        "Icon": "https://www.google.com/s2/favicons?domain=mozilla.org&sz=128"
      },
      {
        "Name": "Floorp",
        "Id": "Ablaze.Floorp",
        "Description": "Y\u00fcksek \u00f6zelle\u015ftirme ve gizlilik \u00f6zelliklerine sahip Firefox tabanl\u0131 modern taray\u0131c\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=floorp.app&sz=128"
      },
      {
        "Name": "Helium",
        "Id": "ImputNet.Helium",
        "Description": "Hafif, h\u0131zl\u0131 ve gizlilik odakl\u0131 yeni nesil Chromium tabanl\u0131 web taray\u0131c\u0131s\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=helium.computer&sz=128"
      },
      {
        "Name": "Mullvad Browser",
        "Id": "MullvadVPN.MullvadBrowser",
        "Description": "Tor Projesi i\u015f birli\u011fiyle geli\u015ftirilen, parmak izi takibini \u00f6nleyen maksimum gizlilik taray\u0131c\u0131s\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=mullvad.net&sz=128"
      },
      {
        "Name": "Ungoogled Chromium",
        "Id": "eloston.ungoogled-chromium",
        "Description": "Google ba\u011flant\u0131 ve izleyicilerinden tamamen ar\u0131nd\u0131r\u0131lm\u0131\u015f maksimum gizlilikli Chromium.",
        "Icon": "https://www.google.com/s2/favicons?domain=github.com&sz=128"
      },
      {
        "Name": "Waterfox",
        "Id": "Waterfox.Waterfox",
        "Description": "Gizlilik ve h\u0131z odakl\u0131, eski ve modern eklentileri destekleyen Firefox tabanl\u0131 taray\u0131c\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=waterfox.net&sz=128"
      },
      {
        "Name": "Zen Browser",
        "Id": "Zen-Team.Zen-Browser",
        "Description": "Arc benzeri dikey sekme ve \u00e7al\u0131\u015fma alan\u0131 tasar\u0131m\u0131na sahip, Firefox tabanl\u0131 modern ve h\u0131zl\u0131 taray\u0131c\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=zen-browser.app&sz=128"
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
      },
      {
        "Name": "Bruno",
        "Id": "Bruno.Bruno",
        "Description": "Git dostu, \u00e7evrimd\u0131\u015f\u0131 \u00e7al\u0131\u015fan h\u0131zl\u0131 ve a\u00e7\u0131k kaynakl\u0131 API istemcisi.",
        "Icon": "https://www.google.com/s2/favicons?domain=usebruno.com&sz=128"
      },
      {
        "Name": "ChatGPT Desktop",
        "Id": "9NT1R1C2HH7J",
        "Description": "OpenAI taraf\u0131ndan geli\u015ftirilen resmi masa\u00fcst\u00fc yapay zeka asistan\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=openai.com&sz=128"
      },
      {
        "Name": "Claude Desktop",
        "Id": "Anthropic.Claude",
        "Description": "Anthropic Claude yapay zeka modeli i\u00e7in resmi masa\u00fcst\u00fc uygulamas\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=claude.ai&sz=128"
      },
      {
        "Name": "Claude Code",
        "Id": "Anthropic.ClaudeCode",
        "Description": "Terminal tabanl\u0131 otonom yapay zeka kodlama ve geli\u015ftirici arac\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=code.claude.com&sz=128"
      },
      {
        "Name": "CMake",
        "Id": "Kitware.CMake",
        "Description": "Platformlar aras\u0131 derleme ve proje yap\u0131land\u0131rma otomasyon sistemi.",
        "Icon": "https://www.google.com/s2/favicons?domain=cmake.org&sz=128"
      },
      {
        "Name": "Codex",
        "Id": "OpenAI.Codex",
        "Description": "OpenAI terminal tabanl\u0131 kodlama ajan\u0131 ve CLI arac\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=developers.openai.com&sz=128"
      },
      {
        "Name": "Cursor",
        "Id": "Anysphere.Cursor",
        "Description": "Yapay zeka destekli yeni nesil kod edit\u00f6r\u00fc (VS Code tabanl\u0131).",
        "Icon": "https://www.google.com/s2/favicons?domain=cursor.com&sz=128"
      },
      {
        "Name": "Fast Node Manager",
        "Id": "Schniz.fnm",
        "Description": "Rust ile yaz\u0131lm\u0131\u015f ultra h\u0131zl\u0131 ve hafif Node.js s\u00fcr\u00fcm y\u00f6neticisi (Fast Node Manager).",
        "Icon": "https://www.google.com/s2/favicons?domain=github.com&sz=128"
      },
      {
        "Name": "Git Extensions",
        "Id": "GitExtensionsTeam.GitExtensions",
        "Description": "Git depolar\u0131n\u0131 y\u00f6netmek i\u00e7in g\u00f6rsel kullan\u0131c\u0131 aray\u00fcz\u00fc ve Visual Studio eklentisi.",
        "Icon": "https://www.google.com/s2/favicons?domain=gitextensions.github.io&sz=128"
      },
      {
        "Name": "GitHub CLI",
        "Id": "GitHub.cli",
        "Description": "GitHub i\u015flemlerini (Pull Request, Issue, Repo) do\u011frudan terminalden y\u00f6neten resmi CLI arac\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=cli.github.com&sz=128"
      },
      {
        "Name": "Go",
        "Id": "GoLang.Go",
        "Description": "Google taraf\u0131ndan geli\u015ftirilen h\u0131zl\u0131, derlenen ve e\u015fzamanl\u0131 (concurrent) Go programlama dili.",
        "Icon": "https://www.google.com/s2/favicons?domain=go.dev&sz=128"
      },
      {
        "Name": "Hugo",
        "Id": "Hugo.Hugo.Extended",
        "Description": "Go tabanl\u0131 d\u00fcnyan\u0131n en h\u0131zl\u0131 statik web sitesi olu\u015fturma motoru.",
        "Icon": "https://www.google.com/s2/favicons?domain=gohugo.io&sz=128"
      },
      {
        "Name": "Amazon Corretto 8 (LTS)",
        "Id": "Amazon.Corretto.8.JDK",
        "Description": "Amazon taraf\u0131ndan uzun s\u00fcreli desteklenen \u00fccretsiz Java 8 (OpenJDK) geli\u015ftirme kiti.",
        "Icon": "https://www.google.com/s2/favicons?domain=aws.amazon.com&sz=128"
      },
      {
        "Name": "Amazon Corretto 21 (LTS)",
        "Id": "Amazon.Corretto.21.JDK",
        "Description": "Amazon taraf\u0131ndan desteklenen \u00fcretim ortam\u0131 haz\u0131r Java 21 (LTS) geli\u015ftirme kiti.",
        "Icon": "https://www.google.com/s2/favicons?domain=aws.amazon.com&sz=128"
      },
      {
        "Name": "Amazon Corretto 25 (LTS)",
        "Id": "Amazon.Corretto.25.JDK",
        "Description": "Amazon Corretto Java 25 geli\u015ftirme kiti ve \u00e7al\u0131\u015fma zaman\u0131 ortam\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=aws.amazon.com&sz=128"
      },
      {
        "Name": "Jetbrains Toolbox",
        "Id": "JetBrains.Toolbox",
        "Description": "IntelliJ IDEA, PyCharm, WebStorm gibi t\u00fcm JetBrains IDE'lerini tek merkezden kurma ve g\u00fcncelleme arac\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=jetbrains.com&sz=128"
      },
      {
        "Name": "Lazygit",
        "Id": "JesseDuffield.lazygit",
        "Description": "Git komutlar\u0131n\u0131 terminal i\u00e7inde g\u00f6rsel panellerle y\u00f6netmeyi sa\u011flayan pratik TUI arac\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=github.com&sz=128"
      },
      {
        "Name": "Neovim",
        "Id": "Neovim.Neovim",
        "Description": "H\u0131z ve geni\u015fletilebilirlik odakl\u0131, modernle\u015ftirilmi\u015f Vim tabanl\u0131 metin ve kod d\u00fczenleyici.",
        "Icon": "https://www.google.com/s2/favicons?domain=neovim.io&sz=128"
      },
      {
        "Name": "NodeJS",
        "Id": "OpenJS.NodeJS",
        "Description": "En g\u00fcncel \u00f6zellikleri i\u00e7eren Node.js JavaScript \u00e7al\u0131\u015fma zaman\u0131 ortam\u0131 (Current).",
        "Icon": "https://www.google.com/s2/favicons?domain=nodejs.org&sz=128"
      },
      {
        "Name": "pnpm",
        "Id": "pnpm.pnpm",
        "Description": "Disk alan\u0131ndan tasarruf sa\u011flayan, ultra h\u0131zl\u0131 ve modern JavaScript paket y\u00f6neticisi.",
        "Icon": "https://www.google.com/s2/favicons?domain=pnpm.io&sz=128"
      },
      {
        "Name": "OpenCode",
        "Id": "SST.opencode",
        "Description": "Terminal i\u00e7in a\u00e7\u0131k kaynakl\u0131 yapay zeka destekli yaz\u0131l\u0131m geli\u015ftirme asistan\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=opencode.ai&sz=128"
      },
      {
        "Name": "Oh My Posh (Prompt)",
        "Id": "JanDeDobbeleer.OhMyPosh",
        "Description": "PowerShell ve di\u011fer terminaller i\u00e7in \u015f\u0131k, renkli ve Git durum destekli tema motoru.",
        "Icon": "https://www.google.com/s2/favicons?domain=ohmyposh.dev&sz=128"
      },
      {
        "Name": "Python3",
        "Id": "Python.Python.3.14",
        "Description": "Python programlama dilinin en g\u00fcncel s\u00fcr\u00fcm\u00fc.",
        "Icon": "https://www.google.com/s2/favicons?domain=python.org&sz=128"
      },
      {
        "Name": "Rust",
        "Id": "Rustlang.Rust.MSVC",
        "Description": "Bellek g\u00fcvenli\u011fi ve y\u00fcksek performans odakl\u0131 modern sistem programlama dili (Rust).",
        "Icon": "https://www.google.com/s2/favicons?domain=rust-lang.org&sz=128"
      },
      {
        "Name": "Starship (Shell Prompt)",
        "Id": "Starship.Starship",
        "Description": "Her kabuk (PowerShell, Bash, Zsh) i\u00e7in Rust ile yaz\u0131lm\u0131\u015f ultra h\u0131zl\u0131 ve \u015f\u0131k komut istemi.",
        "Icon": "https://www.google.com/s2/favicons?domain=starship.rs&sz=128"
      },
      {
        "Name": "Sublime Text",
        "Id": "SublimeHQ.SublimeText.4",
        "Description": "\u00c7ok y\u00fcksek h\u0131zda a\u00e7\u0131lan ve b\u00fcy\u00fck dosyalar\u0131 zorlanmadan i\u015fleyen geli\u015fmi\u015f kod edit\u00f6r\u00fc.",
        "Icon": "https://www.google.com/s2/favicons?domain=sublimetext.com&sz=128"
      },
      {
        "Name": "Unity Game Engine",
        "Id": "Unity.UnityHub",
        "Description": "Unity oyun motoru s\u00fcr\u00fcmlerini ve oyun projelerini y\u00f6netmek i\u00e7in resmi merkez.",
        "Icon": "https://www.google.com/s2/favicons?domain=unity.com&sz=128"
      },
      {
        "Name": "Vagrant",
        "Id": "Hashicorp.Vagrant",
        "Description": "Ta\u015f\u0131nabilir ve tekrarlanabilir sanal geli\u015ftirme ortamlar\u0131 olu\u015fturma arac\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=developer.hashicorp.com&sz=128"
      },
      {
        "Name": "Visual Studio 2022",
        "Id": "Microsoft.VisualStudio.2022.Community",
        "Description": "C#, C++ ve .NET geli\u015ftiricileri i\u00e7in tam kapsaml\u0131 profesyonel t\u00fcmle\u015fik geli\u015ftirme ortam\u0131 (IDE).",
        "Icon": "https://www.google.com/s2/favicons?domain=visualstudio.microsoft.com&sz=128"
      },
      {
        "Name": "Visual Studio 2026",
        "Id": "Microsoft.VisualStudio.Community",
        "Description": "En yeni nesil Visual Studio Community t\u00fcmle\u015fik geli\u015ftirme ortam\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=visualstudio.microsoft.com&sz=128"
      },
      {
        "Name": "VS Codium",
        "Id": "VSCodium.VSCodium",
        "Description": "Visual Studio Code'un Microsoft telemetri ve izleyicilerinden tamamen ar\u0131nd\u0131r\u0131lm\u0131\u015f a\u00e7\u0131k kaynakl\u0131 derlemesi.",
        "Icon": "https://www.google.com/s2/favicons?domain=vscodium.com&sz=128"
      },
      {
        "Name": "Yarn",
        "Id": "Yarn.Yarn",
        "Description": "JavaScript ve Node.js projeleri i\u00e7in h\u0131zl\u0131 ve g\u00fcvenilir paket ve ba\u011f\u0131ml\u0131l\u0131k y\u00f6neticisi.",
        "Icon": "https://www.google.com/s2/favicons?domain=yarnpkg.com&sz=128"
      },
      {
        "Name": "uv",
        "Id": "astral-sh.uv",
        "Description": "Rust ile yaz\u0131lm\u0131\u015f, pip ve virtualenv'in yerini alan ultra h\u0131zl\u0131 Python paket ve s\u00fcr\u00fcm y\u00f6neticisi.",
        "Icon": "https://www.google.com/s2/favicons?domain=docs.astral.sh&sz=128"
      },
      {
        "Name": "Zed",
        "Id": "ZedIndustries.Zed",
        "Description": "Rust ile s\u0131f\u0131rdan yaz\u0131lm\u0131\u015f, \u00e7ok oyunculu i\u015f birli\u011fi ve yapay zeka destekli ultra h\u0131zl\u0131 kod edit\u00f6r\u00fc.",
        "Icon": "https://www.google.com/s2/favicons?domain=zed.dev&sz=128"
      },
      {
        "Name": "Ruby",
        "Id": "RubyInstallerTeam.Ruby.4.0",
        "Description": "Windows i\u00e7in Ruby programlama dili ve MSYS2 geli\u015ftirme ortam\u0131 kurulum paketi.",
        "Icon": "https://www.google.com/s2/favicons?domain=rubyinstaller.org&sz=128"
      },
      {
        "Name": "Lua",
        "Id": "rjpcomputing.luaforwindows",
        "Description": "Lua betik dili ve pop\u00fcler k\u00fct\u00fcphanelerini i\u00e7eren tam kapsaml\u0131 Windows \u00e7al\u0131\u015fma ortam\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=github.com&sz=128"
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
      },
      {
        "Name": "Battle.net",
        "Id": "Blizzard.BattleNet",
        "Description": "Blizzard ve Call of Duty oyunlar\u0131 i\u00e7in resmi ba\u015flat\u0131c\u0131 ve ma\u011faza.",
        "Icon": "https://www.google.com/s2/favicons?domain=battle.net&sz=128"
      },
      {
        "Name": "Cemu",
        "Id": "Cemu.Cemu",
        "Description": "Y\u00fcksek performansl\u0131 Wii U oyun konsolu em\u00fclat\u00f6r\u00fc.",
        "Icon": "https://www.google.com/s2/favicons?domain=cemu.info&sz=128"
      },
      {
        "Name": "EmulationStation Desktop Edition",
        "Id": "ES-DE.EmulationStation-DE",
        "Description": "Retro oyunlar ve em\u00fclat\u00f6rler i\u00e7in g\u00f6rsel k\u00fct\u00fcphane ve \u00f6n y\u00fcz (Frontend) aray\u00fcz\u00fc.",
        "Icon": "https://www.google.com/s2/favicons?domain=es-de.org&sz=128"
      },
      {
        "Name": "GeForce NOW",
        "Id": "Nvidia.GeForceNow",
        "Description": "Oyunlar\u0131 bulut sunucular \u00fczerinden donan\u0131m gerektirmeden oynatan NVIDIA yay\u0131n hizmeti.",
        "Icon": "https://www.google.com/s2/favicons?domain=nvidia.com&sz=128"
      },
      {
        "Name": "Heroic Games Launcher",
        "Id": "HeroicGamesLauncher.HeroicGamesLauncher",
        "Description": "Epic Games, GOG ve Amazon Prime oyunlar\u0131 i\u00e7in a\u00e7\u0131k kaynakl\u0131 h\u0131zl\u0131 ba\u015flat\u0131c\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=heroicgameslauncher.com&sz=128"
      },
      {
        "Name": "Itch.io",
        "Id": "ItchIo.Itch",
        "Description": "Ba\u011f\u0131ms\u0131z (Indie) oyunlar\u0131 indirmek ve otomatik g\u00fcncellemek i\u00e7in resmi masa\u00fcst\u00fc uygulamas\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=itch.io&sz=128"
      },
      {
        "Name": "Modrinth App",
        "Id": "Modrinth.ModrinthApp",
        "Description": "Minecraft modlar\u0131n\u0131, mod paketlerini ve \u0448\u0435\u0439der'lar\u0131 kolayca y\u00f6neten resmi Modrinth ba\u015flat\u0131c\u0131s\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=modrinth.com&sz=128"
      },
      {
        "Name": "Playnite",
        "Id": "Playnite.Playnite",
        "Description": "Steam, Epic, GOG, EA ve em\u00fclat\u00f6r oyunlar\u0131n\u0131 tek bir \u015f\u0131k k\u00fct\u00fcphanede birle\u015ftiren a\u00e7\u0131k kaynakl\u0131 y\u00f6netici.",
        "Icon": "https://www.google.com/s2/favicons?domain=playnite.link&sz=128"
      },
      {
        "Name": "Roblox",
        "Id": "Roblox.Roblox",
        "Description": "Milyonlarca kullan\u0131c\u0131 yap\u0131m\u0131 oyunu bar\u0131nd\u0131ran \u00e7evrimi\u00e7i oyun platformu.",
        "Icon": "https://www.google.com/s2/favicons?domain=roblox.com&sz=128"
      },
      {
        "Name": "Virtual Desktop Streamer",
        "Id": "VirtualDesktop.Streamer",
        "Description": "VR g\u00f6zl\u00fcklerden bilgisayar masa\u00fcst\u00fcne ve PCVR oyunlar\u0131na kablosuz ba\u011flanma arac\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=vrdesktop.net&sz=128"
      },
      {
        "Name": "CurseForge",
        "Id": "Overwolf.CurseForge",
        "Description": "Minecraft, WoW, Sims 4 ve di\u011fer oyunlar i\u00e7in pop\u00fcler mod ve eklenti y\u00f6neticisi.",
        "Icon": "https://www.google.com/s2/favicons?domain=overwolf.com&sz=128"
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
      },
      {
        "Name": "Chatterino",
        "Id": "ChatterinoTeam.Chatterino",
        "Description": "Twitch yay\u0131nc\u0131lar\u0131 ve izleyicileri i\u00e7in geli\u015fmi\u015f masa\u00fcst\u00fc sohbet istemcisi.",
        "Icon": "https://www.google.com/s2/favicons?domain=chatterino.com&sz=128"
      },
      {
        "Name": "Dorion",
        "Id": "SpikeHD.Dorion",
        "Description": "D\u00fc\u015f\u00fck sistem kayna\u011f\u0131 t\u00fcketen, tema ve eklenti destekli alternatif Discord istemcisi.",
        "Icon": "https://www.google.com/s2/favicons?domain=spikehd.dev&sz=128"
      },
      {
        "Name": "Element",
        "Id": "Element.Element",
        "Description": "Matrix protokol\u00fc tabanl\u0131, u\u00e7tan uca \u015fifreli ve merkeziyetsiz g\u00fcvenli ileti\u015fim istemcisi.",
        "Icon": "https://www.google.com/s2/favicons?domain=element.io&sz=128"
      },
      {
        "Name": "Proton Mail",
        "Id": "Proton.ProtonMail",
        "Description": "U\u00e7tan uca \u015fifreli Proton Mail ve Takvim i\u00e7in resmi masa\u00fcst\u00fc uygulamas\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=proton.me&sz=128"
      },
      {
        "Name": "QTox",
        "Id": "Tox.qTox",
        "Description": "Sunucusuz (P2P) ve u\u00e7tan uca \u015fifreli g\u00fcvenli mesajla\u015fma ve g\u00f6r\u00fc\u015fme uygulamas\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=qtox.github.io&sz=128"
      },
      {
        "Name": "Signal",
        "Id": "OpenWhisperSystems.Signal",
        "Description": "Ba\u011f\u0131ms\u0131z ve u\u00e7tan uca \u015fifreli g\u00fcvenli mesajla\u015fma ve arama uygulamas\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=signal.org&sz=128"
      },
      {
        "Name": "Slack",
        "Id": "SlackTechnologies.Slack",
        "Description": "Ekipler ve i\u015f yerleri i\u00e7in kanal tabanl\u0131 kurumsal ileti\u015fim ve i\u015f birli\u011fi platformu.",
        "Icon": "https://www.google.com/s2/favicons?domain=slack.com&sz=128"
      },
      {
        "Name": "Teams",
        "Id": "Microsoft.Teams",
        "Description": "G\u00f6r\u00fcnt\u00fcl\u00fc toplant\u0131, ekip sohbeti ve kurumsal i\u015f birli\u011fi uygulamas\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=microsoft.com&sz=128"
      },
      {
        "Name": "TeamSpeak 3",
        "Id": "TeamSpeakSystems.TeamSpeakClient",
        "Description": "D\u00fc\u015f\u00fck gecikmeli ve y\u00fcksek ses kaliteli klasik oyuncu sesli ileti\u015fim istemcisi (TS3).",
        "Icon": "https://www.google.com/s2/favicons?domain=teamspeak.com&sz=128"
      },
      {
        "Name": "TeamSpeak 6",
        "Id": "TeamSpeakSystems.TeamSpeakClient.Beta.6",
        "Description": "Modern aray\u00fcz ve ekran payla\u015f\u0131m\u0131 \u00f6zellikleriyle yeni nesil TeamSpeak 6 istemcisi.",
        "Icon": "https://www.google.com/s2/favicons?domain=teamspeak.com&sz=128"
      },
      {
        "Name": "Thunderbird",
        "Id": "Mozilla.Thunderbird",
        "Description": "Mozilla taraf\u0131ndan geli\u015ftirilen a\u00e7\u0131k kaynakl\u0131, g\u00fcvenli \u00e7oklu e-posta ve takvim istemcisi.",
        "Icon": "https://www.google.com/s2/favicons?domain=thunderbird.net&sz=128"
      },
      {
        "Name": "Betterbird",
        "Id": "Betterbird.Betterbird",
        "Description": "Thunderbird'\u00fcn hata d\u00fczeltmeleri ve geli\u015fmi\u015f \u00f6zelliklerle g\u00fc\u00e7lendirilmi\u015f s\u00fcr\u00fcm\u00fc.",
        "Icon": "https://www.google.com/s2/favicons?domain=betterbird.eu&sz=128"
      },
      {
        "Name": "Vesktop",
        "Id": "Vencord.Vesktop",
        "Description": "Dahili Vencord eklentili, daha h\u0131zl\u0131 ve d\u00fc\u015f\u00fck kaynak t\u00fcketen \u00f6zel Discord istemcisi.",
        "Icon": "https://www.google.com/s2/favicons?domain=vesktop.dev&sz=128"
      },
      {
        "Name": "Viber",
        "Id": "Rakuten.Viber",
        "Description": "Sesli ve g\u00f6r\u00fcnt\u00fcl\u00fc g\u00f6r\u00fc\u015fme destekli masa\u00fcst\u00fc mesajla\u015fma uygulamas\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=viber.com&sz=128"
      },
      {
        "Name": "Zoom",
        "Id": "Zoom.Zoom",
        "Description": "\u00c7evrimi\u00e7i g\u00f6r\u00fcnt\u00fcl\u00fc toplant\u0131, ders ve web semineri platformu.",
        "Icon": "https://www.google.com/s2/favicons?domain=zoom.us&sz=128"
      }
    ]
  },
  {
    "Category": "Medya ve Multimedya",
    "Apps": [
      {
        "Name": "AIMP (Music Player)",
        "Id": "AIMP.AIMP",
        "Description": "D\u00fc\u015f\u00fck kaynak t\u00fcketen, geli\u015fmi\u015f ses kalitesine sahip m\u00fczik \u00e7alar.",
        "Icon": "https://www.google.com/s2/favicons?domain=aimp.ru&sz=128"
      },
      {
        "Name": "Audacity",
        "Id": "Audacity.Audacity",
        "Description": "A\u00e7\u0131k kaynakl\u0131 \u00e7ok kanall\u0131 ses kaydetme ve d\u00fczenleme yaz\u0131l\u0131m\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=audacityteam.org&sz=128"
      },
      {
        "Name": "Blender (3D Graphics)",
        "Id": "BlenderFoundation.Blender",
        "Description": "A\u00e7\u0131k kaynakl\u0131 profesyonel 3B modelleme, animasyon ve render st\u00fcdyosu.",
        "Icon": "https://www.google.com/s2/favicons?domain=blender.org&sz=128"
      },
      {
        "Name": "Calibre",
        "Id": "calibre.calibre",
        "Description": "Kapsaml\u0131 e-kitap k\u00fct\u00fcphane y\u00f6netimi, okuma ve format d\u00f6n\u00fc\u015ft\u00fcrme arac\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=calibre-ebook.com&sz=128"
      },
      {
        "Name": "EarTrumpet (Audio)",
        "Id": "File-New-Project.EarTrumpet",
        "Description": "Uygulamalar\u0131n ses seviyelerini ve \u00e7\u0131k\u0131\u015f cihazlar\u0131n\u0131 ayr\u0131 ayr\u0131 y\u00f6neten geli\u015fmi\u015f ses kar\u0131\u015ft\u0131r\u0131c\u0131s\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=eartrumpet.app&sz=128"
      },
      {
        "Name": "File Converter",
        "Id": "AdrienAllard.FileConverter",
        "Description": "Sa\u011f t\u0131k men\u00fcs\u00fcnden ses, video, g\u00f6rsel ve belge formatlar\u0131n\u0131 an\u0131nda d\u00f6n\u00fc\u015ft\u00fcren ara\u00e7.",
        "Icon": "https://www.google.com/s2/favicons?domain=file-converter.io&sz=128"
      },
      {
        "Name": "foobar2000 (Music Player)",
        "Id": "PeterPawlowski.foobar2000",
        "Description": "Mod\u00fcler tasar\u0131ml\u0131, y\u00fcksek ses kalitesi ve geni\u015f format destekli geli\u015fmi\u015f m\u00fczik \u00e7alar.",
        "Icon": "https://www.google.com/s2/favicons?domain=foobar2000.org&sz=128"
      },
      {
        "Name": "GIMP (Image Editor)",
        "Id": "GIMP.GIMP.3",
        "Description": "A\u00e7\u0131k kaynakl\u0131, katman ve eklenti destekli profesyonel foto\u011fraf ve g\u00f6rsel d\u00fczenleme yaz\u0131l\u0131m\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=gimp.org&sz=128"
      },
      {
        "Name": "ImageGlass (Image Viewer)",
        "Id": "DuongDieuPhap.ImageGlass",
        "Description": "T\u00fcm g\u00f6rsel formatlar\u0131n\u0131 (WEBP, SVG, HEIC, RAW) destekleyen hafif ve modern foto\u011fraf g\u00f6r\u00fcnt\u00fcleyici.",
        "Icon": "https://www.google.com/s2/favicons?domain=imageglass.org&sz=128"
      },
      {
        "Name": "IrfanView",
        "Id": "IrfanSkiljan.IrfanView",
        "Description": "\u00c7ok h\u0131zl\u0131 a\u00e7\u0131lan, toplu d\u00f6n\u00fc\u015ft\u00fcrme destekli klasik resim ve medya g\u00f6r\u00fcnt\u00fcleyici.",
        "Icon": "https://www.google.com/s2/favicons?domain=irfanview.com&sz=128"
      },
      {
        "Name": "iTunes",
        "Id": "Apple.iTunes",
        "Description": "Apple cihazlar\u0131n\u0131 yedekleme, senkronize etme ve medya y\u00f6netimi i\u00e7in resmi uygulama.",
        "Icon": "https://www.google.com/s2/favicons?domain=apple.com&sz=128"
      },
      {
        "Name": "K-Lite Codec Standard",
        "Id": "CodecGuide.K-LiteCodecPack.Standard",
        "Description": "T\u00fcm ses ve video formatlar\u0131n\u0131n sorunsuz oynat\u0131lmas\u0131 i\u00e7in kapsaml\u0131 medya kodek paketi.",
        "Icon": "https://www.google.com/s2/favicons?domain=codecguide.com&sz=128"
      },
      {
        "Name": "mpc-qt",
        "Id": "mpc-qt.mpc-qt",
        "Description": "Media Player Classic aray\u00fcz\u00fcn\u00fc modern Qt ve mpv motoruyla sunan medya oynat\u0131c\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=mpc-qt.github.io&sz=128"
      },
      {
        "Name": "mpv",
        "Id": "shinchiro.mpv",
        "Description": "Komut sat\u0131r\u0131 ve y\u00fcksek kaliteli GPU video i\u015fleme odakl\u0131 minimalist medya oynat\u0131c\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=mpv.io&sz=128"
      },
      {
        "Name": "Media Player Classic - Home Cinema",
        "Id": "clsid2.mpc-hc",
        "Description": "\u00c7ok hafif, \u00f6zelle\u015ftirilebilir ve t\u00fcm formatlar\u0131 destekleyen klasik Media Player Classic (MPC-HC).",
        "Icon": "https://www.google.com/s2/favicons?domain=mpc-hc.org&sz=128"
      },
      {
        "Name": "nomacs",
        "Id": "nomacs.nomacs",
        "Description": "RAW ve PSD dahil t\u00fcm formatlar\u0131 a\u00e7abilen a\u00e7\u0131k kaynakl\u0131 ve h\u0131zl\u0131 resim g\u00f6r\u00fcnt\u00fcleyici.",
        "Icon": "https://www.google.com/s2/favicons?domain=nomacs.org&sz=128"
      },
      {
        "Name": "Paint.NET",
        "Id": "dotPDN.PaintDotNet",
        "Description": "Katman, \u00f6zel efekt ve eklenti destekli pratik resim ve foto\u011fraf d\u00fczenleme program\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=getpaint.net&sz=128"
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
      },
      {
        "Name": "1Password",
        "Id": "AgileBits.1Password",
        "Description": "Kapsaml\u0131 ve g\u00fcvenli bulut tabanl\u0131 parola y\u00f6neticisi.",
        "Icon": "https://www.google.com/s2/favicons?domain=1password.com&sz=128"
      },
      {
        "Name": "AB Download Manager",
        "Id": "amir1376.ABDownloadManager",
        "Description": "Modern aray\u00fczl\u00fc, a\u00e7\u0131k kaynakl\u0131 h\u0131zl\u0131 indirme y\u00f6neticisi.",
        "Icon": "https://www.google.com/s2/favicons?domain=abdownloadmanager.com&sz=128"
      },
      {
        "Name": "Advanced IP Scanner",
        "Id": "Famatech.AdvancedIPScanner",
        "Description": "Yerel a\u011fdaki cihazlar\u0131 ve payla\u015f\u0131mlar\u0131 tespit eden h\u0131zl\u0131 a\u011f taray\u0131c\u0131s\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=advanced-ip-scanner.com&sz=128"
      },
      {
        "Name": "Angry IP Scanner",
        "Id": "angryziber.AngryIPScanner",
        "Description": "\u00c7oklu i\u015f par\u00e7ac\u0131kl\u0131, h\u0131zl\u0131 ve a\u00e7\u0131k kaynakl\u0131 IP ve port taray\u0131c\u0131s\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=angryip.org&sz=128"
      },
      {
        "Name": "Autoruns",
        "Id": "Microsoft.Sysinternals.Autoruns",
        "Description": "Windows ba\u015flang\u0131c\u0131nda \u00e7al\u0131\u015fan t\u00fcm program, servis ve zamanlanm\u0131\u015f g\u00f6revleri y\u00f6netir.",
        "Icon": "https://www.google.com/s2/favicons?domain=learn.microsoft.com&sz=128"
      },
      {
        "Name": "RDCMan",
        "Id": "Microsoft.Sysinternals.RDCMan",
        "Description": "Birden fazla Uzak Masa\u00fcst\u00fc (RDP) ba\u011flant\u0131s\u0131n\u0131 tek pencereden y\u00f6netme arac\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=learn.microsoft.com&sz=128"
      },
      {
        "Name": "AutoHotkey",
        "Id": "AutoHotkey.AutoHotkey",
        "Description": "Windows i\u00e7in klavye k\u0131sayollar\u0131, makro ve otomasyon betik dili.",
        "Icon": "https://www.google.com/s2/favicons?domain=autohotkey.com&sz=128"
      },
      {
        "Name": "Bitwarden",
        "Id": "Bitwarden.Bitwarden",
        "Description": "A\u00e7\u0131k kaynakl\u0131, u\u00e7tan uca \u015fifreli g\u00fcvenli parola y\u00f6neticisi.",
        "Icon": "https://www.google.com/s2/favicons?domain=bitwarden.com&sz=128"
      },
      {
        "Name": "Bulk Crap Uninstaller",
        "Id": "Klocman.BulkCrapUninstaller",
        "Description": "Toplu program kald\u0131rma ve derin kay\u0131t defteri kal\u0131nt\u0131 temizleme arac\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=bcuninstaller.com&sz=128"
      },
      {
        "Name": "BlurAutoClicker",
        "Id": "Blur009.BlurAutoClicker",
        "Description": "Modern aray\u00fczl\u00fc ve \u00f6zelle\u015ftirilebilir otomatik fare t\u0131klama arac\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=blur009.vercel.app&sz=128"
      },
      {
        "Name": "Cinebench R23",
        "Id": "Maxon.CinebenchR23",
        "Description": "\u0130\u015flemci (CPU) tekli ve \u00e7oklu \u00e7ekirdek performans\u0131n\u0131 \u00f6l\u00e7en end\u00fcstri standard\u0131 test arac\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=maxon.net&sz=128"
      },
      {
        "Name": "Crystal Disk Info",
        "Id": "CrystalDewWorld.CrystalDiskInfo",
        "Description": "SSD ve HDD disklerin sa\u011fl\u0131k durumunu, s\u0131cakl\u0131\u011f\u0131n\u0131 ve S.M.A.R.T. verilerini izler.",
        "Icon": "https://www.google.com/s2/favicons?domain=crystalmark.info&sz=128"
      },
      {
        "Name": "Crystal Disk Mark",
        "Id": "CrystalDewWorld.CrystalDiskMark",
        "Description": "SSD ve sabit disklerin s\u0131ral\u0131 ve rastgele okuma/yazma h\u0131zlar\u0131n\u0131 test eder.",
        "Icon": "https://www.google.com/s2/favicons?domain=crystalmark.info&sz=128"
      },
      {
        "Name": "Display Driver Uninstaller",
        "Id": "Wagnardsoft.DisplayDriverUninstaller",
        "Description": "NVIDIA, AMD ve Intel ekran kart\u0131 s\u00fcr\u00fcc\u00fclerini kal\u0131nt\u0131s\u0131z temizleyen DDU arac\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=wagnardsoft.com&sz=128"
      },
      {
        "Name": "DISMTools",
        "Id": "CodingWondersSoftware.DISMTools.Stable",
        "Description": "Windows imajlar\u0131n\u0131, \u00f6zelliklerini ve paketlerini g\u00f6rsel aray\u00fczle y\u00f6neten DISM arac\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=github.com&sz=128"
      },
      {
        "Name": "NTLite",
        "Id": "Nlitesoft.NTLite",
        "Description": "Windows kurulum ISO dosyalar\u0131n\u0131 \u00f6zelle\u015ftirme ve bile\u015fen sadele\u015ftirme arac\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=ntlite.com&sz=128"
      },
      {
        "Name": ".NET Desktop Runtime 6",
        "Id": "Microsoft.DotNet.DesktopRuntime.6",
        "Description": ".NET 6 tabanl\u0131 masa\u00fcst\u00fc uygulamalar\u0131n\u0131 \u00e7al\u0131\u015ft\u0131rmak i\u00e7in gerekli \u00e7al\u0131\u015fma zaman\u0131 paketi.",
        "Icon": "https://www.google.com/s2/favicons?domain=dotnet.microsoft.com&sz=128"
      },
      {
        "Name": ".NET Desktop Runtime 8",
        "Id": "Microsoft.DotNet.DesktopRuntime.8",
        "Description": ".NET 8 (LTS) masa\u00fcst\u00fc uygulamalar\u0131 i\u00e7in resmi Microsoft \u00e7al\u0131\u015fma zaman\u0131 bile\u015feni.",
        "Icon": "https://www.google.com/s2/favicons?domain=dotnet.microsoft.com&sz=128"
      },
      {
        "Name": ".NET Desktop Runtime 9",
        "Id": "Microsoft.DotNet.DesktopRuntime.9",
        "Description": ".NET 9 masa\u00fcst\u00fc uygulamalar\u0131 i\u00e7in resmi Microsoft \u00e7al\u0131\u015fma zaman\u0131 bile\u015feni.",
        "Icon": "https://www.google.com/s2/favicons?domain=dotnet.microsoft.com&sz=128"
      },
      {
        "Name": ".NET Desktop Runtime 10",
        "Id": "Microsoft.DotNet.DesktopRuntime.10",
        "Description": ".NET 10 masa\u00fcst\u00fc uygulamalar\u0131 i\u00e7in en g\u00fcncel Microsoft \u00e7al\u0131\u015fma zaman\u0131 bile\u015feni.",
        "Icon": "https://www.google.com/s2/favicons?domain=dotnet.microsoft.com&sz=128"
      },
      {
        "Name": "Ente Auth",
        "Id": "ente-io.auth-desktop",
        "Description": "A\u00e7\u0131k kaynakl\u0131, bulut yedeklemeli iki a\u015famal\u0131 do\u011frulama (2FA) kodu y\u00f6neticisi.",
        "Icon": "https://www.google.com/s2/favicons?domain=ente.io&sz=128"
      },
      {
        "Name": "Files",
        "Id": "FilesCommunity.Files",
        "Description": "Sekmeli, modern tasar\u0131ml\u0131 ve geli\u015fmi\u015f \u00f6zellikli alternatif Windows Dosya Gezgini.",
        "Icon": "https://www.google.com/s2/favicons?domain=files.community&sz=128"
      },
      {
        "Name": "F.lux",
        "Id": "flux.flux",
        "Description": "G\u00fcn\u00fcn saatine g\u00f6re ekran mavi \u0131\u015f\u0131\u011f\u0131n\u0131 ve renk s\u0131cakl\u0131\u011f\u0131n\u0131 otomatik ayarlayan g\u00f6z koruma arac\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=justgetflux.com&sz=128"
      },
      {
        "Name": "GPU-Z",
        "Id": "TechPowerUp.GPU-Z",
        "Description": "Ekran kart\u0131 (GPU) teknik \u00f6zelliklerini, sens\u00f6r s\u0131cakl\u0131klar\u0131n\u0131 ve saat h\u0131zlar\u0131n\u0131 g\u00f6steren ara\u00e7.",
        "Icon": "https://www.google.com/s2/favicons?domain=techpowerup.com&sz=128"
      },
      {
        "Name": "gsudo",
        "Id": "gerardog.gsudo",
        "Description": "Windows i\u00e7in Linux sudo benzeri, mevcut konsoldan \u00e7\u0131kmadan y\u00f6netici yetkisi y\u00fckseltme arac\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=github.com&sz=128"
      },
      {
        "Name": "HWiNFO",
        "Id": "REALiX.HWiNFO",
        "Description": "T\u00fcm bilgisayar donan\u0131mlar\u0131n\u0131, sens\u00f6rleri ve voltaj de\u011ferlerini en ince ayr\u0131nt\u0131s\u0131na kadar analiz eder.",
        "Icon": "https://www.google.com/s2/favicons?domain=hwinfo.com&sz=128"
      },
      {
        "Name": "ImHex",
        "Id": "WerWolv.ImHex",
        "Description": "Tersine m\u00fchendisler ve geli\u015ftiriciler i\u00e7in geli\u015fmi\u015f onalt\u0131l\u0131k (Hex) dosya d\u00fczenleyici.",
        "Icon": "https://www.google.com/s2/favicons?domain=imhex.werwolv.net&sz=128"
      },
      {
        "Name": "Internet Download Manager",
        "Id": "Tonec.InternetDownloadManager",
        "Description": "Dosya indirme h\u0131zlar\u0131n\u0131 \u00e7oklu ba\u011flant\u0131 ile art\u0131ran geli\u015fmi\u015f indirme y\u00f6neticisi (IDM).",
        "Icon": "https://www.google.com/s2/favicons?domain=internetdownloadmanager.com&sz=128"
      },
      {
        "Name": "Jellyfin Media Player",
        "Id": "Jellyfin.JellyfinMediaPlayer",
        "Description": "Jellyfin medya sunucular\u0131 i\u00e7in donan\u0131m h\u0131zland\u0131rmal\u0131 masa\u00fcst\u00fc oynat\u0131c\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=jellyfin.org&sz=128"
      },
      {
        "Name": "Jellyfin Server",
        "Id": "Jellyfin.Server",
        "Description": "Kendi film, dizi ve m\u00fczik ar\u015fivinizi yay\u0131nlamak i\u00e7in a\u00e7\u0131k kaynakl\u0131 medya sunucusu.",
        "Icon": "https://www.google.com/s2/favicons?domain=jellyfin.org&sz=128"
      },
      {
        "Name": "JPEG View",
        "Id": "sylikc.JPEGView",
        "Description": "Minimalist, ultra h\u0131zl\u0131 ve anl\u0131k g\u00f6r\u00fcnt\u00fc i\u015fleme destekli foto\u011fraf g\u00f6r\u00fcnt\u00fcleyici.",
        "Icon": "https://www.google.com/s2/favicons?domain=github.com&sz=128"
      },
      {
        "Name": "KeePassXC",
        "Id": "KeePassXCTeam.KeePassXC",
        "Description": "Parolalar\u0131 yerel veritaban\u0131nda y\u00fcksek \u015fifreleme ile saklayan a\u00e7\u0131k kaynakl\u0131 parola y\u00f6neticisi.",
        "Icon": "https://www.google.com/s2/favicons?domain=keepassxc.org&sz=128"
      },
      {
        "Name": "Kodi Media Center",
        "Id": "XBMCFoundation.Kodi",
        "Description": "Ev sinemas\u0131 ve medya ar\u015fivleri i\u00e7in a\u00e7\u0131k kaynakl\u0131 e\u011flence merkezi yaz\u0131l\u0131m\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=kodi.tv&sz=128"
      },
      {
        "Name": "LocalSend",
        "Id": "LocalSend.LocalSend",
        "Description": "\u0130nternet gerektirmeden yerel a\u011fdaki (Wi-Fi) telefon ve bilgisayarlar aras\u0131nda h\u0131zl\u0131 dosya payla\u015f\u0131m\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=localsend.org&sz=128"
      },
      {
        "Name": "MiniTool Partition Wizard",
        "Id": "MiniTool.PartitionWizard.Free",
        "Description": "Disk b\u00f6l\u00fcm\u00fc boyutland\u0131rma, formatlama ve disk klonlama i\u015flemleri i\u00e7in y\u00f6netim arac\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=partitionwizard.com&sz=128"
      },
      {
        "Name": "Moonlight/GameStream Client",
        "Id": "MoonlightGameStreamingProject.Moonlight",
        "Description": "Bilgisayar\u0131n\u0131zdaki oyunlar\u0131 d\u00fc\u015f\u00fck gecikmeyle ba\u015fka cihazlara aktaran a\u00e7\u0131k kaynakl\u0131 istemci.",
        "Icon": "https://www.google.com/s2/favicons?domain=moonlight-stream.org&sz=128"
      },
      {
        "Name": "MSEdgeRedirect",
        "Id": "rcmaehl.MSEdgeRedirect",
        "Description": "Windows widget ve arama ba\u011flant\u0131lar\u0131n\u0131 zorunlu Edge yerine varsay\u0131lan taray\u0131c\u0131n\u0131za y\u00f6nlendirir.",
        "Icon": "https://www.google.com/s2/favicons?domain=github.com&sz=128"
      },
      {
        "Name": "Mullvad VPN",
        "Id": "MullvadVPN.MullvadVPN",
        "Description": "Kay\u0131t tutmayan ve hesap bilgisi istemeyen \u00fcst d\u00fczey gizlilik odakl\u0131 VPN istemcisi.",
        "Icon": "https://www.google.com/s2/favicons?domain=mullvad.net&sz=128"
      },
      {
        "Name": "NanaZip",
        "Id": "M2Team.NanaZip",
        "Description": "Windows 11 modern sa\u011f t\u0131k men\u00fcs\u00fcyle tam uyumlu, 7-Zip tabanl\u0131 a\u00e7\u0131k kaynakl\u0131 ar\u015fiv y\u00f6neticisi.",
        "Icon": "https://www.google.com/s2/favicons?domain=nanazip.org&sz=128"
      },
      {
        "Name": "NetBird",
        "Id": "Netbird.Netbird",
        "Description": "WireGuard tabanl\u0131, s\u0131f\u0131r yap\u0131land\u0131rmal\u0131 g\u00fcvenli \u00f6zel a\u011f (Mesh VPN) platformu.",
        "Icon": "https://www.google.com/s2/favicons?domain=netbird.io&sz=128"
      },
      {
        "Name": "Tailscale",
        "Id": "Tailscale.Tailscale",
        "Description": "Cihazlar\u0131n\u0131z aras\u0131nda g\u00fcvenli WireGuard tabanl\u0131 \u00f6zel yerel a\u011f kuran kolay VPN arac\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=tailscale.com&sz=128"
      },
      {
        "Name": "Nmap",
        "Id": "Insecure.Nmap",
        "Description": "A\u011f ke\u015ffi, port taramas\u0131 ve g\u00fcvenlik denetimi i\u00e7in end\u00fcstri standard\u0131 analiz arac\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=nmap.org&sz=128"
      },
      {
        "Name": "NuGet",
        "Id": "Microsoft.NuGet",
        "Description": ".NET geli\u015ftiricileri i\u00e7in resmi paket y\u00f6neticisi komut sat\u0131r\u0131 arac\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=nuget.org&sz=128"
      },
      {
        "Name": "NVCleanstall",
        "Id": "TechPowerUp.NVCleanstall",
        "Description": "NVIDIA ekran kart\u0131 s\u00fcr\u00fcc\u00fclerini telemetri ve gereksiz bile\u015fenler olmadan temiz kurma arac\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=techpowerup.com&sz=128"
      },
      {
        "Name": "OPAutoClicker",
        "Id": "OPAutoClicker.OPAutoClicker",
        "Description": "Oyunlar ve tekrarlayan i\u015flemler i\u00e7in hafif ve g\u00fcvenilir otomatik fare t\u0131klama arac\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=opautoclicker.com&sz=128"
      },
      {
        "Name": "OpenRGB",
        "Id": "OpenRGB.OpenRGB",
        "Description": "Farkl\u0131 markalara ait t\u00fcm RGB ayd\u0131nlatmal\u0131 donan\u0131mlar\u0131 tek programdan y\u00f6neten a\u00e7\u0131k kaynakl\u0131 ara\u00e7.",
        "Icon": "https://www.google.com/s2/favicons?domain=openrgb.org&sz=128"
      },
      {
        "Name": "OpenVPN Connect",
        "Id": "OpenVPNTechnologies.OpenVPNConnect",
        "Description": "OpenVPN sunucular\u0131na g\u00fcvenli ba\u011flant\u0131 sa\u011flayan resmi VPN istemcisi.",
        "Icon": "https://www.google.com/s2/favicons?domain=openvpn.net&sz=128"
      },
      {
        "Name": "Oracle VirtualBox",
        "Id": "Oracle.VirtualBox",
        "Description": "Bilgisayar\u0131n\u0131zda farkl\u0131 i\u015fletim sistemlerini sanal makine olarak \u00e7al\u0131\u015ft\u0131ran \u00fccretsiz sanalla\u015ft\u0131rma arac\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=virtualbox.org&sz=128"
      },
      {
        "Name": "Policy Plus",
        "Id": "Fleex255.PolicyPlus",
        "Description": "Windows Home s\u00fcr\u00fcmleri dahil t\u00fcm sistemlerde Yerel Grup \u0130lkesi (gpedit) ayarlar\u0131n\u0131 y\u00f6netme arac\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=github.com&sz=128"
      },
      {
        "Name": "Process Explorer",
        "Id": "Microsoft.Sysinternals.ProcessExplorer",
        "Description": "G\u00f6rev Y\u00f6neticisi'nin \u00e7ok daha detayl\u0131 s\u00fcr\u00fcm\u00fc; hangi dosyan\u0131n veya DLL'in hangi s\u00fcre\u00e7te a\u00e7\u0131k oldu\u011funu g\u00f6sterir.",
        "Icon": "https://www.google.com/s2/favicons?domain=learn.microsoft.com&sz=128"
      },
      {
        "Name": "Parsec",
        "Id": "Parsec.Parsec",
        "Description": "Ultra d\u00fc\u015f\u00fck gecikmeli (60 FPS+) uzak masa\u00fcst\u00fc ve birlikte oyun oynama ba\u011flant\u0131s\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=parsec.app&sz=128"
      },
      {
        "Name": "PeaZip",
        "Id": "Giorgiotani.Peazip",
        "Description": "200'den fazla ar\u015fiv format\u0131n\u0131 destekleyen a\u00e7\u0131k kaynakl\u0131 dosya s\u0131k\u0131\u015ft\u0131rma ve \u015fifreleme arac\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=peazip.github.io&sz=128"
      },
      {
        "Name": "Plex Media Server",
        "Id": "Plex.PlexMediaServer",
        "Description": "Kendi medya ar\u015fivinizi t\u00fcm cihazlar\u0131n\u0131za yay\u0131nlayan medya sunucusu.",
        "Icon": "https://www.google.com/s2/favicons?domain=plex.tv&sz=128"
      },
      {
        "Name": "Plex Desktop",
        "Id": "Plex.Plex",
        "Description": "Plex medya sunucular\u0131 ve dijital i\u00e7erikler i\u00e7in resmi masa\u00fcst\u00fc oynat\u0131c\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=plex.tv&sz=128"
      },
      {
        "Name": "Process Lasso",
        "Id": "BitSum.ProcessLasso",
        "Description": "Oyunlar ve a\u011f\u0131r programlar i\u00e7in ger\u00e7ek zamanl\u0131 CPU \u00f6nceliklendirme (ProBalance) ve \u00e7ekirdek atama arac\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=bitsum.com&sz=128"
      },
      {
        "Name": "Proton Authenticator",
        "Id": "Proton.ProtonAuthenticator",
        "Description": "Proton ekosistemi ile uyumlu g\u00fcvenli iki a\u015famal\u0131 do\u011frulama (2FA) uygulamas\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=proton.me&sz=128"
      },
      {
        "Name": "Proton Pass",
        "Id": "Proton.ProtonPass",
        "Description": "Proton taraf\u0131ndan geli\u015ftirilen a\u00e7\u0131k kaynakl\u0131 ve \u015fifreli parola/kimlik y\u00f6neticisi.",
        "Icon": "https://www.google.com/s2/favicons?domain=proton.me&sz=128"
      },
      {
        "Name": "Proton VPN",
        "Id": "Proton.ProtonVPN",
        "Description": "A\u00e7\u0131k kaynakl\u0131, s\u0131n\u0131rs\u0131z \u00fccretsiz plan\u0131 bulunan y\u00fcksek g\u00fcvenlikli VPN istemcisi.",
        "Icon": "https://www.google.com/s2/favicons?domain=protonvpn.com&sz=128"
      },
      {
        "Name": "Process Monitor",
        "Id": "Microsoft.Sysinternals.ProcessMonitor",
        "Description": "Ger\u00e7ek zamanl\u0131 dosya sistemi, Kay\u0131t Defteri (Registry) ve s\u00fcre\u00e7 etkinliklerini izleme arac\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=docs.microsoft.com&sz=128"
      },
      {
        "Name": "PsTools",
        "Id": "Microsoft.Sysinternals.PsTools",
        "Description": "Uzaktan ve yerel sistem y\u00f6netimi i\u00e7in geli\u015fmi\u015f komut sat\u0131r\u0131 ara\u00e7 seti.",
        "Icon": "https://www.google.com/s2/favicons?domain=learn.microsoft.com&sz=128"
      },
      {
        "Name": "PuTTY",
        "Id": "PuTTY.PuTTY",
        "Description": "SSH ve Telnet ba\u011flant\u0131lar\u0131 i\u00e7in en yayg\u0131n kullan\u0131lan hafif terminal istemcisi.",
        "Icon": "https://www.google.com/s2/favicons?domain=chiark.greenend.org.uk&sz=128"
      },
      {
        "Name": "qBittorrent",
        "Id": "qBittorrent.qBittorrent",
        "Description": "Reklams\u0131z, a\u00e7\u0131k kaynakl\u0131 ve hafif BitTorrent indirme istemcisi.",
        "Icon": "https://www.google.com/s2/favicons?domain=qbittorrent.org&sz=128"
      },
      {
        "Name": "Wise Program Uninstaller (WiseCleaner)",
        "Id": "WiseCleaner.WiseProgramUninstaller",
        "Description": "Uygulamalar\u0131 zorla kald\u0131rma ve geride kalan kay\u0131tlar\u0131 temizleme arac\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=wisecleaner.com&sz=128"
      },
      {
        "Name": "Snappy Driver Installer Origin",
        "Id": "GlennDelahoy.SnappyDriverInstallerOrigin",
        "Description": "Eksik veya eski donan\u0131m s\u00fcr\u00fcc\u00fclerini reklams\u0131z ve \u00e7evrimd\u0131\u015f\u0131/\u00e7evrimi\u00e7i kuran a\u00e7\u0131k kaynakl\u0131 s\u00fcr\u00fcc\u00fc arac\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=glenn.delahoy.com&sz=128"
      },
      {
        "Name": "Nilesoft Shell",
        "Id": "Nilesoft.Shell",
        "Description": "Windows 10/11 sa\u011f t\u0131k men\u00fcs\u00fcn\u00fc tamamen \u00f6zelle\u015ftiren g\u00fc\u00e7l\u00fc ba\u011flam men\u00fcs\u00fc y\u00f6neticisi.",
        "Icon": "https://www.google.com/s2/favicons?domain=nilesoft.org&sz=128"
      },
      {
        "Name": "System Informer",
        "Id": "WinsiderSS.SystemInformer",
        "Description": "Geli\u015fmi\u015f s\u00fcre\u00e7, servis, a\u011f ba\u011flant\u0131s\u0131 ve \u00e7ekirdek d\u00fczeyinde sistem izleme arac\u0131 (eski Process Hacker).",
        "Icon": "https://www.google.com/s2/favicons?domain=systeminformer.com&sz=128"
      },
      {
        "Name": "SignalRGB",
        "Id": "WhirlwindFX.SignalRgb",
        "Description": "T\u00fcm RGB oyuncu ekipmanlar\u0131n\u0131 oyun i\u00e7i efektlerle senkronize eden ayd\u0131nlatma yaz\u0131l\u0131m\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=signalrgb.com&sz=128"
      },
      {
        "Name": "Simplewall",
        "Id": "Henry++.simplewall",
        "Description": "Windows Filtreleme Platformunu (WFP) y\u00f6neterek hangi uygulaman\u0131n internete \u00e7\u0131kaca\u011f\u0131n\u0131 kontrol eden hafif g\u00fcvenlik duvar\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=github.com&sz=128"
      },
      {
        "Name": "StartAllBack",
        "Id": "StartIsBack.StartAllBack",
        "Description": "Windows 11'e klasik g\u00f6rev \u00e7ubu\u011fu, ba\u015flat men\u00fcs\u00fc ve dosya gezgini g\u00f6r\u00fcn\u00fcm\u00fcn\u00fc geri kazand\u0131ran ara\u00e7.",
        "Icon": "https://www.google.com/s2/favicons?domain=startallback.com&sz=128"
      },
      {
        "Name": "Sunshine/GameStream Server",
        "Id": "LizardByte.Sunshine",
        "Description": "Bilgisayar\u0131n\u0131z\u0131 d\u00fc\u015f\u00fck gecikmeli bir bulut oyun sunucusuna d\u00f6n\u00fc\u015ft\u00fcren a\u00e7\u0131k kaynakl\u0131 Moonlight sunucusu.",
        "Icon": "https://www.google.com/s2/favicons?domain=app.lizardbyte.dev&sz=128"
      },
      {
        "Name": "SyncTrayzor",
        "Id": "GermanCoding.SyncTrayzor",
        "Description": "Syncthing dosya senkronizasyon motoru i\u00e7in sistem tepsisi (Tray) ve g\u00f6rsel y\u00f6netim aray\u00fcz\u00fc.",
        "Icon": "https://www.google.com/s2/favicons?domain=github.com&sz=128"
      },
      {
        "Name": "Syncthing (CLI / Web UI)",
        "Id": "Syncthing.Syncthing",
        "Description": "Bulut kullanmadan cihazlar\u0131n\u0131z aras\u0131nda do\u011frudan \u015fifreli dosya senkronizasyonu sa\u011flayan a\u00e7\u0131k kaynakl\u0131 ara\u00e7.",
        "Icon": "https://www.google.com/s2/favicons?domain=syncthing.net&sz=128"
      },
      {
        "Name": "TCPView",
        "Id": "Microsoft.Sysinternals.TCPView",
        "Description": "Sistemdeki t\u00fcm a\u00e7\u0131k TCP ve UDP a\u011f ba\u011flant\u0131lar\u0131n\u0131 ve hangi programa ait olduklar\u0131n\u0131 canl\u0131 g\u00f6sterir.",
        "Icon": "https://www.google.com/s2/favicons?domain=docs.microsoft.com&sz=128"
      },
      {
        "Name": "TeamViewer",
        "Id": "TeamViewer.TeamViewer",
        "Description": "Uzaktan teknik destek ve ekran kontrol\u00fc i\u00e7in yayg\u0131n kullan\u0131lan ba\u011flant\u0131 yaz\u0131l\u0131m\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=teamviewer.com&sz=128"
      },
      {
        "Name": "Total Commander",
        "Id": "Ghisler.TotalCommander",
        "Description": "\u00c7ift panelli, klavye odakl\u0131 klasik ve \u00e7ok g\u00fc\u00e7l\u00fc dosya y\u00f6neticisi.",
        "Icon": "https://www.google.com/s2/favicons?domain=ghisler.com&sz=128"
      },
      {
        "Name": "TreeSize Free",
        "Id": "JAMSoftware.TreeSize.Free",
        "Description": "Disk alan\u0131n\u0131 hangi klas\u00f6rlerin doldurdu\u011funu a\u011fa\u00e7 yap\u0131s\u0131yla h\u0131zl\u0131ca g\u00f6steren analiz arac\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=jam-software.com&sz=128"
      },
      {
        "Name": "TranslucentTB",
        "Id": "CharlesMilette.TranslucentTB",
        "Description": "Windows g\u00f6rev \u00e7ubu\u011funu tamamen \u015feffaf veya bulan\u0131k (Acrylic/Blur) yapan hafif ara\u00e7.",
        "Icon": "https://www.google.com/s2/favicons?domain=translucenttb.github.io&sz=128"
      },
      {
        "Name": "Visual C++ 2015-2022 32-bit",
        "Id": "Microsoft.VCRedist.2015+.x86",
        "Description": "Oyunlar\u0131n ve programlar\u0131n \u00e7al\u0131\u015fmas\u0131 i\u00e7in zorunlu olan 32-bit Visual C++ (msvcp140.dll) k\u00fct\u00fcphanesi.",
        "Icon": "https://www.google.com/s2/favicons?domain=support.microsoft.com&sz=128"
      },
      {
        "Name": "Visual C++ 2015-2022 64-bit",
        "Id": "Microsoft.VCRedist.2015+.x64",
        "Description": "Oyunlar\u0131n ve programlar\u0131n hatas\u0131z a\u00e7\u0131lmas\u0131 i\u00e7in zorunlu 64-bit Visual C++ (vcruntime140.dll) k\u00fct\u00fcphanesi.",
        "Icon": "https://www.google.com/s2/favicons?domain=support.microsoft.com&sz=128"
      },
      {
        "Name": "Ventoy",
        "Id": "Ventoy.Ventoy",
        "Description": "USB belle\u011fi tekrar formatlamadan i\u00e7ine birden fazla Windows/Linux ISO dosyas\u0131 kopyalay\u0131p ba\u015flatma arac\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=ventoy.net&sz=128"
      },
      {
        "Name": "UniGetUI",
        "Id": "Devolutions.UniGetUI",
        "Description": "Winget, Scoop, Chocolatey ve npm paketlerini \u015f\u0131k bir g\u00f6rsel ma\u011faza aray\u00fcz\u00fcnden y\u00f6netme arac\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=devolutions.net&sz=128"
      },
      {
        "Name": "WinSCP",
        "Id": "WinSCP.WinSCP",
        "Description": "Windows i\u00e7in a\u00e7\u0131k kaynakl\u0131 SFTP, FTP, WebDAV ve SCP g\u00fcvenli dosya aktar\u0131m istemcisi.",
        "Icon": "https://www.google.com/s2/favicons?domain=winscp.net&sz=128"
      },
      {
        "Name": "WireGuard",
        "Id": "WireGuard.WireGuard",
        "Description": "Modern kriptografi kullanan son derece h\u0131zl\u0131 ve hafif VPN protokol\u00fc istemcisi.",
        "Icon": "https://www.google.com/s2/favicons?domain=wireguard.com&sz=128"
      },
      {
        "Name": "Wireshark",
        "Id": "WiresharkFoundation.Wireshark",
        "Description": "A\u011f trafi\u011fini ve paketlerini ger\u00e7ek zamanl\u0131 yakalay\u0131p inceleyen profesyonel protokol analiz\u00f6r\u00fc.",
        "Icon": "https://www.google.com/s2/favicons?domain=wireshark.org&sz=128"
      },
      {
        "Name": "HxD Hex Editor",
        "Id": "MHNexus.HxD",
        "Description": "B\u00fcy\u00fck dosyalar\u0131, RAM belle\u011fini ve disk sekt\u00f6rlerini d\u00fczenleyebilen h\u0131zl\u0131 Hex edit\u00f6r\u00fc.",
        "Icon": "https://www.google.com/s2/favicons?domain=mh-nexus.de&sz=128"
      },
      {
        "Name": "TightVNC",
        "Id": "GlavSoft.TightVNC",
        "Description": "Hafif ve \u00fccretsiz VNC tabanl\u0131 uzak masa\u00fcst\u00fc kontrol yaz\u0131l\u0131m\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=tightvnc.com&sz=128"
      },
      {
        "Name": "GlazeWM",
        "Id": "glzr-io.glazewm",
        "Description": "Windows i\u00e7in Linux i3wm benzeri klavye odakl\u0131 pencere d\u00f6\u015feme (Tiling Window Manager) arac\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=github.com&sz=128"
      },
      {
        "Name": "OFGB (Oh Frick Go Back)",
        "Id": "xM4ddy.OFGB",
        "Description": "Windows 11 i\u00e7erisindeki t\u00fcm sistem reklamlar\u0131n\u0131 ve \u00f6nerilerini tek t\u0131kla kapatan a\u00e7\u0131k kaynakl\u0131 ara\u00e7.",
        "Icon": "https://www.google.com/s2/favicons?domain=github.com&sz=128"
      },
      {
        "Name": "Deskflow",
        "Id": "Deskflow.Deskflow",
        "Description": "Tek bir klavye ve fareyi yerel a\u011fdaki birden fazla bilgisayar aras\u0131nda kesintisiz payla\u015fma arac\u0131 (Synergy \u00e7atal\u0131).",
        "Icon": "https://www.google.com/s2/favicons?domain=github.com&sz=128"
      },
      {
        "Name": "Cloudflare WARP",
        "Id": "Cloudflare.Warp",
        "Description": "\u0130nternet trafi\u011finizi \u015fifreleyen ve 1.1.1.1 DNS \u00fczerinden h\u0131zland\u0131ran \u00fccretsiz Cloudflare WARP istemcisi.",
        "Icon": "https://www.google.com/s2/favicons?domain=one.one.one.one&sz=128"
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
      },
      {
        "Name": "Dropbox",
        "Id": "Dropbox.Dropbox",
        "Description": "Dosyalar\u0131n\u0131z\u0131 bulutta yedekleyen ve cihazlar aras\u0131nda senkronize eden depolama istemcisi.",
        "Icon": "https://www.google.com/s2/favicons?domain=dropbox.com&sz=128"
      },
      {
        "Name": "Foxit PDF Reader",
        "Id": "Foxit.FoxitReader",
        "Description": "H\u0131zl\u0131 a\u00e7\u0131lan, d\u00fc\u015f\u00fck kaynak t\u00fcketen kapsaml\u0131 PDF okuma ve not alma yaz\u0131l\u0131m\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=foxit.com&sz=128"
      },
      {
        "Name": "Joplin",
        "Id": "Joplin.Joplin",
        "Description": "U\u00e7tan uca \u015fifreleme ve bulut senkronizasyonu destekleyen a\u00e7\u0131k kaynakl\u0131 Markdown not uygulamas\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=joplinapp.org&sz=128"
      },
      {
        "Name": "NAPS2 (Scanner)",
        "Id": "Cyanfish.NAPS2",
        "Description": "Belge taray\u0131c\u0131lar i\u00e7in OCR (Metin Tan\u0131ma) ve PDF birle\u015ftirme destekli a\u00e7\u0131k kaynakl\u0131 tarama arac\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=naps2.com&sz=128"
      },
      {
        "Name": "Nextcloud Desktop",
        "Id": "Nextcloud.NextcloudDesktop",
        "Description": "Kendi \u00f6zel bulut sunucunuzdaki dosyalar\u0131 bilgisayar\u0131n\u0131zla senkronize eden resmi istemci.",
        "Icon": "https://www.google.com/s2/favicons?domain=nextcloud.com&sz=128"
      },
      {
        "Name": "Okular",
        "Id": "KDE.Okular",
        "Description": "PDF, ePub, DjVu ve \u00e7izgi roman formatlar\u0131n\u0131 destekleyen geli\u015fmi\u015f belge g\u00f6r\u00fcnt\u00fcleyici.",
        "Icon": "https://www.google.com/s2/favicons?domain=okular.kde.org&sz=128"
      },
      {
        "Name": "OneDrive",
        "Id": "Microsoft.OneDrive",
        "Description": "Microsoft bulut depolama ve dosya yedekleme istemcisi.",
        "Icon": "https://www.google.com/s2/favicons?domain=onedrive.live.com&sz=128"
      },
      {
        "Name": "ONLYOFFICE Desktop",
        "Id": "ONLYOFFICE.DesktopEditors",
        "Description": "Word, Excel ve PowerPoint formatlar\u0131yla tam uyumlu \u00fccretsiz ofis paketi.",
        "Icon": "https://www.google.com/s2/favicons?domain=onlyoffice.com&sz=128"
      },
      {
        "Name": "PDF-XChange Editor",
        "Id": "TrackerSoftware.PDF-XChangeEditor",
        "Description": "H\u0131zl\u0131 ve zengin \u00f6zellikli PDF d\u00fczenleme, OCR ve yorum ekleme yaz\u0131l\u0131m\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=pdf-xchange.com&sz=128"
      },
      {
        "Name": "PDF24 Creator",
        "Id": "geeksoftwareGmbH.PDF24Creator",
        "Description": "PDF birle\u015ftirme, b\u00f6lme, s\u0131k\u0131\u015ft\u0131rma ve d\u00f6n\u00fc\u015ft\u00fcrme i\u00e7in tamamen \u00fccretsiz PDF ara\u00e7 kutusu.",
        "Icon": "https://www.google.com/s2/favicons?domain=tools.pdf24.org&sz=128"
      },
      {
        "Name": "PDFgear",
        "Id": "PDFgear.PDFgear",
        "Description": "Tamamen \u00fccretsiz, yapay zeka destekli kapsaml\u0131 PDF d\u00fczenleme ve d\u00f6n\u00fc\u015ft\u00fcrme yaz\u0131l\u0131m\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=pdfgear.com&sz=128"
      },
      {
        "Name": "PDFsam Basic",
        "Id": "PDFsam.PDFsam",
        "Description": "PDF dosyalar\u0131n\u0131 sayfalara g\u00f6re b\u00f6lmek, birle\u015ftirmek ve d\u00f6nd\u00fcrmek i\u00e7in a\u00e7\u0131k kaynakl\u0131 ara\u00e7.",
        "Icon": "https://www.google.com/s2/favicons?domain=pdfsam.org&sz=128"
      },
      {
        "Name": "Proton Drive",
        "Id": "Proton.ProtonDrive",
        "Description": "\u0130svi\u00e7re gizlilik standartlar\u0131nda u\u00e7tan uca \u015fifreli bulut depolama istemcisi.",
        "Icon": "https://www.google.com/s2/favicons?domain=proton.me&sz=128"
      },
      {
        "Name": "QOwnNotes",
        "Id": "pbek.QOwnNotes",
        "Description": "Nextcloud entegrasyonlu, a\u00e7\u0131k kaynakl\u0131 d\u00fcz metin ve Markdown not alma uygulamas\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=qownnotes.org&sz=128"
      },
      {
        "Name": "Simplenote",
        "Id": "Automattic.Simplenote",
        "Description": "T\u00fcm cihazlarla an\u0131nda senkronize olan sade, h\u0131zl\u0131 ve \u00fccretsiz not alma uygulamas\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=simplenote.com&sz=128"
      },
      {
        "Name": "Xournal++",
        "Id": "Xournal++.Xournal++",
        "Description": "Grafik tablet ve kalem destekli, PDF \u00fczerine el yaz\u0131s\u0131 not alma ve \u00e7izim uygulamas\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=xournalpp.github.io&sz=128"
      },
      {
        "Name": "Zotero",
        "Id": "DigitalScholar.Zotero",
        "Description": "Akademik ara\u015ft\u0131rmalar, makaleler ve kaynak\u00e7a y\u00f6netimi i\u00e7in a\u00e7\u0131k kaynakl\u0131 ki\u015fisel asistan.",
        "Icon": "https://www.google.com/s2/favicons?domain=zotero.org&sz=128"
      }
    ]
  }
]
'@ | ConvertFrom-Json

$sync.FeaturesConfig = @'
[
  {
    "Name": "DirectPlay (Eski DirectX Oyun Deste\u011fi)",
    "Feature": "DirectPlay",
    "ExtraFeatures": [
      "LegacyComponents"
    ],
    "Desc": "GTA San Andreas, Blur, eski NFS ve DirectX 8/9 oyunlar\u0131n\u0131n Windows 10/11'de hatas\u0131z a\u00e7\u0131lmas\u0131 i\u00e7in \u015fartt\u0131r."
  },
  {
    "Name": ".NET Framework 3.5 (2.0 ve 3.0 Dahil)",
    "Feature": "NetFx3",
    "ExtraFeatures": [
      "NetFx4-AdvSrvs"
    ],
    "Desc": "Eski program, oyun modlar\u0131 ve kurulumcular\u0131n ihtiya\u00e7 duydu\u011fu .NET 2.0, 3.0 ve 3.5 \u00e7al\u0131\u015fma zaman\u0131 k\u00fct\u00fcphanesi."
  },
  {
    "Name": "WSL 2 (Windows Subsystem for Linux)",
    "Feature": "Microsoft-Windows-Subsystem-Linux",
    "ExtraFeatures": [],
    "Desc": "Geli\u015ftiriciler i\u00e7in Windows i\u00e7inde yerel Linux \u00e7ekirde\u011fi ve Ubuntu/Debian terminali \u00e7al\u0131\u015ft\u0131rma altyap\u0131s\u0131."
  },
  {
    "Name": "Sanal Makine Platformu (Virtual Machine Platform)",
    "Feature": "VirtualMachinePlatform",
    "ExtraFeatures": [],
    "Desc": "WSL 2, WSA ve sanalla\u015ft\u0131rma tabanl\u0131 alt sistemler i\u00e7in gerekli temel donan\u0131m sanalla\u015ft\u0131rma bile\u015feni."
  },
  {
    "Name": "Windows Sandbox (Kum Havuzu)",
    "Feature": "Containers-DisposableClientVM",
    "ExtraFeatures": [],
    "Desc": "\u015e\u00fcpheli dosyalar\u0131 ve kurulumlar\u0131 ana sisteme zarar vermeden izole ge\u00e7ici sanal makinede g\u00fcvenle test etme arac\u0131."
  },
  {
    "Name": "Hyper-V Sanalla\u015ft\u0131rma Altyap\u0131s\u0131",
    "Feature": "Microsoft-Hyper-V-All",
    "ExtraFeatures": [],
    "Desc": "Tam donan\u0131m sanalla\u015ft\u0131rma hiperviz\u00f6r\u00fc (Type-1 Hypervisor) ve Hyper-V Y\u00f6neticisi konsolu."
  },
  {
    "Name": "Telnet \u0130stemcisi (Telnet Client)",
    "Feature": "TelnetClient",
    "ExtraFeatures": [],
    "Desc": "A\u011f cihazlar\u0131na, sunuculara ve a\u00e7\u0131k portlara komut sat\u0131r\u0131ndan Telnet protokol\u00fc ile ba\u011flanma ve port testi arac\u0131."
  },
  {
    "Name": "TFTP \u0130stemcisi (TFTP Client)",
    "Feature": "TFTP",
    "ExtraFeatures": [],
    "Desc": "Modem, router, switch ve PXE a\u011f \u00f6ny\u00fckleme cihazlar\u0131na Trivial FTP protokol\u00fc ile dosya/firmware aktar\u0131m arac\u0131."
  },
  {
    "Name": "Klasik Medya Bile\u015fenleri (Windows Media Player)",
    "Feature": "WindowsMediaPlayer",
    "ExtraFeatures": [
      "MediaPlayback"
    ],
    "Desc": "Eski oyunlar\u0131n ara sahne videolar\u0131 i\u00e7in ihtiya\u00e7 duydu\u011fu klasik Windows Media Player ve medya oynatma bile\u015fenleri."
  },
  {
    "Name": "A\u011f Dosya Sistemi (NFS Client)",
    "Feature": "ServicesForNFS-ClientOnly",
    "ExtraFeatures": [
      "ClientForNFS-Infrastructure",
      "NFS-Administration"
    ],
    "Desc": "Linux/NAS sunucular\u0131ndaki NFS a\u011f payla\u015f\u0131mlar\u0131n\u0131 Windows'a do\u011frudan yerel disk gibi ba\u011flama bile\u015feni."
  }
]
'@ | ConvertFrom-Json

$sync.TweaksConfig = @'
[
  {
    "Group": "1. Temel ve Gizlilik Ayarlar\u0131 (Essential Tweaks)",
    "Items": [
      {
        "Id": "Tweak_RestorePoint",
        "Recommended": true,
        "Preset": [
          "Standard",
          "Advanced"
        ],
        "Title": "Sistem Geri Y\u00fckleme Noktas\u0131 Olu\u015ftur (Checkpoint-Computer)",
        "Desc": "\u0130\u015flemlerden \u00f6nce sistem korumas\u0131n\u0131 a\u00e7ar, s\u0131kl\u0131k s\u0131n\u0131r\u0131n\u0131 kald\u0131r\u0131r ve g\u00fcvenli geri d\u00f6n\u00fc\u015f noktas\u0131 olu\u015fturur."
      },
      {
        "Id": "Tweak_Telemetry",
        "Recommended": true,
        "Preset": [
          "Standard",
          "Minimal",
          "Advanced"
        ],
        "Title": "Telemetri ve Tan\u0131lama Verilerini Kapat (DiagTrack + Group Policy)",
        "Desc": "DiagTrack ve dmwappushservice servislerini devre d\u0131\u015f\u0131 b\u0131rak\u0131r, Group Policy, SIUF, m\u00fcrekkep/ses ve PowerShell 7 telemetrisini kapat\u0131r."
      },
      {
        "Id": "Tweak_ActivityHistory",
        "Recommended": true,
        "Preset": [
          "Standard",
          "Advanced"
        ],
        "Title": "Etkinlik Ge\u00e7mi\u015fi (Timeline) ve Kullan\u0131c\u0131 Takibini Kapat",
        "Desc": "Windows'un a\u00e7t\u0131\u011f\u0131n\u0131z dosya ve uygulama ge\u00e7mi\u015fini kaydetmesini ve buluta senkronize etmesini durdurur (Pano ge\u00e7mi\u015fini korur)."
      },
      {
        "Id": "Tweak_Location",
        "Recommended": true,
        "Preset": [
          "Standard",
          "Advanced"
        ],
        "Title": "Konum Takibi ve Harita Servislerini Kapat (lfsvc)",
        "Desc": "Uygulamalar\u0131n ve Windows'un fiziksel konumunuzu takip etmesini ve sens\u00f6r izinlerini devre d\u0131\u015f\u0131 b\u0131rak\u0131r."
      },
      {
        "Id": "Tweak_AdvertisingId",
        "Recommended": true,
        "Preset": [
          "Standard",
          "Advanced"
        ],
        "Title": "Reklam Kimli\u011fi (Advertising ID) ve Ki\u015fiselle\u015ftirilmi\u015f \u0130pu\u00e7lar\u0131n\u0131 Kapat",
        "Desc": "Uygulamalar aras\u0131 reklam kimli\u011fi takibini ve tan\u0131 verisiyle ki\u015fiselle\u015ftirilmi\u015f \u00f6nerileri kapat\u0131r."
      },
      {
        "Id": "Tweak_BingSearch",
        "Recommended": true,
        "Preset": [
          "Standard",
          "Advanced"
        ],
        "Title": "Ba\u015flat Men\u00fcs\u00fc Bing Web Arama Sonu\u00e7lar\u0131n\u0131 Kapat (DisableSearchBoxSuggestions)",
        "Desc": "Ba\u015flat men\u00fcs\u00fcnde arama yaparken Bing internet sonu\u00e7lar\u0131n\u0131n \u00e7\u0131kmas\u0131n\u0131 engeller, yerel aramay\u0131 h\u0131zland\u0131r\u0131r."
      },
      {
        "Id": "Tweak_ConsumerFeatures",
        "Recommended": true,
        "Preset": [
          "Standard",
          "Minimal",
          "Advanced"
        ],
        "Title": "Kilit Ekran\u0131 \u0130pu\u00e7lar\u0131 ve Microsoft T\u00fcketici Deneyimlerini (Spotlight) Kapat",
        "Desc": "Windows'un arka planda sessizce sponsorlu ma\u011faza uygulamalar\u0131 ve oyunlar kurmas\u0131n\u0131 (ConsumerFeatures) engeller."
      },
      {
        "Id": "Tweak_ErrorReporting",
        "Recommended": true,
        "Preset": [
          "Standard",
          "Advanced"
        ],
        "Title": "Windows Hata Bildirimi (WerFault / WerSvc) Kapat",
        "Desc": "\u00c7\u00f6ken uygulamalar i\u00e7in Microsoft'a tan\u0131 raporu haz\u0131rlayan Windows Error Reporting servisini devre d\u0131\u015f\u0131 b\u0131rak\u0131r."
      },
      {
        "Id": "Tweak_DeliveryOpt",
        "Recommended": true,
        "Preset": [
          "Standard",
          "Advanced"
        ],
        "Title": "Teslim En \u0130yile\u015ftirme (P2P G\u00fcncelleme Payla\u015f\u0131m\u0131) Kapat",
        "Desc": "Windows'un arka planda internet bant geni\u015fli\u011finizi kullanarak ba\u015fka bilgisayarlara g\u00fcncelleme y\u00fcklemesini durdurur."
      },
      {
        "Id": "Tweak_WPBT",
        "Recommended": true,
        "Preset": [
          "Standard",
          "Minimal",
          "Advanced"
        ],
        "Title": "Windows Platform Binary Table (WPBT) Kapat",
        "Desc": "Anakart \u00fcreticilerinin BIOS \u00fczerinden Windows a\u00e7\u0131l\u0131\u015f\u0131nda izinsiz arka plan yaz\u0131l\u0131m\u0131 enjekte etmesini engeller."
      },
      {
        "Id": "Tweak_DeviceMetadata",
        "Recommended": true,
        "Preset": [
          "Standard",
          "Advanced"
        ],
        "Title": "Cihaz E\u015flik\u00e7i Uygulamalar\u0131n\u0131n Otomatik Kurulumunu Engelle",
        "Desc": "Monit\u00f6r veya \u00e7evre birimi tak\u0131ld\u0131\u011f\u0131nda a\u011f \u00fczerinden otomatik tan\u0131t\u0131m/reklam uygulamas\u0131 indirilmesini engeller."
      },
      {
        "Id": "Tweak_StoreSearch",
        "Recommended": false,
        "Preset": [
          "Advanced"
        ],
        "Title": "Ba\u015flat Men\u00fcs\u00fcnde Microsoft Store Uygulama \u00d6nerilerini Kapat",
        "Desc": "Arama kutusunda y\u00fckl\u00fc olmayan Microsoft Store uygulama tavsiyelerinin g\u00f6sterilmesini engeller."
      },
      {
        "Id": "Tweak_ExplorerAutoDiscovery",
        "Recommended": true,
        "Preset": [
          "Standard",
          "Advanced"
        ],
        "Title": "Dosya Gezgini Otomatik Klas\u00f6r T\u00fcr\u00fc Alg\u0131lamay\u0131 Kapat (H\u0131zl\u0131 Gezinme)",
        "Desc": "\u0130\u00e7inde \u00e7ok say\u0131da medya olan klas\u00f6rleri a\u00e7arken Dosya Gezgini'nin bekleyip tak\u0131lmas\u0131n\u0131 \u00f6nler, t\u00fcm klas\u00f6rleri genel modda an\u0131nda a\u00e7ar."
      },
      {
        "Id": "Tweak_EndTaskOnTaskbar",
        "Recommended": true,
        "Preset": [
          "Standard",
          "Advanced"
        ],
        "Title": "G\u00f6rev \u00c7ubu\u011fundan Sa\u011f T\u0131kla 'G\u00f6revi Sonland\u0131r' \u00d6zelli\u011fini A\u00e7",
        "Desc": "G\u00f6rev Y\u00f6neticisi'ni a\u00e7maya gerek kalmadan g\u00f6rev \u00e7ubu\u011fundaki uygulama simgesine sa\u011f t\u0131klay\u0131p kapatabilmenizi sa\u011flar."
      }
    ]
  },
  {
    "Group": "2. Oyun ve Sistem Performans\u0131 (Gaming & Latency)",
    "Items": [
      {
        "Id": "Tweak_UltimatePerf",
        "Recommended": true,
        "Preset": [
          "Standard",
          "Advanced"
        ],
        "Title": "Nihai Performans (Ultimate Performance) G\u00fc\u00e7 Plan\u0131 Aktivasyonu",
        "Desc": "\u0130\u015flemci frekans d\u00fc\u015f\u00fc\u015flerini ve mikro gecikmeleri \u00f6nleyen gizli Nihai Performans g\u00fc\u00e7 plan\u0131n\u0131 olu\u015fturur ve etkinle\u015ftirir."
      },
      {
        "Id": "Tweak_MouseAccel",
        "Recommended": true,
        "Preset": [
          "Standard",
          "Advanced"
        ],
        "Title": "Fare \u0130vmesini (Enhance Pointer Precision) Kapat (1:1 Ham Giri\u015f)",
        "Desc": "Windows i\u015faret\u00e7i hassasiyetini kapatarak rekabet\u00e7i FPS oyunlar\u0131nda (CS2, Valorant) 1:1 ham fare hareketi sa\u011flar."
      },
      {
        "Id": "Tweak_GameDVR",
        "Recommended": true,
        "Preset": [
          "Standard",
          "Advanced"
        ],
        "Title": "Xbox GameDVR Arka Plan Kayd\u0131n\u0131 Kapat ve Oyun Modunu (Game Mode) A\u00e7",
        "Desc": "Oyunlarda FPS d\u00fc\u015f\u00fc\u015f\u00fc ve tak\u0131lmalara yol a\u00e7an arka plan video yakalamay\u0131 kapat\u0131r, Windows Oyun Modu'nu aktif eder."
      },
      {
        "Id": "Tweak_NetworkThrottling",
        "Recommended": true,
        "Preset": [
          "Standard",
          "Advanced"
        ],
        "Title": "A\u011f Trafi\u011fi K\u0131s\u0131tlamas\u0131n\u0131 Kald\u0131r (NetworkThrottlingIndex = 0xFFFFFFFF)",
        "Desc": "Multimedya ve oyun esnas\u0131nda Windows'un a\u011f paket i\u015fleme h\u0131z\u0131n\u0131 s\u0131n\u0131rland\u0131rmas\u0131n\u0131 tamamen kald\u0131r\u0131r."
      },
      {
        "Id": "Tweak_SystemResponsiveness",
        "Recommended": true,
        "Preset": [
          "Standard",
          "Advanced"
        ],
        "Title": "Sistem Tepkiselli\u011fi ve Oyun \u00d6nceli\u011fi (SystemResponsiveness = 0)",
        "Desc": "Arka plan i\u015flemleri yerine oyun ve ger\u00e7ek zamanl\u0131 uygulamalara %100 i\u015flemci ve a\u011f \u00f6nceli\u011fi tan\u0131r."
      },
      {
        "Id": "Tweak_TCPNoDelay",
        "Recommended": true,
        "Preset": [
          "Standard",
          "Advanced"
        ],
        "Title": "TCP No Delay & Ack Frequency (Nagle Algoritmas\u0131n\u0131 Devre D\u0131\u015f\u0131 B\u0131rak)",
        "Desc": "A\u011f paketlerini arabellekte bekletmeden an\u0131nda g\u00f6ndererek \u00e7evrimi\u00e7i oyunlarda ping dalgalanmas\u0131n\u0131 ve gecikmeyi d\u00fc\u015f\u00fcr\u00fcr."
      },
      {
        "Id": "Tweak_GreenEthernet",
        "Recommended": true,
        "Preset": [
          "Advanced"
        ],
        "Title": "Green Ethernet ve A\u011f Kart\u0131 Enerji Tasarrufu Modlar\u0131n\u0131 Kapat",
        "Desc": "A\u011f ba\u011fda\u015ft\u0131r\u0131c\u0131s\u0131n\u0131n g\u00fc\u00e7 tasarrufu moduna ge\u00e7ip oyun ortas\u0131nda anl\u0131k paket kayb\u0131 (lag spike) olu\u015fturmas\u0131n\u0131 engeller."
      },
      {
        "Id": "Tweak_Hibernation",
        "Recommended": false,
        "Preset": [
          "Standard",
          "Advanced"
        ],
        "Title": "Haz\u0131rda Bekletmeyi (Hibernation) Kapat (powercfg -h off ile 10-30 GB Yer A\u00e7)",
        "Desc": "Masa\u00fcst\u00fc bilgisayarlarda gereksiz olan hiberfil.sys dosyas\u0131n\u0131 kald\u0131rarak SSD \u00fczerinde ciddi depolama alan\u0131 a\u00e7ar."
      },
      {
        "Id": "Tweak_BgApps",
        "Recommended": true,
        "Preset": [
          "Standard",
          "Advanced"
        ],
        "Title": "Gereksiz Ma\u011faza Arka Plan Uygulamalar\u0131n\u0131 Kapat (GlobalUserDisabled)",
        "Desc": "Kullanmad\u0131\u011f\u0131n\u0131z Microsoft Store uygulamalar\u0131n\u0131n arka planda gizlice \u00e7al\u0131\u015f\u0131p RAM ve CPU t\u00fcketmesini engeller."
      },
      {
        "Id": "Tweak_MultiplaneOverlay",
        "Recommended": false,
        "Preset": [],
        "Title": "Multiplane Overlay (MPO) Kapat (Ekran Titremesi ve Tak\u0131lma \u00c7\u00f6z\u00fcm\u00fc)",
        "Desc": "NVIDIA ve AMD ekran kartlar\u0131nda masa\u00fcst\u00fc ve oyun ge\u00e7i\u015flerinde ya\u015fanan siyah ekran, titreme ve tak\u0131lmalar\u0131 (OverlayTestMode=5) \u00e7\u00f6zer."
      },
      {
        "Id": "Tweak_VisualFX",
        "Recommended": true,
        "Preset": [
          "Standard",
          "Advanced"
        ],
        "Title": "Men\u00fc Ge\u00e7i\u015flerini H\u0131zland\u0131r ve En \u0130yi Performans G\u00f6rsel Efektlerini Uygula",
        "Desc": "MenuShowDelay s\u00fcresini 10ms'ye d\u00fc\u015f\u00fcr\u00fcr ve gereksiz pencere/g\u00f6rev \u00e7ubu\u011fu animasyonlar\u0131n\u0131 azaltarak aray\u00fcz\u00fc h\u0131zland\u0131r\u0131r."
      }
    ]
  },
  {
    "Group": "3. Disk, Servis ve Donan\u0131m Optimizasyonlar\u0131",
    "Items": [
      {
        "Id": "Tweak_SSDTrim",
        "Recommended": true,
        "Preset": [
          "Standard",
          "Advanced"
        ],
        "Title": "SSD TRIM \u00d6zelli\u011fini Zorla ve Do\u011frula (DisableDeleteNotify = 0)",
        "Desc": "SSD disklerin okuma/yazma \u00f6mr\u00fcn\u00fc ve h\u0131z\u0131n\u0131 koruyan TRIM komutunun aktif oldu\u011funu do\u011frular ve zorlar."
      },
      {
        "Id": "Tweak_Services",
        "Recommended": true,
        "Preset": [
          "Standard",
          "Minimal",
          "Advanced"
        ],
        "Title": "Gereksiz Arka Plan Servislerini Manuel/Devre D\u0131\u015f\u0131 Moduna Al (WinUtil Services)",
        "Desc": "RemoteRegistry, Fax, MapsBroker, CscService, StorSvc, SharedAccess, RetailDemo ve WMPNetworkSvc gibi servisleri optimize eder."
      },
      {
        "Id": "Tweak_DiskCleanup",
        "Recommended": true,
        "Preset": [
          "Standard",
          "Advanced"
        ],
        "Title": "Kapsaml\u0131 Disk ve \u00d6nbellek Temizli\u011fi (Cleanmgr / Temp / Prefetch / WU Cache)",
        "Desc": "Temp klas\u00f6rlerini, Prefetch \u00f6nbelle\u011fini, Windows Update indirme kal\u0131nt\u0131lar\u0131n\u0131 ve C: s\u00fcr\u00fcc\u00fcs\u00fc gereksiz dosyalar\u0131n\u0131 temizler."
      },
      {
        "Id": "Tweak_StorageSense",
        "Recommended": false,
        "Preset": [],
        "Title": "Ak\u0131ll\u0131 Depolama (Storage Sense) Otomatik Silmeyi Kapat",
        "Desc": "Windows'un \u0130ndirilenler veya ge\u00e7ici klas\u00f6rlerdeki dosyalar\u0131 arka planda kendili\u011finden silmesini durdurur."
      },
      {
        "Id": "Tweak_ReservedStorage",
        "Recommended": false,
        "Preset": [],
        "Title": "Windows Ayr\u0131lm\u0131\u015f Depolama Alan\u0131n\u0131 (Reserved Storage) Kapat (~7-10 GB)",
        "Desc": "Windows'un g\u00fcncellemeler i\u00e7in diskte bloke etti\u011fi 7-10 GB'l\u0131k ayr\u0131lm\u0131\u015f alan\u0131 serbest b\u0131rak\u0131r."
      },
      {
        "Id": "Tweak_SvcHostSplitting",
        "Recommended": false,
        "Preset": [],
        "Title": "svchost.exe S\u00fcre\u00e7 B\u00f6l\u00fcnmesini (Splitting) Kapat",
        "Desc": "RAM boyutuna g\u00f6re SvcHostSplitThresholdInKB de\u011ferini y\u00fckselterek G\u00f6rev Y\u00f6neticisi'ndeki svchost.exe say\u0131s\u0131n\u0131 azalt\u0131r."
      },
      {
        "Id": "Tweak_BitLocker",
        "Recommended": false,
        "Preset": [],
        "Title": "BitLocker S\u00fcr\u00fcc\u00fc \u015eifrelemesini Devre D\u0131\u015f\u0131 B\u0131rak (SSD Performans\u0131)",
        "Desc": "Sistem s\u00fcr\u00fcc\u00fcs\u00fcnde yaz\u0131l\u0131msal BitLocker \u015fifrelemesini kapatarak disk G/\u00c7 gecikmesini azalt\u0131r."
      },
      {
        "Id": "Tweak_LongPaths",
        "Recommended": true,
        "Preset": [
          "Standard",
          "Advanced"
        ],
        "Title": "260 Karakterden Uzun Dosya Yolu (Long Paths) Deste\u011fini A\u00e7",
        "Desc": "Geli\u015ftiriciler ve derin klas\u00f6r yap\u0131lar\u0131 i\u00e7in Windows'un 260 karakterlik MAX_PATH s\u0131n\u0131r\u0131n\u0131 kald\u0131r\u0131r."
      },
      {
        "Id": "Tweak_UTC",
        "Recommended": false,
        "Preset": [],
        "Title": "Donan\u0131m Saatini UTC Olarak Ayarla (Dual-Boot Linux Uyumlulu\u011fu)",
        "Desc": "Windows ve Linux'u ayn\u0131 bilgisayarda (Dual-Boot) kullan\u0131rken saat kaymas\u0131 sorununu (RealTimeIsUniversal) \u00e7\u00f6zer."
      },
      {
        "Id": "Tweak_S0StandbyFix",
        "Recommended": false,
        "Preset": [],
        "Title": "Modern Uyku (S0 Low Power Idle) A\u011f Ba\u011flant\u0131s\u0131n\u0131 Kapat",
        "Desc": "Diz\u00fcst\u00fc bilgisayarlarda uyku modundayken a\u011f ba\u011flant\u0131s\u0131n\u0131 keserek pil t\u00fckenmesini ve \u0131s\u0131nmay\u0131 \u00f6nler."
      },
      {
        "Id": "Tweak_S3Sleep",
        "Recommended": false,
        "Preset": [],
        "Title": "Klasik S3 Uyku Modunu Zorla (PlatformAoAcOverride)",
        "Desc": "Sorunlu Modern Standby yerine i\u015flemci g\u00fcc\u00fcn\u00fc tamamen kesen klasik S3 derin uyku modunu etkinle\u015ftirir."
      }
    ]
  },
  {
    "Group": "4. Aray\u00fcz ve Kullan\u0131labilirlik (UI Tweaks)",
    "Items": [
      {
        "Id": "Tweak_ClassicContext",
        "Recommended": true,
        "Preset": [
          "Advanced"
        ],
        "Title": "Windows 11 Klasik Sa\u011f T\u0131k Men\u00fcs\u00fcn\u00fc Etkinle\u015ftir (CLSID\\{86ca1aa0-...})",
        "Desc": "'Daha fazla se\u00e7enek g\u00f6ster' ad\u0131m\u0131n\u0131 kald\u0131rarak do\u011frudan tam kapsaml\u0131 klasik sa\u011f t\u0131k men\u00fcs\u00fcn\u00fc a\u00e7ar."
      },
      {
        "Id": "Tweak_FileExt",
        "Recommended": true,
        "Preset": [
          "Standard",
          "Advanced"
        ],
        "Title": "Bilinen Dosya Uzant\u0131lar\u0131n\u0131 (.exe, .ps1, .txt) G\u00f6ster",
        "Desc": "Dosya Gezgini'nde t\u00fcm dosyalar\u0131n ger\u00e7ek uzant\u0131lar\u0131n\u0131 g\u00f6r\u00fcn\u00fcr yaparak g\u00fcvenli\u011fi ve kullan\u0131m kolayl\u0131\u011f\u0131n\u0131 art\u0131r\u0131r."
      },
      {
        "Id": "Tweak_HiddenFiles",
        "Recommended": false,
        "Preset": [],
        "Title": "Gizli Dosya ve Klas\u00f6rleri G\u00f6ster (AppData vb.)",
        "Desc": "Dosya Gezgini'nde gizli sistem ve kullan\u0131c\u0131 klas\u00f6rlerini g\u00f6r\u00fcn\u00fcr hale getirir."
      },
      {
        "Id": "Tweak_HideTaskbarJunk",
        "Recommended": true,
        "Preset": [
          "Standard",
          "Advanced"
        ],
        "Title": "G\u00f6rev \u00c7ubu\u011fu Arama, Widget (Hava Durumu) ve G\u00f6rev G\u00f6r\u00fcn\u00fcm\u00fc Simgelerini Gizle",
        "Desc": "G\u00f6rev \u00e7ubu\u011fundaki gereksiz arama kutusunu, G\u00f6rev G\u00f6r\u00fcn\u00fcm\u00fc butonunu ve arka planda \u00e7al\u0131\u015fan Widget s\u00fcrecini kapat\u0131r."
      },
      {
        "Id": "Tweak_DarkMode",
        "Recommended": true,
        "Preset": [
          "Standard",
          "Advanced"
        ],
        "Title": "Sistem ve Uygulama D\u00fczeyinde Koyu Tema (Dark Mode) Zorla",
        "Desc": "Windows kabu\u011funu, Ba\u015flat men\u00fcs\u00fcn\u00fc ve t\u00fcm destekleyen uygulamalar\u0131 Koyu Tema moduna ge\u00e7irir."
      },
      {
        "Id": "Tweak_StickyKeys",
        "Recommended": true,
        "Preset": [
          "Standard",
          "Advanced"
        ],
        "Title": "Yap\u0131\u015fkan Tu\u015flar (Sticky Keys) K\u0131sayolunu ve Bildirimini Kapat",
        "Desc": "Oyunlarda art arda Shift tu\u015funa bas\u0131ld\u0131\u011f\u0131nda ekrana gelen Yap\u0131\u015fkan Tu\u015flar uyar\u0131s\u0131n\u0131 (Flags=506) tamamen kapat\u0131r."
      },
      {
        "Id": "Tweak_ClassicPhotoViewer",
        "Recommended": true,
        "Preset": [
          "Standard",
          "Advanced"
        ],
        "Title": "Klasik Windows Foto\u011fraf G\u00f6r\u00fcnt\u00fcleyicisini (Windows Photo Viewer) Geri Getir",
        "Desc": "Yava\u015f a\u00e7\u0131lan UWP Foto\u011fraflar uygulamas\u0131 yerine saliseler i\u00e7inde a\u00e7\u0131lan klasik Windows Foto\u011fraf G\u00f6r\u00fcnt\u00fcleyicisi kay\u0131tlar\u0131n\u0131 ekler."
      },
      {
        "Id": "Tweak_RemoveHomeGallery",
        "Recommended": true,
        "Preset": [
          "Advanced"
        ],
        "Title": "Dosya Gezgini'nde 'Giri\u015f (Home)' ve 'Galeri' Sekmelerini Kald\u0131r, 'Bu Bilgisayar' ile A\u00e7",
        "Desc": "Dosya Gezgini sol panelinden Giri\u015f ve Galeri kalabal\u0131\u011f\u0131n\u0131 kald\u0131r\u0131r, gezgini do\u011frudan Bu Bilgisayar g\u00f6r\u00fcn\u00fcm\u00fcnde ba\u015flat\u0131r."
      },
      {
        "Id": "Tweak_TaskbarLeft",
        "Recommended": false,
        "Preset": [],
        "Title": "Windows 11 G\u00f6rev \u00c7ubu\u011fu Simgelerini Sola Hizala",
        "Desc": "Ortalanm\u0131\u015f Windows 11 ba\u015flat men\u00fcs\u00fc ve g\u00f6rev \u00e7ubu\u011fu simgelerini klasik sol k\u00f6\u015feye hizalar."
      },
      {
        "Id": "Tweak_RevertStartMenu",
        "Recommended": false,
        "Preset": [
          "Advanced"
        ],
        "Title": "Ba\u015flat Men\u00fcs\u00fc \u00d6nerilenler B\u00f6l\u00fcm\u00fc ve 25H2 D\u00fczenini Kapat",
        "Desc": "Ba\u015flat men\u00fcs\u00fcndeki \u00d6nerilenler (Recommended) alan\u0131n\u0131 gizler ve klasik d\u00fczeni etkinle\u015ftirir."
      },
      {
        "Id": "Tweak_NumLock",
        "Recommended": true,
        "Preset": [
          "Standard",
          "Advanced"
        ],
        "Title": "Bilgisayar A\u00e7\u0131l\u0131\u015f\u0131nda Num Lock Tu\u015funu Otomatik A\u00e7",
        "Desc": "Oturum a\u00e7ma ekran\u0131nda ve masa\u00fcst\u00fcnde klavye say\u0131sal tu\u015f tak\u0131m\u0131n\u0131 (Num Lock) her zaman a\u00e7\u0131k ba\u015flat\u0131r."
      },
      {
        "Id": "Tweak_DetailedBSoD",
        "Recommended": true,
        "Preset": [
          "Standard",
          "Advanced"
        ],
        "Title": "Ayr\u0131nt\u0131l\u0131 Mavi Ekran (BSoD) ve A\u00e7\u0131l\u0131\u015f/Kapan\u0131\u015f Durum Mesajlar\u0131n\u0131 A\u00e7",
        "Desc": "Mavi ekran hatalar\u0131nda tam hata parametrelerini ve Windows a\u00e7\u0131l\u0131\u015f/kapan\u0131\u015f\u0131nda detayl\u0131 durum bilgisini (VerboseLogon) g\u00f6sterir."
      },
      {
        "Id": "Tweak_BatteryPct",
        "Recommended": false,
        "Preset": [],
        "Title": "Sistem Tepsisinde Pil Y\u00fczdesini G\u00f6ster, Kayd\u0131rma \u00c7ubuklar\u0131n\u0131 Her Zaman A\u00e7\u0131k Tut",
        "Desc": "G\u00f6rev \u00e7ubu\u011fu pil simgesi yan\u0131nda say\u0131sal y\u00fczdeyi g\u00f6sterir ve pencere kayd\u0131rma \u00e7ubuklar\u0131n\u0131n otomatik gizlenmesini kapat\u0131r."
      },
      {
        "Id": "Tweak_HideSettingsHome",
        "Recommended": true,
        "Preset": [
          "Standard"
        ],
        "Title": "Windows Ayarlar 'Giri\u015f (Home)' Sayfas\u0131n\u0131 ve Kilit Ekran\u0131 Bulan\u0131kl\u0131\u011f\u0131n\u0131 Kapat",
        "Desc": "Ayarlar uygulamas\u0131ndaki reklaml\u0131 Giri\u015f sekmesini gizler ve oturum a\u00e7ma ekran\u0131ndaki Acrylic Blur efektini kapat\u0131r."
      }
    ]
  },
  {
    "Group": "5. Geli\u015fmi\u015f Tweaks & Derin Temizlik (Advanced Tweaks & Deep Debloat)",
    "Items": [
      {
        "Id": "Tweak_DeepOneDrive",
        "Recommended": false,
        "Preset": [
          "Advanced"
        ],
        "Title": "OneDrive K\u00f6kten Kald\u0131rma ve CLSID Temizli\u011fi",
        "Desc": "Kullan\u0131c\u0131 dosyalar\u0131n\u0131 koruyarak OneDrive s\u00fcre\u00e7lerini sonland\u0131r\u0131r, OneDriveSetup /uninstall \u00e7al\u0131\u015ft\u0131r\u0131r ve Gezgin sol panel CLSID kal\u0131nt\u0131lar\u0131n\u0131 siler."
      },
      {
        "Id": "Tweak_DisableCopilotAI",
        "Recommended": true,
        "Preset": [
          "Advanced"
        ],
        "Title": "Copilot, Windows Recall ve AI Bile\u015fenlerini Tamamen Devre D\u0131\u015f\u0131 B\u0131rak",
        "Desc": "Group Policy, Registry, WSAIFabricSvc ve DISM \u00fczerinden Windows Copilot, Recall anl\u0131k g\u00f6r\u00fcnt\u00fc alma ve Notepad AI \u00f6zelliklerini kapat\u0131r."
      },
      {
        "Id": "Tweak_EdgeDebloat",
        "Recommended": true,
        "Preset": [
          "Advanced"
        ],
        "Title": "Microsoft Edge \u0130zolasyonu ve Telemetri Temizli\u011fi (17 \u0130lke + Arka Plan Kapatma)",
        "Desc": "Edge Startup Boost, arka plan \u00e7al\u0131\u015fma, al\u0131\u015fveri\u015f asistan\u0131, \u00f6d\u00fcller, kenar \u00e7ubu\u011fu ve telemetri ilkelerinin tamam\u0131n\u0131 devre d\u0131\u015f\u0131 b\u0131rak\u0131r."
      },
      {
        "Id": "Tweak_RemoveEdge",
        "Recommended": false,
        "Preset": [],
        "Title": "Microsoft Edge Taray\u0131c\u0131s\u0131n\u0131 Sistem D\u00fczeyinde Kald\u0131r (Edge Unlocker)",
        "Desc": "WinUtil y\u00f6ntemiyle resmi Edge kald\u0131r\u0131c\u0131s\u0131n\u0131n kilidini a\u00e7arak Microsoft Edge'i sistemden kald\u0131r\u0131r (Geri Al ile Winget \u00fczerinden tekrar kurulur)."
      },
      {
        "Id": "Tweak_BraveDebloat",
        "Recommended": true,
        "Preset": [
          "Advanced"
        ],
        "Title": "Brave Browser Debloat (Rewards, Kripto C\u00fczdan, Leo AI ve VPN Kapatma)",
        "Desc": "Brave taray\u0131c\u0131s\u0131ndaki kripto c\u00fczdan, Brave Rewards, Leo AI sohbet, Brave VPN ve haber ak\u0131\u015f\u0131 kalabal\u0131\u011f\u0131n\u0131 Group Policy ile kapat\u0131r."
      },
      {
        "Id": "Tweak_PeripheralBlock",
        "Recommended": false,
        "Preset": [],
        "Title": "Razer Synapse ve Logitech Download Assistant Otomatik Kurulumunu Engelle",
        "Desc": "Fare veya klavye tak\u0131ld\u0131\u011f\u0131nda Windows Update'in arka planda zorla Razer ve Logitech yaz\u0131l\u0131mlar\u0131n\u0131 indirmesini engeller."
      },
      {
        "Id": "Tweak_BlockAdobeNet",
        "Recommended": false,
        "Preset": [],
        "Title": "Adobe Telemetri ve Lisans Do\u011frulama Sunucular\u0131n\u0131 Engelle (Hosts Blocklist)",
        "Desc": "Hosts dosyas\u0131na Adobe telemetri engelleyici kurallar\u0131 ekleyerek arka plan a\u011f trafi\u011fini ve a\u00e7\u0131l\u0131r pencereleri durdurur."
      },
      {
        "Id": "Tweak_IPv4Prefer",
        "Recommended": false,
        "Preset": [],
        "Title": "IPv4 \u00d6nceli\u011fini Zorla ve Teredo T\u00fcnelini Kapat (D\u00fc\u015f\u00fck A\u011f Gecikmesi)",
        "Desc": "IPv6 yerine IPv4 kullan\u0131m\u0131na \u00f6ncelik verir (DisabledComponents=32) ve oyunlarda gecikme yaratan Teredo t\u00fcnellemesini kapat\u0131r."
      },
      {
        "Id": "Tweak_DisableIPv6",
        "Recommended": false,
        "Preset": [],
        "Title": "IPv6 Protokol\u00fcn\u00fc T\u00fcm A\u011f Ba\u011fda\u015ft\u0131r\u0131c\u0131lar\u0131nda Tamamen Devre D\u0131\u015f\u0131 B\u0131rak",
        "Desc": "Kay\u0131t defteri ve a\u011f ba\u011fda\u015ft\u0131r\u0131c\u0131s\u0131 ba\u011flamalar\u0131 (ms_tcpip6) \u00fczerinden IPv6 protokol\u00fcn\u00fc tamamen kapat\u0131r."
      },
      {
        "Id": "Tweak_DisableNotifications",
        "Recommended": false,
        "Preset": [],
        "Title": "Sistem Tepsisi Bildirim Merkezini ve RDP \u0130mzas\u0131z Dosya Uyar\u0131lar\u0131n\u0131 Kapat",
        "Desc": "Windows Bildirim Merkezi balonlar\u0131n\u0131 ve Uzak Masa\u00fcst\u00fc (RDP) ba\u011flant\u0131 uyar\u0131lar\u0131n\u0131 devre d\u0131\u015f\u0131 b\u0131rak\u0131r."
      },
      {
        "Id": "Tweak_NewOutlookBlock",
        "Recommended": true,
        "Preset": [
          "Standard",
          "Advanced"
        ],
        "Title": "Yeni Outlook (New Outlook) Otomatik G\u00f6\u00e7\u00fcn\u00fc ve Zorlamas\u0131n\u0131 Engelle",
        "Desc": "Klasik Posta/Outlook uygulamas\u0131n\u0131n zorla reklaml\u0131 Yeni Outlook'a d\u00f6n\u00fc\u015ft\u00fcr\u00fclmesini kay\u0131t defteri ilkeleriyle engeller."
      }
    ]
  }
]
'@ | ConvertFrom-Json

$sync.BloatwareConfig = @'
[
  {
    "Name": "Cortana Asistan",
    "Pkg": "*Microsoft.549981C3F5F10*",
    "StoreId": "9NFFX4SZZ23L",
    "DefaultCheck": true
  },
  {
    "Name": "Microsoft Haberler (Bing News)",
    "Pkg": "*Microsoft.BingNews*",
    "StoreId": "9WZDNCRFHVFW",
    "DefaultCheck": true
  },
  {
    "Name": "MSN Hava Durumu (Bing Weather)",
    "Pkg": "*Microsoft.BingWeather*",
    "StoreId": "9WZDNCRFJ3Q2",
    "DefaultCheck": true
  },
  {
    "Name": "Bing Web Arama Entegrasyonu",
    "Pkg": "*Microsoft.BingSearch*",
    "StoreId": "9NZBF4GT040C",
    "DefaultCheck": true
  },
  {
    "Name": "Microsoft Copilot (UWP)",
    "Pkg": "*Microsoft.Copilot*",
    "StoreId": "9NHT9RB2F4HD",
    "DefaultCheck": true
  },
  {
    "Name": "Ba\u015flat Deneyimleri ve Widget Beslemesi",
    "Pkg": "*Microsoft.StartExperiencesApp*",
    "StoreId": "9PC1H9VN18CM",
    "DefaultCheck": true
  },
  {
    "Name": "Microsoft Yard\u0131m Al (Get Help)",
    "Pkg": "*Microsoft.GetHelp*",
    "StoreId": "9PKDZBMV1H3T",
    "DefaultCheck": true
  },
  {
    "Name": "Windows \u0130pu\u00e7lar\u0131 (Tips / Getstarted)",
    "Pkg": "*Microsoft.Getstarted*",
    "StoreId": "9WZDNCRDTBJJ",
    "DefaultCheck": true
  },
  {
    "Name": "Geri Bildirim Merkezi (Feedback Hub)",
    "Pkg": "*Microsoft.WindowsFeedbackHub*",
    "StoreId": "9NBLGGH4R32N",
    "DefaultCheck": true
  },
  {
    "Name": "Microsoft 365 (Office Hub)",
    "Pkg": "*Microsoft.MicrosoftOfficeHub*",
    "StoreId": "9WZDNCRD29V9",
    "DefaultCheck": true
  },
  {
    "Name": "Yeni Outlook (Outlook for Windows)",
    "Pkg": "*Microsoft.OutlookForWindows*",
    "StoreId": "9NRX63209R7B",
    "DefaultCheck": true
  },
  {
    "Name": "Microsoft Teams (Ki\u015fisel / UWP)",
    "Pkg": "*MSTeams*",
    "StoreId": "XP8BT8DW290MPQ",
    "DefaultCheck": true
  },
  {
    "Name": "Microsoft Solitaire Collection",
    "Pkg": "*Microsoft.MicrosoftSolitaireCollection*",
    "StoreId": "9WZDNCRFHWD2",
    "DefaultCheck": true
  },
  {
    "Name": "Microsoft \u0130nsanlar (People)",
    "Pkg": "*Microsoft.People*",
    "StoreId": "9NBLGGH10PG8",
    "DefaultCheck": true
  },
  {
    "Name": "Windows Haritalar (Maps)",
    "Pkg": "*Microsoft.WindowsMaps*",
    "StoreId": "9WZDNCRDTBVB",
    "DefaultCheck": true
  },
  {
    "Name": "3D G\u00f6r\u00fcnt\u00fcleyici (3D Viewer)",
    "Pkg": "*Microsoft.Microsoft3DViewer*",
    "StoreId": "9NBLGGH42THS",
    "DefaultCheck": true
  },
  {
    "Name": "Mixed Reality Portal",
    "Pkg": "*Microsoft.MixedReality.Portal*",
    "StoreId": "9NG1H8B3ZC7M",
    "DefaultCheck": true
  },
  {
    "Name": "Skype (UWP)",
    "Pkg": "*Microsoft.SkypeApp*",
    "StoreId": "9WZDNCRFJ364",
    "DefaultCheck": true
  },
  {
    "Name": "Clipchamp Video Edit\u00f6r",
    "Pkg": "*Clipchamp.Clipchamp*",
    "StoreId": "9P1J8S7CCWWT",
    "DefaultCheck": true
  },
  {
    "Name": "Microsoft To-Do",
    "Pkg": "*Microsoft.Todos*",
    "StoreId": "9NBLGGH5R558",
    "DefaultCheck": true
  },
  {
    "Name": "Power Automate Desktop",
    "Pkg": "*Microsoft.PowerAutomateDesktop*",
    "StoreId": "9NFTCH6J7FHV",
    "DefaultCheck": true
  },
  {
    "Name": "Windows Dev Home (Geli\u015ftirici Merkezi)",
    "Pkg": "*Microsoft.Windows.DevHome*",
    "StoreId": "9N8MHTPHNGVV",
    "DefaultCheck": true
  },
  {
    "Name": "H\u0131zl\u0131 Yard\u0131m (Quick Assist)",
    "Pkg": "*MicrosoftCorporationII.QuickAssist*",
    "StoreId": "9P7BP5VNWKX5",
    "DefaultCheck": true
  },
  {
    "Name": "Microsoft Yap\u0131\u015fkan Notlar (Sticky Notes)",
    "Pkg": "*Microsoft.MicrosoftStickyNotes*",
    "StoreId": "9NBLGGH4QGHW",
    "DefaultCheck": true
  },
  {
    "Name": "Ses Kaydedicisi (Sound Recorder)",
    "Pkg": "*Microsoft.WindowsSoundRecorder*",
    "StoreId": "9WZDNCRFHWKN",
    "DefaultCheck": false
  },
  {
    "Name": "Windows Saat ve Alarm (Clock)",
    "Pkg": "*Microsoft.WindowsAlarms*",
    "StoreId": "9WZDNCRFJ3PR",
    "DefaultCheck": false
  },
  {
    "Name": "Zune M\u00fczik / Media Player",
    "Pkg": "*Microsoft.ZuneMusic*",
    "StoreId": "9WZDNCRFJ3PT",
    "DefaultCheck": true
  },
  {
    "Name": "Zune Film ve TV (Movies & TV)",
    "Pkg": "*Microsoft.ZuneVideo*",
    "StoreId": "9WZDNCRFJ3P2",
    "DefaultCheck": true
  },
  {
    "Name": "Telefon Ba\u011flant\u0131s\u0131 (Phone Link / Your Phone)",
    "Pkg": "*Microsoft.YourPhone*",
    "StoreId": "9NMPJ99VJBWV",
    "DefaultCheck": true
  },
  {
    "Name": "Mobil Cihazlar Arka Plan Ba\u011flant\u0131s\u0131 (CrossDevice)",
    "Pkg": "*MicrosoftWindows.CrossDevice*",
    "StoreId": "9NTXGKQ8P7N0",
    "DefaultCheck": false
  },
  {
    "Name": "Microsoft Aile G\u00fcvenli\u011fi (Family Safety)",
    "Pkg": "*MicrosoftCorporationII.MicrosoftFamily*",
    "StoreId": "9PDJDJS743XF",
    "DefaultCheck": true
  },
  {
    "Name": "Windows Kamera (Camera)",
    "Pkg": "*Microsoft.WindowsCamera*",
    "StoreId": "9WZDNCRFJBBG",
    "DefaultCheck": false
  },
  {
    "Name": "Windows Hesap Makinesi (Calculator)",
    "Pkg": "*Microsoft.WindowsCalculator*",
    "StoreId": "9WZDNCRFHVN5",
    "DefaultCheck": false
  },
  {
    "Name": "Windows Foto\u011fraflar (Modern Photos)",
    "Pkg": "*Microsoft.Windows.Photos*",
    "StoreId": "9WZDNCRFJBH4",
    "DefaultCheck": false
  },
  {
    "Name": "Ekran Al\u0131nt\u0131s\u0131 Arac\u0131 (Snipping Tool)",
    "Pkg": "*Microsoft.ScreenSketch*",
    "StoreId": "9MZ95KL8MR0L",
    "DefaultCheck": false
  },
  {
    "Name": "Modern Paint (UWP)",
    "Pkg": "*Microsoft.Paint*",
    "StoreId": "9PCFS5B6T72H",
    "DefaultCheck": false
  },
  {
    "Name": "Modern Notepad (UWP)",
    "Pkg": "*Microsoft.WindowsNotepad*",
    "StoreId": "9MSMLRH6LZF3",
    "DefaultCheck": false
  },
  {
    "Name": "Xbox Uygulamas\u0131 (GamingApp)",
    "Pkg": "*Microsoft.GamingApp*",
    "StoreId": "9MV0B5HZVK9Z",
    "DefaultCheck": false
  },
  {
    "Name": "Xbox Game Bar (GamingOverlay)",
    "Pkg": "*Microsoft.XboxGamingOverlay*",
    "StoreId": "9NZKPSTSNW4P",
    "DefaultCheck": false
  },
  {
    "Name": "Xbox Speech To Text Overlay",
    "Pkg": "*Microsoft.XboxSpeechToTextOverlay*",
    "StoreId": "",
    "DefaultCheck": false
  },
  {
    "Name": "Xbox Identity Provider (Dikkat: Xbox Giri\u015fi \u0130\u00e7in Gerekli)",
    "Pkg": "*Microsoft.XboxIdentityProvider*",
    "StoreId": "9WZDNCRD1HKW",
    "DefaultCheck": false
  },
  {
    "Name": "Xbox TCUI (Canl\u0131 Hesap Aray\u00fcz\u00fc)",
    "Pkg": "*Microsoft.Xbox.TCUI*",
    "StoreId": "",
    "DefaultCheck": false
  }
]
'@ | ConvertFrom-Json

$sync.Xaml = @'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Umut Evran Tool v4.0 - Ultimate WinUtil Edition (Sistem Kurulum ve Optimizasyon Merkezi)"
        Width="1320" Height="860" MinWidth="1080" MinHeight="720"
        WindowStartupLocation="CenterScreen" Background="{DynamicResource WindowBg}" Foreground="#F8FAFC"
        FontFamily="Segoe UI">
    <Window.Resources>
        <!-- Dinamik Renk Paletleri (Canli Tema Gecisi) -->
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
            <Setter Property="Padding" Value="11,7"/>
            <Setter Property="Margin" Value="0,0,0,4"/>
            <Setter Property="HorizontalContentAlignment" Value="Left"/>
            <Setter Property="FontSize" Value="12.5"/>
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
            <Setter Property="Padding" Value="12,8"/>
            <Setter Property="FontSize" Value="12"/>
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
            <ColumnDefinition Width="275"/>
            <ColumnDefinition Width="*"/>
            <ColumnDefinition Width="330"/>
        </Grid.ColumnDefinitions>

        <!-- SOL MENU PANELI -->
        <Border Grid.Column="0" Background="{DynamicResource PanelBg}" BorderBrush="{DynamicResource BorderBrushColor}" BorderThickness="0,0,1,0" Padding="12">
            <DockPanel LastChildFill="True">
                <StackPanel DockPanel.Dock="Bottom" Margin="0,8,0,0">
                    <Button x:Name="BtnRestorePoint" Style="{StaticResource ActionBtnStyle}" Background="{DynamicResource HoverBg}" Content="&#x1F6E1;&#xFE0F; Geri Y&#x00FC;kleme Noktas&#x0131; Olu&#x015F;tur" Margin="0,0,0,6"/>
                    <TextBlock x:Name="TxtSysInfo" Text="Y&#x00F6;netici Olarak &#x00C7;al&#x0131;&#x015F;&#x0131;yor" FontSize="11" Foreground="{DynamicResource TextDim}" HorizontalAlignment="Center" TextTrimming="CharacterEllipsis"/>
                </StackPanel>

                <ScrollViewer VerticalScrollBarVisibility="Auto">
                    <StackPanel>
                        <Border Background="{DynamicResource CardBg}" BorderBrush="{DynamicResource AccentColor}" BorderThickness="1.5" CornerRadius="8" Padding="11" Margin="0,0,0,10">
                            <StackPanel>
                                <TextBlock Text="&#x1F680; UMUT EVRAN TOOL" FontSize="16" FontWeight="Bold" Foreground="{DynamicResource AccentColor}"/>
                                <TextBlock Text="WinUtil %100 Full Entegre v4.0" FontSize="11" Foreground="{DynamicResource TextMuted}" Margin="0,2,0,0"/>
                            </StackPanel>
                        </Border>

                        <!-- MENULER (6 SEKME) -->
                        <TextBlock Text="MOD&#x00DC;LLER VE MEN&#x00DC;LER" FontSize="10.5" FontWeight="Bold" Foreground="{DynamicResource TextDim}" Margin="4,0,0,4"/>
                        <Button x:Name="BtnNavApps" Style="{StaticResource NavButtonStyle}" Content="&#x1F4E6;  Uygulama Kurulumu (248+)" Background="{DynamicResource ActiveBtnColor}" BorderBrush="{DynamicResource AccentColor}"/>
                        <Button x:Name="BtnNavTweaks" Style="{StaticResource NavButtonStyle}" Content="&#x26A1;  Sistem &amp; Geli&#x015F;mi&#x015F; Tweaks"/>
                        <Button x:Name="BtnNavFeatures" Style="{StaticResource NavButtonStyle}" Content="&#x1F6E0;&#xFE0F;  Windows &#x00D6;zellikleri &amp; DNS"/>
                        <Button x:Name="BtnNavBloatware" Style="{StaticResource NavButtonStyle}" Content="&#x1F9F9;  Bloatware &amp; UWP Tasfiyesi"/>
                        <Button x:Name="BtnNavTools" Style="{StaticResource NavButtonStyle}" Content="&#x1F9F0;  Sistem Ara&#x00E7;lar&#x0131; &amp; MAS"/>
                        <Button x:Name="BtnNavConfig" Style="{StaticResource NavButtonStyle}" Content="&#x1F4BE;  Yedekleme &amp; Config"/>

                        <!-- TEMA SECIMI BOLUMU (3 CANLI TEMA) -->
                        <TextBlock Text="TEMA SE&#x00C7;&#x0130;M&#x0130; (CANLI GE&#x00C7;&#x0130;&#x015E;)" FontSize="10.5" FontWeight="Bold" Foreground="{DynamicResource TextDim}" Margin="4,8,0,4"/>
                        <UniformGrid Columns="3" Margin="0,0,0,6">
                            <Button x:Name="BtnThemeOlive" Style="{StaticResource ActionBtnStyle}" Background="#4E664A" Content="&#x1F33F; Ye&#x015F;il" ToolTip="Askeri Ada&#x00E7;ay&#x0131; Ye&#x015F;ili" Padding="4,6" Margin="0,0,2,0" FontSize="11"/>
                            <Button x:Name="BtnThemeAmber" Style="{StaticResource ActionBtnStyle}" Background="#EA580C" Content="&#x26A1; Turuncu" ToolTip="Karbon &amp; Kehribar Turuncu" Padding="4,6" Margin="2,0,2,0" FontSize="11"/>
                            <Button x:Name="BtnThemeNeon" Style="{StaticResource ActionBtnStyle}" Background="#BE185D" Content="&#x1F52E; Neon" ToolTip="Siberpunk Neon Pembe" Padding="4,6" Margin="2,0,0,0" FontSize="11"/>
                        </UniformGrid>

                        <!-- HAZIR PAKETLER -->
                        <TextBlock Text="UYGULAMA PAKETLER&#x0130; (PRESETS)" FontSize="10.5" FontWeight="Bold" Foreground="{DynamicResource TextDim}" Margin="4,6,0,4"/>
                        <Button x:Name="BtnPresetUmut" Style="{StaticResource NavButtonStyle}" Content="&#x1F451;  Umut &#x00D6;zel Paketi Se&#x00E7;" BorderBrush="{DynamicResource AccentColor}"/>
                        <Button x:Name="BtnPresetGamer" Style="{StaticResource NavButtonStyle}" Content="&#x1F3AE;  Oyuncu Paketi Se&#x00E7;"/>
                        <Button x:Name="BtnPresetDev" Style="{StaticResource NavButtonStyle}" Content="&#x1F4BB;  Geli&#x015F;tirici Paketi Se&#x00E7;"/>
                        <Button x:Name="BtnPresetStandard" Style="{StaticResource NavButtonStyle}" Content="&#x2728;  Standart Kurulum Paketi"/>
                        <Button x:Name="BtnClearSelection" Style="{StaticResource NavButtonStyle}" Content="&#x1F504;  T&#x00FC;m Se&#x00E7;imleri Temizle"/>
                    </StackPanel>
                </ScrollViewer>
            </DockPanel>
        </Border>

        <!-- ORTA ANA ICERIK PANELI -->
        <Grid Grid.Column="1" Margin="14">
            <!-- SEKME 1: UYGULAMA KURULUMU (WINGET ENGINE) -->
            <Grid x:Name="ViewApps" Visibility="Visible">
                <Grid.RowDefinitions>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="*"/>
                    <RowDefinition Height="Auto"/>
                </Grid.RowDefinitions>

                <!-- Arama Bar -->
                <Border Grid.Row="0" Background="{DynamicResource CardBg}" BorderBrush="{DynamicResource BorderBrushColor}" BorderThickness="1" CornerRadius="8" Padding="10,6" Margin="0,0,0,8">
                    <DockPanel>
                        <TextBlock Text="&#x1F50D; Ara:" Foreground="{DynamicResource TextMuted}" VerticalAlignment="Center" FontWeight="SemiBold" Margin="4,0,10,0"/>
                        <Button x:Name="BtnClearSearch" DockPanel.Dock="Right" Content="Temizle" Background="{DynamicResource HoverBg}" Foreground="#E2E8F0" BorderThickness="0" Padding="10,4" Cursor="Hand" Margin="6,0,0,0"/>
                        <Button x:Name="BtnCheckInstalled" DockPanel.Dock="Right" Content="&#x1F4CB; Y&#x00FC;kl&#x00FC; Olanlar&#x0131; Tara" Background="{DynamicResource ActiveBtnColor}" Foreground="#FFFFFF" BorderThickness="0" Padding="10,4" Cursor="Hand" Margin="6,0,0,0" ToolTip="Sistemde kurulu olan uygulamalar&#x0131; tespit edip i&#x015F;aretler"/>
                        <TextBox x:Name="TxtSearch" Background="Transparent" Foreground="#F8FAFC" BorderThickness="0" FontSize="14" VerticalContentAlignment="Center" CaretBrush="{DynamicResource AccentColor}"/>
                    </DockPanel>
                </Border>

                <!-- Kategori Filtre Butonlari -->
                <WrapPanel x:Name="CategoryButtonPanel" Grid.Row="1" Margin="0,0,0,8"/>

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
                        <WrapPanel HorizontalAlignment="Right" DockPanel.Dock="Right">
                            <Button x:Name="BtnInstall" Style="{StaticResource ActionBtnStyle}" Background="{DynamicResource BtnInstallBg}" Content="&#x1F680; Se&#x00E7;ilenleri Kur (Winget)" Margin="0,0,8,0"/>
                            <Button x:Name="BtnUninstall" Style="{StaticResource ActionBtnStyle}" Background="{DynamicResource BtnUninstallBg}" Content="&#x1F5D1;&#xFE0F; Se&#x00E7;ilenleri Kald&#x0131;r" Margin="0,0,8,0"/>
                            <Button x:Name="BtnUpgradeSelected" Style="{StaticResource ActionBtnStyle}" Background="{DynamicResource ActiveBtnColor}" Content="&#x2B06;&#xFE0F; Se&#x00E7;ilenleri G&#x00FC;ncelle" Margin="0,0,8,0"/>
                            <Button x:Name="BtnUpgradeAll" Style="{StaticResource ActionBtnStyle}" Background="{DynamicResource BtnUpgradeBg}" Content="&#x1F504; T&#x00FC;m&#x00FC;n&#x00FC; G&#x00FC;ncelle (Upgrade All)"/>
                        </WrapPanel>
                    </DockPanel>
                </Border>
            </Grid>

            <!-- SEKME 2: SISTEM INCE AYARLARI VE GELISMIS TWEAKS (APPLY + UNDO DESTEGI ILE) -->
            <Grid x:Name="ViewTweaks" Visibility="Collapsed">
                <Grid.RowDefinitions>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="*"/>
                    <RowDefinition Height="Auto"/>
                </Grid.RowDefinitions>

                <Border Grid.Row="0" Background="{DynamicResource CardBg}" BorderBrush="{DynamicResource BorderBrushColor}" BorderThickness="1" CornerRadius="8" Padding="12" Margin="0,0,0,8">
                    <StackPanel>
                        <TextBlock Text="&#x26A1; Sistem &#x0130;nce Ayarlar&#x0131;, Oyun Performans&#x0131; ve Geli&#x015F;mi&#x015F; Tweaks (Uygula &amp; Geri Al)" FontSize="15.5" FontWeight="Bold" Foreground="{DynamicResource AccentColor}"/>
                        <TextBlock Text="WinUtil'deki t&#x00FC;m Essential, Gaming, UI ve Advanced Tweaks se&#x00E7;eneklerini tek t&#x0131;kla uygulayabilir veya Geri Al (Undo) butonuyla fabrika de&#x011F;erlerine d&#x00F6;nd&#x00FC;rebilirsiniz." FontSize="12" Foreground="{DynamicResource TextMuted}" Margin="0,3,0,0" TextWrapping="Wrap"/>
                    </StackPanel>
                </Border>

                <!-- WinUtil Tweak Preset Secicileri -->
                <Border Grid.Row="1" Background="{DynamicResource CardBg}" BorderBrush="{DynamicResource BorderBrushColor}" BorderThickness="1" CornerRadius="8" Padding="8" Margin="0,0,0,8">
                    <WrapPanel VerticalAlignment="Center">
                        <TextBlock Text="WinUtil Profilleri:" FontSize="12" FontWeight="Bold" Foreground="{DynamicResource AccentColor}" VerticalAlignment="Center" Margin="4,0,10,0"/>
                        <Button x:Name="BtnSelectRecTweaks" Style="{StaticResource ActionBtnStyle}" Background="{DynamicResource ActiveBtnColor}" Content="&#x2728; &#x00D6;nerilen (Recommended)" Padding="10,5" Margin="0,0,6,0"/>
                        <Button x:Name="BtnTweakPresetStandard" Style="{StaticResource ActionBtnStyle}" Background="{DynamicResource HoverBg}" Content="&#x1F5A5;&#xFE0F; WinUtil Standart (Masa&#x00FC;st&#x00FC;)" Padding="10,5" Margin="0,0,6,0"/>
                        <Button x:Name="BtnTweakPresetMinimal" Style="{StaticResource ActionBtnStyle}" Background="{DynamicResource HoverBg}" Content="&#x1F4BB; WinUtil Minimal (Laptop)" Padding="10,5" Margin="0,0,6,0"/>
                        <Button x:Name="BtnTweakPresetAdvanced" Style="{StaticResource ActionBtnStyle}" Background="{DynamicResource HoverBg}" Content="&#x1F525; WinUtil Geli&#x015F;mi&#x015F; (Tam)" Padding="10,5" Margin="0,0,6,0"/>
                        <Button x:Name="BtnClearTweaks" Style="{StaticResource ActionBtnStyle}" Background="{DynamicResource BorderBrushColor}" Content="Temizle" Padding="10,5"/>
                    </WrapPanel>
                </Border>

                <Border Grid.Row="2" Background="{DynamicResource PanelBg}" BorderBrush="{DynamicResource BorderBrushColor}" BorderThickness="1" CornerRadius="8" Padding="12">
                    <ScrollViewer VerticalScrollBarVisibility="Auto">
                        <StackPanel x:Name="TweaksStackPanel"/>
                    </ScrollViewer>
                </Border>

                <Border Grid.Row="3" Background="{DynamicResource CardBg}" BorderBrush="{DynamicResource BorderBrushColor}" BorderThickness="1" CornerRadius="8" Padding="12" Margin="0,10,0,0">
                    <WrapPanel HorizontalAlignment="Right">
                        <Button x:Name="BtnApplyTweaks" Style="{StaticResource ActionBtnStyle}" Background="{DynamicResource BtnInstallBg}" Content="&#x26A1; Se&#x00E7;ili Ayarlar&#x0131; Uygula (Apply)" Margin="0,0,8,0"/>
                        <Button x:Name="BtnUndoTweaks" Style="{StaticResource ActionBtnStyle}" Background="{DynamicResource BtnUninstallBg}" Content="&#x21A9;&#xFE0F; Se&#x00E7;ili Ayarlar&#x0131; Geri Al (Undo / Revert)" Margin="0,0,8,0"/>
                        <Button x:Name="BtnRevertContextMenu" Style="{StaticResource ActionBtnStyle}" Background="#D97706" Content="&#x267B;&#xFE0F; Sa&#x011F; T&#x0131;k Men&#x00FC;s&#x00FC;n&#x00FC; Varsay&#x0131;lana D&#x00F6;nd&#x00FC;r" Margin="0,0,8,0"/>
                        <Button x:Name="BtnCleanTemp" Style="{StaticResource ActionBtnStyle}" Background="{DynamicResource BtnUpgradeBg}" Content="&#x1F9F9; Disk, Temp &amp; DNS Temizle"/>
                    </WrapPanel>
                </Border>
            </Grid>

            <!-- SEKME 3: WINDOWS OZELLIKLERI (DISM), HIZLI DNS, DERIN TEMIZLIK & WINDOWS UPDATE -->
            <Grid x:Name="ViewFeatures" Visibility="Collapsed">
                <Grid.RowDefinitions>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="*"/>
                </Grid.RowDefinitions>

                <Border Grid.Row="0" Background="{DynamicResource CardBg}" BorderBrush="{DynamicResource BorderBrushColor}" BorderThickness="1" CornerRadius="8" Padding="12" Margin="0,0,0,8">
                    <StackPanel>
                        <TextBlock Text="&#x1F6E0;&#xFE0F; Windows &#x00D6;zellikleri (DISM), H&#x0131;zl&#x0131; DNS, Derin Temizlik ve Windows Update" FontSize="15.5" FontWeight="Bold" Foreground="{DynamicResource AccentColor}"/>
                        <TextBlock Text="DirectPlay, .NET 3.5, WSL2, Sandbox, Hyper-V, Telnet ve TFTP bile&#x015F;enlerini y&#x00F6;netin; tek t&#x0131;kla DNS de&#x011F;i&#x015F;tirin ve Windows Update politikas&#x0131;n&#x0131; belirleyin." FontSize="12" Foreground="{DynamicResource TextMuted}" Margin="0,3,0,0" TextWrapping="Wrap"/>
                    </StackPanel>
                </Border>

                <Border Grid.Row="1" Background="{DynamicResource PanelBg}" BorderBrush="{DynamicResource BorderBrushColor}" BorderThickness="1" CornerRadius="8" Padding="12">
                    <ScrollViewer VerticalScrollBarVisibility="Auto">
                        <StackPanel x:Name="FeaturesStackPanel">
                            <!-- 1. HIZLI DNS DEGISTIRICI -->
                            <Border Background="{DynamicResource CardBg}" BorderBrush="{DynamicResource BorderBrushColor}" BorderThickness="1" CornerRadius="8" Padding="12" Margin="0,0,0,10">
                                <StackPanel>
                                    <TextBlock Text="&#x1F310; HIZLI DNS DE&#x011E;&#x0130;&#x015E;T&#x0130;R&#x0130;C&#x0130; (F&#x0130;Z&#x0130;KSEL A&#x011E; BA&#x011E;DA&#x015E;TIRICISI OTOMAT&#x0130;K TESP&#x0130;T - IPv4 &amp; IPv6)" FontSize="13" FontWeight="Bold" Foreground="{DynamicResource AccentColor}" Margin="0,0,0,4"/>
                                    <TextBlock x:Name="TxtDnsStatus" Text="Aktif A&#x011F; Ba&#x011F;da&#x015F;t&#x0131;r&#x0131;c&#x0131;s&#x0131; Haz&#x0131;r (Sanal/VPN a&#x011F;lar&#x0131; hari&#x00E7; tutularak tek t&#x0131;kla DNS atan&#x0131;r)" FontSize="11.5" Foreground="{DynamicResource TextMuted}" Margin="0,0,0,8"/>
                                    <UniformGrid Columns="4" Margin="0,0,0,6">
                                        <Button x:Name="BtnDnsCloudflare" Style="{StaticResource ActionBtnStyle}" Background="{DynamicResource HoverBg}" Content="&#x26A1; Cloudflare (1.1.1.1)" Margin="0,0,4,0" ToolTip="1.1.1.1 / 1.0.0.1"/>
                                        <Button x:Name="BtnDnsGoogle" Style="{StaticResource ActionBtnStyle}" Background="{DynamicResource HoverBg}" Content="&#x1F310; Google (8.8.8.8)" Margin="2,0,2,0" ToolTip="8.8.8.8 / 8.8.4.4"/>
                                        <Button x:Name="BtnDnsAdguard" Style="{StaticResource ActionBtnStyle}" Background="{DynamicResource HoverBg}" Content="&#x1F6E1;&#xFE0F; AdGuard (94.140.14.14)" Margin="2,0,2,0" ToolTip="Reklam ve &#x0130;zleyici Engelleyici DNS (94.140.14.14 / 94.140.15.15)"/>
                                        <Button x:Name="BtnDnsQuad9" Style="{StaticResource ActionBtnStyle}" Background="{DynamicResource HoverBg}" Content="&#x1F512; Quad9 (9.9.9.9)" Margin="4,0,0,0" ToolTip="Zararl&#x0131; Yaz&#x0131;l&#x0131;m Engelleyici G&#x00FC;venlik DNS (9.9.9.9 / 149.112.112.112)"/>
                                    </UniformGrid>
                                    <UniformGrid Columns="3">
                                        <Button x:Name="BtnDnsCloudflareMalware" Style="{StaticResource ActionBtnStyle}" Background="{DynamicResource HoverBg}" Content="&#x1F6E1;&#xFE0F; Cloudflare G&#x00FC;venlik (1.1.1.2)" Margin="0,0,4,0" ToolTip="Zararl&#x0131; Yaz&#x0131;l&#x0131;m Engelleyici Cloudflare (1.1.1.2 / 1.0.0.2)"/>
                                        <Button x:Name="BtnDnsOpenDns" Style="{StaticResource ActionBtnStyle}" Background="{DynamicResource HoverBg}" Content="&#x1F4E1; Cisco OpenDNS (208.67.222.222)" Margin="2,0,2,0" ToolTip="208.67.222.222 / 208.67.220.220"/>
                                        <Button x:Name="BtnDnsDhcp" Style="{StaticResource ActionBtnStyle}" Background="{DynamicResource BorderBrushColor}" Content="&#x1F504; Varsay&#x0131;lan (Otomatik DHCP)" Margin="4,0,0,0" ToolTip="Otomatik modem/ISS DNS ayarlar&#x0131;na geri d&#x00F6;n"/>
                                    </UniformGrid>
                                </StackPanel>
                            </Border>

                            <!-- 2. DERIN TEMIZLIK & GELISMIS WINUTIL ARACLARI -->
                            <Border Background="{DynamicResource CardBg}" BorderBrush="{DynamicResource BorderBrushColor}" BorderThickness="1" CornerRadius="8" Padding="12" Margin="0,0,0,10">
                                <StackPanel>
                                    <TextBlock Text="&#x1F9F9; DER&#x0130;N TEM&#x0130;ZL&#x0130;K &amp; &#x0130;ZOLASYON MOD&#x00DC;LLER&#x0130; (DEEP DEBLOAT)" FontSize="13" FontWeight="Bold" Foreground="{DynamicResource AccentColor}" Margin="0,0,0,4"/>
                                    <TextBlock Text="OneDrive kal&#x0131;nt&#x0131;lar&#x0131;n&#x0131;, Windows 11 Copilot/Recall yapay zeka izlemesini ve Edge arka plan servislerini tek t&#x0131;kla y&#x00F6;netin:" FontSize="11.5" Foreground="{DynamicResource TextMuted}" Margin="0,0,0,8"/>
                                    <UniformGrid Columns="3" Margin="0,0,0,6">
                                        <Button x:Name="BtnDeepOneDrive" Style="{StaticResource ActionBtnStyle}" Background="{DynamicResource BtnUninstallBg}" Content="&#x1F5D1;&#xFE0F; OneDrive K&#x00F6;kten Kald&#x0131;r" Margin="0,0,4,0" ToolTip="OneDriveSetup /uninstall &#x00E7;al&#x0131;&#x015F;t&#x0131;r&#x0131;r ve Dosya Gezgini CLSID kay&#x0131;tlar&#x0131;n&#x0131; siler"/>
                                        <Button x:Name="BtnDisableCopilot" Style="{StaticResource ActionBtnStyle}" Background="{DynamicResource HoverBg}" Content="&#x1F6AB; Copilot &amp; Recall Kapat" Margin="2,0,2,0" ToolTip="Copilot, Recall ve Windows AI anl&#x0131;k g&#x00F6;r&#x00FC;nt&#x00FC; alma mekanizmalar&#x0131;n&#x0131; kapat&#x0131;r"/>
                                        <Button x:Name="BtnDisableEdgeBg" Style="{StaticResource ActionBtnStyle}" Background="{DynamicResource HoverBg}" Content="&#x1F6D1; Edge &#x0130;zolasyonu &amp; Debloat" Margin="4,0,0,0" ToolTip="Edge Startup Boost, arka plan servisleri ve 17 telemetri ilkesini kapat&#x0131;r"/>
                                    </UniformGrid>
                                    <UniformGrid Columns="3">
                                        <Button x:Name="BtnRestoreOneDrive" Style="{StaticResource ActionBtnStyle}" Background="{DynamicResource BorderBrushColor}" Content="&#x21A9;&#xFE0F; OneDrive Geri Y&#x00FC;kle" Margin="0,0,4,0" ToolTip="Winget &#x00FC;zerinden OneDrive'&#x0131; yeniden kurar ve servislerini a&#x00E7;ar"/>
                                        <Button x:Name="BtnEnableCopilot" Style="{StaticResource ActionBtnStyle}" Background="{DynamicResource BorderBrushColor}" Content="&#x21A9;&#xFE0F; Copilot &amp; AI Geri A&#x00E7;" Margin="2,0,2,0" ToolTip="Copilot ve Windows AI k&#x0131;s&#x0131;tlamalar&#x0131;n&#x0131; kald&#x0131;r&#x0131;r"/>
                                        <Button x:Name="BtnEnableEdgeBg" Style="{StaticResource ActionBtnStyle}" Background="{DynamicResource BorderBrushColor}" Content="&#x21A9;&#xFE0F; Edge &#x0130;lkelerini S&#x0131;f&#x0131;rla" Margin="4,0,0,0" ToolTip="Edge k&#x0131;s&#x0131;tlama ilkelerini varsay&#x0131;lana d&#x00F6;nd&#x00FC;r&#x00FC;r"/>
                                    </UniformGrid>
                                </StackPanel>
                            </Border>

                            <!-- 3. WINDOWS UPDATE AKILLI YONETIMI (3 MOD) -->
                            <Border Background="{DynamicResource CardBg}" BorderBrush="{DynamicResource BorderBrushColor}" BorderThickness="1" CornerRadius="8" Padding="12" Margin="0,0,0,10">
                                <StackPanel>
                                    <TextBlock Text="&#x1F504; WINDOWS UPDATE AKILLI Y&#x00D6;NET&#x0130;M&#x0130; (WINUTIL 3 MOD)" FontSize="13" FontWeight="Bold" Foreground="{DynamicResource AccentColor}" Margin="0,0,0,4"/>
                                    <TextBlock Text="1) G&#x00FC;venlik Odakl&#x0131; Mod (365 g&#x00FC;n &#x00F6;zellik erteleme, 4 g&#x00FC;n kalite erteleme, s&#x00FC;r&#x00FC;c&#x00FC; engeli), 2) Tamamen Kapatma, 3) Fabrika Varsay&#x0131;lan&#x0131;:" FontSize="11.5" Foreground="{DynamicResource TextMuted}" Margin="0,0,0,8"/>
                                    <UniformGrid Columns="3">
                                        <Button x:Name="BtnWinUpdateSecurity" Style="{StaticResource ActionBtnStyle}" Background="{DynamicResource BtnInstallBg}" Content="&#x1F6E1;&#xFE0F; 1. G&#x00FC;venlik Odakl&#x0131; Mod (&#x00D6;nerilen)" Margin="0,0,4,0" ToolTip="B&#x00FC;y&#x00FC;k s&#x00FC;r&#x00FC;m g&#x00FC;ncellemelerini 365 g&#x00FC;n geciktirir, s&#x00FC;r&#x00FC;c&#x00FC; g&#x00FC;ncellemelerini kapat&#x0131;r"/>
                                        <Button x:Name="BtnWinUpdateDisable" Style="{StaticResource ActionBtnStyle}" Background="{DynamicResource BtnUninstallBg}" Content="&#x26D4; 2. G&#x00FC;ncellemeleri Tamamen Durdur" Margin="2,0,2,0" ToolTip="wuauserv, bits, UsoSvc, dosvc servislerini ve zamanlanm&#x0131;&#x015F; g&#x00F6;revleri tamamen kapat&#x0131;r"/>
                                        <Button x:Name="BtnWinUpdateDefault" Style="{StaticResource ActionBtnStyle}" Background="{DynamicResource BorderBrushColor}" Content="&#x267B;&#xFE0F; 3. Varsay&#x0131;lan Mod (Fabrika Ayar&#x0131;)" Margin="4,0,0,0" ToolTip="T&#x00FC;m Windows Update ilkelerini ve servislerini standart fabrika de&#x011F;erlerine d&#x00F6;nd&#x00FC;r&#x00FC;r"/>
                                    </UniformGrid>
                                </StackPanel>
                            </Border>

                            <!-- 4. WINDOWS ISTEGE BAGLI BILESENLERI (DISM ENGINE) -->
                            <Border Background="{DynamicResource CardBg}" BorderBrush="{DynamicResource BorderBrushColor}" BorderThickness="1" CornerRadius="8" Padding="12">
                                <StackPanel>
                                    <DockPanel Margin="0,0,0,6">
                                        <TextBlock Text="&#x1F4BB; WINDOWS &#x0130;STE&#x011E;E BA&#x011E;LI B&#x0130;LE&#x015E;ENLER&#x0130; (DISM ENGINE)" FontSize="13" FontWeight="Bold" Foreground="{DynamicResource AccentColor}" VerticalAlignment="Center"/>
                                        <Button x:Name="BtnCheckFeaturesStatus" DockPanel.Dock="Right" Style="{StaticResource ActionBtnStyle}" Background="{DynamicResource HoverBg}" Content="&#x1F50D; Bile&#x015F;en Durumlar&#x0131;n&#x0131; Sorgula" Padding="10,4" FontSize="11.5"/>
                                    </DockPanel>
                                    <TextBlock Text="DirectPlay, .NET Framework 3.5, WSL 2, Virtual Machine Platform, Windows Sandbox, Hyper-V, Telnet ve TFTP bile&#x015F;enlerini y&#x00F6;netin:" FontSize="11.5" Foreground="{DynamicResource TextMuted}" Margin="0,0,0,8"/>
                                    <UniformGrid x:Name="FeaturesGrid" Columns="2" Margin="0,0,0,10"/>
                                    <StackPanel Orientation="Horizontal" HorizontalAlignment="Right">
                                        <Button x:Name="BtnApplyFeatures" Style="{StaticResource ActionBtnStyle}" Background="{DynamicResource BtnInstallBg}" Content="&#x2699;&#xFE0F; Se&#x00E7;ili Bile&#x015F;enleri Etkinle&#x015F;tir (DISM Enable)" Margin="0,0,8,0"/>
                                        <Button x:Name="BtnDisableFeatures" Style="{StaticResource ActionBtnStyle}" Background="{DynamicResource BtnUninstallBg}" Content="&#x1F6AB; Se&#x00E7;ili Bile&#x015F;enleri Devre D&#x0131;&#x015F;&#x0131; B&#x0131;rak (DISM Disable)"/>
                                    </StackPanel>
                                </StackPanel>
                            </Border>
                        </StackPanel>
                    </ScrollViewer>
                </Border>
            </Grid>

            <!-- SEKME 4: KAPSAMLI BLOATWARE TASFIYESI (42 UWP PAKETI) -->
            <Grid x:Name="ViewBloatware" Visibility="Collapsed">
                <Grid.RowDefinitions>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="*"/>
                    <RowDefinition Height="Auto"/>
                </Grid.RowDefinitions>

                <Border Grid.Row="0" Background="{DynamicResource CardBg}" BorderBrush="{DynamicResource BorderBrushColor}" BorderThickness="1" CornerRadius="8" Padding="12" Margin="0,0,0,8">
                    <StackPanel>
                        <TextBlock Text="&#x1F9F9; Kapsaml&#x0131; Windows Bloatware ve UWP Paket Tasfiyesi (WinUtil Appx Engine)" FontSize="15.5" FontWeight="Bold" Foreground="{DynamicResource AccentColor}"/>
                        <TextBlock Text="Se&#x00E7;ilen UWP paketlerini hem ge&#x00E7;erli kullan&#x0131;c&#x0131; (Get-AppxPackage -AllUsers) hem de yeni kullan&#x0131;c&#x0131; provizyon kay&#x0131;tlar&#x0131;ndan (Get-AppxProvisionedPackage -Online) tamamen kald&#x0131;r&#x0131;r veya Microsoft Store'dan geri y&#x00FC;kler." FontSize="12" Foreground="{DynamicResource TextMuted}" Margin="0,3,0,0" TextWrapping="Wrap"/>
                    </StackPanel>
                </Border>

                <Border Grid.Row="1" Background="{DynamicResource PanelBg}" BorderBrush="{DynamicResource BorderBrushColor}" BorderThickness="1" CornerRadius="8" Padding="12">
                    <ScrollViewer VerticalScrollBarVisibility="Auto">
                        <UniformGrid x:Name="BloatwareGrid" Columns="2"/>
                    </ScrollViewer>
                </Border>

                <Border Grid.Row="2" Background="{DynamicResource CardBg}" BorderBrush="{DynamicResource BorderBrushColor}" BorderThickness="1" CornerRadius="8" Padding="12" Margin="0,10,0,0">
                    <DockPanel>
                        <WrapPanel VerticalAlignment="Center">
                            <Button x:Name="BtnSelectDefaultBloat" Style="{StaticResource ActionBtnStyle}" Background="{DynamicResource ActiveBtnColor}" Content="&#x2728; &#x00D6;nerilen Bloatware Se&#x00E7;" Margin="0,0,6,0"/>
                            <Button x:Name="BtnSelectAllBloat" Style="{StaticResource ActionBtnStyle}" Background="{DynamicResource HoverBg}" Content="T&#x00FC;m&#x00FC;n&#x00FC; Se&#x00E7;" Margin="0,0,6,0"/>
                            <Button x:Name="BtnClearBloat" Style="{StaticResource ActionBtnStyle}" Background="{DynamicResource BorderBrushColor}" Content="Se&#x00E7;imi Temizle"/>
                        </WrapPanel>
                        <WrapPanel HorizontalAlignment="Right" DockPanel.Dock="Right">
                            <Button x:Name="BtnReinstallBloatware" Style="{StaticResource ActionBtnStyle}" Background="{DynamicResource BtnInstallBg}" Content="&#x1F4E5; Se&#x00E7;ilenleri Ma&#x011F;azadan Geri Y&#x00FC;kle" Margin="0,0,8,0"/>
                            <Button x:Name="BtnRemoveBloatware" Style="{StaticResource ActionBtnStyle}" Background="{DynamicResource BtnUninstallBg}" Content="&#x1F5D1;&#xFE0F; Se&#x00E7;ili Bloatware Paketlerini Kald&#x0131;r"/>
                        </WrapPanel>
                    </DockPanel>
                </Border>
            </Grid>

            <!-- SEKME 5: SISTEM YARDIMCI ARACLARI, ONARIM & MAS AKTIVASYON -->
            <Grid x:Name="ViewTools" Visibility="Collapsed">
                <Grid.RowDefinitions>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="*"/>
                </Grid.RowDefinitions>

                <Border Grid.Row="0" Background="{DynamicResource CardBg}" BorderBrush="{DynamicResource BorderBrushColor}" BorderThickness="1" CornerRadius="8" Padding="12" Margin="0,0,0,8">
                    <StackPanel>
                        <TextBlock Text="&#x1F9F0; Sistem Yard&#x0131;mc&#x0131; Ara&#x00E7;lar&#x0131;, MAS Aktivasyon, Onar&#x0131;m ve Klasik Konsollar" FontSize="15.5" FontWeight="Bold" Foreground="{DynamicResource AccentColor}"/>
                        <TextBlock Text="God Mode, Microsoft Activation Scripts (MAS), SFC/DISM Sistem Onar&#x0131;m&#x0131;, Windows Update S&#x0131;f&#x0131;rlama ve Klasik Windows Y&#x00F6;netim Panellerine tek t&#x0131;kla eri&#x015F;in." FontSize="12" Foreground="{DynamicResource TextMuted}" Margin="0,3,0,0" TextWrapping="Wrap"/>
                    </StackPanel>
                </Border>

                <Border Grid.Row="1" Background="{DynamicResource PanelBg}" BorderBrush="{DynamicResource BorderBrushColor}" BorderThickness="1" CornerRadius="8" Padding="12">
                    <ScrollViewer VerticalScrollBarVisibility="Auto">
                        <StackPanel>
                            <!-- 1. MAS AKTIVASYON & GOD MODE & O&O SHUTUP10 -->
                            <Border Background="{DynamicResource CardBg}" BorderBrush="{DynamicResource AccentColor}" BorderThickness="1.5" CornerRadius="8" Padding="12" Margin="0,0,0,10">
                                <StackPanel>
                                    <TextBlock Text="&#x1F511; AKT&#x0130;VASYON DESTE&#x011E;&#x0130;, GOD MODE VE &#x00D6;ZEL YARDIMCI ARA&#x00C7;LAR" FontSize="13" FontWeight="Bold" Foreground="{DynamicResource AccentColor}" Margin="0,0,0,4"/>
                                    <TextBlock Text="A&#x00E7;&#x0131;k kaynakl&#x0131; Microsoft Activation Scripts (MAS), Masa&#x00FC;st&#x00FC; God Mode (Tanr&#x0131; Modu) klas&#x00F6;r&#x00FC; ve O&amp;O ShutUp10++ gizlilik arac&#x0131;:" FontSize="11.5" Foreground="{DynamicResource TextMuted}" Margin="0,0,0,8"/>
                                    <UniformGrid Columns="3">
                                        <Button x:Name="BtnRunMAS" Style="{StaticResource ActionBtnStyle}" Background="{DynamicResource BtnInstallBg}" Content="&#x1F511; MAS Aktivasyon &#x00C7;al&#x0131;&#x015F;t&#x0131;r (get.mas.dev)" Margin="0,0,4,0" ToolTip="irm https://get.mas.dev | iex komutunu &#x00E7;al&#x0131;&#x015F;t&#x0131;r&#x0131;r"/>
                                        <Button x:Name="BtnCreateGodMode" Style="{StaticResource ActionBtnStyle}" Background="{DynamicResource ActiveBtnColor}" Content="&#x26A1; Masa&#x00FC;st&#x00FC;nde God Mode Olu&#x015F;tur" Margin="2,0,2,0" ToolTip="GodMode.{ED7BA470-8E54-465E-825C-99712043E01C} klas&#x00F6;r&#x00FC;n&#x00FC; masa&#x00FC;st&#x00FC;nde olu&#x015F;turur"/>
                                        <Button x:Name="BtnRunOOSU" Style="{StaticResource ActionBtnStyle}" Background="{DynamicResource HoverBg}" Content="&#x1F6E1;&#xFE0F; O&amp;O ShutUp10++ &#x0130;ndir ve A&#x00E7;" Margin="4,0,0,0" ToolTip="Resmi O&amp;O ShutUp10++ ta&#x015F;&#x0131;nabilir arac&#x0131;n&#x0131; indirip ba&#x015F;lat&#x0131;r"/>
                                    </UniformGrid>
                                </StackPanel>
                            </Border>

                            <!-- 2. WINUTIL SISTEM ONARIM VE KURTARMA MOTORU (FIXES) -->
                            <Border Background="{DynamicResource CardBg}" BorderBrush="{DynamicResource BorderBrushColor}" BorderThickness="1" CornerRadius="8" Padding="12" Margin="0,0,0,10">
                                <StackPanel>
                                    <TextBlock Text="&#x1FA7A; S&#x0130;STEM ONARIM, KURTARMA VE SIFIRLAMA ARA&#x00C7;LARI (WINUTIL FIXES)" FontSize="13" FontWeight="Bold" Foreground="{DynamicResource AccentColor}" Margin="0,0,0,4"/>
                                    <TextBlock Text="Bozuk sistem dosyalar&#x0131;n&#x0131; (SFC / DISM), bozuk Windows Update bile&#x015F;enlerini, a&#x011F; y&#x0131;&#x011F;&#x0131;n&#x0131;n&#x0131; ve Winget paket y&#x00F6;neticisini onar&#x0131;n:" FontSize="11.5" Foreground="{DynamicResource TextMuted}" Margin="0,0,0,8"/>
                                    <UniformGrid Columns="3" Margin="0,0,0,6">
                                        <Button x:Name="BtnFixSystemCorruption" Style="{StaticResource ActionBtnStyle}" Background="{DynamicResource BtnInstallBg}" Content="&#x1FA7A; Sistem Bozulma Taramas&#x0131; (Chkdsk+SFC+DISM)" Margin="0,0,4,0" ToolTip="S&#x0131;ras&#x0131;yla chkdsk /scan, sfc /scannow ve DISM /RestoreHealth &#x00E7;al&#x0131;&#x015F;t&#x0131;r&#x0131;r"/>
                                        <Button x:Name="BtnFixWinUpdate" Style="{StaticResource ActionBtnStyle}" Background="{DynamicResource BtnUpgradeBg}" Content="&#x1F504; Windows Update Tam S&#x0131;f&#x0131;rlama &amp; Onar&#x0131;m" Margin="2,0,2,0" ToolTip="Update servislerini, Catroot2/SoftwareDistribution klas&#x00F6;rlerini ve 36 DLL kayd&#x0131;n&#x0131; s&#x0131;f&#x0131;rlar"/>
                                        <Button x:Name="BtnFixNetwork" Style="{StaticResource ActionBtnStyle}" Background="{DynamicResource HoverBg}" Content="&#x1F310; A&#x011F; Y&#x0131;&#x011F;&#x0131;n&#x0131;n&#x0131; S&#x0131;f&#x0131;rla (Winsock &amp; IP Reset)" Margin="4,0,0,0" ToolTip="netsh winsock reset, netsh int ip reset ve DNS temizli&#x011F;i yapar"/>
                                    </UniformGrid>
                                    <UniformGrid Columns="3">
                                        <Button x:Name="BtnFixWinget" Style="{StaticResource ActionBtnStyle}" Background="{DynamicResource HoverBg}" Content="&#x1F4E6; WinGet Paket Y&#x00F6;neticisini Onar" Margin="0,0,4,0" ToolTip="AppInstaller / Winget kaynaklar&#x0131;n&#x0131; ve kay&#x0131;tlar&#x0131;n&#x0131; onar&#x0131;r"/>
                                        <Button x:Name="BtnFixNTP" Style="{StaticResource ActionBtnStyle}" Background="{DynamicResource HoverBg}" Content="&#x23F1;&#xFE0F; NTP Saat Sunucusunu Onar (pool.ntp.org)" Margin="2,0,2,0" ToolTip="Windows saat senkronizasyon sunucusunu pool.ntp.org olarak yap&#x0131;land&#x0131;r&#x0131;r"/>
                                        <Button x:Name="BtnRunAutologon" Style="{StaticResource ActionBtnStyle}" Background="{DynamicResource HoverBg}" Content="&#x1F513; Sysinternals AutoLogon &#x0130;ndir ve A&#x00E7;" Margin="4,0,0,0" ToolTip="Microsoft Sysinternals AutoLogon arac&#x0131;n&#x0131; indirip ba&#x015F;lat&#x0131;r"/>
                                    </UniformGrid>
                                </StackPanel>
                            </Border>

                            <!-- 3. GELISMIS SISTEM KISAYOLLARI, OPENSSH & KAYIT DEFTERI YEDEGI -->
                            <Border Background="{DynamicResource CardBg}" BorderBrush="{DynamicResource BorderBrushColor}" BorderThickness="1" CornerRadius="8" Padding="12" Margin="0,0,0,10">
                                <StackPanel>
                                    <TextBlock Text="&#x2699;&#xFE0F; UZAKTAN ER&#x0130;&#x015E;&#x0130;M, &#x00D6;NY&#x00DC;KLEME (F8) VE S&#x0130;STEM G&#x00D6;REVLER&#x0130;" FontSize="13" FontWeight="Bold" Foreground="{DynamicResource AccentColor}" Margin="0,0,0,4"/>
                                    <UniformGrid Columns="3" Margin="0,0,0,6">
                                        <Button x:Name="BtnEnableOpenSSH" Style="{StaticResource ActionBtnStyle}" Background="{DynamicResource HoverBg}" Content="&#x1F5A7; OpenSSH Sunucusunu Kur ve Ba&#x015F;lat" Margin="0,0,4,0" ToolTip="OpenSSH Server kurar, Port 22 g&#x00FC;venlik duvar&#x0131; kural&#x0131;n&#x0131; a&#x00E7;ar ve sshd servisini ba&#x015F;lat&#x0131;r"/>
                                        <Button x:Name="BtnEnableRegBackup" Style="{StaticResource ActionBtnStyle}" Background="{DynamicResource HoverBg}" Content="&#x1F5C2;&#xFE0F; G&#x00FC;nl&#x00FC;k Kay&#x0131;t Defteri Yede&#x011F;ini A&#x00E7; (00:30)" Margin="2,0,2,0" ToolTip="RegIdleBackup g&#x00F6;revini her gece 00:30'da otomatik &#x00E7;al&#x0131;&#x015F;acak &#x015F;ekilde etkinle&#x015F;tirir"/>
                                        <Button x:Name="BtnRestartExplorer" Style="{StaticResource ActionBtnStyle}" Background="{DynamicResource HoverBg}" Content="&#x1F504; Dosya Gezgini'ni (Explorer) Yeniden Ba&#x015F;lat" Margin="4,0,0,0" ToolTip="explorer.exe s&#x00FC;recini g&#x00FC;venli bi&#x00E7;imde yeniden ba&#x015F;lat&#x0131;r"/>
                                    </UniformGrid>
                                    <UniformGrid Columns="2">
                                        <Button x:Name="BtnEnableF8Boot" Style="{StaticResource ActionBtnStyle}" Background="{DynamicResource HoverBg}" Content="&#x1F6E0;&#xFE0F; Klasik F8 G&#x00FC;venli Mod &#x00D6;ny&#x00FC;kleme Men&#x00FC;s&#x00FC;n&#x00FC; A&#x00E7;" Margin="0,0,4,0" ToolTip="bcdedit /set bootmenupolicy legacy"/>
                                        <Button x:Name="BtnDisableF8Boot" Style="{StaticResource ActionBtnStyle}" Background="{DynamicResource BorderBrushColor}" Content="&#x21A9;&#xFE0F; Standart Modern &#x00D6;ny&#x00FC;kleme Men&#x00FC;s&#x00FC;ne D&#x00F6;n" Margin="4,0,0,0" ToolTip="bcdedit /set bootmenupolicy standard"/>
                                    </UniformGrid>
                                </StackPanel>
                            </Border>

                            <!-- 4. KLASIK WINDOWS DENETIM MASASI VE YONETIM KONSOLLARI (14 PANEL) -->
                            <Border Background="{DynamicResource CardBg}" BorderBrush="{DynamicResource BorderBrushColor}" BorderThickness="1" CornerRadius="8" Padding="12">
                                <StackPanel>
                                    <TextBlock Text="&#x1F5A5;&#xFE0F; KLAS&#x0130;K WINDOWS DENET&#x0130;M MASASI VE S&#x0130;STEM KONSOLLARI (LEGACY PANELS)" FontSize="13" FontWeight="Bold" Foreground="{DynamicResource AccentColor}" Margin="0,0,0,4"/>
                                    <TextBlock Text="Windows 11'de gizlenen klasik y&#x00F6;netim ara&#x00E7;lar&#x0131;n&#x0131; do&#x011F;rudan ba&#x015F;lat&#x0131;n:" FontSize="11.5" Foreground="{DynamicResource TextMuted}" Margin="0,0,0,8"/>
                                    <UniformGrid Columns="4" Margin="0,0,0,6">
                                        <Button x:Name="BtnPanelControl" Style="{StaticResource ActionBtnStyle}" Background="{DynamicResource HoverBg}" Content="&#x1F39B;&#xFE0F; Denetim Masas&#x0131; (control)" Margin="0,0,4,0"/>
                                        <Button x:Name="BtnPanelNetwork" Style="{StaticResource ActionBtnStyle}" Background="{DynamicResource HoverBg}" Content="&#x1F310; A&#x011F; Ba&#x011F;lant&#x0131;lar&#x0131; (ncpa.cpl)" Margin="2,0,2,0"/>
                                        <Button x:Name="BtnPanelSystem" Style="{StaticResource ActionBtnStyle}" Background="{DynamicResource HoverBg}" Content="&#x1F4BB; Sistem &#x00D6;zellikleri (sysdm.cpl)" Margin="2,0,2,0"/>
                                        <Button x:Name="BtnPanelPower" Style="{StaticResource ActionBtnStyle}" Background="{DynamicResource HoverBg}" Content="&#x1F50B; G&#x00FC;&#x00E7; Se&#x00E7;enekleri (powercfg.cpl)" Margin="4,0,0,0"/>
                                    </UniformGrid>
                                    <UniformGrid Columns="4" Margin="0,0,0,6">
                                        <Button x:Name="BtnPanelSound" Style="{StaticResource ActionBtnStyle}" Background="{DynamicResource HoverBg}" Content="&#x1F50A; Ses Ayarlar&#x0131; (mmsys.cpl)" Margin="0,0,4,0"/>
                                        <Button x:Name="BtnPanelPrograms" Style="{StaticResource ActionBtnStyle}" Background="{DynamicResource HoverBg}" Content="&#x1F4E6; Program Ekle/Kald&#x0131;r (appwiz.cpl)" Margin="2,0,2,0"/>
                                        <Button x:Name="BtnPanelComputer" Style="{StaticResource ActionBtnStyle}" Background="{DynamicResource HoverBg}" Content="&#x2699;&#xFE0F; Bilgisayar Y&#x00F6;netimi (compmgmt)" Margin="2,0,2,0"/>
                                        <Button x:Name="BtnPanelMouse" Style="{StaticResource ActionBtnStyle}" Background="{DynamicResource HoverBg}" Content="&#x1F5B1;&#xFE0F; Fare &#x00D6;zellikleri (main.cpl)" Margin="4,0,0,0"/>
                                    </UniformGrid>
                                    <UniformGrid Columns="4">
                                        <Button x:Name="BtnPanelFirewall" Style="{StaticResource ActionBtnStyle}" Background="{DynamicResource HoverBg}" Content="&#x1F9F1; G&#x00FC;venlik Duvar&#x0131; (firewall.cpl)" Margin="0,0,4,0"/>
                                        <Button x:Name="BtnPanelRestore" Style="{StaticResource ActionBtnStyle}" Background="{DynamicResource HoverBg}" Content="&#x23EA; Sistem Geri Y&#x00FC;kleme (rstrui)" Margin="2,0,2,0"/>
                                        <Button x:Name="BtnPanelTimedate" Style="{StaticResource ActionBtnStyle}" Background="{DynamicResource HoverBg}" Content="&#x1F552; Tarih ve Saat (timedate.cpl)" Margin="2,0,2,0"/>
                                        <Button x:Name="BtnPanelRegion" Style="{StaticResource ActionBtnStyle}" Background="{DynamicResource HoverBg}" Content="&#x1F30D; B&#x00F6;lge ve Dil (intl.cpl)" Margin="4,0,0,0"/>
                                    </UniformGrid>
                                </StackPanel>
                            </Border>
                        </StackPanel>
                    </ScrollViewer>
                </Border>
            </Grid>

            <!-- SEKME 6: YEDEKLEME & CONFIG -->
            <Grid x:Name="ViewConfig" Visibility="Collapsed">
                <StackPanel>
                    <Border Background="{DynamicResource CardBg}" BorderBrush="{DynamicResource BorderBrushColor}" BorderThickness="1" CornerRadius="8" Padding="16" Margin="0,0,0,12">
                        <StackPanel>
                            <TextBlock Text="&#x1F4BE; Yap&#x0131;land&#x0131;rma Yedekleme (JSON D&#x0131;&#x015F;a / &#x0130;&#x00E7;e Aktar - WinUtil &amp; UmutEvranTool)" FontSize="16" FontWeight="Bold" Foreground="{DynamicResource AccentColor}"/>
                            <TextBlock Text="Se&#x00E7;ti&#x011F;iniz uygulama, sistem ince ayarlar&#x0131; (Tweaks), Windows bile&#x015F;enleri (DISM) ve Bloatware listesini JSON dosyas&#x0131; olarak kaydedebilir, ba&#x015F;ka bir bilgisayarda tek t&#x0131;kla geri y&#x00FC;kleyebilirsiniz." FontSize="13" Foreground="{DynamicResource TextMuted}" Margin="0,6,0,14" TextWrapping="Wrap"/>
                            <WrapPanel>
                                <Button x:Name="BtnExportConfig" Style="{StaticResource ActionBtnStyle}" Background="{DynamicResource BtnInstallBg}" Content="&#x1F4E4; Se&#x00E7;imleri JSON Olarak D&#x0131;&#x015F;a Aktar (Export)" Margin="0,0,10,0"/>
                                <Button x:Name="BtnImportConfig" Style="{StaticResource ActionBtnStyle}" Background="{DynamicResource BtnUpgradeBg}" Content="&#x1F4C2; JSON Yap&#x0131;land&#x0131;rma Dosyas&#x0131; &#x0130;&#x00E7;e Aktar (Import)" Margin="0,0,10,0"/>
                                <Button x:Name="BtnExportSysReport" Style="{StaticResource ActionBtnStyle}" Background="{DynamicResource HoverBg}" Content="&#x1F4CA; Sistem Donan&#x0131;m &amp; Ortam Raporu Kaydet"/>
                            </WrapPanel>
                        </StackPanel>
                    </Border>

                    <Border Background="{DynamicResource CardBg}" BorderBrush="{DynamicResource BorderBrushColor}" BorderThickness="1" CornerRadius="8" Padding="16">
                        <StackPanel>
                            <TextBlock Text="&#x1F4BB; Uzaktan Tek Sat&#x0131;rla &#x00C7;al&#x0131;&#x015F;t&#x0131;rma Komutu (Cloudflare Worker)" FontSize="16" FontWeight="Bold" Foreground="{DynamicResource AccentColor}"/>
                            <TextBlock Text="Windows PowerShell konsolunda kurulum yapmadan do&#x011F;rudan bellekte &#x00E7;al&#x0131;&#x015F;t&#x0131;rmak i&#x00E7;in a&#x015F;a&#x011F;&#x0131;daki komutu kullanabilirsiniz:" FontSize="13" Foreground="{DynamicResource TextMuted}" Margin="0,6,0,10"/>
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
# UMUT EVRAN TOOL v4.0 - CANLI TEMA VE TAM WINUTIL MOTORU (100% PURE ASCII)
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
            "Guru3D.Afterburner", "Playnite.Playnite", "PrismLauncher.PrismLauncher",
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
        Write-Host "[+] CLI Preset Kurulumu Baslatiliyor: $presetArg" -ForegroundColor Cyan
        foreach ($id in $cliIds) {
            Write-Host " -> Kuruluyor: $id" -ForegroundColor Yellow
            try {
                winget install --id $id -e --silent --accept-package-agreements --accept-source-agreements
            } catch {
                Write-Warning "Kurulum hatasi ($id): $($_.Exception.Message)"
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

# --- Gomulu Tema Verileri (3 Canli Tema Paleti) ---
$script:ThemesData = @'
{
  "olive": {
    "Name": "Askeri Ada\u00E7ay\u0131 Ye\u015Fili",
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
    "BtnInstallBg": "#588157",
    "BtnUninstallBg": "#8B4B4B",
    "BtnUpgradeBg": "#3A5A40"
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
    "BtnInstallBg": "#10B981",
    "BtnUninstallBg": "#EF4444",
    "BtnUpgradeBg": "#EA580C"
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
    "BtnInstallBg": "#10B981",
    "BtnUninstallBg": "#EF4444",
    "BtnUpgradeBg": "#7C3AED"
  }
}
'@ | ConvertFrom-Json

$script:AppCategories = $sync.AppsConfig
$script:FeaturesData  = $sync.FeaturesConfig
$script:TweaksData    = $sync.TweaksConfig
$script:BloatwareData = $sync.BloatwareConfig

# --- XAML Penceresini Yukle ---
$cleanXaml = $sync.Xaml.TrimStart([char]0xFEFF).Trim()
$script:window = [System.Windows.Markup.XamlReader]::Parse($cleanXaml)
$sync.Window = $script:window

# --- Kontrolleri Bagla ---
$script:ViewApps      = $script:window.FindName("ViewApps")
$script:ViewTweaks    = $script:window.FindName("ViewTweaks")
$script:ViewFeatures  = $script:window.FindName("ViewFeatures")
$script:ViewBloatware = $script:window.FindName("ViewBloatware")
$script:ViewTools     = $script:window.FindName("ViewTools")
$script:ViewConfig    = $script:window.FindName("ViewConfig")

$script:BtnNavApps      = $script:window.FindName("BtnNavApps")
$script:BtnNavTweaks    = $script:window.FindName("BtnNavTweaks")
$script:BtnNavFeatures  = $script:window.FindName("BtnNavFeatures")
$script:BtnNavBloatware = $script:window.FindName("BtnNavBloatware")
$script:BtnNavTools     = $script:window.FindName("BtnNavTools")
$script:BtnNavConfig    = $script:window.FindName("BtnNavConfig")

# Tema Butonlari
$script:BtnThemeOlive = $script:window.FindName("BtnThemeOlive")
$script:BtnThemeAmber = $script:window.FindName("BtnThemeAmber")
$script:BtnThemeNeon  = $script:window.FindName("BtnThemeNeon")

# Sol Panel Preset ve Geri Yukleme Butonlari
$script:BtnPresetUmut     = $script:window.FindName("BtnPresetUmut")
$script:BtnPresetGamer    = $script:window.FindName("BtnPresetGamer")
$script:BtnPresetDev      = $script:window.FindName("BtnPresetDev")
$script:BtnPresetStandard = $script:window.FindName("BtnPresetStandard")
$script:BtnClearSelection = $script:window.FindName("BtnClearSelection")
$script:BtnRestorePoint   = $script:window.FindName("BtnRestorePoint")

# Sekme 1: Uygulama Kurulumu Kontrolleri
$script:TxtSearch           = $script:window.FindName("TxtSearch")
$script:BtnClearSearch      = $script:window.FindName("BtnClearSearch")
$script:BtnCheckInstalled   = $script:window.FindName("BtnCheckInstalled")
$script:CategoryButtonPanel = $script:window.FindName("CategoryButtonPanel")
$script:MainStackPanel      = $script:window.FindName("MainStackPanel")
$script:TxtSelectedCount    = $script:window.FindName("TxtSelectedCount")
$script:BtnInstall          = $script:window.FindName("BtnInstall")
$script:BtnUninstall        = $script:window.FindName("BtnUninstall")
$script:BtnUpgradeSelected  = $script:window.FindName("BtnUpgradeSelected")
$script:BtnUpgradeAll       = $script:window.FindName("BtnUpgradeAll")

# Sekme 2: Tweaks Kontrolleri
$script:TweaksStackPanel       = $script:window.FindName("TweaksStackPanel")
$script:BtnSelectRecTweaks     = $script:window.FindName("BtnSelectRecTweaks")
$script:BtnTweakPresetStandard = $script:window.FindName("BtnTweakPresetStandard")
$script:BtnTweakPresetMinimal  = $script:window.FindName("BtnTweakPresetMinimal")
$script:BtnTweakPresetAdvanced = $script:window.FindName("BtnTweakPresetAdvanced")
$script:BtnClearTweaks         = $script:window.FindName("BtnClearTweaks")
$script:BtnApplyTweaks         = $script:window.FindName("BtnApplyTweaks")
$script:BtnUndoTweaks          = $script:window.FindName("BtnUndoTweaks")
$script:BtnRevertContextMenu   = $script:window.FindName("BtnRevertContextMenu")
$script:BtnCleanTemp           = $script:window.FindName("BtnCleanTemp")

# Sekme 3: Windows Ozellikleri, DNS, Derin Temizlik & Update Kontrolleri
$script:TxtDnsStatus            = $script:window.FindName("TxtDnsStatus")
$script:BtnDnsCloudflare        = $script:window.FindName("BtnDnsCloudflare")
$script:BtnDnsGoogle            = $script:window.FindName("BtnDnsGoogle")
$script:BtnDnsAdguard           = $script:window.FindName("BtnDnsAdguard")
$script:BtnDnsQuad9             = $script:window.FindName("BtnDnsQuad9")
$script:BtnDnsCloudflareMalware = $script:window.FindName("BtnDnsCloudflareMalware")
$script:BtnDnsOpenDns           = $script:window.FindName("BtnDnsOpenDns")
$script:BtnDnsDhcp              = $script:window.FindName("BtnDnsDhcp")

$script:BtnDeepOneDrive         = $script:window.FindName("BtnDeepOneDrive")
$script:BtnDisableCopilot       = $script:window.FindName("BtnDisableCopilot")
$script:BtnDisableEdgeBg        = $script:window.FindName("BtnDisableEdgeBg")
$script:BtnRestoreOneDrive      = $script:window.FindName("BtnRestoreOneDrive")
$script:BtnEnableCopilot        = $script:window.FindName("BtnEnableCopilot")
$script:BtnEnableEdgeBg         = $script:window.FindName("BtnEnableEdgeBg")

$script:BtnWinUpdateSecurity    = $script:window.FindName("BtnWinUpdateSecurity")
$script:BtnWinUpdateDisable     = $script:window.FindName("BtnWinUpdateDisable")
$script:BtnWinUpdateDefault     = $script:window.FindName("BtnWinUpdateDefault")

$script:FeaturesGrid            = $script:window.FindName("FeaturesGrid")
$script:BtnCheckFeaturesStatus  = $script:window.FindName("BtnCheckFeaturesStatus")
$script:BtnApplyFeatures        = $script:window.FindName("BtnApplyFeatures")
$script:BtnDisableFeatures      = $script:window.FindName("BtnDisableFeatures")

# Sekme 4: Bloatware Kontrolleri
$script:BloatwareGrid         = $script:window.FindName("BloatwareGrid")
$script:BtnSelectDefaultBloat = $script:window.FindName("BtnSelectDefaultBloat")
$script:BtnSelectAllBloat     = $script:window.FindName("BtnSelectAllBloat")
$script:BtnClearBloat         = $script:window.FindName("BtnClearBloat")
$script:BtnReinstallBloatware = $script:window.FindName("BtnReinstallBloatware")
$script:BtnRemoveBloatware    = $script:window.FindName("BtnRemoveBloatware")

# Sekme 5: Sistem Araclari & MAS Kontrolleri
$script:BtnRunMAS              = $script:window.FindName("BtnRunMAS")
$script:BtnCreateGodMode       = $script:window.FindName("BtnCreateGodMode")
$script:BtnRunOOSU             = $script:window.FindName("BtnRunOOSU")
$script:BtnFixSystemCorruption = $script:window.FindName("BtnFixSystemCorruption")
$script:BtnFixWinUpdate        = $script:window.FindName("BtnFixWinUpdate")
$script:BtnFixNetwork          = $script:window.FindName("BtnFixNetwork")
$script:BtnFixWinget           = $script:window.FindName("BtnFixWinget")
$script:BtnFixNTP              = $script:window.FindName("BtnFixNTP")
$script:BtnRunAutologon        = $script:window.FindName("BtnRunAutologon")
$script:BtnEnableOpenSSH       = $script:window.FindName("BtnEnableOpenSSH")
$script:BtnEnableRegBackup     = $script:window.FindName("BtnEnableRegBackup")
$script:BtnRestartExplorer     = $script:window.FindName("BtnRestartExplorer")
$script:BtnEnableF8Boot        = $script:window.FindName("BtnEnableF8Boot")
$script:BtnDisableF8Boot       = $script:window.FindName("BtnDisableF8Boot")

$script:BtnPanelControl        = $script:window.FindName("BtnPanelControl")
$script:BtnPanelNetwork        = $script:window.FindName("BtnPanelNetwork")
$script:BtnPanelSystem         = $script:window.FindName("BtnPanelSystem")
$script:BtnPanelPower          = $script:window.FindName("BtnPanelPower")
$script:BtnPanelSound          = $script:window.FindName("BtnPanelSound")
$script:BtnPanelPrograms       = $script:window.FindName("BtnPanelPrograms")
$script:BtnPanelComputer       = $script:window.FindName("BtnPanelComputer")
$script:BtnPanelMouse          = $script:window.FindName("BtnPanelMouse")
$script:BtnPanelFirewall       = $script:window.FindName("BtnPanelFirewall")
$script:BtnPanelRestore        = $script:window.FindName("BtnPanelRestore")
$script:BtnPanelTimedate       = $script:window.FindName("BtnPanelTimedate")
$script:BtnPanelRegion         = $script:window.FindName("BtnPanelRegion")

# Sekme 6: Yedekleme & Config Kontrolleri
$script:BtnExportConfig    = $script:window.FindName("BtnExportConfig")
$script:BtnImportConfig    = $script:window.FindName("BtnImportConfig")
$script:BtnExportSysReport = $script:window.FindName("BtnExportSysReport")
$script:TxtRemoteCmd       = $script:window.FindName("TxtRemoteCmd")
$script:BtnCopyCmd         = $script:window.FindName("BtnCopyCmd")

# Sag Log Paneli Kontrolleri
$script:TxtStatus       = $script:window.FindName("TxtStatus")
$script:ProgressBarMain = $script:window.FindName("ProgressBarMain")
$script:TxtLog          = $script:window.FindName("TxtLog")
$script:BtnClearLog     = $script:window.FindName("BtnClearLog")
$script:TxtSysInfo      = $script:window.FindName("TxtSysInfo")

$sync.TxtLog               = $script:TxtLog
$sync.TxtStatus            = $script:TxtStatus
$sync.ProgressBarMain      = $script:ProgressBarMain
$sync.BtnInstall           = $script:BtnInstall
$sync.BtnUninstall         = $script:BtnUninstall
$sync.BtnUpgradeSelected   = $script:BtnUpgradeSelected
$sync.BtnUpgradeAll        = $script:BtnUpgradeAll
$sync.BtnApplyTweaks       = $script:BtnApplyTweaks
$sync.BtnUndoTweaks        = $script:BtnUndoTweaks
$sync.BtnApplyFeatures     = $script:BtnApplyFeatures
$sync.BtnDisableFeatures   = $script:BtnDisableFeatures
$sync.BtnRemoveBloatware   = $script:BtnRemoveBloatware
$sync.BtnReinstallBloatware= $script:BtnReinstallBloatware
$sync.IsBusy               = $false

function Write-UiLog([string]$msg) {
    $time = (Get-Date).ToString("HH:mm:ss")
    $decoded = Decode-U $msg
    $script:window.Dispatcher.Invoke([action]{
        $script:TxtLog.AppendText("[$time] $decoded`r`n")
        $script:TxtLog.ScrollToEnd()
    })
}

function Set-UiStatus([string]$msg, [double]$progress = -1) {
    $decoded = Decode-U $msg
    $script:window.Dispatcher.Invoke([action]{
        $script:TxtStatus.Text = $decoded
        if ($progress -ge 0) {
            $script:ProgressBarMain.Value = $progress
        }
    })
}

# --- Genel Arka Plan Runspace Yurutucu (Donmayan Arayuz Motoru) ---
function Start-BackgroundTask([string]$TaskName, [hashtable]$Params, [scriptblock]$WorkBlock) {
    if ($sync.IsBusy) {
        Write-UiLog (Decode-U "[!] \u015Eu anda devam eden bir arka plan i\u015Flemi var, l\u00FCtfen bitmesini bekleyin.")
        return
    }
    $sync.IsBusy = $true
    $rs = [runspacefactory]::CreateRunspace()
    $rs.ApartmentState = "STA"
    $rs.ThreadOptions  = "ReuseThread"
    $rs.Open()
    $rs.SessionStateProxy.SetVariable("sync", $sync)
    $rs.SessionStateProxy.SetVariable("TaskName", $TaskName)
    $workStr = $WorkBlock.ToString()
    $rs.SessionStateProxy.SetVariable("Params", $Params)
    $rs.SessionStateProxy.SetVariable("WorkStr", $workStr)

    $ps = [powershell]::Create()
    $ps.Runspace = $rs
    [void]$ps.AddScript({
        function Decode-Bg([string]$text) {
            if ([string]::IsNullOrEmpty($text)) { return "" }
            return [regex]::Replace($text, '\\u([0-9a-fA-F]{4})', { param($m) [char][int]("0x" + $m.Groups[1].Value) })
        }
        function Log-Bg([string]$m) {
            $t = (Get-Date).ToString("HH:mm:ss")
            $dec = Decode-Bg $m
            $sync.Window.Dispatcher.Invoke([action]{
                $sync.TxtLog.AppendText("[$t] $dec`r`n")
                $sync.TxtLog.ScrollToEnd()
            })
        }
        function Status-Bg([string]$s, [double]$p = -1) {
            $dec = Decode-Bg $s
            $sync.Window.Dispatcher.Invoke([action]{
                $sync.TxtStatus.Text = $dec
                if ($p -ge 0) { $sync.ProgressBarMain.Value = $p }
            })
        }
        function Set-RegSafe([string]$Path, [string]$Name, [string]$Type, $Value) {
            try {
                if ($Path.StartsWith("HKU:\") -and !(Test-Path "HKU:\")) {
                    New-PSDrive -PSProvider Registry -Name HKU -Root HKEY_USERS -ErrorAction SilentlyContinue | Out-Null
                }
                if ($Path.StartsWith("HKCR:\") -and !(Test-Path "HKCR:\")) {
                    New-PSDrive -PSProvider Registry -Name HKCR -Root HKEY_CLASSES_ROOT -ErrorAction SilentlyContinue | Out-Null
                }
                if ($Value -eq "<RemoveEntry>") {
                    if (Test-Path $Path) {
                        Remove-ItemProperty -Path $Path -Name $Name -Force -ErrorAction SilentlyContinue
                    }
                    return
                }
                if (!(Test-Path $Path)) {
                    New-Item -Path $Path -Force -ErrorAction SilentlyContinue | Out-Null
                }
                if ($Type -eq "Binary") {
                    Set-ItemProperty -Path $Path -Name $Name -Type Binary -Value $Value -Force -ErrorAction Stop
                } elseif ($Type -eq "DWord") {
                    Set-ItemProperty -Path $Path -Name $Name -Type DWord -Value ([int64]$Value) -Force -ErrorAction Stop
                } elseif ($Type -eq "QWord") {
                    Set-ItemProperty -Path $Path -Name $Name -Type QWord -Value ([int64]$Value) -Force -ErrorAction Stop
                } else {
                    Set-ItemProperty -Path $Path -Name $Name -Type $Type -Value $Value -Force -ErrorAction Stop
                }
            } catch {
                Log-Bg "  [!] Kayit defteri uyarisi ($Path\$Name): $($_.Exception.Message)"
            }
        }
        function Set-SvcSafe([string]$SvcName, [string]$StartupType, [bool]$StopNow = $false) {
            try {
                $svc = Get-Service -Name $SvcName -ErrorAction SilentlyContinue
                if (-not $svc) { return }
                if ($StopNow -and $svc.Status -eq 'Running') {
                    Stop-Service -Name $SvcName -Force -ErrorAction SilentlyContinue
                }
                if ($StartupType -eq "AutomaticDelayedStart" -and $PSVersionTable.PSVersion.Major -lt 7) {
                    sc.exe config $SvcName start= delayed-auto | Out-Null
                } else {
                    Set-Service -Name $SvcName -StartupType $StartupType -ErrorAction SilentlyContinue
                }
            } catch {
                Log-Bg "  [!] Servis uyarisi ($SvcName): $($_.Exception.Message)"
            }
        }

        try {
            $sb = [scriptblock]::Create($WorkStr)
            & $sb $Params
        } catch {
            Log-Bg "[HATA] ($TaskName): $($_.Exception.Message)"
            Status-Bg "Islem sirasinda hata olustu: $TaskName" 100
        } finally {
            $sync.Window.Dispatcher.Invoke([action]{
                $sync.BtnInstall.IsEnabled            = $true
                $sync.BtnUninstall.IsEnabled          = $true
                $sync.BtnUpgradeSelected.IsEnabled    = $true
                $sync.BtnUpgradeAll.IsEnabled         = $true
                $sync.BtnApplyTweaks.IsEnabled        = $true
                $sync.BtnUndoTweaks.IsEnabled         = $true
                $sync.BtnApplyFeatures.IsEnabled      = $true
                $sync.BtnDisableFeatures.IsEnabled    = $true
                $sync.BtnRemoveBloatware.IsEnabled    = $true
                $sync.BtnReinstallBloatware.IsEnabled = $true
                $sync.IsBusy = $false
            })
        }
    })
    [void]$ps.BeginInvoke()
}

try {
    $osInfo = Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue
    if ($osInfo) {
        $script:TxtSysInfo.Text = "$($osInfo.Caption) ($($osInfo.BuildNumber))"
    }
} catch {}

# =============================================================================
# CANLI TEMA SISTEMI (REAL-TIME THEME SWITCHER)
# =============================================================================
$script:dynamicThemedItems = @()
$script:currentThemeKey = "olive"
$script:currentActiveNavBtn = $script:BtnNavApps

function Set-Theme([string]$key) {
    $t = $script:ThemesData.$key
    if (-not $t) { return }
    $script:currentThemeKey = $key

    $resKeys = @("WindowBg", "PanelBg", "CardBg", "BorderBrushColor", "HoverBg", "AccentColor", "ActiveBtnColor", "TextMuted", "TextDim", "LogBg", "LogFg", "BtnInstallBg", "BtnUninstallBg", "BtnUpgradeBg")
    foreach ($rk in $resKeys) {
        if ($t.$rk) {
            $script:window.Resources[$rk] = Get-Brush $t.$rk
        }
    }

    foreach ($item in $script:dynamicThemedItems) {
        if ($item.Type -eq "CatHeader") {
            $item.Element.Foreground = Get-Brush $t.AccentColor
        } elseif ($item.Type -eq "Card") {
            $item.Element.Background  = Get-Brush $t.CardBg
            $item.Element.BorderBrush = Get-Brush $t.BorderBrushColor
        } elseif ($item.Type -eq "IconBox") {
            $item.Element.Background  = Get-Brush $t.HoverBg
            $item.Element.BorderBrush = Get-Brush $t.BorderBrushColor
        } elseif ($item.Type -eq "Desc") {
            $item.Element.Foreground = Get-Brush $t.TextMuted
        } elseif ($item.Type -eq "Id") {
            $item.Element.Foreground = Get-Brush $t.TextDim
        }
    }

    if ($script:currentActiveNavBtn) {
        $script:currentActiveNavBtn.Background  = Get-Brush $t.ActiveBtnColor
        $script:currentActiveNavBtn.BorderBrush = Get-Brush $t.AccentColor
    }

    if ($script:currentActiveCatBtn) {
        $script:currentActiveCatBtn.Background = Get-Brush $t.ActiveBtnColor
    }

    $script:BtnThemeOlive.BorderThickness = New-Object System.Windows.Thickness(0)
    $script:BtnThemeAmber.BorderThickness = New-Object System.Windows.Thickness(0)
    $script:BtnThemeNeon.BorderThickness  = New-Object System.Windows.Thickness(0)

    if ($key -eq "olive") {
        $script:BtnThemeOlive.BorderThickness = New-Object System.Windows.Thickness(2)
        $script:BtnThemeOlive.BorderBrush = Get-Brush "#FFFFFF"
    } elseif ($key -eq "amber") {
        $script:BtnThemeAmber.BorderThickness = New-Object System.Windows.Thickness(2)
        $script:BtnThemeAmber.BorderBrush = Get-Brush "#FFFFFF"
    } elseif ($key -eq "neon") {
        $script:BtnThemeNeon.BorderThickness = New-Object System.Windows.Thickness(2)
        $script:BtnThemeNeon.BorderBrush = Get-Brush "#FFFFFF"
    }

    Write-UiLog (Decode-U "Tema de\u011Fi\u015Ftirildi: $($t.Name)")
}

$script:BtnThemeOlive.Add_Click({ Set-Theme "olive" })
$script:BtnThemeAmber.Add_Click({ Set-Theme "amber" })
$script:BtnThemeNeon.Add_Click({ Set-Theme "neon" })

# =============================================================================
# 1. SEKME GECISLERI (NAVIGASYON - 6 MODUL)
# =============================================================================
$script:navButtons = @($script:BtnNavApps, $script:BtnNavTweaks, $script:BtnNavFeatures, $script:BtnNavBloatware, $script:BtnNavTools, $script:BtnNavConfig)
$script:views      = @($script:ViewApps, $script:ViewTweaks, $script:ViewFeatures, $script:ViewBloatware, $script:ViewTools, $script:ViewConfig)

function Switch-Tab($activeBtn, $activeView) {
    $t = $script:ThemesData.$($script:currentThemeKey)
    foreach ($v in $script:views) { $v.Visibility = "Collapsed" }
    foreach ($b in $script:navButtons) {
        $b.Background  = Get-Brush $t.CardBg
        $b.BorderBrush = Get-Brush $t.BorderBrushColor
    }
    $activeView.Visibility = "Visible"
    $activeBtn.Background  = Get-Brush $t.ActiveBtnColor
    $activeBtn.BorderBrush = Get-Brush $t.AccentColor
    $script:currentActiveNavBtn = $activeBtn
}

$script:BtnNavApps.Add_Click({ Switch-Tab $script:BtnNavApps $script:ViewApps })
$script:BtnNavTweaks.Add_Click({ Switch-Tab $script:BtnNavTweaks $script:ViewTweaks })
$script:BtnNavFeatures.Add_Click({ Switch-Tab $script:BtnNavFeatures $script:ViewFeatures })
$script:BtnNavBloatware.Add_Click({ Switch-Tab $script:BtnNavBloatware $script:ViewBloatware })
$script:BtnNavTools.Add_Click({ Switch-Tab $script:BtnNavTools $script:ViewTools })
$script:BtnNavConfig.Add_Click({ Switch-Tab $script:BtnNavConfig $script:ViewConfig })

$script:BtnClearLog.Add_Click({ $script:TxtLog.Clear() })
$script:BtnCopyCmd.Add_Click({
    [System.Windows.Clipboard]::SetText($script:TxtRemoteCmd.Text)
    Write-UiLog (Decode-U "Uzaktan \u00E7al\u0131\u015Ft\u0131rma komutu panoya kopyaland\u0131.")
})

# =============================================================================
# 2. UYGULAMA KARTLARI, ARAMA VE KATEGORI FILTRELEME (248 UYGULAMA)
# =============================================================================
$script:appCheckboxes    = @()
$script:categoryBlocks   = @{}
$script:selectedCategory = "ALL"
$script:catButtons       = @()
$script:currentActiveCatBtn = $null

$updateCounter = {
    $cnt = ($script:appCheckboxes | Where-Object { $_.IsChecked -eq $true }).Count
    $script:TxtSelectedCount.Text = (Decode-U "$cnt uygulama se\u00E7ildi")
}

function Apply-AppFilter {
    $q = $script:TxtSearch.Text.Trim().ToLower()
    foreach ($cat in $script:AppCategories) {
        $catName = Decode-U $cat.Category
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

$script:btnAll = New-Object System.Windows.Controls.Button
$script:btnAll.Content = (Decode-U "T\u00FCm\u00FC ($($script:AppCategories | ForEach-Object { $_.Apps.Count } | Measure-Object -Sum | Select-Object -ExpandProperty Sum))")
$script:btnAll.Padding = "10,5"
$script:btnAll.Margin  = "0,0,5,5"
$script:btnAll.Background = Get-Brush $initTheme.ActiveBtnColor
$script:btnAll.Foreground = Get-Brush "#FFFFFF"
$script:btnAll.BorderThickness = "0"
$script:btnAll.FontWeight = "SemiBold"
$script:btnAll.Cursor = "Hand"
$script:btnAll.Add_Click({
    $script:selectedCategory = "ALL"
    Set-CategoryButtonActive $script:btnAll
    Apply-AppFilter
})
[void]$script:CategoryButtonPanel.Children.Add($script:btnAll)
$script:catButtons += $script:btnAll
$script:currentActiveCatBtn = $script:btnAll

foreach ($cat in $script:AppCategories) {
    $catName = Decode-U $cat.Category

    $cBtn = New-Object System.Windows.Controls.Button
    $cBtn.Content = "$catName ($($cat.Apps.Count))"
    $cBtn.Tag     = $catName
    $cBtn.Padding = "10,5"
    $cBtn.Margin  = "0,0,5,5"
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
    [void]$script:CategoryButtonPanel.Children.Add($cBtn)
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
        $appName = Decode-U $app.Name
        $appDesc = Decode-U $app.Description

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

        $iconBorder = New-Object System.Windows.Controls.Border
        $iconBorder.Width = 38
        $iconBorder.Height = 38
        $iconBorder.CornerRadius = New-Object System.Windows.CornerRadius(6)
        $iconBorder.Background = Get-Brush $initTheme.HoverBg
        $iconBorder.BorderBrush = Get-Brush $initTheme.BorderBrushColor
        $iconBorder.BorderThickness = New-Object System.Windows.Thickness(1)
        $iconBorder.Margin = New-Object System.Windows.Thickness(0, 0, 10, 0)
        $iconBorder.VerticalAlignment = "Center"
        [System.Windows.Controls.DockPanel]::SetDock($iconBorder, [System.Windows.Controls.Dock]::Left)
        $script:dynamicThemedItems += [PSCustomObject]@{ Type = "IconBox"; Element = $iconBorder }

        $img = New-Object System.Windows.Controls.Image
        $img.Width = 26
        $img.Height = 26
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
        $cb.FontSize = 13
        $cb.Content = $appName
        $cb.Tag = [PSCustomObject]@{
            Name        = $appName
            Id          = $app.Id
            Description = $appDesc
            Category    = $catName
            Card        = $card
        }
        $cb.Add_Checked($updateCounter)
        $cb.Add_Unchecked($updateCounter)

        $descBlock = New-Object System.Windows.Controls.TextBlock
        $descBlock.Text = $appDesc
        $descBlock.FontSize = 11
        $descBlock.Foreground = Get-Brush $initTheme.TextMuted
        $descBlock.TextWrapping = "Wrap"
        $descBlock.Margin = "0,2,0,2"
        $script:dynamicThemedItems += [PSCustomObject]@{ Type = "Desc"; Element = $descBlock }

        $idBlock = New-Object System.Windows.Controls.TextBlock
        $idBlock.Text = $app.Id
        $idBlock.FontSize = 10
        $idBlock.FontFamily = "Consolas"
        $idBlock.Foreground = Get-Brush $initTheme.TextDim
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
    [void]$script:MainStackPanel.Children.Add($catContainer)
    $script:categoryBlocks[$catName] = $catContainer
}

$script:TxtSearch.Add_TextChanged({ Apply-AppFilter })
$script:BtnClearSearch.Add_Click({
    $script:TxtSearch.Text = ""
    Apply-AppFilter
})

# Sistemde Yuklu Uygulamalari Tarama (WinUtil GetInstalled Engine)
$script:BtnCheckInstalled.Add_Click({
    Start-BackgroundTask "CheckInstalled" @{ Checkboxes = $script:appCheckboxes } {
        param($p)
        Status-Bg "Sistemde kurulu uygulamalar Winget ile taraniyor..." 25
        Log-Bg ">>> Winget kurulu uygulama listesi aliniyor (winget list)..."
        $rawOut = winget list --accept-source-agreements 2>&1 | Out-String
        Status-Bg "Kurulu uygulamalar eslestiriliyor..." 75
        $matched = 0
        $sync.Window.Dispatcher.Invoke([action]{
            foreach ($cb in $p.Checkboxes) {
                if ($rawOut -match [regex]::Escape($cb.Tag.Id)) {
                    $cb.IsChecked = $true
                    $matched++
                }
            }
        })
        Log-Bg "[OK] Sistemde kurulu olan $matched uygulama tespit edildi ve isaretlendi."
        Status-Bg "$matched kurulu uygulama isaretlendi!" 100
    }
})

# =============================================================================
# 3. HAZIR UYGULAMA PAKETLERI (PRESETS)
# =============================================================================
function Select-PresetByIds([string[]]$ids, [string]$presetTitle) {
    Switch-Tab $script:BtnNavApps $script:ViewApps
    foreach ($cb in $script:appCheckboxes) {
        $cb.IsChecked = ($ids -contains $cb.Tag.Id)
    }
    Write-UiLog (Decode-U "$presetTitle se\u00E7ildi ($($ids.Count) uygulama).")
}

$script:BtnPresetUmut.Add_Click({
    $umutIds = @(
        "TheBrowserCompany.Arc", "Brave.Brave", "Discord.Discord", "Valve.Steam",
        "EpicGames.EpicGamesLauncher", "ElectronicArts.EADesktop", "SteelSeries.GG",
        "PrismLauncher.PrismLauncher", "VideoLAN.VLC", "OBSProject.OBSStudio",
        "Spotify.Spotify", "Microsoft.VisualStudioCode", "Git.Git", "7zip.7zip",
        "RARLab.WinRAR", "voidtools.Everything", "Microsoft.PowerToys",
        "Google.Drive", "AnyDeskSoftwareGmbH.AnyDesk", "TechPowerUp.NVCleanstall",
        "WinsiderSS.SystemInformer", "AntibodySoftware.WizTree"
    )
    Select-PresetByIds $umutIds (Decode-U "\uD83D\uDC51 Umut \u00D6zel Paketi")
})

$script:BtnPresetGamer.Add_Click({
    $gamerIds = @(
        "TheBrowserCompany.Arc", "Brave.Brave", "Discord.Discord", "Valve.Steam",
        "EpicGames.EpicGamesLauncher", "ElectronicArts.EADesktop", "GOG.Galaxy",
        "Ubisoft.Connect", "Blizzard.BattleNet", "SteelSeries.GG", "Logitech.GHUB",
        "Guru3D.Afterburner", "Playnite.Playnite", "PrismLauncher.PrismLauncher",
        "Modrinth.ModrinthApp", "VideoLAN.VLC", "OBSProject.OBSStudio", "7zip.7zip",
        "Spotify.Spotify", "TechPowerUp.NVCleanstall", "BitSum.ProcessLasso"
    )
    Select-PresetByIds $gamerIds "Oyuncu Paketi"
})

$script:BtnPresetDev.Add_Click({
    $devIds = @(
        "TheBrowserCompany.Arc", "Microsoft.VisualStudioCode", "Anysphere.Cursor",
        "Git.Git", "GitHub.GitHubDesktop", "GitHub.cli", "OpenJS.NodeJS.LTS",
        "Python.Python.3.12", "Microsoft.WindowsTerminal", "Microsoft.PowerShell",
        "Docker.DockerDesktop", "Postman.Postman", "Bruno.Bruno", "Notepad++.Notepad++",
        "JetBrains.Toolbox", "7zip.7zip", "Microsoft.PowerToys", "WinSCP.WinSCP", "PuTTY.PuTTY"
    )
    Select-PresetByIds $devIds (Decode-U "Geli\u015Ftirici Paketi")
})

$script:BtnPresetStandard.Add_Click({
    $stdIds = @(
        "Google.Chrome", "Brave.Brave", "7zip.7zip", "RARLab.WinRAR", "VideoLAN.VLC",
        "Spotify.Spotify", "Discord.Discord", "voidtools.Everything",
        "Skillbrains.Lightshot", "ShareX.ShareX", "Adobe.Acrobat.Reader.64-bit",
        "SumatraPDF.SumatraPDF", "TheDocumentFoundation.LibreOffice",
        "Microsoft.VCRedist.2015+.x64", "Microsoft.VCRedist.2015+.x86"
    )
    Select-PresetByIds $stdIds "Standart Kurulum Paketi"
})

$script:BtnClearSelection.Add_Click({
    foreach ($cb in $script:appCheckboxes) { $cb.IsChecked = $false }
    Write-UiLog (Decode-U "T\u00FCm uygulama se\u00E7imleri temizlendi.")
})

# =============================================================================
# 4. ARKA PLAN RUNSPACE ILE WINGET KURULUM / KALDIRMA / GUNCELLEME
# =============================================================================
function Start-WingetJob([array]$appsList, [string]$mode) {
    $script:BtnInstall.IsEnabled         = $false
    $script:BtnUninstall.IsEnabled       = $false
    $script:BtnUpgradeSelected.IsEnabled = $false
    $script:BtnUpgradeAll.IsEnabled      = $false

    Start-BackgroundTask "Winget_$mode" @{ Apps = $appsList; Mode = $mode } {
        param($p)
        $mode = $p.Mode
        $appsList = $p.Apps

        if ($mode -eq "upgrade_all") {
            Status-Bg "Tum sistem uygulamalariniz Winget ile guncelleniyor..." 20
            Log-Bg ">>> Baslatiliyor: winget upgrade --all --include-unknown"
            $proc = Start-Process -FilePath "winget.exe" -ArgumentList "upgrade --all --include-unknown --silent --accept-package-agreements --accept-source-agreements" -NoNewWindow -Wait -PassThru
            Log-Bg ">>> Tum guncellemeler tamamlandi (Cikis Kodu: $($proc.ExitCode))."
            Status-Bg "Tum uygulamalar guncellendi!" 100
        } else {
            $total = $appsList.Count
            $idx = 0
            foreach ($item in $appsList) {
                $idx++
                $pct = [math]::Round(($idx / $total) * 100)
                if ($mode -eq "install") {
                    Status-Bg "($idx/$total) Kuruluyor: $($item.Name)..." $pct
                    Log-Bg "[$idx/$total] Kuruluyor: $($item.Name) ($($item.Id))"
                    $proc = Start-Process -FilePath "winget.exe" -ArgumentList "install --id `"$($item.Id)`" -e --silent --accept-package-agreements --accept-source-agreements" -NoNewWindow -Wait -PassThru
                    if ($proc.ExitCode -eq 0) {
                        Log-Bg "  [OK] $($item.Name) basariyla kuruldu."
                    } else {
                        Log-Bg "  [!] $($item.Name) cikis kodu: $($proc.ExitCode)"
                    }
                } elseif ($mode -eq "uninstall") {
                    Status-Bg "($idx/$total) Kaldiriliyor: $($item.Name)..." $pct
                    Log-Bg "[$idx/$total] Kaldiriliyor: $($item.Name) ($($item.Id))"
                    $proc = Start-Process -FilePath "winget.exe" -ArgumentList "uninstall --id `"$($item.Id)`" -e --silent --accept-source-agreements" -NoNewWindow -Wait -PassThru
                    if ($proc.ExitCode -eq 0) {
                        Log-Bg "  [OK] $($item.Name) kaldirildi."
                    } else {
                        Log-Bg "  [!] $($item.Name) cikis kodu: $($proc.ExitCode)"
                    }
                } elseif ($mode -eq "upgrade_selected") {
                    Status-Bg "($idx/$total) Guncelleniyor: $($item.Name)..." $pct
                    Log-Bg "[$idx/$total] Guncelleniyor: $($item.Name) ($($item.Id))"
                    $proc = Start-Process -FilePath "winget.exe" -ArgumentList "upgrade --id `"$($item.Id)`" -e --silent --accept-package-agreements --accept-source-agreements" -NoNewWindow -Wait -PassThru
                    if ($proc.ExitCode -eq 0) {
                        Log-Bg "  [OK] $($item.Name) basariyla guncellendi."
                    } else {
                        Log-Bg "  [!] $($item.Name) cikis kodu: $($proc.ExitCode)"
                    }
                }
            }
            Status-Bg "Secili Winget islemleri tamamlandi ($total / $total)!" 100
            Log-Bg "=== TUM WINGET ISLEMLERI TAMAMLANDI ==="
        }
    }
}

$script:BtnInstall.Add_Click({
    $selected = @($script:appCheckboxes | Where-Object { $_.IsChecked -eq $true } | ForEach-Object { $_.Tag })
    if ($selected.Count -eq 0) {
        Write-UiLog (Decode-U "[!] L\u00FCtfen kurmak i\u00E7in en az bir uygulama se\u00E7in.")
        return
    }
    Start-WingetJob $selected "install"
})

$script:BtnUninstall.Add_Click({
    $selected = @($script:appCheckboxes | Where-Object { $_.IsChecked -eq $true } | ForEach-Object { $_.Tag })
    if ($selected.Count -eq 0) {
        Write-UiLog (Decode-U "[!] L\u00FCtfen kald\u0131rmak i\u00E7in en az bir uygulama se\u00E7in.")
        return
    }
    Start-WingetJob $selected "uninstall"
})

$script:BtnUpgradeSelected.Add_Click({
    $selected = @($script:appCheckboxes | Where-Object { $_.IsChecked -eq $true } | ForEach-Object { $_.Tag })
    if ($selected.Count -eq 0) {
        Write-UiLog (Decode-U "[!] L\u00FCtfen g\u00FCncellemek i\u00E7in en az bir uygulama se\u00E7in.")
        return
    }
    Start-WingetJob $selected "upgrade_selected"
})

$script:BtnUpgradeAll.Add_Click({
    Start-WingetJob @() "upgrade_all"
})

# =============================================================================
# 5. SEKME 2: SISTEM INCE AYARLARI VE GELISMIS TWEAKS (61 AYAR - APPLY + UNDO)
# =============================================================================
$script:tweakCheckboxes = @()

foreach ($grp in $script:TweaksData) {
    $grpTitle = Decode-U $grp.Group
    $gHeader = New-Object System.Windows.Controls.TextBlock
    $gHeader.Text = $grpTitle.ToUpper()
    $gHeader.FontSize = 13
    $gHeader.FontWeight = "Bold"
    $gHeader.Foreground = Get-Brush $initTheme.AccentColor
    $gHeader.Margin = "4,8,0,8"
    [void]$script:TweaksStackPanel.Children.Add($gHeader)
    $script:dynamicThemedItems += [PSCustomObject]@{ Type = "CatHeader"; Element = $gHeader }

    foreach ($tw in $grp.Items) {
        $twTitle = Decode-U $tw.Title
        $twDesc  = Decode-U $tw.Desc

        $card = New-Object System.Windows.Controls.Border
        $card.Background = Get-Brush $initTheme.CardBg
        $card.BorderBrush = Get-Brush $initTheme.BorderBrushColor
        $card.BorderThickness = "1"
        $card.CornerRadius = "6"
        $card.Padding = "10"
        $card.Margin = "0,0,0,6"
        $card.Cursor = "Hand"
        $script:dynamicThemedItems += [PSCustomObject]@{ Type = "Card"; Element = $card }

        $sp = New-Object System.Windows.Controls.StackPanel
        $cb = New-Object System.Windows.Controls.CheckBox
        $cb.Content = $twTitle
        $cb.Foreground = Get-Brush "#F8FAFC"
        $cb.FontWeight = "SemiBold"
        $cb.FontSize = 13
        $cb.IsChecked = [bool]$tw.Recommended
        $cb.Tag = [PSCustomObject]@{
            Id          = $tw.Id
            Title       = $twTitle
            Desc        = $twDesc
            Recommended = [bool]$tw.Recommended
            Preset      = @($tw.Preset)
        }

        $d = New-Object System.Windows.Controls.TextBlock
        $d.Text = $twDesc
        $d.FontSize = 11.5
        $d.Foreground = Get-Brush $initTheme.TextMuted
        $d.Margin = "22,3,0,0"
        $d.TextWrapping = "Wrap"
        $script:dynamicThemedItems += [PSCustomObject]@{ Type = "Desc"; Element = $d }

        [void]$sp.Children.Add($cb)
        [void]$sp.Children.Add($d)
        $card.Child = $sp

        $card.Tag = $cb
        $card.Add_MouseLeftButtonUp({
            param($sender, $e)
            if ($e.OriginalSource -isnot [System.Windows.Controls.CheckBox]) {
                $targetCb = $sender.Tag
                $targetCb.IsChecked = -not $targetCb.IsChecked
            }
        })

        [void]$script:TweaksStackPanel.Children.Add($card)
        $script:tweakCheckboxes += $cb
    }
}

$script:BtnSelectRecTweaks.Add_Click({
    foreach ($cb in $script:tweakCheckboxes) { $cb.IsChecked = [bool]$cb.Tag.Recommended }
    Write-UiLog (Decode-U "\u00D6nerilen sistem ince ayarlar\u0131 se\u00E7ildi.")
})

$script:BtnTweakPresetStandard.Add_Click({
    foreach ($cb in $script:tweakCheckboxes) { $cb.IsChecked = ($cb.Tag.Preset -contains "Standard") }
    Write-UiLog (Decode-U "WinUtil Standart (Masa\u00FCst\u00FC) ince ayar profili se\u00E7ildi.")
})

$script:BtnTweakPresetMinimal.Add_Click({
    foreach ($cb in $script:tweakCheckboxes) { $cb.IsChecked = ($cb.Tag.Preset -contains "Minimal") }
    Write-UiLog (Decode-U "WinUtil Minimal (Diz\u00FCst\u00FC / Koruyucu) ince ayar profili se\u00E7ildi.")
})

$script:BtnTweakPresetAdvanced.Add_Click({
    foreach ($cb in $script:tweakCheckboxes) { $cb.IsChecked = ($cb.Tag.Preset -contains "Advanced") }
    Write-UiLog (Decode-U "WinUtil Geli\u015Fmi\u015F (Tam Kapsaml\u0131) ince ayar profili se\u00E7ildi.")
})

$script:BtnClearTweaks.Add_Click({
    foreach ($cb in $script:tweakCheckboxes) { $cb.IsChecked = $false }
    Write-UiLog (Decode-U "T\u00FCm ince ayar se\u00E7imleri temizlendi.")
})

function Start-TweaksEngine([array]$selectedTweaks, [bool]$isUndo) {
    if ($selectedTweaks.Count -eq 0) {
        Write-UiLog (Decode-U "[!] L\u00FCtfen i\u015Flem yap\u0131lacak en az bir ince ayar se\u00E7in.")
        return
    }
    $script:BtnApplyTweaks.IsEnabled = $false
    $script:BtnUndoTweaks.IsEnabled  = $false

    Start-BackgroundTask "TweaksEngine" @{ Tweaks = $selectedTweaks; Undo = $isUndo } {
        param($p)
        $list = $p.Tweaks
        $undo = [bool]$p.Undo
        $modeLabel = if ($undo) { "GERI ALINIYOR (UNDO)" } else { "UYGULANIYOR (APPLY)" }
        Log-Bg ">>> $($list.Count) Sistem Ince Ayari $modeLabel..."
        $done = 0

        foreach ($tw in $list) {
            $done++
            $pct = [math]::Round(($done / $list.Count) * 100)
            Status-Bg "($done/$($list.Count)) $modeLabel : $($tw.Title)" $pct
            try {
                switch ($tw.Id) {
                                        "Tweak_LocationAdvertising" {
                        if (-not $undo) {
                            Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" "Value" "String" "Deny"
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" "Enabled" "DWord" 0
                            Set-SvcSafe "lfsvc" "Disabled" $true
                            Log-Bg "[OK] Konum takibi (lfsvc) ve Reklam Kimligi kapatildi."
                        } else {
                            Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" "Value" "String" "Allow"
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" "Enabled" "DWord" 1
                            Set-SvcSafe "lfsvc" "Manual" $false
                            Log-Bg "[UNDO] Konum takibi ve Reklam Kimligi varsayilana donduruldu."
                        }
                    }
                    "Tweak_LockScreenSpotlight" {
                        if (-not $undo) {
                            Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" "DisableWindowsConsumerFeatures" "DWord" 1
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SubscribedContent-338387Enabled" "DWord" 0
                            Log-Bg "[OK] Kilit ekrani ipuclari ve sponsorlu tuketici deneyimleri kapatildi."
                        } else {
                            Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" "DisableWindowsConsumerFeatures" "DWord" "<RemoveEntry>"
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SubscribedContent-338387Enabled" "DWord" 1
                            Log-Bg "[UNDO] Kilit ekrani ipuclari varsayilana donduruldu."
                        }
                    }
                    "Tweak_WerFault" {
                        if (-not $undo) {
                            Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting" "Disabled" "DWord" 1
                            Set-SvcSafe "WerSvc" "Disabled" $true
                            Log-Bg "[OK] Windows Hata Bildirimi (WerSvc) devre disi birakildi."
                        } else {
                            Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting" "Disabled" "DWord" 0
                            Set-SvcSafe "WerSvc" "Manual" $false
                            Log-Bg "[UNDO] Windows Hata Bildirimi (WerSvc) varsayilana donduruldu."
                        }
                    }
                    "Tweak_SsdTrim" {
                        fsutil behavior set DisableDeleteNotify 0 | Out-Null
                        Log-Bg "[OK] SSD TRIM destegi aktif edildi ve dogrulandi."
                    }
                    "Tweak_BgServices" {
                        $svcList = @(
                            @{ Name = "CscService"; Apply = "Disabled"; Orig = "Manual" },
                            @{ Name = "DiagTrack"; Apply = "Disabled"; Orig = "Automatic" },
                            @{ Name = "MapsBroker"; Apply = "Manual"; Orig = "Automatic" },
                            @{ Name = "RemoteRegistry"; Apply = "Disabled"; Orig = "Disabled" },
                            @{ Name = "Fax"; Apply = "Disabled"; Orig = "Manual" },
                            @{ Name = "PcaSvc"; Apply = "Manual"; Orig = "Automatic" }
                        )
                        foreach ($s in $svcList) {
                            $targetMode = if ($undo) { $s.Orig } else { $s.Apply }
                            Set-SvcSafe $s.Name $targetMode $false
                        }
                        Log-Bg "[OK] Arka plan servisleri optimize edildi."
                    }
                    "Tweak_PhotoViewer" {
                        $exts = @(".bmp", ".dib", ".gif", ".jfif", ".jpe", ".jpeg", ".jpg", ".png", ".tif", ".tiff", ".wdp")
                        $regBase = "HKLM:\SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities\FileAssociations"
                        if (-not $undo) {
                            foreach ($ext in $exts) { Set-RegSafe $regBase $ext "String" "PhotoViewer.FileAssoc.Tiff" }
                            Log-Bg "[OK] Klasik Windows Fotograf Goruntuleyicisi aktif edildi."
                        } else {
                            foreach ($ext in $exts) {
                                if (-not ($ext -in @(".tif", ".tiff"))) { Set-RegSafe $regBase $ext "String" "<RemoveEntry>" }
                            }
                            Log-Bg "[UNDO] Klasik Windows Fotograf Goruntuleyicisi varsayilana donduruldu."
                        }
                    }
                    "Tweak_RestorePoint" {
                        if (-not $undo) {
                            Enable-ComputerRestore -Drive "$env:SystemDrive\" -ErrorAction SilentlyContinue
                            Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore" "SystemRestorePointCreationFrequency" "DWord" 0
                            Checkpoint-Computer -Description "UmutEvranTool_WinUtil_RestorePoint" -RestorePointType "MODIFY_SETTINGS" -ErrorAction SilentlyContinue
                            Log-Bg "[OK] Sistem Geri Yukleme Noktasi olusturuldu."
                        } else {
                            Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore" "SystemRestorePointCreationFrequency" "DWord" 1440
                            Log-Bg "[UNDO] Geri yukleme noktasi siklik degeri varsayilana (1440 dk) donduruldu."
                        }
                    }
                    "Tweak_Telemetry" {
                        if (-not $undo) {
                            Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" "AllowTelemetry" "DWord" 0
                            Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" "AllowTelemetry" "DWord" 0
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy" "TailoredExperiencesWithDiagnosticDataEnabled" "DWord" 0
                            Set-RegSafe "HKCU:\Software\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy" "HasAccepted" "DWord" 0
                            Set-RegSafe "HKCU:\Software\Microsoft\Input\TIPC" "Enabled" "DWord" 0
                            Set-RegSafe "HKCU:\Software\Microsoft\InputPersonalization" "RestrictImplicitInkCollection" "DWord" 1
                            Set-RegSafe "HKCU:\Software\Microsoft\InputPersonalization" "RestrictImplicitTextCollection" "DWord" 1
                            Set-RegSafe "HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore" "HarvestContacts" "DWord" 0
                            Set-RegSafe "HKCU:\Software\Microsoft\Personalization\Settings" "AcceptedPrivacyPolicy" "DWord" 0
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "Start_TrackProgs" "DWord" 0
                            Set-RegSafe "HKCU:\Software\Microsoft\Siuf\Rules" "NumberOfSIUFInPeriod" "DWord" 0
                            Set-RegSafe "HKCU:\Software\Microsoft\Siuf\Rules" "PeriodInNanoSeconds" "DWord" "<RemoveEntry>"
                            Set-SvcSafe "DiagTrack" "Disabled" $true
                            Set-SvcSafe "dmwappushservice" "Disabled" $true
                            Set-MpPreference -SubmitSamplesConsent 2 -ErrorAction SilentlyContinue
                            [Environment]::SetEnvironmentVariable('POWERSHELL_TELEMETRY_OPTOUT', '1', 'Machine')
                            Log-Bg "[OK] Telemetri, DiagTrack, dmwappushservice ve SIUF tamamen devre disi birakildi."
                        } else {
                            Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" "AllowTelemetry" "DWord" "<RemoveEntry>"
                            Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" "AllowTelemetry" "DWord" "<RemoveEntry>"
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy" "TailoredExperiencesWithDiagnosticDataEnabled" "DWord" "<RemoveEntry>"
                            Set-RegSafe "HKCU:\Software\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy" "HasAccepted" "DWord" "<RemoveEntry>"
                            Set-RegSafe "HKCU:\Software\Microsoft\Input\TIPC" "Enabled" "DWord" "<RemoveEntry>"
                            Set-RegSafe "HKCU:\Software\Microsoft\InputPersonalization" "RestrictImplicitInkCollection" "DWord" "<RemoveEntry>"
                            Set-RegSafe "HKCU:\Software\Microsoft\InputPersonalization" "RestrictImplicitTextCollection" "DWord" "<RemoveEntry>"
                            Set-RegSafe "HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore" "HarvestContacts" "DWord" "<RemoveEntry>"
                            Set-RegSafe "HKCU:\Software\Microsoft\Personalization\Settings" "AcceptedPrivacyPolicy" "DWord" "<RemoveEntry>"
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "Start_TrackProgs" "DWord" "<RemoveEntry>"
                            Set-RegSafe "HKCU:\Software\Microsoft\Siuf\Rules" "NumberOfSIUFInPeriod" "DWord" "<RemoveEntry>"
                            Set-SvcSafe "DiagTrack" "Automatic" $false
                            Set-SvcSafe "dmwappushservice" "Manual" $false
                            Set-MpPreference -SubmitSamplesConsent 1 -ErrorAction SilentlyContinue
                            [Environment]::SetEnvironmentVariable('POWERSHELL_TELEMETRY_OPTOUT', '', 'Machine')
                            Log-Bg "[UNDO] Telemetri ve DiagTrack servisleri varsayilan duruma donduruldu."
                        }
                    }
                    "Tweak_ActivityHistory" {
                        if (-not $undo) {
                            Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "EnableActivityFeed" "DWord" 0
                            Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "PublishUserActivities" "DWord" 0
                            Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "UploadUserActivities" "DWord" 0
                            Log-Bg "[OK] Etkinlik gecmisi (Timeline) ve kullanici takibi kapatildi."
                        } else {
                            Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "EnableActivityFeed" "DWord" "<RemoveEntry>"
                            Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "PublishUserActivities" "DWord" "<RemoveEntry>"
                            Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "UploadUserActivities" "DWord" "<RemoveEntry>"
                            Log-Bg "[UNDO] Etkinlik gecmisi (Timeline) varsayilana donduruldu."
                        }
                    }
                    "Tweak_Location" {
                        if (-not $undo) {
                            Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" "Value" "String" "Deny"
                            Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" "SensorPermissionState" "DWord" 0
                            Set-RegSafe "HKLM:\SYSTEM\Maps" "AutoUpdateEnabled" "DWord" 0
                            Set-SvcSafe "lfsvc" "Disabled" $true
                            Log-Bg "[OK] Fiziksel konum takibi ve lfsvc servisi kapatildi."
                        } else {
                            Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" "Value" "String" "Allow"
                            Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" "SensorPermissionState" "DWord" 1
                            Set-RegSafe "HKLM:\SYSTEM\Maps" "AutoUpdateEnabled" "DWord" 1
                            Set-SvcSafe "lfsvc" "Manual" $false
                            Log-Bg "[UNDO] Konum takibi ve lfsvc servisi varsayilana donduruldu."
                        }
                    }
                    "Tweak_AdvertisingId" {
                        if (-not $undo) {
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" "Enabled" "DWord" 0
                            Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" "DisabledByGroupPolicy" "DWord" 1
                            Log-Bg "[OK] Reklam Kimligi (Advertising ID) devre disi birakildi."
                        } else {
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" "Enabled" "DWord" 1
                            Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" "DisabledByGroupPolicy" "DWord" "<RemoveEntry>"
                            Log-Bg "[UNDO] Reklam Kimligi varsayilana donduruldu."
                        }
                    }
                    "Tweak_BingSearch" {
                        if (-not $undo) {
                            Set-RegSafe "HKCU:\Software\Policies\Microsoft\Windows\Explorer" "DisableSearchBoxSuggestions" "DWord" 1
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" "BingSearchEnabled" "DWord" 0
                            Log-Bg "[OK] Baslat menusu Bing web arama sonuclari kapatildi."
                        } else {
                            Set-RegSafe "HKCU:\Software\Policies\Microsoft\Windows\Explorer" "DisableSearchBoxSuggestions" "DWord" "<RemoveEntry>"
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" "BingSearchEnabled" "DWord" 1
                            Log-Bg "[UNDO] Baslat menusu Bing web aramalari varsayilana donduruldu."
                        }
                    }
                    "Tweak_ConsumerFeatures" {
                        if (-not $undo) {
                            Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" "DisableWindowsConsumerFeatures" "DWord" 1
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SubscribedContent-338387Enabled" "DWord" 0
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "RotatingLockScreenOverlayEnabled" "DWord" 0
                            Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization" "NoLockScreen" "DWord" 0
                            Log-Bg "[OK] Microsoft tuketici deneyimleri (ConsumerFeatures) ve kilit ekrani ipuclari kapatildi."
                        } else {
                            Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" "DisableWindowsConsumerFeatures" "DWord" "<RemoveEntry>"
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SubscribedContent-338387Enabled" "DWord" 1
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "RotatingLockScreenOverlayEnabled" "DWord" 1
                            Log-Bg "[UNDO] Microsoft tuketici deneyimleri varsayilana donduruldu."
                        }
                    }
                    "Tweak_ErrorReporting" {
                        if (-not $undo) {
                            Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting" "Disabled" "DWord" 1
                            Set-SvcSafe "WerSvc" "Disabled" $true
                            Log-Bg "[OK] Windows Hata Bildirimi (WerFault / WerSvc) devre disi birakildi."
                        } else {
                            Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting" "Disabled" "DWord" 0
                            Set-SvcSafe "WerSvc" "Manual" $false
                            Log-Bg "[UNDO] Windows Hata Bildirimi varsayilana donduruldu."
                        }
                    }
                    "Tweak_DeliveryOpt" {
                        if (-not $undo) {
                            Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" "DODownloadMode" "DWord" 0
                            Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" "DODownloadMode" "DWord" 0
                            Log-Bg "[OK] Teslim En Iyilestirme (P2P Guncelleme Paylasimi) kapatildi."
                        } else {
                            Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" "DODownloadMode" "DWord" "<RemoveEntry>"
                            Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" "DODownloadMode" "DWord" "<RemoveEntry>"
                            Log-Bg "[UNDO] Teslim En Iyilestirme varsayilana donduruldu."
                        }
                    }
                    "Tweak_WPBT" {
                        if (-not $undo) {
                            Set-RegSafe "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" "DisableWpbtExecution" "DWord" 1
                            Log-Bg "[OK] Windows Platform Binary Table (WPBT) devre disi birakildi."
                        } else {
                            Set-RegSafe "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" "DisableWpbtExecution" "DWord" "<RemoveEntry>"
                            Log-Bg "[UNDO] WPBT ayari varsayilana donduruldu."
                        }
                    }
                    "Tweak_DeviceMetadata" {
                        if (-not $undo) {
                            Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Device Metadata" "PreventDeviceMetadataFromNetwork" "DWord" 1
                            Log-Bg "[OK] Cihaz eslikci uygulamalarinin agdan otomatik indirilmesi engellendi."
                        } else {
                            Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Device Metadata" "PreventDeviceMetadataFromNetwork" "DWord" "<RemoveEntry>"
                            Log-Bg "[UNDO] Cihaz metadata ayari varsayilana donduruldu."
                        }
                    }
                    "Tweak_StoreSearch" {
                        $storeDb = "$env:LocalAppData\Packages\Microsoft.WindowsStore_8wekyb3d8bbwe\LocalState\store.db"
                        if (-not $undo) {
                            if (Test-Path $storeDb) { icacls $storeDb /deny "*S-1-1-0:F" | Out-Null }
                            Log-Bg "[OK] Baslat menusunde Microsoft Store uygulama onerileri engellendi."
                        } else {
                            if (Test-Path $storeDb) { icacls $storeDb /grant "*S-1-1-0:F" | Out-Null }
                            Log-Bg "[UNDO] Microsoft Store arama onerisi izni geri verildi."
                        }
                    }
                    "Tweak_ExplorerAutoDiscovery" {
                        $bags = "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags"
                        $bagMRU = "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\BagMRU"
                        $allFolders = "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags\AllFolders\Shell"
                        Remove-Item -Path $bags -Recurse -Force -ErrorAction SilentlyContinue
                        Remove-Item -Path $bagMRU -Recurse -Force -ErrorAction SilentlyContinue
                        if (-not $undo) {
                            Set-RegSafe $allFolders "FolderType" "String" "NotSpecified"
                            Log-Bg "[OK] Dosya Gezgini otomatik klasor algilama kapatildi (Genel hizli gorunum)."
                        } else {
                            Log-Bg "[UNDO] Dosya Gezgini klasor gorunum veritabani sifirlandi."
                        }
                    }
                    "Tweak_EndTaskOnTaskbar" {
                        if (-not $undo) {
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings" "TaskbarEndTask" "DWord" 1
                            Log-Bg "[OK] Gorev cubugundan sag tikla 'Gorevi Sonlandir' ozelligi acildi."
                        } else {
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings" "TaskbarEndTask" "DWord" "<RemoveEntry>"
                            Log-Bg "[UNDO] Gorev cubugu Gorevi Sonlandir secenegi kapatildi."
                        }
                    }
                    "Tweak_UltimatePerf" {
                        if (-not $undo) {
                            $ultOut = powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 2>&1 | Out-String
                            if ($ultOut -match '([a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12})') {
                                powercfg -setactive $matches[1] | Out-Null
                            }
                            Log-Bg "[OK] Nihai Performans (Ultimate Performance) guc plani olusturuldu ve aktif edildi."
                        } else {
                            powercfg -setactive 381b4222-f694-41f0-9685-ff5bb260df2e | Out-Null
                            Log-Bg "[UNDO] Dengeli (Balanced) standart guc planina geri donuldu."
                        }
                    }
                    "Tweak_MouseAccel" {
                        if (-not $undo) {
                            Set-RegSafe "HKCU:\Control Panel\Mouse" "MouseSpeed" "String" "0"
                            Set-RegSafe "HKCU:\Control Panel\Mouse" "MouseThreshold1" "String" "0"
                            Set-RegSafe "HKCU:\Control Panel\Mouse" "MouseThreshold2" "String" "0"
                            Log-Bg "[OK] Fare ivmesi (Enhance Pointer Precision) kapatildi (1:1 ham giris)."
                        } else {
                            Set-RegSafe "HKCU:\Control Panel\Mouse" "MouseSpeed" "String" "1"
                            Set-RegSafe "HKCU:\Control Panel\Mouse" "MouseThreshold1" "String" "6"
                            Set-RegSafe "HKCU:\Control Panel\Mouse" "MouseThreshold2" "String" "10"
                            Log-Bg "[UNDO] Fare ivmesi varsayilan Windows degerlerine (1 / 6 / 10) donduruldu."
                        }
                    }
                    "Tweak_GameDVR" {
                        if (-not $undo) {
                            Set-RegSafe "HKCU:\System\GameConfigStore" "GameDVR_Enabled" "DWord" 0
                            Set-RegSafe "HKCU:\System\GameConfigStore" "GameDVR_FSEBehaviorMode" "DWord" 2
                            Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" "AllowGameDVR" "DWord" 0
                            Set-RegSafe "HKCU:\Software\Microsoft\GameBar" "AllowAutoGameMode" "DWord" 1
                            Set-RegSafe "HKCU:\Software\Microsoft\GameBar" "AutoGameModeEnabled" "DWord" 1
                            Log-Bg "[OK] Xbox GameDVR arka plan kaydi kapatildi ve Oyun Modu (Game Mode) acildi."
                        } else {
                            Set-RegSafe "HKCU:\System\GameConfigStore" "GameDVR_Enabled" "DWord" 1
                            Set-RegSafe "HKCU:\System\GameConfigStore" "GameDVR_FSEBehaviorMode" "DWord" 0
                            Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" "AllowGameDVR" "DWord" "<RemoveEntry>"
                            Log-Bg "[UNDO] Xbox GameDVR varsayilan duruma donduruldu."
                        }
                    }
                    "Tweak_NetworkThrottling" {
                        $mmPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
                        if (-not $undo) {
                            if (!(Test-Path $mmPath)) { New-Item -Path $mmPath -Force | Out-Null }
                            reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v NetworkThrottlingIndex /t REG_DWORD /d 0xffffffff /f | Out-Null
                            Log-Bg "[OK] Ag trafigi kisitlamasi kaldirildi (NetworkThrottlingIndex = 0xFFFFFFFF)."
                        } else {
                            Set-RegSafe $mmPath "NetworkThrottlingIndex" "DWord" 10
                            Log-Bg "[UNDO] NetworkThrottlingIndex varsayilan degere (10) donduruldu."
                        }
                    }
                    "Tweak_SystemResponsiveness" {
                        $mmPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
                        if (-not $undo) {
                            Set-RegSafe $mmPath "SystemResponsiveness" "DWord" 0
                            Log-Bg "[OK] Sistem tepkiselligi ve oyun onceligi %100 yapildi (SystemResponsiveness = 0)."
                        } else {
                            Set-RegSafe $mmPath "SystemResponsiveness" "DWord" 20
                            Log-Bg "[UNDO] SystemResponsiveness varsayilan degere (20) donduruldu."
                        }
                    }
                    "Tweak_TCPNoDelay" {
                        $tcpInterfaces = Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces" -ErrorAction SilentlyContinue
                        if (-not $undo) {
                            foreach ($ifc in $tcpInterfaces) {
                                Set-ItemProperty -Path $ifc.PSPath -Name "TcpAckFrequency" -Type DWord -Value 1 -Force -ErrorAction SilentlyContinue
                                Set-ItemProperty -Path $ifc.PSPath -Name "TCPNoDelay" -Type DWord -Value 1 -Force -ErrorAction SilentlyContinue
                            }
                            Log-Bg "[OK] Nagle Algoritmasi (TCPNoDelay & TcpAckFrequency) devre disi birakildi."
                        } else {
                            foreach ($ifc in $tcpInterfaces) {
                                Remove-ItemProperty -Path $ifc.PSPath -Name "TcpAckFrequency" -Force -ErrorAction SilentlyContinue
                                Remove-ItemProperty -Path $ifc.PSPath -Name "TCPNoDelay" -Force -ErrorAction SilentlyContinue
                            }
                            Log-Bg "[UNDO] Nagle Algoritmasi (TCPNoDelay) varsayilan duruma donduruldu."
                        }
                    }
                    "Tweak_GreenEthernet" {
                        $val = if ($undo) { 1 } else { 0 }
                        Get-NetAdapterAdvancedProperty -DisplayName "*Energy Efficient Ethernet*" -ErrorAction SilentlyContinue | Set-NetAdapterAdvancedProperty -RegistryValue $val -ErrorAction SilentlyContinue
                        Get-NetAdapterAdvancedProperty -DisplayName "*Green Ethernet*" -ErrorAction SilentlyContinue | Set-NetAdapterAdvancedProperty -RegistryValue $val -ErrorAction SilentlyContinue
                        Get-NetAdapterAdvancedProperty -DisplayName "*Power Saving*" -ErrorAction SilentlyContinue | Set-NetAdapterAdvancedProperty -RegistryValue $val -ErrorAction SilentlyContinue
                        if (-not $undo) {
                            Log-Bg "[OK] Green Ethernet ve ag karti enerji tasarrufu modlari kapatildi."
                        } else {
                            Log-Bg "[UNDO] Green Ethernet enerji tasarrufu modlari varsayilana donduruldu."
                        }
                    }
                    "Tweak_Hibernation" {
                        if (-not $undo) {
                            Set-RegSafe "HKLM:\System\CurrentControlSet\Control\Session Manager\Power" "HibernateEnabled" "DWord" 0
                            Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings" "ShowHibernateOption" "DWord" 0
                            powercfg.exe /hibernate off | Out-Null
                            Log-Bg "[OK] Hazirda bekletme (Hibernation) kapatildi, disk alani serbest birakildi."
                        } else {
                            Set-RegSafe "HKLM:\System\CurrentControlSet\Control\Session Manager\Power" "HibernateEnabled" "DWord" 1
                            Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings" "ShowHibernateOption" "DWord" 1
                            powercfg.exe /hibernate on | Out-Null
                            Log-Bg "[UNDO] Hazirda bekletme (Hibernation) yeniden etkinlestirildi."
                        }
                    }
                    "Tweak_BgApps" {
                        if (-not $undo) {
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" "GlobalUserDisabled" "DWord" 1
                            Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" "LetAppsRunInBackground" "DWord" 2
                            Log-Bg "[OK] Magaza uygulamalarinin arka planda calismasi engellendi."
                        } else {
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" "GlobalUserDisabled" "DWord" 0
                            Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" "LetAppsRunInBackground" "DWord" "<RemoveEntry>"
                            Log-Bg "[UNDO] Arka plan uygulama izinleri varsayilana donduruldu."
                        }
                    }
                    "Tweak_MultiplaneOverlay" {
                        if (-not $undo) {
                            Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows\Dwm" "OverlayTestMode" "DWord" 5
                            Set-RegSafe "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" "DisableOverlays" "DWord" 1
                            Log-Bg "[OK] Multiplane Overlay (MPO) devre disi birakildi."
                        } else {
                            Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows\Dwm" "OverlayTestMode" "DWord" "<RemoveEntry>"
                            Set-RegSafe "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" "DisableOverlays" "DWord" "<RemoveEntry>"
                            Log-Bg "[UNDO] Multiplane Overlay (MPO) varsayilana donduruldu."
                        }
                    }
                    "Tweak_VisualFX" {
                        if (-not $undo) {
                            Set-RegSafe "HKCU:\Control Panel\Desktop" "DragFullWindows" "String" "0"
                            Set-RegSafe "HKCU:\Control Panel\Desktop" "MenuShowDelay" "String" "10"
                            Set-RegSafe "HKCU:\Control Panel\Desktop\WindowMetrics" "MinAnimate" "String" "0"
                            Set-RegSafe "HKCU:\Control Panel\Keyboard" "KeyboardDelay" "String" "0"
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "ListviewAlphaSelect" "DWord" 0
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "ListviewShadow" "DWord" 0
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "TaskbarAnimations" "DWord" 0
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" "VisualFXSetting" "DWord" 3
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\DWM" "EnableAeroPeek" "DWord" 0
                            Set-RegSafe "HKCU:\Control Panel\Desktop" "UserPreferencesMask" "Binary" ([byte[]](144,18,3,128,16,0,0,0))
                            Log-Bg "[OK] MenuShowDelay (10ms) ve performans odakli gorsel efektler uygulandi."
                        } else {
                            Set-RegSafe "HKCU:\Control Panel\Desktop" "DragFullWindows" "String" "1"
                            Set-RegSafe "HKCU:\Control Panel\Desktop" "MenuShowDelay" "String" "400"
                            Set-RegSafe "HKCU:\Control Panel\Desktop\WindowMetrics" "MinAnimate" "String" "1"
                            Set-RegSafe "HKCU:\Control Panel\Keyboard" "KeyboardDelay" "String" "1"
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "ListviewAlphaSelect" "DWord" 1
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "ListviewShadow" "DWord" 1
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "TaskbarAnimations" "DWord" 1
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" "VisualFXSetting" "DWord" 1
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\DWM" "EnableAeroPeek" "DWord" 1
                            Set-RegSafe "HKCU:\Control Panel\Desktop" "UserPreferencesMask" "DWord" "<RemoveEntry>"
                            Log-Bg "[UNDO] Gorsel efektler ve MenuShowDelay (400ms) varsayilana donduruldu."
                        }
                    }
                    "Tweak_SSDTrim" {
                        if (-not $undo) {
                            fsutil behavior set DisableDeleteNotify 0 | Out-Null
                            Log-Bg "[OK] SSD TRIM ozelligi zorlandi ve dogrulandi (DisableDeleteNotify = 0)."
                        } else {
                            fsutil behavior set DisableDeleteNotify 0 | Out-Null
                            Log-Bg "[UNDO] SSD sagligi icin TRIM aktif tutuldu (DisableDeleteNotify = 0)."
                        }
                    }
                    "Tweak_Services" {
                        $svcList = @(
                            @{ Name = "CscService"; Apply = "Disabled"; Orig = "Manual" },
                            @{ Name = "DiagTrack"; Apply = "Disabled"; Orig = "Automatic" },
                            @{ Name = "MapsBroker"; Apply = "Manual"; Orig = "Automatic" },
                            @{ Name = "StorSvc"; Apply = "Manual"; Orig = "Automatic" },
                            @{ Name = "SharedAccess"; Apply = "Disabled"; Orig = "Automatic" },
                            @{ Name = "RemoteRegistry"; Apply = "Disabled"; Orig = "Disabled" },
                            @{ Name = "Fax"; Apply = "Disabled"; Orig = "Manual" },
                            @{ Name = "RetailDemo"; Apply = "Disabled"; Orig = "Manual" },
                            @{ Name = "WMPNetworkSvc"; Apply = "Disabled"; Orig = "Manual" },
                            @{ Name = "wisvc"; Apply = "Manual"; Orig = "Manual" },
                            @{ Name = "PhoneSvc"; Apply = "Manual"; Orig = "Manual" },
                            @{ Name = "PrintNotify"; Apply = "Manual"; Orig = "Manual" },
                            @{ Name = "PcaSvc"; Apply = "Manual"; Orig = "Automatic" },
                            @{ Name = "WSearch"; Apply = "Manual"; Orig = "AutomaticDelayedStart" }
                        )
                        foreach ($s in $svcList) {
                            $targetMode = if ($undo) { $s.Orig } else { $s.Apply }
                            Set-SvcSafe $s.Name $targetMode $false
                        }
                        if (-not $undo) {
                            Log-Bg "[OK] Arka plan servisleri Manuel/Devre Disi moduna optimize edildi."
                        } else {
                            Log-Bg "[UNDO] Arka plan servisleri varsayilan baslangic turlerine donduruldu."
                        }
                    }
                    "Tweak_DiskCleanup" {
                        if (-not $undo) {
                            Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
                            Remove-Item -Path "$env:SystemRoot\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
                            Remove-Item -Path "$env:SystemRoot\Prefetch\*" -Recurse -Force -ErrorAction SilentlyContinue
                            Remove-Item -Path "$env:SystemRoot\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction SilentlyContinue
                            Start-Process -FilePath "cleanmgr.exe" -ArgumentList "/d C: /VERYLOWDISK" -NoNewWindow -ErrorAction SilentlyContinue
                            ipconfig /flushdns | Out-Null
                            Log-Bg "[OK] Temp, Prefetch, Windows Update onbellegi ve DNS temizlendi; Cleanmgr baslatildi."
                        } else {
                            Log-Bg "[UNDO] Disk temizligi tek yonlu bir islemdir, silinen gecici dosyalar geri alinamaz."
                        }
                    }
                    "Tweak_StorageSense" {
                        if (-not $undo) {
                            Set-RegSafe "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" "01" "DWord" 0
                            Log-Bg "[OK] Akilli Depolama (Storage Sense) devre disi birakildi."
                        } else {
                            Set-RegSafe "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" "01" "DWord" 1
                            Log-Bg "[UNDO] Akilli Depolama (Storage Sense) yeniden acildi."
                        }
                    }
                    "Tweak_ReservedStorage" {
                        if (-not $undo) {
                            DISM.exe /Online /Set-ReservedStorageState /State:Disabled | Out-Null
                            Log-Bg "[OK] Windows Ayrilmis Depolama Alani (Reserved Storage) kapatildi."
                        } else {
                            DISM.exe /Online /Set-ReservedStorageState /State:Enabled | Out-Null
                            Log-Bg "[UNDO] Windows Ayrilmis Depolama Alani yeniden acildi."
                        }
                    }
                    "Tweak_SvcHostSplitting" {
                        if (-not $undo) {
                            $memKB = [int64]((Get-CimInstance Win32_PhysicalMemory -ErrorAction SilentlyContinue | Measure-Object Capacity -Sum).Sum / 1KB)
                            if ($memKB -gt 0) {
                                Set-RegSafe "HKLM:\SYSTEM\CurrentControlSet\Control" "SvcHostSplitThresholdInKB" "DWord" $memKB
                            }
                            Log-Bg "[OK] svchost.exe surec bolunmesi (SvcHostSplitThresholdInKB) devre disi birakildi."
                        } else {
                            Set-RegSafe "HKLM:\SYSTEM\CurrentControlSet\Control" "SvcHostSplitThresholdInKB" "DWord" 3670016
                            Log-Bg "[UNDO] svchost.exe surec bolunmesi varsayilana (3670016) donduruldu."
                        }
                    }
                    "Tweak_BitLocker" {
                        if (-not $undo) {
                            Disable-BitLocker -MountPoint $env:SystemDrive -ErrorAction SilentlyContinue | Out-Null
                            Log-Bg "[OK] Sistem surucusu icin BitLocker devre disi birakma komutu calistirildi."
                        } else {
                            Enable-BitLocker -MountPoint $env:SystemDrive -ErrorAction SilentlyContinue | Out-Null
                            Log-Bg "[UNDO] BitLocker etkinlestirme komutu calistirildi."
                        }
                    }
                    "Tweak_LongPaths" {
                        $val = if ($undo) { 0 } else { 1 }
                        Set-RegSafe "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" "LongPathsEnabled" "DWord" $val
                        Log-Bg "[OK] Uzun dosya yolu destegi (LongPathsEnabled = $val) ayarlandi."
                    }
                    "Tweak_UTC" {
                        $val = if ($undo) { 0 } else { 1 }
                        Set-RegSafe "HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation" "RealTimeIsUniversal" "QWord" $val
                        Log-Bg "[OK] Donanim saati UTC modu (RealTimeIsUniversal = $val) ayarlandi."
                    }
                    "Tweak_S0StandbyFix" {
                        $val = if ($undo) { 1 } else { 0 }
                        Set-RegSafe "HKCU:\SOFTWARE\Policies\Microsoft\Power\PowerSettings\f15576e8-98b7-4186-b944-eafa664402d9" "ACSettingIndex" "DWord" $val
                        Log-Bg "[OK] S0 Modern Uyku ag baglantisi (ACSettingIndex = $val) ayarlandi."
                    }
                    "Tweak_S3Sleep" {
                        if (-not $undo) {
                            Set-RegSafe "HKLM:\SYSTEM\CurrentControlSet\Control\Power" "PlatformAoAcOverride" "DWord" 0
                            Log-Bg "[OK] Klasik S3 Uyku modu (PlatformAoAcOverride = 0) etkinlestirildi."
                        } else {
                            Set-RegSafe "HKLM:\SYSTEM\CurrentControlSet\Control\Power" "PlatformAoAcOverride" "DWord" "<RemoveEntry>"
                            Log-Bg "[UNDO] Modern Standby varsayilanina donuldu."
                        }
                    }
                    "Tweak_ClassicContext" {
                        if (-not $undo) {
                            New-Item -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" -Value "" -Force -ErrorAction SilentlyContinue | Out-Null
                            Log-Bg "[OK] Windows 11 klasik sag tik menusu aktif edildi."
                        } else {
                            Remove-Item -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" -Recurse -Force -ErrorAction SilentlyContinue
                            Log-Bg "[UNDO] Windows 11 modern sag tik menusune geri donuldu."
                        }
                    }
                    "Tweak_FileExt" {
                        $val = if ($undo) { 1 } else { 0 }
                        Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "HideFileExt" "DWord" $val
                        Log-Bg "[OK] Bilinen dosya uzantilari gorunurlugu guncellendi (HideFileExt = $val)."
                    }
                    "Tweak_HiddenFiles" {
                        $val = if ($undo) { 2 } else { 1 }
                        Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "Hidden" "DWord" $val
                        Log-Bg "[OK] Gizli dosya ve klasor gorunurlugu guncellendi (Hidden = $val)."
                    }
                    "Tweak_HideTaskbarJunk" {
                        if (-not $undo) {
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "ShowTaskViewButton" "DWord" 0
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "TaskbarDa" "DWord" 0
                            Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Dsh" "AllowNewsAndInterests" "DWord" 0
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" "SearchboxTaskbarMode" "DWord" 0
                            Get-Process *Widget* -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
                            Log-Bg "[OK] Gorev cubugu Arama, Gorev Gorunumu ve Widget (Hava Durumu) simgeleri gizlendi."
                        } else {
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "ShowTaskViewButton" "DWord" 1
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "TaskbarDa" "DWord" 1
                            Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Dsh" "AllowNewsAndInterests" "DWord" "<RemoveEntry>"
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" "SearchboxTaskbarMode" "DWord" 1
                            Log-Bg "[UNDO] Gorev cubugu Arama, Gorev Gorunumu ve Widget simgeleri geri acildi."
                        }
                    }
                    "Tweak_DarkMode" {
                        $val = if ($undo) { 1 } else { 0 }
                        Set-RegSafe "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" "AppsUseLightTheme" "DWord" $val
                        Set-RegSafe "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" "SystemUsesLightTheme" "DWord" $val
                        if (-not $undo) {
                            Log-Bg "[OK] Sistem ve uygulama Koyu Tema (Dark Mode) etkinlestirildi."
                        } else {
                            Log-Bg "[UNDO] Acik Tema (Light Mode) etkinlestirildi."
                        }
                    }
                    "Tweak_StickyKeys" {
                        $val = if ($undo) { "510" } else { "506" }
                        Set-RegSafe "HKCU:\Control Panel\Accessibility\StickyKeys" "Flags" "String" $val
                        Log-Bg "[OK] Yapiskan Tuslar (Sticky Keys) kisayolu guncellendi (Flags = $val)."
                    }
                    "Tweak_ClassicPhotoViewer" {
                        $exts = @(".bmp", ".dib", ".gif", ".jfif", ".jpe", ".jpeg", ".jpg", ".png", ".tif", ".tiff", ".wdp")
                        $regBase = "HKLM:\SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities\FileAssociations"
                        if (-not $undo) {
                            foreach ($ext in $exts) {
                                Set-RegSafe $regBase $ext "String" "PhotoViewer.FileAssoc.Tiff"
                            }
                            Log-Bg "[OK] Klasik Windows Fotograf Goruntuleyicisi (Windows Photo Viewer) aktif edildi."
                        } else {
                            foreach ($ext in $exts) {
                                if (-not ($ext -in @(".tif", ".tiff"))) {
                                    Set-RegSafe $regBase $ext "String" "<RemoveEntry>"
                                }
                            }
                            Log-Bg "[UNDO] Klasik Windows Fotograf Goruntuleyicisi dosya iliskilendirmeleri kaldirildi."
                        }
                    }
                    "Tweak_RemoveHomeGallery" {
                        if (-not $undo) {
                            Set-RegSafe "HKCU:\Software\Classes\CLSID\{f874310e-b6b7-47dc-bc84-b9e6b38f5903}" "System.IsPinnedToNameSpaceTree" "DWord" 0
                            Set-RegSafe "HKCU:\Software\Classes\CLSID\{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}" "System.IsPinnedToNameSpaceTree" "DWord" 0
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "LaunchTo" "DWord" 1
                            Log-Bg "[OK] Dosya Gezgini Giris ve Galeri kaldirildi, varsayilan 'Bu Bilgisayar' yapildi."
                        } else {
                            Set-RegSafe "HKCU:\Software\Classes\CLSID\{f874310e-b6b7-47dc-bc84-b9e6b38f5903}" "System.IsPinnedToNameSpaceTree" "DWord" "<RemoveEntry>"
                            Set-RegSafe "HKCU:\Software\Classes\CLSID\{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}" "System.IsPinnedToNameSpaceTree" "DWord" "<RemoveEntry>"
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "LaunchTo" "DWord" "<RemoveEntry>"
                            Log-Bg "[UNDO] Dosya Gezgini Giris ve Galeri sekmeleri geri yuklendi."
                        }
                    }
                    "Tweak_TaskbarLeft" {
                        $val = if ($undo) { 1 } else { 0 }
                        Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "TaskbarAl" "DWord" $val
                        Log-Bg "[OK] Gorev cubugu hizalamasi guncellendi (TaskbarAl = $val)."
                    }
                    "Tweak_RevertStartMenu" {
                        if (-not $undo) {
                            Set-RegSafe "HKLM:\SYSTEM\ControlSet001\Control\FeatureManagement\Overrides\8\3036241548" "EnabledState" "DWord" 1
                            Set-RegSafe "HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device\Start" "HideRecommendedSection" "DWord" 1
                            Set-RegSafe "HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device\Education" "IsEducationEnvironment" "DWord" 1
                            Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" "HideRecommendedSection" "DWord" 1
                            Log-Bg "[OK] Baslat menusu Onerilenler bolumu gizlendi ve klasik duzen etkinlestirildi."
                        } else {
                            Set-RegSafe "HKLM:\SYSTEM\ControlSet001\Control\FeatureManagement\Overrides\8\3036241548" "EnabledState" "DWord" "<RemoveEntry>"
                            Set-RegSafe "HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device\Start" "HideRecommendedSection" "DWord" 0
                            Set-RegSafe "HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device\Education" "IsEducationEnvironment" "DWord" 0
                            Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" "HideRecommendedSection" "DWord" 0
                            Log-Bg "[UNDO] Baslat menusu Onerilenler bolumu varsayilana donduruldu."
                        }
                    }
                    "Tweak_NumLock" {
                        $val = if ($undo) { "0" } else { "2" }
                        Set-RegSafe "HKU:\.Default\Control Panel\Keyboard" "InitialKeyboardIndicators" "String" $val
                        Set-RegSafe "HKCU:\Control Panel\Keyboard" "InitialKeyboardIndicators" "String" $val
                        Log-Bg "[OK] Acilista Num Lock durumu guncellendi (InitialKeyboardIndicators = $val)."
                    }
                    "Tweak_DetailedBSoD" {
                        $val = if ($undo) { 0 } else { 1 }
                        Set-RegSafe "HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl" "DisplayParameters" "DWord" $val
                        Set-RegSafe "HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl" "DisableEmoticon" "DWord" $val
                        Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "VerboseStatus" "DWord" $val
                        Log-Bg "[OK] Ayrintili Mavi Ekran (BSoD) ve Verbose Logon durumu ($val) ayarlandi."
                    }
                    "Tweak_BatteryPct" {
                        if (-not $undo) {
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "IsBatteryPercentageEnabled" "DWord" 1
                            Set-RegSafe "HKCU:\Control Panel\Accessibility" "DynamicScrollbars" "DWord" 0
                            Log-Bg "[OK] Pil yuzdesi gosterimi ve sabit kaydirma cubuklari acildi."
                        } else {
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "IsBatteryPercentageEnabled" "DWord" "<RemoveEntry>"
                            Set-RegSafe "HKCU:\Control Panel\Accessibility" "DynamicScrollbars" "DWord" 1
                            Log-Bg "[UNDO] Pil yuzdesi ve kaydirma cubuklari varsayilana donduruldu."
                        }
                    }
                    "Tweak_HideSettingsHome" {
                        if (-not $undo) {
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" "SettingsPageVisibility" "String" "hide:home"
                            Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "DisableAcrylicBackgroundOnLogon" "DWord" 1
                            Log-Bg "[OK] Ayarlar Giris (Home) sekmesi ve kilit ekrani bulanikligi kapatildi."
                        } else {
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" "SettingsPageVisibility" "String" "show:home"
                            Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "DisableAcrylicBackgroundOnLogon" "DWord" 0
                            Log-Bg "[UNDO] Ayarlar Giris sekmesi ve kilit ekrani bulanikligi geri acildi."
                        }
                    }
                    "Tweak_DeepOneDrive" {
                        if (-not $undo) {
                            Stop-Process -Name "OneDrive" -Force -ErrorAction SilentlyContinue
                            $odSetup = "$env:SystemRoot\SysWOW64\OneDriveSetup.exe"
                            if (!(Test-Path $odSetup)) { $odSetup = "$env:SystemRoot\System32\OneDriveSetup.exe" }
                            if (Test-Path $odSetup) {
                                Start-Process -FilePath $odSetup -ArgumentList "/uninstall" -NoNewWindow -Wait -ErrorAction SilentlyContinue
                            }
                            Set-RegSafe "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" "System.IsPinnedToNameSpaceTree" "DWord" 0
                            Set-RegSafe "HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" "System.IsPinnedToNameSpaceTree" "DWord" 0
                            Remove-Item -Path "HKCU:\Software\Classes\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" -Recurse -Force -ErrorAction SilentlyContinue
                            if (Test-Path "HKLM:\SYSTEM\CurrentControlSet\Services\OneSyncSvc") {
                                Set-SvcSafe "OneSyncSvc" "Disabled" $false
                            }
                            Log-Bg "[OK] OneDrive kokten kaldirildi ve Gezgin sol panel CLSID kalintilari temizlendi."
                        } else {
                            Start-Process -FilePath "winget.exe" -ArgumentList "install --id Microsoft.OneDrive -e --silent --accept-package-agreements --accept-source-agreements" -NoNewWindow -Wait -ErrorAction SilentlyContinue
                            if (Test-Path "HKLM:\SYSTEM\CurrentControlSet\Services\OneSyncSvc") {
                                Set-SvcSafe "OneSyncSvc" "Automatic" $false
                            }
                            Log-Bg "[UNDO] OneDrive Winget uzerinden yeniden kuruldu."
                        }
                    }
                    "Tweak_DisableCopilotAI" {
                        if (-not $undo) {
                            Set-RegSafe "HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot" "TurnOffWindowsCopilot" "DWord" 1
                            Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" "TurnOffWindowsCopilot" "DWord" 1
                            Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" "DisableAIDataAnalysis" "DWord" 1
                            Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" "TurnOffSavingSnapshots" "DWord" 1
                            Set-RegSafe "HKLM:\SOFTWARE\Policies\WindowsNotepad" "DisableAIFeatures" "DWord" 1
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "ShowCopilotButton" "DWord" 0
                            Set-SvcSafe "WSAIFabricSvc" "Disabled" $true
                            Get-AppxPackage -AllUsers "*Copilot*" -ErrorAction SilentlyContinue | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
                            Start-Process -FilePath "dism.exe" -ArgumentList "/Online /Disable-Feature /FeatureName:Recall /NoRestart" -NoNewWindow -Wait -ErrorAction SilentlyContinue
                            Log-Bg "[OK] Copilot, Windows Recall ve AI bilesenleri tamamen devre disi birakildi."
                        } else {
                            Set-RegSafe "HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot" "TurnOffWindowsCopilot" "DWord" "<RemoveEntry>"
                            Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" "TurnOffWindowsCopilot" "DWord" "<RemoveEntry>"
                            Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" "DisableAIDataAnalysis" "DWord" "<RemoveEntry>"
                            Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" "TurnOffSavingSnapshots" "DWord" "<RemoveEntry>"
                            Set-RegSafe "HKLM:\SOFTWARE\Policies\WindowsNotepad" "DisableAIFeatures" "DWord" "<RemoveEntry>"
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "ShowCopilotButton" "DWord" 1
                            Set-SvcSafe "WSAIFabricSvc" "Manual" $false
                            Log-Bg "[UNDO] Copilot ve Windows AI kisitlama ilkeleri kaldirildi."
                        }
                    }
                    "Tweak_EdgeDebloat" {
                        $edgePol = "HKLM:\SOFTWARE\Policies\Microsoft\Edge"
                        $edgeKeys = @(
                            "PersonalizationReportingEnabled", "ShowRecommendationsEnabled", "UserFeedbackAllowed",
                            "AlternateErrorPagesEnabled", "EdgeCollectionsEnabled", "EdgeShoppingAssistantEnabled",
                            "MicrosoftEdgeInsiderPromotionEnabled", "ShowMicrosoftRewards", "WebWidgetAllowed",
                            "DiagnosticData", "EdgeAssetDeliveryServiceEnabled", "WalletDonationEnabled",
                            "DefaultBrowserSettingsCampaignEnabled", "StartupBoostEnabled", "BackgroundModeEnabled"
                        )
                        if (-not $undo) {
                            Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\EdgeUpdate" "CreateDesktopShortcutDefault" "DWord" 0
                            Set-RegSafe $edgePol "HideFirstRunExperience" "DWord" 1
                            Set-RegSafe $edgePol "ConfigureDoNotTrack" "DWord" 1
                            foreach ($k in $edgeKeys) { Set-RegSafe $edgePol $k "DWord" 0 }
                            Stop-Process -Name "msedge" -Force -ErrorAction SilentlyContinue
                            Log-Bg "[OK] Microsoft Edge 17 gizlilik/izolasyon ilkesi uygulandi ve arka plan kapatildi."
                        } else {
                            Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\EdgeUpdate" "CreateDesktopShortcutDefault" "DWord" "<RemoveEntry>"
                            Set-RegSafe $edgePol "HideFirstRunExperience" "DWord" "<RemoveEntry>"
                            Set-RegSafe $edgePol "ConfigureDoNotTrack" "DWord" "<RemoveEntry>"
                            foreach ($k in $edgeKeys) { Set-RegSafe $edgePol $k "DWord" "<RemoveEntry>" }
                            Log-Bg "[UNDO] Microsoft Edge kisitlama ilkeleri varsayilana sifirlandi."
                        }
                    }
                    "Tweak_RemoveEdge" {
                        if (-not $undo) {
                            $edgeAppDir = "${env:ProgramFiles(x86)}\Microsoft\Edge\Application"
                            if (Test-Path $edgeAppDir) {
                                $setupPath = Get-ChildItem -Path $edgeAppDir -Filter "setup.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -Last 1
                                if ($setupPath) {
                                    New-Item -Path "$env:SystemRoot\SystemApps\Microsoft.MicrosoftEdge_8wekyb3d8bbwe\MicrosoftEdge.exe" -Force -ErrorAction SilentlyContinue | Out-Null
                                    Start-Process -FilePath $setupPath.FullName -ArgumentList "--uninstall --system-level --force-uninstall --delete-profile" -NoNewWindow -Wait -ErrorAction SilentlyContinue
                                    Log-Bg "[OK] Microsoft Edge sistem duzeyinde kaldirildi."
                                }
                            } else {
                                Log-Bg "[!] Microsoft Edge zaten kurulu degil."
                            }
                        } else {
                            Start-Process -FilePath "winget.exe" -ArgumentList "install --id Microsoft.Edge -e --silent --accept-package-agreements --accept-source-agreements" -NoNewWindow -Wait -ErrorAction SilentlyContinue
                            Log-Bg "[UNDO] Microsoft Edge Winget uzerinden yeniden kuruldu."
                        }
                    }
                    "Tweak_BraveDebloat" {
                        $bravePol = "HKLM:\SOFTWARE\Policies\BraveSoftware\Brave"
                        if (-not $undo) {
                            Set-RegSafe $bravePol "BraveRewardsDisabled" "DWord" 1
                            Set-RegSafe $bravePol "BraveWalletDisabled" "DWord" 1
                            Set-RegSafe $bravePol "BraveVPNDisabled" "DWord" 1
                            Set-RegSafe $bravePol "BraveAIChatEnabled" "DWord" 0
                            Set-RegSafe $bravePol "BraveStatsPingEnabled" "DWord" 0
                            Set-RegSafe $bravePol "BraveNewsDisabled" "DWord" 1
                            Set-RegSafe $bravePol "BraveTalkDisabled" "DWord" 1
                            Set-RegSafe $bravePol "TorDisabled" "DWord" 1
                            Set-RegSafe $bravePol "BraveP3AEnabled" "DWord" 0
                            Set-RegSafe $bravePol "MetricsReportingEnabled" "DWord" 0
                            Log-Bg "[OK] Brave Browser (Rewards, Wallet, Leo AI, VPN, Telemetri) debloat ilkeleri uygulandi."
                        } else {
                            Remove-Item -Path $bravePol -Recurse -Force -ErrorAction SilentlyContinue
                            Log-Bg "[UNDO] Brave Browser ilkeleri varsayilana sifirlandi."
                        }
                    }
                    "Tweak_PeripheralBlock" {
                        $razerPath = "$env:SystemRoot\Installer\Razer"
                        $prog64 = if ($env:ProgramW6432) { $env:ProgramW6432 } else { $env:ProgramFiles }
                        $logiPath = "$prog64\LogiDownloadAssistant"
                        if (-not $undo) {
                            Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching" "SearchOrderConfig" "DWord" 0
                            Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Installer" "DisableCoInstallers" "DWord" 1
                            Stop-Process -Name "logi_download_assistant" -Force -ErrorAction SilentlyContinue
                            if (!(Test-Path $razerPath)) { New-Item -Path $razerPath -ItemType Directory -Force | Out-Null }
                            if (!(Test-Path $logiPath)) { New-Item -Path $logiPath -ItemType Directory -Force | Out-Null }
                            icacls $razerPath /deny "*S-1-1-0:(W)" | Out-Null
                            icacls $logiPath /deny "*S-1-1-0:(W)" | Out-Null
                            Log-Bg "[OK] Razer Synapse ve Logitech Download Assistant otomatik kurulumu engellendi."
                        } else {
                            Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching" "SearchOrderConfig" "DWord" 1
                            Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Installer" "DisableCoInstallers" "DWord" 0
                            if (Test-Path $razerPath) { icacls $razerPath /remove:d "*S-1-1-0" | Out-Null }
                            if (Test-Path $logiPath) { icacls $logiPath /remove:d "*S-1-1-0" | Out-Null }
                            Log-Bg "[UNDO] Razer ve Logitech klasor yazma engelleri kaldirildi."
                        }
                    }
                    "Tweak_BlockAdobeNet" {
                        $hostsFile = "$env:SystemRoot\System32\drivers\etc\hosts"
                        if (-not $undo) {
                            $adobeRules = "`r`n#New Ver Adobe Block`r`n0.0.0.0 ic.adobe.io`r`n0.0.0.0 genuine.adobe.com`r`n0.0.0.0 prod.adobegenuine.com`r`n0.0.0.0 lm.licenses.adobe.com`r`n"
                            Add-Content -Path $hostsFile -Value $adobeRules -ErrorAction SilentlyContinue
                            ipconfig /flushdns | Out-Null
                            Log-Bg "[OK] Adobe telemetri ve dogrulama sunuculari hosts dosyasinda engellendi."
                        } else {
                            if (Test-Path $hostsFile) {
                                $c = (Get-Content $hostsFile -Raw) -replace '(?s)#New Ver Adobe Block.*', ''
                                Set-Content -Path $hostsFile -Value $c.TrimEnd() -Force -ErrorAction SilentlyContinue
                            }
                            ipconfig /flushdns | Out-Null
                            Log-Bg "[UNDO] Adobe hosts engelleme kurallari temizlendi."
                        }
                    }
                    "Tweak_IPv4Prefer" {
                        if (-not $undo) {
                            Set-RegSafe "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" "DisabledComponents" "DWord" 32
                            netsh interface teredo set state disabled | Out-Null
                            Log-Bg "[OK] IPv4 onceligi (DisabledComponents=32) aktif edildi ve Teredo kapatildi."
                        } else {
                            Set-RegSafe "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" "DisabledComponents" "DWord" 0
                            netsh interface teredo set state default | Out-Null
                            Log-Bg "[UNDO] IPv4/IPv6 onceligi ve Teredo varsayilana donduruldu."
                        }
                    }
                    "Tweak_DisableIPv6" {
                        if (-not $undo) {
                            Set-RegSafe "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" "DisabledComponents" "DWord" 255
                            Disable-NetAdapterBinding -Name "*" -ComponentID ms_tcpip6 -ErrorAction SilentlyContinue
                            Log-Bg "[OK] IPv6 tum ag bagdastiricilarinda devre disi birakildi."
                        } else {
                            Set-RegSafe "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" "DisabledComponents" "DWord" 0
                            Enable-NetAdapterBinding -Name "*" -ComponentID ms_tcpip6 -ErrorAction SilentlyContinue
                            Log-Bg "[UNDO] IPv6 tum ag bagdastiricilarinda yeniden etkinlestirildi."
                        }
                    }
                    "Tweak_DisableNotifications" {
                        if (-not $undo) {
                            Set-RegSafe "HKCU:\Software\Policies\Microsoft\Windows\Explorer" "DisableNotificationCenter" "DWord" 1
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\PushNotifications" "ToastEnabled" "DWord" 0
                            Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\Client" "RedirectionWarningDialogVersion" "DWord" 1
                            Set-RegSafe "HKCU:\SOFTWARE\Microsoft\Terminal Server Client" "RdpLaunchConsentAccepted" "DWord" 1
                            Log-Bg "[OK] Bildirim Merkezi ve imzasiz RDP dosyalari uyarilari kapatildi."
                        } else {
                            Set-RegSafe "HKCU:\Software\Policies\Microsoft\Windows\Explorer" "DisableNotificationCenter" "DWord" "<RemoveEntry>"
                            Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\PushNotifications" "ToastEnabled" "DWord" 1
                            Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\Client" "RedirectionWarningDialogVersion" "DWord" "<RemoveEntry>"
                            Log-Bg "[UNDO] Bildirim Merkezi ve RDP uyarilari varsayilana donduruldu."
                        }
                    }
                    "Tweak_NewOutlookBlock" {
                        if (-not $undo) {
                            Set-RegSafe "HKCU:\SOFTWARE\Microsoft\Office\16.0\Outlook\Preferences" "UseNewOutlook" "DWord" 0
                            Set-RegSafe "HKCU:\Software\Microsoft\Office\16.0\Outlook\Options\General" "HideNewOutlookToggle" "DWord" 1
                            Set-RegSafe "HKCU:\Software\Policies\Microsoft\Office\16.0\Outlook\Options\General" "DoNewOutlookAutoMigration" "DWord" 0
                            Log-Bg "[OK] Yeni Outlook otomatik gecisi ve zorlamasi engellendi."
                        } else {
                            Set-RegSafe "HKCU:\SOFTWARE\Microsoft\Office\16.0\Outlook\Preferences" "UseNewOutlook" "DWord" 1
                            Set-RegSafe "HKCU:\Software\Microsoft\Office\16.0\Outlook\Options\General" "HideNewOutlookToggle" "DWord" 0
                            Log-Bg "[UNDO] Yeni Outlook secenegi varsayilana donduruldu."
                        }
                    }
                }
            } catch {
                Log-Bg "[!] $($tw.Id) islem uyarisi: $($_.Exception.Message)"
            }
        }
        Status-Bg "Secili sistem ince ayarlari tamamlandi ($($list.Count) / $($list.Count))!" 100
        Log-Bg "=== SISTEM INCE AYARLARI ISLEMI TAMAMLANDI ==="
    }
}

$script:BtnApplyTweaks.Add_Click({
    $sel = @($script:tweakCheckboxes | Where-Object { $_.IsChecked -eq $true } | ForEach-Object { $_.Tag })
    Start-TweaksEngine $sel $false
})

$script:BtnUndoTweaks.Add_Click({
    $sel = @($script:tweakCheckboxes | Where-Object { $_.IsChecked -eq $true } | ForEach-Object { $_.Tag })
    Start-TweaksEngine $sel $true
})

$script:BtnRevertContextMenu.Add_Click({
    Remove-Item -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" -Recurse -Force -ErrorAction SilentlyContinue
    Write-UiLog (Decode-U "[OK] Windows 11 varsay\u0131lan sa\u011F t\u0131k men\u00FCs\u00FCne d\u00F6n\u00FCld\u00FC.")
})

$script:BtnCleanTemp.Add_Click({
    Start-BackgroundTask "DiskClean" @{} {
        Status-Bg "Temp, Prefetch, Windows Update onbellegi ve DNS temizleniyor..." 40
        Log-Bg ">>> Kapsamli Disk, Temp, Prefetch ve DNS temizligi baslatildi..."
        Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "$env:SystemRoot\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "$env:SystemRoot\Prefetch\*" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "$env:SystemRoot\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction SilentlyContinue
        Start-Process -FilePath "cleanmgr.exe" -ArgumentList "/d C: /VERYLOWDISK" -NoNewWindow -ErrorAction SilentlyContinue
        ipconfig /flushdns | Out-Null
        Status-Bg "Disk, Temp ve DNS onbellegi basariyla temizlendi!" 100
        Log-Bg "[OK] Gecici dosyalar, Prefetch ve DNS onbellegi temizlendi."
    }
})

# =============================================================================
# 6. SEKME 3: HIZLI DNS, DERIN TEMIZLIK, WINDOWS UPDATE & DISM MOTORU
# =============================================================================
function Set-ActiveAdapterDns([string[]]$dnsV4, [string[]]$dnsV6, [string]$providerName) {
    try {
        $adapters = @(Get-NetAdapter -ErrorAction SilentlyContinue | Where-Object { $_.Status -eq 'Up' -and $_.InterfaceDescription -notmatch 'Virtual|Hyper-V|vEthernet|TAP|VPN|Loopback|VMware|VirtualBox' })
        if ($adapters.Count -eq 0) {
            $adapters = @(Get-NetAdapter -ErrorAction SilentlyContinue | Where-Object { $_.Status -eq 'Up' })
        }
        if ($adapters.Count -eq 0) {
            Write-UiLog (Decode-U "[!] Aktif bir fiziksel a\u011F ba\u011Fda\u015Ft\u0131r\u0131c\u0131s\u0131 bulunamad\u0131.")
            return
        }
        foreach ($nic in $adapters) {
            if ($dnsV4.Count -gt 0) {
                $allDns = $dnsV4 + $dnsV6
                Set-DnsClientServerAddress -InterfaceIndex $nic.InterfaceIndex -ServerAddresses $allDns -ErrorAction SilentlyContinue
                if (-not $?) {
                    Set-DnsClientServerAddress -InterfaceIndex $nic.InterfaceIndex -ServerAddresses $dnsV4 -ErrorAction Stop
                }
                Write-UiLog (Decode-U "[OK] [$($nic.Name)] i\u00E7in $providerName atand\u0131: $($dnsV4 -join ', ')")
            } else {
                Set-DnsClientServerAddress -InterfaceIndex $nic.InterfaceIndex -ResetServerAddresses -ErrorAction Stop
                Write-UiLog (Decode-U "[OK] [$($nic.Name)] DNS ayarlar\u0131 varsay\u0131lan (Otomatik DHCP) moduna d\u00F6nd\u00FCr\u00FCld\u00FC.")
            }
        }
        ipconfig /flushdns | Out-Null
        $script:TxtDnsStatus.Text = (Decode-U "Aktif DNS: $providerName ($($adapters[0].Name))")
        Set-UiStatus (Decode-U "DNS g\u00FCncellendi: $providerName") 100
    } catch {
        Write-UiLog "[HATA] DNS degistirilemedi: $($_.Exception.Message)"
    }
}

$script:BtnDnsCloudflare.Add_Click({ Set-ActiveAdapterDns @("1.1.1.1", "1.0.0.1") @("2606:4700:4700::1111", "2606:4700:4700::1001") "Cloudflare DNS (1.1.1.1)" })
$script:BtnDnsGoogle.Add_Click({ Set-ActiveAdapterDns @("8.8.8.8", "8.8.4.4") @("2001:4860:4860::8888", "2001:4860:4860::8844") "Google DNS (8.8.8.8)" })
$script:BtnDnsAdguard.Add_Click({ Set-ActiveAdapterDns @("94.140.14.14", "94.140.15.15") @("2a10:50c0::ad1:ff", "2a10:50c0::ad2:ff") "AdGuard Reklam Engelleyici DNS" })
$script:BtnDnsQuad9.Add_Click({ Set-ActiveAdapterDns @("9.9.9.9", "149.112.112.112") @("2620:fe::fe", "2620:fe::9") "Quad9 Guvenlik DNS (9.9.9.9)" })
$script:BtnDnsCloudflareMalware.Add_Click({ Set-ActiveAdapterDns @("1.1.1.2", "1.0.0.2") @("2606:4700:4700::1112", "2606:4700:4700::1002") "Cloudflare Malware Engelleyici (1.1.1.2)" })
$script:BtnDnsOpenDns.Add_Click({ Set-ActiveAdapterDns @("208.67.222.222", "208.67.220.220") @("2620:119:35::35", "2620:119:53::53") "Cisco OpenDNS" })
$script:BtnDnsDhcp.Add_Click({ Set-ActiveAdapterDns @() @() "Varsayilan (Otomatik DHCP)" })

# Derin Temizlik Butonlari (Apply + Undo)
$script:BtnDeepOneDrive.Add_Click({
    Start-TweaksEngine @([PSCustomObject]@{ Id = "Tweak_DeepOneDrive"; Title = "OneDrive Kokten Kaldirma" }) $false
})
$script:BtnRestoreOneDrive.Add_Click({
    Start-TweaksEngine @([PSCustomObject]@{ Id = "Tweak_DeepOneDrive"; Title = "OneDrive Geri Yukleme" }) $true
})
$script:BtnDisableCopilot.Add_Click({
    Start-TweaksEngine @([PSCustomObject]@{ Id = "Tweak_DisableCopilotAI"; Title = "Copilot ve Recall Kapatma" }) $false
})
$script:BtnEnableCopilot.Add_Click({
    Start-TweaksEngine @([PSCustomObject]@{ Id = "Tweak_DisableCopilotAI"; Title = "Copilot ve Recall Geri Acma" }) $true
})
$script:BtnDisableEdgeBg.Add_Click({
    Start-TweaksEngine @([PSCustomObject]@{ Id = "Tweak_EdgeDebloat"; Title = "Edge Izolasyonu ve Debloat" }) $false
})
$script:BtnEnableEdgeBg.Add_Click({
    Start-TweaksEngine @([PSCustomObject]@{ Id = "Tweak_EdgeDebloat"; Title = "Edge Ilkelerini Sifirlama" }) $true
})

# Windows Update Akilli Yonetimi (3 Mod - WinUtil Birebir)
$script:BtnWinUpdateSecurity.Add_Click({
    Start-BackgroundTask "WinUpdate_Security" @{} {
        Status-Bg "Windows Update Guvenlik Odakli Mod uygulaniyor..." 50
        Log-Bg ">>> Windows Update: Guvenlik Odakli Mod (WinUtil Recommended) yapilandiriliyor..."
        $wuPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
        $auPath = Join-Path $wuPath "AU"

        Remove-ItemProperty -Path $auPath -Name "NoAutoUpdate" -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path $wuPath -Name "DisableWindowsUpdateAccess" -ErrorAction SilentlyContinue

        Set-SvcSafe "BITS" "Manual" $false
        Set-SvcSafe "wuauserv" "Manual" $false
        Set-SvcSafe "UsoSvc" "Automatic" $false
        Set-SvcSafe "dosvc" "Manual" $false
        Start-Service -Name "UsoSvc" -ErrorAction SilentlyContinue

        $tasks = @('\Microsoft\Windows\InstallService\*', '\Microsoft\Windows\UpdateOrchestrator\*', '\Microsoft\Windows\UpdateAssistant\*', '\Microsoft\Windows\WaaSMedic\*', '\Microsoft\Windows\WindowsUpdate\*', '\Microsoft\WindowsUpdate\*')
        foreach ($t in $tasks) { Get-ScheduledTask -TaskPath $t -ErrorAction SilentlyContinue | Enable-ScheduledTask -ErrorAction SilentlyContinue | Out-Null }

        Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Device Metadata" "PreventDeviceMetadataFromNetwork" "DWord" 1
        Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DriverSearching" "DontPromptForWindowsUpdate" "DWord" 1
        Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DriverSearching" "DontSearchWindowsUpdate" "DWord" 1
        Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DriverSearching" "DriverUpdateWizardWuSearchEnabled" "DWord" 0
        Set-RegSafe $wuPath "ExcludeWUDriversInQualityUpdate" "DWord" 1
        Set-RegSafe $wuPath "DeferFeatureUpdates" "DWord" 1
        Set-RegSafe $wuPath "DeferFeatureUpdatesPeriodInDays" "DWord" 365
        Set-RegSafe $wuPath "DeferQualityUpdates" "DWord" 1
        Set-RegSafe $wuPath "DeferQualityUpdatesPeriodInDays" "DWord" 4
        Set-RegSafe $auPath "AUOptions" "DWord" 3
        Set-RegSafe $auPath "AUPowerManagement" "DWord" 0
        Set-RegSafe $auPath "NoAutoRebootWithLoggedOnUsers" "DWord" 1

        Log-Bg "[OK] Windows Update Guvenlik Odakli Mod aktif: Ozellik guncellemeleri 365 gun, kalite guncellemeleri 4 gun ertelendi, surucu guncellemeleri kapatildi."
        Status-Bg "Windows Update: Guvenlik Odakli Mod Aktif!" 100
    }
})

$script:BtnWinUpdateDisable.Add_Click({
    Start-BackgroundTask "WinUpdate_Disable" @{} {
        Status-Bg "Windows Update tamamen devre disi birakiliyor..." 50
        Log-Bg ">>> Windows Update: Tamamen Durdurma Modu (WinUtil Disable) uygulaniyor..."
        Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" "NoAutoUpdate" "DWord" 1
        Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" "AUOptions" "DWord" 1
        Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" "DODownloadMode" "DWord" 0

        foreach ($svc in @("BITS", "wuauserv", "UsoSvc", "dosvc")) {
            Set-SvcSafe $svc "Disabled" $true
        }
        Remove-Item -Path "$env:SystemRoot\SoftwareDistribution\*" -Recurse -Force -ErrorAction SilentlyContinue

        $tasks = @('\Microsoft\Windows\InstallService\*', '\Microsoft\Windows\UpdateOrchestrator\*', '\Microsoft\Windows\UpdateAssistant\*', '\Microsoft\Windows\WaaSMedic\*', '\Microsoft\Windows\WindowsUpdate\*', '\Microsoft\WindowsUpdate\*')
        foreach ($t in $tasks) { Get-ScheduledTask -TaskPath $t -ErrorAction SilentlyContinue | Disable-ScheduledTask -ErrorAction SilentlyContinue | Out-Null }

        Log-Bg "[OK] Windows Update servisleri (wuauserv, bits, UsoSvc, dosvc) ve gorevleri tamamen durduruldu."
        Status-Bg "Windows Update tamamen devre disi birakildi!" 100
    }
})

$script:BtnWinUpdateDefault.Add_Click({
    Start-BackgroundTask "WinUpdate_Default" @{} {
        Status-Bg "Windows Update varsayilan fabrika ayarlarina donduruluyor..." 50
        Log-Bg ">>> Windows Update: Varsayilan Mod (Stock Defaults) yukleniyor..."
        $wuPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
        $auPath = Join-Path $wuPath "AU"
        foreach ($n in @("NoAutoUpdate", "AUOptions", "NoAutoRebootWithLoggedOnUsers", "AUPowerManagement")) {
            Remove-ItemProperty -Path $auPath -Name $n -Force -ErrorAction SilentlyContinue
        }
        foreach ($n in @("ExcludeWUDriversInQualityUpdate", "DeferFeatureUpdates", "DeferFeatureUpdatesPeriodInDays", "DeferQualityUpdates", "DeferQualityUpdatesPeriodInDays")) {
            Remove-ItemProperty -Path $wuPath -Name $n -Force -ErrorAction SilentlyContinue
        }
        foreach ($n in @("DontPromptForWindowsUpdate", "DontSearchWindowsUpdate", "DriverUpdateWizardWuSearchEnabled")) {
            Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DriverSearching" -Name $n -Force -ErrorAction SilentlyContinue
        }
        Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" -Name "DODownloadMode" -Force -ErrorAction SilentlyContinue

        Set-SvcSafe "BITS" "Manual" $false
        Set-SvcSafe "wuauserv" "Manual" $false
        Set-SvcSafe "UsoSvc" "Automatic" $false
        Set-SvcSafe "dosvc" "Manual" $false
        Start-Service -Name "UsoSvc" -ErrorAction SilentlyContinue

        $tasks = @('\Microsoft\Windows\InstallService\*', '\Microsoft\Windows\UpdateOrchestrator\*', '\Microsoft\Windows\UpdateAssistant\*', '\Microsoft\Windows\WaaSMedic\*', '\Microsoft\Windows\WindowsUpdate\*', '\Microsoft\WindowsUpdate\*')
        foreach ($t in $tasks) { Get-ScheduledTask -TaskPath $t -ErrorAction SilentlyContinue | Enable-ScheduledTask -ErrorAction SilentlyContinue | Out-Null }

        Log-Bg "[OK] Windows Update standart fabrika ayarlarina geri donduruldu."
        Status-Bg "Windows Update varsayilan moda donduruldu!" 100
    }
})

# Windows Istege Bagli Bilesenleri (DISM Engine - 10 Bilesen)
$script:featureCheckboxes = @()

foreach ($ft in $script:FeaturesData) {
    $ftName = Decode-U $ft.Name
    $ftDesc = Decode-U $ft.Desc

    $card = New-Object System.Windows.Controls.Border
    $card.Background = Get-Brush $initTheme.CardBg
    $card.BorderBrush = Get-Brush $initTheme.BorderBrushColor
    $card.BorderThickness = "1"
    $card.CornerRadius = "6"
    $card.Padding = "10"
    $card.Margin = "4"
    $card.Cursor = "Hand"
    $script:dynamicThemedItems += [PSCustomObject]@{ Type = "Card"; Element = $card }

    $sp = New-Object System.Windows.Controls.StackPanel
    $cb = New-Object System.Windows.Controls.CheckBox
    $cb.Content = $ftName
    $cb.Foreground = Get-Brush "#F8FAFC"
    $cb.FontWeight = "Bold"
    $cb.FontSize = 13

    $fId = New-Object System.Windows.Controls.TextBlock
    $fId.Text = "DISM: $($ft.Feature)"
    $fId.FontSize = 10
    $fId.FontFamily = "Consolas"
    $fId.Foreground = Get-Brush $initTheme.TextDim
    $fId.Margin = "22,0,0,0"
    $script:dynamicThemedItems += [PSCustomObject]@{ Type = "Id"; Element = $fId }

    $cb.Tag = [PSCustomObject]@{
        Name          = $ftName
        Feature       = $ft.Feature
        ExtraFeatures = @($ft.ExtraFeatures)
        StatusBlock   = $fId
    }

    $d = New-Object System.Windows.Controls.TextBlock
    $d.Text = $ftDesc
    $d.FontSize = 11
    $d.Foreground = Get-Brush $initTheme.TextMuted
    $d.Margin = "22,3,0,2"
    $d.TextWrapping = "Wrap"
    $script:dynamicThemedItems += [PSCustomObject]@{ Type = "Desc"; Element = $d }

    [void]$sp.Children.Add($cb)
    [void]$sp.Children.Add($d)
    [void]$sp.Children.Add($fId)
    $card.Child = $sp

    $card.Tag = $cb
    $card.Add_MouseLeftButtonUp({
        param($sender, $e)
        if ($e.OriginalSource -isnot [System.Windows.Controls.CheckBox]) {
            $targetCb = $sender.Tag
            $targetCb.IsChecked = -not $targetCb.IsChecked
        }
    })

    [void]$script:FeaturesGrid.Children.Add($card)
    $script:featureCheckboxes += $cb
}

$script:BtnCheckFeaturesStatus.Add_Click({
    Start-BackgroundTask "CheckDISMStatus" @{ Checkboxes = $script:featureCheckboxes } {
        param($p)
        Status-Bg "DISM ile Windows bilesen durumlari sorgulaniyor..." 30
        Log-Bg ">>> Windows istege bagli bilesenlerin kurulum durumu kontrol ediliyor..."
        foreach ($cb in $p.Checkboxes) {
            $featName = $cb.Tag.Feature
            try {
                $st = (Get-WindowsOptionalFeature -Online -FeatureName $featName -ErrorAction SilentlyContinue).State
                $stText = if ($st) { [string]$st } else { "Bilinmiyor" }
                $sync.Window.Dispatcher.Invoke([action]{
                    $cb.Tag.StatusBlock.Text = "DISM: $featName [Durum: $stText]"
                })
                Log-Bg "  -> $($cb.Tag.Name) ($featName): $stText"
            } catch {}
        }
        Status-Bg "Windows bilesen durumlari guncellendi!" 100
    }
})

function Start-DismFeaturesJob([bool]$enableMode) {
    $selFeatures = @($script:featureCheckboxes | Where-Object { $_.IsChecked -eq $true } | ForEach-Object { $_.Tag })
    if ($selFeatures.Count -eq 0) {
        Write-UiLog (Decode-U "[!] L\u00FCtfen i\u015Flem yap\u0131lacak en az bir Windows bile\u015Feni se\u00E7in.")
        return
    }
    $script:BtnApplyFeatures.IsEnabled   = $false
    $script:BtnDisableFeatures.IsEnabled = $false

    Start-BackgroundTask "DISM_Features" @{ Features = $selFeatures; Enable = $enableMode } {
        param($p)
        $list = $p.Features
        $enable = [bool]$p.Enable
        $total = $list.Count
        $idx = 0
        foreach ($ft in $list) {
            $idx++
            $pct = [math]::Round(($idx / $total) * 100)
            $allFeats = @($ft.Feature) + @($ft.ExtraFeatures | Where-Object { $_ })
            if ($enable) {
                Status-Bg "($idx/$total) DISM Etkinlestiriliyor: $($ft.Name)..." $pct
                Log-Bg "[$idx/$total] DISM Bileseni Etkinlestiriliyor: $($ft.Name) ($($allFeats -join ', '))"
                foreach ($fName in $allFeats) {
                    $proc = Start-Process -FilePath "dism.exe" -ArgumentList "/Online /Enable-Feature /FeatureName:$fName /All /NoRestart" -NoNewWindow -Wait -PassThru
                    if ($proc.ExitCode -eq 0 -or $proc.ExitCode -eq 3010) {
                        Log-Bg "  [OK] $fName etkinlestirildi."
                    } else {
                        Log-Bg "  [!] $fName DISM cikis kodu: $($proc.ExitCode)"
                    }
                }
            } else {
                Status-Bg "($idx/$total) DISM Devre Disi Birakiliyor: $($ft.Name)..." $pct
                Log-Bg "[$idx/$total] DISM Bileseni Kapatiliyor: $($ft.Name) ($($ft.Feature))"
                $proc = Start-Process -FilePath "dism.exe" -ArgumentList "/Online /Disable-Feature /FeatureName:$($ft.Feature) /NoRestart" -NoNewWindow -Wait -PassThru
                if ($proc.ExitCode -eq 0 -or $proc.ExitCode -eq 3010) {
                    Log-Bg "  [OK] $($ft.Feature) devre disi birakildi."
                } else {
                    Log-Bg "  [!] $($ft.Feature) DISM cikis kodu: $($proc.ExitCode)"
                }
            }
        }
        Status-Bg "DISM Windows bilesen islemleri tamamlandi!" 100
        Log-Bg "=== TUM DISM WINDOWS BILESEN ISLEMLERI TAMAMLANDI ==="
    }
}

$script:BtnApplyFeatures.Add_Click({ Start-DismFeaturesJob $true })
$script:BtnDisableFeatures.Add_Click({ Start-DismFeaturesJob $false })

# =============================================================================
# 7. SEKME 4: KAPSAMLI BLOATWARE VE UWP TASFIYESI (42 PAKET - KALDIR / YUKLE)
# =============================================================================
$script:bloatCheckboxes = @()

foreach ($bl in $script:BloatwareData) {
    $blName = Decode-U $bl.Name

    $card = New-Object System.Windows.Controls.Border
    $card.Background = Get-Brush $initTheme.CardBg
    $card.BorderBrush = Get-Brush $initTheme.BorderBrushColor
    $card.BorderThickness = "1"
    $card.CornerRadius = "6"
    $card.Padding = "10"
    $card.Margin = "4"
    $card.Cursor = "Hand"
    $script:dynamicThemedItems += [PSCustomObject]@{ Type = "Card"; Element = $card }

    $sp = New-Object System.Windows.Controls.StackPanel
    $cb = New-Object System.Windows.Controls.CheckBox
    $cb.Content = $blName
    $cb.Foreground = Get-Brush "#F8FAFC"
    $cb.FontWeight = "SemiBold"
    $cb.FontSize = 13
    $cb.IsChecked = [bool]$bl.DefaultCheck
    $cb.Tag = [PSCustomObject]@{
        Name         = $blName
        Pkg          = $bl.Pkg
        StoreId      = $bl.StoreId
        DefaultCheck = [bool]$bl.DefaultCheck
    }

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

    $card.Tag = $cb
    $card.Add_MouseLeftButtonUp({
        param($sender, $e)
        if ($e.OriginalSource -isnot [System.Windows.Controls.CheckBox]) {
            $targetCb = $sender.Tag
            $targetCb.IsChecked = -not $targetCb.IsChecked
        }
    })

    [void]$script:BloatwareGrid.Children.Add($card)
    $script:bloatCheckboxes += $cb
}

$script:BtnSelectDefaultBloat.Add_Click({
    foreach ($cb in $script:bloatCheckboxes) { $cb.IsChecked = [bool]$cb.Tag.DefaultCheck }
    Write-UiLog (Decode-U "\u00D6nerilen g\u00FCvenli Bloatware listesi se\u00E7ildi.")
})

$script:BtnSelectAllBloat.Add_Click({
    foreach ($cb in $script:bloatCheckboxes) { $cb.IsChecked = $true }
})

$script:BtnClearBloat.Add_Click({
    foreach ($cb in $script:bloatCheckboxes) { $cb.IsChecked = $false }
})

$script:BtnRemoveBloatware.Add_Click({
    $selBloat = @($script:bloatCheckboxes | Where-Object { $_.IsChecked -eq $true } | ForEach-Object { $_.Tag })
    if ($selBloat.Count -eq 0) {
        Write-UiLog (Decode-U "[!] L\u00FCtfen kald\u0131rmak i\u00E7in en az bir Bloatware paketi se\u00E7in.")
        return
    }
    $script:BtnRemoveBloatware.IsEnabled    = $false
    $script:BtnReinstallBloatware.IsEnabled = $false

    Start-BackgroundTask "RemoveBloatware" @{ Packages = $selBloat } {
        param($p)
        $list = $p.Packages
        $total = $list.Count
        Log-Bg ">>> $total UWP Bloatware paketi (AllUsers + Provisioned) sistemden kaldiriliyor..."
        $provPackages = @(Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue)
        $i = 0
        foreach ($b in $list) {
            $i++
            $pct = [math]::Round(($i / $total) * 100)
            Status-Bg "($i/$total) Bloatware Kaldiriliyor: $($b.Name)..." $pct
            try {
                $patterns = $b.Pkg -split '\|'
                foreach ($pat in $patterns) {
                    Get-AppxPackage -Name $pat -AllUsers -ErrorAction SilentlyContinue | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
                    $provPackages | Where-Object { $_.DisplayName -like $pat } | ForEach-Object {
                        Remove-AppxProvisionedPackage -Online -PackageName $_.PackageName -ErrorAction SilentlyContinue | Out-Null
                    }
                }
                Log-Bg "  [OK] Kaldirildi: $($b.Name) ($($b.Pkg))"
            } catch {
                Log-Bg "  [!] $($b.Name) uyarisi: $($_.Exception.Message)"
            }
        }
        Status-Bg "Secili Bloatware paketleri tamamen kaldirildi ($total / $total)!" 100
        Log-Bg "=== BLOATWARE TEMIZLIGI TAMAMLANDI ==="
    }
})

$script:BtnReinstallBloatware.Add_Click({
    $selBloat = @($script:bloatCheckboxes | Where-Object { $_.IsChecked -eq $true } | ForEach-Object { $_.Tag })
    if ($selBloat.Count -eq 0) {
        Write-UiLog (Decode-U "[!] L\u00FCtfen geri y\u00FCklemek i\u00E7in en az bir paket se\u00E7in.")
        return
    }
    $script:BtnRemoveBloatware.IsEnabled    = $false
    $script:BtnReinstallBloatware.IsEnabled = $false

    Start-BackgroundTask "ReinstallBloatware" @{ Packages = $selBloat } {
        param($p)
        $list = $p.Packages
        $total = $list.Count
        Log-Bg ">>> $total UWP paketi Microsoft Store (Winget) uzerinden geri yukleniyor..."
        $i = 0
        foreach ($b in $list) {
            $i++
            $pct = [math]::Round(($i / $total) * 100)
            Status-Bg "($i/$total) Geri Yukleniyor: $($b.Name)..." $pct
            if ($b.StoreId) {
                Start-Process -FilePath "winget.exe" -ArgumentList "install --id `"$($b.StoreId)`" --source msstore --silent --accept-package-agreements --accept-source-agreements" -NoNewWindow -Wait -ErrorAction SilentlyContinue
                Log-Bg "  [OK] Geri yuklendi: $($b.Name) (StoreId: $($b.StoreId))"
            } else {
                Log-Bg "  [!] $($b.Name) icin StoreId bulunamadi."
            }
        }
        Status-Bg "Secili UWP paketleri geri yuklendi!" 100
    }
})

# =============================================================================
# 8. SEKME 5: SISTEM YARDIMCI ARACLARI, ONARIM & MAS AKTIVASYON
# =============================================================================
$script:BtnRunMAS.Add_Click({
    Write-UiLog (Decode-U ">>> Microsoft Activation Scripts (MAS) ayr\u0131 PowerShell penceresinde ba\u015Flat\u0131l\u0131yor (irm https://get.mas.dev | iex)...")
    try {
        Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"irm https://get.mas.dev | iex`"" -Verb RunAs
        Set-UiStatus (Decode-U "MAS Aktivasyon penceresi ba\u015Flat\u0131ld\u0131!") 100
    } catch {
        Write-UiLog "[HATA] MAS baslatilamadi: $($_.Exception.Message)"
    }
})

$script:BtnCreateGodMode.Add_Click({
    try {
        $desktopPath = [Environment]::GetFolderPath("Desktop")
        $godModePath = Join-Path $desktopPath "GodMode.{ED7BA470-8E54-465E-825C-99712043E01C}"
        if (!(Test-Path -LiteralPath $godModePath)) {
            New-Item -Path $godModePath -ItemType Directory -Force | Out-Null
        }
        Write-UiLog (Decode-U "[OK] Masa\u00FCst\u00FCnde God Mode (Tanr\u0131 Modu) klas\u00F6r\u00FC olu\u015Fturuldu.")
        Set-UiStatus (Decode-U "God Mode klas\u00F6r\u00FC Masa\u00FCst\u00FCnde olu\u015Fturuldu!") 100
    } catch {
        Write-UiLog "[HATA] God Mode olusturulamadi: $($_.Exception.Message)"
    }
})

$script:BtnRunOOSU.Add_Click({
    Start-BackgroundTask "RunOOSU" @{} {
        Status-Bg "O&O ShutUp10++ indiriliyor..." 40
        Log-Bg ">>> O&O ShutUp10++ resmi sunucudan indiriliyor..."
        $dest = Join-Path $env:TEMP "OOSU10.exe"
        Invoke-WebRequest -Uri "https://dl5.oo-software.com/files/ooshutup10/OOSU10.exe" -OutFile $dest -UseBasicParsing -ErrorAction Stop
        Status-Bg "O&O ShutUp10++ baslatiliyor..." 100
        Start-Process -FilePath $dest
        Log-Bg "[OK] O&O ShutUp10++ indirildi ve baslatildi."
    }
})

$script:BtnFixSystemCorruption.Add_Click({
    Start-BackgroundTask "SystemRepair" @{} {
        Status-Bg "Adim 1/3: Disk Hata Taramasi (chkdsk /scan /perf)..." 20
        Log-Bg ">>> [1/3] Disk taramasi baslatiliyor: chkdsk /scan /perf"
        Start-Process -FilePath "cmd.exe" -ArgumentList "/c chkdsk /scan /perf" -NoNewWindow -Wait

        Status-Bg "Adim 2/3: Sistem Dosya Denetleyicisi (sfc /scannow)..." 55
        Log-Bg ">>> [2/3] Korunan sistem dosyalari onariliyor: sfc /scannow"
        Start-Process -FilePath "cmd.exe" -ArgumentList "/c sfc /scannow" -NoNewWindow -Wait

        Status-Bg "Adim 3/3: Windows Imaj Onarimi (DISM /RestoreHealth)..." 85
        Log-Bg ">>> [3/3] Windows sistem goruntusu onariliyor: DISM /Online /Cleanup-Image /RestoreHealth"
        Start-Process -FilePath "cmd.exe" -ArgumentList "/c dism /online /cleanup-image /restorehealth" -NoNewWindow -Wait

        Status-Bg "Sistem Bozulma Taramasi ve Onarimi tamamlandi!" 100
        Log-Bg "[OK] Chkdsk, SFC ve DISM onarim adimlari tamamlandi."
    }
})

$script:BtnFixWinUpdate.Add_Click({
    Start-BackgroundTask "FixWindowsUpdate" @{} {
        Status-Bg "Windows Update servisleri durduruluyor ve onbellek sifirlaniyor..." 25
        Log-Bg ">>> Windows Update Tam Sifirlama ve Onarim (WinUtil FixesUpdate) baslatildi..."
        foreach ($svc in @("BITS", "wuauserv", "appidsvc", "cryptsvc")) {
            Stop-Service -Name $svc -Force -ErrorAction SilentlyContinue
        }
        Remove-Item "$env:ALLUSERSPROFILE\Application Data\Microsoft\Network\Downloader\qmgr*.dat" -Force -ErrorAction SilentlyContinue
        Rename-Item "$env:SystemRoot\SoftwareDistribution\DataStore" "DataStore.bak" -Force -ErrorAction SilentlyContinue
        Rename-Item "$env:SystemRoot\SoftwareDistribution\Download" "Download.bak" -Force -ErrorAction SilentlyContinue
        Rename-Item "$env:SystemRoot\System32\catroot2" "catroot2.bak" -Force -ErrorAction SilentlyContinue

        Status-Bg "Windows Update DLL dosyalari yeniden kaydediliyor..." 60
        $dlls = @(
            "atl.dll", "urlmon.dll", "mshtml.dll", "shdocvw.dll", "browseui.dll", "jscript.dll",
            "vbscript.dll", "scrrun.dll", "msxml.dll", "msxml3.dll", "msxml6.dll", "actxprxy.dll",
            "softpub.dll", "wintrust.dll", "dssenh.dll", "rsaenh.dll", "gpkcsp.dll", "sccbase.dll",
            "slbcsp.dll", "cryptdlg.dll", "oleaut32.dll", "ole32.dll", "shell32.dll", "initpki.dll",
            "wuapi.dll", "wuaueng.dll", "wuaueng1.dll", "wucltui.dll", "wups.dll", "wups2.dll",
            "wuweb.dll", "qmgr.dll", "qmgrprxy.dll", "wucltux.dll", "muweb.dll", "wuwebv.dll"
        )
        foreach ($d in $dlls) {
            Start-Process -FilePath "regsvr32.exe" -ArgumentList "/s $d" -NoNewWindow -ErrorAction SilentlyContinue
        }

        netsh winsock reset | Out-Null
        netsh winhttp reset proxy | Out-Null
        Get-BitsTransfer -ErrorAction SilentlyContinue | Remove-BitsTransfer -ErrorAction SilentlyContinue

        foreach ($svc in @("BITS", "wuauserv", "cryptsvc")) {
            Set-SvcSafe $svc "Manual" $false
            Start-Service -Name $svc -ErrorAction SilentlyContinue
        }
        Start-Process -FilePath "wuauclt.exe" -ArgumentList "/resetauthorization /detectnow" -NoNewWindow -ErrorAction SilentlyContinue
        Log-Bg "[OK] Windows Update bilesenleri, DLL kayitlari ve indirme klasorleri sifirlandi."
        Status-Bg "Windows Update tam onarimi tamamlandi!" 100
    }
})

$script:BtnFixNetwork.Add_Click({
    Start-BackgroundTask "FixNetwork" @{} {
        Status-Bg "Ag yigini (Winsock, IP ve DNS) sifirlaniyor..." 50
        Log-Bg ">>> Ag sifirlama komutlari calistiriliyor (winsock & ip reset)..."
        netsh winsock reset | Out-Null
        netsh int ip reset | Out-Null
        ipconfig /release | Out-Null
        ipconfig /renew | Out-Null
        ipconfig /flushdns | Out-Null
        Log-Bg "[OK] Ag yapilandirmasi sifirlandi (Tam etki icin yeniden baslatma onerilir)."
        Status-Bg "Ag sifirlama tamamlandi!" 100
    }
})

$script:BtnFixWinget.Add_Click({
    Start-BackgroundTask "FixWinget" @{} {
        Status-Bg "WinGet paket yoneticisi kaynaklari ve kayitlari onariliyor..." 50
        Log-Bg ">>> WinGet kaynaklari sifirlaniyor ve guncelleniyor..."
        winget source reset --force | Out-Null
        winget source update | Out-Null
        Add-AppxPackage -DisableDevelopmentMode -Register "$env:ProgramFiles\WindowsApps\Microsoft.DesktopAppInstaller_*_x64__8wekyb3d8bbwe\AppxManifest.xml" -ErrorAction SilentlyContinue
        Log-Bg "[OK] WinGet paket yoneticisi kaynaklari ve AppInstaller kaydi onarildi."
        Status-Bg "WinGet onarimi tamamlandi!" 100
    }
})

$script:BtnFixNTP.Add_Click({
    Start-BackgroundTask "FixNTP" @{} {
        Status-Bg "NTP Saat Sunucusu (pool.ntp.org) yapilandiriliyor..." 50
        Start-Service -Name "w32time" -ErrorAction SilentlyContinue
        w32tm /config /manualpeerlist:"pool.ntp.org" /syncfromflags:manual /reliable:YES /update | Out-Null
        Restart-Service -Name "w32time" -Force -ErrorAction SilentlyContinue
        w32tm /resync | Out-Null
        Log-Bg "[OK] NTP Saat Sunucusu pool.ntp.org olarak ayarlandi ve senkronize edildi."
        Status-Bg "NTP saat senkronizasyonu tamamlandi!" 100
    }
})

$script:BtnRunAutologon.Add_Click({
    Start-BackgroundTask "RunAutologon" @{} {
        Status-Bg "Microsoft Sysinternals AutoLogon indiriliyor..." 50
        $dest = Join-Path $env:TEMP "Autologon64.exe"
        Invoke-WebRequest -Uri "https://live.sysinternals.com/Autologon64.exe" -OutFile $dest -UseBasicParsing -ErrorAction Stop
        Start-Process -FilePath $dest -ArgumentList "/accepteula"
        Log-Bg "[OK] Sysinternals AutoLogon indirildi ve baslatildi."
        Status-Bg "AutoLogon baslatildi!" 100
    }
})

$script:BtnEnableOpenSSH.Add_Click({
    Start-BackgroundTask "EnableOpenSSH" @{} {
        Status-Bg "OpenSSH Server kuruluyor ve yapilandiriliyor..." 50
        Log-Bg ">>> OpenSSH Sunucusu kontrol ediliyor ve etkinlestiriliyor..."
        $cap = Get-WindowsCapability -Online -Name "OpenSSH.Server~~~~0.0.1.0" -ErrorAction SilentlyContinue
        if ($cap -and $cap.State -ne "Installed") {
            Add-WindowsCapability -Online -Name "OpenSSH.Server~~~~0.0.1.0" -ErrorAction SilentlyContinue | Out-Null
        }
        Set-SvcSafe "sshd" "Automatic" $false
        Set-SvcSafe "ssh-agent" "Automatic" $false
        Start-Service -Name "sshd" -ErrorAction SilentlyContinue
        Start-Service -Name "ssh-agent" -ErrorAction SilentlyContinue
        if (!(Get-NetFirewallRule -Name "sshd" -ErrorAction SilentlyContinue)) {
            New-NetFirewallRule -Name "sshd" -DisplayName "OpenSSH Server (sshd)" -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22 -ErrorAction SilentlyContinue | Out-Null
        }
        Log-Bg "[OK] OpenSSH Server kuruldu, Port 22 acildi ve servisler baslatildi."
        Status-Bg "OpenSSH Server aktif!" 100
    }
})

$script:BtnEnableRegBackup.Add_Click({
    try {
        if (!(Test-Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Configuration Manager")) {
            New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Configuration Manager" -Force | Out-Null
        }
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Configuration Manager" -Name "EnablePeriodicBackup" -Type DWord -Value 1 -Force
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Configuration Manager" -Name "BackupCount" -Type DWord -Value 2 -Force
        $action  = New-ScheduledTaskAction -Execute "schtasks.exe" -Argument '/run /i /tn "\Microsoft\Windows\Registry\RegIdleBackup"'
        $trigger = New-ScheduledTaskTrigger -Daily -At "00:30"
        Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "AutoRegBackup" -Description "Create System Registry Backups" -User "SYSTEM" -Force -ErrorAction SilentlyContinue | Out-Null
        Write-UiLog (Decode-U "[OK] G\u00FCnl\u00FCk otomatik Kay\u0131t Defteri yedekleme g\u00F6revi (00:30) etkinle\u015Ftirildi.")
        Set-UiStatus (Decode-U "G\u00FCnl\u00FCk Kay\u0131t Defteri yede\u011Fi aktif!") 100
    } catch {
        Write-UiLog "[HATA] Kayit defteri yedegi gorevi olusturulamadi: $($_.Exception.Message)"
    }
})

$script:BtnRestartExplorer.Add_Click({
    try {
        Stop-Process -Name "explorer" -Force -ErrorAction SilentlyContinue
        Start-Sleep -Milliseconds 500
        if (!(Get-Process -Name "explorer" -ErrorAction SilentlyContinue)) {
            Start-Process "explorer.exe"
        }
        Write-UiLog (Decode-U "[OK] Dosya Gezgini (explorer.exe) yeniden ba\u015Flat\u0131ld\u0131.")
    } catch {}
})

$script:BtnEnableF8Boot.Add_Click({
    bcdedit.exe /set bootmenupolicy legacy | Out-Null
    Write-UiLog (Decode-U "[OK] Klasik F8 G\u00FCvenli Mod \u00F6ny\u00FCkleme men\u00FCs\u00FC etkinle\u015Ftirildi (bootmenupolicy legacy).")
})

$script:BtnDisableF8Boot.Add_Click({
    bcdedit.exe /set bootmenupolicy standard | Out-Null
    Write-UiLog (Decode-U "[OK] Standart modern \u00F6ny\u00FCkleme men\u00FCs\u00FCne d\u00F6n\u00FCld\u00FC (bootmenupolicy standard).")
})

# Klasik Windows Denetim Masasi ve Yonetim Konsollari (12 Panel)
function Open-SystemPanel([string]$cmd, [string]$argsStr = "") {
    try {
        if ([string]::IsNullOrEmpty($argsStr)) {
            Start-Process $cmd
        } else {
            Start-Process $cmd -ArgumentList $argsStr
        }
        Write-UiLog (Decode-U "[OK] Sistem konsolu a\u00E7\u0131ld\u0131: $cmd $argsStr")
    } catch {
        Write-UiLog "[!] Konsol acilamadi ($cmd): $($_.Exception.Message)"
    }
}

$script:BtnPanelControl.Add_Click({ Open-SystemPanel "control.exe" })
$script:BtnPanelNetwork.Add_Click({ Open-SystemPanel "ncpa.cpl" })
$script:BtnPanelSystem.Add_Click({ Open-SystemPanel "sysdm.cpl" })
$script:BtnPanelPower.Add_Click({ Open-SystemPanel "powercfg.cpl" })
$script:BtnPanelSound.Add_Click({ Open-SystemPanel "mmsys.cpl" })
$script:BtnPanelPrograms.Add_Click({ Open-SystemPanel "appwiz.cpl" })
$script:BtnPanelComputer.Add_Click({ Open-SystemPanel "compmgmt.msc" })
$script:BtnPanelMouse.Add_Click({ Open-SystemPanel "main.cpl" })
$script:BtnPanelFirewall.Add_Click({ Open-SystemPanel "firewall.cpl" })
$script:BtnPanelRestore.Add_Click({ Open-SystemPanel "rstrui.exe" })
$script:BtnPanelTimedate.Add_Click({ Open-SystemPanel "timedate.cpl" })
$script:BtnPanelRegion.Add_Click({ Open-SystemPanel "intl.cpl" })

# =============================================================================
# 9. SEKME 6: YEDEKLEME (CONFIG EXPORT / IMPORT), SISTEM RAPORU & GERI YUKLEME
# =============================================================================
$script:BtnExportConfig.Add_Click({
    $sfd = New-Object System.Windows.Forms.SaveFileDialog
    $sfd.Filter = "JSON Config (*.json)|*.json"
    $sfd.FileName = "UmutEvranTool_WinUtil_Config.json"
    if ($sfd.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $exportObj = [PSCustomObject]@{
            Version   = "4.0"
            Theme     = $script:currentThemeKey
            Apps      = @($script:appCheckboxes | Where-Object { $_.IsChecked -eq $true } | ForEach-Object { $_.Tag.Id })
            Tweaks    = @($script:tweakCheckboxes | Where-Object { $_.IsChecked -eq $true } | ForEach-Object { $_.Tag.Id })
            Features  = @($script:featureCheckboxes | Where-Object { $_.IsChecked -eq $true } | ForEach-Object { $_.Tag.Feature })
            Bloatware = @($script:bloatCheckboxes | Where-Object { $_.IsChecked -eq $true } | ForEach-Object { $_.Tag.Pkg })
        }
        $jsonOut = $exportObj | ConvertTo-Json -Depth 4
        [System.IO.File]::WriteAllText($sfd.FileName, $jsonOut, [System.Text.Encoding]::UTF8)
        Write-UiLog "[OK] Yapilandirma JSON olarak kaydedildi: $($sfd.FileName)"
    }
})

$script:BtnImportConfig.Add_Click({
    $ofd = New-Object System.Windows.Forms.OpenFileDialog
    $ofd.Filter = "JSON Config (*.json)|*.json"
    if ($ofd.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        try {
            $imported = [System.IO.File]::ReadAllText($ofd.FileName, [System.Text.Encoding]::UTF8) | ConvertFrom-Json
            if ($imported.Theme) {
                Set-Theme $imported.Theme
            }
            if ($imported.Apps) {
                foreach ($cb in $script:appCheckboxes) {
                    $cb.IsChecked = ($imported.Apps -contains $cb.Tag.Id)
                }
            }
            if ($imported.Tweaks) {
                foreach ($cb in $script:tweakCheckboxes) {
                    $cb.IsChecked = ($imported.Tweaks -contains $cb.Tag.Id)
                }
            }
            if ($imported.Features) {
                foreach ($cb in $script:featureCheckboxes) {
                    $cb.IsChecked = ($imported.Features -contains $cb.Tag.Feature)
                }
            }
            if ($imported.Bloatware) {
                foreach ($cb in $script:bloatCheckboxes) {
                    $cb.IsChecked = ($imported.Bloatware -contains $cb.Tag.Pkg)
                }
            }
            Switch-Tab $script:BtnNavApps $script:ViewApps
            Write-UiLog "[OK] Yapilandirma basariyla yuklendi: $($ofd.FileName)"
        } catch {
            Write-UiLog "[HATA] JSON dosyasi okunamadi: $($_.Exception.Message)"
        }
    }
})

$script:BtnExportSysReport.Add_Click({
    $sfd = New-Object System.Windows.Forms.SaveFileDialog
    $sfd.Filter = "JSON Sistem Raporu (*.json)|*.json"
    $sfd.FileName = "UmutEvranTool_SistemRaporu.json"
    if ($sfd.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        try {
            $os  = Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue
            $cpu = Get-CimInstance Win32_Processor -ErrorAction SilentlyContinue | Select-Object -First 1
            $gpu = Get-CimInstance Win32_VideoController -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Name
            $rep = [PSCustomObject]@{
                Timestamp   = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
                Computer    = $env:COMPUTERNAME
                OS          = if ($os) { $os.Caption } else { "Unknown" }
                Build       = if ($os) { $os.BuildNumber } else { "Unknown" }
                CPU         = if ($cpu) { $cpu.Name } else { "Unknown" }
                GPU         = $gpu
                PowerShell  = $PSVersionTable.PSVersion.ToString()
            }
            [System.IO.File]::WriteAllText($sfd.FileName, ($rep | ConvertTo-Json -Depth 4), [System.Text.Encoding]::UTF8)
            Write-UiLog "[OK] Sistem donanim ve ortam raporu kaydedildi: $($sfd.FileName)"
        } catch {
            Write-UiLog "[HATA] Rapor olusturulamadi: $($_.Exception.Message)"
        }
    }
})

$script:BtnRestorePoint.Add_Click({
    Start-BackgroundTask "RestorePoint" @{} {
        Status-Bg "Sistem Geri Yukleme Noktasi olusturuluyor..." 50
        Log-Bg ">>> Sistem Geri Yukleme Noktasi olusturuluyor (Checkpoint-Computer)..."
        Enable-ComputerRestore -Drive "$env:SystemDrive\" -ErrorAction SilentlyContinue
        Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore" "SystemRestorePointCreationFrequency" "DWord" 0
        Checkpoint-Computer -Description "UmutEvranTool_Oncesi" -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop
        Log-Bg "[OK] Sistem Geri Yukleme Noktasi basariyla olusturuldu!"
        Status-Bg "Geri yukleme noktasi olusturuldu!" 100
    }
})

# Baslangic temasini aktif et (Varsayilan Askeri Adacayi Yesili)
Set-Theme "olive"
Write-UiLog (Decode-U "Umut Evran Tool v4.0 (WinUtil %100 Entegre S\u00FCr\u00FCm) Canl\u0131 Tema Sistemi ile ba\u015Flat\u0131ld\u0131.")

[void]$script:window.ShowDialog()
