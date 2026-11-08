# =============================================================================
# PETRA OMNITOOL (TEK DOSYA / UZAKTAN CALISTIRMA SURUMU)
# Post-Install & Script Engine v4.0
# Komut: irm tinyurl.com/evrantool | iex (veya irm evrantool.evranumut.workers.dev | iex)
# Mimari: 100% Pure ASCII + Decode-U + WPF XamlReader + Runspace Multithreading
# =============================================================================
$ErrorActionPreference = 'Continue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
$isSta   = ([System.Threading.Thread]::CurrentThread.GetApartmentState() -eq 'STA')

if ((-not $isAdmin) -or (-not $isSta)) {
    $tempRunner = Join-Path $env:TEMP "PetraOmniTool_Runtime.ps1"
    # Once iex ile gelen gomulu betik metnini kullan (yanlis dosya kopyalanmasin),
    # sonra -File ile calistirilan gercek betik yolunu, en son uzaktan indirmeyi dene.
    if ($MyInvocation.MyCommand.Definition -and ($MyInvocation.MyCommand.Definition.Length -gt 200)) {
        [System.IO.File]::WriteAllText($tempRunner, $MyInvocation.MyCommand.Definition, (New-Object System.Text.UTF8Encoding($false)))
    } elseif ($PSCommandPath -and (Test-Path $PSCommandPath)) {
        Copy-Item -Path $PSCommandPath -Destination $tempRunner -Force
    } else {
        Invoke-RestMethod -Uri "https://evrantool.evranumut.workers.dev" -OutFile $tempRunner
    }
    $argList = "-NoProfile -STA -ExecutionPolicy Bypass -File `"$tempRunner`""
    if ($args.Count -gt 0) {
        $escapedArgs = $args | ForEach-Object { "`"$_`"" }
        $argList += " " + ($escapedArgs -join " ")
    }
    try {
        Start-Process powershell.exe -ArgumentList $argList -Verb RunAs -ErrorAction Stop
    } catch {
        Write-Host "[HATA] Yonetici olarak yeniden baslatilamadi: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "[i] PowerShell'i 'Yonetici olarak calistir' secenegiyle acip tekrar deneyin." -ForegroundColor Yellow
    }
    return
}

$sync = [Hashtable]::Synchronized(@{})
$sync.IsAdmin = $isAdmin

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
        "Name": "Brave Browser",
        "Id": "Brave.Brave",
        "Description": "Reklamlar\u0131 ve izleyicileri varsay\u0131lan olarak engelleyen gizlilik taray\u0131c\u0131s\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=brave.com&sz=128"
      },
      {
        "Name": "Chromium",
        "Id": "Hibbiki.Chromium",
        "Description": "Google servislerinden ar\u0131nd\u0131r\u0131lm\u0131\u015f a\u00e7\u0131k kaynakl\u0131 Chromium web taray\u0131c\u0131s\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=chromium.org&sz=128"
      },
      {
        "Name": "DuckDuckGo Browser",
        "Id": "DuckDuckGo.DesktopBrowser",
        "Description": "Dahili izleyici engelleyici ve yapay zeka destekli gizlilik odakl\u0131 taray\u0131c\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=duckduckgo.com&sz=128"
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
        "Name": "Google Chrome",
        "Id": "Google.Chrome",
        "Description": "D\u00fcnyan\u0131n en pop\u00fcler, h\u0131zl\u0131 ve g\u00fcvenli web taray\u0131c\u0131s\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=google.com&sz=128"
      },
      {
        "Name": "Helium",
        "Id": "ImputNet.Helium",
        "Description": "Hafif, h\u0131zl\u0131 ve gizlilik odakl\u0131 yeni nesil Chromium tabanl\u0131 web taray\u0131c\u0131s\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=helium.computer&sz=128"
      },
      {
        "Name": "LibreWolf",
        "Id": "LibreWolf.LibreWolf",
        "Description": "Telemetri ar\u0131nd\u0131r\u0131lm\u0131\u015f, maksimum gizlilik odakl\u0131 Firefox \u00e7atal\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=librewolf.net&sz=128"
      },
      {
        "Name": "Microsoft Edge",
        "Id": "Microsoft.Edge",
        "Description": "Windows ile tam uyumlu, d\u00fc\u015f\u00fck kaynak t\u00fcketen modern taray\u0131c\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=microsoft.com&sz=128"
      },
      {
        "Name": "Mozilla Firefox",
        "Id": "Mozilla.Firefox",
        "Description": "Gizlilik odakl\u0131, a\u00e7\u0131k kaynakl\u0131 ve \u00f6zelle\u015ftirilebilir taray\u0131c\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=mozilla.org&sz=128"
      },
      {
        "Name": "Mullvad Browser",
        "Id": "MullvadVPN.MullvadBrowser",
        "Description": "Tor Projesi i\u015f birli\u011fiyle geli\u015ftirilen, parmak izi takibini \u00f6nleyen maksimum gizlilik taray\u0131c\u0131s\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=mullvad.net&sz=128"
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
        "Icon": "https://www.google.com/s2/favicons?domain=opera.com&sz=128"
      },
      {
        "Name": "Supermium",
        "Id": "win32ss.Supermium",
        "Description": "Hafif, h\u0131zl\u0131 ve geni\u015f sistem uyumlulu\u011funa sahip a\u00e7\u0131k kaynakl\u0131 Chromium taray\u0131c\u0131s\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=win32subsystem.live&sz=128"
      },
      {
        "Name": "Thorium Browser",
        "Id": "Alex313031.Thorium",
        "Description": "Modern i\u015flemci komut setleriyle maksimum h\u0131z i\u00e7in optimize edilmi\u015f Chromium \u00e7atal\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=thorium.rocks&sz=128"
      },
      {
        "Name": "Tor Browser",
        "Id": "TorProject.TorBrowser",
        "Description": "Anonim internet gezintisi ve \u00fcst d\u00fczey gizlilik sa\u011flayan taray\u0131c\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=torproject.org&sz=128"
      },
      {
        "Name": "Ungoogled Chromium",
        "Id": "eloston.ungoogled-chromium",
        "Description": "Google ba\u011flant\u0131 ve izleyicilerinden tamamen ar\u0131nd\u0131r\u0131lm\u0131\u015f maksimum gizlilikli Chromium.",
        "Icon": "https://github.com/ungoogled-software.png?size=128"
      },
      {
        "Name": "Vivaldi",
        "Id": "Vivaldi.Vivaldi",
        "Description": "Uzman kullan\u0131c\u0131lar i\u00e7in y\u00fcksek d\u00fczeyde \u00f6zelle\u015ftirilebilir taray\u0131c\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=vivaldi.com&sz=128"
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
        "Name": "Amazon Corretto 8 (LTS)",
        "Id": "Amazon.Corretto.8.JDK",
        "Description": "Amazon taraf\u0131ndan uzun s\u00fcreli desteklenen \u00fccretsiz Java 8 (OpenJDK) geli\u015ftirme kiti.",
        "Icon": "https://www.google.com/s2/favicons?domain=aws.amazon.com&sz=128"
      },
      {
        "Name": "Amazon Corretto 17 (LTS)",
        "Id": "Amazon.Corretto.17.JDK",
        "Description": "Amazon Corretto Java 17 (LTS) geli\u015ftirme kiti ve \u00e7al\u0131\u015fma zaman\u0131 ortam\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=aws.amazon.com&sz=128"
      },
      {
        "Name": "Amazon Corretto 21 (LTS)",
        "Id": "Amazon.Corretto.21.JDK",
        "Description": "Amazon taraf\u0131ndan desteklenen \u00fcretim ortam\u0131 haz\u0131r Java 21 (LTS) geli\u015ftirme kiti.",
        "Icon": "https://www.google.com/s2/favicons?domain=aws.amazon.com&sz=128"
      },
      {
        "Name": "Bruno",
        "Id": "Bruno.Bruno",
        "Description": "Git dostu, \u00e7evrimd\u0131\u015f\u0131 \u00e7al\u0131\u015fan h\u0131zl\u0131 ve a\u00e7\u0131k kaynakl\u0131 API istemcisi.",
        "Icon": "https://www.google.com/s2/favicons?domain=usebruno.com&sz=128"
      },
      {
        "Name": "Bun",
        "Id": "Oven-sh.Bun",
        "Description": "JavaScript ve TypeScript i\u00e7in ultra h\u0131zl\u0131 \u00e7al\u0131\u015fma zaman\u0131, paketleyici ve paket y\u00f6neticisi.",
        "Icon": "https://www.google.com/s2/favicons?domain=bun.sh&sz=128"
      },
      {
        "Name": "ChatGPT Desktop",
        "Id": "9NT1R1C2HH7J",
        "Description": "OpenAI taraf\u0131ndan geli\u015ftirilen resmi masa\u00fcst\u00fc yapay zeka asistan\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=openai.com&sz=128"
      },
      {
        "Name": "Claude Code",
        "Id": "Anthropic.ClaudeCode",
        "Description": "Terminal tabanl\u0131 otonom yapay zeka kodlama ve geli\u015ftirici arac\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=claude.ai&sz=128"
      },
      {
        "Name": "Claude Desktop",
        "Id": "Anthropic.Claude",
        "Description": "Anthropic Claude yapay zeka modeli i\u00e7in resmi masa\u00fcst\u00fc uygulamas\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=claude.ai&sz=128"
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
        "Icon": "https://www.google.com/s2/favicons?domain=openai.com&sz=128"
      },
      {
        "Name": "Cursor",
        "Id": "Anysphere.Cursor",
        "Description": "Yapay zeka destekli yeni nesil kod edit\u00f6r\u00fc (VS Code tabanl\u0131).",
        "Icon": "https://www.google.com/s2/favicons?domain=cursor.com&sz=128"
      },
      {
        "Name": "DBeaver Community",
        "Id": "DBeaver.DBeaver.Community",
        "Description": "SQL, NoSQL ve t\u00fcm pop\u00fcler veritabanlar\u0131n\u0131 destekleyen a\u00e7\u0131k kaynakl\u0131 y\u00f6netim arac\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=dbeaver.io&sz=128"
      },
      {
        "Name": "Deno",
        "Id": "DenoLand.Deno",
        "Description": "JavaScript, TypeScript ve WebAssembly i\u00e7in g\u00fcvenli ve modern \u00e7al\u0131\u015fma zaman\u0131 ortam\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=deno.com&sz=128"
      },
      {
        "Name": "Docker Desktop",
        "Id": "Docker.DockerDesktop",
        "Description": "Konteyner tabanl\u0131 uygulama geli\u015ftirme ve y\u00f6netim platformu.",
        "Icon": "https://www.google.com/s2/favicons?domain=docker.com&sz=128"
      },
      {
        "Name": "Fast Node Manager",
        "Id": "Schniz.fnm",
        "Description": "Rust ile yaz\u0131lm\u0131\u015f ultra h\u0131zl\u0131 ve hafif Node.js s\u00fcr\u00fcm y\u00f6neticisi (Fast Node Manager).",
        "Icon": "https://github.com/Schniz.png?size=128"
      },
      {
        "Name": "Git",
        "Id": "Git.Git",
        "Description": "Da\u011f\u0131t\u0131k versiyon kontrol sistemi ve Git Bash terminali.",
        "Icon": "https://www.google.com/s2/favicons?domain=git-scm.com&sz=128"
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
        "Icon": "https://www.google.com/s2/favicons?domain=github.com&sz=128"
      },
      {
        "Name": "GitHub Desktop",
        "Id": "GitHub.GitHubDesktop",
        "Description": "Git ve GitHub depolar\u0131n\u0131 g\u00f6rsel aray\u00fczle y\u00f6netme arac\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=github.com&sz=128"
      },
      {
        "Name": "Go",
        "Id": "GoLang.Go",
        "Description": "Google taraf\u0131ndan geli\u015ftirilen h\u0131zl\u0131, derlenen ve e\u015fzamanl\u0131 (concurrent) Go programlama dili.",
        "Icon": "https://www.google.com/s2/favicons?domain=go.dev&sz=128"
      },
      {
        "Name": "Godot Engine",
        "Id": "GodotEngine.GodotEngine",
        "Description": "2B ve 3B oyun geli\u015ftirmek i\u00e7in hafif, tamamen \u00fccretsiz ve a\u00e7\u0131k kaynakl\u0131 oyun motoru.",
        "Icon": "https://www.google.com/s2/favicons?domain=godotengine.org&sz=128"
      },
      {
        "Name": "Hugo",
        "Id": "Hugo.Hugo.Extended",
        "Description": "Go tabanl\u0131 d\u00fcnyan\u0131n en h\u0131zl\u0131 statik web sitesi olu\u015fturma motoru.",
        "Icon": "https://www.google.com/s2/favicons?domain=gohugo.io&sz=128"
      },
      {
        "Name": "JetBrains Toolbox",
        "Id": "JetBrains.Toolbox",
        "Description": "IntelliJ IDEA, PyCharm, WebStorm gibi t\u00fcm JetBrains IDE'lerini tek merkezden kurma ve g\u00fcncelleme arac\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=jetbrains.com&sz=128"
      },
      {
        "Name": "Lazygit",
        "Id": "JesseDuffield.lazygit",
        "Description": "Git komutlar\u0131n\u0131 terminal i\u00e7inde g\u00f6rsel panellerle y\u00f6netmeyi sa\u011flayan pratik TUI arac\u0131.",
        "Icon": "https://github.com/jesseduffield.png?size=128"
      },
      {
        "Name": "LM Studio",
        "Id": "ElementLabs.LMStudio",
        "Description": "Yerel a\u00e7\u0131k kaynakl\u0131 yapay zeka modellerini GPU h\u0131zland\u0131rmas\u0131yla indirme ve \u00e7al\u0131\u015ft\u0131rma aray\u00fcz\u00fc.",
        "Icon": "https://www.google.com/s2/favicons?domain=lmstudio.ai&sz=128"
      },
      {
        "Name": "Lua",
        "Id": "DEVCOM.Lua",
        "Description": "Hafif, h\u0131zl\u0131 ve g\u00f6m\u00fclebilir Lua 5.4 betik programlama dili \u00e7al\u0131\u015fma ortam\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=lua.org&sz=128"
      },
      {
        "Name": "Neovim",
        "Id": "Neovim.Neovim",
        "Description": "H\u0131z ve geni\u015fletilebilirlik odakl\u0131, modernle\u015ftirilmi\u015f Vim tabanl\u0131 metin ve kod d\u00fczenleyici.",
        "Icon": "https://www.google.com/s2/favicons?domain=neovim.io&sz=128"
      },
      {
        "Name": "Node.js (Current)",
        "Id": "OpenJS.NodeJS",
        "Description": "En g\u00fcncel \u00f6zellikleri i\u00e7eren Node.js JavaScript \u00e7al\u0131\u015fma zaman\u0131 ortam\u0131 (Current).",
        "Icon": "https://www.google.com/s2/favicons?domain=nodejs.org&sz=128"
      },
      {
        "Name": "Node.js (LTS)",
        "Id": "OpenJS.NodeJS.LTS",
        "Description": "JavaScript \u00e7al\u0131\u015fma zaman\u0131 ortam\u0131 ve npm paket y\u00f6neticisi.",
        "Icon": "https://www.google.com/s2/favicons?domain=nodejs.org&sz=128"
      },
      {
        "Name": "Notepad++",
        "Id": "Notepad++.Notepad++",
        "Description": "H\u0131zl\u0131 ve \u00e7ok dilli geli\u015fmi\u015f metin/kod d\u00fczenleyici.",
        "Icon": "https://www.google.com/s2/favicons?domain=notepad-plus-plus.org&sz=128"
      },
      {
        "Name": "NuGet",
        "Id": "Microsoft.NuGet",
        "Description": ".NET geli\u015ftiricileri i\u00e7in resmi paket y\u00f6neticisi komut sat\u0131r\u0131 arac\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=nuget.org&sz=128"
      },
      {
        "Name": "Oh My Posh (Prompt)",
        "Id": "JanDeDobbeleer.OhMyPosh",
        "Description": "PowerShell ve di\u011fer terminaller i\u00e7in \u015f\u0131k, renkli ve Git durum destekli tema motoru.",
        "Icon": "https://www.google.com/s2/favicons?domain=ohmyposh.dev&sz=128"
      },
      {
        "Name": "Ollama",
        "Id": "Ollama.Ollama",
        "Description": "B\u00fcy\u00fck dil modellerini (Llama, DeepSeek, Qwen vb.) yerel bilgisayarda \u00e7al\u0131\u015ft\u0131rma arac\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=ollama.com&sz=128"
      },
      {
        "Name": "OpenCode",
        "Id": "SST.opencode",
        "Description": "Terminal i\u00e7in a\u00e7\u0131k kaynakl\u0131 yapay zeka destekli yaz\u0131l\u0131m geli\u015ftirme asistan\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=opencode.ai&sz=128"
      },
      {
        "Name": "pnpm",
        "Id": "pnpm.pnpm",
        "Description": "Disk alan\u0131ndan tasarruf sa\u011flayan, ultra h\u0131zl\u0131 ve modern JavaScript paket y\u00f6neticisi.",
        "Icon": "https://www.google.com/s2/favicons?domain=pnpm.io&sz=128"
      },
      {
        "Name": "Postman",
        "Id": "Postman.Postman",
        "Description": "API geli\u015ftirme, test etme ve dok\u00fcmantasyon platformu.",
        "Icon": "https://www.google.com/s2/favicons?domain=postman.com&sz=128"
      },
      {
        "Name": "PowerShell 7",
        "Id": "Microsoft.PowerShell",
        "Description": "Platformlar aras\u0131 modern PowerShell s\u00fcr\u00fcm\u00fc.",
        "Icon": "https://www.google.com/s2/favicons?domain=microsoft.com&sz=128"
      },
      {
        "Name": "Python 3.12",
        "Id": "Python.Python.3.12",
        "Description": "Genel ama\u00e7l\u0131, g\u00fc\u00e7l\u00fc ve yayg\u0131n programlama dili.",
        "Icon": "https://www.google.com/s2/favicons?domain=python.org&sz=128"
      },
      {
        "Name": "Python 3.13",
        "Id": "Python.Python.3.13",
        "Description": "Python programlama dilinin en g\u00fcncel kararl\u0131 s\u00fcr\u00fcm\u00fc.",
        "Icon": "https://www.google.com/s2/favicons?domain=python.org&sz=128"
      },
      {
        "Name": "Ruby",
        "Id": "RubyInstallerTeam.RubyWithDevKit.3.3",
        "Description": "Windows i\u00e7in Ruby programlama dili ve MSYS2 geli\u015ftirme ortam\u0131 kurulum paketi.",
        "Icon": "https://www.google.com/s2/favicons?domain=rubyinstaller.org&sz=128"
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
        "Name": "Unity Hub",
        "Id": "Unity.UnityHub",
        "Description": "Unity oyun motoru s\u00fcr\u00fcmlerini ve oyun projelerini y\u00f6netmek i\u00e7in resmi merkez.",
        "Icon": "https://www.google.com/s2/favicons?domain=unity.com&sz=128"
      },
      {
        "Name": "uv",
        "Id": "astral-sh.uv",
        "Description": "Rust ile yaz\u0131lm\u0131\u015f, pip ve virtualenv'in yerini alan ultra h\u0131zl\u0131 Python paket ve s\u00fcr\u00fcm y\u00f6neticisi.",
        "Icon": "https://www.google.com/s2/favicons?domain=astral.sh&sz=128"
      },
      {
        "Name": "Vagrant",
        "Id": "Hashicorp.Vagrant",
        "Description": "Ta\u015f\u0131nabilir ve tekrarlanabilir sanal geli\u015ftirme ortamlar\u0131 olu\u015fturma arac\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=hashicorp.com&sz=128"
      },
      {
        "Name": "Visual Studio 2022 Community",
        "Id": "Microsoft.VisualStudio.2022.Community",
        "Description": "C#, C++ ve .NET geli\u015ftiricileri i\u00e7in tam kapsaml\u0131 profesyonel t\u00fcmle\u015fik geli\u015ftirme ortam\u0131 (IDE).",
        "Icon": "https://www.google.com/s2/favicons?domain=visualstudio.microsoft.com&sz=128"
      },
      {
        "Name": "Visual Studio 2022 Enterprise",
        "Id": "Microsoft.VisualStudio.2022.Enterprise",
        "Description": "Kurumsal mimari, geli\u015fmi\u015f hata ay\u0131klama ve test ara\u00e7lar\u0131n\u0131 i\u00e7eren Visual Studio Enterprise s\u00fcr\u00fcm\u00fc.",
        "Icon": "https://www.google.com/s2/favicons?domain=visualstudio.microsoft.com&sz=128"
      },
      {
        "Name": "Visual Studio Code",
        "Id": "Microsoft.VisualStudioCode",
        "Description": "Hafif, g\u00fc\u00e7l\u00fc ve eklenti destekli pop\u00fcler kod edit\u00f6r\u00fc.",
        "Icon": "https://www.google.com/s2/favicons?domain=code.visualstudio.com&sz=128"
      },
      {
        "Name": "VSCodium",
        "Id": "VSCodium.VSCodium",
        "Description": "Visual Studio Code'un Microsoft telemetri ve izleyicilerinden tamamen ar\u0131nd\u0131r\u0131lm\u0131\u015f a\u00e7\u0131k kaynakl\u0131 derlemesi.",
        "Icon": "https://www.google.com/s2/favicons?domain=vscodium.com&sz=128"
      },
      {
        "Name": "Windows Terminal",
        "Id": "Microsoft.WindowsTerminal",
        "Description": "Sekmeli, modern ve \u00f6zelle\u015ftirilebilir komut sat\u0131r\u0131 uygulamas\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=microsoft.com&sz=128"
      },
      {
        "Name": "Windsurf",
        "Id": "Codeium.Windsurf",
        "Description": "Codeium taraf\u0131ndan geli\u015ftirilen otonom yapay zeka ajan destekli yeni nesil kod edit\u00f6r\u00fc.",
        "Icon": "https://www.google.com/s2/favicons?domain=windsurf.com&sz=128"
      },
      {
        "Name": "Yarn",
        "Id": "Yarn.Yarn",
        "Description": "JavaScript ve Node.js projeleri i\u00e7in h\u0131zl\u0131 ve g\u00fcvenilir paket ve ba\u011f\u0131ml\u0131l\u0131k y\u00f6neticisi.",
        "Icon": "https://www.google.com/s2/favicons?domain=yarnpkg.com&sz=128"
      },
      {
        "Name": "Zed",
        "Id": "ZedIndustries.Zed",
        "Description": "Rust ile s\u0131f\u0131rdan yaz\u0131lm\u0131\u015f, \u00e7ok oyunculu i\u015f birli\u011fi ve yapay zeka destekli ultra h\u0131zl\u0131 kod edit\u00f6r\u00fc.",
        "Icon": "https://www.google.com/s2/favicons?domain=zed.dev&sz=128"
      }
    ]
  },
  {
    "Category": "Oyun ve Oyuncu Ara\u00e7lar\u0131",
    "Apps": [
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
        "Name": "CurseForge",
        "Id": "Overwolf.CurseForge",
        "Description": "Minecraft, WoW, Sims 4 ve di\u011fer oyunlar i\u00e7in pop\u00fcler mod ve eklenti y\u00f6neticisi.",
        "Icon": "https://www.google.com/s2/favicons?domain=curseforge.com&sz=128"
      },
      {
        "Name": "Dolphin Emulator",
        "Id": "DolphinEmulator.Dolphin",
        "Description": "Nintendo GameCube ve Wii oyunlar\u0131n\u0131 y\u00fcksek kalitede \u00e7al\u0131\u015ft\u0131ran pop\u00fcler em\u00fclat\u00f6r.",
        "Icon": "https://www.google.com/s2/favicons?domain=dolphin-emu.org&sz=128"
      },
      {
        "Name": "EA App",
        "Id": "ElectronicArts.EADesktop",
        "Description": "Electronic Arts (EA FC, Battlefield vb.) oyun platformu.",
        "Icon": "https://www.google.com/s2/favicons?domain=ea.com&sz=128"
      },
      {
        "Name": "EmulationStation Desktop Edition",
        "Id": "ES-DE.EmulationStation-DE",
        "Description": "Retro oyunlar ve em\u00fclat\u00f6rler i\u00e7in g\u00f6rsel k\u00fct\u00fcphane ve \u00f6n y\u00fcz (Frontend) aray\u00fcz\u00fc.",
        "Icon": "https://www.google.com/s2/favicons?domain=es-de.org&sz=128"
      },
      {
        "Name": "Epic Games Launcher",
        "Id": "EpicGames.EpicGamesLauncher",
        "Description": "Epic Games oyunlar\u0131 ve Unreal Engine ba\u015flat\u0131c\u0131s\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=epicgames.com&sz=128"
      },
      {
        "Name": "GeForce NOW",
        "Id": "Nvidia.GeForceNow",
        "Description": "Oyunlar\u0131 bulut sunucular \u00fczerinden donan\u0131m gerektirmeden oynatan NVIDIA yay\u0131n hizmeti.",
        "Icon": "https://www.google.com/s2/favicons?domain=nvidia.com&sz=128"
      },
      {
        "Name": "GOG Galaxy",
        "Id": "GOG.Galaxy",
        "Description": "DRM-siz oyunlar ve birle\u015fik oyun k\u00fct\u00fcphanesi y\u00f6neticisi.",
        "Icon": "https://www.google.com/s2/favicons?domain=gog.com&sz=128"
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
        "Name": "Logitech G HUB",
        "Id": "Logitech.GHUB",
        "Description": "Logitech G oyuncu ekipmanlar\u0131 i\u00e7in yaz\u0131l\u0131m ve makro y\u00f6netimi.",
        "Icon": "https://www.google.com/s2/favicons?domain=logitechg.com&sz=128"
      },
      {
        "Name": "Modrinth App",
        "Id": "Modrinth.ModrinthApp",
        "Description": "Minecraft modlar\u0131n\u0131, mod paketlerini ve shader'lar\u0131 kolayca y\u00f6neten resmi Modrinth ba\u015flat\u0131c\u0131s\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=modrinth.com&sz=128"
      },
      {
        "Name": "Moonlight/GameStream Client",
        "Id": "MoonlightGameStreamingProject.Moonlight",
        "Description": "Bilgisayar\u0131n\u0131zdaki oyunlar\u0131 d\u00fc\u015f\u00fck gecikmeyle ba\u015fka cihazlara aktaran a\u00e7\u0131k kaynakl\u0131 istemci.",
        "Icon": "https://www.google.com/s2/favicons?domain=moonlight-stream.org&sz=128"
      },
      {
        "Name": "MSI Afterburner",
        "Id": "Guru3D.Afterburner",
        "Description": "Ekran kart\u0131 h\u0131z a\u015f\u0131rtma (OC), fan kontrol\u00fc ve oyun i\u00e7i FPS g\u00f6stergesi.",
        "Icon": "https://www.google.com/s2/favicons?domain=msi.com&sz=128"
      },
      {
        "Name": "PCSX2",
        "Id": "PCSX2Team.PCSX2",
        "Description": "Y\u00fcksek \u00e7\u00f6z\u00fcn\u00fcrl\u00fck ve modern kontrolc\u00fc destekli a\u00e7\u0131k kaynakl\u0131 PlayStation 2 em\u00fclat\u00f6r\u00fc.",
        "Icon": "https://www.google.com/s2/favicons?domain=pcsx2.net&sz=128"
      },
      {
        "Name": "Playnite",
        "Id": "Playnite.Playnite",
        "Description": "Steam, Epic, GOG, EA ve em\u00fclat\u00f6r oyunlar\u0131n\u0131 tek bir \u015f\u0131k k\u00fct\u00fcphanede birle\u015ftiren a\u00e7\u0131k kaynakl\u0131 y\u00f6netici.",
        "Icon": "https://www.google.com/s2/favicons?domain=playnite.link&sz=128"
      },
      {
        "Name": "Prism Launcher",
        "Id": "PrismLauncher.PrismLauncher",
        "Description": "Modlu Minecraft (Forge, NeoForge, Fabric) i\u00e7in geli\u015fmi\u015f ba\u015flat\u0131c\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=prismlauncher.org&sz=128"
      },
      {
        "Name": "RetroArch",
        "Id": "Libretro.RetroArch",
        "Description": "Klasik konsol em\u00fclat\u00f6rlerini ve oyun motorlar\u0131n\u0131 tek \u00e7at\u0131 alt\u0131nda toplayan geli\u015fmi\u015f aray\u00fcz.",
        "Icon": "https://www.google.com/s2/favicons?domain=retroarch.com&sz=128"
      },
      {
        "Name": "RivaTuner Statistics Server (RTSS)",
        "Id": "Guru3D.RTSS",
        "Description": "MSI Afterburner ile tam uyumlu oyun i\u00e7i FPS/donan\u0131m g\u00f6stergesi (OSD) ve kare h\u0131z\u0131 sabitleyici.",
        "Icon": "https://www.google.com/s2/favicons?domain=guru3d.com&sz=128"
      },
      {
        "Name": "Roblox",
        "Id": "Roblox.Roblox",
        "Description": "Milyonlarca kullan\u0131c\u0131 yap\u0131m\u0131 oyunu bar\u0131nd\u0131ran \u00e7evrimi\u00e7i oyun platformu.",
        "Icon": "https://www.google.com/s2/favicons?domain=roblox.com&sz=128"
      },
      {
        "Name": "Steam",
        "Id": "Valve.Steam",
        "Description": "En b\u00fcy\u00fck PC oyun ma\u011fazas\u0131 ve topluluk platformu.",
        "Icon": "https://www.google.com/s2/favicons?domain=steampowered.com&sz=128"
      },
      {
        "Name": "SteelSeries GG",
        "Id": "SteelSeries.GG",
        "Description": "SteelSeries kulakl\u0131k/ekipman y\u00f6netimi ve Sonar ses motoru.",
        "Icon": "https://www.google.com/s2/favicons?domain=steelseries.com&sz=128"
      },
      {
        "Name": "Sunshine/GameStream Server",
        "Id": "LizardByte.Sunshine",
        "Description": "Bilgisayar\u0131n\u0131z\u0131 d\u00fc\u015f\u00fck gecikmeli bir bulut oyun sunucusuna d\u00f6n\u00fc\u015ft\u00fcren a\u00e7\u0131k kaynakl\u0131 Moonlight sunucusu.",
        "Icon": "https://www.google.com/s2/favicons?domain=lizardbyte.dev&sz=128"
      },
      {
        "Name": "Ubisoft Connect",
        "Id": "Ubisoft.Connect",
        "Description": "Ubisoft oyunlar\u0131 i\u00e7in k\u00fct\u00fcphane ve ba\u015flat\u0131c\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=ubisoft.com&sz=128"
      },
      {
        "Name": "Virtual Desktop Streamer",
        "Id": "VirtualDesktop.Streamer",
        "Description": "VR g\u00f6zl\u00fcklerden bilgisayar masa\u00fcst\u00fcne ve PCVR oyunlar\u0131na kablosuz ba\u011flanma arac\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=vrdesktop.net&sz=128"
      }
    ]
  },
  {
    "Category": "\u0130leti\u015fim",
    "Apps": [
      {
        "Name": "Betterbird",
        "Id": "Betterbird.Betterbird",
        "Description": "Thunderbird'\u00fcn hata d\u00fczeltmeleri ve geli\u015fmi\u015f \u00f6zelliklerle g\u00fc\u00e7lendirilmi\u015f s\u00fcr\u00fcm\u00fc.",
        "Icon": "https://www.google.com/s2/favicons?domain=betterbird.eu&sz=128"
      },
      {
        "Name": "Chatterino",
        "Id": "ChatterinoTeam.Chatterino",
        "Description": "Twitch yay\u0131nc\u0131lar\u0131 ve izleyicileri i\u00e7in geli\u015fmi\u015f masa\u00fcst\u00fc sohbet istemcisi.",
        "Icon": "https://www.google.com/s2/favicons?domain=chatterino.com&sz=128"
      },
      {
        "Name": "Discord",
        "Id": "Discord.Discord",
        "Description": "Oyuncular ve topluluklar i\u00e7in sesli, g\u00f6r\u00fcnt\u00fcl\u00fc ve yaz\u0131l\u0131 sohbet.",
        "Icon": "https://www.google.com/s2/favicons?domain=discord.com&sz=128"
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
        "Name": "Ferdium",
        "Id": "Ferdium.Ferdium",
        "Description": "WhatsApp, Telegram, Discord, Slack ve e-posta hesaplar\u0131n\u0131 tek uygulamada birle\u015ftiren istemci.",
        "Icon": "https://www.google.com/s2/favicons?domain=ferdium.org&sz=128"
      },
      {
        "Name": "Mattermost Desktop",
        "Id": "Mattermost.MattermostDesktop",
        "Description": "Geli\u015ftirici ekipleri ve kurumlar i\u00e7in g\u00fcvenli, a\u00e7\u0131k kaynakl\u0131 mesajla\u015fma ve i\u015f birli\u011fi platformu.",
        "Icon": "https://www.google.com/s2/favicons?domain=mattermost.com&sz=128"
      },
      {
        "Name": "Microsoft Teams",
        "Id": "Microsoft.Teams",
        "Description": "G\u00f6r\u00fcnt\u00fcl\u00fc toplant\u0131, ekip sohbeti ve kurumsal i\u015f birli\u011fi uygulamas\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=microsoft.com&sz=128"
      },
      {
        "Name": "Proton Mail",
        "Id": "Proton.ProtonMail",
        "Description": "U\u00e7tan uca \u015fifreli Proton Mail ve Takvim i\u00e7in resmi masa\u00fcst\u00fc uygulamas\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=proton.me&sz=128"
      },
      {
        "Name": "qTox",
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
        "Name": "TeamSpeak 3",
        "Id": "TeamSpeakSystems.TeamSpeakClient",
        "Description": "D\u00fc\u015f\u00fck gecikmeli ve y\u00fcksek ses kaliteli klasik oyuncu sesli ileti\u015fim istemcisi (TS3).",
        "Icon": "https://www.google.com/s2/favicons?domain=teamspeak.com&sz=128"
      },
      {
        "Name": "TeamSpeak 6 Beta",
        "Id": "TeamSpeakSystems.TeamSpeakClient.Beta",
        "Description": "Modern aray\u00fcz ve ekran payla\u015f\u0131m\u0131 \u00f6zellikleriyle yeni nesil TeamSpeak istemcisi.",
        "Icon": "https://www.google.com/s2/favicons?domain=teamspeak.com&sz=128"
      },
      {
        "Name": "Telegram Desktop",
        "Id": "Telegram.TelegramDesktop",
        "Description": "H\u0131zl\u0131 ve bulut tabanl\u0131 masa\u00fcst\u00fc mesajla\u015fma uygulamas\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=telegram.org&sz=128"
      },
      {
        "Name": "Thunderbird",
        "Id": "Mozilla.Thunderbird",
        "Description": "Mozilla taraf\u0131ndan geli\u015ftirilen a\u00e7\u0131k kaynakl\u0131, g\u00fcvenli \u00e7oklu e-posta ve takvim istemcisi.",
        "Icon": "https://www.google.com/s2/favicons?domain=thunderbird.net&sz=128"
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
        "Name": "WhatsApp",
        "Id": "9NKSQGP7F2NH",
        "Description": "Masa\u00fcst\u00fc i\u00e7in resmi WhatsApp mesajla\u015fma uygulamas\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=whatsapp.com&sz=128"
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
        "Name": "Figma",
        "Id": "Figma.Figma",
        "Description": "Kullan\u0131c\u0131 aray\u00fcz\u00fc (UI/UX) tasar\u0131m\u0131 ve ekip i\u00e7i ger\u00e7ek zamanl\u0131 prototipleme uygulamas\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=figma.com&sz=128"
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
        "Name": "HandBrake",
        "Id": "HandBrake.HandBrake",
        "Description": "A\u00e7\u0131k kaynakl\u0131 video d\u00f6n\u00fc\u015ft\u00fcrme ve s\u0131k\u0131\u015ft\u0131rma arac\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=handbrake.fr&sz=128"
      },
      {
        "Name": "ImageGlass (Image Viewer)",
        "Id": "DuongDieuPhap.ImageGlass",
        "Description": "T\u00fcm g\u00f6rsel formatlar\u0131n\u0131 (WEBP, SVG, HEIC, RAW) destekleyen hafif ve modern foto\u011fraf g\u00f6r\u00fcnt\u00fcleyici.",
        "Icon": "https://www.google.com/s2/favicons?domain=imageglass.org&sz=128"
      },
      {
        "Name": "Inkscape",
        "Id": "Inkscape.Inkscape",
        "Description": "SVG format\u0131 ve vekt\u00f6rel grafik tasar\u0131m\u0131 i\u00e7in g\u00fc\u00e7l\u00fc, \u00fccretsiz ve a\u00e7\u0131k kaynakl\u0131 tasar\u0131m arac\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=inkscape.org&sz=128"
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
        "Name": "JPEGView",
        "Id": "sylikc.JPEGView",
        "Description": "Minimalist, ultra h\u0131zl\u0131 ve anl\u0131k g\u00f6r\u00fcnt\u00fc i\u015fleme destekli foto\u011fraf g\u00f6r\u00fcnt\u00fcleyici.",
        "Icon": "https://github.com/sylikc.png?size=128"
      },
      {
        "Name": "K-Lite Codec Standard",
        "Id": "CodecGuide.K-LiteCodecPack.Standard",
        "Description": "T\u00fcm ses ve video formatlar\u0131n\u0131n sorunsuz oynat\u0131lmas\u0131 i\u00e7in kapsaml\u0131 medya kodek paketi.",
        "Icon": "https://www.google.com/s2/favicons?domain=codecguide.com&sz=128"
      },
      {
        "Name": "Kdenlive",
        "Id": "KDE.Kdenlive",
        "Description": "\u00c7oklu iz, efekt ve renk d\u00fczenleme destekli \u00fccretsiz ve a\u00e7\u0131k kaynakl\u0131 video kurgu yaz\u0131l\u0131m\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=kdenlive.org&sz=128"
      },
      {
        "Name": "Kodi Media Center",
        "Id": "XBMCFoundation.Kodi",
        "Description": "Ev sinemas\u0131 ve medya ar\u015fivleri i\u00e7in a\u00e7\u0131k kaynakl\u0131 e\u011flence merkezi yaz\u0131l\u0131m\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=kodi.tv&sz=128"
      },
      {
        "Name": "Krita",
        "Id": "KDE.Krita",
        "Description": "Dijital boyama, konsept tasar\u0131m ve 2B animasyon i\u00e7in profesyonel a\u00e7\u0131k kaynakl\u0131 \u00e7izim st\u00fcdyosu.",
        "Icon": "https://www.google.com/s2/favicons?domain=krita.org&sz=128"
      },
      {
        "Name": "Media Player Classic - Home Cinema",
        "Id": "clsid2.mpc-hc",
        "Description": "\u00c7ok hafif, \u00f6zelle\u015ftirilebilir ve t\u00fcm formatlar\u0131 destekleyen klasik Media Player Classic (MPC-HC).",
        "Icon": "https://www.google.com/s2/favicons?domain=mpc-hc.org&sz=128"
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
        "Name": "nomacs",
        "Id": "nomacs.nomacs",
        "Description": "RAW ve PSD dahil t\u00fcm formatlar\u0131 a\u00e7abilen a\u00e7\u0131k kaynakl\u0131 ve h\u0131zl\u0131 resim g\u00f6r\u00fcnt\u00fcleyici.",
        "Icon": "https://www.google.com/s2/favicons?domain=nomacs.org&sz=128"
      },
      {
        "Name": "OBS Studio",
        "Id": "OBSProject.OBSStudio",
        "Description": "Profesyonel ekran kayd\u0131 ve canl\u0131 yay\u0131n yaz\u0131l\u0131m\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=obsproject.com&sz=128"
      },
      {
        "Name": "Paint.NET",
        "Id": "dotPDN.PaintDotNet",
        "Description": "Katman, \u00f6zel efekt ve eklenti destekli pratik resim ve foto\u011fraf d\u00fczenleme program\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=getpaint.net&sz=128"
      },
      {
        "Name": "Plex Desktop",
        "Id": "Plex.Plex",
        "Description": "Plex medya sunucular\u0131 ve dijital i\u00e7erikler i\u00e7in resmi masa\u00fcst\u00fc oynat\u0131c\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=plex.tv&sz=128"
      },
      {
        "Name": "Plex Media Server",
        "Id": "Plex.PlexMediaServer",
        "Description": "Kendi medya ar\u015fivinizi t\u00fcm cihazlar\u0131n\u0131za yay\u0131nlayan medya sunucusu.",
        "Icon": "https://www.google.com/s2/favicons?domain=plex.tv&sz=128"
      },
      {
        "Name": "Spotify",
        "Id": "Spotify.Spotify",
        "Description": "Dijital m\u00fczik ve podcast dinleme platformu.",
        "Icon": "https://www.google.com/s2/favicons?domain=spotify.com&sz=128"
      },
      {
        "Name": "Stremio",
        "Id": "Stremio.Stremio",
        "Description": "Film, dizi ve canl\u0131 yay\u0131nlar\u0131 eklenti deste\u011fiyle organize eden modern medya merkezi.",
        "Icon": "https://www.google.com/s2/favicons?domain=stremio.com&sz=128"
      },
      {
        "Name": "VLC Media Player",
        "Id": "VideoLAN.VLC",
        "Description": "T\u00fcm video ve ses formatlar\u0131n\u0131 kodeksiz oynatan medya oynat\u0131c\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=videolan.org&sz=128"
      }
    ]
  },
  {
    "Category": "Sistem ve Yard\u0131mc\u0131 Ara\u00e7lar",
    "Apps": [
      {
        "Name": ".NET Desktop Runtime 6",
        "Id": "Microsoft.DotNet.DesktopRuntime.6",
        "Description": ".NET 6 tabanl\u0131 masa\u00fcst\u00fc uygulamalar\u0131n\u0131 \u00e7al\u0131\u015ft\u0131rmak i\u00e7in gerekli \u00e7al\u0131\u015fma zaman\u0131 paketi.",
        "Icon": "https://www.google.com/s2/favicons?domain=dotnet.microsoft.com&sz=128"
      },
      {
        "Name": ".NET Desktop Runtime 7",
        "Id": "Microsoft.DotNet.DesktopRuntime.7",
        "Description": ".NET 7 masa\u00fcst\u00fc uygulamalar\u0131 i\u00e7in resmi Microsoft \u00e7al\u0131\u015fma zaman\u0131 bile\u015feni.",
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
        "Description": ".NET 10 (LTS) masa\u00fcst\u00fc uygulamalar\u0131 i\u00e7in resmi Microsoft \u00e7al\u0131\u015fma zaman\u0131 bile\u015feni.",
        "Icon": "https://www.google.com/s2/favicons?domain=dotnet.microsoft.com&sz=128"
      },
      {
        "Name": "1Password",
        "Id": "AgileBits.1Password",
        "Description": "Kapsaml\u0131 ve g\u00fcvenli bulut tabanl\u0131 parola y\u00f6neticisi.",
        "Icon": "https://www.google.com/s2/favicons?domain=1password.com&sz=128"
      },
      {
        "Name": "7-Zip",
        "Id": "7zip.7zip",
        "Description": "Y\u00fcksek s\u0131k\u0131\u015ft\u0131rma oran\u0131na sahip \u00fccretsiz ar\u015fiv y\u00f6neticisi.",
        "Icon": "https://www.google.com/s2/favicons?domain=7-zip.org&sz=128"
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
        "Name": "AnyDesk",
        "Id": "AnyDeskSoftwareGmbH.AnyDesk",
        "Description": "D\u00fc\u015f\u00fck gecikmeli ve h\u0131zl\u0131 uzak masa\u00fcst\u00fc ba\u011flant\u0131 yaz\u0131l\u0131m\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=anydesk.com&sz=128"
      },
      {
        "Name": "AutoHotkey",
        "Id": "AutoHotkey.AutoHotkey",
        "Description": "Windows i\u00e7in klavye k\u0131sayollar\u0131, makro ve otomasyon betik dili.",
        "Icon": "https://www.google.com/s2/favicons?domain=autohotkey.com&sz=128"
      },
      {
        "Name": "Autoruns",
        "Id": "Microsoft.Sysinternals.Autoruns",
        "Description": "Windows ba\u015flang\u0131c\u0131nda \u00e7al\u0131\u015fan t\u00fcm program, servis ve zamanlanm\u0131\u015f g\u00f6revleri y\u00f6netir.",
        "Icon": "https://www.google.com/s2/favicons?domain=microsoft.com&sz=128"
      },
      {
        "Name": "Bitwarden",
        "Id": "Bitwarden.Bitwarden",
        "Description": "A\u00e7\u0131k kaynakl\u0131, u\u00e7tan uca \u015fifreli g\u00fcvenli parola y\u00f6neticisi.",
        "Icon": "https://www.google.com/s2/favicons?domain=bitwarden.com&sz=128"
      },
      {
        "Name": "BlurAutoClicker",
        "Id": "Blur009.BlurAutoClicker",
        "Description": "Modern aray\u00fczl\u00fc ve \u00f6zelle\u015ftirilebilir otomatik fare t\u0131klama arac\u0131.",
        "Icon": "https://github.com/Blur009.png?size=128"
      },
      {
        "Name": "Bulk Crap Uninstaller",
        "Id": "Klocman.BulkCrapUninstaller",
        "Description": "Toplu program kald\u0131rma ve derin kay\u0131t defteri kal\u0131nt\u0131 temizleme arac\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=bcuninstaller.com&sz=128"
      },
      {
        "Name": "Cinebench R23",
        "Id": "Maxon.CinebenchR23",
        "Description": "\u0130\u015flemci (CPU) tekli ve \u00e7oklu \u00e7ekirdek performans\u0131n\u0131 \u00f6l\u00e7en end\u00fcstri standard\u0131 test arac\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=maxon.net&sz=128"
      },
      {
        "Name": "Cloudflare WARP",
        "Id": "Cloudflare.Warp",
        "Description": "\u0130nternet trafi\u011finizi \u015fifreleyen ve 1.1.1.1 DNS \u00fczerinden h\u0131zland\u0131ran \u00fccretsiz Cloudflare WARP istemcisi.",
        "Icon": "https://www.google.com/s2/favicons?domain=one.one.one.one&sz=128"
      },
      {
        "Name": "CPU-Z",
        "Id": "CPUID.CPU-Z",
        "Description": "\u0130\u015flemci, anakart ve RAM donan\u0131m bilgilerini detayl\u0131 g\u00f6sterir.",
        "Icon": "https://www.google.com/s2/favicons?domain=cpuid.com&sz=128"
      },
      {
        "Name": "CrystalDiskInfo",
        "Id": "CrystalDewWorld.CrystalDiskInfo",
        "Description": "SSD ve HDD disklerin sa\u011fl\u0131k durumunu, s\u0131cakl\u0131\u011f\u0131n\u0131 ve S.M.A.R.T. verilerini izler.",
        "Icon": "https://www.google.com/s2/favicons?domain=crystalmark.info&sz=128"
      },
      {
        "Name": "CrystalDiskMark",
        "Id": "CrystalDewWorld.CrystalDiskMark",
        "Description": "SSD ve sabit disklerin s\u0131ral\u0131 ve rastgele okuma/yazma h\u0131zlar\u0131n\u0131 test eder.",
        "Icon": "https://www.google.com/s2/favicons?domain=crystalmark.info&sz=128"
      },
      {
        "Name": "Deskflow",
        "Id": "Deskflow.Deskflow",
        "Description": "Tek bir klavye ve fareyi yerel a\u011fdaki birden fazla bilgisayar aras\u0131nda kesintisiz payla\u015fma arac\u0131 (Synergy \u00e7atal\u0131).",
        "Icon": "https://github.com/deskflow.png?size=128"
      },
      {
        "Name": "DISMTools",
        "Id": "CodingWondersSoftware.DISMTools.Stable",
        "Description": "Windows imajlar\u0131n\u0131, \u00f6zelliklerini ve paketlerini g\u00f6rsel aray\u00fczle y\u00f6neten DISM arac\u0131.",
        "Icon": "https://github.com/CodingWonders.png?size=128"
      },
      {
        "Name": "Display Driver Uninstaller",
        "Id": "Wagnardsoft.DisplayDriverUninstaller",
        "Description": "NVIDIA, AMD ve Intel ekran kart\u0131 s\u00fcr\u00fcc\u00fclerini kal\u0131nt\u0131s\u0131z temizleyen DDU arac\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=wagnardsoft.com&sz=128"
      },
      {
        "Name": "Ente Auth",
        "Id": "ente-io.auth-desktop",
        "Description": "A\u00e7\u0131k kaynakl\u0131, bulut yedeklemeli iki a\u015famal\u0131 do\u011frulama (2FA) kodu y\u00f6neticisi.",
        "Icon": "https://www.google.com/s2/favicons?domain=ente.io&sz=128"
      },
      {
        "Name": "Everything",
        "Id": "voidtools.Everything",
        "Description": "Dosya ve klas\u00f6rleri saliseler i\u00e7inde bulan ultra h\u0131zl\u0131 arama arac\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=voidtools.com&sz=128"
      },
      {
        "Name": "f.lux",
        "Id": "flux.flux",
        "Description": "G\u00fcn\u00fcn saatine g\u00f6re ekran mavi \u0131\u015f\u0131\u011f\u0131n\u0131 ve renk s\u0131cakl\u0131\u011f\u0131n\u0131 otomatik ayarlayan g\u00f6z koruma arac\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=justgetflux.com&sz=128"
      },
      {
        "Name": "Fan Control",
        "Id": "Rem0o.FanControl",
        "Description": "\u0130\u015flemci, ekran kart\u0131 ve kasa fanlar\u0131n\u0131 \u00f6zel s\u0131cakl\u0131k e\u011frilerine g\u00f6re y\u00f6neten hafif ara\u00e7.",
        "Icon": "https://www.google.com/s2/favicons?domain=getfancontrol.com&sz=128"
      },
      {
        "Name": "Files",
        "Id": "FilesCommunity.Files",
        "Description": "Sekmeli, modern tasar\u0131ml\u0131 ve geli\u015fmi\u015f \u00f6zellikli alternatif Windows Dosya Gezgini.",
        "Icon": "https://www.google.com/s2/favicons?domain=files.community&sz=128"
      },
      {
        "Name": "GlazeWM",
        "Id": "glzr-io.glazewm",
        "Description": "Windows i\u00e7in Linux i3wm benzeri klavye odakl\u0131 pencere d\u00f6\u015feme (Tiling Window Manager) arac\u0131.",
        "Icon": "https://github.com/glzr-io.png?size=128"
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
        "Icon": "https://www.google.com/s2/favicons?domain=gerardog.github.io&sz=128"
      },
      {
        "Name": "HWiNFO",
        "Id": "REALiX.HWiNFO",
        "Description": "T\u00fcm bilgisayar donan\u0131mlar\u0131n\u0131, sens\u00f6rleri ve voltaj de\u011ferlerini en ince ayr\u0131nt\u0131s\u0131na kadar analiz eder.",
        "Icon": "https://www.google.com/s2/favicons?domain=hwinfo.com&sz=128"
      },
      {
        "Name": "HWMonitor",
        "Id": "CPUID.HWMonitor",
        "Description": "Sistem s\u0131cakl\u0131klar\u0131n\u0131, voltajlar\u0131 ve fan h\u0131zlar\u0131n\u0131 canl\u0131 izleme arac\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=cpuid.com&sz=128"
      },
      {
        "Name": "HxD Hex Editor",
        "Id": "MHNexus.HxD",
        "Description": "B\u00fcy\u00fck dosyalar\u0131, RAM belle\u011fini ve disk sekt\u00f6rlerini d\u00fczenleyebilen h\u0131zl\u0131 Hex edit\u00f6r\u00fc.",
        "Icon": "https://www.google.com/s2/favicons?domain=mh-nexus.de&sz=128"
      },
      {
        "Name": "ImHex",
        "Id": "WerWolv.ImHex",
        "Description": "Tersine m\u00fchendisler ve geli\u015ftiriciler i\u00e7in geli\u015fmi\u015f onalt\u0131l\u0131k (Hex) dosya d\u00fczenleyici.",
        "Icon": "https://www.google.com/s2/favicons?domain=werwolv.net&sz=128"
      },
      {
        "Name": "Internet Download Manager",
        "Id": "Tonec.InternetDownloadManager",
        "Description": "Dosya indirme h\u0131zlar\u0131n\u0131 \u00e7oklu ba\u011flant\u0131 ile art\u0131ran geli\u015fmi\u015f indirme y\u00f6neticisi (IDM).",
        "Icon": "https://www.google.com/s2/favicons?domain=internetdownloadmanager.com&sz=128"
      },
      {
        "Name": "KeePassXC",
        "Id": "KeePassXCTeam.KeePassXC",
        "Description": "Parolalar\u0131 yerel veritaban\u0131nda y\u00fcksek \u015fifreleme ile saklayan a\u00e7\u0131k kaynakl\u0131 parola y\u00f6neticisi.",
        "Icon": "https://www.google.com/s2/favicons?domain=keepassxc.org&sz=128"
      },
      {
        "Name": "Lightshot",
        "Id": "Skillbrains.Lightshot",
        "Description": "Pratik ve h\u0131zl\u0131 ekran g\u00f6r\u00fcnt\u00fcs\u00fc alma arac\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=prnt.sc&sz=128"
      },
      {
        "Name": "Lively Wallpaper",
        "Id": "rocksdanister.LivelyWallpaper",
        "Description": "Videolar\u0131, web sayfalar\u0131n\u0131 ve 3B sahneleri etkile\u015fimli masa\u00fcst\u00fc arka plan\u0131 yapan a\u00e7\u0131k kaynakl\u0131 ara\u00e7.",
        "Icon": "https://www.google.com/s2/favicons?domain=rocksdanister.com&sz=128"
      },
      {
        "Name": "LocalSend",
        "Id": "LocalSend.LocalSend",
        "Description": "\u0130nternet gerektirmeden yerel a\u011fdaki (Wi-Fi) telefon ve bilgisayarlar aras\u0131nda h\u0131zl\u0131 dosya payla\u015f\u0131m\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=localsend.org&sz=128"
      },
      {
        "Name": "Microsoft PowerToys",
        "Id": "Microsoft.PowerToys",
        "Description": "Windows i\u00e7in geli\u015fmi\u015f pencere, k\u0131sayol ve verimlilik ara\u00e7lar\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=microsoft.com&sz=128"
      },
      {
        "Name": "MiniTool Partition Wizard",
        "Id": "MiniTool.PartitionWizard.Free",
        "Description": "Disk b\u00f6l\u00fcm\u00fc boyutland\u0131rma, formatlama ve disk klonlama i\u015flemleri i\u00e7in y\u00f6netim arac\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=partitionwizard.com&sz=128"
      },
      {
        "Name": "MSEdgeRedirect",
        "Id": "rcmaehl.MSEdgeRedirect",
        "Description": "Windows widget ve arama ba\u011flant\u0131lar\u0131n\u0131 zorunlu Edge yerine varsay\u0131lan taray\u0131c\u0131n\u0131za y\u00f6nlendirir.",
        "Icon": "https://github.com/rcmaehl.png?size=128"
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
        "Name": "Nilesoft Shell",
        "Id": "Nilesoft.Shell",
        "Description": "Windows 10/11 sa\u011f t\u0131k men\u00fcs\u00fcn\u00fc tamamen \u00f6zelle\u015ftiren g\u00fc\u00e7l\u00fc ba\u011flam men\u00fcs\u00fc y\u00f6neticisi.",
        "Icon": "https://www.google.com/s2/favicons?domain=nilesoft.org&sz=128"
      },
      {
        "Name": "Nmap",
        "Id": "Insecure.Nmap",
        "Description": "A\u011f ke\u015ffi, port taramas\u0131 ve g\u00fcvenlik denetimi i\u00e7in end\u00fcstri standard\u0131 analiz arac\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=nmap.org&sz=128"
      },
      {
        "Name": "NTLite",
        "Id": "Nlitesoft.NTLite",
        "Description": "Windows kurulum ISO dosyalar\u0131n\u0131 \u00f6zelle\u015ftirme ve bile\u015fen sadele\u015ftirme arac\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=ntlite.com&sz=128"
      },
      {
        "Name": "NVCleanstall",
        "Id": "TechPowerUp.NVCleanstall",
        "Description": "NVIDIA ekran kart\u0131 s\u00fcr\u00fcc\u00fclerini telemetri ve gereksiz bile\u015fenler olmadan temiz kurma arac\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=techpowerup.com&sz=128"
      },
      {
        "Name": "OFGB (Oh Frick Go Back)",
        "Id": "xM4ddy.OFGB",
        "Description": "Windows 11 i\u00e7erisindeki t\u00fcm sistem reklamlar\u0131n\u0131 ve \u00f6nerilerini tek t\u0131kla kapatan a\u00e7\u0131k kaynakl\u0131 ara\u00e7.",
        "Icon": "https://github.com/xM4ddy.png?size=128"
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
        "Name": "Policy Plus",
        "Id": "Fleex255.PolicyPlus",
        "Description": "Windows Home s\u00fcr\u00fcmleri dahil t\u00fcm sistemlerde Yerel Grup \u0130lkesi (gpedit) ayarlar\u0131n\u0131 y\u00f6netme arac\u0131.",
        "Icon": "https://github.com/Fleex255.png?size=128"
      },
      {
        "Name": "Process Explorer",
        "Id": "Microsoft.Sysinternals.ProcessExplorer",
        "Description": "G\u00f6rev Y\u00f6neticisi'nin \u00e7ok daha detayl\u0131 s\u00fcr\u00fcm\u00fc; hangi dosyan\u0131n veya DLL'in hangi s\u00fcre\u00e7te a\u00e7\u0131k oldu\u011funu g\u00f6sterir.",
        "Icon": "https://www.google.com/s2/favicons?domain=microsoft.com&sz=128"
      },
      {
        "Name": "Process Lasso",
        "Id": "BitSum.ProcessLasso",
        "Description": "Oyunlar ve a\u011f\u0131r programlar i\u00e7in ger\u00e7ek zamanl\u0131 CPU \u00f6nceliklendirme (ProBalance) ve \u00e7ekirdek atama arac\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=bitsum.com&sz=128"
      },
      {
        "Name": "Process Monitor",
        "Id": "Microsoft.Sysinternals.ProcessMonitor",
        "Description": "Ger\u00e7ek zamanl\u0131 dosya sistemi, Kay\u0131t Defteri (Registry) ve s\u00fcre\u00e7 etkinliklerini izleme arac\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=microsoft.com&sz=128"
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
        "Name": "PsTools",
        "Id": "Microsoft.Sysinternals.PsTools",
        "Description": "Uzaktan ve yerel sistem y\u00f6netimi i\u00e7in geli\u015fmi\u015f komut sat\u0131r\u0131 ara\u00e7 seti.",
        "Icon": "https://www.google.com/s2/favicons?domain=microsoft.com&sz=128"
      },
      {
        "Name": "PuTTY",
        "Id": "PuTTY.PuTTY",
        "Description": "SSH ve Telnet ba\u011flant\u0131lar\u0131 i\u00e7in en yayg\u0131n kullan\u0131lan hafif terminal istemcisi.",
        "Icon": "https://www.google.com/s2/favicons?domain=putty.org&sz=128"
      },
      {
        "Name": "qBittorrent",
        "Id": "qBittorrent.qBittorrent",
        "Description": "Reklams\u0131z, a\u00e7\u0131k kaynakl\u0131 ve hafif BitTorrent indirme istemcisi.",
        "Icon": "https://www.google.com/s2/favicons?domain=qbittorrent.org&sz=128"
      },
      {
        "Name": "QuickLook",
        "Id": "QL-Win.QuickLook",
        "Description": "Dosya Gezgini'nde Bo\u015fluk (Space) tu\u015funa basarak dosyalar\u0131 an\u0131nda \u00f6nizleme arac\u0131 (macOS tarz\u0131).",
        "Icon": "https://github.com/QL-Win.png?size=128"
      },
      {
        "Name": "RDCMan",
        "Id": "Microsoft.Sysinternals.RDCMan",
        "Description": "Birden fazla Uzak Masa\u00fcst\u00fc (RDP) ba\u011flant\u0131s\u0131n\u0131 tek pencereden y\u00f6netme arac\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=microsoft.com&sz=128"
      },
      {
        "Name": "Revo Uninstaller",
        "Id": "RevoUninstaller.RevoUninstaller",
        "Description": "Programlar\u0131 kal\u0131nt\u0131 ve kay\u0131t defteri izi b\u0131rakmadan kald\u0131r\u0131r.",
        "Icon": "https://www.google.com/s2/favicons?domain=revouninstaller.com&sz=128"
      },
      {
        "Name": "Rufus",
        "Id": "Rufus.Rufus",
        "Description": "\u00d6ny\u00fcklenebilir (Bootable) USB format belle\u011fi haz\u0131rlama arac\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=rufus.ie&sz=128"
      },
      {
        "Name": "RustDesk",
        "Id": "RustDesk.RustDesk",
        "Description": "Kendi sunucunuzu da kurabildi\u011finiz, TeamViewer ve AnyDesk alternatifi a\u00e7\u0131k kaynakl\u0131 uzak masa\u00fcst\u00fc.",
        "Icon": "https://www.google.com/s2/favicons?domain=rustdesk.com&sz=128"
      },
      {
        "Name": "ShareX",
        "Id": "ShareX.ShareX",
        "Description": "Geli\u015fmi\u015f ekran g\u00f6r\u00fcnt\u00fcs\u00fc alma, GIF kaydetme ve payla\u015f\u0131m arac\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=getsharex.com&sz=128"
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
        "Icon": "https://www.google.com/s2/favicons?domain=henrypp.org&sz=128"
      },
      {
        "Name": "Snappy Driver Installer Origin",
        "Id": "GlennDelahoy.SnappyDriverInstallerOrigin",
        "Description": "Eksik veya eski donan\u0131m s\u00fcr\u00fcc\u00fclerini reklams\u0131z ve \u00e7evrimd\u0131\u015f\u0131/\u00e7evrimi\u00e7i kuran a\u00e7\u0131k kaynakl\u0131 s\u00fcr\u00fcc\u00fc arac\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=delahoy.com&sz=128"
      },
      {
        "Name": "StartAllBack",
        "Id": "StartIsBack.StartAllBack",
        "Description": "Windows 11'e klasik g\u00f6rev \u00e7ubu\u011fu, ba\u015flat men\u00fcs\u00fc ve dosya gezgini g\u00f6r\u00fcn\u00fcm\u00fcn\u00fc geri kazand\u0131ran ara\u00e7.",
        "Icon": "https://www.google.com/s2/favicons?domain=startallback.com&sz=128"
      },
      {
        "Name": "Syncthing (CLI / Web UI)",
        "Id": "Syncthing.Syncthing",
        "Description": "Bulut kullanmadan cihazlar\u0131n\u0131z aras\u0131nda do\u011frudan \u015fifreli dosya senkronizasyonu sa\u011flayan a\u00e7\u0131k kaynakl\u0131 ara\u00e7.",
        "Icon": "https://www.google.com/s2/favicons?domain=syncthing.net&sz=128"
      },
      {
        "Name": "SyncTrayzor",
        "Id": "GermanCoding.SyncTrayzor",
        "Description": "Syncthing dosya senkronizasyon motoru i\u00e7in sistem tepsisi (Tray) ve g\u00f6rsel y\u00f6netim aray\u00fcz\u00fc.",
        "Icon": "https://www.google.com/s2/favicons?domain=syncthing.net&sz=128"
      },
      {
        "Name": "System Informer",
        "Id": "WinsiderSS.SystemInformer",
        "Description": "Geli\u015fmi\u015f s\u00fcre\u00e7, servis, a\u011f ba\u011flant\u0131s\u0131 ve \u00e7ekirdek d\u00fczeyinde sistem izleme arac\u0131 (eski Process Hacker).",
        "Icon": "https://www.google.com/s2/favicons?domain=systeminformer.com&sz=128"
      },
      {
        "Name": "Tailscale",
        "Id": "Tailscale.Tailscale",
        "Description": "Cihazlar\u0131n\u0131z aras\u0131nda g\u00fcvenli WireGuard tabanl\u0131 \u00f6zel yerel a\u011f kuran kolay VPN arac\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=tailscale.com&sz=128"
      },
      {
        "Name": "TCPView",
        "Id": "Microsoft.Sysinternals.TCPView",
        "Description": "Sistemdeki t\u00fcm a\u00e7\u0131k TCP ve UDP a\u011f ba\u011flant\u0131lar\u0131n\u0131 ve hangi programa ait olduklar\u0131n\u0131 canl\u0131 g\u00f6sterir.",
        "Icon": "https://www.google.com/s2/favicons?domain=microsoft.com&sz=128"
      },
      {
        "Name": "TeamViewer",
        "Id": "TeamViewer.TeamViewer",
        "Description": "Uzaktan teknik destek ve ekran kontrol\u00fc i\u00e7in yayg\u0131n kullan\u0131lan ba\u011flant\u0131 yaz\u0131l\u0131m\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=teamviewer.com&sz=128"
      },
      {
        "Name": "TeraCopy",
        "Id": "CodeSector.TeraCopy",
        "Description": "Dosya kopyalama ve ta\u015f\u0131ma i\u015flemlerini h\u0131zland\u0131ran, hata kurtarma ve do\u011frulama destekli ara\u00e7.",
        "Icon": "https://www.google.com/s2/favicons?domain=codesector.com&sz=128"
      },
      {
        "Name": "TightVNC",
        "Id": "GlavSoft.TightVNC",
        "Description": "Hafif ve \u00fccretsiz VNC tabanl\u0131 uzak masa\u00fcst\u00fc kontrol yaz\u0131l\u0131m\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=tightvnc.com&sz=128"
      },
      {
        "Name": "Total Commander",
        "Id": "Ghisler.TotalCommander",
        "Description": "\u00c7ift panelli, klavye odakl\u0131 klasik ve \u00e7ok g\u00fc\u00e7l\u00fc dosya y\u00f6neticisi.",
        "Icon": "https://www.google.com/s2/favicons?domain=ghisler.com&sz=128"
      },
      {
        "Name": "TranslucentTB",
        "Id": "CharlesMilette.TranslucentTB",
        "Description": "Windows g\u00f6rev \u00e7ubu\u011funu tamamen \u015feffaf veya bulan\u0131k (Acrylic/Blur) yapan hafif ara\u00e7.",
        "Icon": "https://www.google.com/s2/favicons?domain=translucenttb.github.io&sz=128"
      },
      {
        "Name": "TreeSize Free",
        "Id": "JAMSoftware.TreeSize.Free",
        "Description": "Disk alan\u0131n\u0131 hangi klas\u00f6rlerin doldurdu\u011funu a\u011fa\u00e7 yap\u0131s\u0131yla h\u0131zl\u0131ca g\u00f6steren analiz arac\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=jam-software.com&sz=128"
      },
      {
        "Name": "UniGetUI",
        "Id": "Devolutions.UniGetUI",
        "Description": "Winget, Scoop, Chocolatey ve npm paketlerini \u015f\u0131k bir g\u00f6rsel ma\u011faza aray\u00fcz\u00fcnden y\u00f6netme arac\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=devolutions.net&sz=128"
      },
      {
        "Name": "Ventoy",
        "Id": "Ventoy.Ventoy",
        "Description": "USB belle\u011fi tekrar formatlamadan i\u00e7ine birden fazla Windows/Linux ISO dosyas\u0131 kopyalay\u0131p ba\u015flatma arac\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=ventoy.net&sz=128"
      },
      {
        "Name": "VeraCrypt",
        "Id": "IDRIX.VeraCrypt",
        "Description": "Disk b\u00f6l\u00fcmlerini ve sanal s\u00fcr\u00fcc\u00fcleri ger\u00e7ek zamanl\u0131 \u015fifreleyen geli\u015fmi\u015f g\u00fcvenlik yaz\u0131l\u0131m\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=veracrypt.fr&sz=128"
      },
      {
        "Name": "Visual C++ 2015-2022 32-bit",
        "Id": "Microsoft.VCRedist.2015+.x86",
        "Description": "Oyunlar\u0131n ve programlar\u0131n \u00e7al\u0131\u015fmas\u0131 i\u00e7in zorunlu olan 32-bit Visual C++ (msvcp140.dll) k\u00fct\u00fcphanesi.",
        "Icon": "https://www.google.com/s2/favicons?domain=microsoft.com&sz=128"
      },
      {
        "Name": "Visual C++ 2015-2022 64-bit",
        "Id": "Microsoft.VCRedist.2015+.x64",
        "Description": "Oyunlar\u0131n ve programlar\u0131n hatas\u0131z a\u00e7\u0131lmas\u0131 i\u00e7in zorunlu 64-bit Visual C++ (vcruntime140.dll) k\u00fct\u00fcphanesi.",
        "Icon": "https://www.google.com/s2/favicons?domain=microsoft.com&sz=128"
      },
      {
        "Name": "Windhawk",
        "Id": "RamenSoftware.Windhawk",
        "Description": "Windows g\u00f6rev \u00e7ubu\u011fu, ba\u015flat men\u00fcs\u00fc ve sistem bile\u015fenlerini modlarla \u00f6zelle\u015ftirme ma\u011fazas\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=windhawk.net&sz=128"
      },
      {
        "Name": "WinRAR",
        "Id": "RARLab.WinRAR",
        "Description": "RAR ve ZIP ar\u015fivleri i\u00e7in klasik s\u0131k\u0131\u015ft\u0131rma program\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=rarlab.com&sz=128"
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
        "Name": "Wise Program Uninstaller (WiseCleaner)",
        "Id": "WiseCleaner.WiseProgramUninstaller",
        "Description": "Uygulamalar\u0131 zorla kald\u0131rma ve geride kalan kay\u0131tlar\u0131 temizleme arac\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=wisecleaner.com&sz=128"
      },
      {
        "Name": "WizTree",
        "Id": "AntibodySoftware.WizTree",
        "Description": "Diskte yer kaplayan dosya ve klas\u00f6rleri saniyeler i\u00e7inde analiz eder.",
        "Icon": "https://www.google.com/s2/favicons?domain=diskanalyzer.com&sz=128"
      }
    ]
  },
  {
    "Category": "Ofis, Belge ve Bulut",
    "Apps": [
      {
        "Name": "Adobe Acrobat Reader DC",
        "Id": "Adobe.Acrobat.Reader.64-bit",
        "Description": "End\u00fcstri standard\u0131 PDF g\u00f6r\u00fcnt\u00fcleme ve imzalama yaz\u0131l\u0131m\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=adobe.com&sz=128"
      },
      {
        "Name": "AFFiNE",
        "Id": "ToEverything.AFFiNE",
        "Description": "Notion ve Miro'yu birle\u015ftiren, gizlilik odakl\u0131 ve a\u00e7\u0131k kaynakl\u0131 belge/beyaz tahta \u00e7al\u0131\u015fma alan\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=affine.pro&sz=128"
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
        "Name": "Google Drive",
        "Id": "Google.Drive",
        "Description": "Google Drive bulut dosyalar\u0131n\u0131 bilgisayarla senkronize etme arac\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=drive.google.com&sz=128"
      },
      {
        "Name": "Joplin",
        "Id": "Joplin.Joplin",
        "Description": "U\u00e7tan uca \u015fifreleme ve bulut senkronizasyonu destekleyen a\u00e7\u0131k kaynakl\u0131 Markdown not uygulamas\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=joplinapp.org&sz=128"
      },
      {
        "Name": "LibreOffice",
        "Id": "TheDocumentFoundation.LibreOffice",
        "Description": "\u00dccretsiz ve a\u00e7\u0131k kaynakl\u0131 tam kapsaml\u0131 ofis paketi.",
        "Icon": "https://www.google.com/s2/favicons?domain=libreoffice.org&sz=128"
      },
      {
        "Name": "Logseq",
        "Id": "Logseq.Logseq",
        "Description": "Yerel Markdown dosyalar\u0131 \u00fczerinde \u00e7al\u0131\u015fan, \u00e7ift y\u00f6nl\u00fc ba\u011flant\u0131 destekli a\u00e7\u0131k kaynakl\u0131 bilgi taban\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=logseq.com&sz=128"
      },
      {
        "Name": "MEGAsync",
        "Id": "Mega.MEGASync",
        "Description": "MEGA u\u00e7tan uca \u015fifreli bulut depolama hesab\u0131 ile bilgisayar aras\u0131nda otomatik dosya senkronizasyonu.",
        "Icon": "https://www.google.com/s2/favicons?domain=mega.io&sz=128"
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
        "Name": "Notion",
        "Id": "Notion.Notion",
        "Description": "Notlar, g\u00f6revler ve projeler i\u00e7in hepsi bir arada \u00e7al\u0131\u015fma alan\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=notion.so&sz=128"
      },
      {
        "Name": "Obsidian",
        "Id": "Obsidian.Obsidian",
        "Description": "Markdown tabanl\u0131 ki\u015fisel bilgi taban\u0131 ve not alma uygulamas\u0131.",
        "Icon": "https://www.google.com/s2/favicons?domain=obsidian.md&sz=128"
      },
      {
        "Name": "Okular",
        "Id": "KDE.Okular",
        "Description": "PDF, ePub, DjVu ve \u00e7izgi roman formatlar\u0131n\u0131 destekleyen geli\u015fmi\u015f belge g\u00f6r\u00fcnt\u00fcleyici.",
        "Icon": "https://www.google.com/s2/favicons?domain=kde.org&sz=128"
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
        "Icon": "https://www.google.com/s2/favicons?domain=pdf24.org&sz=128"
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
        "Name": "SumatraPDF",
        "Id": "SumatraPDF.SumatraPDF",
        "Description": "\u00c7ok hafif ve ultra h\u0131zl\u0131 PDF, ePub ve \u00e7izgi roman okuyucu.",
        "Icon": "https://www.google.com/s2/favicons?domain=sumatrapdfreader.org&sz=128"
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
    "ExtraFeatures": [
      "VirtualMachinePlatform"
    ],
    "Desc": "Geli\u015ftiriciler i\u00e7in Windows i\u00e7inde yerel Linux \u00e7ekirde\u011fi ve Ubuntu/Debian terminali \u00e7al\u0131\u015ft\u0131rma altyap\u0131s\u0131."
  },
  {
    "Name": "Sanal Makine Platformu (Virtual Machine Platform)",
    "Feature": "VirtualMachinePlatform",
    "ExtraFeatures": [],
    "Desc": "WSL 2, Docker Desktop ve sanalla\u015ft\u0131rma tabanl\u0131 alt sistemler i\u00e7in gerekli temel donan\u0131m sanalla\u015ft\u0131rma bile\u015feni."
  },
  {
    "Name": "Windows Hiperviz\u00f6r Platformu (Hypervisor Platform)",
    "Feature": "HypervisorPlatform",
    "ExtraFeatures": [],
    "Desc": "QEMU, Android Em\u00fclat\u00f6rleri ve VirtualBox'\u0131n Hyper-V/WSL 2 ile \u00e7ak\u0131\u015fmadan \u00e7al\u0131\u015fmas\u0131n\u0131 sa\u011flayan sanalla\u015ft\u0131rma API'si."
  },
  {
    "Name": "Windows Sandbox (Kum Havuzu)",
    "Feature": "Containers-DisposableClientVM",
    "ExtraFeatures": [],
    "Desc": "\u015e\u00fcpheli dosyalar\u0131 ve kurulumlar\u0131 ana sisteme zarar vermeden izole ge\u00e7ici sanal makinede g\u00fcvenle test etme arac\u0131 (Pro/Ent)."
  },
  {
    "Name": "Hyper-V Sanalla\u015ft\u0131rma Altyap\u0131s\u0131",
    "Feature": "Microsoft-Hyper-V-All",
    "ExtraFeatures": [
      "Microsoft-Hyper-V-Tools-All",
      "Microsoft-Hyper-V-Management-Clients"
    ],
    "Desc": "Tam donan\u0131m sanalla\u015ft\u0131rma hiperviz\u00f6r\u00fc (Type-1 Hypervisor) ve Hyper-V Y\u00f6neticisi konsolu (Pro/Ent)."
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
    "Name": "Microsoft PDF Yazd\u0131r (Print to PDF)",
    "Feature": "Printing-PrintToPDFServices-Features",
    "ExtraFeatures": [],
    "Desc": "Belgeleri ve web sayfalar\u0131n\u0131 ek program gerektirmeden do\u011frudan PDF olarak kaydetmeyi sa\u011flayan yerle\u015fik sanal yaz\u0131c\u0131."
  },
  {
    "Name": "A\u011f Dosya Sistemi (NFS Client)",
    "Feature": "ServicesForNFS-ClientOnly",
    "ExtraFeatures": [
      "ClientForNFS-Infrastructure",
      "NFS-Administration"
    ],
    "Desc": "Linux/NAS sunucular\u0131ndaki NFS a\u011f payla\u015f\u0131mlar\u0131n\u0131 Windows'a do\u011frudan yerel disk gibi ba\u011flama bile\u015feni."
  },
  {
    "Name": "SMB 1.0 / CIFS Dosya Payla\u015f\u0131m \u0130stemcisi",
    "Feature": "SMB1Protocol-Client",
    "ExtraFeatures": [
      "SMB1Protocol"
    ],
    "Desc": "Eski NAS cihazlar\u0131na, modem USB payla\u015f\u0131mlar\u0131na ve eski Windows s\u00fcr\u00fcmlerine a\u011f \u00fczerinden eri\u015fim protokol\u00fc."
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
    "Name": "Basit TCP/IP Servisleri (Simple TCPIP)",
    "Feature": "SimpleTCP",
    "ExtraFeatures": [],
    "Desc": "A\u011f tan\u0131lamas\u0131 ve eski yaz\u0131l\u0131mlar i\u00e7in Echo, Daytime ve karakter \u00fcretici temel TCP/IP protokol servisleri."
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
          "Minimal",
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
          "Minimal",
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
          "Minimal",
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
          "Minimal",
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
          "Minimal",
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
          "Minimal",
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
          "Minimal",
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
          "Minimal",
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
          "Minimal",
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
          "Minimal",
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
        "Id": "Tweak_HAGS",
        "Recommended": true,
        "Preset": [
          "Standard",
          "Advanced"
        ],
        "Title": "Donan\u0131m H\u0131zland\u0131rmal\u0131 GPU Zamanlamas\u0131n\u0131 (HAGS) Etkinle\u015ftir",
        "Desc": "VRAM y\u00f6netimini do\u011frudan ekran kart\u0131na devrederek DLSS 3 Frame Generation deste\u011fini a\u00e7ar ve oyun gecikmesini d\u00fc\u015f\u00fcr\u00fcr."
      },
      {
        "Id": "Tweak_PowerThrottling",
        "Recommended": true,
        "Preset": [
          "Standard",
          "Advanced"
        ],
        "Title": "\u0130\u015flemci G\u00fc\u00e7 K\u0131s\u0131tlamas\u0131n\u0131 (Power Throttling) Devre D\u0131\u015f\u0131 B\u0131rak",
        "Desc": "Windows'un oyun ve arka plan uygulamalar\u0131nda i\u015flemci saat h\u0131zlar\u0131n\u0131 zorla d\u00fc\u015f\u00fcrmesini (PowerThrottlingOff) engeller."
      },
      {
        "Id": "Tweak_MouseAccel",
        "Recommended": true,
        "Preset": [
          "Standard",
          "Minimal",
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
          "Minimal",
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
        "Id": "Tweak_FastStartup",
        "Recommended": true,
        "Preset": [
          "Standard",
          "Advanced"
        ],
        "Title": "H\u0131zl\u0131 Ba\u015flatmay\u0131 (Fast Startup / Hiberboot) Kapat (Temiz \u00c7ekirdek A\u00e7\u0131l\u0131\u015f\u0131)",
        "Desc": "Bilgisayar kapat\u0131ld\u0131\u011f\u0131nda \u00e7ekirde\u011fin uyku modunda kalmas\u0131n\u0131 \u00f6nler; s\u00fcr\u00fcc\u00fc ve a\u011f tak\u0131lmalar\u0131n\u0131 giderir."
      },
      {
        "Id": "Tweak_BgApps",
        "Recommended": true,
        "Preset": [
          "Standard",
          "Minimal",
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
          "Minimal",
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
          "Minimal",
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
          "Minimal",
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
        "Preset": [
          "Minimal"
        ],
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
          "Minimal",
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
          "Minimal",
          "Advanced"
        ],
        "Title": "G\u00f6rev \u00c7ubu\u011fu Arama, Widget (Hava Durumu) ve G\u00f6rev G\u00f6r\u00fcn\u00fcm\u00fc Simgelerini Gizle",
        "Desc": "G\u00f6rev \u00e7ubu\u011fundaki gereksiz arama kutusunu, G\u00f6rev G\u00f6r\u00fcn\u00fcm\u00fc butonunu ve arka planda \u00e7al\u0131\u015fan Widget s\u00fcrecini kapat\u0131r."
      },
      {
        "Id": "Tweak_RemoveWidgets",
        "Recommended": false,
        "Preset": [],
        "Title": "Widgets / Haber Ak\u0131\u015f\u0131n\u0131 Tamamen Kald\u0131r (Windows Web Experience Pack)",
        "Desc": "G\u00f6rev \u00e7ubu\u011fundaki Widgets d\u00fc\u011fmesini ve arka plan haber ak\u0131\u015f\u0131n\u0131 sa\u011flayan paketi kald\u0131r\u0131r. UCPD korumal\u0131 kay\u0131t defteri ayarlar\u0131na dokunmaz. Geri al\u0131nd\u0131\u011f\u0131nda Microsoft Store'dan yeniden kurulur."
      },
      {
        "Id": "Tweak_DarkMode",
        "Recommended": true,
        "Preset": [
          "Standard",
          "Minimal",
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
          "Minimal",
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
          "Minimal",
          "Advanced"
        ],
        "Title": "Ayr\u0131nt\u0131l\u0131 Mavi Ekran (BSoD) ve A\u00e7\u0131l\u0131\u015f/Kapan\u0131\u015f Durum Mesajlar\u0131n\u0131 A\u00e7",
        "Desc": "Mavi ekran hatalar\u0131nda tam hata parametrelerini ve Windows a\u00e7\u0131l\u0131\u015f/kapan\u0131\u015f\u0131nda detayl\u0131 durum bilgisini (VerboseLogon) g\u00f6sterir."
      },
      {
        "Id": "Tweak_BatteryPct",
        "Recommended": false,
        "Preset": [
          "Minimal"
        ],
        "Title": "Sistem Tepsisinde Pil Y\u00fczdesini G\u00f6ster, Kayd\u0131rma \u00c7ubuklar\u0131n\u0131 Her Zaman A\u00e7\u0131k Tut",
        "Desc": "G\u00f6rev \u00e7ubu\u011fu pil simgesi yan\u0131nda say\u0131sal y\u00fczdeyi g\u00f6sterir ve pencere kayd\u0131rma \u00e7ubuklar\u0131n\u0131n otomatik gizlenmesini kapat\u0131r."
      },
      {
        "Id": "Tweak_HideSettingsHome",
        "Recommended": true,
        "Preset": [
          "Standard",
          "Minimal",
          "Advanced"
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
          "Minimal",
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
    "Name": "MSN Finans (Bing Finance)",
    "Pkg": "*Microsoft.BingFinance*",
    "StoreId": "9WZDNCRFHV4V",
    "DefaultCheck": true
  },
  {
    "Name": "MSN Spor (Bing Sports)",
    "Pkg": "*Microsoft.BingSports*",
    "StoreId": "9WZDNCRFHVH4",
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
    "Pkg": "*Teams*",
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
    "Name": "Paint 3D",
    "Pkg": "*Microsoft.MSPaint*",
    "StoreId": "9NBLGGH5FV99",
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
    "Name": "Microsoft Whiteboard (Beyaz Tahta)",
    "Pkg": "*Microsoft.Whiteboard*",
    "StoreId": "9MSPC6MP8FM4",
    "DefaultCheck": true
  },
  {
    "Name": "Microsoft OneNote (UWP)",
    "Pkg": "*Microsoft.Office.OneNote*",
    "StoreId": "9WZDNCRFHVJL",
    "DefaultCheck": true
  },
  {
    "Name": "Microsoft Office Sway",
    "Pkg": "*Microsoft.Office.Sway*",
    "StoreId": "9WZDNCRD2G0J",
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
    "Name": "Microsoft Aile G\u00fcvenli\u011fi (Family Safety)",
    "Pkg": "*MicrosoftCorporationII.MicrosoftFamily*",
    "StoreId": "9PDJDJS743XF",
    "DefaultCheck": true
  },
  {
    "Name": "Windows Widgets (Web Experience Pack)",
    "Pkg": "*MicrosoftWindows.Client.WebExperience*",
    "StoreId": "9MSSGKG348SP",
    "DefaultCheck": false
  },
  {
    "Name": "Mobil Cihazlar Arka Plan Ba\u011flant\u0131s\u0131 (CrossDevice)",
    "Pkg": "*MicrosoftWindows.CrossDevice*",
    "StoreId": "9NTXGKQ8P7N0",
    "DefaultCheck": false
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
    "Name": "Xbox Game Bar Arka Plan Eklentisi (GameOverlay)",
    "Pkg": "*Microsoft.XboxGameOverlay*",
    "StoreId": "",
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
    "StoreId": "9NBLGGH5SLLL",
    "DefaultCheck": false
  }
]
'@ | ConvertFrom-Json

$sync.MasScript = @'
@setlocal DisableDelayedExpansion
@echo off

:: ============================================================================
:: PROJE: PETRA OMNITOOL - GELISMIS WINDOWS & OFFICE SISTEM YONETIM ARACI (AIO)
:: DURUM: FAZ 1 - FAZ 6 FINAL SURUM (HWID / OHOOK / TSFORGE CRASH FIX)
:: ============================================================================

:: [1] KOMUT SATIRI PARAMETRELERINI YAKALA
set "_args="
set "_args=%*"
if defined _args set "_args=%_args:"=%"
set "_unattended=0"
if defined _args (
    for %%A in (%_args%) do (
        if /i "%%A"=="/S" set "_unattended=1"
        if /i "%%A"=="/Silent" set "_unattended=1"
    )
)

:: [2] SISTEM YOLU (PATH) VE ORTAM DEGISKENLERINI GARANTIYE AL
set "SysPath=%SystemRoot%\System32"
if exist "%SystemRoot%\Sysnative\reg.exe" set "SysPath=%SystemRoot%\Sysnative"
set "Path=%SysPath%;%SystemRoot%;%SysPath%\Wbem;%SysPath%\WindowsPowerShell\v1.0\;%LocalAppData%\Microsoft\WindowsApps\"

:: [3] 32-BIT CMD ICINDEN 64-BIT SISTEMDE CALISMA KONTROLU (SYSNATIVE RELAUNCH)
set "_cmdf=%~f0"
if exist "%SystemRoot%\Sysnative\cmd.exe" if not defined _rel1 (
    set "_rel1=1"
    start "" "%SystemRoot%\Sysnative\cmd.exe" /c ""%_cmdf%" %*"
    exit /b
)

:: [4] TURKCE KARAKTER (UTF-8) VE GECICI KLASOR AYARLARI
chcp 65001 >nul 2>&1
set "_work=%~dp0"
if "%_work:~-1%"=="\" set "_work=%_work:~0,-1%"
set "_temp=%Temp%"
set "psc=powershell.exe -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass"

:: [5] POWERSHELL VE WMI VARLIK KONTROLU
set "_pstest=1"
%psc% "$ExecutionContext.SessionState.LanguageMode" >nul 2>&1 || set "_pstest=0"

:: [6] YONETICI HAKLARI (UAC ELEVATION) KONTROLU VE OTOMATIK YUKSELTME
reg query "HKU\S-1-5-19" >nul 2>&1 && goto :Passed_UAC

if "%_unattended%"=="1" (
    echo [HATA] Katilimsiz mod icin betigi Yonetici olarak calistirmalisiniz.
    exit /b 1
)

echo.
echo  ====================================================================
echo   [i] Yonetici yetkileri gerekiyor, UAC penceresi baslatiliyor...
echo  ====================================================================
if "%_pstest%"=="1" (
    %psc% "$q = [char]34; Start-Process -FilePath $env:COMSPEC -ArgumentList ('/c ' + $q + $q + $env:_cmdf + $q + ' ' + $env:_args + $q) -Verb RunAs" >nul 2>&1 && exit /b
)
set "_vbs=%_temp%\uac_elevate_%random%.vbs"
(
    echo Set UAC = CreateObject^("Shell.Application"^)
    echo UAC.ShellExecute "%COMSPEC%", "/c """"%_cmdf%"" %_args%""", "", "runas", 1
) > "%_vbs%"
cscript //nologo "%_vbs%" >nul 2>&1
del /f /q "%_vbs%" >nul 2>&1
exit /b

:Passed_UAC
setlocal EnableDelayedExpansion
pushd "%_work%"

:: [7] MIMARI, WINDOWS BUILD VE SURUM TESPITI
set "os_arch=x86"
if /i "%PROCESSOR_ARCHITECTURE%"=="AMD64" set "os_arch=x64"
if /i "%PROCESSOR_ARCHITECTURE%"=="ARM64" set "os_arch=ARM64"
if defined PROCESSOR_ARCHITEW6432 set "os_arch=%PROCESSOR_ARCHITEW6432%"

set "winbuild=0"
for /f "tokens=2*" %%a in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v CurrentBuildNumber 2^>nul') do set "winbuild=%%b"
if "%winbuild%"=="0" (
    for /f "tokens=2 delims=[]" %%G in ('ver') do for /f "tokens=4 delims=. " %%H in ("%%G") do set "winbuild=%%H"
)

set "win_edition=Bilinmiyor"
set "edition_id=Bilinmiyor"
for /f "tokens=2*" %%a in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v ProductName 2^>nul') do set "win_edition=%%b"
for /f "tokens=2*" %%a in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v EditionID 2^>nul') do set "edition_id=%%b"
set "edition_id=!edition_id: =!"

if %winbuild% GEQ 22000 (
    set "win_edition=!win_edition:Windows 10=Windows 11!"
)

:: [8] ANSI ESCAPE (RENK MOTORU) KURULUMU
set "_ansi=0"
if %winbuild% GEQ 10586 (
    reg add "HKCU\Console" /v VirtualTerminalLevel /t REG_DWORD /d 1 /f >nul 2>&1
    for /f %%A in ('echo prompt $E^| cmd') do set "_esc=%%A"
    set "_ansi=1"
)

if "%_ansi%"=="1" (
    set "_Red=!_esc![91m"
    set "_Green=!_esc![92m"
    set "_Yellow=!_esc![93m"
    set "_Blue=!_esc![94m"
    set "_Magenta=!_esc![95m"
    set "_Cyan=!_esc![96m"
    set "_White=!_esc![97m"
    set "_Gray=!_esc![90m"
    set "_Reset=!_esc![0m"
) else (
    set "_Red=" & set "_Green=" & set "_Yellow=" & set "_Blue="
    set "_Magenta=" & set "_Cyan=" & set "_White=" & set "_Gray=" & set "_Reset="
)

:: [9] KRITIK SERVIS VE SISTEM SAGLIK KONTROLU (SELF-CHECK)
set "_serv_ok=1"
set "_wmi_ok=1"
sc query Winmgmt | find /i "RUNNING" >nul 2>&1
if errorlevel 1 (
    net start Winmgmt /y >nul 2>&1
    sc query Winmgmt | find /i "RUNNING" >nul 2>&1
    if errorlevel 1 set "_wmi_ok=0"
)
sc query sppsvc >nul 2>&1
if errorlevel 1 set "_serv_ok=0"

:: [10] KOMUT SATIRI PARAMETRE YONLENDIRICISI (CLI SWITCHES)
if defined _args (
    for %%A in (%_args%) do (
        if /i "%%A"=="/?"           call :CLI_Help & goto :End_Unattended
        if /i "%%A"=="/help"        call :CLI_Help & goto :End_Unattended
        if /i "%%A"=="/HWID"        call :HWID_Run & goto :End_Unattended
        if /i "%%A"=="/Ohook"       call :Ohook_Install & goto :End_Unattended
        if /i "%%A"=="/TSforge"     call :TSforge_Run_Win & goto :End_Unattended
        if /i "%%A"=="/KMS"         call :KMS_Act_All & goto :End_Unattended
        if /i "%%A"=="/KMS-Windows" call :KMS_Act_Win & goto :End_Unattended
        if /i "%%A"=="/KMS-Office"  call :KMS_Act_Off & goto :End_Unattended
        if /i "%%A"=="/KMS-Task"    call :KMS_InstallTask & goto :End_Unattended
        if /i "%%A"=="/Status"      call :Mod_CheckStatus & goto :End_Unattended
    )
)

:: ============================================================================
:: ANA MENU (TUI)
:: ============================================================================
:MainMenu
for /f "tokens=2*" %%a in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v EditionID 2^>nul') do set "edition_id=%%b"
set "edition_id=!edition_id: =!"
if "%_unattended%"=="0" mode con cols=98 lines=32 >nul 2>&1
title Petra OmniTool - Gelismis Sistem ve Lisans Yonetim Araci v4.0 [Mimari: %os_arch% ^| Build: %winbuild%]
cls
echo.
echo   !_Cyan!==============================================================================================!_Reset!
echo      !_White!PETRA OMNITOOL - GELISMIS WINDOWS ^& OFFICE LISANS YONETIM ARACI (AIO)!_Reset!
echo      !_Gray!Sistem: %win_edition% [%edition_id%] ^| Mimari: %os_arch% ^| Yapim: %winbuild%!_Reset!
echo   !_Cyan!==============================================================================================!_Reset!
if "%_wmi_ok%"=="0" echo      !_Red![UYARI] WMI Servisi [Winmgmt] yanit vermiyor. Sorun Giderme [8] menusunu kullanin.!_Reset!
if "%_pstest%"=="0" echo      !_Yellow![UYARI] PowerShell kisitlanmis veya calismiyor. Bazi gelismis moduller etkilenebilir.!_Reset!
echo.
echo      !_White!Ana Moduller:!_Reset!
echo.
echo       !_Green![1] HWID Yonetimi!_Reset!               ^| Windows 10-11                   (Kalici Dijital Lisans)
echo       !_Green![2] Ohook Yonetimi!_Reset!              ^| Microsoft Office                (Kalici Yerel SPPC Lisans)
echo       !_Green![3] TSforge Yonetimi!_Reset!            ^| Windows / ESU / Office          (Kalici Guvenilir Depolama)
echo       !_Green![4] Online KMS Yonetimi!_Reset!         ^| Windows / Office                (180 Gun + Otomatik Yenileme)
echo.
echo      !_White!Sistem ve Yonetim Araclari:!_Reset!
echo.
echo       !_Cyan![5] Lisans Durumu Kontrolu!_Reset!      ^| Detayli WMI, Slmgr, OSPP, BIOS OEM ve vNext Dokumu
echo       !_Cyan![6] Windows Surum Degistir!_Reset!      ^| Home / Pro / Enterprise CBS ^& DISM Surum Gecisi
echo       !_Cyan![7] Office Surum Degistir!_Reset!       ^| Click-to-Run (C2R) Kanal ve Lisans Surumu Yonetimi
echo       !_Yellow![8] Gelismis Sorun Giderme!_Reset!      ^| WMI, Token, ClipSVC, sppsvc ve Sistem Onarimi
echo       !_Magenta![9] Ekstra Araclar ($OEM$)!_Reset!      ^| $OEM$ Klasoru Cikartma, Base64 Motoru ve CLI Rehberi
echo.
echo       !_Red![0] Cikis!_Reset!
echo.
echo   !_Cyan!==============================================================================================!_Reset!
echo.

choice /C:1234567890 /N /M "   >> Lutfen yapmak istediginiz islemi secin [1-9, Cikis icin 0]: "
set "_erl=%errorlevel%"

if %_erl%==10 goto :Exit_Script
if %_erl%==9  call :Mod_Extras       & goto :MainMenu
if %_erl%==8  call :Mod_Troubleshoot & goto :MainMenu
if %_erl%==7  call :Mod_ChangeOffice & goto :MainMenu
if %_erl%==6  call :Mod_ChangeWin    & goto :MainMenu
if %_erl%==5  call :Mod_CheckStatus  & goto :MainMenu
if %_erl%==4  call :Mod_OnlineKMS    & goto :MainMenu
if %_erl%==3  call :Mod_TSforge      & goto :MainMenu
if %_erl%==2  call :Mod_Ohook        & goto :MainMenu
if %_erl%==1  call :Mod_HWID         & goto :MainMenu
goto :MainMenu

:: ============================================================================
:: YARDIMCI FONKSIYONLAR VE ANAHTAR VERITABANLARI (HELPER SUBROUTINES)
:: ============================================================================
:dk_start_service
set "_srv=%~1"
sc query "%_srv%" | find /i "RUNNING" >nul 2>&1 && exit /b 0
sc config "%_srv%" start= demand >nul 2>&1
net start "%_srv%" /y >nul 2>&1
sc query "%_srv%" | find /i "RUNNING" >nul 2>&1 && exit /b 0
exit /b 1

:dk_check_perm_win
set "_win_perm_ok=0"
%psc% "$p = Get-CimInstance SoftwareLicensingProduct -ErrorAction SilentlyContinue | Where-Object {$_.PartialProductKey -and $_.ApplicationID -eq '55c92734-d682-4d71-983e-d6ec3f16059f' -and $_.LicenseStatus -eq 1 -and $_.GracePeriodRemaining -eq 0}; if ($p) { exit 0 } else { exit 1 }" >nul 2>&1
if !errorlevel! equ 0 set "_win_perm_ok=1"
exit /b 0

:dk_check_act_win
set "_win_act_ok=0"
%psc% "$p = Get-CimInstance SoftwareLicensingProduct -ErrorAction SilentlyContinue | Where-Object {$_.PartialProductKey -and $_.ApplicationID -eq '55c92734-d682-4d71-983e-d6ec3f16059f' -and $_.LicenseStatus -eq 1}; if ($p) { exit 0 } else { exit 1 }" >nul 2>&1
if !errorlevel! equ 0 set "_win_act_ok=1"
exit /b 0

:dk_extract_b64
set "_b64_tag=%~1"
set "_b64_out=%~2"
findstr /i /c:"::B64_START_%_b64_tag%" "%_cmdf%" >nul 2>&1 || exit /b 1
%psc% "$c = Get-Content -LiteralPath $env:_cmdf; $s = $false; $b = New-Object System.Text.StringBuilder; foreach ($l in $c) { if ($l -match ('^::B64_END_' + $env:_b64_tag)) { break }; if ($s -and $l.StartsWith('::')) { [void]$b.Append($l.Substring(2).Trim()) }; if ($l -match ('^::B64_START_' + $env:_b64_tag)) { $s = $true } }; if ($b.Length -gt 0) { [IO.File]::WriteAllBytes($env:_b64_out, [Convert]::FromBase64String($b.ToString())); exit 0 } else { exit 1 }" >nul 2>&1
exit /b %errorlevel%

:dk_invoke_core_engine
set "_eng_arg=%~1"
set "_found_local_mas="

if exist "%_work%\MAS_AIO.cmd" set "_found_local_mas=%_work%\MAS_AIO.cmd"
if not defined _found_local_mas if exist "%_work%\MAS\All-In-One-Version-KL\MAS_AIO.cmd" set "_found_local_mas=%_work%\MAS\All-In-One-Version-KL\MAS_AIO.cmd"
if not defined _found_local_mas if exist "%_work%\..\MAS_AIO.cmd" set "_found_local_mas=%_work%\..\MAS_AIO.cmd"
if not defined _found_local_mas if exist "%_work%\..\All-In-One-Version-KL\MAS_AIO.cmd" set "_found_local_mas=%_work%\..\All-In-One-Version-KL\MAS_AIO.cmd"

if defined _found_local_mas (
    echo   !_Cyan![i] Yerel cekirdek modul bulundu, izole alt islemde calistiriliyor: !_found_local_mas!!_Reset!
    "%ComSpec%" /c ""!_found_local_mas!" %_eng_arg%"
    exit /b 0
)

echo   !_Yellow![*] Yerel klasorde ikili bilet dosyasi bulunamadi, Bellek Ici [RAM] Cekirdek Motoru baslatiliyor...!_Reset!
%psc% "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; $s = $null; try { $s = Invoke-RestMethod -Uri 'https://get.activated.win' -TimeoutSec 15 } catch {}; if (-not $s) { Write-Host '   [i] Standart baglanti engellendi, Cloudflare DoH [1.1.1.1] deneniyor...' -ForegroundColor Yellow; $s = (curl.exe -s -L --doh-url https://1.1.1.1/dns-query https://get.activated.win | Out-String) }; if ($s -and $s.Length -gt 500) { & ([ScriptBlock]::Create($s)) $env:_eng_arg; exit 0 } else { exit 1 }"
if !errorlevel! neq 0 (
    echo   !_Red![HATA] Cekirdek motor indirilemedi. Lutfen internet baglantinizi kontrol edin veya MAS_AIO.cmd dosyasini bu klasore kopyalayin.!_Reset!
    exit /b 1
)
exit /b 0

:Get_Edition_Key
set "%~2="
if /i "%~1"=="Core"                        set "%~2=YTMG3-N6DKC-DKB77-7M9GH-8HVX7"
if /i "%~1"=="CoreN"                       set "%~2=4CPRK-NM3K3-X6XXQ-RXX86-WXCHW"
if /i "%~1"=="CoreSingleLanguage"          set "%~2=BT79Q-G7N6G-PGBYW-4YWX6-6F4BT"
if /i "%~1"=="CoreCountrySpecific"         set "%~2=N2434-X9D7W-8PF6X-8DV9T-8TYMD"
if /i "%~1"=="Professional"                set "%~2=VK7JG-NPHTM-C97JM-9MPGT-3V66T"
if /i "%~1"=="ProfessionalN"               set "%~2=2B87N-8KFHP-DKV6R-Y2C8J-PKCKT"
if /i "%~1"=="ProfessionalWorkstation"     set "%~2=DXG7C-N36C4-C4HTG-X4T3X-2YV77"
if /i "%~1"=="ProfessionalWorkstationN"    set "%~2=WYPNQ-8C467-V2W6J-TX4WX-WT2RQ"
if /i "%~1"=="ProfessionalEducation"       set "%~2=8PTT6-RNW4C-6V7J2-C2D3X-MHBPB"
if /i "%~1"=="ProfessionalEducationN"      set "%~2=GJTYN-HDMQY-FRR76-HVGC7-QPF8P"
if /i "%~1"=="ProfessionalSingleLanguage"  set "%~2=G3KNM-CHG6T-R36X3-9QDG6-8M8K9"
if /i "%~1"=="Education"                   set "%~2=YNMGQ-8RYV3-4PGQ3-C8XTP-7CFBY"
if /i "%~1"=="EducationN"                  set "%~2=84NGF-MHBT6-FXBX8-QWJK7-DRR8H"
if /i "%~1"=="Enterprise"                  set "%~2=XGVPP-NMH47-7TTHJ-W3FW7-8HV2C"
if /i "%~1"=="EnterpriseN"                 set "%~2=3V6Q6-NQXCX-V8YXR-9QCYV-QPFCT"
if /i "%~1"=="IoTEnterprise"               set "%~2=XQQYW-NFFMW-XJPBH-K8732-CKFFD"
if /i "%~1"=="IoTEnterpriseS"              set "%~2=QPM6N-7J2WJ-P88HH-P3YRH-YY74H"
if /i "%~1"=="EnterpriseS"                 set "%~2=NK96Y-D9CD8-W44CQ-R8YTK-DYJWX"
if /i "%~1"=="EnterpriseSN"                set "%~2=2DBW3-N2PJG-MVHW3-G7TDK-9HKR4"
if /i "%~1"=="ServerRdsh"                  set "%~2=NJCF7-PW8QT-3324D-688JX-2YV66"
if /i "%~1"=="ServerStandard"              set "%~2=VDYBN-27WPP-V4HQT-9VMD4-VMK7H"
if /i "%~1"=="ServerDatacenter"            set "%~2=W3GGN-FT8W3-Y4M27-J84CP-Q3VJ9"
exit /b 0

:Get_GVLK_Key
set "%~2="
if /i "%~1"=="Core"                        set "%~2=TX9XD-98N7V-6WMQ6-BX7FG-H8Q99"
if /i "%~1"=="CoreN"                       set "%~2=3KHY7-WNT83-DGQKR-F7HPR-844BM"
if /i "%~1"=="CoreSingleLanguage"          set "%~2=7HNRX-D7KGG-3K4RQ-4WPJ4-YTDFH"
if /i "%~1"=="CoreCountrySpecific"         set "%~2=PVMJN-6DFY6-9CCP6-7BKTT-D3WVR"
if /i "%~1"=="Professional"                set "%~2=W269N-WFGWX-YVC9B-4J6C9-T83GX"
if /i "%~1"=="ProfessionalN"               set "%~2=MH37W-N47XK-V7XM9-C7227-GCQG9"
if /i "%~1"=="ProfessionalWorkstation"     set "%~2=NRG8B-VKK3Q-CXVCJ-9G2XF-6Q84J"
if /i "%~1"=="ProfessionalWorkstationN"    set "%~2=9FNHH-K3HBT-3W4TD-6383H-6XYWF"
if /i "%~1"=="ProfessionalEducation"       set "%~2=6TP4R-GNPTD-KYYHQ-7B7DP-J447Y"
if /i "%~1"=="ProfessionalEducationN"      set "%~2=YVWGF-BXNMC-HTQYQ-CPQ99-66QFC"
if /i "%~1"=="Education"                   set "%~2=NW6C2-QMPVW-D7KKK-3GKT6-VCFB2"
if /i "%~1"=="EducationN"                  set "%~2=2WH4N-8QGBV-H22JP-CT43Q-MDWWJ"
if /i "%~1"=="Enterprise"                  set "%~2=NPPR9-FWDCX-D2C8J-H872K-2YT43"
if /i "%~1"=="EnterpriseN"                 set "%~2=DPH2V-TTNVB-4X9Q3-TJR4H-KHJW4"
if /i "%~1"=="EnterpriseG"                 set "%~2=YYVX9-NTFWV-6MDM3-9PT4T-4M68B"
if /i "%~1"=="EnterpriseS"                 set "%~2=M7XTQ-FN8P6-TTKYV-9D4CC-J462D"
if /i "%~1"=="EnterpriseSN"                set "%~2=92NFX-8DJQP-P6BBQ-THF9C-7CG2H"
if /i "%~1"=="IoTEnterprise"               set "%~2=NPPR9-FWDCX-D2C8J-H872K-2YT43"
if /i "%~1"=="IoTEnterpriseS"              set "%~2=KBN8V-HFGQ4-MGXVD-347P6-PDQGT"
if /i "%~1"=="ServerRdsh"                  set "%~2=CPWHC-NT2C7-VYW78-DHDB2-PG3GK"
if /i "%~1"=="ServerStandard"              set "%~2=VDYBN-27WPP-V4HQT-9VMD4-VMK7H"
if /i "%~1"=="ServerDatacenter"            set "%~2=W3GGN-FT8W3-Y4M27-J84CP-Q3VJ9"
exit /b 0

:Get_Office_GVLK
set "%~2="
if /i "%~1"=="ProPlus2024Volume"       set "%~2=XJ2XN-FW8RK-P4HMP-DKDBV-GCVGB"
if /i "%~1"=="Standard2024Volume"      set "%~2=V28N4-JG22K-W66P8-VTMGK-H6HGR"
if /i "%~1"=="ProjectPro2024Volume"    set "%~2=FQQ23-N4YCY-73HQ3-FM9WC-76HF4"
if /i "%~1"=="VisioPro2024Volume"      set "%~2=B7TN8-FJ8V3-7QYCP-HQPMV-YY89G"
if /i "%~1"=="ProPlus2021Volume"       set "%~2=FXYTK-NJJ8C-GB6DW-3DYQT-6F7TH"
if /i "%~1"=="Standard2021Volume"      set "%~2=KDX7X-BNVR8-TKW4D-TKFF7-86B6F"
if /i "%~1"=="ProjectPro2021Volume"    set "%~2=FTNWT-C6WBT-8HMGF-K9PRX-QV9H8"
if /i "%~1"=="VisioPro2021Volume"      set "%~2=KNH8D-FGHT4-T8RK3-CTDYJ-K2HT4"
if /i "%~1"=="ProPlus2019Volume"       set "%~2=NMMKJ-6RK4F-KMJVX-8D9MJ-6MWKP"
if /i "%~1"=="Standard2019Volume"      set "%~2=6NWWJ-YQWMR-QKGCB-6TMB3-9D9HK"
if /i "%~1"=="ProjectPro2019Volume"    set "%~2=B4NPR-3FKK7-T2MBV-FRQ4W-PKD2B"
if /i "%~1"=="VisioPro2019Volume"      set "%~2=9BGNQ-K37YR-RQHF2-38RQ3-7VCBB"
if /i "%~1"=="MondoVolume"             set "%~2=HFTND-W9MK4-8B7MJ-B6C4G-XQBR2"
exit /b 0

:: ============================================================================
:: FAZ 2: LISANS VE AKTIVASYON DURUMU KONTROL MODULU (CHECK ACTIVATION STATUS)
:: ============================================================================
:Mod_CheckStatus
cls
if "%_unattended%"=="0" mode con cols=105 lines=45 >nul 2>&1
title Lisans ve Aktivasyon Durumu Kontrolu [Mimari: %os_arch% ^| Build: %winbuild%]

echo.
echo   !_Cyan!====================================================================================================!_Reset!
echo      !_White!DETAYLI WINDOWS VE OFFICE LISANS DURUMU RAPORU!_Reset!
echo      !_Gray!Lutfen bekleyin, WMI / SPPSVC / OSPP / BIOS OEM ve vNext kayitlari taraniyor...!_Reset!
echo   !_Cyan!====================================================================================================!_Reset!
echo.

call :dk_start_service sppsvc >nul 2>&1
call :dk_start_service Winmgmt >nul 2>&1

if "%_pstest%"=="0" (
    echo   !_Red![HATA] PowerShell kullanilamiyor. Standart slmgr ciktisina geciliyor...!_Reset!
    echo.
    cscript //nologo "%SysPath%\slmgr.vbs" /dlv
    echo.
    if "%_unattended%"=="0" pause
    exit /b
)

%psc% "$ErrorActionPreference = 'SilentlyContinue'; " ^
  "$os = Get-CimInstance -ClassName Win32_OperatingSystem; " ^
  "$sls = Get-CimInstance -ClassName SoftwareLicensingService; " ^
  "Write-Host '  === [1] SISTEM, SPPSVC VE BIOS OEM ANAHTAR BILGILERI ===' -ForegroundColor Cyan; " ^
  "Write-Host ('   Isletim Sistemi   : ' + $os.Caption + ' (' + $os.OSArchitecture + ')') -ForegroundColor White; " ^
  "Write-Host ('   Surum / Build     : ' + $os.Version + ' / ' + $os.BuildNumber) -ForegroundColor Gray; " ^
  "Write-Host ('   Istemci CMID      : ' + $sls.ClientMachineID) -ForegroundColor Gray; " ^
  "$oemKey = $sls.OA3xOriginalProductKey; " ^
  "if ($oemKey) { Write-Host ('   BIOS OEM Anahtari : ' + $oemKey + ' (' + $sls.OA3xOriginalProductKeyDescription + ')') -ForegroundColor Green } else { Write-Host '   BIOS OEM Anahtari : Anakart uzerinde gomulu OA3 OEM anahtari bulunamadi.' -ForegroundColor DarkGray }; " ^
  "Write-Host ''; " ^
  "Write-Host '  === [2] WINDOWS LISANS DURUMU (WMI / SoftwareLicensingProduct) ===' -ForegroundColor Cyan; " ^
  "$winProds = Get-CimInstance -ClassName SoftwareLicensingProduct | Where-Object { $_.PartialProductKey -ne $null -and $_.ApplicationID -eq '55c92734-d682-4d71-983e-d6ec3f16059f' }; " ^
  "if (-not $winProds) { Write-Host '   [-] Yuklu Windows urun anahtari bulunamadi.' -ForegroundColor Red } " ^
  "foreach ($p in $winProds) { " ^
  "  $statusText = switch ($p.LicenseStatus) { " ^
  "    0 {'Lisanssiz (Unlicensed)'} " ^
  "    1 {'Lisansli (Licensed)'} " ^
  "    2 {'OOB Grace (Ilk Kullanim Suresi)'} " ^
  "    3 {'OOT Grace (Donanim Degisikligi)'} " ^
  "    4 {'Non-Genuine Grace (Orijinal Degil)'} " ^
  "    5 {'Bildirim Modu (Notification)'} " ^
  "    6 {'Uzatilmis Sure (Extended Grace)'} " ^
  "    default {'Bilinmiyor (' + $p.LicenseStatus + ')'} " ^
  "  }; " ^
  "  $color = if ($p.LicenseStatus -eq 1) {'Green'} elseif ($p.LicenseStatus -in 2,3,6) {'Yellow'} else {'Red'}; " ^
  "  $graceDays = [math]::Round($p.GracePeriodRemaining / 1440, 1); " ^
  "  $expireMsg = if ($p.LicenseStatus -eq 1 -and $p.GracePeriodRemaining -eq 0) {'Kalici (Permanent)'} elseif ($p.GracePeriodRemaining -gt 0) { $graceDays.ToString() + ' Gun (' + $p.GracePeriodRemaining + ' dk) kaldi' } else {'Suresi Dolmus / Yok'}; " ^
  "  Write-Host ('   Urun Adi          : ' + $p.Name) -ForegroundColor White; " ^
  "  Write-Host ('   Aciklama / Kanal  : ' + $p.Description) -ForegroundColor Gray; " ^
  "  Write-Host ('   SKU ID            : ' + $p.ID) -ForegroundColor Gray; " ^
  "  Write-Host ('   Kismi Anahtar     : XXXXX-XXXXX-XXXXX-XXXXX-' + $p.PartialProductKey) -ForegroundColor Gray; " ^
  "  Write-Host ('   Lisans Durumu     : ' + $statusText) -ForegroundColor $color; " ^
  "  Write-Host ('   Gecerlilik Suresi : ' + $expireMsg) -ForegroundColor $color; " ^
  "  if ($p.Description -match 'KMS') { " ^
  "    $kmsHost = if ($p.DiscoveredKeyManagementServiceMachineName) {$p.DiscoveredKeyManagementServiceMachineName} else {$sls.KeyManagementServiceMachine}; " ^
  "    $kmsPort = if ($p.DiscoveredKeyManagementServiceMachinePort -ne 0) {$p.DiscoveredKeyManagementServiceMachinePort} else {$sls.KeyManagementServicePort}; " ^
  "    Write-Host ('   KMS Sunucu / Port : ' + $kmsHost + ' : ' + $kmsPort) -ForegroundColor Yellow; " ^
  "  } " ^
  "  Write-Host '   --------------------------------------------------------------------------------------' -ForegroundColor DarkGray; " ^
  "}; " ^
  "Write-Host ''; " ^
  "Write-Host '  === [3] MICROSOFT OFFICE LISANS DURUMU (SPP / OSPP / OHOOK) ===' -ForegroundColor Cyan; " ^
  "$offProds = Get-CimInstance -ClassName SoftwareLicensingProduct | Where-Object { $_.PartialProductKey -ne $null -and $_.ApplicationID -eq '0ff1ce15-a989-479d-af46-f275c6370663' }; " ^
  "$osppProds = Get-CimInstance -ClassName OfficeSoftwareProtectionProduct; " ^
  "$allOff = @($offProds) + @($osppProds) | Where-Object { $_ -ne $null }; " ^
  "if ($allOff.Count -eq 0) { Write-Host '   [i] WMI/OSPP uzerinde aktif geleneksel Office anahtari tespit edilmedi.' -ForegroundColor Yellow } " ^
  "foreach ($o in $allOff) { " ^
  "  $oStatus = switch ($o.LicenseStatus) { 1 {'Lisansli (Licensed)'} 0 {'Lisanssiz'} 5 {'Bildirim Modu (Notification)'} default {'Grace / Diger (' + $o.LicenseStatus + ')'} }; " ^
  "  $oColor = if ($o.LicenseStatus -eq 1) {'Green'} else {'Yellow'}; " ^
  "  $oDays = [math]::Round($o.GracePeriodRemaining / 1440, 1); " ^
  "  $oExp = if ($o.LicenseStatus -eq 1 -and $o.GracePeriodRemaining -eq 0) {'Kalici (Permanent / Ohook)'} elseif ($o.GracePeriodRemaining -gt 0) { $oDays.ToString() + ' Gun kaldi' } else {'Suresi Dolmus / Yok'}; " ^
  "  Write-Host ('   Office Urunu      : ' + $o.Name) -ForegroundColor White; " ^
  "  Write-Host ('   Aciklama          : ' + $o.Description) -ForegroundColor Gray; " ^
  "  Write-Host ('   Kismi Anahtar     : XXXXX-' + $o.PartialProductKey) -ForegroundColor Gray; " ^
  "  Write-Host ('   Durum / Sure      : ' + $oStatus + ' | ' + $oExp) -ForegroundColor $oColor; " ^
  "  Write-Host '   --------------------------------------------------------------------------------------' -ForegroundColor DarkGray; " ^
  "}; " ^
  "Write-Host ''; " ^
  "Write-Host '  === [4] OHOOK VE OFFICE C2R / vNEXT KONTROLU ===' -ForegroundColor Cyan; " ^
  "$c2rPath = 'HKLM:\SOFTWARE\Microsoft\Office\ClickToRun\Configuration'; " ^
  "if (Test-Path $c2rPath) { " ^
  "  $c2r = Get-ItemProperty -Path $c2rPath; " ^
  "  Write-Host ('   C2R Surum / Mimari: ' + $c2r.VersionToReport + ' (' + $c2r.Platform + ')') -ForegroundColor White; " ^
  "  Write-Host ('   Yuklu Urunler     : ' + $c2r.ProductReleaseIds) -ForegroundColor Gray; " ^
  "  Write-Host ('   Guncelleme Kanali : ' + $c2r.CDNBaseUrl) -ForegroundColor Gray; " ^
  "} else { Write-Host '   [i] Office Click-to-Run (C2R) kurulumu bulunamadi.' -ForegroundColor DarkGray }; " ^
  "$ohookFound = $false; " ^
  "$pfPaths = @($env:ProgramFiles, ${env:ProgramFiles(x86)}) | Where-Object { $_ } | Select-Object -Unique; " ^
  "foreach ($pf in $pfPaths) { " ^
  "  $sppcFiles = Get-ChildItem -Path ($pf + '\Microsoft Office\root\vfs\System*') -Filter 'sppc*.dll' -ErrorAction SilentlyContinue; " ^
  "  if ($sppcFiles) { $ohookFound = $true; foreach ($f in $sppcFiles) { Write-Host ('   [Ohook Tespit]    : ' + $f.FullName) -ForegroundColor Green } } " ^
  "}; " ^
  "if (-not $ohookFound) { Write-Host '   Ohook Durumu      : Sistemde ozel sppc.dll kancasi bulunamadi.' -ForegroundColor Gray }"

echo.
echo   !_Cyan!====================================================================================================!_Reset!
echo      !_Green![Tamamlandi]!_Reset! Raporu Masaustune kaydetmek icin !_Yellow![K]!_Reset!, Ana Menuye donmek icin !_White![M]!_Reset! tusuna basin.
echo   !_Cyan!====================================================================================================!_Reset!
echo.

if "%_unattended%"=="1" exit /b 0

choice /C:KM0 /N /M "   >> Seciminiz [K: Masaustune Rapor Kaydet | M / 0: Ana Menu]: "
set "_st_choice=%errorlevel%"

if %_st_choice%==1 (
    set "_repfile=%UserProfile%\Desktop\Lisans_Durum_Raporu.txt"
    echo.
    echo   !_Yellow![i] Rapor Masaustune kaydediliyor, lutfen bekleyin...!_Reset!
    cscript //nologo "%SysPath%\slmgr.vbs" /dlv > "!_repfile!" 2>&1
    echo   !_Green![+] Rapor basariyla kaydedildi:!_Reset! !_repfile!
    echo.
    pause
)
exit /b 0

:: ============================================================================
:: FAZ 3: GELISMIS SORUN GIDERME VE ONARIM MODULU (TROUBLESHOOT)
:: ============================================================================
:Mod_Troubleshoot
cls
if "%_unattended%"=="0" mode con cols=98 lines=34 >nul 2>&1
title Gelismis Sorun Giderme ve Sistem Onarim Araclari
echo.
echo   !_Cyan!==============================================================================================!_Reset!
echo      !_White!GELISMIS SORUN GIDERME VE LISANS ONARIM MERKEZI (TROUBLESHOOT)!_Reset!
echo      !_Gray!Lisans hatalarini, bozuk WMI havuzunu ve durmus sistem servislerini onarir.!_Reset!
echo   !_Cyan!==============================================================================================!_Reset!
echo.
echo       !_Green![1] Lisans ve Aktivasyon Depolarini Yeniden Olustur (Rebuild Licensing Tokens ^& Rearm)!_Reset!
echo           !_Gray!Bozuk tokens.dat, data.dat ve ClipSVC onbellegini sifirlayip yeniden olusturur.!_Reset!
echo.
echo       !_Green![2] Kritik Lisans Servislerini ve Izinlerini Onar (Fix sppsvc, ClipSVC, Winmgmt, wuauserv)!_Reset!
echo           !_Gray!Devre disi birakilmis veya kilitlenmis lisans servislerini varsayilana dondurur.!_Reset!
echo.
echo       !_Yellow![3] WMI Havuzunu Dogrula ve Onar (Repair / Salvage WMI Repository)!_Reset!
echo           !_Gray!Sorgu hatalarina yol acan bozuk WMI (Winmgmt) veritabanini onarir ve MOF derler.!_Reset!
echo.
echo       !_Yellow![4] KMS Kalintilarini, Gorev Zamanlayiciyi ve Ohook Kancalarini Temizle!_Reset!
echo           !_Gray!Eski KMS sunucu kayitlarini, yenileme gorevlerini ve ozel sppc.dll dosyalarini siler.!_Reset!
echo.
echo       !_Cyan![5] Sistem Dosyalarini ve Imajini Onar (DISM RestoreHealth + SFC /SCANNOW)!_Reset!
echo           !_Gray!Bozuk Windows sistem dosyalarini ve CBS bilesen deposunu denetler ve onarir.!_Reset!
echo.
echo       !_Red![0] Ana Menuye Don!_Reset!
echo.
echo   !_Cyan!==============================================================================================!_Reset!
echo.

choice /C:123450 /N /M "   >> Onarim islemini secin [1-5, Ana Menu icin 0]: "
set "_tb_erl=%errorlevel%"

if %_tb_erl%==6 exit /b 0
if %_tb_erl%==5 call :TB_SystemRepair & goto :Mod_Troubleshoot
if %_tb_erl%==4 call :TB_CleanKMSOhook & goto :Mod_Troubleshoot
if %_tb_erl%==3 call :TB_RepairWMI & goto :Mod_Troubleshoot
if %_tb_erl%==2 call :TB_FixServices & goto :Mod_Troubleshoot
if %_tb_erl%==1 call :TB_RebuildTokens & goto :Mod_Troubleshoot
goto :Mod_Troubleshoot

:TB_RebuildTokens
cls
echo.
echo   !_Cyan!=== [1] LISANS VE TOKEN DEPOLARI YENIDEN OLUSTURULUYOR ===!_Reset!
echo.
echo   !_Yellow![*] Yazilim Koruma Servisi (sppsvc) ve ClipSVC durduruluyor...!_Reset!
net stop sppsvc /y >nul 2>&1
net stop ClipSVC /y >nul 2>&1

set "_spp_store=%SystemRoot%\System32\spp\store"
if exist "%SystemRoot%\System32\spp\store\2.0" set "_spp_store=%SystemRoot%\System32\spp\store\2.0"

echo   !_Yellow![*] Eski tokens.dat ve cache.dat yedeklenip temizleniyor...!_Reset!
if exist "!_spp_store!\tokens.dat" (
    takeown /f "!_spp_store!\*" /a >nul 2>&1
    icacls "!_spp_store!\*" /grant administrators:F >nul 2>&1
    del /f /q "!_spp_store!\tokens.dat.bak" >nul 2>&1
    ren "!_spp_store!\tokens.dat" "tokens.dat.bak" >nul 2>&1
    if exist "!_spp_store!\cache\cache.dat" del /f /q "!_spp_store!\cache\cache.dat" >nul 2>&1
)

echo   !_Yellow![*] Servisler baslatiliyor ve lisans motoru tetikleniyor (slmgr /rilc)...!_Reset!
call :dk_start_service ClipSVC
call :dk_start_service sppsvc
cscript //nologo "%SysPath%\slmgr.vbs" /rilc >nul 2>&1

echo.
echo   !_Green![+] Lisans ve Token depolari basariyla yeniden olusturuldu.!_Reset!
echo.
pause
exit /b

:TB_FixServices
cls
echo.
echo   !_Cyan!=== [2] KRITIK LISANS SERVISLERI ONARILIYOR ===!_Reset!
echo.
for %%S in (RpcSs DcomLaunch sppsvc ClipSVC Winmgmt LicenseManager wuauserv KeyIso) do (
    echo   !_Gray![*] %%S servisi kontrol ediliyor ve yapilandiriliyor...!_Reset!
    sc config "%%S" start= demand >nul 2>&1
    if /i "%%S"=="RpcSs" sc config "%%S" start= auto >nul 2>&1
    if /i "%%S"=="DcomLaunch" sc config "%%S" start= auto >nul 2>&1
    if /i "%%S"=="Winmgmt" sc config "%%S" start= auto >nul 2>&1
    if /i "%%S"=="sppsvc" sc config "%%S" start= delayed-auto >nul 2>&1
    net start "%%S" /y >nul 2>&1
)
echo.
echo   !_Green![+] Tum kritik servisler basariyla yapilandirildi ve baslatildi.!_Reset!
echo.
pause
exit /b

:TB_RepairWMI
cls
echo.
echo   !_Cyan!=== [3] WMI HAVUZU DOGRULANIYOR VE ONARILIYOR ===!_Reset!
echo.
echo   !_Yellow![*] WMI Tutarlilik kontrolu yapiliyor (winmgmt /verifyrepository)...!_Reset!
winmgmt /verifyrepository
echo.
echo   !_Yellow![*] WMI Havuzu kurtarma islemi baslatiliyor (winmgmt /salvagerepository)...!_Reset!
net stop Winmgmt /y >nul 2>&1
winmgmt /salvagerepository
net start Winmgmt /y >nul 2>&1

echo   !_Yellow![*] SPPSVC ve Lisans MOF dosyalari yeniden kaydediliyor...!_Reset!
if exist "%SysPath%\wbem\sppwmi.mof" mofcomp "%SysPath%\wbem\sppwmi.mof" >nul 2>&1
set "_wmi_ok=1"
echo.
echo   !_Green![+] WMI Havuzu onarimi tamamlandi.!_Reset!
echo.
pause
exit /b

:TB_CleanKMSOhook
cls
echo.
echo   !_Cyan!=== [4] KMS KALINTILARI VE OHOOK KANCALARI TEMIZLENIYOR ===!_Reset!
echo.
echo   !_Yellow![*] KMS sunucu onbellegi ve port ayarlari temizleniyor...!_Reset!
cscript //nologo "%SysPath%\slmgr.vbs" /ckms >nul 2>&1
cscript //nologo "%SysPath%\slmgr.vbs" /cpky >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform" /v KeyManagementServiceName /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform" /v KeyManagementServicePort /f >nul 2>&1

echo   !_Yellow![*] Bilinen KMS zamanlanmis gorevleri kontrol edilip siliniyor...!_Reset!
schtasks /query /tn "Online_KMS_Activation_Script-Renewal" >nul 2>&1 && schtasks /delete /tn "Online_KMS_Activation_Script-Renewal" /f >nul 2>&1
schtasks /query /tn "Online_KMS_Activation_Script-Run_Once" >nul 2>&1 && schtasks /delete /tn "Online_KMS_Activation_Script-Run_Once" /f >nul 2>&1

echo   !_Yellow![*] Office vfs\System dizinlerindeki ozel Ohook (sppc.dll) kancalari kontrol ediliyor...!_Reset!
%psc% "$pfPaths = @($env:ProgramFiles, ${env:ProgramFiles(x86)}) | Where-Object { $_ } | Select-Object -Unique; foreach ($pf in $pfPaths) { foreach ($d in @('System', 'SystemX86')) { $v = Join-Path $pf ('Microsoft Office\root\vfs\' + $d); foreach ($f in @('sppc.dll', 'sppcs.dll')) { $fp = Join-Path $v $f; if (Test-Path $fp) { Write-Host ('   [-] Kaldiriliyor: ' + $fp) -ForegroundColor Red; Remove-Item -LiteralPath $fp -Force -ErrorAction SilentlyContinue } } } }"
reg delete "HKLM\SOFTWARE\Microsoft\Office\ClickToRun\Configuration" /v "OhookInstalled" /f >nul 2>&1
echo.
echo   !_Green![+] KMS ayarlari ve Ohook kancalari basariyla temizlendi.!_Reset!
echo.
pause
exit /b

:TB_SystemRepair
cls
echo.
echo   !_Cyan!=== [5] SISTEM DOSYALARI VE BILESEN DEPOSU ONARILIYOR (DISM ^& SFC) ===!_Reset!
echo.
echo   !_Yellow![1/2] DISM /Online /Cleanup-Image /RestoreHealth calistiriliyor (Bu islem birkac dakika surebilir)...!_Reset!
dism.exe /Online /Cleanup-Image /RestoreHealth
echo.
echo   !_Yellow![2/2] SFC /SCANNOW calistiriliyor...!_Reset!
sfc.exe /scannow
echo.
echo   !_Green![+] Sistem dosyalari tarama ve onarim islemi tamamlandi.!_Reset!
echo.
pause
exit /b

:: ============================================================================
:: FAZ 4A: WINDOWS SURUM DEGISTIRME MODULU (CHANGE WINDOWS EDITION)
:: ============================================================================
:Mod_ChangeWin
cls
if "%_unattended%"=="0" mode con cols=98 lines=36 >nul 2>&1
title Windows Surum Degistirme Araci [Mevcut: %edition_id%]

for /f "tokens=2*" %%a in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v EditionID 2^>nul') do set "edition_id=%%b"
set "edition_id=!edition_id: =!"

echo.
echo   !_Cyan!==============================================================================================!_Reset!
echo      !_White!WINDOWS SURUM DEGISTIRME MERKEZI (CBS / DISM / CHANGEPK)!_Reset!
echo      !_Gray!Mevcut Surum: %win_edition% [EditionID: %edition_id%] ^| Yapim: %winbuild%!_Reset!
echo   !_Cyan!==============================================================================================!_Reset!
echo.
echo   !_Yellow![*] Sisteminizden gecis yapilabilecek resmi hedef surumler (Target Editions) sorgulaniyor...!_Reset!
echo.

set "_ed_count=0"
for /f "tokens=4" %%E in ('dism /online /English /Get-TargetEditions 2^>nul ^| findstr /i /c:"Target Edition : "') do (
    set /a _ed_count+=1
    set "_target_!_ed_count!=%%E"
    call :Get_Edition_Key "%%E" _tkey
    echo       !_Green![!_ed_count!] %%E!_Reset! !_Gray![Genel Kurulum Anahtari: !_tkey!]!_Reset!
)

echo.
echo   !_White!Dogrudan Hizli Gecis Secenekleri (Genel CBS / Changepk Yontemi):!_Reset!
echo       !_Cyan![P] Professional!_Reset!               (VK7JG-NPHTM-C97JM-9MPGT-3V66T)
echo       !_Cyan![E] Enterprise!_Reset!                 (XGVPP-NMH47-7TTHJ-W3FW7-8HV2C)
echo       !_Cyan![I] IoT Enterprise!_Reset!             (XQQYW-NFFMW-XJPBH-K8732-CKFFD)
echo       !_Cyan![W] ProfessionalWorkstation!_Reset!    (DXG7C-N36C4-C4HTG-X4T3X-2YV77)
echo       !_Cyan![D] Education!_Reset!                  (YNMGQ-8RYV3-4PGQ3-C8XTP-7CFBY)
echo       !_Cyan![S] Enterprise LTSC 2021/2024!_Reset!  (NK96Y-D9CD8-W44CQ-R8YTK-DYJWX)
echo.
echo       !_Red![0] Ana Menuye Don!_Reset!
echo   !_Cyan!==============================================================================================!_Reset!
echo.

set "_win_sel="
set /p "_win_sel=   >> Hedef surum numarasini veya harfini girin [1-%_ed_count%, P/E/I/W/D/S, Cikis: 0]: "
if not defined _win_sel goto :Mod_ChangeWin
if "%_win_sel%"=="0" exit /b 0

set "_chosen_ed="
if /i "%_win_sel%"=="P" set "_chosen_ed=Professional"
if /i "%_win_sel%"=="E" set "_chosen_ed=Enterprise"
if /i "%_win_sel%"=="I" set "_chosen_ed=IoTEnterprise"
if /i "%_win_sel%"=="W" set "_chosen_ed=ProfessionalWorkstation"
if /i "%_win_sel%"=="D" set "_chosen_ed=Education"
if /i "%_win_sel%"=="S" set "_chosen_ed=EnterpriseS"

if not defined _chosen_ed (
    if defined _target_%_win_sel% (
        set "_chosen_ed=!_target_%_win_sel%!"
    )
)

if not defined _chosen_ed (
    echo.
    echo   !_Red![HATA] Gecersiz secim yaptiniz. Lutfen listeden bir secenek girin.!_Reset!
    timeout /t 2 >nul
    goto :Mod_ChangeWin
)

call :Get_Edition_Key "!_chosen_ed!" _upgrade_key
if not defined _upgrade_key (
    echo.
    echo   !_Red![HATA] !_chosen_ed! surumu icin uygun gecis anahtari bulunamadi.!_Reset!
    pause
    goto :Mod_ChangeWin
)

echo.
echo   !_Yellow!==============================================================================================!_Reset!
echo    Hedef Surum     : !_Green!!_chosen_ed!!_Reset!
echo    Kurulum Anahtari: !_White!!_upgrade_key!!_Reset!
echo   !_Yellow!==============================================================================================!_Reset!
echo.
echo   !_White!Gecis Yontemini Secin:!_Reset!
echo    !_Green![1] Standart DISM / Changepk Yontemi!_Reset! (Onerilen - Resmi CBS gecisi, yeniden baslatma gerekir)
echo    !_Cyan![2] Hizli SLMGR Anahtar Enjeksiyonu!_Reset!  (Ayni cekirdek ailesi icinde aninda gecis - Orn: Pro -^> Ent)
echo    !_Red![0] Iptal!_Reset!
echo.
choice /C:120 /N /M "   >> Yontem seciminiz [1, 2 veya 0]: "
set "_up_meth=%errorlevel%"
if %_up_meth%==3 goto :Mod_ChangeWin

if %_up_meth%==2 (
    echo.
    echo   !_Yellow![*] Urun anahtari slmgr.vbs /ipk ile sisteme yukleniyor...!_Reset!
    cscript //nologo "%SysPath%\slmgr.vbs" /ipk !_upgrade_key!
    echo.
    echo   !_Green![+] Anahtar islemi tamamlandi. Yeni surumu Ana Menuden veya Durum Kontrolunden dogrulayabilirsiniz.!_Reset!
    pause
    exit /b 0
)

if %_up_meth%==1 (
    echo.
    echo   !_Yellow![*] DISM /Set-Edition veya Changepk ile surum yukseltmesi baslatiliyor...!_Reset!
    echo   !_Gray!Not: Islem sirasinda ekran %%100 seviyesine geldiginde sistem yeniden baslatma isteyebilir.!_Reset!
    echo.
    dism /online /Set-Edition:!_chosen_ed! /ProductKey:!_upgrade_key! /NoRestart
    if !errorlevel! neq 0 if !errorlevel! neq 3010 (
        echo.
        echo   !_Yellow![i] DISM dogrudan gecisi desteklemedi, Changepk.exe motoru devreye aliniyor...!_Reset!
        changepk.exe /ProductKey !_upgrade_key!
    ) else (
        echo.
        echo   !_Green![+] Surum gecis paketi basariyla uygulandi. Degisikligin tamamlanmasi icin bilgisayari yeniden baslatin.!_Reset!
    )
    echo.
    pause
    exit /b 0
)
goto :Mod_ChangeWin

:: ============================================================================
:: FAZ 4B: OFFICE SURUM VE KANAL DEGISTIRME MODULU (CHANGE OFFICE EDITION)
:: ============================================================================
:Mod_ChangeOffice
cls
if "%_unattended%"=="0" mode con cols=102 lines=36 >nul 2>&1
title Microsoft Office C2R Surum ve Kanal Yonetimi

set "_c2r_reg=HKLM\SOFTWARE\Microsoft\Office\ClickToRun\Configuration"
set "_c2r_ver=Bulunamadi"
set "_c2r_prods=Bulunamadi"
set "_c2r_cdn=Bulunamadi"
set "_c2r_plat=x64"

reg query "%_c2r_reg%" >nul 2>&1 && goto :C2R_Installed
echo.
echo   !_Red!==============================================================================================!_Reset!
echo      !_White![HATA] Sistemde Microsoft Office Click-to-Run [C2R] kurulumu tespit edilemedi.!_Reset!
echo      !_Gray!Bu modul yalnizca Office 2016 / 2019 / 2021 / 2024 / 365 C2R kurulumlari icindir.!_Reset!
echo   !_Red!==============================================================================================!_Reset!
echo.
pause
exit /b 0

:C2R_Installed
for /f "tokens=2*" %%a in ('reg query "%_c2r_reg%" /v VersionToReport 2^>nul') do set "_c2r_ver=%%b"
for /f "tokens=2*" %%a in ('reg query "%_c2r_reg%" /v ProductReleaseIds 2^>nul') do set "_c2r_prods=%%b"
for /f "tokens=2*" %%a in ('reg query "%_c2r_reg%" /v CDNBaseUrl 2^>nul') do set "_c2r_cdn=%%b"
for /f "tokens=2*" %%a in ('reg query "%_c2r_reg%" /v Platform 2^>nul') do set "_c2r_plat=%%b"

echo.
echo   !_Cyan!==================================================================================================!_Reset!
echo      !_White!MICROSOFT OFFICE (C2R) SURUM VE GUNCELLEME KANALI YONETIMI!_Reset!
echo      !_Gray!Mevcut Surum: %_c2r_ver% [%_c2r_plat%] ^| Yuklu Urunler: %_c2r_prods%!_Reset!
echo      !_Gray!Mevcut CDN  : %_c2r_cdn%!_Reset!
echo   !_Cyan!==================================================================================================!_Reset!
echo.
echo      !_White![A] Guncelleme Kanalini (Update Channel) Degistir:!_Reset!
echo       !_Green![1] Current (Retail / Perakende)!_Reset!         - En guncel ozellik guncellemeleri
echo       !_Green![2] Monthly Enterprise (Aylik Kurumsal)!_Reset!  - Ayda bir kararli ozellik ve guvenlik
echo       !_Green![3] Semi-Annual (6 Aylik Kurumsal)!_Reset!       - Maksimum kararlilik (Yilda 2 kez)
echo       !_Green![4] PerpetualVL2021 (Office LTSC 2021)!_Reset!   - Office 2021 Volume resmi kanali
echo       !_Green![5] PerpetualVL2024 (Office LTSC 2024)!_Reset!   - Office 2024 Volume resmi kanali
echo.
echo      !_White![B] Office Urun / Lisans Kimligi (ProductReleaseId) Ekle veya Degistir:!_Reset!
echo       !_Cyan![6] ProPlus2024Volume Ekle/Donustur!_Reset!      - Office LTSC Professional Plus 2024
echo       !_Cyan![7] ProPlus2021Volume Ekle/Donustur!_Reset!      - Office LTSC Professional Plus 2021
echo       !_Cyan![8] O365ProPlusRetail Ekle/Donustur!_Reset!      - Microsoft 365 Apps for Enterprise
echo       !_Cyan![9] MondoVolume (Tum Office Paketleri)!_Reset!   - Project, Visio ve tum yetkileri iceren paket
echo.
echo       !_Red![0] Ana Menuye Don!_Reset!
echo   !_Cyan!==================================================================================================!_Reset!
echo.

choice /C:1234567890 /N /M "   >> Seciminizi yapin [1-9, Ana Menu icin 0]: "
set "_off_erl=%errorlevel%"

if %_off_erl%==10 exit /b 0

set "_new_cdn="
if %_off_erl%==1 set "_new_cdn=http://officecdn.microsoft.com/pr/492350f6-3a01-4f97-b9c0-c7c6ddf67d60"
if %_off_erl%==2 set "_new_cdn=http://officecdn.microsoft.com/pr/55336b82-a18d-4dd6-b5f6-9e5095c314a6"
if %_off_erl%==3 set "_new_cdn=http://officecdn.microsoft.com/pr/7ffbc6bf-bc32-4f92-8982-f9dd17fd3114"
if %_off_erl%==4 set "_new_cdn=http://officecdn.microsoft.com/pr/f2e724c1-748f-4b47-8fb8-8e0d210e9208"
if %_off_erl%==5 set "_new_cdn=http://officecdn.microsoft.com/pr/7983bac0-e531-40cf-be00-fd24fe66619c"

if defined _new_cdn (
    echo.
    echo   !_Yellow![*] Office C2R Guncelleme Kanali yapilandiriliyor...!_Reset!
    reg add "%_c2r_reg%" /v CDNBaseUrl /t REG_SZ /d "!_new_cdn!" /f >nul 2>&1
    reg add "%_c2r_reg%" /v UpdateChannel /t REG_SZ /d "!_new_cdn!" /f >nul 2>&1
    reg delete "%_c2r_reg%" /v UpdateUrl /f >nul 2>&1
    reg delete "HKLM\SOFTWARE\Policies\Microsoft\office\16.0\common\officeupdate" /v updatebranch /f >nul 2>&1
    echo   !_Yellow![*] OfficeC2RClient ile kanal senkronizasyonu tetikleniyor...!_Reset!
    if exist "%CommonProgramFiles%\microsoft shared\ClickToRun\OfficeC2RClient.exe" (
        "%CommonProgramFiles%\microsoft shared\ClickToRun\OfficeC2RClient.exe" /changesetting Channel=!_new_cdn! >nul 2>&1
        "%CommonProgramFiles%\microsoft shared\ClickToRun\OfficeC2RClient.exe" /update user >nul 2>&1
    )
    echo   !_Green![+] Guncelleme kanali basariyla degistirildi ve Office guncelleyici baslatildi.!_Reset!
    echo.
    pause
    goto :Mod_ChangeOffice
)

set "_add_prod="
if %_off_erl%==6 set "_add_prod=ProPlus2024Volume"
if %_off_erl%==7 set "_add_prod=ProPlus2021Volume"
if %_off_erl%==8 set "_add_prod=O365ProPlusRetail"
if %_off_erl%==9 set "_add_prod=MondoVolume"

if defined _add_prod (
    echo.
    echo   !_Yellow![*] ProductReleaseIds kaydina !_add_prod! ekleniyor...!_Reset!
    echo "%_c2r_prods%" | find /i "!_add_prod!" >nul 2>&1
    if errorlevel 1 (
        set "_updated_prods=%_c2r_prods%,!_add_prod!"
        reg add "%_c2r_reg%" /v ProductReleaseIds /t REG_SZ /d "!_updated_prods!" /f >nul 2>&1
    )
    echo   !_Green![+] Office urun kimligi [!_add_prod!] kayit defterine basariyla islendi.!_Reset!
    echo   !_Gray!Not: Ilgili urun lisansini aktif etmek icin Ana Menudeki Ohook [2] veya KMS [4] modulunu kullanabilirsiniz.!_Reset!
    echo.
    pause
    goto :Mod_ChangeOffice
)
goto :Mod_ChangeOffice

:: ============================================================================
:: FAZ 5A: HWID (DIJITAL LISANS VE DONANIM KIMLIGI YONETIM MODULU)
:: ============================================================================
:Mod_HWID
cls
if "%_unattended%"=="0" mode con cols=98 lines=32 >nul 2>&1
title HWID Dijital Lisans Yonetim Modulu [Surum: %edition_id%]

echo.
echo   !_Cyan!==============================================================================================!_Reset!
echo      !_White!HWID (WINDOWS 10 / 11 KALICI DIJITAL LISANS VE CLIPSVC YONETIMI)!_Reset!
echo      !_Gray!Mevcut Surum: %win_edition% [%edition_id%] ^| Mimari: %os_arch% ^| Yapim: %winbuild%!_Reset!
echo   !_Cyan!==============================================================================================!_Reset!
echo.
if %winbuild% LSS 10240 (
    echo   !_Red![HATA] HWID Dijital Lisans mimarisi yalnizca Windows 10 ve Windows 11 [Build 10240+] destekler.!_Reset!
    echo.
    pause
    exit /b 1
)
echo       !_Green![1] HWID Kalici Dijital Lisans Etkinlestirmesini Baslat (Tam Otomatik Motor)!_Reset!
echo       !_Cyan![2] Sadece Varsayilan Genel Retail/OEM Anahtarini Yukle (Install Default Key Only)!_Reset!
echo       !_Yellow![3] BIOS/UEFI Gomulu Orijinal OEM Anahtarini (OA3x) Algila ve Etkinlestir!_Reset!
echo       !_Red![0] Ana Menuye Don!_Reset!
echo.
echo   !_Cyan!==============================================================================================!_Reset!
echo.

choice /C:1230 /N /M "   >> Seciminiz [1-3, Ana Menu icin 0]: "
set "_hw_erl=%errorlevel%"
if %_hw_erl%==4 exit /b 0
if %_hw_erl%==3 call :HWID_ApplyOEM & goto :Mod_HWID
if %_hw_erl%==2 call :HWID_KeyOnly & goto :Mod_HWID
if %_hw_erl%==1 call :HWID_Run & goto :Mod_HWID
goto :Mod_HWID

:HWID_KeyOnly
echo.
call :Get_Edition_Key "%edition_id%" _hwid_key
if not defined _hwid_key (
    echo   !_Red![HATA] %edition_id% surumu icin varsayilan HWID anahtari tablosunda eslesme bulunamadi.!_Reset!
    if "%_unattended%"=="0" pause
    exit /b 1
)
echo   !_Yellow![*] %edition_id% icin genel anahtar yukleniyor: !_hwid_key!...!_Reset!
cscript //nologo "%SysPath%\slmgr.vbs" /ipk !_hwid_key!
if "%_unattended%"=="0" pause
exit /b 0

:HWID_ApplyOEM
echo.
echo   !_Yellow![*] Anakart BIOS/UEFI MSDM tablosundan OA3x anahtari sorgulaniyor...!_Reset!
%psc% "$k = (Get-CimInstance -ClassName SoftwareLicensingService -ErrorAction SilentlyContinue).OA3xOriginalProductKey; if ($k) { Write-Host ('   [+] BIOS OEM Anahtari bulundu: ' + $k) -ForegroundColor Green; cscript.exe //nologo \"$env:SysPath\slmgr.vbs\" /ipk $k; cscript.exe //nologo \"$env:SysPath\slmgr.vbs\" /ato } else { Write-Host '   [HATA] Anakart uzerinde gomulu bir OEM anahtari bulunamadi.' -ForegroundColor Red }"
echo.
if "%_unattended%"=="0" pause
exit /b 0

:HWID_Run
echo.
echo   !_Cyan!=== HWID KALICI DIJITAL LISANS YAPILANDIRMASI BASLATILIYOR ===!_Reset!
echo.
echo   !_Yellow![1/4] Kritik lisans ve kimlik dogrulama servisleri baslatiliyor...!_Reset!
for %%S in (ClipSVC sppsvc wuauserv LicenseManager Winmgmt) do (
    call :dk_start_service %%S >nul 2>&1
)
sc query wuauserv | find /i "RUNNING" >nul 2>&1
if errorlevel 1 echo   !_Red![UYARI] Windows Update [wuauserv] servisi baslatilamadi. Dijital lisans dogrulamasi icin gereklidir.!_Reset!

echo   !_Yellow![2/4] Sistemdeki eski KMS sunucu kilitleri temizleniyor...!_Reset!
cscript //nologo "%SysPath%\slmgr.vbs" /ckms >nul 2>&1

call :Get_Edition_Key "%edition_id%" _hwid_key
if not defined _hwid_key (
    echo   !_Red![HATA] Mevcut Windows surumu [%edition_id%] HWID anahtar tablosunda bulunamadi.!_Reset!
    if "%_unattended%"=="0" pause
    exit /b 1
)
echo   !_Yellow![3/4] %edition_id% genel urun anahtari [!_hwid_key!] yukleniyor...!_Reset!
cscript //nologo "%SysPath%\slmgr.vbs" /ipk !_hwid_key!

echo   !_Yellow![4/4] Microsoft Dijital Lisans sunuculari ve Bilet Motoru kontrol ediliyor...!_Reset!
cscript //nologo "%SysPath%\slmgr.vbs" /ato >nul 2>&1
call :dk_check_perm_win
if "!_win_perm_ok!"=="1" (
    echo.
    echo   !_Green![BASARILI] Windows zaten anakartta kayitli Dijital Lisans ile Kalici olarak etkinlestirildi.!_Reset!
    echo.
    if "%_unattended%"=="0" pause
    exit /b 0
)

set "_local_hwid="
if exist "%_work%\HWID_Activation.cmd" set "_local_hwid=%_work%\HWID_Activation.cmd"
if not defined _local_hwid if exist "%_work%\Activators\HWID_Activation.cmd" set "_local_hwid=%_work%\Activators\HWID_Activation.cmd"
if not defined _local_hwid if exist "%_work%\Separate-Files-Version\Activators\HWID_Activation.cmd" set "_local_hwid=%_work%\Separate-Files-Version\Activators\HWID_Activation.cmd"
if not defined _local_hwid if exist "%_work%\MAS\Separate-Files-Version\Activators\HWID_Activation.cmd" set "_local_hwid=%_work%\MAS\Separate-Files-Version\Activators\HWID_Activation.cmd"

if defined _local_hwid (
    echo   !_Cyan![i] Yerel HWID_Activation.cmd modulu tespit edildi, izole alt islemde calistiriliyor...!_Reset!
    "%ComSpec%" /c ""!_local_hwid!" /HWID"
    call :dk_check_perm_win
    if "!_win_perm_ok!"=="1" echo   !_Green![BASARILI] Windows Kalici Dijital Lisans [Permanent] ile etkinlestirildi.!_Reset!
    if "%_unattended%"=="0" pause
    exit /b 0
)

set "_gt_dir=%ProgramData%\Microsoft\Windows\ClipSVC\GenuineTicket"
if not exist "!_gt_dir!" mkdir "!_gt_dir!" >nul 2>&1
call :dk_extract_b64 "GENUINETICKET_XML" "!_gt_dir!\GenuineTicket.xml" >nul 2>&1
if exist "!_gt_dir!\*.xml" (
    echo   !_Green![+] GenuineTicket XML bileti bulundu, ClipUp.exe -v -o uygulaniyor...!_Reset!
    clipup.exe -v -o >nul 2>&1
    cscript //nologo "%SysPath%\slmgr.vbs" /ato >nul 2>&1
)

call :dk_check_perm_win
if "!_win_perm_ok!"=="1" (
    echo.
    echo   !_Green![BASARILI] Windows Kalici Dijital Lisans [Permanent] ile etkinlestirildi.!_Reset!
    echo.
    if "%_unattended%"=="0" pause
    exit /b 0
)

call :dk_invoke_core_engine "/HWID"
call :dk_check_perm_win
if "!_win_perm_ok!"=="1" (
    echo.
    echo   !_Green![BASARILI] Windows Kalici Dijital Lisans [Permanent] ile etkinlestirildi.!_Reset!
) else (
    echo.
    echo   !_Yellow![UYARI] HWID islemi tamamlandi ancak kalici lisans dogrulanamadi. [3] TSforge veya [4] Online KMS deneyin.!_Reset!
)
echo.
if "%_unattended%"=="0" pause
exit /b 0

:: ============================================================================
:: FAZ 5B: OHOOK (MICROSOFT OFFICE YEREL SPPC YAPILANDIRMA MODULU)
:: ============================================================================
:Mod_Ohook
cls
if "%_unattended%"=="0" mode con cols=98 lines=34 >nul 2>&1
title Ohook Microsoft Office Yonetim Modulu

echo.
echo   !_Cyan!==============================================================================================!_Reset!
echo      !_White!OHOOK (MICROSOFT OFFICE YEREL SPPC KANCASI VE GVLK YONETIMI)!_Reset!
echo      !_Gray!Office C2R kurulumlarinda yerel sppc.dll sembolik bagi ve Volume GVLK anahtari yapilandirir.!_Reset!
echo   !_Cyan!==============================================================================================!_Reset!
echo.
echo       !_Green![1] Ohook Kalici Office Etkinlestirmesini ve GVLK Anahtarlarini Kur!_Reset!
echo       !_Yellow![2] Sadece Yuklu Office Urunleri Icin GVLK Anahtarlarini Yukle (DLL Dokunmadan)!_Reset!
echo       !_Red![3] Ohook Kancasini (sppc.dll / sppcs.dll) Sistemden Tamamen Kaldir!_Reset!
echo       !_Red![0] Ana Menuye Don!_Reset!
echo.
echo   !_Cyan!==============================================================================================!_Reset!
echo.

choice /C:1230 /N /M "   >> Seciminiz [1-3, Ana Menu icin 0]: "
set "_oh_erl=%errorlevel%"
if %_oh_erl%==4 exit /b 0
if %_oh_erl%==3 call :TB_CleanKMSOhook & goto :Mod_Ohook
if %_oh_erl%==2 call :Ohook_KeysOnly & goto :Mod_Ohook
if %_oh_erl%==1 call :Ohook_Install & goto :Mod_Ohook
goto :Mod_Ohook

:Ohook_KeysOnly
echo.
echo   !_Yellow![*] Yuklu Office Click-to-Run urunleri taranip uygun GVLK anahtarlari yukleniyor...!_Reset!
set "_c2r_reg=HKLM\SOFTWARE\Microsoft\Office\ClickToRun\Configuration"
set "_c2r_prods="
for /f "tokens=2*" %%a in ('reg query "%_c2r_reg%" /v ProductReleaseIds 2^>nul') do set "_c2r_prods=%%b"
if not defined _c2r_prods (
    echo   !_Red![HATA] Sistemde Office Click-to-Run ProductReleaseIds kaydi bulunamadi.!_Reset!
    if "%_unattended%"=="0" pause
    exit /b 1
)
for %%I in (ProPlus2024Volume Standard2024Volume ProjectPro2024Volume VisioPro2024Volume ProPlus2021Volume Standard2021Volume ProjectPro2021Volume VisioPro2021Volume ProPlus2019Volume Standard2019Volume ProjectPro2019Volume VisioPro2019Volume MondoVolume) do (
    echo "%_c2r_prods%" | find /i "%%I" >nul 2>&1 && (
        call :Get_Office_GVLK "%%I" _ok
        if defined _ok (
            echo   !_Green![+] %%I tespit edildi, GVLK yukleniyor: !_ok!!_Reset!
            cscript //nologo "%SysPath%\slmgr.vbs" /ipk !_ok! >nul 2>&1
        )
    )
)
echo   !_Green![+] Office GVLK anahtar kurulumu tamamlandi.!_Reset!
if "%_unattended%"=="0" pause
exit /b 0

:Ohook_Install
echo.
echo   !_Cyan!=== OHOOK OFFICE YAPILANDIRMASI BASLATILIYOR ===!_Reset!
echo.
set "_local_ohook="
if exist "%_work%\Ohook_Activation_AIO.cmd" set "_local_ohook=%_work%\Ohook_Activation_AIO.cmd"
if not defined _local_ohook if exist "%_work%\Activators\Ohook_Activation_AIO.cmd" set "_local_ohook=%_work%\Activators\Ohook_Activation_AIO.cmd"
if not defined _local_ohook if exist "%_work%\Separate-Files-Version\Activators\Ohook_Activation_AIO.cmd" set "_local_ohook=%_work%\Separate-Files-Version\Activators\Ohook_Activation_AIO.cmd"
if not defined _local_ohook if exist "%_work%\MAS\Separate-Files-Version\Activators\Ohook_Activation_AIO.cmd" set "_local_ohook=%_work%\MAS\Separate-Files-Version\Activators\Ohook_Activation_AIO.cmd"

if defined _local_ohook (
    echo   !_Cyan![i] Yerel Ohook_Activation_AIO.cmd modulu tespit edildi, izole alt islemde calistiriliyor...!_Reset!
    "%ComSpec%" /c ""!_local_ohook!" /Ohook"
    if "%_unattended%"=="0" pause
    exit /b 0
)

call :dk_invoke_core_engine "/Ohook"
echo.
if "%_unattended%"=="0" pause
exit /b 0

:: ============================================================================
:: FAZ 5C: TSFORGE (GUVENILIR DEPOLAMA / ESU / PHYSICAL STORE YONETIMI)
:: ============================================================================
:Mod_TSforge
cls
if "%_unattended%"=="0" mode con cols=98 lines=34 >nul 2>&1
title TSforge Guvenilir Depolama ve ESU Yonetim Modulu

echo.
echo   !_Cyan!==============================================================================================!_Reset!
echo      !_White!TSFORGE (TRUSTED STORAGE / PHYSICAL STORE ^& ESU YONETIM MODULU)!_Reset!
echo      !_Gray!SPP Physical Store (data.dat / tokens.dat) analizi, yedeklemesi ve ESU/Lisans dogrulamasi.!_Reset!
echo   !_Cyan!==============================================================================================!_Reset!
echo.
echo       !_Green![1] TSforge Windows / ESU Kalici Etkinlestirmesini Calistir!_Reset!
echo       !_Green![2] TSforge Office Kalici Etkinlestirmesini Calistir!_Reset!
echo       !_Cyan![3] SPP Trusted Store (data.dat ^& tokens.dat) Yedegini Al (Masaustune Yedekle)!_Reset!
echo       !_Yellow![4] SPP Trusted Store Yedegini Geri Yukle (Restore Backup)!_Reset!
echo       !_Red![0] Ana Menuye Don!_Reset!
echo.
echo   !_Cyan!==============================================================================================!_Reset!
echo.

choice /C:12340 /N /M "   >> Seciminiz [1-4, Ana Menu icin 0]: "
set "_ts_erl=%errorlevel%"
if %_ts_erl%==5 exit /b 0
if %_ts_erl%==4 call :TSforge_Restore & goto :Mod_TSforge
if %_ts_erl%==3 call :TSforge_Backup & goto :Mod_TSforge
if %_ts_erl%==2 call :TSforge_Run_Off & goto :Mod_TSforge
if %_ts_erl%==1 call :TSforge_Run_Win & goto :Mod_TSforge
goto :Mod_TSforge

:TSforge_Run_Win
echo.
set "_local_tsf="
if exist "%_work%\TSforge_Activation.cmd" set "_local_tsf=%_work%\TSforge_Activation.cmd"
if not defined _local_tsf if exist "%_work%\Activators\TSforge_Activation.cmd" set "_local_tsf=%_work%\Activators\TSforge_Activation.cmd"
if not defined _local_tsf if exist "%_work%\Separate-Files-Version\Activators\TSforge_Activation.cmd" set "_local_tsf=%_work%\Separate-Files-Version\Activators\TSforge_Activation.cmd"
if not defined _local_tsf if exist "%_work%\MAS\Separate-Files-Version\Activators\TSforge_Activation.cmd" set "_local_tsf=%_work%\MAS\Separate-Files-Version\Activators\TSforge_Activation.cmd"

if defined _local_tsf (
    echo   !_Cyan![i] Yerel TSforge_Activation.cmd tespit edildi, izole alt islemde calistiriliyor...!_Reset!
    "%ComSpec%" /c ""!_local_tsf!" /Z-Windows"
    if "%_unattended%"=="0" pause
    exit /b 0
)
call :dk_invoke_core_engine "/Z-Windows"
if "%_unattended%"=="0" pause
exit /b 0

:TSforge_Run_Off
echo.
set "_local_tsf="
if exist "%_work%\TSforge_Activation.cmd" set "_local_tsf=%_work%\TSforge_Activation.cmd"
if not defined _local_tsf if exist "%_work%\Activators\TSforge_Activation.cmd" set "_local_tsf=%_work%\Activators\TSforge_Activation.cmd"
if not defined _local_tsf if exist "%_work%\Separate-Files-Version\Activators\TSforge_Activation.cmd" set "_local_tsf=%_work%\Separate-Files-Version\Activators\TSforge_Activation.cmd"
if not defined _local_tsf if exist "%_work%\MAS\Separate-Files-Version\Activators\TSforge_Activation.cmd" set "_local_tsf=%_work%\MAS\Separate-Files-Version\Activators\TSforge_Activation.cmd"

if defined _local_tsf (
    "%ComSpec%" /c ""!_local_tsf!" /Z-Office"
    if "%_unattended%"=="0" pause
    exit /b 0
)
call :dk_invoke_core_engine "/Z-Office"
if "%_unattended%"=="0" pause
exit /b 0

:TSforge_Backup
echo.
set "_spp_store=%SystemRoot%\System32\spp\store\2.0"
if not exist "!_spp_store!" set "_spp_store=%SystemRoot%\System32\spp\store"
set "_bk_dir=%UserProfile%\Desktop\SPP_TrustedStore_Backup"
if not exist "!_bk_dir!" mkdir "!_bk_dir!" >nul 2>&1
echo   !_Yellow![*] sppsvc durduruluyor ve data.dat / tokens.dat Masaustune yedekleniyor...!_Reset!
net stop sppsvc /y >nul 2>&1
xcopy "!_spp_store!\*" "!_bk_dir!\" /E /H /C /I /Y >nul 2>&1
net start sppsvc /y >nul 2>&1
echo   !_Green![+] Trusted Store yedegi basariyla alindi: !_bk_dir!!_Reset!
echo.
pause
exit /b 0

:TSforge_Restore
echo.
set "_spp_store=%SystemRoot%\System32\spp\store\2.0"
if not exist "!_spp_store!" set "_spp_store=%SystemRoot%\System32\spp\store"
set "_bk_dir=%UserProfile%\Desktop\SPP_TrustedStore_Backup"
if not exist "!_bk_dir!\tokens.dat" (
    echo   !_Red![HATA] Masaustunde SPP_TrustedStore_Backup klasorunde gecerli bir yedek bulunamadi.!_Reset!
    pause
    exit /b 1
)
echo   !_Yellow![*] Yedek geri yukleniyor...!_Reset!
net stop sppsvc /y >nul 2>&1
xcopy "!_bk_dir!\*" "!_spp_store!\" /E /H /C /I /Y >nul 2>&1
net start sppsvc /y >nul 2>&1
cscript //nologo "%SysPath%\slmgr.vbs" /rilc >nul 2>&1
echo   !_Green![+] Trusted Store yedegi basariyla geri yuklendi.!_Reset!
echo.
pause
exit /b 0

:: ============================================================================
:: FAZ 5D: ONLINE KMS (180 GUN + OTOMATIK FAILOVER + GOREV ZAMANLAYICI)
:: ============================================================================
:Mod_OnlineKMS
cls
if "%_unattended%"=="0" mode con cols=100 lines=36 >nul 2>&1
title Online KMS Lisans ve Gorev Zamanlayici Yonetimi

echo.
echo   !_Cyan!================================================================================================!_Reset!
echo      !_White!ONLINE KMS YONETIMI (WINDOWS ^& OFFICE 180 GUN + OTOMATIK FAILOVER)!_Reset!
echo      !_Gray!Sistem: %win_edition% [%edition_id%] ^| Port: 1688 ^| 8 Sunuculu Otomatik Yedekli KMS Havuzu!_Reset!
echo   !_Cyan!================================================================================================!_Reset!
echo.
echo       !_Green![1] Windows ve Office Icin Online KMS Etkinlestir (Hepsi Bir Arada)!_Reset!
echo       !_Green![2] Sadece Windows Icin Online KMS Etkinlestir!_Reset!
echo       !_Green![3] Sadece Microsoft Office Icin Online KMS Etkinlestir!_Reset!
echo.
echo       !_Cyan![4] Otomatik Yenileme Gorevi Olustur (Gorev Zamanlayici - Her Hafta Otomatik Yeniler)!_Reset!
echo       !_Yellow![5] Ozel KMS Sunucu Adresi Belirle ve Baglanti Testi Yap (Port 1688 TCP Test)!_Reset!
echo       !_Red![6] KMS Yapilandirmasini ve Yenileme Gorevlerini Tamamen Kaldir (Uninstall KMS)!_Reset!
echo.
echo       !_Red![0] Ana Menuye Don!_Reset!
echo.
echo   !_Cyan!================================================================================================!_Reset!
echo.

choice /C:1234560 /N /M "   >> Seciminiz [1-6, Ana Menu icin 0]: "
set "_kms_erl=%errorlevel%"
if %_kms_erl%==7 exit /b 0
if %_kms_erl%==6 call :TB_CleanKMSOhook & goto :Mod_OnlineKMS
if %_kms_erl%==5 call :KMS_CustomHost & goto :Mod_OnlineKMS
if %_kms_erl%==4 call :KMS_InstallTask & goto :Mod_OnlineKMS
if %_kms_erl%==3 call :KMS_Act_Off & goto :Mod_OnlineKMS
if %_kms_erl%==2 call :KMS_Act_Win & goto :Mod_OnlineKMS
if %_kms_erl%==1 call :KMS_Act_All & goto :Mod_OnlineKMS
goto :Mod_OnlineKMS

:KMS_Act_Win
echo.
echo   !_Cyan!=== WINDOWS ONLINE KMS ETKINLESTIRME BASLATILIYOR ===!_Reset!
call :dk_start_service sppsvc >nul 2>&1
call :dk_start_service wuauserv >nul 2>&1

for /f "tokens=2*" %%a in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v EditionID 2^>nul') do set "edition_id=%%b"
set "edition_id=!edition_id: =!"

if /i "%edition_id%"=="IoTEnterprise" (
    echo   !_Yellow![i] IoTEnterprise surumu KMS desteklemedigi icin KMS uyumlu Enterprise anahtari yukleniyor...!_Reset!
)

call :Get_GVLK_Key "%edition_id%" _win_gvlk
if not defined _win_gvlk (
    echo   !_Red![HATA] Mevcut Windows surumu [%edition_id%] KMS GVLK tablosunda bulunamadi.!_Reset!
    echo   !_Yellow![i] Lutfen Ana Menuden [1] HWID veya [3] TSforge modullerini kullanin.!_Reset!
    if "%_unattended%"=="0" pause
    exit /b 1
)

echo   !_Yellow![1/3] %edition_id% KMS Istemci Anahtari [GVLK] yukleniyor: !_win_gvlk!...!_Reset!
cscript //nologo "%SysPath%\slmgr.vbs" /ipk !_win_gvlk!

set "_kms_list=kms.loli.best kms.03k.org kms8.MSGuides.com kms9.MSGuides.com kms.sixyin.com kms.loli.beer kms.cangshui.net kms.cin.org.cn"
if defined _custom_kms_host set "_kms_list=%_custom_kms_host%"

set "_kms_win_success=0"
echo   !_Yellow![2/3] KMS sunucu havuzu uzerinden etkinlestirme deneniyor...!_Reset!
for %%H in (!_kms_list!) do (
    if "!_kms_win_success!"=="0" (
        echo.
        echo   !_Cyan![*] Denenen KMS Sunucusu: %%H:1688!_Reset!
        cscript //nologo "%SysPath%\slmgr.vbs" /skms %%H:1688
        cscript //nologo "%SysPath%\slmgr.vbs" /ato
        call :dk_check_act_win
        if "!_win_act_ok!"=="1" (
            set "_kms_win_success=1"
            set "_alive_kms=%%H"
            echo.
            echo   !_Green![BASARILI] Windows, %%H sunucusu uzerinden 180 Gunluk KMS ile etkinlestirildi.!_Reset!
        ) else (
            echo   !_Yellow![-] %%H yanit vermedi, siradaki yedek sunucuya geciliyor...!_Reset!
        )
    )
)

if "!_kms_win_success!"=="0" (
    echo.
    echo   !_Red![HATA] KMS sunucularina Port 1688 uzerinden ulasilamadi [ISP veya Guvenlik Duvari engeli olabilir].!_Reset!
    echo   !_Yellow![i] Port 1688 gerektirmeyen [1] HWID veya [3] TSforge modullerini kullanmaniz onerilir.!_Reset!
)
echo.
if "%_unattended%"=="0" pause
exit /b 0

:KMS_Act_Off
echo.
echo   !_Cyan!=== MICROSOFT OFFICE ONLINE KMS ETKINLESTIRME BASLATILIYOR ===!_Reset!
call :dk_start_service sppsvc >nul 2>&1
call :Ohook_KeysOnly
set "_kms_off_host=kms.loli.best"
if defined _alive_kms set "_kms_off_host=!_alive_kms!"
if defined _custom_kms_host set "_kms_off_host=%_custom_kms_host%"

echo   !_Yellow![*] KMS sunucu adresi [!_kms_off_host!] kayit defterine ve SPP havuzuna isleniyor...!_Reset!
cscript //nologo "%SysPath%\slmgr.vbs" /skms !_kms_off_host!:1688 >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform" /v KeyManagementServiceName /t REG_SZ /d "!_kms_off_host!" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform" /v KeyManagementServicePort /t REG_SZ /d "1688" /f >nul 2>&1

echo   !_Yellow![*] Tum yuklu Office Volume urunleri etkinlestiriliyor...!_Reset!
%psc% "$off = Get-CimInstance SoftwareLicensingProduct | Where-Object {$_.PartialProductKey -and $_.ApplicationID -eq '0ff1ce15-a989-479d-af46-f275c6370663'}; if (-not $off) { Write-Host '   [-] Yuklu Office Volume GVLK urunu bulunamadi.' -ForegroundColor Red } else { foreach ($o in $off) { Write-Host ('   [*] Etkinlestiriliyor: ' + $o.Name) -ForegroundColor Cyan; try { Invoke-CimMethod -InputObject $o -MethodName Activate | Out-Null; $u = Get-CimInstance SoftwareLicensingProduct | Where-Object { $_.ID -eq $o.ID }; if ($u.LicenseStatus -eq 1) { Write-Host '      [+] Basariyla Etkinlestirildi (180 Gun).' -ForegroundColor Green } else { Write-Host ('      [i] Durum Kodu: ' + $u.LicenseStatus) -ForegroundColor Yellow } } catch { Write-Host '      [-] KMS sunucu baglanti hatasi.' -ForegroundColor Red } } }"
echo.
if "%_unattended%"=="0" pause
exit /b 0

:KMS_Act_All
call :KMS_Act_Win
call :KMS_Act_Off
exit /b 0

:KMS_InstallTask
echo.
echo   !_Cyan!=== KMS OTOMATIK YENILEME GOREVI (SCHEDULED TASK) KURULUYOR ===!_Reset!
set "_kms_dir=%ProgramData%\AIO_KMS_Renewal"
if not exist "!_kms_dir!" mkdir "!_kms_dir!" >nul 2>&1
copy /y "%_cmdf%" "!_kms_dir!\AIO_KMS_Renew.cmd" >nul 2>&1
schtasks /delete /tn "Online_KMS_Activation_Script-Renewal" /f >nul 2>&1
schtasks /create /tn "Online_KMS_Activation_Script-Renewal" /tr "'!_kms_dir!\AIO_KMS_Renew.cmd' /KMS /S" /sc WEEKLY /d SUN /st 12:00 /ru "SYSTEM" /rl HIGHEST /f >nul 2>&1
if !errorlevel! equ 0 (
    echo   !_Green![+] Gorev Zamanlayici kaydi basariyla olusturuldu:!_Reset!
    echo   !_Gray!    Gorev Adi : Online_KMS_Activation_Script-Renewal!_Reset!
    echo   !_Gray!    Periyot   : Her Hafta Pazar 12:00 [SYSTEM Yetkisiyle Katilimsiz]!_Reset!
) else (
    echo   !_Red![HATA] Gorev Zamanlayici olusturulurken hata meydana geldi.!_Reset!
)
echo.
if "%_unattended%"=="0" pause
exit /b 0

:KMS_CustomHost
echo.
set "_custom_kms_host="
set /p "_custom_kms_host=   >> Ozel KMS Sunucu Adresi veya IP girin (Varsayilan havuz icin bos birakin): "
if not defined _custom_kms_host (
    echo   !_Yellow![i] Ozel sunucu sifirlandi, otomatik KMS havuzu kullanilacak.!_Reset!
    pause
    exit /b 0
)
echo   !_Yellow![*] !_custom_kms_host!:1688 TCP baglantisi test ediliyor...!_Reset!
%psc% "$t = New-Object Net.Sockets.TcpClient; try { $c = $t.BeginConnect($env:_custom_kms_host, 1688, $null, $null); $w = $c.AsyncWaitHandle.WaitOne(2500, $false); if ($w -and $t.Connected) { $t.Close(); Write-Host '   [+] Sunucu ERISILEBILIR (Port 1688 Acik).' -ForegroundColor Green } else { Write-Host '   [-] Sunucuya ulasilamadi (Port 1688 Kapali veya Zaman Asimi).' -ForegroundColor Red } } catch { Write-Host '   [-] Sunucu adresi cozulemedi.' -ForegroundColor Red }"
echo.
pause
exit /b 0

:: ============================================================================
:: FAZ 6: EKSTRA ARACLAR ($OEM$ KLASORU CIKARTICI, BASE64 MOTORU VE CLI REHBERI)
:: ============================================================================
:Mod_Extras
cls
if "%_unattended%"=="0" mode con cols=100 lines=36 >nul 2>&1
title Ekstra Araclar: $OEM$ Katilimsiz Kurulum, Base64 Motoru ve Yardim

echo.
echo   !_Cyan!================================================================================================!_Reset!
echo      !_White!EKSTRA ARACLAR ($OEM$ KATILIMSIZ KURULUM KLASORU ^& BASE64 GOMULU VERI MOTORU)!_Reset!
echo      !_Gray!Windows ISO entegrasyonu icin $OEM$ uretir ve ikili (binary) dosyalari betige gomer.!_Reset!
echo   !_Cyan!================================================================================================!_Reset!
echo.
echo       !_Green![1] Masaustune $OEM$ Klasoru Cikart (Windows ISO Format Sonrasi Otomatik Kurulum)!_Reset!
echo           !_Gray!SetupComplete.cmd ve Home/Core surumleri icin ei.cfg dosyasini otomatik olusturur.!_Reset!
echo.
echo       !_Cyan![2] Harici Bir Dosyayi (DLL / EXE / XML) Bu Betigin Icine Base64 Olarak Gom!_Reset!
echo           !_Gray!Secilen dosyayi Base64'e kodlayip tek dosya (AIO) tasinabilirligi icin betigin altina ekler.!_Reset!
echo.
echo       !_Yellow![3] Betik Icindeki Gomulu Base64 Verilerini Kontrol Et ve Listele!_Reset!
echo           !_Gray!Betigin sonuna gomulmus OHOOK_SPPC64, OHOOK_SPPC32 veya GENUINETICKET_XML bloklarini listeler.!_Reset!
echo.
echo       !_Magenta![4] Komut Satiri (CLI) Katilimsiz Parametreler Rehberini Goruntule (/?)!_Reset!
echo           !_Gray!Betigi arayuz acmadan (sessiz/katilimsiz) scriptlerden calistirma komutlarini gosterir.!_Reset!
echo.
echo       !_Red![0] Ana Menuye Don!_Reset!
echo.
echo   !_Cyan!================================================================================================!_Reset!
echo.

choice /C:12340 /N /M "   >> Seciminiz [1-4, Ana Menu icin 0]: "
set "_ex_erl=%errorlevel%"
if %_ex_erl%==5 exit /b 0
if %_ex_erl%==4 call :CLI_Help & goto :Mod_Extras
if %_ex_erl%==3 call :B64_VerifyMenu & goto :Mod_Extras
if %_ex_erl%==2 call :B64_EmbedMenu & goto :Mod_Extras
if %_ex_erl%==1 call :OEM_ExtractMenu & goto :Mod_Extras
goto :Mod_Extras

:OEM_ExtractMenu
cls
echo.
echo   !_Cyan!================================================================================================!_Reset!
echo      !_White!MASAUSTUNE $OEM$ KLASORU CIKARTMA ARACI (ISO ENTEGRASYONU)!_Reset!
echo      !_Gray!Olusturulan $OEM$ klasorunu Windows ISO'nuzun "sources" klasoru icine kopyalamaniz yeterlidir.!_Reset!
echo   !_Cyan!================================================================================================!_Reset!
echo.
echo      !_White!Format Sonrasi Otomatik Calisacak Yapilandirma Turunu Secin:!_Reset!
echo.
echo       !_Green![1] HWID (Kalici Dijital Lisans)!_Reset!
echo       !_Green![2] HWID (Windows) + Ohook (Office)!_Reset!
echo       !_Green![3] Online KMS (Windows + Office 180 Gun + Haftalik Otomatik Yenileme Gorevi)!_Reset!
echo       !_Green![4] TSforge (Windows / ESU + Office)!_Reset!
echo       !_Red![0] Iptal / Geri Don!_Reset!
echo.
choice /C:12340 /N /M "   >> Seciminiz [1-4, Geri icin 0]: "
set "_oem_opt=%errorlevel%"
if %_oem_opt%==5 exit /b 0

set "_oem_root=%UserProfile%\Desktop\$OEM$"
set "_oem_scripts=!_oem_root!\$$\Setup\Scripts"

if exist "!_oem_root!" (
    echo.
    echo   !_Yellow![i] Masaustunde zaten bir $OEM$ klasoru mevcut. Silinip yeniden olusturuluyor...!_Reset!
    rmdir /s /q "!_oem_root!" >nul 2>&1
)

mkdir "!_oem_scripts!" >nul 2>&1
copy /y "%_cmdf%" "!_oem_scripts!\AIO_Tool.cmd" >nul 2>&1

set "_sc_cmd=call "%%~dp0AIO_Tool.cmd" /HWID /S"
if %_oem_opt%==2 set "_sc_cmd=call "%%~dp0AIO_Tool.cmd" /HWID /Ohook /S"
if %_oem_opt%==3 set "_sc_cmd=call "%%~dp0AIO_Tool.cmd" /KMS /KMS-Task /S"
if %_oem_opt%==4 set "_sc_cmd=call "%%~dp0AIO_Tool.cmd" /TSforge /S"

echo @echo off> "!_oem_scripts!\SetupComplete.cmd"
echo :: Windows Kurulum Sonrasi Otomatik Yapilandirma Betigi>> "!_oem_scripts!\SetupComplete.cmd"
echo !_sc_cmd!>> "!_oem_scripts!\SetupComplete.cmd"
echo cd /d "%%SystemRoot%%\Setup">> "!_oem_scripts!\SetupComplete.cmd"
echo if exist "%%SystemRoot%%\Setup\Scripts" @rd /s /q "%%SystemRoot%%\Setup\Scripts">> "!_oem_scripts!\SetupComplete.cmd"
echo exit /b 0>> "!_oem_scripts!\SetupComplete.cmd"

echo [Channel]> "!_oem_root!\ei.cfg"
echo _Default>> "!_oem_root!\ei.cfg"
echo [VL]>> "!_oem_root!\ei.cfg"
echo 0>> "!_oem_root!\ei.cfg"

echo.
echo   !_Green!================================================================================================!_Reset!
echo      !_White![+] $OEM$ Klasoru Masaustunde Basariyla Olusturuldu.!_Reset!
echo   !_Green!================================================================================================!_Reset!
echo.
echo    !_Cyan!Klasor Yolu :!_Reset! !_oem_root!
echo    !_Cyan!Kurulum Kodu:!_Reset! !_sc_cmd!
echo.
echo    !_Yellow!Nasil Kullanilir?!_Reset!
echo    1. Masaustundeki !_White!$OEM$!_Reset! klasorunu ve icindeki !_White!ei.cfg!_Reset! dosyasini USB/ISO icindeki
echo       !_Green!sources!_Reset! klasorunun icine atin.
echo    2. Windows kurulumu bittiginde ilk masaustu acilisinda betik sessizce calisip kendini temizler.
echo.
pause
exit /b 0

:B64_EmbedMenu
cls
echo.
echo   !_Cyan!================================================================================================!_Reset!
echo      !_White!BASE64 GOMULU VERI MOTORU (DOSYAYI BETIGIN ICINE GOMME ARACI)!_Reset!
echo      !_Gray!Harici DLL, EXE veya XML dosyalarini bu .cmd dosyasinin en altina Base64 olarak gomer.!_Reset!
echo   !_Cyan!================================================================================================!_Reset!
echo.
echo      !_White!Hangi Etiket Icin Dosya Gommek Istiyorsunuz?!_Reset!
echo       !_Green![1] OHOOK_SPPC64!_Reset!       (64-bit Office Ohook sppc64.dll dosyasi)
echo       !_Green![2] OHOOK_SPPC32!_Reset!       (32-bit Office Ohook sppc32.dll dosyasi)
echo       !_Green![3] GENUINETICKET_XML!_Reset!  (HWID ozel GenuineTicket.xml dosyasi)
echo       !_Cyan![4] OZEL_ETIKET!_Reset!        (Kendi belirleyeceginiz herhangi bir dosya/etiket)
echo       !_Red![0] Geri Don!_Reset!
echo.
choice /C:12340 /N /M "   >> Seciminiz [1-4, Geri icin 0]: "
set "_b_sel=%errorlevel%"
if %_b_sel%==5 exit /b 0

set "_tag_name="
if %_b_sel%==1 set "_tag_name=OHOOK_SPPC64"
if %_b_sel%==2 set "_tag_name=OHOOK_SPPC32"
if %_b_sel%==3 set "_tag_name=GENUINETICKET_XML"
if %_b_sel%==4 (
    echo.
    set /p "_tag_name=   >> Ozel etiket adini girin (Orn: ARAC_EXE): "
)
if not defined _tag_name exit /b 0

echo.
set "_src_file="
set /p "_src_file=   >> Gomulecek dosyanin tam yolunu girin (veya surukleyip birakin): "
if not defined _src_file exit /b 0
set "_src_file=!_src_file:"=!"

if not exist "!_src_file!" (
    echo.
    echo   !_Red![HATA] Belirtilen dosya bulunamadi: !_src_file!!_Reset!
    pause
    exit /b 1
)

echo.
echo   !_Yellow![*] Dosya Base64 formatina kodlanip %~nx0 dosyasinin sonuna ekleniyor...!_Reset!
%psc% "$bytes = [IO.File]::ReadAllBytes($env:_src_file); $b64 = [Convert]::ToBase64String($bytes, 'InsertLineBreaks'); $lines = $b64 -split [Environment]::NewLine; $out = New-Object System.Collections.Generic.List[string]; $out.Add(''); $out.Add('::B64_START_' + $env:_tag_name); foreach ($l in $lines) { $out.Add('::' + $l) }; $out.Add('::B64_END_' + $env:_tag_name); [IO.File]::AppendAllLines($env:_cmdf, $out)"

if !errorlevel! equ 0 (
    echo   !_Green![+] Dosya [!_tag_name!] basariyla betigin sonuna Base64 olarak gomuldu.!_Reset!
    echo   !_Gray!Artik harici dosyaya ihtiyac duymadan betigi tek basina tasiyabilirsiniz.!_Reset!
) else (
    echo   !_Red![HATA] Kodlama sirasinda bir hata olustu.!_Reset!
)
echo.
pause
exit /b 0

:B64_VerifyMenu
cls
echo.
echo   !_Cyan!=== BETIK ICINDEKI GOMULU BASE64 VERILERI ===!_Reset!
echo.
set "_found_b64=0"
for /f "tokens=1 delims=" %%L in ('findstr /i "^::B64_START_" "%_cmdf%" 2^>nul') do (
    set /a _found_b64+=1
    set "_line_tag=%%L"
    set "_line_tag=!_line_tag:::B64_START_=!"
    echo   !_Green![!_found_b64!] Gomulu Veri Etiketi Bulundu:!_Reset! !_White!!_line_tag!!_Reset!
)
if "!_found_b64!"=="0" (
    echo   !_Yellow![i] Su anda betigin icinde gomulu herhangi bir Base64 blogu bulunmuyor.!_Reset!
    echo   !_Gray!Gommek icin bir onceki menude [2] numarali secenegi kullanabilirsiniz.!_Reset!
)
echo.
pause
exit /b 0

:CLI_Help
cls
echo.
echo   !_Cyan!================================================================================================!_Reset!
echo      !_White!KOMUT SATIRI (CLI) KATILIMSIZ KULLANIM PARAMETRELERI!_Reset!
echo   !_Cyan!================================================================================================!_Reset!
echo.
echo    Bu betigi PowerShell veya CMD uzerinden hicbir menuye tiklamadan katilimsiz calistirabilirsiniz:
echo.
echo    !_Green!%~nx0 /HWID /S!_Reset!          - Windows 10/11 HWID yapilandirmasini sessizce calistirir ve cikar.
echo    !_Green!%~nx0 /Ohook /S!_Reset!         - Office Ohook ve Volume GVLK kurulumunu sessizce yapar.
echo    !_Green!%~nx0 /TSforge /S!_Reset!       - TSforge Guvenilir Depolama kontrolunu calistirir.
echo    !_Green!%~nx0 /KMS /S!_Reset!           - Hem Windows hem Office icin Online KMS (180 Gun) etkinlestirir.
echo    !_Green!%~nx0 /KMS-Windows /S!_Reset!   - Sadece Windows icin Online KMS etkinlestirir.
echo    !_Green!%~nx0 /KMS-Office /S!_Reset!    - Sadece Office icin Online KMS etkinlestirir.
echo    !_Green!%~nx0 /KMS-Task /S!_Reset!      - Haftalik otomatik KMS yenileme gorevini (SYSTEM) kurar.
echo    !_Green!%~nx0 /Status!_Reset!           - Dogrudan detayli lisans durumu raporunu acar.
echo.
echo   !_Cyan!================================================================================================!_Reset!
echo.
if "%_unattended%"=="0" pause
exit /b 0

:End_Unattended
if "%_unattended%"=="0" pause
:Exit_Script
popd
echo.
echo   !_Cyan!Cikis yapiliyor...!_Reset!
timeout /t 1 >nul 2>&1
exit /b 0

:: ============================================================================
:: GOMULU BASE64 VERI DEPOSU (BU SATIRIN ALTINA OTOMATIK EKLENIR)
:: ============================================================================
'@

$sync.LogoBase64 = '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'

$sync.Xaml = @'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Petra OmniTool - Post-Install &amp; Script Engine v4.0 (Sistem Kurulum ve Optimizasyon Merkezi)"
        Width="1360" Height="880" MinWidth="1120" MinHeight="740"
        WindowStartupLocation="CenterScreen" Background="{DynamicResource WindowBg}" Foreground="#F4F4F5"
        FontFamily="Segoe UI" UseLayoutRounding="True" SnapsToDevicePixels="True"
        TextOptions.TextFormattingMode="Ideal" TextOptions.TextRenderingMode="ClearType">
    <Window.Resources>
        <!-- Varsayilan tema: Solar Eclipse (turuncu / sicak siyah) -->
        <SolidColorBrush x:Key="WindowBg" Color="#0B0A09"/>
        <SolidColorBrush x:Key="PanelBg" Color="#141110"/>
        <SolidColorBrush x:Key="CardBg" Color="#1B1715"/>
        <SolidColorBrush x:Key="BorderBrushColor" Color="#2E2723"/>
        <SolidColorBrush x:Key="HoverBg" Color="#241E1A"/>
        <SolidColorBrush x:Key="AccentColor" Color="#FBBF6B"/>
        <SolidColorBrush x:Key="ActiveBtnColor" Color="#F97316"/>
        <SolidColorBrush x:Key="PrimaryHover" Color="#C2410C"/>
        <SolidColorBrush x:Key="TextMuted" Color="#A8A29E"/>
        <SolidColorBrush x:Key="TextDim" Color="#7C7269"/>
        <SolidColorBrush x:Key="LogBg" Color="#090807"/>
        <SolidColorBrush x:Key="LogFg" Color="#E7E0D8"/>
        <SolidColorBrush x:Key="BtnInstallBg" Color="#F97316"/>
        <SolidColorBrush x:Key="BtnUninstallBg" Color="#4A1D1D"/>
        <SolidColorBrush x:Key="BtnUpgradeBg" Color="#241D18"/>
        <SolidColorBrush x:Key="SuccessFg" Color="#86EFAC"/>
        <SolidColorBrush x:Key="SuccessBg" Color="#17251B"/>
        <SolidColorBrush x:Key="SuccessBorder" Color="#2F5C41"/>
        <SolidColorBrush x:Key="WarnFg" Color="#FBBF24"/>
        <SolidColorBrush x:Key="ErrorFg" Color="#FCA5A5"/>
        <SolidColorBrush x:Key="SelectedBg" Color="#2C2115"/>
        <SolidColorBrush x:Key="SelectedBorder" Color="#F97316"/>

        <!-- ToolTip Stili -->
        <Style TargetType="ToolTip">
            <Setter Property="Background" Value="{DynamicResource PanelBg}"/>
            <Setter Property="Foreground" Value="#F4F4F5"/>
            <Setter Property="BorderBrush" Value="{DynamicResource BorderBrushColor}"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="Padding" Value="8,5"/>
            <Setter Property="FontSize" Value="11.5"/>
        </Style>

        <!-- Fluent Dark CheckBox Stili -->
        <Style TargetType="CheckBox">
            <Setter Property="Foreground" Value="#F4F4F5"/>
            <Setter Property="Background" Value="#18181B"/>
            <Setter Property="BorderBrush" Value="#52525B"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="VerticalContentAlignment" Value="Center"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="CheckBox">
                        <Grid Background="Transparent">
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="Auto"/>
                                <ColumnDefinition Width="*"/>
                            </Grid.ColumnDefinitions>
                            <Border x:Name="CheckBoxBorder" Grid.Column="0" Width="16" Height="16"
                                    Background="{TemplateBinding Background}"
                                    BorderBrush="{TemplateBinding BorderBrush}"
                                    BorderThickness="{TemplateBinding BorderThickness}"
                                    CornerRadius="4" VerticalAlignment="Center">
                                <Path x:Name="CheckMark" Data="M 3,8 L 6.5,11.5 L 13,4.5"
                                      Stroke="#FFFFFF" StrokeThickness="2"
                                      StrokeStartLineCap="Round" StrokeEndLineCap="Round"
                                      StrokeLineJoin="Round" Visibility="Collapsed"/>
                            </Border>
                            <ContentPresenter Grid.Column="1" Margin="8,0,0,0"
                                              VerticalAlignment="{TemplateBinding VerticalContentAlignment}"
                                              HorizontalAlignment="{TemplateBinding HorizontalContentAlignment}"
                                              RecognizesAccessKey="True"/>
                        </Grid>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="CheckBoxBorder" Property="BorderBrush" Value="{DynamicResource AccentColor}"/>
                            </Trigger>
                            <Trigger Property="IsChecked" Value="True">
                                <Setter TargetName="CheckBoxBorder" Property="Background" Value="{DynamicResource ActiveBtnColor}"/>
                                <Setter TargetName="CheckBoxBorder" Property="BorderBrush" Value="{DynamicResource AccentColor}"/>
                                <Setter TargetName="CheckMark" Property="Visibility" Value="Visible"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <!-- Fluent Dark ProgressBar Stili -->
        <Style TargetType="ProgressBar">
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="ProgressBar">
                        <Grid MinHeight="8">
                            <Border x:Name="PART_Track" Background="{TemplateBinding Background}" CornerRadius="4"/>
                            <Border x:Name="PART_Indicator" Background="{TemplateBinding Foreground}" CornerRadius="4" HorizontalAlignment="Left"/>
                        </Grid>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <!-- Fluent Dark ScrollBar Stili (Dikey + Yatay Destekli) -->
        <Style TargetType="ScrollBar">
            <Setter Property="Background" Value="Transparent"/>
            <Setter Property="Width" Value="8"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="ScrollBar">
                        <Grid Background="Transparent">
                            <Track x:Name="PART_Track" IsDirectionReversed="True">
                                <Track.Thumb>
                                    <Thumb>
                                        <Thumb.Template>
                                            <ControlTemplate TargetType="Thumb">
                                                <Border Background="#3F3F46" CornerRadius="4" Margin="1"/>
                                            </ControlTemplate>
                                        </Thumb.Template>
                                    </Thumb>
                                </Track.Thumb>
                            </Track>
                        </Grid>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
            <Style.Triggers>
                <Trigger Property="Orientation" Value="Horizontal">
                    <Setter Property="Width" Value="Auto"/>
                    <Setter Property="Height" Value="8"/>
                    <Setter Property="Template">
                        <Setter.Value>
                            <ControlTemplate TargetType="ScrollBar">
                                <Grid Background="Transparent">
                                    <Track x:Name="PART_Track" IsDirectionReversed="False">
                                        <Track.Thumb>
                                            <Thumb>
                                                <Thumb.Template>
                                                    <ControlTemplate TargetType="Thumb">
                                                        <Border Background="#3F3F46" CornerRadius="4" Margin="1"/>
                                                    </ControlTemplate>
                                                </Thumb.Template>
                                            </Thumb>
                                        </Track.Thumb>
                                    </Track>
                                </Grid>
                            </ControlTemplate>
                        </Setter.Value>
                    </Setter>
                </Trigger>
            </Style.Triggers>
        </Style>

        <!-- Sol menu: bolum basligi (akordeon) -->
        <Style x:Key="NavSectionStyle" TargetType="Button">
            <Setter Property="Background" Value="Transparent"/>
            <Setter Property="Foreground" Value="{DynamicResource TextDim}"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="Padding" Value="6,6"/>
            <Setter Property="Margin" Value="0,6,0,2"/>
            <Setter Property="HorizontalContentAlignment" Value="Left"/>
            <Setter Property="FontSize" Value="10.5"/>
            <Setter Property="FontWeight" Value="Bold"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border Background="{TemplateBinding Background}" CornerRadius="5" Padding="{TemplateBinding Padding}">
                            <ContentPresenter HorizontalAlignment="Left" VerticalAlignment="Center"/>
                        </Border>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
            <Style.Triggers>
                <Trigger Property="IsMouseOver" Value="True">
                    <Setter Property="Foreground" Value="{DynamicResource TextMuted}"/>
                </Trigger>
            </Style.Triggers>
        </Style>

        <!-- Sol menu: gezinme satiri (kart degil, sade satir) -->
        <Style x:Key="NavButtonStyle" TargetType="Button">
            <Setter Property="Background" Value="Transparent"/>
            <Setter Property="Foreground" Value="#E4E4E7"/>
            <Setter Property="BorderBrush" Value="Transparent"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="Padding" Value="12,9"/>
            <Setter Property="Margin" Value="0,1,0,1"/>
            <Setter Property="HorizontalContentAlignment" Value="Left"/>
            <Setter Property="FontSize" Value="12.5"/>
            <Setter Property="FontWeight" Value="Normal"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border Background="{TemplateBinding Background}"
                                BorderBrush="{TemplateBinding BorderBrush}"
                                BorderThickness="{TemplateBinding BorderThickness}"
                                CornerRadius="7" Padding="{TemplateBinding Padding}">
                            <ContentPresenter HorizontalAlignment="{TemplateBinding HorizontalContentAlignment}" VerticalAlignment="Center"/>
                        </Border>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
            <Style.Triggers>
                <Trigger Property="IsMouseOver" Value="True">
                    <Setter Property="Background" Value="{DynamicResource HoverBg}"/>
                </Trigger>
            </Style.Triggers>
        </Style>

        <!-- Kategori filtresi -->
        <Style x:Key="CatPillStyle" TargetType="Button">
            <Setter Property="Background" Value="{DynamicResource CardBg}"/>
            <Setter Property="Foreground" Value="{DynamicResource TextMuted}"/>
            <Setter Property="BorderBrush" Value="{DynamicResource BorderBrushColor}"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="Padding" Value="12,5"/>
            <Setter Property="Margin" Value="0,0,6,6"/>
            <Setter Property="FontSize" Value="12"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border Background="{TemplateBinding Background}"
                                BorderBrush="{TemplateBinding BorderBrush}"
                                BorderThickness="{TemplateBinding BorderThickness}"
                                CornerRadius="6" Padding="{TemplateBinding Padding}">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
            <Style.Triggers>
                <Trigger Property="IsMouseOver" Value="True">
                    <Setter Property="Background" Value="{DynamicResource HoverBg}"/>
                    <Setter Property="Foreground" Value="#FFFFFF"/>
                </Trigger>
            </Style.Triggers>
        </Style>

        <!-- Ikincil (ghost) eylem butonu -->
        <Style x:Key="ActionBtnStyle" TargetType="Button">
            <Setter Property="Foreground" Value="#E4E4E7"/>
            <Setter Property="BorderBrush" Value="{DynamicResource BorderBrushColor}"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="Padding" Value="12,8"/>
            <Setter Property="FontSize" Value="12"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border Background="{TemplateBinding Background}"
                                BorderBrush="{TemplateBinding BorderBrush}"
                                BorderThickness="{TemplateBinding BorderThickness}"
                                CornerRadius="7" Padding="{TemplateBinding Padding}">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
            <Style.Triggers>
                <Trigger Property="IsMouseOver" Value="True">
                    <Setter Property="Opacity" Value="0.86"/>
                </Trigger>
                <Trigger Property="IsEnabled" Value="False">
                    <Setter Property="Opacity" Value="0.45"/>
                </Trigger>
            </Style.Triggers>
        </Style>

        <!-- Birincil CTA -->
        <Style x:Key="PrimaryBtnStyle" TargetType="Button" BasedOn="{StaticResource ActionBtnStyle}">
            <Setter Property="Background" Value="{DynamicResource BtnInstallBg}"/>
            <Setter Property="Foreground" Value="#FFFFFF"/>
            <Setter Property="BorderBrush" Value="{DynamicResource PrimaryHover}"/>
            <Setter Property="Padding" Value="18,10"/>
            <Setter Property="FontSize" Value="12.5"/>
            <Setter Property="FontWeight" Value="Bold"/>
        </Style>

        <!-- Yikici eylem -->
        <Style x:Key="DangerBtnStyle" TargetType="Button" BasedOn="{StaticResource ActionBtnStyle}">
            <Setter Property="Background" Value="{DynamicResource BtnUninstallBg}"/>
            <Setter Property="Foreground" Value="{DynamicResource ErrorFg}"/>
            <Setter Property="BorderBrush" Value="#7F2A2E"/>
        </Style>

        <!-- Sade ikon butonu -->
        <Style x:Key="IconBtnStyle" TargetType="Button">
            <Setter Property="Background" Value="Transparent"/>
            <Setter Property="Foreground" Value="{DynamicResource TextMuted}"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="Padding" Value="8,5"/>
            <Setter Property="FontSize" Value="12"/>
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
                <Trigger Property="IsMouseOver" Value="True">
                    <Setter Property="Background" Value="{DynamicResource HoverBg}"/>
                    <Setter Property="Foreground" Value="#FFFFFF"/>
                </Trigger>
            </Style.Triggers>
        </Style>
    </Window.Resources>

    <Grid>
        <Grid.ColumnDefinitions>
            <ColumnDefinition Width="262"/>
            <ColumnDefinition Width="*"/>
            <ColumnDefinition x:Name="LogColumn" Width="344"/>
        </Grid.ColumnDefinitions>

        <!-- SOL MENU PANELI -->
        <Border Grid.Column="0" Background="{DynamicResource PanelBg}" BorderBrush="{DynamicResource BorderBrushColor}" BorderThickness="0,0,1,0" Padding="12,14">
            <DockPanel LastChildFill="True">
                <StackPanel DockPanel.Dock="Bottom" Margin="0,10,0,0">
                    <Button x:Name="BtnRestorePoint" Style="{StaticResource ActionBtnStyle}" Background="Transparent" Content="&#x1F6E1;&#xFE0F; Geri Y&#x00FC;kleme Noktas&#x0131; Olu&#x015F;tur" Margin="0,0,0,8" ToolTip="Sistemde de&#x011F;i&#x015F;iklik yapmadan &#x00F6;nce g&#x00FC;venli geri d&#x00F6;n&#x00FC;&#x015F; noktas&#x0131; olu&#x015F;turur"/>
                    <TextBlock x:Name="TxtSysInfo" Text="Y&#x00F6;netici Olarak &#x00C7;al&#x0131;&#x015F;&#x0131;yor" FontSize="11" Foreground="{DynamicResource TextDim}" HorizontalAlignment="Center" TextTrimming="CharacterEllipsis"/>
                </StackPanel>

                <ScrollViewer VerticalScrollBarVisibility="Auto">
                    <StackPanel>
                        <Border Background="{DynamicResource CardBg}" BorderBrush="{DynamicResource BorderBrushColor}" BorderThickness="1" CornerRadius="10" Padding="10,9,10,6" Margin="0,0,0,14">
                            <Grid>
                                <Grid.RowDefinitions>
                                    <RowDefinition Height="Auto"/>
                                    <RowDefinition Height="Auto"/>
                                </Grid.RowDefinitions>
                                <StackPanel Grid.Row="0" Orientation="Horizontal">
                                    <Border x:Name="LogoBadge" Width="44" Height="44" CornerRadius="11" Background="{DynamicResource HoverBg}" BorderBrush="{DynamicResource BorderBrushColor}" BorderThickness="1" VerticalAlignment="Center">
                                        <Grid>
                                            <TextBlock x:Name="TxtLogoFallback" Text="&#x1F680;" FontSize="18" HorizontalAlignment="Center" VerticalAlignment="Center"/>
                                            <Image x:Name="ImgLogo" Width="38" Height="38" Stretch="Uniform" Visibility="Collapsed" RenderOptions.BitmapScalingMode="HighQuality"/>
                                        </Grid>
                                    </Border>
                                    <StackPanel Margin="10,0,0,0" VerticalAlignment="Center">
                                        <TextBlock Text="PETRA OMNITOOL" FontSize="15" FontWeight="Bold" Foreground="#FAFAFA"/>
                                        <TextBlock Text="Post-Install &amp; Script Engine v4.0" FontSize="10.5" Foreground="{DynamicResource AccentColor}" Margin="0,3,0,0"/>
                                    </StackPanel>
                                </StackPanel>
                                <TextBlock Grid.Row="1" Text="by Umut Evran" FontSize="9" FontStyle="Italic" Foreground="{DynamicResource TextDim}" HorizontalAlignment="Right" VerticalAlignment="Bottom" Margin="0,5,2,0"/>
                            </Grid>
                        </Border>

                        <!-- MODULLER -->
                        <Button x:Name="BtnNavGroupModules" Style="{StaticResource NavSectionStyle}" Content="&#x25BE; MOD&#x00DC;LLER"/>
                        <StackPanel x:Name="NavGroupModules">
                            <Button x:Name="BtnNavApps" Style="{StaticResource NavButtonStyle}" Content="&#x1F4E6; Uygulama Kurulumu" Background="{DynamicResource ActiveBtnColor}" Foreground="#FFFFFF" FontWeight="SemiBold"/>
                            <Button x:Name="BtnNavTweaks" Style="{StaticResource NavButtonStyle}" Content="&#x26A1; Sistem Tweaks"/>
                            <Button x:Name="BtnNavFeatures" Style="{StaticResource NavButtonStyle}" Content="&#x1F6E0;&#xFE0F; Windows &#x00D6;zellikleri &amp; DNS"/>
                            <Button x:Name="BtnNavBloatware" Style="{StaticResource NavButtonStyle}" Content="&#x1F9F9; Bloatware &amp; UWP"/>
                            <Button x:Name="BtnNavTools" Style="{StaticResource NavButtonStyle}" Content="&#x1F9F0; Sistem Ara&#x00E7;lar&#x0131; &amp; Petra"/>
                            <Button x:Name="BtnNavConfig" Style="{StaticResource NavButtonStyle}" Content="&#x1F4BE; Yedekleme &amp; Config"/>
                        </StackPanel>

                        <!-- PRESETLER -->
                        <Button x:Name="BtnNavGroupPresets" Style="{StaticResource NavSectionStyle}" Content="&#x25BE; HAZIR PAKETLER"/>
                        <StackPanel x:Name="NavGroupPresets">
                            <Button x:Name="BtnPresetUmut" Style="{StaticResource NavButtonStyle}" Content="&#x1F451; Umut &#x00D6;zel Paketi"/>
                            <Button x:Name="BtnPresetGamer" Style="{StaticResource NavButtonStyle}" Content="&#x1F3AE; Oyuncu Paketi"/>
                            <Button x:Name="BtnPresetDev" Style="{StaticResource NavButtonStyle}" Content="&#x1F4BB; Geli&#x015F;tirici Paketi"/>
                            <Button x:Name="BtnPresetStandard" Style="{StaticResource NavButtonStyle}" Content="&#x2728; Standart Kurulum Paketi"/>
                            <Button x:Name="BtnClearSelection" Style="{StaticResource NavButtonStyle}" Content="&#x1F504; T&#x00FC;m Se&#x00E7;imleri Temizle" Foreground="{DynamicResource TextMuted}"/>
                        </StackPanel>
                    </StackPanel>
                </ScrollViewer>
            </DockPanel>
        </Border>

        <!-- ORTA ANA ICERIK PANELI -->
        <Grid Grid.Column="1" Margin="16,14,16,14">
            <!-- SEKME 1: UYGULAMA KURULUMU (WINGET ENGINE) -->
            <Grid x:Name="ViewApps" Visibility="Visible">
                <Grid.RowDefinitions>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="*"/>
                    <RowDefinition Height="Auto"/>
                </Grid.RowDefinitions>

                <!-- Arama Bar -->
                <Border Grid.Row="0" Background="{DynamicResource CardBg}" BorderBrush="{DynamicResource BorderBrushColor}" BorderThickness="1" CornerRadius="9" Padding="12,8" Margin="0,0,0,10">
                    <DockPanel>
                        <TextBlock Text="&#x1F50D; Ara:" Foreground="{DynamicResource TextMuted}" VerticalAlignment="Center" FontWeight="SemiBold" Margin="4,0,10,0"/>
                        <Button x:Name="BtnClearSearch" DockPanel.Dock="Right" Style="{StaticResource ActionBtnStyle}" Content="Temizle" Background="Transparent" Padding="10,5" FontSize="11.5" Margin="6,0,0,0" ToolTip="Aramay&#x0131; ve se&#x00E7;ili uygulamalar&#x0131; temizler"/>
                        <Button x:Name="BtnCheckInstalled" DockPanel.Dock="Right" Style="{StaticResource ActionBtnStyle}" Content="&#x1F4CB; Y&#x00FC;kl&#x00FC; Olanlar&#x0131; Tara" Background="Transparent" Padding="10,5" FontSize="11.5" Margin="6,0,0,0" ToolTip="Sistemde kurulu olan uygulamalar&#x0131; tespit edip &#x00FC;st vitrinde ve listede g&#x00F6;sterir"/>
                        <TextBox x:Name="TxtSearch" Background="Transparent" Foreground="#FAFAFA" BorderThickness="0" FontSize="14" VerticalContentAlignment="Center" CaretBrush="{DynamicResource AccentColor}"/>
                    </DockPanel>
                </Border>

                <!-- Kategori Filtre Butonlari -->
                <WrapPanel x:Name="CategoryButtonPanel" Grid.Row="1" Margin="0,0,0,8"/>

                <!-- YUKLU OLAN UYGULAMALAR VITRIN BARI -->
                <Border x:Name="InstalledAppsBar" Grid.Row="2" Visibility="Collapsed" Background="{DynamicResource SuccessBg}" BorderBrush="{DynamicResource SuccessBorder}" BorderThickness="1" CornerRadius="9" Padding="12,9" Margin="0,0,0,10">
                    <StackPanel>
                        <DockPanel Margin="2,0,2,6">
                            <TextBlock x:Name="TxtInstalledBarTitle" Text="&#x2705; Sistemde Kurulu Uygulamalar (0)" FontSize="11.5" FontWeight="Bold" Foreground="{DynamicResource SuccessFg}" VerticalAlignment="Center"/>
                            <TextBlock Text="T&#x0131;klayarak se&#x00E7;ime ekleyebilir veya &#x00E7;&#x0131;karabilirsiniz" FontSize="10.5" Foreground="{DynamicResource TextDim}" HorizontalAlignment="Right" VerticalAlignment="Center"/>
                        </DockPanel>
                        <ScrollViewer HorizontalScrollBarVisibility="Auto" VerticalScrollBarVisibility="Disabled" Padding="0,0,0,3">
                            <StackPanel x:Name="InstalledAppsStrip" Orientation="Horizontal"/>
                        </ScrollViewer>
                    </StackPanel>
                </Border>

                <!-- Uygulama Listesi -->
                <Border Grid.Row="3" Background="{DynamicResource PanelBg}" BorderBrush="{DynamicResource BorderBrushColor}" BorderThickness="1" CornerRadius="9" Padding="12">
                    <ScrollViewer VerticalScrollBarVisibility="Auto">
                        <StackPanel x:Name="MainStackPanel"/>
                    </ScrollViewer>
                </Border>

                <!-- Alt Eylem Cubugu -->
                <Border Grid.Row="4" Background="{DynamicResource PanelBg}" BorderBrush="{DynamicResource BorderBrushColor}" BorderThickness="1" CornerRadius="9" Padding="14,10" Margin="0,12,0,0">
                    <DockPanel>
                        <TextBlock x:Name="TxtSelectedCount" Text="0 uygulama se&#x00E7;ildi" FontSize="13.5" FontWeight="SemiBold" Foreground="{DynamicResource AccentColor}" VerticalAlignment="Center"/>
                        <StackPanel Orientation="Horizontal" HorizontalAlignment="Right" DockPanel.Dock="Right">
                            <Button x:Name="BtnUpgradeAll" Style="{StaticResource ActionBtnStyle}" Background="Transparent" Content="&#x1F504; T&#x00FC;m&#x00FC;n&#x00FC; G&#x00FC;ncelle" ToolTip="Kurulu t&#x00FC;m paketleri g&#x00FC;ncelle (winget upgrade --all)" Padding="10,7" Margin="0,0,10,0"/>
                            <Button x:Name="BtnUninstall" Style="{StaticResource DangerBtnStyle}" Content="&#x1F5D1;&#xFE0F; Kald&#x0131;r" Margin="0,0,10,0"/>
                            <Button x:Name="BtnUpgradeSelected" Style="{StaticResource ActionBtnStyle}" Background="Transparent" Content="&#x2B06;&#xFE0F; G&#x00FC;ncelle" Margin="0,0,10,0"/>
                            <Button x:Name="BtnInstall" Style="{StaticResource PrimaryBtnStyle}" Content="&#x1F680; Se&#x00E7;ilenleri Kur (Winget)"/>
                        </StackPanel>
                    </DockPanel>
                </Border>
            </Grid>

            <!-- SEKME 2: SISTEM INCE AYARLARI VE GELISMIS TWEAKS -->
            <Grid x:Name="ViewTweaks" Visibility="Collapsed">
                <Grid.RowDefinitions>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="*"/>
                    <RowDefinition Height="Auto"/>
                </Grid.RowDefinitions>

                <Border Grid.Row="0" Background="{DynamicResource CardBg}" BorderBrush="{DynamicResource BorderBrushColor}" BorderThickness="1" CornerRadius="9" Padding="14,12" Margin="0,0,0,10">
                    <StackPanel>
                        <TextBlock Text="&#x26A1; Sistem &#x0130;nce Ayarlar&#x0131; ve Geli&#x015F;mi&#x015F; Tweaks" FontSize="15.5" FontWeight="Bold" Foreground="{DynamicResource AccentColor}"/>
                        <TextBlock Text="Essential, Gaming, UI ve Advanced tweak setlerini tek t&#x0131;kla uygulay&#x0131;n veya Geri Al (Undo) ile fabrika de&#x011F;erlerine d&#x00F6;n&#x00FC;n." FontSize="12" Foreground="{DynamicResource TextMuted}" Margin="0,4,0,0" TextWrapping="Wrap"/>
                    </StackPanel>
                </Border>

                <!-- WinUtil Tweak Preset Secicileri -->
                <Border Grid.Row="1" Background="{DynamicResource CardBg}" BorderBrush="{DynamicResource BorderBrushColor}" BorderThickness="1" CornerRadius="9" Padding="10" Margin="0,0,0,10">
                    <WrapPanel VerticalAlignment="Center">
                        <TextBlock Text="Profiller:" FontSize="12" FontWeight="SemiBold" Foreground="{DynamicResource TextMuted}" VerticalAlignment="Center" Margin="4,0,10,0"/>
                        <Button x:Name="BtnSelectRecTweaks" Style="{StaticResource ActionBtnStyle}" Background="Transparent" BorderBrush="{DynamicResource AccentColor}" Content="&#x2728; &#x00D6;nerilen" Padding="10,5" Margin="0,0,6,0"/>
                        <Button x:Name="BtnTweakPresetStandard" Style="{StaticResource ActionBtnStyle}" Background="Transparent" Content="&#x1F5A5;&#xFE0F; Standart" Padding="10,5" Margin="0,0,6,0"/>
                        <Button x:Name="BtnTweakPresetMinimal" Style="{StaticResource ActionBtnStyle}" Background="Transparent" Content="&#x1F4BB; Minimal" Padding="10,5" Margin="0,0,6,0"/>
                        <Button x:Name="BtnTweakPresetAdvanced" Style="{StaticResource ActionBtnStyle}" Background="Transparent" Content="&#x1F525; Geli&#x015F;mi&#x015F;" Padding="10,5" Margin="0,0,6,0"/>
                        <Button x:Name="BtnClearTweaks" Style="{StaticResource ActionBtnStyle}" Background="Transparent" Foreground="{DynamicResource TextMuted}" Content="Temizle" Padding="10,5"/>
                    </WrapPanel>
                </Border>

                <Border Grid.Row="2" Background="{DynamicResource PanelBg}" BorderBrush="{DynamicResource BorderBrushColor}" BorderThickness="1" CornerRadius="9" Padding="12">
                    <ScrollViewer VerticalScrollBarVisibility="Auto">
                        <StackPanel x:Name="TweaksStackPanel"/>
                    </ScrollViewer>
                </Border>

                <Border Grid.Row="3" Background="{DynamicResource PanelBg}" BorderBrush="{DynamicResource BorderBrushColor}" BorderThickness="1" CornerRadius="9" Padding="14,10" Margin="0,12,0,0">
                    <DockPanel>
                        <StackPanel Orientation="Horizontal" HorizontalAlignment="Right" DockPanel.Dock="Right">
                            <Button x:Name="BtnCleanTemp" Style="{StaticResource ActionBtnStyle}" Background="Transparent" Foreground="{DynamicResource TextMuted}" Content="&#x1F9F9; Disk &amp; Temp Temizle" Margin="0,0,10,0"/>
                            <Button x:Name="BtnRevertContextMenu" Style="{StaticResource ActionBtnStyle}" Background="Transparent" Foreground="{DynamicResource TextMuted}" Content="&#x267B;&#xFE0F; Sa&#x011F; T&#x0131;k Men&#x00FC;s&#x00FC;" ToolTip="Klasik sa&#x011F; t&#x0131;k men&#x00FC;s&#x00FC;n&#x00FC; a&#x00E7;ar veya kapat&#x0131;r (Explorer yeniden ba&#x015F;lat&#x0131;l&#x0131;r)" Margin="0,0,10,0"/>
                            <Button x:Name="BtnUndoTweaks" Style="{StaticResource ActionBtnStyle}" Background="Transparent" Content="&#x21A9;&#xFE0F; Geri Al (Undo)" Margin="0,0,10,0"/>
                            <Button x:Name="BtnApplyTweaks" Style="{StaticResource PrimaryBtnStyle}" Content="&#x26A1; Se&#x00E7;ili Ayarlar&#x0131; Uygula"/>
                        </StackPanel>
                    </DockPanel>
                </Border>
            </Grid>

            <!-- SEKME 3: WINDOWS OZELLIKLERI (DISM), HIZLI DNS, DERIN TEMIZLIK & WINDOWS UPDATE -->
            <Grid x:Name="ViewFeatures" Visibility="Collapsed">
                <Grid.RowDefinitions>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="*"/>
                    <RowDefinition Height="Auto"/>
                </Grid.RowDefinitions>

                <Border Grid.Row="0" Background="{DynamicResource CardBg}" BorderBrush="{DynamicResource BorderBrushColor}" BorderThickness="1" CornerRadius="9" Padding="14,12" Margin="0,0,0,10">
                    <StackPanel>
                        <TextBlock Text="&#x1F6E0;&#xFE0F; Windows &#x00D6;zellikleri (DISM), H&#x0131;zl&#x0131; DNS ve G&#x00FC;ncelleme Politikas&#x0131;" FontSize="15.5" FontWeight="Bold" Foreground="{DynamicResource AccentColor}"/>
                        <TextBlock Text="DirectPlay, .NET 3.5, WSL2, Sandbox, Hyper-V gibi bile&#x015F;enleri y&#x00F6;netin; tek t&#x0131;kla DNS de&#x011F;i&#x015F;tirin ve Windows Update politikas&#x0131;n&#x0131; belirleyin." FontSize="12" Foreground="{DynamicResource TextMuted}" Margin="0,4,0,0" TextWrapping="Wrap"/>
                    </StackPanel>
                </Border>

                <Border Grid.Row="1" Background="{DynamicResource PanelBg}" BorderBrush="{DynamicResource BorderBrushColor}" BorderThickness="1" CornerRadius="9" Padding="14">
                    <ScrollViewer VerticalScrollBarVisibility="Auto">
                        <StackPanel>
                            <!-- Hizli DNS Degistirici -->
                            <Border Background="{DynamicResource CardBg}" BorderBrush="{DynamicResource BorderBrushColor}" BorderThickness="1" CornerRadius="8" Padding="12" Margin="0,0,0,12">
                                <StackPanel>
                                    <DockPanel Margin="0,0,0,10">
                                        <TextBlock Text="&#x1F310; H&#x0131;zl&#x0131; DNS De&#x011F;i&#x015F;tirici (IPv4)" FontSize="13.5" FontWeight="Bold" Foreground="{DynamicResource AccentColor}"/>
                                        <TextBlock x:Name="TxtDnsStatus" Text="Aktif DNS: Sistem Varsay&#x0131;lan&#x0131;" FontSize="11.5" Foreground="{DynamicResource TextMuted}" HorizontalAlignment="Right"/>
                                    </DockPanel>
                                    <WrapPanel>
                                        <Button x:Name="BtnDnsCloudflare" Style="{StaticResource PrimaryBtnStyle}" Content="Cloudflare (1.1.1.1)" Padding="12,6" FontSize="11.5" Margin="0,0,6,6"/>
                                        <Button x:Name="BtnDnsGoogle" Style="{StaticResource ActionBtnStyle}" Background="Transparent" Content="Google (8.8.8.8)" Padding="10,6" Margin="0,0,6,6"/>
                                        <Button x:Name="BtnDnsAdguard" Style="{StaticResource ActionBtnStyle}" Background="Transparent" Content="AdGuard (Reklam Engelleyici)" Padding="10,6" Margin="0,0,6,6"/>
                                        <Button x:Name="BtnDnsQuad9" Style="{StaticResource ActionBtnStyle}" Background="Transparent" Content="Quad9 (9.9.9.9)" Padding="10,6" Margin="0,0,6,6"/>
                                        <Button x:Name="BtnDnsCloudflareMalware" Style="{StaticResource ActionBtnStyle}" Background="Transparent" Content="Cloudflare (Malware Block)" Padding="10,6" Margin="0,0,6,6"/>
                                        <Button x:Name="BtnDnsOpenDns" Style="{StaticResource ActionBtnStyle}" Background="Transparent" Content="OpenDNS" Padding="10,6" Margin="0,0,6,6"/>
                                        <Button x:Name="BtnDnsDhcp" Style="{StaticResource ActionBtnStyle}" Background="Transparent" Foreground="{DynamicResource TextMuted}" Content="&#x1F504; Otomatik (DHCP)" Padding="10,6" Margin="0,0,6,6"/>
                                    </WrapPanel>
                                </StackPanel>
                            </Border>

                            <!-- Derin Temizlik & Windows Update Politikasi -->
                            <Grid Margin="0,0,0,12">
                                <Grid.ColumnDefinitions>
                                    <ColumnDefinition Width="*"/>
                                    <ColumnDefinition Width="12"/>
                                    <ColumnDefinition Width="*"/>
                                </Grid.ColumnDefinitions>

                                <Border Grid.Column="0" Background="{DynamicResource CardBg}" BorderBrush="{DynamicResource BorderBrushColor}" BorderThickness="1" CornerRadius="8" Padding="12">
                                    <StackPanel>
                                        <TextBlock Text="&#x1F9F9; OneDrive, Copilot ve Edge" FontSize="13" FontWeight="Bold" Foreground="{DynamicResource AccentColor}" Margin="0,0,0,10"/>
                                        <WrapPanel>
                                            <Button x:Name="BtnDeepOneDrive" Style="{StaticResource DangerBtnStyle}" Content="OneDrive Kald&#x0131;r" Padding="9,5" FontSize="11.5" Margin="0,0,6,6"/>
                                            <Button x:Name="BtnRestoreOneDrive" Style="{StaticResource ActionBtnStyle}" Background="Transparent" Content="OneDrive Kur" Padding="9,5" FontSize="11.5" Margin="0,0,6,6"/>
                                            <Button x:Name="BtnDisableCopilot" Style="{StaticResource DangerBtnStyle}" Content="Copilot Kapat" Padding="9,5" FontSize="11.5" Margin="0,0,6,6"/>
                                            <Button x:Name="BtnEnableCopilot" Style="{StaticResource ActionBtnStyle}" Background="Transparent" Content="Copilot A&#x00E7;" Padding="9,5" FontSize="11.5" Margin="0,0,6,6"/>
                                            <Button x:Name="BtnDisableEdgeBg" Style="{StaticResource DangerBtnStyle}" Content="Edge Arka Plan Kapat" Padding="9,5" FontSize="11.5" Margin="0,0,6,6"/>
                                            <Button x:Name="BtnEnableEdgeBg" Style="{StaticResource ActionBtnStyle}" Background="Transparent" Content="Edge Varsay&#x0131;lan" Padding="9,5" FontSize="11.5" Margin="0,0,6,6"/>
                                        </WrapPanel>
                                    </StackPanel>
                                </Border>

                                <Border Grid.Column="2" Background="{DynamicResource CardBg}" BorderBrush="{DynamicResource BorderBrushColor}" BorderThickness="1" CornerRadius="8" Padding="12">
                                    <StackPanel>
                                        <TextBlock Text="&#x1F6E1;&#xFE0F; Windows Update Politikas&#x0131;" FontSize="13" FontWeight="Bold" Foreground="{DynamicResource AccentColor}" Margin="0,0,0,10"/>
                                        <WrapPanel>
                                            <Button x:Name="BtnWinUpdateSecurity" Style="{StaticResource PrimaryBtnStyle}" Content="Yaln&#x0131;zca G&#x00FC;venlik Yamalar&#x0131;" Padding="10,5" FontSize="11.5" Margin="0,0,6,6"/>
                                            <Button x:Name="BtnWinUpdateDisable" Style="{StaticResource ActionBtnStyle}" Background="Transparent" Foreground="{DynamicResource ErrorFg}" Content="Update Tamamen Kapat" Padding="9,5" FontSize="11.5" Margin="0,0,6,6"/>
                                            <Button x:Name="BtnWinUpdateDefault" Style="{StaticResource ActionBtnStyle}" Background="Transparent" Content="Varsay&#x0131;lan" Padding="9,5" FontSize="11.5" Margin="0,0,6,6"/>
                                        </WrapPanel>
                                    </StackPanel>
                                </Border>
                            </Grid>

                            <!-- DISM Ozellikler Listesi -->
                            <TextBlock Text="&#x1F4E6; Windows &#x0130;ste&#x011F;e Ba&#x011F;l&#x0131; Bile&#x015F;enler (DISM)" FontSize="13.5" FontWeight="Bold" Foreground="{DynamicResource AccentColor}" Margin="4,2,0,8"/>
                            <UniformGrid x:Name="FeaturesGrid" Columns="2" VerticalAlignment="Top"/>
                        </StackPanel>
                    </ScrollViewer>
                </Border>

                <Border Grid.Row="2" Background="{DynamicResource PanelBg}" BorderBrush="{DynamicResource BorderBrushColor}" BorderThickness="1" CornerRadius="9" Padding="14,10" Margin="0,12,0,0">
                    <DockPanel>
                        <StackPanel Orientation="Horizontal" HorizontalAlignment="Right" DockPanel.Dock="Right">
                            <Button x:Name="BtnCheckFeaturesStatus" Style="{StaticResource ActionBtnStyle}" Background="Transparent" Content="&#x1F50D; Durumlar&#x0131; Sorgula" Margin="0,0,10,0"/>
                            <Button x:Name="BtnDisableFeatures" Style="{StaticResource DangerBtnStyle}" Content="&#x274C; Devre D&#x0131;&#x015F;&#x0131; B&#x0131;rak" Margin="0,0,10,0"/>
                            <Button x:Name="BtnApplyFeatures" Style="{StaticResource PrimaryBtnStyle}" Content="&#x2705; Se&#x00E7;ili &#x00D6;zellikleri Etkinle&#x015F;tir"/>
                        </StackPanel>
                    </DockPanel>
                </Border>
            </Grid>

            <!-- SEKME 4: BLOATWARE & UWP TASFIYESI -->
            <Grid x:Name="ViewBloatware" Visibility="Collapsed">
                <Grid.RowDefinitions>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="*"/>
                    <RowDefinition Height="Auto"/>
                </Grid.RowDefinitions>

                <Border Grid.Row="0" Background="{DynamicResource CardBg}" BorderBrush="{DynamicResource BorderBrushColor}" BorderThickness="1" CornerRadius="9" Padding="14,12" Margin="0,0,0,10">
                    <StackPanel>
                        <TextBlock Text="&#x1F9F9; UWP Bloatware Tasfiyesi ve Geri Y&#x00FC;kleme" FontSize="15.5" FontWeight="Bold" Foreground="{DynamicResource AccentColor}"/>
                        <TextBlock Text="Kullanmad&#x0131;&#x011F;&#x0131;n&#x0131;z yerle&#x015F;ik Microsoft Store / UWP uygulamalar&#x0131;n&#x0131; AllUsers ve Provisioned d&#x00FC;zeyinde temizleyin veya Store &#x00FC;zerinden geri kurun." FontSize="12" Foreground="{DynamicResource TextMuted}" Margin="0,4,0,0" TextWrapping="Wrap"/>
                    </StackPanel>
                </Border>

                <Border Grid.Row="1" Background="{DynamicResource CardBg}" BorderBrush="{DynamicResource BorderBrushColor}" BorderThickness="1" CornerRadius="9" Padding="10" Margin="0,0,0,10">
                    <WrapPanel>
                        <Button x:Name="BtnSelectDefaultBloat" Style="{StaticResource ActionBtnStyle}" Background="Transparent" BorderBrush="{DynamicResource AccentColor}" Content="&#x2728; &#x00D6;nerilen G&#x00FC;venli Liste" Padding="10,5" Margin="0,0,6,0"/>
                        <Button x:Name="BtnSelectAllBloat" Style="{StaticResource ActionBtnStyle}" Background="Transparent" Content="T&#x00FC;m&#x00FC;n&#x00FC; Se&#x00E7;" Padding="10,5" Margin="0,0,6,0"/>
                        <Button x:Name="BtnClearBloat" Style="{StaticResource ActionBtnStyle}" Background="Transparent" Foreground="{DynamicResource TextMuted}" Content="Se&#x00E7;imi Temizle" Padding="10,5"/>
                    </WrapPanel>
                </Border>

                <Border Grid.Row="2" Background="{DynamicResource PanelBg}" BorderBrush="{DynamicResource BorderBrushColor}" BorderThickness="1" CornerRadius="9" Padding="12">
                    <ScrollViewer VerticalScrollBarVisibility="Auto">
                        <UniformGrid x:Name="BloatwareGrid" Columns="2" VerticalAlignment="Top"/>
                    </ScrollViewer>
                </Border>

                <Border Grid.Row="3" Background="{DynamicResource PanelBg}" BorderBrush="{DynamicResource BorderBrushColor}" BorderThickness="1" CornerRadius="9" Padding="14,10" Margin="0,12,0,0">
                    <DockPanel>
                        <StackPanel Orientation="Horizontal" HorizontalAlignment="Right" DockPanel.Dock="Right">
                            <Button x:Name="BtnReinstallBloatware" Style="{StaticResource ActionBtnStyle}" Background="Transparent" Content="&#x1F4E5; Store'dan Geri Y&#x00FC;kle" Margin="0,0,10,0"/>
                            <Button x:Name="BtnRemoveBloatware" Style="{StaticResource DangerBtnStyle}" Content="&#x1F5D1;&#xFE0F; Se&#x00E7;ili Paketleri Kald&#x0131;r"/>
                        </StackPanel>
                    </DockPanel>
                </Border>
            </Grid>

            <!-- SEKME 5: SISTEM ARACLARI, ONARIM & PETRA -->
            <Grid x:Name="ViewTools" Visibility="Collapsed">
                <Grid.RowDefinitions>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="*"/>
                </Grid.RowDefinitions>

                <Border Grid.Row="0" Background="{DynamicResource CardBg}" BorderBrush="{DynamicResource BorderBrushColor}" BorderThickness="1" CornerRadius="9" Padding="14,12" Margin="0,0,0,10">
                    <StackPanel>
                        <TextBlock Text="&#x1F9F0; Sistem Onar&#x0131;m Ara&#x00E7;lar&#x0131; ve Klasik Konsollar" FontSize="15.5" FontWeight="Bold" Foreground="{DynamicResource AccentColor}"/>
                        <TextBlock Text="DISM/SFC onar&#x0131;m&#x0131;, a&#x011F; s&#x0131;f&#x0131;rlama, O&amp;O ShutUp10++, Petra Lisans Arac&#x0131; ve klasik y&#x00F6;netim konsollar&#x0131;." FontSize="12" Foreground="{DynamicResource TextMuted}" Margin="0,4,0,0" TextWrapping="Wrap"/>
                    </StackPanel>
                </Border>

                <Border Grid.Row="1" Background="{DynamicResource PanelBg}" BorderBrush="{DynamicResource BorderBrushColor}" BorderThickness="1" CornerRadius="9" Padding="14">
                    <ScrollViewer VerticalScrollBarVisibility="Auto">
                        <StackPanel>
                            <TextBlock Text="&#x1F527; Sistem Bak&#x0131;m, Onar&#x0131;m ve Harici Ara&#x00E7;lar" FontSize="13.5" FontWeight="Bold" Foreground="{DynamicResource AccentColor}" Margin="4,0,0,10"/>
                            <UniformGrid Columns="2" Margin="0,0,0,16">
                                <Button x:Name="BtnRunMAS" Style="{StaticResource ActionBtnStyle}" Background="Transparent" BorderBrush="{DynamicResource AccentColor}" Content="&#x1F511; Petra Lisans ve Sistem Y&#x00F6;netim Arac&#x0131; (HWID / Ohook / KMS)" Margin="4"/>
                                <Button x:Name="BtnRunOOSU" Style="{StaticResource ActionBtnStyle}" Background="Transparent" Content="&#x1F6E1;&#xFE0F; O&amp;O ShutUp10++ &#x0130;ndir ve &#x00C7;al&#x0131;&#x015F;t&#x0131;r" Margin="4"/>
                                <Button x:Name="BtnFixSystemCorruption" Style="{StaticResource ActionBtnStyle}" Background="Transparent" Content="&#x1FA7A; DISM RestoreHealth + SFC /scannow" Margin="4"/>
                                <Button x:Name="BtnFixWinUpdate" Style="{StaticResource ActionBtnStyle}" Background="Transparent" Content="&#x1F504; Windows Update Bile&#x015F;enlerini S&#x0131;f&#x0131;rla" Margin="4"/>
                                <Button x:Name="BtnFixNetwork" Style="{StaticResource ActionBtnStyle}" Background="Transparent" Content="&#x1F310; A&#x011F; Y&#x0131;&#x011F;&#x0131;n&#x0131; ve Winsock S&#x0131;f&#x0131;rla" Margin="4"/>
                                <Button x:Name="BtnFixWinget" Style="{StaticResource ActionBtnStyle}" Background="Transparent" Content="&#x1F4E6; Winget Kaynaklar&#x0131;n&#x0131; Onar" Margin="4"/>
                                <Button x:Name="BtnFixNTP" Style="{StaticResource ActionBtnStyle}" Background="Transparent" Content="&#x23F0; Sistem Saatini (NTP) Senkronize Et" Margin="4"/>
                                <Button x:Name="BtnRunAutologon" Style="{StaticResource ActionBtnStyle}" Background="Transparent" Content="&#x1F513; Sysinternals Autologon &#x00C7;al&#x0131;&#x015F;t&#x0131;r" Margin="4"/>
                                <Button x:Name="BtnEnableOpenSSH" Style="{StaticResource ActionBtnStyle}" Background="Transparent" Content="&#x1F4DF; OpenSSH Sunucusunu Etkinle&#x015F;tir" Margin="4"/>
                                <Button x:Name="BtnEnableRegBackup" Style="{StaticResource ActionBtnStyle}" Background="Transparent" Content="&#x1F4BE; Kay&#x0131;t Defteri Yede&#x011F;ini (RegBack) A&#x00E7;" Margin="4"/>
                                <Button x:Name="BtnCreateGodMode" Style="{StaticResource ActionBtnStyle}" Background="Transparent" Content="&#x2699;&#xFE0F; Masa&#x00FC;st&#x00FC;ne GodMode Klas&#x00F6;r&#x00FC;" Margin="4"/>
                                <Button x:Name="BtnRestartExplorer" Style="{StaticResource ActionBtnStyle}" Background="Transparent" Content="&#x1F503; Windows Gezgini'ni Yeniden Ba&#x015F;lat" Margin="4"/>
                                <Button x:Name="BtnEnableF8Boot" Style="{StaticResource ActionBtnStyle}" Background="Transparent" Content="&#x1F5A5;&#xFE0F; Klasik F8 G&#x00FC;venli Mod Men&#x00FC;s&#x00FC;" Margin="4"/>
                                <Button x:Name="BtnDisableF8Boot" Style="{StaticResource ActionBtnStyle}" Background="Transparent" Content="&#x1F5A5;&#xFE0F; Standart Boot Men&#x00FC;s&#x00FC;ne D&#x00F6;n" Margin="4"/>
                            </UniformGrid>

                            <TextBlock Text="&#x1F39B;&#xFE0F; Klasik Denetim Masas&#x0131; ve Sistem Konsollar&#x0131; (.cpl / .msc)" FontSize="13.5" FontWeight="Bold" Foreground="{DynamicResource AccentColor}" Margin="4,4,0,10"/>
                            <UniformGrid Columns="3">
                                <Button x:Name="BtnPanelControl" Style="{StaticResource ActionBtnStyle}" Background="Transparent" Content="Denetim Masas&#x0131;" Margin="4"/>
                                <Button x:Name="BtnPanelNetwork" Style="{StaticResource ActionBtnStyle}" Background="Transparent" Content="A&#x011F; Ba&#x011F;da&#x015F;t&#x0131;r&#x0131;c&#x0131;lar&#x0131; (ncpa.cpl)" Margin="4"/>
                                <Button x:Name="BtnPanelSystem" Style="{StaticResource ActionBtnStyle}" Background="Transparent" Content="Sistem &#x00D6;zellikleri (sysdm.cpl)" Margin="4"/>
                                <Button x:Name="BtnPanelPower" Style="{StaticResource ActionBtnStyle}" Background="Transparent" Content="G&#x00FC;&#x00E7; Se&#x00E7;enekleri (powercfg.cpl)" Margin="4"/>
                                <Button x:Name="BtnPanelSound" Style="{StaticResource ActionBtnStyle}" Background="Transparent" Content="Ses Denetimi (mmsys.cpl)" Margin="4"/>
                                <Button x:Name="BtnPanelPrograms" Style="{StaticResource ActionBtnStyle}" Background="Transparent" Content="Program Ekle/Kald&#x0131;r (appwiz.cpl)" Margin="4"/>
                                <Button x:Name="BtnPanelComputer" Style="{StaticResource ActionBtnStyle}" Background="Transparent" Content="Bilgisayar Y&#x00F6;netimi (compmgmt.msc)" Margin="4"/>
                                <Button x:Name="BtnPanelMouse" Style="{StaticResource ActionBtnStyle}" Background="Transparent" Content="Fare Ayarlar&#x0131; (main.cpl)" Margin="4"/>
                                <Button x:Name="BtnPanelFirewall" Style="{StaticResource ActionBtnStyle}" Background="Transparent" Content="G&#x00FC;venlik Duvar&#x0131; (wf.msc)" Margin="4"/>
                                <Button x:Name="BtnPanelRestore" Style="{StaticResource ActionBtnStyle}" Background="Transparent" Content="Sistem Geri Y&#x00FC;kleme (rstrui.exe)" Margin="4"/>
                                <Button x:Name="BtnPanelTimedate" Style="{StaticResource ActionBtnStyle}" Background="Transparent" Content="Tarih ve Saat (timedate.cpl)" Margin="4"/>
                                <Button x:Name="BtnPanelRegion" Style="{StaticResource ActionBtnStyle}" Background="Transparent" Content="B&#x00F6;lge Ayarlar&#x0131; (intl.cpl)" Margin="4"/>
                            </UniformGrid>
                        </StackPanel>
                    </ScrollViewer>
                </Border>
            </Grid>

            <!-- SEKME 6: YEDEKLEME & CONFIG -->
            <Grid x:Name="ViewConfig" Visibility="Collapsed">
                <Grid.RowDefinitions>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="*"/>
                </Grid.RowDefinitions>

                <Border Grid.Row="0" Background="{DynamicResource CardBg}" BorderBrush="{DynamicResource BorderBrushColor}" BorderThickness="1" CornerRadius="9" Padding="14,12" Margin="0,0,0,10">
                    <StackPanel>
                        <TextBlock Text="&#x1F4BE; Yap&#x0131;land&#x0131;rma Yedekleme (Import / Export) ve Uzaktan &#x00C7;al&#x0131;&#x015F;t&#x0131;rma" FontSize="15.5" FontWeight="Bold" Foreground="{DynamicResource AccentColor}"/>
                        <TextBlock Text="Se&#x00E7;ti&#x011F;iniz uygulama, Tweak, DISM ve Bloatware profillerini JSON olarak d&#x0131;&#x015F;a aktar&#x0131;n veya ba&#x015F;ka bir bilgisayarda i&#x00E7;e aktar&#x0131;n." FontSize="12" Foreground="{DynamicResource TextMuted}" Margin="0,4,0,0" TextWrapping="Wrap"/>
                    </StackPanel>
                </Border>

                <Border Grid.Row="1" Background="{DynamicResource PanelBg}" BorderBrush="{DynamicResource BorderBrushColor}" BorderThickness="1" CornerRadius="9" Padding="16">
                    <StackPanel>
                        <TextBlock Text="&#x1F4C2; JSON Yap&#x0131;land&#x0131;rma ve Sistem Raporu" FontSize="13.5" FontWeight="Bold" Foreground="{DynamicResource AccentColor}" Margin="0,0,0,12"/>
                        <WrapPanel Margin="0,0,0,20">
                            <Button x:Name="BtnExportConfig" Style="{StaticResource PrimaryBtnStyle}" Content="&#x1F4E4; Se&#x00E7;imleri JSON Olarak D&#x0131;&#x015F;a Aktar" Margin="0,0,10,8"/>
                            <Button x:Name="BtnImportConfig" Style="{StaticResource ActionBtnStyle}" Background="Transparent" Content="&#x1F4E5; JSON Yap&#x0131;land&#x0131;rma Y&#x00FC;kle" Margin="0,0,10,8"/>
                            <Button x:Name="BtnExportSysReport" Style="{StaticResource ActionBtnStyle}" Background="Transparent" Content="&#x1F4DD; Sistem Raporu Kaydet (.txt)" Margin="0,0,10,8"/>
                        </WrapPanel>

                        <TextBlock Text="&#x2601;&#xFE0F; PowerShell Uzaktan &#x00C7;al&#x0131;&#x015F;t&#x0131;rma Komutu (Cloudflare Worker)" FontSize="13.5" FontWeight="Bold" Foreground="{DynamicResource AccentColor}" Margin="0,0,0,10"/>
                        <Border Background="{DynamicResource CardBg}" BorderBrush="{DynamicResource BorderBrushColor}" BorderThickness="1" CornerRadius="8" Padding="12">
                            <DockPanel>
                                <Button x:Name="BtnCopyCmd" DockPanel.Dock="Right" Style="{StaticResource ActionBtnStyle}" Background="Transparent" Content="&#x1F4CB; Kopyala" Padding="12,6" Margin="10,0,0,0"/>
                                <TextBox x:Name="TxtRemoteCmd" Text="irm evrantool.evranumut.workers.dev | iex" IsReadOnly="True" Background="Transparent" Foreground="{DynamicResource SuccessFg}" BorderThickness="0" FontFamily="Consolas" FontSize="13.5" VerticalContentAlignment="Center"/>
                            </DockPanel>
                        </Border>
                    </StackPanel>
                </Border>
            </Grid>
        </Grid>

        <!-- SAG LOG VE DURUM PANELI -->
        <Border Grid.Column="2" Background="{DynamicResource PanelBg}" BorderBrush="{DynamicResource BorderBrushColor}" BorderThickness="1,0,0,0" Padding="12">
            <Grid>
                <!-- ACIK KONSOL -->
                <Grid x:Name="LogExpandedPanel">
                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="*"/>
                        <RowDefinition Height="Auto"/>
                    </Grid.RowDefinitions>

                    <DockPanel Grid.Row="0" Margin="0,0,0,10">
                        <Button x:Name="BtnToggleLog" DockPanel.Dock="Right" Style="{StaticResource IconBtnStyle}" Content="&#x276F;" ToolTip="Konsolu daralt" VerticalAlignment="Center"/>
                        <Button x:Name="BtnTheme" DockPanel.Dock="Right" Style="{StaticResource IconBtnStyle}" Content="&#x1F319;" FontSize="14" Foreground="{DynamicResource AccentColor}" ToolTip="Tema: Solar Eclipse (de&#x011F;i&#x015F;tirmek i&#x00E7;in t&#x0131;kla)" VerticalAlignment="Center" Margin="0,0,2,0"/>
                        <TextBlock Text="&#x1F4DF; CANLI &#x0130;&#x015E;LEM KONSOLU" FontSize="13" FontWeight="Bold" Foreground="{DynamicResource AccentColor}" VerticalAlignment="Center"/>
                    </DockPanel>

                    <Border Grid.Row="1" Background="{DynamicResource CardBg}" BorderBrush="{DynamicResource BorderBrushColor}" BorderThickness="1" CornerRadius="8" Padding="12,10" Margin="0,0,0,10">
                        <StackPanel>
                            <TextBlock x:Name="TxtStatus" Text="Haz&#x0131;r" FontSize="12" FontWeight="SemiBold" Foreground="#FAFAFA" TextTrimming="CharacterEllipsis" Margin="0,0,0,8"/>
                            <ProgressBar x:Name="ProgressBarMain" Height="8" Minimum="0" Maximum="100" Value="0" Background="{DynamicResource LogBg}" Foreground="{DynamicResource AccentColor}" BorderThickness="0"/>
                        </StackPanel>
                    </Border>

                    <Border Grid.Row="2" Background="{DynamicResource LogBg}" BorderBrush="{DynamicResource BorderBrushColor}" BorderThickness="1" CornerRadius="8" Padding="10,8">
                        <RichTextBox x:Name="TxtLog" Background="Transparent" Foreground="{DynamicResource LogFg}" BorderThickness="0"
                                     FontFamily="Consolas" FontSize="11.5" IsReadOnly="True" IsDocumentEnabled="False"
                                     IsReadOnlyCaretVisible="False" VerticalScrollBarVisibility="Auto" Padding="0" Margin="0"
                                     SelectionBrush="{DynamicResource ActiveBtnColor}">
                            <FlowDocument PagePadding="0" FontFamily="Consolas" FontSize="11.5" Foreground="{DynamicResource LogFg}"/>
                        </RichTextBox>
                    </Border>

                    <DockPanel Grid.Row="3" Margin="0,10,0,0">
                        <Button x:Name="BtnClearLog" DockPanel.Dock="Right" Style="{StaticResource ActionBtnStyle}" Background="Transparent" Foreground="{DynamicResource TextMuted}" Content="&#x1F9F9; Temizle" Padding="10,6" Margin="8,0,0,0"/>
                        <Button x:Name="BtnSaveLog" Style="{StaticResource ActionBtnStyle}" Background="Transparent" Foreground="{DynamicResource TextMuted}" Content="&#x1F4BE; Konsolu Kaydet" ToolTip="Konsol kayitlarini metin dosyasina aktar"/>
                    </DockPanel>
                </Grid>

                <!-- DARALTILMIS KONSOL -->
                <Grid x:Name="LogCollapsedBar" Visibility="Collapsed">
                    <StackPanel VerticalAlignment="Top" HorizontalAlignment="Center">
                        <Button x:Name="BtnExpandLog" Style="{StaticResource IconBtnStyle}" Content="&#x1F4DF;" ToolTip="Konsolu geni&#x015F;let" Margin="0,0,0,10"/>
                        <Button x:Name="BtnThemeCollapsed" Style="{StaticResource IconBtnStyle}" Content="&#x1F319;" FontSize="14" Foreground="{DynamicResource AccentColor}" ToolTip="Tema: Solar Eclipse (de&#x011F;i&#x015F;tirmek i&#x00E7;in t&#x0131;kla)" Margin="0,0,0,10"/>
                        <TextBlock Text="KONSOL" FontSize="11" FontWeight="Bold" Foreground="{DynamicResource TextDim}" HorizontalAlignment="Center">
                            <TextBlock.LayoutTransform>
                                <RotateTransform Angle="90"/>
                            </TextBlock.LayoutTransform>
                        </TextBlock>
                    </StackPanel>
                </Grid>
            </Grid>
        </Border>
    </Grid>
</Window>
'@

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

# --- TEMA KATALOGU (Solar Eclipse varsayilan / Deep Ocean alternatif) ---
$script:Themes = @{}

$script:Themes["SolarEclipse"] = @'
{
    "Name": "Solar Eclipse",
    "WindowBg": "#0B0A09",
    "PanelBg": "#141110",
    "CardBg": "#1B1715",
    "BorderBrushColor": "#2E2723",
    "HoverBg": "#241E1A",
    "AccentColor": "#FBBF6B",
    "ActiveBtnColor": "#F97316",
    "PrimaryHover": "#C2410C",
    "TextMuted": "#A8A29E",
    "TextDim": "#7C7269",
    "LogBg": "#090807",
    "LogFg": "#E7E0D8",
    "BtnInstallBg": "#F97316",
    "BtnUninstallBg": "#4A1D1D",
    "BtnUpgradeBg": "#241D18",
    "SuccessFg": "#86EFAC",
    "SuccessBg": "#17251B",
    "SuccessBorder": "#2F5C41",
    "WarnFg": "#FBBF24",
    "ErrorFg": "#FCA5A5",
    "SelectedBg": "#2C2115",
    "SelectedBorder": "#F97316"
}
'@ | ConvertFrom-Json

$script:Themes["DeepOcean"] = @'
{
    "Name": "Deep Ocean",
    "WindowBg": "#07121B",
    "PanelBg": "#0A1A26",
    "CardBg": "#0F2434",
    "BorderBrushColor": "#1B4358",
    "HoverBg": "#142F44",
    "AccentColor": "#67E8F9",
    "ActiveBtnColor": "#0891B2",
    "PrimaryHover": "#0E7490",
    "TextMuted": "#94A3B8",
    "TextDim": "#64748B",
    "LogBg": "#05101A",
    "LogFg": "#D6E6F0",
    "BtnInstallBg": "#0891B2",
    "BtnUninstallBg": "#4A1F2E",
    "BtnUpgradeBg": "#0E2A3D",
    "SuccessFg": "#5EEAD4",
    "SuccessBg": "#0A2B2C",
    "SuccessBorder": "#17606A",
    "WarnFg": "#FCD34D",
    "ErrorFg": "#FCA5A5",
    "SelectedBg": "#0E3348",
    "SelectedBorder": "#22D3EE"
}
'@ | ConvertFrom-Json

# --- TEMA TERCIHI KALICILIGI (%LOCALAPPDATA%\PetraOmniTool\settings.json) ---
function Get-PetraSettingsDir {
    $base = $env:LOCALAPPDATA
    if ([string]::IsNullOrWhiteSpace($base)) { $base = $env:TEMP }
    return (Join-Path $base "PetraOmniTool")
}

function Get-PetraSettingsPath {
    return (Join-Path (Get-PetraSettingsDir) "settings.json")
}

function Read-PetraSettings {
    try {
        $path = Get-PetraSettingsPath
        if (Test-Path -LiteralPath $path) {
            $raw = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)
            if (-not [string]::IsNullOrWhiteSpace($raw)) { return ($raw | ConvertFrom-Json) }
        }
    } catch {}
    return $null
}

function Save-PetraSettings($settings) {
    try {
        $dir = Get-PetraSettingsDir
        if (-not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
        $path = Get-PetraSettingsPath
        $tmp = "$path.tmp"
        $json = $settings | ConvertTo-Json -Depth 5
        [System.IO.File]::WriteAllText($tmp, $json, (New-Object System.Text.UTF8Encoding($false)))
        Move-Item -LiteralPath $tmp -Destination $path -Force
        return $true
    } catch {
        return $false
    }
}

function Save-PetraThemePreference([string]$name) {
    if ([string]::IsNullOrWhiteSpace($name)) { return }
    $settings = Read-PetraSettings
    if ($null -eq $settings) { $settings = [pscustomobject]@{} }
    try {
        $settings | Add-Member -NotePropertyName "Theme" -NotePropertyValue $name -Force
        [void](Save-PetraSettings $settings)
    } catch {}
}

$script:ThemeName = "SolarEclipse"
$script:ThemeLoadedFromSettings = $false
try {
    $savedSettings = Read-PetraSettings
    if ($savedSettings -and $savedSettings.PSObject.Properties["Theme"]) {
        $savedTheme = [string]$savedSettings.Theme
        $savedThemeKey = Get-OrdinalIgnoreCaseKey $script:Themes $savedTheme
        if ($savedThemeKey) {
            $script:ThemeName = $savedThemeKey
            $script:ThemeLoadedFromSettings = $true
        }
    }
} catch {}
$script:Theme = $script:Themes[$script:ThemeName]

# --- TEMA MOTORU ---
# Bir elemanin rengini pencere kaynagina baglar; tema degisince eleman
# yeniden olusturulmadan otomatik guncellenir (UI donmasini engeller).
function Get-ThemeDependencyProperty($element, [string]$property) {
    if ($null -eq $element -or [string]::IsNullOrWhiteSpace($property)) { return $null }
    $fieldName = $property + "Property"
    $t = $element.GetType()
    while ($t) {
        $flags = [System.Reflection.BindingFlags]::Public -bor [System.Reflection.BindingFlags]::Static -bor [System.Reflection.BindingFlags]::FlattenHierarchy
        $field = $t.GetField($fieldName, $flags)
        if ($field) {
            try { return $field.GetValue($null) } catch { return $null }
        }
        $t = $t.BaseType
    }
    return $null
}

function Set-ThemeRef($element, $property, [string]$key) {
    if ($null -eq $element -or -not $key) { return }
    try {
        $dp = Get-ThemeDependencyProperty $element $property
        if ($dp) { $element.SetResourceReference($dp, $key) }
    } catch { }
}

function Set-PetraThemeResources {
    if (-not $script:window -or -not $script:Theme) { return }
    foreach ($prop in $script:Theme.PSObject.Properties) {
        if ($prop.Name -eq "Name") { continue }
        try { $script:window.Resources[$prop.Name] = Get-Brush ([string]$prop.Value) } catch {}
    }
}

function Update-ThemeButtonVisual {
    $icon = if ($script:ThemeName -eq "DeepOcean") { Decode-U "\uD83C\uDF0A" } else { Decode-U "\uD83C\uDF11" }
    $tip  = "Tema: " + $script:Theme.Name + " - degistirmek icin tikla"
    foreach ($b in @($script:BtnTheme, $script:BtnThemeCollapsed)) {
        if ($b) {
            $b.Content  = $icon
            $b.ToolTip  = $tip
        }
    }
}

function Find-PanelScrollViewer($panel) {
    if (-not $panel) { return $null }
    $node = $panel
    while ($node) {
        if ($node -is [System.Windows.Controls.ScrollViewer]) { return $node }
        try {
            $node = [System.Windows.Media.VisualTreeHelper]::GetParent($node)
        } catch {
            return $null
        }
    }
    return $null
}

function Get-PanelScrollOffset($panel) {
    $sv = Find-PanelScrollViewer $panel
    if ($sv) { return $sv.VerticalOffset }
    return 0
}

function Set-PanelScrollOffset($panel, [double]$offset) {
    $sv = Find-PanelScrollViewer $panel
    if ($sv -and $offset -ge 0) { $sv.ScrollToVerticalOffset($offset) }
}

function Update-LogColors {
    if (-not $script:TxtLog) { return }
    foreach ($block in $script:TxtLog.Document.Blocks) {
        if ($block -is [System.Windows.Documents.Paragraph]) {
            foreach ($inline in $block.Inlines) {
                if ($inline -is [System.Windows.Documents.Run]) {
                    try { $inline.Foreground = Get-Brush (Get-LogLineColor $inline.Text) } catch {}
                }
            }
        }
    }
}

function Apply-PetraTheme([string]$name) {
    $themeKey = Get-OrdinalIgnoreCaseKey $script:Themes $name
    if (-not $themeKey) { return }
    $name = $themeKey

    $script:ThemeName = $name
    $script:Theme = $script:Themes[$name]
    # Pencere kaynaklarini guncelle: listelerdeki elemanlar bu kaynaklara
    # bagli oldugu icin yeniden olusturmaya (ve donmaya) gerek kalmaz.
    Set-PetraThemeResources

    try { Update-CategoryPillStyles } catch {}
    try { Switch-Tab $script:ActiveTab } catch {}
    Update-LogColors
    Update-ThemeButtonVisual

    # Durum cubugu metni son islemin rengini korur; tema rengine gore yenile.
    if ($script:TxtStatus) {
        $statusText = [string]$script:TxtStatus.Text
        $statusColor = if ($statusText -match '\[(HATA|!)\]|Hata|hata') { $script:Theme.ErrorFg } else { $script:Theme.LogFg }
        try { $script:TxtStatus.Foreground = Get-Brush $statusColor } catch {}
    }

    Save-PetraThemePreference $name
    Write-UiLog ("[i] Tema degistirildi: " + $script:Theme.Name)
}

function New-ThemeMenuRow([string]$key) {
    $t = $script:Themes[$key]

    $row = New-Object System.Windows.Controls.Border
    $row.Tag = $key
    $row.CornerRadius = New-Object System.Windows.CornerRadius(6)
    $row.Padding = New-Object System.Windows.Thickness(8, 7, 8, 7)
    $row.Background = Get-Brush "Transparent"
    $row.Cursor = [System.Windows.Input.Cursors]::Hand

    $grid = New-Object System.Windows.Controls.Grid
    $c1 = New-Object System.Windows.Controls.ColumnDefinition
    $c1.Width = New-Object System.Windows.GridLength(18)
    $c2 = New-Object System.Windows.Controls.ColumnDefinition
    $c2.Width = New-Object System.Windows.GridLength(1, [System.Windows.GridUnitType]::Star)
    $c3 = New-Object System.Windows.Controls.ColumnDefinition
    $c3.Width = New-Object System.Windows.GridLength(18)
    [void]$grid.ColumnDefinitions.Add($c1)
    [void]$grid.ColumnDefinitions.Add($c2)
    [void]$grid.ColumnDefinitions.Add($c3)

    $swatch = New-Object System.Windows.Controls.Border
    $swatch.Width = 11
    $swatch.Height = 11
    $swatch.CornerRadius = New-Object System.Windows.CornerRadius(3)
    $swatch.Background = Get-Brush $t.ActiveBtnColor
    $swatch.BorderBrush = Get-Brush $t.AccentColor
    $swatch.BorderThickness = New-Object System.Windows.Thickness(1)
    $swatch.VerticalAlignment = "Center"
    [System.Windows.Controls.Grid]::SetColumn($swatch, 0)
    [void]$grid.Children.Add($swatch)

    $label = New-Object System.Windows.Controls.TextBlock
    $label.Text = $t.Name
    Set-ThemeRef $label "Foreground" "LogFg"
    $label.VerticalAlignment = "Center"
    $label.Margin = New-Object System.Windows.Thickness(8, 0, 10, 0)
    [System.Windows.Controls.Grid]::SetColumn($label, 1)
    [void]$grid.Children.Add($label)

    $check = New-Object System.Windows.Controls.TextBlock
    $check.Text = Decode-U "\u2713"
    $check.FontWeight = "Bold"
    $check.Foreground = Get-Brush $t.AccentColor
    $check.VerticalAlignment = "Center"
    $check.HorizontalAlignment = "Right"
    $check.Margin = New-Object System.Windows.Thickness(0, 0, 2, 0)
    $check.Visibility = if ($key -eq $script:ThemeName) { "Visible" } else { "Hidden" }
    [System.Windows.Controls.Grid]::SetColumn($check, 2)
    [void]$grid.Children.Add($check)

    $row.Child = $grid
    $row.Add_MouseEnter({ param($s, $e) $s.Background = Get-Brush $script:Theme.HoverBg })
    $row.Add_MouseLeave({ param($s, $e) $s.Background = Get-Brush "Transparent" })
    $row.Add_MouseLeftButtonUp({
        param($s, $e)
        $script:ThemePopup.IsOpen = $false
        Apply-PetraTheme ([string]$s.Tag)
    })
    return $row
}

function Show-ThemePopup {
    $panel = New-Object System.Windows.Controls.StackPanel
    foreach ($key in @("SolarEclipse", "DeepOcean")) {
        [void]$panel.Children.Add((New-ThemeMenuRow $key))
    }

    $card = New-Object System.Windows.Controls.Border
    Set-ThemeRef $card "Background" "PanelBg"
    Set-ThemeRef $card "BorderBrush" "BorderBrushColor"
    $card.BorderThickness = New-Object System.Windows.Thickness(1)
    $card.CornerRadius = New-Object System.Windows.CornerRadius(8)
    $card.Padding = New-Object System.Windows.Thickness(5)
    $card.MinWidth = 192
    $card.Margin = New-Object System.Windows.Thickness(10)
    $card.Child = $panel

    try {
        $shadow = New-Object System.Windows.Media.Effects.DropShadowEffect
        $shadow.BlurRadius = 14
        $shadow.ShadowDepth = 3
        $shadow.Opacity = 0.55
        $shadow.Color = [System.Windows.Media.Colors]::Black
        $card.Effect = $shadow
    } catch {}

    $script:ThemePopupCard = $card
    $script:ThemePopup.Child = $card
}

function Show-ThemePopupFor($button) {
    Show-ThemePopup
    $script:ThemePopup.PlacementTarget = $button
    $popupWidth = 0
    try {
        $script:ThemePopupCard.Measure((New-Object System.Windows.Size([double]::PositiveInfinity, [double]::PositiveInfinity)))
        $popupWidth = $script:ThemePopupCard.DesiredSize.Width
    } catch {}
    if ($popupWidth -gt $button.ActualWidth) {
        $script:ThemePopup.HorizontalOffset = -($popupWidth - $button.ActualWidth)
    } else {
        $script:ThemePopup.HorizontalOffset = 0
    }
    $script:ThemePopup.IsOpen = $true
}

function Initialize-ThemePopup {
    $popup = New-Object System.Windows.Controls.Primitives.Popup
    $popup.Placement = [System.Windows.Controls.Primitives.PlacementMode]::Bottom
    $popup.StaysOpen = $true
    $popup.AllowsTransparency = $true
    $popup.PopupAnimation = [System.Windows.Controls.Primitives.PopupAnimation]::Fade
    $popup.VerticalOffset = 2
    $script:ThemePopup = $popup
    $popup.Add_Opened({
        $target = $script:ThemePopup.PlacementTarget
        if (-not $target) { return }
        $popupWidth = 0
        try { $popupWidth = $script:ThemePopupCard.DesiredSize.Width } catch {}
        if ($popupWidth -gt $target.ActualWidth) {
            $script:ThemePopup.HorizontalOffset = -($popupWidth - $target.ActualWidth)
        } else {
            $script:ThemePopup.HorizontalOffset = 0
        }
    })

    foreach ($b in @($script:BtnTheme, $script:BtnThemeCollapsed)) {
        if (-not $b) { continue }
        $b.Add_Click({
            if ($script:ThemePopup.IsOpen) { $script:ThemePopup.IsOpen = $false }
            else { Show-ThemePopupFor $this }
        })
    }

    $script:window.Add_PreviewMouseDown({
        param($s, $e)
        if (-not $script:ThemePopup.IsOpen) { return }
        if ($script:BtnTheme -and $script:BtnTheme.IsMouseOver) { return }
        if ($script:BtnThemeCollapsed -and $script:BtnThemeCollapsed.IsMouseOver) { return }
        $script:ThemePopup.IsOpen = $false
    })
    $script:window.Add_PreviewKeyDown({
        param($s, $e)
        if ($e.Key -eq [System.Windows.Input.Key]::Escape -and $script:ThemePopup.IsOpen) {
            $script:ThemePopup.IsOpen = $false
            $e.Handled = $true
        }
    })
    $script:window.Add_Deactivated({ $script:ThemePopup.IsOpen = $false })
    Update-ThemeButtonVisual
}

$script:AppCategories = $sync.AppsConfig
$script:FeaturesData  = $sync.FeaturesConfig
$script:TweaksData    = $sync.TweaksConfig
$script:BloatwareData = $sync.BloatwareConfig

# AppsConfig icindeki Winget ID, Icon URL ve aciklama duzeltmelerini otomatik uygula
foreach ($cat in $script:AppCategories) {
    $cat.Category = Decode-U $cat.Category
    foreach ($app in $cat.Apps) {
        $app.Name = Decode-U $app.Name
        $app.Id   = Resolve-WingetId $app.Id
        if ($app.PSObject.Properties["Icon"] -and $app.Icon) {
            $app.Icon = Decode-U ([string]$app.Icon)
        }
        $desc     = Decode-U $app.Description
        $desc     = $desc.Replace([string]([char]0x0448 + [char]0x0435 + [char]0x0439 + "der"), "shader")
        $app.Description = $desc
        if ($app.Name -eq "Visual Studio 2026" -and $app.Id -eq "Microsoft.VisualStudio.2022.Enterprise") {
            $app.Name = "Visual Studio 2022 Enterprise"
        }
        if ($app.Name -eq "Python3" -and $app.Id -eq "Python.Python.3.13") {
            $app.Name = "Python 3.13"
        }
    }
}

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

# Sol Panel Preset ve Geri Yukleme Butonlari
$script:BtnPresetUmut     = $script:window.FindName("BtnPresetUmut")
$script:BtnPresetGamer    = $script:window.FindName("BtnPresetGamer")
$script:BtnPresetDev      = $script:window.FindName("BtnPresetDev")
$script:BtnPresetStandard = $script:window.FindName("BtnPresetStandard")
$script:BtnClearSelection = $script:window.FindName("BtnClearSelection")
$script:BtnRestorePoint   = $script:window.FindName("BtnRestorePoint")

# Sekme 1: Uygulama Kurulumu Kontrolleri ve Yuklu Vitrin Bari
$script:TxtSearch           = $script:window.FindName("TxtSearch")
$script:BtnClearSearch      = $script:window.FindName("BtnClearSearch")
$script:BtnCheckInstalled   = $script:window.FindName("BtnCheckInstalled")
$script:CategoryButtonPanel = $script:window.FindName("CategoryButtonPanel")
$script:InstalledAppsBar    = $script:window.FindName("InstalledAppsBar")
$script:TxtInstalledBarTitle= $script:window.FindName("TxtInstalledBarTitle")
$script:InstalledAppsStrip  = $script:window.FindName("InstalledAppsStrip")
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
$script:TxtDnsStatus           = $script:window.FindName("TxtDnsStatus")
$script:BtnDnsCloudflare       = $script:window.FindName("BtnDnsCloudflare")
$script:BtnDnsGoogle           = $script:window.FindName("BtnDnsGoogle")
$script:BtnDnsAdguard          = $script:window.FindName("BtnDnsAdguard")
$script:BtnDnsQuad9            = $script:window.FindName("BtnDnsQuad9")
$script:BtnDnsCloudflareMalware= $script:window.FindName("BtnDnsCloudflareMalware")
$script:BtnDnsOpenDns          = $script:window.FindName("BtnDnsOpenDns")
$script:BtnDnsDhcp             = $script:window.FindName("BtnDnsDhcp")

$script:BtnDeepOneDrive    = $script:window.FindName("BtnDeepOneDrive")
$script:BtnDisableCopilot  = $script:window.FindName("BtnDisableCopilot")
$script:BtnDisableEdgeBg   = $script:window.FindName("BtnDisableEdgeBg")
$script:BtnRestoreOneDrive = $script:window.FindName("BtnRestoreOneDrive")
$script:BtnEnableCopilot   = $script:window.FindName("BtnEnableCopilot")
$script:BtnEnableEdgeBg    = $script:window.FindName("BtnEnableEdgeBg")

$script:BtnWinUpdateSecurity = $script:window.FindName("BtnWinUpdateSecurity")
$script:BtnWinUpdateDisable  = $script:window.FindName("BtnWinUpdateDisable")
$script:BtnWinUpdateDefault  = $script:window.FindName("BtnWinUpdateDefault")

$script:FeaturesGrid           = $script:window.FindName("FeaturesGrid")
$script:BtnCheckFeaturesStatus = $script:window.FindName("BtnCheckFeaturesStatus")
$script:BtnApplyFeatures       = $script:window.FindName("BtnApplyFeatures")
$script:BtnDisableFeatures     = $script:window.FindName("BtnDisableFeatures")

# Sekme 4: Bloatware Kontrolleri
$script:BloatwareGrid         = $script:window.FindName("BloatwareGrid")
$script:BtnSelectDefaultBloat = $script:window.FindName("BtnSelectDefaultBloat")
$script:BtnSelectAllBloat     = $script:window.FindName("BtnSelectAllBloat")
$script:BtnClearBloat         = $script:window.FindName("BtnClearBloat")
$script:BtnReinstallBloatware = $script:window.FindName("BtnReinstallBloatware")
$script:BtnRemoveBloatware    = $script:window.FindName("BtnRemoveBloatware")

# Sekme 5: Sistem Araclari & Petra Kontrolleri
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

$script:BtnPanelControl  = $script:window.FindName("BtnPanelControl")
$script:BtnPanelNetwork  = $script:window.FindName("BtnPanelNetwork")
$script:BtnPanelSystem   = $script:window.FindName("BtnPanelSystem")
$script:BtnPanelPower    = $script:window.FindName("BtnPanelPower")
$script:BtnPanelSound    = $script:window.FindName("BtnPanelSound")
$script:BtnPanelPrograms = $script:window.FindName("BtnPanelPrograms")
$script:BtnPanelComputer = $script:window.FindName("BtnPanelComputer")
$script:BtnPanelMouse    = $script:window.FindName("BtnPanelMouse")
$script:BtnPanelFirewall = $script:window.FindName("BtnPanelFirewall")
$script:BtnPanelRestore  = $script:window.FindName("BtnPanelRestore")
$script:BtnPanelTimedate = $script:window.FindName("BtnPanelTimedate")
$script:BtnPanelRegion   = $script:window.FindName("BtnPanelRegion")

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
$script:BtnSaveLog      = $script:window.FindName("BtnSaveLog")
$script:TxtSysInfo      = $script:window.FindName("TxtSysInfo")

# Konsol daraltma / genisletme ve sol menu akordeon kontrolleri
$script:LogColumn         = $script:window.FindName("LogColumn")
$script:LogExpandedPanel  = $script:window.FindName("LogExpandedPanel")
$script:LogCollapsedBar   = $script:window.FindName("LogCollapsedBar")
$script:BtnToggleLog      = $script:window.FindName("BtnToggleLog")
$script:BtnExpandLog      = $script:window.FindName("BtnExpandLog")
$script:BtnTheme          = $script:window.FindName("BtnTheme")
$script:BtnThemeCollapsed = $script:window.FindName("BtnThemeCollapsed")
$script:BtnNavGroupModules = $script:window.FindName("BtnNavGroupModules")
$script:NavGroupModules    = $script:window.FindName("NavGroupModules")
$script:BtnNavGroupPresets = $script:window.FindName("BtnNavGroupPresets")
$script:NavGroupPresets    = $script:window.FindName("NavGroupPresets")

# LogColumn FindName ile bulunamazsa ana Grid'in 3. sutununu kullan.
if (-not $script:LogColumn) {
    try {
        $rootGrid = $script:window.Content
        if ($rootGrid -and $rootGrid.ColumnDefinitions.Count -gt 2) {
            $script:LogColumn = $rootGrid.ColumnDefinitions[2]
        }
    } catch {}
}

if ($script:TxtLog) { $script:TxtLog.Document.PagePadding = New-Object System.Windows.Thickness(0) }

if ($script:BtnRunMAS) {
    $script:BtnRunMAS.Content = Decode-U "\uD83D\uDD11 Petra Lisans ve Sistem Yonetim Araci (HWID / Ohook / KMS)"
}

$sync.TxtLog                = $script:TxtLog
$sync.TxtStatus             = $script:TxtStatus
$sync.ProgressBarMain       = $script:ProgressBarMain
$sync.BtnInstall            = $script:BtnInstall
$sync.BtnUninstall          = $script:BtnUninstall
$sync.BtnUpgradeSelected   = $script:BtnUpgradeSelected
$sync.BtnUpgradeAll         = $script:BtnUpgradeAll
$sync.BtnApplyTweaks        = $script:BtnApplyTweaks
$sync.BtnUndoTweaks         = $script:BtnUndoTweaks
$sync.BtnApplyFeatures      = $script:BtnApplyFeatures
$sync.BtnDisableFeatures    = $script:BtnDisableFeatures
$sync.BtnRemoveBloatware    = $script:BtnRemoveBloatware
$sync.BtnReinstallBloatware = $script:BtnReinstallBloatware
$sync.InstalledApps         = [Hashtable]::Synchronized(@{})
$sync.AllAppIds             = @()
foreach ($c in $script:AppCategories) {
    foreach ($a in $c.Apps) { $sync.AllAppIds += $a.Id }
}
$sync.IsBusy                = $false

# Log satirini durumuna gore renklendirir (basari yesil, uyari sari, hata kirmizi).
function Get-LogLineColor([string]$line) {
    if ($line -match '\[(HATA|!)\]') { return $script:Theme.ErrorFg }
    if ($line -match '\[(OK|\+)\]') { return $script:Theme.SuccessFg }
    if ($line -match '\[(UNDO|-)\]') { return $script:Theme.WarnFg }
    if ($line -match '\[(APPLY)\]') { return $script:Theme.AccentColor }
    if ($line -match '\[(i|\*)\]') { return $script:Theme.TextMuted }
    return $script:Theme.LogFg
}

function Add-UiLogLine([string]$line) {
    if (-not $script:TxtLog) { return }
    $doc = $script:TxtLog.Document
    $para = New-Object System.Windows.Documents.Paragraph
    $para.Margin = New-Object System.Windows.Thickness(0)
    $para.LineHeight = 16
    $run = New-Object System.Windows.Documents.Run($line)
    try { $run.Foreground = Get-Brush (Get-LogLineColor $line) } catch { }
    [void]$para.Inlines.Add($run)
    [void]$doc.Blocks.Add($para)
    if ($doc.Blocks.Count -gt 1500) { $doc.Blocks.Remove($doc.Blocks.FirstBlock) }
    $script:TxtLog.ScrollToEnd()
}

function Write-UiLog([string]$msg) {
    $time = (Get-Date).ToString("HH:mm:ss")
    $decoded = Decode-U $msg
    if ($script:window.Dispatcher.CheckAccess()) {
        Add-UiLogLine "[$time] $decoded"
    } else {
        $script:window.Dispatcher.Invoke([action]{ Add-UiLogLine "[$time] $decoded" })
    }
}

function Set-UiStatus([string]$msg, [double]$progress = -1) {
    $decoded = Decode-U $msg
    $color = if ($msg -match '\[(HATA|!)\]|Hata|hata') { $script:Theme.ErrorFg }
             elseif ($msg -match ('^\s*(Hazir|Haz' + [char]0x0131 + 'r)\s*$')) { "#FAFAFA" }
             else { $script:Theme.LogFg }
    $script:window.Dispatcher.Invoke([action]{
        $script:TxtStatus.Text = $decoded
        try { $script:TxtStatus.Foreground = Get-Brush $color } catch { }
        if ($progress -ge 0) {
            $script:ProgressBarMain.Value = $progress
        }
    })
}

# --- Genel Arka Plan Runspace Yurutucu (Donmayan Arayuz Motoru) ---
function Start-BackgroundTask([string]$TaskName, [hashtable]$Params, [scriptblock]$WorkBlock) {
    if ($sync.IsBusy) {
        Write-UiLog (Decode-U "[!] Su anda devam eden bir arka plan islemi var, lutfen bitmesini bekleyin.")
        return
    }
    $sync.IsBusy = $true
    try {
        $rs = [runspacefactory]::CreateRunspace()
        $rs.ApartmentState = "STA"
        $rs.ThreadOptions = "ReuseThread"
        $rs.Open()
    } catch {
        $sync.IsBusy = $false
        Write-UiLog ("[HATA] Arka plan runspace acilamadi: " + $_.Exception.Message)
        return
    }
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
            $sync.UiQueue.Enqueue([pscustomobject]@{ Kind = "log"; Text = "[$t] $dec" })
        }
        function Status-Bg([string]$s, [double]$p = -1) {
            $dec = Decode-Bg $s
            $sync.UiQueue.Enqueue([pscustomobject]@{ Kind = "status"; Text = $dec; Progress = $p })
        }
        function Test-WingetAvailable {
            return [bool](Get-Command "winget" -ErrorAction SilentlyContinue)
        }
        # Store urun kimligi testi arka plan runspace'inde de gerekli
        # (kaldirma/guncelleme islemleri burada calisir).
        function Test-StoreProductId([string]$pkgId) {
            if ([string]::IsNullOrWhiteSpace($pkgId)) { return $false }
            return ($pkgId.Trim() -cmatch '^[0-9A-Z]{12,20}$')
        }
        function Refresh-InstalledAppsBg {
            Status-Bg "Kurulu uygulama listesi guncelleniyor..." 95
            if (-not (Test-WingetAvailable)) {
                Log-Bg "[!] winget bulunamadi. Microsoft Store'dan 'App Installer' paketini guncelleyin."
                Status-Bg "winget bulunamadi" 100
                return
            }
            Log-Bg "[*] Winget uzerinden sistemde kurulu uygulamalar yenileniyor..."
            $rawList = (winget list --accept-source-agreements 2>$null) -join "`n"
            $found = @{}
            $boundaryOpts = [System.Text.RegularExpressions.RegexOptions]::IgnoreCase -bor [System.Text.RegularExpressions.RegexOptions]::CultureInvariant
            foreach ($id in $sync.AllAppIds) {
                $escapedId = [regex]::Escape($id)
                $pattern = "(?<![A-Za-z0-9._+\-])$escapedId(?![A-Za-z0-9._+\-])"
                if ([regex]::IsMatch($rawList, $pattern, $boundaryOpts)) {
                    $found[$id] = $true
                }
            }
            # Paylasilan tabloyu yerinde guncelle (runspace'ler arasi referans yarisi olmasin).
            $sync.InstalledApps.Clear()
            foreach ($foundId in $found.Keys) { $sync.InstalledApps[$foundId] = $true }
            $sync.RenderRequested = $true
            Log-Bg ("[OK] Kurulu uygulama listesi yenilendi (" + $found.Count + " kurulu paket).")
        }
        function Set-RegSafe([string]$Path, [string]$Name, [string]$Type, $Value) {
            # Get-ChildItem'in dondurdugu PSPath ("Microsoft.PowerShell.Core\Registry::HKEY_...")
            # veya ham "HKEY_..." yollari da desteklensin; aksi halde New-ItemProperty
            # calisir gibi gorunup deger yazilmaz.
            if ($Path -and $Path.StartsWith("Microsoft.PowerShell.Core\Registry::")) {
                $Path = $Path.Substring("Microsoft.PowerShell.Core\Registry::".Length)
            }
            if ($Path -and $Path.StartsWith("Registry::")) {
                $Path = $Path.Substring("Registry::".Length)
            }
            if ($Path -and $Path.StartsWith("HKEY_LOCAL_MACHINE")) { $Path = "HKLM:" + $Path.Substring(18) }
            elseif ($Path -and $Path.StartsWith("HKEY_CURRENT_USER")) { $Path = "HKCU:" + $Path.Substring(17) }
            elseif ($Path -and $Path.StartsWith("HKEY_CLASSES_ROOT")) { $Path = "HKCR:" + $Path.Substring(17) }
            elseif ($Path -and $Path.StartsWith("HKEY_USERS")) { $Path = "HKU:" + $Path.Substring(10) }
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
                $propType = switch ($Type) {
                    "DWord"        { "DWord" }
                    "QWord"        { "QWord" }
                    "Binary"       { "Binary" }
                    "ExpandString" { "ExpandString" }
                    "MultiString"  { "MultiString" }
                    default        { "String" }
                }
                New-ItemProperty -Path $Path -Name $Name -PropertyType $propType -Value $Value -Force -ErrorAction Stop | Out-Null
            } catch {
                # Ikinci sans: bazi sistemlerde .NET kayit defteri saglayicisi engellenir,
                # reg.exe ile ayni degeri yazmayi dene.
                $regRoot = switch -Regex ($Path) {
                    '^HKLM:\\' { "HKLM" }
                    '^HKCU:\\' { "HKCU" }
                    '^HKCR:\\' { "HKCR" }
                    '^HKU:\\'  { "HKU" }
                    default    { $null }
                }
                $regOk = $false
                if ($regRoot) {
                    $subKey = $Path -creplace '^[A-Z]+:\\', ''
                    $regKey = "$regRoot\$subKey"
                    if ($Value -eq "<RemoveEntry>") {
                        # Deger zaten yoksa silme komutu hata dondurur; bunu basari say
                        # (yanlis "[!] Reg Hatasi" logu olusmasin).
                        reg query "$regKey" /v "$Name" 2>&1 | Out-Null
                        if ($LASTEXITCODE -ne 0) {
                            $regOk = $true
                        } else {
                            reg delete "$regKey" /v "$Name" /f 2>&1 | Out-Null
                            $regOk = ($LASTEXITCODE -eq 0)
                        }
                    } else {
                        $regType = switch ($Type) {
                            "DWord"        { "REG_DWORD" }
                            "QWord"        { "REG_QWORD" }
                            "Binary"       { "REG_BINARY" }
                            "ExpandString" { "REG_EXPAND_SZ" }
                            "MultiString"  { "REG_MULTI_SZ" }
                            default        { "REG_SZ" }
                        }
                        reg add "$regKey" /v "$Name" /t $regType /d "$Value" /f 2>&1 | Out-Null
                        $regOk = ($LASTEXITCODE -eq 0)
                    }
                }
                if (-not $regOk) {
                    $protectedNames = @("ShellFeedsTaskbarViewMode", "TaskbarDa", "AllowNewsAndInterests")
                    $isDenied = ($_.Exception -is [System.UnauthorizedAccessException]) -or ($_.Exception -is [System.Security.SecurityException])
                    if ($isDenied -and ($protectedNames -contains $Name)) {
                        if ($sync.IsAdmin) {
                            Log-Bg ("[i] Sistem korumali ayar atlandi ($Name). Bu surumde Windows bu degeri salt okunur tutuyor; Ayarlar > Kisisellestirme > Gorev cubugu uzerinden kapatabilirsiniz.")
                        } else {
                            Log-Bg ("[i] Yonetici yetkisi gerektigi icin atlandi ($Name). Araci yonetici olarak calistirin: Ayarlar > Kisisellestirme > Gorev cubugu.")
                        }
                    } else {
                        $hint = ""
                        if ($isDenied) {
                            $hint = " (anahtar sistem tarafindan korumali; manuel ayar gerekebilir)"
                        }
                        Log-Bg ("[!] Reg Hatasi ($Path -> $Name): " + $_.Exception.Message + $hint)
                    }
                }
            }
        }

        try {
            Status-Bg $TaskName 5
            $sb = [scriptblock]::Create($WorkStr)
            & $sb $Params
        } catch {
            Log-Bg ("[HATA] " + $_.Exception.Message)
        } finally {
            $sync.IsBusy = $false
            Status-Bg "Hazir" 100
        }
    })
    try {
        $null = $ps.BeginInvoke()
    } catch {
        $sync.IsBusy = $false
        Write-UiLog ("[HATA] Arka plan gorevi baslatilamadi: " + $_.Exception.Message)
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

# --- SECIM VE DURUM YONETIMI (HER MENUDE SECILEN SAYISI TAKIBI) ---
$script:SelectedApps      = @{}
$script:AppCheckboxes     = @{}   # Sadece o an gorunen (filtreye uyan) uygulamalar
$script:AllAppCheckboxes  = @{}   # Tum uygulamalar (filtre disi secimler icin)
$script:AppCards          = @{}
$script:AppCardMeta       = @{}
$script:AppCategoryGroups = @()
$script:AppsBuilt         = $false
$script:StripBadges       = @{}
$script:TweakCheckboxes   = @{}
$script:FeatureCheckboxes = @{}
$script:BloatCheckboxes   = @{}
$script:TweakCards        = @{}
$script:FeatureCards      = @{}
$script:BloatCards        = @{}
$script:CategoryButtons   = @{}
$script:ActiveCategory    = "ALL"
$script:ActiveTab         = "Apps"
$script:ActiveAppPresetIds = @()

$script:TotalAppCount = 0
foreach ($c in $script:AppCategories) {
    $script:TotalAppCount += $c.Apps.Count
}

function Update-InstalledStripSelectionVisuals {
    foreach ($id in $script:StripBadges.Keys) {
        $badge = $script:StripBadges[$id]
        if ($script:SelectedApps[$id] -eq $true) {
            Set-ThemeRef $badge "Background" "SelectedBg"
            Set-ThemeRef $badge "BorderBrush" "AccentColor"
        } else {
            Set-ThemeRef $badge "Background" "CardBg"
            Set-ThemeRef $badge "BorderBrush" "SuccessBorder"
        }
    }
}

function Update-AllSelectionCounts {
    $appCount = ($script:SelectedApps.Values | Where-Object { $_ -eq $true }).Count
    $script:TxtSelectedCount.Text = Decode-U "$appCount uygulama secildi"

    if ($script:CategoryButtons.ContainsKey("ALL")) {
        $allLabel = if ($appCount -gt 0) {
            Decode-U "Tumu ($appCount/$($script:TotalAppCount))"
        } else {
            Decode-U "Tumu ($($script:TotalAppCount))"
        }
        $script:CategoryButtons["ALL"].Content = $allLabel
    }

    if ($script:CategoryButtons.ContainsKey("INSTALLED")) {
        $instTotal = if ($sync.InstalledApps) { $sync.InstalledApps.Count } else { 0 }
        $btnInst = $script:CategoryButtons["INSTALLED"]
        if ($instTotal -gt 0) {
            $btnInst.Visibility = "Visible"
            $instSel = 0
            foreach ($k in $sync.InstalledApps.Keys) {
                if ($script:SelectedApps[$k] -eq $true) { $instSel++ }
            }
            $btnInst.Content = if ($instSel -gt 0) {
                Decode-U "\u2705 Yuklu ($instSel/$instTotal)"
            } else {
                Decode-U "\u2705 Yuklu ($instTotal)"
            }
        } else {
            $btnInst.Visibility = "Collapsed"
        }
    }

    foreach ($cat in $script:AppCategories) {
        $catName = $cat.Category
        if ($script:CategoryButtons.ContainsKey($catName)) {
            $catTotal = $cat.Apps.Count
            $catSel = 0
            foreach ($a in $cat.Apps) {
                if ($script:SelectedApps[$a.Id] -eq $true) { $catSel++ }
            }
            $script:CategoryButtons[$catName].Content = if ($catSel -gt 0) {
                "$catName ($catSel/$catTotal)"
            } else {
                "$catName ($catTotal)"
            }
        }
    }

    Update-InstalledStripSelectionVisuals

    $tweakCount = ($script:TweakCheckboxes.Values | Where-Object { $_.IsChecked -eq $true }).Count
    $featCount  = ($script:FeatureCheckboxes.Values | Where-Object { $_.IsChecked -eq $true }).Count
    $bloatCount = ($script:BloatCheckboxes.Values | Where-Object { $_.IsChecked -eq $true }).Count

    $script:BtnNavApps.Content = if ($appCount -gt 0) {
        Decode-U "\uD83D\uDCE6 Uygulama Kurulumu ($appCount/$($script:TotalAppCount))"
    } else {
        Decode-U "\uD83D\uDCE6 Uygulama Kurulumu ($($script:TotalAppCount))"
    }

    $script:BtnNavTweaks.Content = if ($tweakCount -gt 0) {
        Decode-U "\u26A1 Sistem & Gelismis Tweaks ($tweakCount secili)"
    } else {
        Decode-U "\u26A1 Sistem & Gelismis Tweaks"
    }

    $script:BtnNavFeatures.Content = if ($featCount -gt 0) {
        Decode-U "\uD83D\uDEE0\uFE0F Windows Ozellikleri & DNS ($featCount secili)"
    } else {
        Decode-U "\uD83D\uDEE0\uFE0F Windows Ozellikleri & DNS"
    }

    $script:BtnNavBloatware.Content = if ($bloatCount -gt 0) {
        Decode-U "\uD83D\uDDD1\uFE0F Bloatware & UWP Tasfiyesi ($bloatCount secili)"
    } else {
        Decode-U "\uD83D\uDDD1\uFE0F Bloatware & UWP Tasfiyesi"
    }
}

# --- SEKME GECIS MOTORU ---
function Switch-Tab([string]$tabName) {
    $script:ActiveTab = $tabName
    $script:ViewApps.Visibility      = if ($tabName -eq "Apps")      { "Visible" } else { "Collapsed" }
    $script:ViewTweaks.Visibility    = if ($tabName -eq "Tweaks")    { "Visible" } else { "Collapsed" }
    $script:ViewFeatures.Visibility  = if ($tabName -eq "Features")  { "Visible" } else { "Collapsed" }
    $script:ViewBloatware.Visibility = if ($tabName -eq "Bloatware") { "Visible" } else { "Collapsed" }
    $script:ViewTools.Visibility     = if ($tabName -eq "Tools")     { "Visible" } else { "Collapsed" }
    $script:ViewConfig.Visibility    = if ($tabName -eq "Config")    { "Visible" } else { "Collapsed" }

    $navMap = @{
        "Apps"      = $script:BtnNavApps
        "Tweaks"    = $script:BtnNavTweaks
        "Features"  = $script:BtnNavFeatures
        "Bloatware" = $script:BtnNavBloatware
        "Tools"     = $script:BtnNavTools
        "Config"    = $script:BtnNavConfig
    }
    foreach ($k in $navMap.Keys) {
        $btn = $navMap[$k]
        if ($k -eq $tabName) {
            Set-ThemeRef $btn "Background" "ActiveBtnColor"
            $btn.Foreground  = Get-Brush "#FFFFFF"
            $btn.FontWeight  = "SemiBold"
        } else {
            $btn.Background  = Get-Brush "Transparent"
            $btn.Foreground  = Get-Brush "#E4E4E7"
            $btn.FontWeight  = "Normal"
        }
    }
}

# --- SOL MENU AKORDEON GRUPLARI ---
function Set-NavGroupState([string]$group, [bool]$expanded) {
    if ($group -eq "Modules") {
        if ($script:NavGroupModules) { $script:NavGroupModules.Visibility = if ($expanded) { "Visible" } else { "Collapsed" } }
        if ($script:BtnNavGroupModules) { $script:BtnNavGroupModules.Content = if ($expanded) { Decode-U "\u25BE MOD\u00DCLLER" } else { Decode-U "\u25B8 MOD\u00DCLLER" } }
    } else {
        if ($script:NavGroupPresets) { $script:NavGroupPresets.Visibility = if ($expanded) { "Visible" } else { "Collapsed" } }
        if ($script:BtnNavGroupPresets) { $script:BtnNavGroupPresets.Content = if ($expanded) { Decode-U "\u25BE HAZIR PAKETLER" } else { Decode-U "\u25B8 HAZIR PAKETLER" } }
    }
}
if ($script:BtnNavGroupModules) {
    $script:BtnNavGroupModules.Add_Click({
        $isOpen = ($script:NavGroupModules.Visibility -eq "Visible")
        Set-NavGroupState "Modules" (-not $isOpen)
    })
}
if ($script:BtnNavGroupPresets) {
    $script:BtnNavGroupPresets.Add_Click({
        $isOpen = ($script:NavGroupPresets.Visibility -eq "Visible")
        Set-NavGroupState "Presets" (-not $isOpen)
    })
}

# --- KONSOL DARALT / GENISLET ---
$script:LogExpanded = $true
function Set-LogPanelState([bool]$expanded) {
    $script:LogExpanded = $expanded
    if ($script:LogColumn) {
        $script:LogColumn.Width = New-Object System.Windows.GridLength($(if ($expanded) { 344 } else { 58 }))
    }
    if ($script:LogExpandedPanel) { $script:LogExpandedPanel.Visibility = if ($expanded) { "Visible" } else { "Collapsed" } }
    if ($script:LogCollapsedBar)  { $script:LogCollapsedBar.Visibility  = if ($expanded) { "Collapsed" } else { "Visible" } }
}
if ($script:BtnToggleLog) { $script:BtnToggleLog.Add_Click({ Set-LogPanelState $false }) }
if ($script:BtnExpandLog) { $script:BtnExpandLog.Add_Click({ Set-LogPanelState $true }) }

$script:BtnNavApps.Add_Click({ Switch-Tab "Apps" })
$script:BtnNavTweaks.Add_Click({ Switch-Tab "Tweaks" })
$script:BtnNavFeatures.Add_Click({ Switch-Tab "Features" })
$script:BtnNavBloatware.Add_Click({ Switch-Tab "Bloatware" })
$script:BtnNavTools.Add_Click({ Switch-Tab "Tools" })
$script:BtnNavConfig.Add_Click({ Switch-Tab "Config" })

# --- SEKME 1: UYGULAMA KATEGORILERI, UST VITRIN VE LOGOLU LISTE RENDER ---
function Update-CategoryPillStyles {
    foreach ($key in $script:CategoryButtons.Keys) {
        $b = $script:CategoryButtons[$key]
        if ($key -eq $script:ActiveCategory) {
            Set-ThemeRef $b "Background" "ActiveBtnColor"
            $b.Foreground  = Get-Brush "#FFFFFF"
            Set-ThemeRef $b "BorderBrush" "AccentColor"
        } elseif ($key -eq "INSTALLED") {
            Set-ThemeRef $b "Background" "SuccessBg"
            Set-ThemeRef $b "Foreground" "SuccessFg"
            Set-ThemeRef $b "BorderBrush" "SuccessBorder"
        } else {
            Set-ThemeRef $b "Background" "CardBg"
            Set-ThemeRef $b "Foreground" "TextMuted"
            Set-ThemeRef $b "BorderBrush" "BorderBrushColor"
        }
    }
}

function Initialize-CategoryPills {
    $script:CategoryButtonPanel.Children.Clear()
    $script:CategoryButtons.Clear()

    $btnAll = New-Object System.Windows.Controls.Button
    $btnAll.Style = $script:window.FindResource("CatPillStyle")
    $btnAll.Content = Decode-U "Tumu ($($script:TotalAppCount))"
    $btnAll.Tag = "ALL"
    $btnAll.Add_Click({
        $script:ActiveCategory = "ALL"
        Update-CategoryPillStyles
        Render-Apps
    })
    [void]$script:CategoryButtonPanel.Children.Add($btnAll)
    $script:CategoryButtons["ALL"] = $btnAll

    $btnInst = New-Object System.Windows.Controls.Button
    $btnInst.Style = $script:window.FindResource("CatPillStyle")
    $btnInst.Content = Decode-U "\u2705 Yuklu (0)"
    $btnInst.Tag = "INSTALLED"
    $btnInst.Visibility = "Collapsed"
    $btnInst.Add_Click({
        $script:ActiveCategory = "INSTALLED"
        Update-CategoryPillStyles
        Render-Apps
    })
    [void]$script:CategoryButtonPanel.Children.Add($btnInst)
    $script:CategoryButtons["INSTALLED"] = $btnInst

    foreach ($cat in $script:AppCategories) {
        $cName = $cat.Category
        $btn = New-Object System.Windows.Controls.Button
        $btn.Style = $script:window.FindResource("CatPillStyle")
        $btn.Content = "$cName ($($cat.Apps.Count))"
        $btn.Tag = $cName
        $btn.Add_Click({
            param($sender, $e)
            $script:ActiveCategory = [string]$sender.Tag
            Update-CategoryPillStyles
            Render-Apps
        })
        [void]$script:CategoryButtonPanel.Children.Add($btn)
        $script:CategoryButtons[$cName] = $btn
    }
    Update-CategoryPillStyles
}

function Render-InstalledStrip {
    if (-not $script:InstalledAppsBar -or -not $script:InstalledAppsStrip) { return }
    $script:InstalledAppsStrip.Children.Clear()
    $script:StripBadges.Clear()

    if (-not $sync.InstalledApps -or $sync.InstalledApps.Count -eq 0) {
        $script:InstalledAppsBar.Visibility = "Collapsed"
        return
    }

    $installedItems = @()
    $seenIds = @{}
    foreach ($cat in $script:AppCategories) {
        foreach ($app in $cat.Apps) {
            if ($sync.InstalledApps[$app.Id] -eq $true -and -not $seenIds.ContainsKey($app.Id)) {
                $seenIds[$app.Id] = $true
                $installedItems += $app
            }
        }
    }
    $installedItems = @($installedItems)

    if ($installedItems.Count -eq 0) {
        $script:InstalledAppsBar.Visibility = "Collapsed"
        return
    }

    $script:InstalledAppsBar.Visibility = "Visible"
    if ($script:TxtInstalledBarTitle) {
        $script:TxtInstalledBarTitle.Text = Decode-U "\u2705 Sistemde Kurulu Uygulamalar ($($installedItems.Count))"
    }

    foreach ($app in $installedItems) {
        $tile = New-Object System.Windows.Controls.Border
        $tile.Width = 84
        $tile.CornerRadius = New-Object System.Windows.CornerRadius(6)
        $tile.BorderThickness = New-Object System.Windows.Thickness(1)
        $tile.Padding = New-Object System.Windows.Thickness(6, 6, 6, 5)
        $tile.Margin = New-Object System.Windows.Thickness(0, 0, 6, 0)
        $tile.Cursor = [System.Windows.Input.Cursors]::Hand
        $tile.ToolTip = "$($app.Name)`n$($app.Id)`n" + (Decode-U "(Secime eklemek/cikarmak icin tiklayin)")

        if ($script:SelectedApps[$app.Id] -eq $true) {
            Set-ThemeRef $tile "Background" "SelectedBg"
            Set-ThemeRef $tile "BorderBrush" "SelectedBorder"
        } else {
            Set-ThemeRef $tile "Background" "CardBg"
            Set-ThemeRef $tile "BorderBrush" "SuccessBorder"
        }

        $sp = New-Object System.Windows.Controls.StackPanel
        $sp.HorizontalAlignment = "Center"

        $iconHost = New-Object System.Windows.Controls.Grid
        $iconHost.Width = 28
        $iconHost.Height = 28
        $iconHost.HorizontalAlignment = "Center"
        $iconHost.Margin = New-Object System.Windows.Thickness(0, 0, 0, 4)

        $fbBorder = New-Object System.Windows.Controls.Border
        Set-ThemeRef $fbBorder "Background" "HoverBg"
        Set-ThemeRef $fbBorder "BorderBrush" "SuccessBorder"
        $fbBorder.BorderThickness = New-Object System.Windows.Thickness(1)
        $fbBorder.CornerRadius = New-Object System.Windows.CornerRadius(6)

        $cleanName = $app.Name.TrimStart('.')
        $initChar = if ($cleanName.Length -gt 0) { $cleanName.Substring(0, 1).ToUpperInvariant() } else { "A" }
        $fbTxt = New-Object System.Windows.Controls.TextBlock
        $fbTxt.Text = $initChar
        $fbTxt.FontSize = 12
        $fbTxt.FontWeight = "Bold"
        Set-ThemeRef $fbTxt "Foreground" "SuccessFg"
        $fbTxt.HorizontalAlignment = "Center"
        $fbTxt.VerticalAlignment = "Center"
        $fbBorder.Child = $fbTxt
        [void]$iconHost.Children.Add($fbBorder)

        if ($app.PSObject.Properties["Icon"] -and -not [string]::IsNullOrWhiteSpace($app.Icon)) {
            $img = New-Object System.Windows.Controls.Image
            $img.Width = 24
            $img.Height = 24
            $img.Stretch = [System.Windows.Media.Stretch]::Uniform
            $img.HorizontalAlignment = "Center"
            $img.VerticalAlignment = "Center"
            [System.Windows.Media.RenderOptions]::SetBitmapScalingMode($img, [System.Windows.Media.BitmapScalingMode]::HighQuality)
            $img.Visibility = "Collapsed"
            [void]$iconHost.Children.Add($img)

            $cachedSource = Get-CachedImageSource $app.Icon
            if ($cachedSource) {
                $img.Source = $cachedSource
                $img.Visibility = "Visible"
                $fbBorder.Visibility = "Collapsed"
            } else {
                $fbBorder.Visibility = "Visible"
            }
            [void]$script:IconTargets.Add(@{ Url = $app.Icon; Image = $img; Fallback = $fbBorder })
        }
        [void]$sp.Children.Add($iconHost)

        $nameTxt = New-Object System.Windows.Controls.TextBlock
        $nameTxt.Text = $app.Name
        $nameTxt.FontSize = 10
        $nameTxt.FontWeight = "SemiBold"
        $nameTxt.Foreground = Get-Brush "#F4F4F5"
        $nameTxt.HorizontalAlignment = "Center"
        $nameTxt.TextAlignment = "Center"
        $nameTxt.TextTrimming = "CharacterEllipsis"
        $nameTxt.MaxWidth = 74
        [void]$sp.Children.Add($nameTxt)

        $statusTxt = New-Object System.Windows.Controls.TextBlock
        $statusTxt.Text = Decode-U "\u25CF Yuklu"
        $statusTxt.FontSize = 9.5
        $statusTxt.FontWeight = "Bold"
        Set-ThemeRef $statusTxt "Foreground" "SuccessFg"
        $statusTxt.HorizontalAlignment = "Center"
        $statusTxt.Margin = New-Object System.Windows.Thickness(0, 1, 0, 0)
        [void]$sp.Children.Add($statusTxt)

        $tile.Child = $sp
        $tile.Tag = $app.Id
        $tile.Add_MouseLeftButtonUp({
            param($sender, $e)
            $pkgId = [string]$sender.Tag
            $newState = -not ($script:SelectedApps[$pkgId] -eq $true)
            $script:SelectedApps[$pkgId] = $newState
            if ($script:AllAppCheckboxes.ContainsKey($pkgId)) {
                $script:AllAppCheckboxes[$pkgId].IsChecked = $newState
            }
            Update-AllSelectionCounts
        })

        [void]$script:InstalledAppsStrip.Children.Add($tile)
        $script:StripBadges[$app.Id] = $tile
    }
}

# Kart secim/hover durumuna gore arka plan ve kenarligi gunceller.
function Update-AppCardVisual([string]$appId) {
    $card = $script:AppCards[$appId]
    if ($null -eq $card) { return }
    $isSel = ($script:SelectedApps[$appId] -eq $true)
    $isInst = ($sync.InstalledApps -and $sync.InstalledApps[$appId] -eq $true)
    if ($isSel) {
        Set-ThemeRef $card "Background" "SelectedBg"
        Set-ThemeRef $card "BorderBrush" "SelectedBorder"
        $card.BorderThickness = New-Object System.Windows.Thickness(1.5)
    } elseif ($isInst) {
        Set-ThemeRef $card "Background" "CardBg"
        Set-ThemeRef $card "BorderBrush" "SuccessBorder"
        $card.BorderThickness = New-Object System.Windows.Thickness(1)
    } else {
        Set-ThemeRef $card "Background" "CardBg"
        Set-ThemeRef $card "BorderBrush" "BorderBrushColor"
        $card.BorderThickness = New-Object System.Windows.Thickness(1)
    }
}

function Render-Apps {
    # Kartlar bir kez olusturulur; arama/kategori filtreleri artik sadece
    # gorunurlugu degistirir. Boylece her arama tusunda 280 kart yeniden
    # cizilmez ve arayuz donmaz.
    if (-not $script:AppsBuilt) {
        Build-AppsUI
        $script:AppsBuilt = $true
    }
    Apply-AppFilter
}

# Tum uygulama kartlarini bir kez olusturur (filtre uygulamaz).
function Build-AppsUI {
    $script:IconTargets = New-Object System.Collections.ArrayList
    $script:IconRefreshIndex = 0
    Render-InstalledStrip
    $script:MainStackPanel.Children.Clear()
    $script:AppCheckboxes.Clear()
    $script:AllAppCheckboxes.Clear()
    $script:AppCards.Clear()
    $script:AppCardMeta.Clear()
    $script:AppCategoryGroups = @()

    foreach ($cat in $script:AppCategories) {
        $catName = $cat.Category

        $catHeader = New-Object System.Windows.Controls.TextBlock
        $catHeader.Text = $catName
        $catHeader.FontSize = 14
        $catHeader.FontWeight = "Bold"
        Set-ThemeRef $catHeader "Foreground" "AccentColor"
        $catHeader.Margin = New-Object System.Windows.Thickness(6, 18, 6, 8)
        [void]$script:MainStackPanel.Children.Add($catHeader)

        $wrap = New-Object System.Windows.Controls.Primitives.UniformGrid
        $wrap.Columns = 2

        $groupCards = @()
        foreach ($app in $cat.Apps) {
            $isInstalled = ($sync.InstalledApps -and $sync.InstalledApps[$app.Id] -eq $true)

            $card = New-Object System.Windows.Controls.Border
            Set-ThemeRef $card "Background" "CardBg"
            if ($isInstalled) { Set-ThemeRef $card "BorderBrush" "SuccessBorder" }
            else { Set-ThemeRef $card "BorderBrush" "BorderBrushColor" }
            $card.BorderThickness = New-Object System.Windows.Thickness(1)
            $card.CornerRadius = New-Object System.Windows.CornerRadius(8)
            $card.Padding = New-Object System.Windows.Thickness(12, 10, 12, 10)
            $card.Margin = New-Object System.Windows.Thickness(5)
            $card.Cursor = [System.Windows.Input.Cursors]::Hand
            $script:AppCards[$app.Id] = $card
            if ($script:SelectedApps[$app.Id] -eq $true) {
                Set-ThemeRef $card "Background" "SelectedBg"
                Set-ThemeRef $card "BorderBrush" "SelectedBorder"
                $card.BorderThickness = New-Object System.Windows.Thickness(1.5)
            }

            $rowGrid = New-Object System.Windows.Controls.Grid
            $colIcon = New-Object System.Windows.Controls.ColumnDefinition
            $colIcon.Width = New-Object System.Windows.GridLength(54)
            $colText = New-Object System.Windows.Controls.ColumnDefinition
            $colText.Width = New-Object System.Windows.GridLength(1, [System.Windows.GridUnitType]::Star)
            [void]$rowGrid.ColumnDefinitions.Add($colIcon)
            [void]$rowGrid.ColumnDefinitions.Add($colText)

            $leftStack = New-Object System.Windows.Controls.StackPanel
            $leftStack.HorizontalAlignment = "Center"
            $leftStack.VerticalAlignment = "Top"
            $leftStack.Margin = New-Object System.Windows.Thickness(0, 1, 8, 0)

            $iconHost = New-Object System.Windows.Controls.Grid
            $iconHost.Width = 40
            $iconHost.Height = 40
            $iconHost.HorizontalAlignment = "Center"

            $fallbackBorder = New-Object System.Windows.Controls.Border
            Set-ThemeRef $fallbackBorder "Background" "HoverBg"
            if ($isInstalled) { $fallbackBorder.BorderBrush = Get-Brush "#22543D" }
            else { Set-ThemeRef $fallbackBorder "BorderBrush" "BorderBrushColor" }
            $fallbackBorder.BorderThickness = New-Object System.Windows.Thickness(1)
            $fallbackBorder.CornerRadius = New-Object System.Windows.CornerRadius(6)

            $cleanName = $app.Name.TrimStart('.')
            $initialChar = if ($cleanName.Length -gt 0) { $cleanName.Substring(0, 1).ToUpperInvariant() } else { "A" }
            $fallbackText = New-Object System.Windows.Controls.TextBlock
            $fallbackText.Text = $initialChar
            $fallbackText.FontSize = 14
            $fallbackText.FontWeight = "Bold"
            if ($isInstalled) { Set-ThemeRef $fallbackText "Foreground" "SuccessFg" }
            else { Set-ThemeRef $fallbackText "Foreground" "AccentColor" }
            $fallbackText.HorizontalAlignment = "Center"
            $fallbackText.VerticalAlignment = "Center"
            $fallbackBorder.Child = $fallbackText
            [void]$iconHost.Children.Add($fallbackBorder)

            if ($app.PSObject.Properties["Icon"] -and -not [string]::IsNullOrWhiteSpace($app.Icon)) {
                $logoImg = New-Object System.Windows.Controls.Image
                $logoImg.Width = 30
                $logoImg.Height = 30
                $logoImg.Stretch = [System.Windows.Media.Stretch]::Uniform
                $logoImg.HorizontalAlignment = "Center"
                $logoImg.VerticalAlignment = "Center"
                [System.Windows.Media.RenderOptions]::SetBitmapScalingMode($logoImg, [System.Windows.Media.BitmapScalingMode]::HighQuality)
                $logoImg.Visibility = "Collapsed"
                [void]$iconHost.Children.Add($logoImg)

                $cachedSource = Get-CachedImageSource $app.Icon
                if ($cachedSource) {
                    $logoImg.Source = $cachedSource
                    $logoImg.Visibility = "Visible"
                    $fallbackBorder.Visibility = "Collapsed"
                } else {
                    $fallbackBorder.Visibility = "Visible"
                }
                [void]$script:IconTargets.Add(@{ Url = $app.Icon; Image = $logoImg; Fallback = $fallbackBorder })
            }
            [void]$leftStack.Children.Add($iconHost)

            $instBadge = New-Object System.Windows.Controls.Border
            Set-ThemeRef $instBadge "Background" "SuccessBg"
            Set-ThemeRef $instBadge "BorderBrush" "SuccessBorder"
            $instBadge.BorderThickness = New-Object System.Windows.Thickness(1)
            $instBadge.CornerRadius = New-Object System.Windows.CornerRadius(3)
            $instBadge.Padding = New-Object System.Windows.Thickness(3, 1, 3, 1)
            $instBadge.Margin = New-Object System.Windows.Thickness(0, 4, 0, 0)
            $instBadge.HorizontalAlignment = "Center"
            $instBadge.Visibility = if ($isInstalled) { "Visible" } else { "Collapsed" }

            $instBadgeTxt = New-Object System.Windows.Controls.TextBlock
            $instBadgeTxt.Text = Decode-U "Y\u00FCkl\u00FC"
            $instBadgeTxt.FontSize = 9
            $instBadgeTxt.FontWeight = "Bold"
            Set-ThemeRef $instBadgeTxt "Foreground" "SuccessFg"
            $instBadgeTxt.HorizontalAlignment = "Center"
            $instBadge.Child = $instBadgeTxt
            [void]$leftStack.Children.Add($instBadge)

            [System.Windows.Controls.Grid]::SetColumn($leftStack, 0)
            [void]$rowGrid.Children.Add($leftStack)

            # Sag Metin ve CheckBox Alani
            $sp = New-Object System.Windows.Controls.StackPanel
            [System.Windows.Controls.Grid]::SetColumn($sp, 1)

            $cb = New-Object System.Windows.Controls.CheckBox
            $cb.Tag = $app.Id
            $cb.IsChecked = ($script:SelectedApps[$app.Id] -eq $true)
            if ($isInstalled) { Set-ThemeRef $cb "Foreground" "SuccessFg" }
            else { $cb.Foreground = Get-Brush "#F4F4F5" }
            $cb.FontWeight = "SemiBold"
            $cb.FontSize = 13
            $cb.Content = $app.Name

            $cb.Add_Checked({
                param($s, $e)
                $script:SelectedApps[[string]$s.Tag] = $true
                Update-AppCardVisual ([string]$s.Tag)
                Update-AllSelectionCounts
            })
            $cb.Add_Unchecked({
                param($s, $e)
                $script:SelectedApps[[string]$s.Tag] = $false
                Update-AppCardVisual ([string]$s.Tag)
                Update-AllSelectionCounts
            })

            $descBlock = New-Object System.Windows.Controls.TextBlock
            $descBlock.Text = $app.Description
            $descBlock.FontSize = 11
            Set-ThemeRef $descBlock "Foreground" "TextMuted"
            $descBlock.TextWrapping = "Wrap"
            $descBlock.Margin = New-Object System.Windows.Thickness(22, 2, 0, 0)

            $idBlock = New-Object System.Windows.Controls.TextBlock
            $idBlock.Text = $app.Id
            $idBlock.FontSize = 10
            Set-ThemeRef $idBlock "Foreground" "TextDim"
            $idBlock.Margin = New-Object System.Windows.Thickness(22, 2, 0, 0)

            [void]$sp.Children.Add($cb)
            [void]$sp.Children.Add($descBlock)
            [void]$sp.Children.Add($idBlock)
            [void]$rowGrid.Children.Add($sp)

            $card.Child = $rowGrid
            $card.Tag = $cb

            $card.Add_MouseLeftButtonUp({
                param($sender, $e)
                if ($e.OriginalSource -isnot [System.Windows.Controls.Primitives.ToggleButton]) {
                    $innerCb = $sender.Tag
                    if ($innerCb) {
                        $innerCb.IsChecked = -not $innerCb.IsChecked
                    }
                }
            })

            # Hover: yumusak yukselme/parlama hissi (arka plan + kenar rengi)
            $card.Add_MouseEnter({
                param($sender, $e)
                $cid = [string]$sender.Tag.Tag
                if ($script:SelectedApps[$cid] -ne $true) {
                    Set-ThemeRef $sender "Background" "HoverBg"
                    Set-ThemeRef $sender "BorderBrush" "AccentColor"
                }
            })
            $card.Add_MouseLeave({
                param($sender, $e)
                Update-AppCardVisual ([string]$sender.Tag.Tag)
            })

            [void]$wrap.Children.Add($card)
            $script:AllAppCheckboxes[$app.Id] = $cb
            $script:AppCardMeta[$app.Id] = @{
                Badge          = $instBadge
                Cb             = $cb
                FallbackBorder = $fallbackBorder
                FallbackText   = $fallbackText
            }
            $groupCards += @{ App = $app; Card = $card }
        }
        [void]$script:MainStackPanel.Children.Add($wrap)
        $script:AppCategoryGroups += @{
            Name   = $catName
            Header = $catHeader
            Wrap   = $wrap
            Cards  = $groupCards
        }
    }
}

# Kategori + arama filtresini sadece gorunurluk uzerinden uygular (hizli).
function Apply-AppFilter {
    $query = ""
    if ($script:TxtSearch) { $query = $script:TxtSearch.Text.Trim().ToLowerInvariant() }
    $script:AppCheckboxes.Clear()
    $active = $script:ActiveCategory

    foreach ($group in $script:AppCategoryGroups) {
        $catName = $group.Name
        $catVisible = ($active -eq "ALL" -or $active -eq "INSTALLED" -or $active -eq $catName)
        $shown = 0
        foreach ($entry in $group.Cards) {
            $app = $entry.App
            $card = $entry.Card
            $visible = $catVisible
            if ($visible -and $active -eq "INSTALLED" -and (-not $sync.InstalledApps -or $sync.InstalledApps[$app.Id] -ne $true)) {
                $visible = $false
            }
            if ($visible -and -not [string]::IsNullOrEmpty($query)) {
                $visible = ($app.Name.ToLowerInvariant().Contains($query) -or
                            $app.Id.ToLowerInvariant().Contains($query) -or
                            $app.Description.ToLowerInvariant().Contains($query))
            }
            $card.Visibility = if ($visible) { "Visible" } else { "Collapsed" }
            if ($visible) {
                $shown++
                $script:AppCheckboxes[$app.Id] = $script:AllAppCheckboxes[$app.Id]
            }
        }
        $group.Header.Text = "$catName ($shown)"
        $group.Header.Visibility = if ($shown -gt 0) { "Visible" } else { "Collapsed" }
        $group.Wrap.Visibility = if ($shown -gt 0) { "Visible" } else { "Collapsed" }
    }
    Update-AllSelectionCounts
}

# Kurulu durumu degisen kartlarin rozet/renklerini yeniden olusturmadan gunceller.
function Update-InstalledCardVisuals {
    foreach ($id in @($script:AppCards.Keys)) {
        Update-AppCardVisual $id
        $meta = $script:AppCardMeta[$id]
        if (-not $meta) { continue }
        $isInst = ($sync.InstalledApps -and $sync.InstalledApps[$id] -eq $true)
        if ($meta.Badge) { $meta.Badge.Visibility = if ($isInst) { "Visible" } else { "Collapsed" } }
        if ($isInst) {
            Set-ThemeRef $meta.Cb "Foreground" "SuccessFg"
            $meta.FallbackBorder.BorderBrush = Get-Brush "#22543D"
            Set-ThemeRef $meta.FallbackText "Foreground" "SuccessFg"
        } else {
            $meta.Cb.Foreground = Get-Brush "#F4F4F5"
            Set-ThemeRef $meta.FallbackBorder "BorderBrush" "BorderBrushColor"
            Set-ThemeRef $meta.FallbackText "Foreground" "AccentColor"
        }
    }
}

# Arka plan Runspace'ten yeniden cizim istegini guvenli sekilde iletmek icin bayrak.
# (ScriptBlock'i baska runspace icinden Dispatcher'a cagirmak kilitlenmeye yol acabilir.)
$sync.RenderRequested = $false

# Ikonlari tek seferde degil, kucuk partiler halinde guncelle (UI donmasini engeller).
function Update-RenderedIcons([int]$BatchSize = 20) {
    $targets = $script:IconTargets
    if ($null -eq $targets -or $script:IconRefreshIndex -ge $targets.Count) { return $true }
    $end = [Math]::Min($script:IconRefreshIndex + $BatchSize, $targets.Count)
    for ($i = $script:IconRefreshIndex; $i -lt $end; $i++) {
        $t = $targets[$i]
        if ($null -eq $t) { continue }
        if ($null -ne $t.Image.Source) { continue }
        $src = Get-CachedImageSource $t.Url
        if ($src) {
            $t.Image.Source = $src
            $t.Image.Visibility = "Visible"
            $t.Fallback.Visibility = "Collapsed"
        }
    }
    $script:IconRefreshIndex = $end
    return ($script:IconRefreshIndex -ge $targets.Count)
}

$script:IconRefreshIndex = 0
$script:IconRefreshTimer = New-Object System.Windows.Threading.DispatcherTimer
$script:IconRefreshTimer.Interval = [TimeSpan]::FromMilliseconds(100)
$script:IconRefreshTimer.Add_Tick({
    # Arka plan runspace'lerinden gelen log/status mesajlarini UI thread'inde uygula.
    $drain = 0
    while ($sync.UiQueue.Count -gt 0 -and $drain -lt 60) {
        $msg = $sync.UiQueue.Dequeue()
        $drain++
        if ($null -eq $msg) { continue }
        if ($msg.Kind -eq "log") {
            Add-UiLogLine ([string]$msg.Text)
        } else {
            if ($script:TxtStatus) {
                $script:TxtStatus.Text = [string]$msg.Text
                try { $script:TxtStatus.Foreground = Get-Brush (Get-LogLineColor ([string]$msg.Text)) } catch { }
            }
            if ($null -ne $msg.Progress -and [double]$msg.Progress -ge 0 -and $script:ProgressBarMain) {
                $script:ProgressBarMain.Value = [double]$msg.Progress
            }
        }
    }

    if ($sync.RenderRequested) {
        $sync.RenderRequested = $false
        # Arka plan taramasi listeyi yenilerken kullanicinin kaydirma konumunu koru.
        $refreshOffset = Get-PanelScrollOffset $script:MainStackPanel
        try { Update-InstalledCardVisuals } catch {}
        try { Render-InstalledStrip } catch {}
        Render-Apps
        $refreshSv = Find-PanelScrollViewer $script:MainStackPanel
        if ($refreshSv -and $refreshOffset -gt 0) {
            $refreshSv.UpdateLayout()
            $refreshSv.ScrollToVerticalOffset($refreshOffset)
        }
        return
    }
    if (-not $sync.IconDownloadsReady) { return }
    if ($script:IconRefreshIndex -lt $script:IconTargets.Count) {
        [void](Update-RenderedIcons 20)
    }
})
$script:IconRefreshTimer.Start()

$script:SearchDebounceTimer = New-Object System.Windows.Threading.DispatcherTimer
$script:SearchDebounceTimer.Interval = [TimeSpan]::FromMilliseconds(250)
$script:SearchDebounceTimer.Add_Tick({
    $script:SearchDebounceTimer.Stop()
    Render-Apps
})
$script:TxtSearch.Add_TextChanged({
    $script:SearchDebounceTimer.Stop()
    $script:SearchDebounceTimer.Start()
})
$script:BtnClearSearch.Add_Click({
    # Bu dugme arama kutusunun yaninda duruyor; kullanici buradan hem aramayi
    # hem de secili uygulamalari temizleyebilmeli.
    $hadSearch = ($script:TxtSearch.Text.Length -gt 0)
    $hadSelection = $false
    foreach ($id in @($script:SelectedApps.Keys)) {
        if ($script:SelectedApps[$id] -eq $true) { $hadSelection = $true; break }
    }

    $script:TxtSearch.Text = ""
    if ($hadSelection) {
        foreach ($cb in $script:AllAppCheckboxes.Values) {
            if ($cb.IsChecked -eq $true) { $cb.IsChecked = $false }
        }
        $script:SelectedApps.Clear()
        $script:ActiveAppPresetIds = @()
        Update-AllSelectionCounts
    }

    $script:SearchDebounceTimer.Stop()
    Render-Apps

    if ($hadSelection -and $hadSearch) {
        Write-UiLog (Decode-U "[i] Arama ve secili uygulamalar temizlendi.")
    } elseif ($hadSelection) {
        Write-UiLog (Decode-U "[i] Secili uygulamalar temizlendi.")
    } elseif ($hadSearch) {
        Write-UiLog (Decode-U "[i] Arama temizlendi.")
    }
})

# Ctrl+F: uygulama sekmesine gec ve arama kutusuna odaklan.
function Focus-AppSearch {
    try {
        if ($script:ActiveTab -ne "Apps") { Switch-Tab "Apps" }
        [void]$script:TxtSearch.Focus()
        $script:TxtSearch.SelectAll()
    } catch {}
}

function Add-AppSearchShortcut {
    if (-not $script:window) { return }
    $script:window.Add_PreviewKeyDown({
        param($s, $e)
        if ($e.Key -eq [System.Windows.Input.Key]::F -and
            ([System.Windows.Input.Keyboard]::Modifiers -band [System.Windows.Input.ModifierKeys]::Control)) {
            Focus-AppSearch
            $e.Handled = $true
        }
    })
}

# --- PRESET SECIM FONKSIYONU (PROFILLER ARASI GECISTE OTOMATIK DEGISIR) ---
function Select-AppPreset([string[]]$ids, [string]$presetTitle) {
    # Yeni profilin kimliklerini coz ve tekillestir.
    $newIds = @()
    foreach ($rawId in $ids) {
        $rid = Resolve-WingetId $rawId
        if (-not [string]::IsNullOrWhiteSpace($rid)) { $newIds += $rid }
    }
    $newIds = @($newIds | Select-Object -Unique)
    $newSet = @{}
    foreach ($id in $newIds) { $newSet[$id] = $true }

    # Onceki profilin ekledigi, yeni profilde olmayan secimleri kaldir.
    $removed = 0
    foreach ($oldId in @($script:ActiveAppPresetIds)) {
        if ($newSet.ContainsKey($oldId)) { continue }
        if ($script:SelectedApps[$oldId] -eq $true) { $removed++ }
        $script:SelectedApps[$oldId] = $false
        if ($script:AllAppCheckboxes.ContainsKey($oldId)) {
            $script:AllAppCheckboxes[$oldId].IsChecked = $false
        }
    }

    # Yeni profilin uygulamalarini sec (manuel secimler korunur).
    $added = 0
    foreach ($id in $newIds) {
        if ($script:SelectedApps[$id] -ne $true) { $added++ }
        $script:SelectedApps[$id] = $true
        if ($script:AllAppCheckboxes.ContainsKey($id)) {
            $script:AllAppCheckboxes[$id].IsChecked = $true
        }
    }
    $script:ActiveAppPresetIds = $newIds
    Update-AllSelectionCounts
    Switch-Tab "Apps"
    Write-UiLog (Decode-U "[+] $presetTitle uygulandi (+$added eklendi, -$removed cikarildi; manuel secimler korundu).")
}

$script:BtnPresetUmut.Add_Click({
    Select-AppPreset @(
        "TheBrowserCompany.Arc", "Brave.Brave", "Discord.Discord", "Valve.Steam",
        "EpicGames.EpicGamesLauncher", "ElectronicArts.EADesktop", "SteelSeries.GG",
        "PrismLauncher.PrismLauncher", "VideoLAN.VLC", "OBSProject.OBSStudio",
        "Spotify.Spotify", "Microsoft.VisualStudioCode", "Git.Git", "7zip.7zip",
        "RARLab.WinRAR", "voidtools.Everything", "Microsoft.PowerToys",
        "Google.Drive", "AnyDeskSoftwareGmbH.AnyDesk", "TechPowerUp.NVCleanstall",
        "WinsiderSS.SystemInformer", "AntibodySoftware.WizTree"
    ) (Decode-U "Umut Ozel Paketi")
})

$script:BtnPresetGamer.Add_Click({
    Select-AppPreset @(
        "TheBrowserCompany.Arc", "Brave.Brave", "Discord.Discord", "Valve.Steam",
        "EpicGames.EpicGamesLauncher", "ElectronicArts.EADesktop", "GOG.Galaxy",
        "Ubisoft.Connect", "Blizzard.BattleNet", "SteelSeries.GG", "Logitech.GHUB",
        "Guru3D.Afterburner", "Guru3D.RTSS", "Playnite.Playnite", "PrismLauncher.PrismLauncher",
        "Modrinth.ModrinthApp", "VideoLAN.VLC", "OBSProject.OBSStudio", "7zip.7zip",
        "Spotify.Spotify", "TechPowerUp.NVCleanstall", "BitSum.ProcessLasso"
    ) "Oyuncu Paketi"
})

$script:BtnPresetDev.Add_Click({
    Select-AppPreset @(
        "TheBrowserCompany.Arc", "Microsoft.VisualStudioCode", "Anysphere.Cursor",
        "Git.Git", "GitHub.GitHubDesktop", "GitHub.cli", "OpenJS.NodeJS.LTS",
        "Python.Python.3.12", "Microsoft.WindowsTerminal", "Microsoft.PowerShell",
        "Docker.DockerDesktop", "Postman.Postman", "Bruno.Bruno", "Notepad++.Notepad++",
        "JetBrains.Toolbox", "7zip.7zip", "Microsoft.PowerToys", "WinSCP.WinSCP", "PuTTY.PuTTY"
    ) (Decode-U "Gelistirici Paketi")
})

$script:BtnPresetStandard.Add_Click({
    Select-AppPreset @(
        "Google.Chrome", "Brave.Brave", "7zip.7zip", "RARLab.WinRAR", "VideoLAN.VLC",
        "Spotify.Spotify", "Discord.Discord", "voidtools.Everything", "Skillbrains.Lightshot",
        "ShareX.ShareX", "Adobe.Acrobat.Reader.64-bit", "SumatraPDF.SumatraPDF",
        "TheDocumentFoundation.LibreOffice", "Microsoft.VCRedist.2015+.x64", "Microsoft.VCRedist.2015+.x86"
    ) "Standart Kurulum Paketi"
})

$script:BtnClearSelection.Add_Click({
    foreach ($cb in $script:AllAppCheckboxes.Values) { $cb.IsChecked = $false }
    foreach ($cb in $script:TweakCheckboxes.Values) { $cb.IsChecked = $false }
    foreach ($cb in $script:FeatureCheckboxes.Values) { $cb.IsChecked = $false }
    foreach ($cb in $script:BloatCheckboxes.Values) { $cb.IsChecked = $false }
    # Unchecked isleyicileri secimi tekrar false olarak ekledigi icin en sona birak.
    $script:SelectedApps.Clear()
    Update-AllSelectionCounts
    Write-UiLog (Decode-U "[i] Tum menulerdeki secimler temizlendi.")
})

# --- YUKLU UYGULAMALARI TARAMA ---
$script:BtnCheckInstalled.Add_Click({
    Start-BackgroundTask (Decode-U "Yuklu uygulamalar taraniyor...") @{} {
        Refresh-InstalledAppsBg
    }
})

# --- WINGET KUR / KALDIR / GUNCELLE MOTORU ---
function Get-SelectedAppList {
    $list = @()
    foreach ($cat in $script:AppCategories) {
        foreach ($app in $cat.Apps) {
            if ($script:SelectedApps[$app.Id] -eq $true) {
                $list += [pscustomobject]@{ Name = $app.Name; Id = (Resolve-WingetId $app.Id) }
            }
        }
    }
    return $list
}

$script:BtnInstall.Add_Click({
    if (-not (Test-WingetAvailable)) { Write-UiLog $script:WingetMissingMessage; return }
    $targets = @(Get-SelectedAppList)
    if ($targets.Count -eq 0) {
        Write-UiLog (Decode-U "[!] Lutfen kurulacak en az 1 uygulama secin.")
        return
    }
    Start-BackgroundTask (Decode-U "Secilen uygulamalar kuruluyor...") @{ Apps = $targets } {
        param($p)
        $apps = @($p.Apps)
        $total = $apps.Count
        if ($total -eq 0) { Log-Bg "[!] Kurulacak uygulama bulunamadi."; return }
        $idx = 0
        $failCount = 0
        foreach ($item in $apps) {
            $idx++; $pct = [math]::Round(($idx / $total) * 90)
            Status-Bg ("Kuruluyor ($idx/$total): " + $item.Name) $pct
            Log-Bg ("[+] Kuruluyor ($idx/$total): " + $item.Name + " [" + $item.Id + "]")
            if (Test-StoreProductId $item.Id) {
                winget install --id $item.Id --source msstore --silent --accept-package-agreements --accept-source-agreements
            } else {
                winget install --id $item.Id -e --silent --accept-package-agreements --accept-source-agreements
            }
            if ($LASTEXITCODE -eq 0) {
                $sync.InstalledApps[$item.Id] = $true
                Log-Bg ("[OK] Kuruldu: " + $item.Name)
            } else {
                $failCount++
                Log-Bg ("[!] Uyari/Cikis Kodu ($LASTEXITCODE): " + $item.Name)
            }
        }
        if ($failCount -eq 0) {
            Log-Bg "[OK] Secilen tum uygulamalar kuruldu."
        } else {
            Log-Bg ("[!] Kurulum tamamlandi: $($total - $failCount) basarili, $failCount basarisiz.")
        }
        Refresh-InstalledAppsBg
    }
})

$script:BtnUninstall.Add_Click({
    if (-not (Test-WingetAvailable)) { Write-UiLog $script:WingetMissingMessage; return }
    $targets = @(Get-SelectedAppList)
    if ($targets.Count -eq 0) {
        Write-UiLog (Decode-U "[!] Lutfen kaldirilacak en az 1 uygulama secin.")
        return
    }
    Start-BackgroundTask (Decode-U "Secilen uygulamalar kaldiriliyor...") @{ Apps = $targets } {
        param($p)
        $apps = @($p.Apps)
        $total = $apps.Count
        if ($total -eq 0) { Log-Bg "[!] Kaldirilacak uygulama bulunamadi."; return }
        $idx = 0
        $failCount = 0
        foreach ($item in $apps) {
            $idx++; $pct = [math]::Round(($idx / $total) * 90)
            Status-Bg ("Kaldiriliyor ($idx/$total): " + $item.Name) $pct
            Log-Bg ("[-] Kaldiriliyor ($idx/$total): " + $item.Name + " [" + $item.Id + "]")
            if (Test-StoreProductId $item.Id) {
                winget uninstall --id $item.Id --silent --accept-source-agreements
            } else {
                winget uninstall --id $item.Id -e --silent --accept-source-agreements
            }
            if ($LASTEXITCODE -eq 0) {
                $sync.InstalledApps.Remove($item.Id)
                Log-Bg ("[OK] Kaldirildi: " + $item.Name)
            } else {
                $failCount++
                Log-Bg ("[!] Kaldirilamadi (Cikis Kodu: $LASTEXITCODE): " + $item.Name)
            }
        }
        if ($failCount -eq 0) {
            Log-Bg "[OK] Secilen uygulamalar kaldirildi."
        } else {
            Log-Bg ("[!] Kaldirma tamamlandi: $($total - $failCount) basarili, $failCount basarisiz.")
        }
        Refresh-InstalledAppsBg
    }
})

$script:BtnUpgradeSelected.Add_Click({
    if (-not (Test-WingetAvailable)) { Write-UiLog $script:WingetMissingMessage; return }
    $targets = @(Get-SelectedAppList)
    if ($targets.Count -eq 0) {
        Write-UiLog (Decode-U "[!] Lutfen guncellenecek en az 1 uygulama secin.")
        return
    }
    Start-BackgroundTask (Decode-U "Secilen uygulamalar guncelleniyor...") @{ Apps = $targets } {
        param($p)
        $apps = @($p.Apps)
        $total = $apps.Count
        if ($total -eq 0) { Log-Bg "[!] Guncellenecek uygulama bulunamadi."; return }
        $idx = 0
        $okCount = 0
        $uptodateCount = 0
        $failCount = 0
        foreach ($item in $apps) {
            $idx++; $pct = [math]::Round(($idx / $total) * 90)
            Status-Bg ("Guncelleniyor ($idx/$total): " + $item.Name) $pct
            Log-Bg ("[^] Guncelleniyor: " + $item.Name)
            if (Test-StoreProductId $item.Id) {
                winget upgrade --id $item.Id --source msstore --silent --accept-package-agreements --accept-source-agreements
            } else {
                winget upgrade --id $item.Id -e --silent --accept-package-agreements --accept-source-agreements
            }
            $code = $LASTEXITCODE
            if ($code -eq 0) {
                $okCount++
                Log-Bg ("[OK] Guncellendi: " + $item.Name)
            } elseif ($code -eq -1978335189) {
                # 0x8A15002B = APPINSTALLER_CLI_ERROR_UPDATE_NOT_APPLICABLE (zaten guncel)
                $uptodateCount++
                Log-Bg ("[i] Zaten guncel: " + $item.Name)
            } else {
                $failCount++
                Log-Bg ("[!] Guncellenemedi (Cikis Kodu: $code): " + $item.Name)
            }
        }
        if ($failCount -eq 0) {
            Log-Bg ("[OK] Guncelleme tamamlandi: $okCount guncellendi, $uptodateCount zaten guncel.")
        } else {
            Log-Bg ("[!] Guncelleme tamamlandi: $okCount guncellendi, $uptodateCount zaten guncel, $failCount basarisiz.")
        }
        Refresh-InstalledAppsBg
    }
})

$script:BtnUpgradeAll.Add_Click({
    if (-not (Test-WingetAvailable)) { Write-UiLog $script:WingetMissingMessage; return }
    Start-BackgroundTask (Decode-U "Tum sistem uygulamalari guncelleniyor...") @{} {
        Log-Bg "[*] Winget Upgrade --all baslatildi..."
        winget upgrade --all --include-unknown --silent --accept-package-agreements --accept-source-agreements
        $code = $LASTEXITCODE
        if ($code -eq 0) {
            Log-Bg "[OK] Tum guncellemeler tamamlandi."
        } elseif ($code -eq -1978335189) {
            Log-Bg "[i] Guncellenecek uygulama bulunamadi (tum paketler zaten guncel)."
        } else {
            Log-Bg ("[!] Guncelleme tamamlandi ancak bazi paketler basarisiz oldu (Cikis Kodu: $code).")
        }
        Refresh-InstalledAppsBg
    }
})

# --- SEKME 2: TWEAKS RENDER VE UYGULA / GERI AL MOTORU ---
# Kart secim durumuna gore arka plan / kenarlik gunceller (tweak, ozellik, bloatware).
function Update-SelectionCardVisual($card, [bool]$isChecked) {
    if ($null -eq $card) { return }
    if ($isChecked) {
        Set-ThemeRef $card "Background" "SelectedBg"
        Set-ThemeRef $card "BorderBrush" "SelectedBorder"
        $card.BorderThickness = New-Object System.Windows.Thickness(1.5)
    } else {
        Set-ThemeRef $card "Background" "CardBg"
        Set-ThemeRef $card "BorderBrush" "BorderBrushColor"
        $card.BorderThickness = New-Object System.Windows.Thickness(1)
    }
}

function Add-SelectionCardHover($card) {
    $card.Add_MouseEnter({
        param($sender, $e)
        if ($sender.Tag.IsChecked -ne $true) {
            Set-ThemeRef $sender "Background" "HoverBg"
            Set-ThemeRef $sender "BorderBrush" "AccentColor"
        }
    })
    $card.Add_MouseLeave({
        param($sender, $e)
        Update-SelectionCardVisual $sender ($sender.Tag.IsChecked -eq $true)
    })
}

function Render-Tweaks {
    $script:TweaksStackPanel.Children.Clear()
    $script:TweakCheckboxes.Clear()
    $script:TweakCards.Clear()

    foreach ($grp in $script:TweaksData) {
        $grpTitle = New-Object System.Windows.Controls.TextBlock
        $grpTitle.Text = Decode-U $grp.Group
        $grpTitle.FontSize = 14
        $grpTitle.FontWeight = "Bold"
        Set-ThemeRef $grpTitle "Foreground" "AccentColor"
        $grpTitle.Margin = New-Object System.Windows.Thickness(4, 10, 4, 6)
        [void]$script:TweaksStackPanel.Children.Add($grpTitle)

        foreach ($item in $grp.Items) {
            $card = New-Object System.Windows.Controls.Border
            Set-ThemeRef $card "Background" "CardBg"
            Set-ThemeRef $card "BorderBrush" "BorderBrushColor"
            $card.BorderThickness = New-Object System.Windows.Thickness(1)
            $card.CornerRadius = New-Object System.Windows.CornerRadius(6)
            $card.Padding = New-Object System.Windows.Thickness(10, 7, 10, 7)
            $card.Margin = New-Object System.Windows.Thickness(0, 0, 0, 5)
            $card.Cursor = [System.Windows.Input.Cursors]::Hand

            $sp = New-Object System.Windows.Controls.StackPanel

            $cb = New-Object System.Windows.Controls.CheckBox
            $cb.Tag = $item
            $cb.Content = Decode-U $item.Title
            $cb.Foreground = Get-Brush "#F8FAFC"
            $cb.FontWeight = "SemiBold"
            $cb.FontSize = 12.5
            $cb.Add_Checked({
                param($s, $e)
                Update-SelectionCardVisual $script:TweakCards[[string]$s.Tag.Id] $true
                Update-AllSelectionCounts
            })
            $cb.Add_Unchecked({
                param($s, $e)
                Update-SelectionCardVisual $script:TweakCards[[string]$s.Tag.Id] $false
                Update-AllSelectionCounts
            })

            $desc = New-Object System.Windows.Controls.TextBlock
            $desc.Text = Decode-U $item.Desc
            $desc.FontSize = 11
            Set-ThemeRef $desc "Foreground" "TextMuted"
            $desc.TextWrapping = "Wrap"
            $desc.Margin = New-Object System.Windows.Thickness(22, 2, 0, 0)

            [void]$sp.Children.Add($cb)
            [void]$sp.Children.Add($desc)
            $card.Child = $sp
            $card.Tag = $cb

            $card.Add_MouseLeftButtonUp({
                param($sender, $e)
                if ($e.OriginalSource -isnot [System.Windows.Controls.Primitives.ToggleButton]) {
                    $innerCb = $sender.Tag
                    if ($innerCb) { $innerCb.IsChecked = -not $innerCb.IsChecked }
                }
            })

            Add-SelectionCardHover $card
            $script:TweakCards[$item.Id] = $card
            [void]$script:TweaksStackPanel.Children.Add($card)
            $script:TweakCheckboxes[$item.Id] = $cb
        }
    }
}

$script:BtnSelectRecTweaks.Add_Click({
    $added = 0
    foreach ($cb in $script:TweakCheckboxes.Values) {
        if ($cb.Tag.Recommended -eq $true -and $cb.IsChecked -ne $true) {
            $cb.IsChecked = $true
            $added++
        }
    }
    Update-AllSelectionCounts
    if ($added -gt 0) {
        Write-UiLog (Decode-U "[+] Onerilen (Recommended) Tweaks secime eklendi ($added yeni).")
    } else {
        Write-UiLog (Decode-U "[i] Onerilen tweakler zaten secili.")
    }
})

function Select-TweakPreset([string]$presetName) {
    $removed = 0
    $added = 0
    foreach ($cb in $script:TweakCheckboxes.Values) {
        $presets = @($cb.Tag.Preset | Where-Object { -not [string]::IsNullOrWhiteSpace([string]$_) })
        if ($presets.Count -eq 0) { continue }   # Profil disi (manuel) tweak korunur
        $belongs = ($presets -contains $presetName)
        if (-not $belongs) {
            # Onceki profilin ekledigi secimleri kaldir; boylece profiller
            # arasinda gecerken Temizle'ye basmak gerekmez.
            if ($cb.IsChecked -eq $true) { $cb.IsChecked = $false; $removed++ }
        } elseif ($cb.IsChecked -ne $true) {
            $cb.IsChecked = $true
            $added++
        }
    }
    Update-AllSelectionCounts
    Write-UiLog (Decode-U "[+] WinUtil '$presetName' profil secimi uygulandi (+$added eklendi, -$removed cikarildi).")
}

$script:BtnTweakPresetStandard.Add_Click({ Select-TweakPreset "Standard" })
$script:BtnTweakPresetMinimal.Add_Click({ Select-TweakPreset "Minimal" })
$script:BtnTweakPresetAdvanced.Add_Click({ Select-TweakPreset "Advanced" })
$script:BtnClearTweaks.Add_Click({
    foreach ($cb in $script:TweakCheckboxes.Values) { $cb.IsChecked = $false }
    Update-AllSelectionCounts
})

function Confirm-Action([string]$message) {
    $result = [System.Windows.MessageBox]::Show(
        $script:window,
        $message,
        "Petra OmniTool - Onay",
        [System.Windows.MessageBoxButton]::YesNo,
        [System.Windows.MessageBoxImage]::Warning
    )
    return ($result -eq [System.Windows.MessageBoxResult]::Yes)
}

function Invoke-SelectedTweaks([bool]$UndoMode) {
    $selectedIds = @()
    foreach ($id in $script:TweakCheckboxes.Keys) {
        if ($script:TweakCheckboxes[$id].IsChecked -eq $true) {
            $selectedIds += $id
        }
    }
    $selectedIds = @($selectedIds)
    if ($selectedIds.Count -eq 0) {
        Write-UiLog (Decode-U "[!] Lutfen uygulanacak veya geri alinacak en az 1 ayar secin.")
        return
    }
    # Geri yukleme noktasi her zaman ilk adim olsun (diger tweaklerden once).
    $restoreIds = @($selectedIds | Where-Object { $_ -eq "Tweak_RestorePoint" })
    $otherIds   = @($selectedIds | Where-Object { $_ -ne "Tweak_RestorePoint" })
    if ($restoreIds.Count -gt 0 -and $otherIds.Count -gt 0) {
        $selectedIds = @($restoreIds + $otherIds)
    }
    $taskTitle = if ($UndoMode) { "Secili Tweaks geri aliniyor..." } else { "Secili Tweaks uygulaniyor..." }
    Start-BackgroundTask $taskTitle @{ Ids = $selectedIds; Undo = $UndoMode } {
        param($p)
        $undo = $p.Undo
        $ids = @($p.Ids)
        $total = $ids.Count
        if ($total -eq 0) { Log-Bg "[!] Uygulanacak ayar bulunamadi."; return }
        $idx = 0
        $restartExplorer = $false
        foreach ($id in $ids) {
            $idx++
            $pct = [math]::Round(($idx / $total) * 100)
            Status-Bg ("Islem ($idx/$total): $id") $pct
            Log-Bg ($(if ($undo) { "[UNDO] " } else { "[APPLY] " }) + $id)

            switch ($id) {
                "Tweak_RestorePoint" {
                    if (-not $undo) {
                        Enable-ComputerRestore -Drive "$env:SystemDrive\" -ErrorAction SilentlyContinue
                        Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore" "SystemRestorePointCreationFrequency" "DWord" 0
                        try {
                            Checkpoint-Computer -Description "PetraOmniTool_RestorePoint" -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop
                            Log-Bg "[OK] Geri yukleme noktasi olusturuldu."
                        } catch {
                            Log-Bg ("[!] Geri yukleme noktasi olusturulamadi: " + $_.Exception.Message)
                        }
                    }
                }
                "Tweak_Telemetry" {
                    $val = if ($undo) { 1 } else { 0 }
                    Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" "AllowTelemetry" "DWord" $val
                    Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" "AllowTelemetry" "DWord" $val
                    Set-RegSafe "HKCU:\Software\Microsoft\Siuf\Rules" "NumberOfSIUFInPeriod" "DWord" $(if ($undo) { "<RemoveEntry>" } else { 0 })
                    if ($undo) {
                        Set-Service -Name "DiagTrack" -StartupType Automatic -ErrorAction SilentlyContinue
                        [Environment]::SetEnvironmentVariable("POWERSHELL_TELEMETRY_OPTOUT", $null, "Machine")
                    } else {
                        Stop-Service -Name "DiagTrack" -Force -ErrorAction SilentlyContinue
                        Set-Service -Name "DiagTrack" -StartupType Disabled -ErrorAction SilentlyContinue
                        Stop-Service -Name "dmwappushservice" -Force -ErrorAction SilentlyContinue
                        Set-Service -Name "dmwappushservice" -StartupType Disabled -ErrorAction SilentlyContinue
                        [Environment]::SetEnvironmentVariable("POWERSHELL_TELEMETRY_OPTOUT", "1", "Machine")
                    }
                }
                "Tweak_ActivityHistory" {
                    $val = if ($undo) { 1 } else { 0 }
                    Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "EnableActivityFeed" "DWord" $val
                    Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "PublishUserActivities" "DWord" $val
                    Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "UploadUserActivities" "DWord" $val
                }
                "Tweak_Location" {
                    $val = if ($undo) { "Allow" } else { "Deny" }
                    Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" "Value" "String" $val
                    Set-Service -Name "lfsvc" -StartupType $(if ($undo) { "Manual" } else { "Disabled" }) -ErrorAction SilentlyContinue
                }
                "Tweak_AdvertisingId" {
                    $val = if ($undo) { 1 } else { 0 }
                    Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" "Enabled" "DWord" $val
                    Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy" "TailoredExperiencesWithDiagnosticDataEnabled" "DWord" $val
                }
                "Tweak_BingSearch" {
                    $val = if ($undo) { 0 } else { 1 }
                    Set-RegSafe "HKCU:\Software\Policies\Microsoft\Windows\Explorer" "DisableSearchBoxSuggestions" "DWord" $val
                    Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" "BingSearchEnabled" "DWord" $(if ($undo) { 1 } else { 0 })
                }
                "Tweak_ConsumerFeatures" {
                    $val = if ($undo) { 0 } else { 1 }
                    Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" "DisableWindowsConsumerFeatures" "DWord" $val
                    Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "RotatingLockScreenOverlayEnabled" "DWord" $(if ($undo) { 1 } else { 0 })
                    Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SubscribedContent-338387Enabled" "DWord" $(if ($undo) { 1 } else { 0 })
                }
                "Tweak_ErrorReporting" {
                    $val = if ($undo) { 0 } else { 1 }
                    Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting" "Disabled" "DWord" $val
                    Set-Service -Name "WerSvc" -StartupType $(if ($undo) { "Manual" } else { "Disabled" }) -ErrorAction SilentlyContinue
                }
                "Tweak_DeliveryOpt" {
                    $val = if ($undo) { 1 } else { 0 }
                    Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" "DODownloadMode" "DWord" $val
                    Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" "DODownloadMode" "DWord" $val
                }
                "Tweak_WPBT" {
                    $val = if ($undo) { 0 } else { 1 }
                    Set-RegSafe "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" "DisableWpbtExecution" "DWord" $val
                }
                "Tweak_DeviceMetadata" {
                    $val = if ($undo) { 0 } else { 1 }
                    Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Metadata" "PreventDeviceMetadataFromNetwork" "DWord" $val
                }
                "Tweak_StoreSearch" {
                    $val = if ($undo) { 1 } else { 0 }
                    Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SilentInstalledAppsEnabled" "DWord" $val
                }
                "Tweak_ExplorerAutoDiscovery" {
                    if ($undo) {
                        Set-RegSafe "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags\AllFolders\Shell" "FolderType" "String" "<RemoveEntry>"
                    } else {
                        Set-RegSafe "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags\AllFolders\Shell" "FolderType" "String" "NotSpecified"
                    }
                }
                "Tweak_EndTaskOnTaskbar" {
                    $val = if ($undo) { 0 } else { 1 }
                    Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings" "TaskbarEndTask" "DWord" $val
                }
                "Tweak_UltimatePerf" {
                    if (-not $undo) {
                        # Duplicatescheme her seferinde yeni bir GUID uretir; etkinlestirmek icin
                        # ciktidan gercek GUID'i oku (sabit High Performance GUID'i kullanma).
                        $dupOut = (powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 2>&1 | Out-String)
                        $guidMatch = [regex]::Match($dupOut, '[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}')
                        if ($guidMatch.Success) {
                            powercfg -setactive $guidMatch.Value | Out-Null
                            Log-Bg ("[OK] Nihai Performans guc plani etkinlestirildi (" + $guidMatch.Value + ").")
                        } else {
                            powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c | Out-Null
                            Log-Bg "[!] Nihai Performans plani olusturulamadi; Yuksek Performans plani etkinlestirildi."
                        }
                    } else {
                        powercfg -setactive 381b4222-f694-41f0-9685-ff5bb260df2e | Out-Null
                        Log-Bg "[UNDO] Dengeli guc planina donuldu."
                    }
                }
                "Tweak_HAGS" {
                    Set-RegSafe "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" "HwSchMode" "DWord" $(if ($undo) { 1 } else { 2 })
                }
                "Tweak_PowerThrottling" {
                    Set-RegSafe "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" "PowerThrottlingOff" "DWord" $(if ($undo) { 0 } else { 1 })
                }
                "Tweak_MouseAccel" {
                    Set-RegSafe "HKCU:\Control Panel\Mouse" "MouseSpeed" "String" $(if ($undo) { "1" } else { "0" })
                    Set-RegSafe "HKCU:\Control Panel\Mouse" "MouseThreshold1" "String" $(if ($undo) { "6" } else { "0" })
                    Set-RegSafe "HKCU:\Control Panel\Mouse" "MouseThreshold2" "String" $(if ($undo) { "10" } else { "0" })
                }
                "Tweak_GameDVR" {
                    Set-RegSafe "HKCU:\System\GameConfigStore" "GameDVR_Enabled" "DWord" $(if ($undo) { 1 } else { 0 })
                    Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" "AllowGameDVR" "DWord" $(if ($undo) { 1 } else { 0 })
                    Set-RegSafe "HKCU:\Software\Microsoft\GameBar" "AutoGameModeEnabled" "DWord" 1
                }
                "Tweak_NetworkThrottling" {
                    Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" "NetworkThrottlingIndex" "DWord" $(if ($undo) { 10 } else { 0xFFFFFFFF })
                }
                "Tweak_SystemResponsiveness" {
                    Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" "SystemResponsiveness" "DWord" $(if ($undo) { 20 } else { 0 })
                    Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" "GPU Priority" "DWord" $(if ($undo) { 2 } else { 8 })
                    Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" "Priority" "DWord" $(if ($undo) { 2 } else { 6 })
                }
                "Tweak_TCPNoDelay" {
                    $ifaces = Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces" -ErrorAction SilentlyContinue
                    foreach ($ifc in $ifaces) {
                        if ($undo) {
                            Set-RegSafe $ifc.PSPath "TcpAckFrequency" "DWord" "<RemoveEntry>"
                            Set-RegSafe $ifc.PSPath "TCPNoDelay" "DWord" "<RemoveEntry>"
                        } else {
                            Set-RegSafe $ifc.PSPath "TcpAckFrequency" "DWord" 1
                            Set-RegSafe $ifc.PSPath "TCPNoDelay" "DWord" 1
                        }
                    }
                }
                "Tweak_GreenEthernet" {
                    $netClasses = Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e972-e325-11ce-bfc1-08002be10318}" -ErrorAction SilentlyContinue
                    foreach ($nc in $netClasses) {
                        if ($nc.PSChildName -match "^\d{4}$") {
                            $v = if ($undo) { "1" } else { "0" }
                            Set-RegSafe $nc.PSPath "EEELinkAdvertisement" "String" $v
                            Set-RegSafe $nc.PSPath "GreenEthernet" "String" $v
                            Set-RegSafe $nc.PSPath "ULPMode" "String" $v
                            Set-RegSafe $nc.PSPath "PnPCapabilities" "DWord" $(if ($undo) { 0 } else { 24 })
                        }
                    }
                }
                "Tweak_Hibernation" {
                    if ($undo) { powercfg -h on | Out-Null } else { powercfg -h off | Out-Null }
                }
                "Tweak_FastStartup" {
                    Set-RegSafe "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" "HiberbootEnabled" "DWord" $(if ($undo) { 1 } else { 0 })
                }
                "Tweak_BgApps" {
                    Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" "GlobalUserDisabled" "DWord" $(if ($undo) { 0 } else { 1 })
                    Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" "LetAppsRunInBackground" "DWord" $(if ($undo) { "<RemoveEntry>" } else { 2 })
                }
                "Tweak_MultiplaneOverlay" {
                    Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows\Dwm" "OverlayTestMode" "DWord" $(if ($undo) { "<RemoveEntry>" } else { 5 })
                }
                "Tweak_VisualFX" {
                    Set-RegSafe "HKCU:\Control Panel\Desktop" "MenuShowDelay" "String" $(if ($undo) { "400" } else { "10" })
                    Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "TaskbarAnimations" "DWord" $(if ($undo) { 1 } else { 0 })
                }
                "Tweak_SSDTrim" {
                    # TRIM varsayilan olarak etkindir (DisableDeleteNotify = 0).
                    # Geri alma da TRIM'i kapatmamali; guvenli varsayilan 0'dir.
                    fsutil behavior set DisableDeleteNotify 0 | Out-Null
                    if ($undo) { Log-Bg "[UNDO] SSD TRIM varsayilan (etkin) durumda birakildi." }
                }
                "Tweak_Services" {
                    $svcs = @("MapsBroker", "Fax", "RetailDemo", "WMPNetworkSvc", "RemoteRegistry", "CscService", "StorSvc", "SharedAccess")
                    foreach ($s in $svcs) {
                        Set-Service -Name $s -StartupType $(if ($undo) { "Manual" } else { "Disabled" }) -ErrorAction SilentlyContinue
                    }
                }
                "Tweak_DiskCleanup" {
                    if (-not $undo) {
                        Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
                        Remove-Item -Path "$env:windir\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
                        Remove-Item -Path "$env:windir\Prefetch\*" -Recurse -Force -ErrorAction SilentlyContinue
                    }
                }
                "Tweak_StorageSense" {
                    Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" "01" "DWord" $(if ($undo) { 1 } else { 0 })
                }
                "Tweak_ReservedStorage" {
                    DISM.exe /Online /Set-ReservedStorageState /State:$(if ($undo) { "Enabled" } else { "Disabled" }) | Out-Null
                }
                "Tweak_SvcHostSplitting" {
                    if ($undo) {
                        Set-RegSafe "HKLM:\SYSTEM\CurrentControlSet\Control" "SvcHostSplitThresholdInKB" "DWord" 3670016
                    } else {
                        $ramKb = [double](Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum).Sum / 1KB
                        if ($ramKb -gt 0) {
                            # uint32 sinirina sikistir (cok yuksek RAM'de tasma olmasin).
                            $ramKb = [math]::Min($ramKb, [double][uint32]::MaxValue)
                            Set-RegSafe "HKLM:\SYSTEM\CurrentControlSet\Control" "SvcHostSplitThresholdInKB" "DWord" ([uint32]$ramKb)
                        }
                    }
                }
                "Tweak_BitLocker" {
                    if (-not $undo) {
                        manage-bde -off $env:SystemDrive 2>$null | Out-Null
                    }
                }
                "Tweak_LongPaths" {
                    Set-RegSafe "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" "LongPathsEnabled" "DWord" $(if ($undo) { 0 } else { 1 })
                }
                "Tweak_UTC" {
                    Set-RegSafe "HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation" "RealTimeIsUniversal" "DWord" $(if ($undo) { 0 } else { 1 })
                }
                "Tweak_S0StandbyFix" {
                    Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Power\PowerSettings\f15576e8-98b7-4186-b944-eafa664402d9" "ACSettingIndex" "DWord" $(if ($undo) { 1 } else { 0 })
                    Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Power\PowerSettings\f15576e8-98b7-4186-b944-eafa664402d9" "DCSettingIndex" "DWord" $(if ($undo) { 1 } else { 0 })
                }
                "Tweak_S3Sleep" {
                    Set-RegSafe "HKLM:\SYSTEM\CurrentControlSet\Control\Power" "PlatformAoAcOverride" "DWord" $(if ($undo) { "<RemoveEntry>" } else { 0 })
                }
                "Tweak_ClassicContext" {
                    $clsidRoot = "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}"
                    $clsidPath = "$clsidRoot\InprocServer32"
                    if ($undo) {
                        Remove-Item -Path $clsidRoot -Recurse -Force -ErrorAction SilentlyContinue
                        Log-Bg "[UNDO] Klasik sag tik menusu kaldirildi; Windows 11 menusu kullanilacak."
                    } else {
                        New-Item -Path $clsidPath -Force -ErrorAction SilentlyContinue | Out-Null
                        Set-Item -Path $clsidPath -Value "" -Force -ErrorAction SilentlyContinue
                        if (Test-Path $clsidPath) {
                            Log-Bg "[OK] Klasik sag tik menusu kayit defterine yazildi."
                        } else {
                            Log-Bg "[!] Klasik sag tik menusu kaydi yazilamadi."
                        }
                    }
                    $restartExplorer = $true
                }
                "Tweak_FileExt" {
                    Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "HideFileExt" "DWord" $(if ($undo) { 1 } else { 0 })
                }
                "Tweak_HiddenFiles" {
                    Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "Hidden" "DWord" $(if ($undo) { 2 } else { 1 })
                }
                "Tweak_HideTaskbarJunk" {
                    Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" "SearchboxTaskbarMode" "DWord" $(if ($undo) { 1 } else { 0 })
                    Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "ShowTaskViewButton" "DWord" $(if ($undo) { 1 } else { 0 })
                    # Widgets/Haber akisi kullanici ayarlari (biri engellenirse digeri uygulanir)
                    Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Feeds" "ShellFeedsTaskbarViewMode" "DWord" $(if ($undo) { 1 } else { 2 })
                    Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "TaskbarDa" "DWord" $(if ($undo) { 1 } else { 0 })
                    Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Dsh" "AllowNewsAndInterests" "DWord" $(if ($undo) { 1 } else { 0 })
                }
                "Tweak_RemoveWidgets" {
                    # Widgets'i UCPD korumali kayit defteri degerlerine dokunmadan kaldirir.
                    if ($undo) {
                        if (Test-WingetAvailable) {
                            winget install --id 9MSSGKG348SP --source msstore --accept-package-agreements --accept-source-agreements 2>&1 | Out-Null
                            if ($LASTEXITCODE -eq 0) {
                                Log-Bg "[OK] Widgets paketi (Windows Web Experience Pack) tekrar kuruldu."
                            } else {
                                Log-Bg "[!] Widgets paketi kurulamadi. Microsoft Store'dan 'Windows Web Experience Pack' kurun."
                            }
                        } else {
                            Log-Bg "[!] winget bulunamadi. Widgets paketini Microsoft Store'dan manuel kurun."
                        }
                    } else {
                        $pkgList = @()
                        $provList = @()
                        try {
                            $pkgList = @(Get-AppxPackage -AllUsers -Name "*WebExperience*" -ErrorAction Stop)
                        } catch {
                            try { $pkgList = @(Get-AppxPackage -Name "*WebExperience*" -ErrorAction Stop) } catch { $pkgList = @() }
                        }
                        try {
                            $provList = @(Get-AppxProvisionedPackage -Online -ErrorAction Stop | Where-Object { $_.DisplayName -like "*WebExperience*" })
                        } catch {
                            $provList = @()
                        }
                        if ($pkgList.Count -eq 0 -and $provList.Count -eq 0) {
                            Log-Bg "[i] Widgets paketi (Windows Web Experience Pack) zaten kurulu degil."
                        } elseif (-not $sync.IsAdmin) {
                            Log-Bg "[!] Widgets paketini kaldirmak icin yonetici yetkisi gerekir. Araci yonetici olarak calistirin."
                        } else {
                            $removedAny = $false
                            foreach ($pkg in $pkgList) {
                                try {
                                    Remove-AppxPackage -Package $pkg.PackageFullName -AllUsers -ErrorAction Stop
                                    $removedAny = $true
                                    Log-Bg ("[OK] Kaldirildi: " + $pkg.Name)
                                } catch {
                                    try {
                                        Remove-AppxPackage -Package $pkg.PackageFullName -ErrorAction Stop
                                        $removedAny = $true
                                        Log-Bg ("[OK] Kaldirildi (gecerli kullanici): " + $pkg.Name)
                                    } catch {
                                        Log-Bg ("[!] Widgets paketi kaldirilamadi (" + $pkg.Name + "): " + $_.Exception.Message)
                                    }
                                }
                            }
                            foreach ($prov in $provList) {
                                try {
                                    Remove-AppxProvisionedPackage -Online -PackageName $prov.PackageName -ErrorAction Stop | Out-Null
                                    Log-Bg ("[OK] Yeni kullanicilar icin kurulum engellendi: " + $prov.DisplayName)
                                } catch {
                                    Log-Bg ("[!] Provisioned paket kaldirilamadi: " + $_.Exception.Message)
                                }
                            }
                            if ($removedAny) {
                                Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
                                Log-Bg "[i] Explorer yeniden baslatildi. Widgets dugmesi kalkti."
                            }
                        }
                    }
                }
                "Tweak_DarkMode" {
                    $v = if ($undo) { 1 } else { 0 }
                    Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" "AppsUseLightTheme" "DWord" $v
                    Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" "SystemUsesLightTheme" "DWord" $v
                }
                "Tweak_StickyKeys" {
                    Set-RegSafe "HKCU:\Control Panel\Accessibility\StickyKeys" "Flags" "String" $(if ($undo) { "510" } else { "506" })
                }
                "Tweak_ClassicPhotoViewer" {
                    $exts = @(".bmp", ".dib", ".gif", ".jfif", ".jpe", ".jpeg", ".jpg", ".png", ".tif", ".tiff", ".wdp")
                    foreach ($ext in $exts) {
                        $regPath = "HKLM:\SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities\FileAssociations"
                        if ($undo) {
                            Set-RegSafe $regPath $ext "String" "<RemoveEntry>"
                        } else {
                            Set-RegSafe $regPath $ext "String" "PhotoViewer.FileAssoc.Tiff"
                        }
                    }
                }
                "Tweak_RemoveHomeGallery" {
                    Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "LaunchTo" "DWord" $(if ($undo) { 2 } else { 1 })
                    $galleryClsid = "HKCU:\Software\Classes\CLSID\{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}"
                    $homeClsid    = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{f874310e-b6b7-47dc-bc84-b9e6b38f5903}"
                    Set-RegSafe $galleryClsid "System.IsPinnedToNameSpaceTree" "DWord" $(if ($undo) { 1 } else { 0 })
                    if (-not $undo) {
                        Remove-Item -Path $homeClsid -Recurse -Force -ErrorAction SilentlyContinue
                    } else {
                        # Geri almada Giris (Home) ad alanini yeniden olustur.
                        if (-not (Test-Path $homeClsid)) {
                            New-Item -Path $homeClsid -Force -ErrorAction SilentlyContinue | Out-Null
                            # Varsayilan (ad) degeri "Home" olmadan kabuk ogesi gorunmez.
                            Set-Item -Path $homeClsid -Value "Home" -Force -ErrorAction SilentlyContinue
                            Log-Bg "[UNDO] Giris (Home) ad alani kaydi geri olusturuldu."
                        }
                    }
                }
                "Tweak_TaskbarLeft" {
                    Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "TaskbarAl" "DWord" $(if ($undo) { 1 } else { 0 })
                }
                "Tweak_RevertStartMenu" {
                    $v = if ($undo) { "<RemoveEntry>" } else { 1 }
                    Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" "HideRecommendedSection" "DWord" $v
                    Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "Start_TrackDocs" "DWord" $(if ($undo) { 1 } else { 0 })
                }
                "Tweak_NumLock" {
                    Set-RegSafe "Registry::HKEY_USERS\.DEFAULT\Control Panel\Keyboard" "InitialKeyboardIndicators" "String" $(if ($undo) { "0" } else { "2" })
                }
                "Tweak_DetailedBSoD" {
                    Set-RegSafe "HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl" "DisplayParameters" "DWord" $(if ($undo) { 0 } else { 1 })
                    Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "VerboseStatus" "DWord" $(if ($undo) { 0 } else { 1 })
                }
                "Tweak_BatteryPct" {
                    Set-RegSafe "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "ShowBatteryPercentage" "DWord" $(if ($undo) { 0 } else { 1 })
                    Set-RegSafe "HKCU:\Control Panel\Accessibility" "DynamicScrollbars" "DWord" $(if ($undo) { 1 } else { 0 })
                }
                "Tweak_HideSettingsHome" {
                    Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" "SettingsPageVisibility" "String" $(if ($undo) { "<RemoveEntry>" } else { "hide:home" })
                    Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "DisableAcrylicBackgroundOnLogon" "DWord" $(if ($undo) { 0 } else { 1 })
                }
                "Tweak_DeepOneDrive" {
                    if ($undo) {
                        winget install --id Microsoft.OneDrive -e --silent --accept-package-agreements --accept-source-agreements
                        Set-RegSafe "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" "System.IsPinnedToNameSpaceTree" "DWord" 1
                        Set-RegSafe "HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" "System.IsPinnedToNameSpaceTree" "DWord" 1
                    } else {
                        Stop-Process -Name "OneDrive" -Force -ErrorAction SilentlyContinue
                        $od = "$env:SystemRoot\SysWOW64\OneDriveSetup.exe"
                        if (!(Test-Path $od)) { $od = "$env:SystemRoot\System32\OneDriveSetup.exe" }
                        if (Test-Path $od) { Start-Process $od -ArgumentList "/uninstall" -Wait -NoNewWindow }
                        Set-RegSafe "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" "System.IsPinnedToNameSpaceTree" "DWord" 0
                        Set-RegSafe "HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" "System.IsPinnedToNameSpaceTree" "DWord" 0
                    }
                }
                "Tweak_DisableCopilotAI" {
                    Set-RegSafe "HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot" "TurnOffWindowsCopilot" "DWord" $(if ($undo) { 0 } else { 1 })
                    Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" "TurnOffWindowsCopilot" "DWord" $(if ($undo) { 0 } else { 1 })
                    Set-RegSafe "HKCU:\Software\Policies\Microsoft\Windows\WindowsAI" "DisableAIDataAnalysis" "DWord" $(if ($undo) { 0 } else { 1 })
                    Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" "DisableAIDataAnalysis" "DWord" $(if ($undo) { 0 } else { 1 })
                }
                "Tweak_EdgeDebloat" {
                    $v = if ($undo) { 1 } else { 0 }
                    Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Edge" "BackgroundModeEnabled" "DWord" $v
                    Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Edge" "StartupBoostEnabled" "DWord" $v
                    Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Edge" "HubsSidebarEnabled" "DWord" $v
                    Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Edge" "EdgeShoppingAssistantEnabled" "DWord" $v
                    Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Edge" "ShowMicrosoftRewards" "DWord" $v
                    Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Edge" "PersonalizationReportingEnabled" "DWord" $v
                }
                "Tweak_RemoveEdge" {
                    if ($undo) {
                        winget install --id Microsoft.Edge -e --silent --accept-package-agreements --accept-source-agreements
                    } else {
                        Set-RegSafe "HKLM:\SOFTWARE\WOW6432Node\Microsoft\EdgeUpdateDev" "AllowUninstall" "DWord" 1
                        $edgeSetups = Get-ChildItem "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\*\Installer\setup.exe" -ErrorAction SilentlyContinue
                        foreach ($es in $edgeSetups) {
                            Start-Process $es.FullName -ArgumentList "--uninstall --system-level --verbose-logging --force-uninstall" -Wait -NoNewWindow
                        }
                    }
                }
                "Tweak_BraveDebloat" {
                    $v = if ($undo) { 0 } else { 1 }
                    Set-RegSafe "HKLM:\SOFTWARE\Policies\BraveSoftware\Brave" "BraveRewardsDisabled" "DWord" $v
                    Set-RegSafe "HKLM:\SOFTWARE\Policies\BraveSoftware\Brave" "BraveWalletDisabled" "DWord" $v
                    Set-RegSafe "HKLM:\SOFTWARE\Policies\BraveSoftware\Brave" "BraveVPNDisabled" "DWord" $v
                    Set-RegSafe "HKLM:\SOFTWARE\Policies\BraveSoftware\Brave" "BraveAIChatEnabled" "DWord" $(if ($undo) { 1 } else { 0 })
                }
                "Tweak_PeripheralBlock" {
                    Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching" "SearchOrderConfig" "DWord" $(if ($undo) { 1 } else { 0 })
                }
                "Tweak_BlockAdobeNet" {
                    $hostsPath = "$env:SystemRoot\System32\drivers\etc\hosts"
                    if (Test-Path $hostsPath) {
                        $content = Get-Content $hostsPath -ErrorAction SilentlyContinue
                        $clean = $content | Where-Object { $_ -notmatch "adobe\.io|adobestats\.io" }
                        if (-not $undo) {
                            $clean += "0.0.0.0 ic.adobe.io"
                            $clean += "0.0.0.0 cc-api-data.adobe.io"
                        }
                        Set-Content -Path $hostsPath -Value $clean -Encoding ASCII -Force -ErrorAction SilentlyContinue
                    }
                }
                "Tweak_IPv4Prefer" {
                    Set-RegSafe "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" "DisabledComponents" "DWord" $(if ($undo) { 0 } else { 32 })
                    netsh interface teredo set state $(if ($undo) { "default" } else { "disabled" }) | Out-Null
                }
                "Tweak_DisableIPv6" {
                    Set-RegSafe "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" "DisabledComponents" "DWord" $(if ($undo) { 0 } else { 255 })
                    if ($undo) {
                        Enable-NetAdapterBinding -Name "*" -ComponentID ms_tcpip6 -ErrorAction SilentlyContinue
                    } else {
                        Disable-NetAdapterBinding -Name "*" -ComponentID ms_tcpip6 -ErrorAction SilentlyContinue
                    }
                }
                "Tweak_DisableNotifications" {
                    $v = if ($undo) { 0 } else { 1 }
                    Set-RegSafe "HKCU:\Software\Policies\Microsoft\Windows\Explorer" "DisableNotificationCenter" "DWord" $v
                }
                "Tweak_NewOutlookBlock" {
                    Set-RegSafe "HKCU:\Software\Microsoft\Office\16.0\Outlook\Preferences" "UseNewOutlook" "DWord" $(if ($undo) { 1 } else { 0 })
                    Set-RegSafe "HKCU:\Software\Policies\Microsoft\office\16.0\outlook\preferences" "NewOutlookMigrationUserSetting" "DWord" $(if ($undo) { "<RemoveEntry>" } else { 0 })
                }
            }
        }
        if ($restartExplorer) {
            Log-Bg "[i] Degisikligin gorunmesi icin Explorer yeniden baslatiliyor..."
            Start-Sleep -Milliseconds 700
            Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
            Log-Bg "[OK] Explorer yeniden baslatildi; sag tik menusu guncellendi."
        }
        Log-Bg "[i] Secili Tweaks islemleri tamamlandi. Basarisiz adimlar varsa yukaridaki [!] satirlarini kontrol edin."
    }
}

$script:BtnApplyTweaks.Add_Click({
    $count = @($script:TweakCheckboxes.Values | Where-Object { $_.IsChecked -eq $true }).Count
    if ($count -eq 0) { Invoke-SelectedTweaks $false; return }
    $msg = "Secili $count ayar uygulanacak.`n`nBazi ayarlar geri alinamaz veya sistem davranisini kalici olarak degistirebilir. Once 'Sistem Geri Yukleme Noktasi' olusturmaniz onerilir."
    $risky = @()
    foreach ($rid in @("Tweak_BitLocker", "Tweak_RemoveEdge", "Tweak_DeepOneDrive", "Tweak_RemoveHomeGallery")) {
        $rcb = $script:TweakCheckboxes[$rid]
        if ($rcb -and $rcb.IsChecked -eq $true) { $risky += $rid }
    }
    if ($risky.Count -gt 0) {
        $msg += "`n`nDIKKAT: Secili yikici ayarlar tam olarak geri alinamaz:`n - " + ($risky -join "`n - ")
        if ($risky -contains "Tweak_BitLocker") {
            $msg += "`n`nBitLocker'in kapatilmasi surucu sifrelemesini kaldirir ve undo ile geri getirilemez."
        }
    }
    $msg += "`n`nDevam etmek istiyor musunuz?"
    if (Confirm-Action $msg) { Invoke-SelectedTweaks $false }
})
$script:BtnUndoTweaks.Add_Click({
    $count = @($script:TweakCheckboxes.Values | Where-Object { $_.IsChecked -eq $true }).Count
    if ($count -eq 0) { Invoke-SelectedTweaks $true; return }
    $msg = "Secili $count ayarin geri alinmasi denenecek.`n`nNot: Bazi ayarlar (or. Edge/OneDrive kaldirma, BitLocker) tam olarak geri alinamaz.`n`nDevam etmek istiyor musunuz?"
    if (Confirm-Action $msg) { Invoke-SelectedTweaks $true }
})

if (-not ("PetraRegInfo" -as [type])) {
    Add-Type @"
using System;
using System.Text;
using System.Runtime.InteropServices;
public static class PetraRegInfo {
    [DllImport("advapi32.dll")]
    public static extern int RegQueryInfoKey(IntPtr hKey, StringBuilder lpClass, ref uint lpcchClass, IntPtr lpReserved,
        out uint lpcSubKeys, out uint lpcbMaxSubKeyLen, out uint lpcbMaxClassLen, out uint lpcValues,
        out uint lpcbMaxValueNameLen, out uint lpcbMaxValueLen, out uint lpcbSecurityDescriptor, out long lpftLastWriteTime);
}
"@
}

function Get-PetraRegLastWrite([string]$subKey) {
    $key = $null
    try {
        $key = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey($subKey)
        if (-not $key) { return $null }
        $class = New-Object System.Text.StringBuilder 256
        [uint32]$classLen = 256
        [uint32]$subKeys = 0; [uint32]$maxSub = 0; [uint32]$maxClass = 0; [uint32]$values = 0
        [uint32]$maxName = 0; [uint32]$maxVal = 0; [uint32]$sd = 0
        [long]$ft = 0
        $rc = [PetraRegInfo]::RegQueryInfoKey($key.Handle.DangerousGetHandle(), $class, [ref]$classLen, [IntPtr]::Zero,
            [ref]$subKeys, [ref]$maxSub, [ref]$maxClass, [ref]$values, [ref]$maxName, [ref]$maxVal, [ref]$sd, [ref]$ft)
        if ($rc -ne 0 -or $ft -le 0) { return $null }
        return [DateTime]::FromFileTime($ft)
    } catch {
        return $null
    } finally {
        if ($key) { $key.Close() }
    }
}

function Test-ClassicContextEffective {
    $sub = "Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32"
    if (-not (Test-Path "HKCU:\$sub")) { return $false }
    $keyTime = Get-PetraRegLastWrite $sub
    $exp = @(Get-Process explorer -ErrorAction SilentlyContinue) | Select-Object -First 1
    if ($keyTime -and $exp) {
        return ($exp.StartTime -gt $keyTime)
    }
    return $true
}

$script:BtnRevertContextMenu.Add_Click({
    $turnOn = -not (Test-ClassicContextEffective)
    $title = if ($turnOn) { "Klasik sag tik menusu aciliyor..." } else { "Windows 11 sag tik menusu geri getiriliyor..." }
    Start-BackgroundTask (Decode-U $title) @{ TurnOn = $turnOn } {
        param($p)
        $clsidRoot = "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}"
        $clsidPath = "$clsidRoot\InprocServer32"
        if ($p.TurnOn) {
            New-Item -Path $clsidPath -Force -ErrorAction SilentlyContinue | Out-Null
            Set-Item -Path $clsidPath -Value "" -Force -ErrorAction SilentlyContinue
            Log-Bg "[OK] Klasik sag tik menusu acildi."
        } else {
            Remove-Item -Path $clsidRoot -Recurse -Force -ErrorAction SilentlyContinue
            Log-Bg "[OK] Klasik sag tik menusu kapatildi; Windows 11 menusu kullanilacak."
        }
        Log-Bg "[i] Explorer yeniden baslatiliyor..."
        Start-Sleep -Milliseconds 700
        Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
        Log-Bg "[OK] Explorer yeniden baslatildi; sag tik menusu guncellendi."
    }
})

$script:BtnCleanTemp.Add_Click({
    Start-BackgroundTask (Decode-U "Gecici dosyalar ve DNS temizleniyor...") @{} {
        Log-Bg "[*] Temp, Prefetch ve DNS onbellegi temizleniyor..."
        Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "$env:windir\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "$env:windir\Prefetch\*" -Recurse -Force -ErrorAction SilentlyContinue
        ipconfig /flushdns | Out-Null
        Log-Bg "[OK] Disk, Temp ve DNS onbellegi temizlendi."
    }
})

# --- SEKME 3: WINDOWS OZELLIKLERI (DISM) VE DNS ---
function Render-Features {
    $script:FeaturesGrid.Children.Clear()
    $script:FeatureCheckboxes.Clear()
    $script:FeatureCards.Clear()

    foreach ($feat in $script:FeaturesData) {
        $card = New-Object System.Windows.Controls.Border
        Set-ThemeRef $card "Background" "CardBg"
        Set-ThemeRef $card "BorderBrush" "BorderBrushColor"
        $card.BorderThickness = New-Object System.Windows.Thickness(1)
        $card.CornerRadius = New-Object System.Windows.CornerRadius(6)
        $card.Padding = New-Object System.Windows.Thickness(10, 8, 10, 8)
        $card.Margin = New-Object System.Windows.Thickness(4)
        $card.Cursor = [System.Windows.Input.Cursors]::Hand

        $sp = New-Object System.Windows.Controls.StackPanel
        $cb = New-Object System.Windows.Controls.CheckBox
        $cb.Tag = $feat
        $cb.Content = Decode-U $feat.Name
        $cb.Foreground = Get-Brush "#F8FAFC"
        $cb.FontWeight = "SemiBold"
        $cb.FontSize = 12.5
        $cb.Add_Checked({
            param($s, $e)
            Update-SelectionCardVisual $script:FeatureCards[[string]$s.Tag.Feature] $true
            Update-AllSelectionCounts
        })
        $cb.Add_Unchecked({
            param($s, $e)
            Update-SelectionCardVisual $script:FeatureCards[[string]$s.Tag.Feature] $false
            Update-AllSelectionCounts
        })

        $desc = New-Object System.Windows.Controls.TextBlock
        $desc.Text = Decode-U $feat.Desc
        $desc.FontSize = 11
        Set-ThemeRef $desc "Foreground" "TextMuted"
        $desc.TextWrapping = "Wrap"
        $desc.Margin = New-Object System.Windows.Thickness(22, 2, 0, 0)

        [void]$sp.Children.Add($cb)
        [void]$sp.Children.Add($desc)
        $card.Child = $sp
        $card.Tag = $cb

        $card.Add_MouseLeftButtonUp({
            param($sender, $e)
            if ($e.OriginalSource -isnot [System.Windows.Controls.Primitives.ToggleButton]) {
                $innerCb = $sender.Tag
                if ($innerCb) { $innerCb.IsChecked = -not $innerCb.IsChecked }
            }
        })

        Add-SelectionCardHover $card
        $script:FeatureCards[$feat.Feature] = $card
        [void]$script:FeaturesGrid.Children.Add($card)
        $script:FeatureCheckboxes[$feat.Feature] = $cb
    }
}

function Set-QuickDns([string[]]$v4, [string]$label) {
    Start-BackgroundTask "DNS Ayarlaniyor: $label" @{ V4 = $v4; Label = $label } {
        param($p)
        $adapters = @(Get-NetAdapter -ErrorAction SilentlyContinue | Where-Object { $_.Status -eq 'Up' })
        $ok = 0
        $fail = 0
        foreach ($a in $adapters) {
            try {
                if ($p.V4.Count -eq 0) {
                    Set-DnsClientServerAddress -InterfaceIndex $a.ifIndex -ResetServerAddresses -ErrorAction Stop
                } else {
                    Set-DnsClientServerAddress -InterfaceIndex $a.ifIndex -ServerAddresses $p.V4 -ErrorAction Stop
                }
                $ok++
            } catch {
                $fail++
            }
        }
        ipconfig /flushdns | Out-Null
        if ($ok -gt 0) {
            Log-Bg ("[OK] DNS guncellendi: " + $p.Label + " (" + $ok + " adaptor)")
            if ($fail -gt 0) { Log-Bg ("[!] $fail adaptorde DNS ayarlanamadi (yonetici yetkisi gerekebilir).") }
        } else {
            Log-Bg ("[!] DNS guncellenemedi: " + $p.Label + " (etkin adaptor bulunamadi veya yetki yetersiz).")
        }
    }
    if ($script:TxtDnsStatus) { $script:TxtDnsStatus.Text = "Aktif DNS: $label" }
}

$script:BtnDnsCloudflare.Add_Click({ Set-QuickDns @("1.1.1.1", "1.0.0.1") "Cloudflare (1.1.1.1)" })
$script:BtnDnsGoogle.Add_Click({ Set-QuickDns @("8.8.8.8", "8.8.4.4") "Google (8.8.8.8)" })
$script:BtnDnsAdguard.Add_Click({ Set-QuickDns @("94.140.14.14", "94.140.15.15") "AdGuard DNS" })
$script:BtnDnsQuad9.Add_Click({ Set-QuickDns @("9.9.9.9", "149.112.112.112") "Quad9 (9.9.9.9)" })
$script:BtnDnsCloudflareMalware.Add_Click({ Set-QuickDns @("1.1.1.2", "1.0.0.2") "Cloudflare Malware Block" })
$script:BtnDnsOpenDns.Add_Click({ Set-QuickDns @("208.67.222.222", "208.67.220.220") "OpenDNS" })
$script:BtnDnsDhcp.Add_Click({ Set-QuickDns @() "Otomatik (DHCP)" })

$script:BtnCheckFeaturesStatus.Add_Click({
    Start-BackgroundTask "DISM ozellik durumlari kontrol ediliyor..." @{} {
        foreach ($feat in $sync.FeaturesConfig) {
            $st = Get-WindowsOptionalFeature -Online -FeatureName $feat.Feature -ErrorAction SilentlyContinue
            if ($st) {
                Log-Bg ("[DISM] " + $feat.Feature + " -> " + $st.State)
            }
        }
    }
})

$script:BtnApplyFeatures.Add_Click({
    $sel = @()
    foreach ($cb in $script:FeatureCheckboxes.Values) {
        if ($cb.IsChecked -eq $true) { $sel += $cb.Tag }
    }
    $sel = @($sel)
    if ($sel.Count -eq 0) {
        Write-UiLog (Decode-U "[!] Etkinlestirilecek en az 1 Windows ozelligi secin.")
        return
    }
    $msg = "$($sel.Count) Windows ozelligi etkinlestirilecek. Bazi ozellikler icin yeniden baslatma gerekebilir.`n`nDevam etmek istiyor musunuz?"
    if (-not (Confirm-Action $msg)) { return }
    Start-BackgroundTask "Windows Ozellikleri etkinlestiriliyor..." @{ Items = $sel } {
        param($p)
        $okCount = 0
        $failCount = 0
        foreach ($f in $p.Items) {
            Log-Bg ("[+] DISM Etkinlestiriliyor: " + $f.Feature)
            try {
                Enable-WindowsOptionalFeature -Online -FeatureName $f.Feature -All -NoRestart -ErrorAction Stop | Out-Null
                if ($f.ExtraFeatures) {
                    foreach ($ex in $f.ExtraFeatures) {
                        Enable-WindowsOptionalFeature -Online -FeatureName $ex -All -NoRestart -ErrorAction Stop | Out-Null
                    }
                }
                $okCount++
                Log-Bg ("[OK] Etkinlestirildi: " + $f.Feature)
            } catch {
                $failCount++
                Log-Bg ("[!] Etkinlestirilemedi ($($f.Feature)): " + $_.Exception.Message)
            }
        }
        if ($failCount -eq 0) {
            Log-Bg "[OK] Secili Windows Ozellikleri etkinlestirildi."
        } else {
            Log-Bg ("[!] Islem tamamlandi: $okCount basarili, $failCount basarisiz.")
        }
    }
})

$script:BtnDisableFeatures.Add_Click({
    $sel = @()
    foreach ($cb in $script:FeatureCheckboxes.Values) {
        if ($cb.IsChecked -eq $true) { $sel += $cb.Tag }
    }
    $sel = @($sel)
    if ($sel.Count -eq 0) {
        Write-UiLog (Decode-U "[!] Devre disi birakilacak en az 1 Windows ozelligi secin.")
        return
    }
    $msg = "$($sel.Count) Windows ozelligi devre disi birakilacak. Bu islem bazi uygulamalari/ozellikleri kullanilamaz hale getirebilir ve yeniden baslatma gerektirebilir.`n`nDevam etmek istiyor musunuz?"
    if (-not (Confirm-Action $msg)) { return }
    Start-BackgroundTask "Windows Ozellikleri kapatiliyor..." @{ Items = $sel } {
        param($p)
        $okCount = 0
        $failCount = 0
        foreach ($f in $p.Items) {
            Log-Bg ("[-] DISM Devre Disi Birakiliyor: " + $f.Feature)
            try {
                Disable-WindowsOptionalFeature -Online -FeatureName $f.Feature -NoRestart -ErrorAction Stop | Out-Null
                $okCount++
                Log-Bg ("[OK] Devre disi birakildi: " + $f.Feature)
            } catch {
                $failCount++
                Log-Bg ("[!] Devre disi birakilamadi ($($f.Feature)): " + $_.Exception.Message)
            }
        }
        if ($failCount -eq 0) {
            Log-Bg "[OK] Secili Windows Ozellikleri devre disi birakildi."
        } else {
            Log-Bg ("[!] Islem tamamlandi: $okCount basarili, $failCount basarisiz.")
        }
    }
})

$script:BtnDeepOneDrive.Add_Click({
    $msg = "OneDrive sistemden kaldirilacak.`n`nBu islem geri alinamaz; 'OneDrive Geri Yukle' ile yeniden kurulabilir. Dosyalariniz OneDrive klasorunde kalirsa erisim icin yeniden kurulum gerekebilir.`n`nDevam etmek istiyor musunuz?"
    if (-not (Confirm-Action $msg)) { return }
    Start-BackgroundTask "OneDrive kaldiriliyor..." @{} {
        Stop-Process -Name "OneDrive" -Force -ErrorAction SilentlyContinue
        $od = "$env:SystemRoot\SysWOW64\OneDriveSetup.exe"
        if (!(Test-Path $od)) { $od = "$env:SystemRoot\System32\OneDriveSetup.exe" }
        if (Test-Path $od) {
            try {
                Start-Process $od -ArgumentList "/uninstall" -Wait -NoNewWindow -ErrorAction Stop
                Log-Bg "[OK] OneDrive sistemden kaldirildi."
            } catch {
                Log-Bg ("[!] OneDrive kaldirilamadi: " + $_.Exception.Message)
            }
        } else {
            Log-Bg "[!] OneDriveSetup.exe bulunamadi; kaldirma atlandi."
        }
    }
})
$script:BtnRestoreOneDrive.Add_Click({
    Start-BackgroundTask "OneDrive geri yukleniyor..." @{} {
        if (-not (Test-WingetAvailable)) {
            Log-Bg "[!] winget bulunamadi. Microsoft Store'dan 'App Installer' paketini guncelleyin."
            return
        }
        winget install --id Microsoft.OneDrive -e --silent --accept-package-agreements --accept-source-agreements
        if ($LASTEXITCODE -eq 0) {
            Log-Bg "[OK] OneDrive tekrar kuruldu."
        } else {
            Log-Bg ("[!] OneDrive kurulamadi (Cikis Kodu: $LASTEXITCODE).")
        }
    }
})
$script:BtnDisableCopilot.Add_Click({
    Start-BackgroundTask "Copilot kapatiliyor..." @{} {
        Set-RegSafe "HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot" "TurnOffWindowsCopilot" "DWord" 1
        Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" "TurnOffWindowsCopilot" "DWord" 1
        Log-Bg "[OK] Windows Copilot devre disi birakildi."
    }
})
$script:BtnEnableCopilot.Add_Click({
    Start-BackgroundTask "Copilot aciliyor..." @{} {
        Set-RegSafe "HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot" "TurnOffWindowsCopilot" "DWord" "<RemoveEntry>"
        Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" "TurnOffWindowsCopilot" "DWord" "<RemoveEntry>"
        Log-Bg "[OK] Windows Copilot etkinlestirildi."
    }
})
$script:BtnDisableEdgeBg.Add_Click({
    Start-BackgroundTask "Edge arka plan kapatiliyor..." @{} {
        Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Edge" "BackgroundModeEnabled" "DWord" 0
        Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Edge" "StartupBoostEnabled" "DWord" 0
        Log-Bg "[OK] Edge arka plan calismasi kapatildi."
    }
})
$script:BtnEnableEdgeBg.Add_Click({
    Start-BackgroundTask "Edge arka plan varsayilana aliniyor..." @{} {
        Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Edge" "BackgroundModeEnabled" "DWord" "<RemoveEntry>"
        Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Edge" "StartupBoostEnabled" "DWord" "<RemoveEntry>"
        Log-Bg "[OK] Edge arka plan ayarlari varsayilana donduruldu."
    }
})

$script:BtnWinUpdateSecurity.Add_Click({
    Start-BackgroundTask "Windows Update Guvenlik Modu..." @{} {
        Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" "NoAutoUpdate" "DWord" 0
        Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" "DeferFeatureUpdates" "DWord" 1
        Set-RegSafe "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" "DeferFeatureUpdatesPeriodInDays" "DWord" 365
        Log-Bg "[OK] Windows Update yalnizca guvenlik yamalarini alacak sekilde ayarlandi."
    }
})
$script:BtnWinUpdateDisable.Add_Click({
    Start-BackgroundTask "Windows Update Durduruluyor..." @{} {
        Stop-Service -Name "wuauserv" -Force -ErrorAction SilentlyContinue
        Set-Service -Name "wuauserv" -StartupType Disabled -ErrorAction SilentlyContinue
        Log-Bg "[OK] Windows Update servisi devre disi birakildi."
    }
})
$script:BtnWinUpdateDefault.Add_Click({
    Start-BackgroundTask "Windows Update Varsayilana Aliniyor..." @{} {
        Set-Service -Name "wuauserv" -StartupType Manual -ErrorAction SilentlyContinue
        Start-Service -Name "wuauserv" -ErrorAction SilentlyContinue
        Remove-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Recurse -Force -ErrorAction SilentlyContinue
        Log-Bg "[OK] Windows Update varsayilan ayarlara donduruldu."
    }
})

# --- SEKME 4: BLOATWARE RENDER VE KALDIR / GERI YUKLE ---
function Render-Bloatware {
    $script:BloatwareGrid.Children.Clear()
    $script:BloatCheckboxes.Clear()
    $script:BloatCards.Clear()

    foreach ($b in $script:BloatwareData) {
        $card = New-Object System.Windows.Controls.Border
        Set-ThemeRef $card "Background" "CardBg"
        Set-ThemeRef $card "BorderBrush" "BorderBrushColor"
        $card.BorderThickness = New-Object System.Windows.Thickness(1)
        $card.CornerRadius = New-Object System.Windows.CornerRadius(6)
        $card.Padding = New-Object System.Windows.Thickness(10, 8, 10, 8)
        $card.Margin = New-Object System.Windows.Thickness(4)
        $card.Cursor = [System.Windows.Input.Cursors]::Hand

        $sp = New-Object System.Windows.Controls.StackPanel
        $cb = New-Object System.Windows.Controls.CheckBox
        $cb.Tag = $b
        $cb.Content = Decode-U $b.Name
        $cb.IsChecked = $false
        $cb.Foreground = Get-Brush "#F8FAFC"
        $cb.FontWeight = "SemiBold"
        $cb.FontSize = 12.5
        $cb.Add_Checked({
            param($s, $e)
            Update-SelectionCardVisual $script:BloatCards[[string]$s.Tag.Pkg] $true
            Update-AllSelectionCounts
        })
        $cb.Add_Unchecked({
            param($s, $e)
            Update-SelectionCardVisual $script:BloatCards[[string]$s.Tag.Pkg] $false
            Update-AllSelectionCounts
        })

        $pkgTxt = New-Object System.Windows.Controls.TextBlock
        $pkgTxt.Text = $b.Pkg
        $pkgTxt.FontSize = 10.5
        Set-ThemeRef $pkgTxt "Foreground" "TextDim"
        $pkgTxt.Margin = New-Object System.Windows.Thickness(22, 2, 0, 0)

        [void]$sp.Children.Add($cb)
        [void]$sp.Children.Add($pkgTxt)
        $card.Child = $sp
        $card.Tag = $cb

        $card.Add_MouseLeftButtonUp({
            param($sender, $e)
            if ($e.OriginalSource -isnot [System.Windows.Controls.Primitives.ToggleButton]) {
                $innerCb = $sender.Tag
                if ($innerCb) { $innerCb.IsChecked = -not $innerCb.IsChecked }
            }
        })

        Add-SelectionCardHover $card
        $script:BloatCards[$b.Pkg] = $card
        [void]$script:BloatwareGrid.Children.Add($card)
        $script:BloatCheckboxes[$b.Pkg] = $cb
    }
}

$script:BtnSelectDefaultBloat.Add_Click({
    foreach ($cb in $script:BloatCheckboxes.Values) {
        if ($cb.Tag.DefaultCheck -eq $true) { $cb.IsChecked = $true }
    }
    Update-AllSelectionCounts
})
$script:BtnSelectAllBloat.Add_Click({
    foreach ($cb in $script:BloatCheckboxes.Values) { $cb.IsChecked = $true }
    Update-AllSelectionCounts
})
$script:BtnClearBloat.Add_Click({
    foreach ($cb in $script:BloatCheckboxes.Values) { $cb.IsChecked = $false }
    Update-AllSelectionCounts
})

$script:BtnRemoveBloatware.Add_Click({
    $sel = @()
    foreach ($cb in $script:BloatCheckboxes.Values) {
        if ($cb.IsChecked -eq $true) { $sel += $cb.Tag }
    }
    $sel = @($sel)
    if ($sel.Count -eq 0) {
        Write-UiLog (Decode-U "[!] Kaldirilacak en az 1 UWP paketi secin.")
        return
    }
    $msg = "$($sel.Count) UWP paketi tum kullanicilar icin kaldirilacak.`n`nBazi paketler geri kurulabilir, ancak bu islem geri alinamaz. Once 'Sistem Geri Yukleme Noktasi' olusturmaniz onerilir.`n`nDevam etmek istiyor musunuz?"
    if (-not (Confirm-Action $msg)) { return }
    Start-BackgroundTask "Secili Bloatware paketleri kaldiriliyor..." @{ Items = $sel } {
        param($p)
        $okCount = 0
        $absentCount = 0
        $failCount = 0
        foreach ($item in $p.Items) {
            $present = @(Get-AppxPackage -AllUsers $item.Pkg -ErrorAction SilentlyContinue)
            if ($present.Count -eq 0) {
                $absentCount++
                Log-Bg ("[i] Zaten kurulu degil: " + (Decode-Bg $item.Name))
                continue
            }
            Log-Bg ("[-] UWP Kaldiriliyor: " + (Decode-Bg $item.Name))
            Get-AppxPackage -AllUsers $item.Pkg -ErrorAction SilentlyContinue | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
            Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -like $item.Pkg } | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Out-Null
            $remaining = @(Get-AppxPackage -AllUsers $item.Pkg -ErrorAction SilentlyContinue)
            if ($remaining.Count -eq 0) {
                $okCount++
                Log-Bg ("[OK] Kaldirildi: " + (Decode-Bg $item.Name))
            } else {
                $failCount++
                Log-Bg ("[!] Kaldirilamadi veya kismen kaldi: " + (Decode-Bg $item.Name))
            }
        }
        if ($failCount -eq 0) {
            Log-Bg ("[OK] UWP temizligi tamamlandi: $okCount kaldirildi, $absentCount zaten yoktu.")
        } else {
            Log-Bg ("[!] Bloatware temizligi tamamlandi: $okCount kaldirildi, $absentCount zaten yoktu, $failCount basarisiz.")
        }
    }
})

$script:BtnReinstallBloatware.Add_Click({
    $sel = @()
    foreach ($cb in $script:BloatCheckboxes.Values) {
        if ($cb.IsChecked -eq $true -and -not [string]::IsNullOrWhiteSpace($cb.Tag.StoreId)) {
            $sel += $cb.Tag
        }
    }
    $sel = @($sel)
    if ($sel.Count -eq 0) {
        Write-UiLog (Decode-U "[!] Geri yuklenecek StoreId destekli en az 1 paket secin.")
        return
    }
    Start-BackgroundTask "Secili UWP paketleri Microsoft Store uzerinden kuruluyor..." @{ Items = $sel } {
        param($p)
        if (-not (Test-WingetAvailable)) {
            Log-Bg "[!] winget bulunamadi. Microsoft Store'dan 'App Installer' paketini guncelleyin."
            return
        }
        $okCount = 0
        $failCount = 0
        foreach ($item in $p.Items) {
            Log-Bg ("[+] Yeniden Kuruluyor: " + (Decode-Bg $item.Name))
            winget install --id $item.StoreId --source msstore --silent --accept-package-agreements --accept-source-agreements
            if ($LASTEXITCODE -eq 0) {
                $okCount++
                Log-Bg ("[OK] Yeniden kuruldu: " + (Decode-Bg $item.Name))
            } else {
                $failCount++
                Log-Bg ("[!] Yeniden kurulamadi (Cikis Kodu: $LASTEXITCODE): " + (Decode-Bg $item.Name))
            }
        }
        if ($failCount -eq 0) {
            Log-Bg "[OK] Secili UWP paketleri geri yuklendi."
        } else {
            Log-Bg ("[!] Geri yukleme tamamlandi: $okCount basarili, $failCount basarisiz.")
        }
    }
})

# --- SEKME 5: SISTEM ARACLARI, ONARIM & PETRA LISANS ARACI ---
$script:BtnRestorePoint.Add_Click({
    Start-BackgroundTask "Sistem Geri Yukleme Noktasi olusturuluyor..." @{} {
        Enable-ComputerRestore -Drive "$env:SystemDrive\" -ErrorAction SilentlyContinue
        Set-RegSafe "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore" "SystemRestorePointCreationFrequency" "DWord" 0
        try {
            Checkpoint-Computer -Description "PetraOmniTool_ManualRestore" -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop
            Log-Bg "[OK] Sistem Geri Yukleme Noktasi olusturuldu."
        } catch {
            Log-Bg ("[!] Geri yukleme noktasi olusturulamadi: " + $_.Exception.Message)
            Log-Bg "[i] Sistem Korumasi kapali olabilir. 'sysdm.cpl' > Sistem Korumasi'ni acip tekrar deneyin."
        }
    }
})

$script:BtnRunMAS.Add_Click({
    Write-UiLog (Decode-U "[*] Petra Lisans ve Sistem Yonetim Araci baslatiliyor...")
    try {
        $uetCmdPath = Join-Path $env:TEMP "UET_Tool.cmd"
        $rawCmd = if ($sync.MasScript -and $sync.MasScript.Length -gt 100) {
            Decode-U $sync.MasScript
        } else {
            ""
        }
        if ([string]::IsNullOrWhiteSpace($rawCmd)) {
            Write-UiLog (Decode-U "[!] Gomulu lisans araci bulunamadi. Lutfen uygulamayi compile.ps1 ile yeniden derleyin.")
            return
        }
        $normalizedCmd = ($rawCmd -replace "\r?\n", "`r`n").Trim() + "`r`n"
        [System.IO.File]::WriteAllText($uetCmdPath, $normalizedCmd, [System.Text.Encoding]::ASCII)
        Start-Process -FilePath "cmd.exe" -ArgumentList "/c `"`"$uetCmdPath`"`"" -WorkingDirectory $env:TEMP
        Write-UiLog (Decode-U "[OK] Petra lisans araci yeni konsol penceresinde baslatildi.")
    } catch {
        Write-UiLog ("[HATA] Petra lisans araci baslatilamadi: " + $_.Exception.Message)
    }
})

$script:BtnCreateGodMode.Add_Click({
    try {
        $desktop = [Environment]::GetFolderPath("Desktop")
        $godPath = Join-Path $desktop "GodMode.{ED7BA470-8E54-465E-825C-99712043E01C}"
        if (Test-Path -LiteralPath $godPath) {
            Write-UiLog (Decode-U "[i] GodMode klasoru zaten masaustunde mevcut.")
        } else {
            New-Item -Path $godPath -ItemType Directory -Force -ErrorAction Stop | Out-Null
            Write-UiLog (Decode-U "[OK] Masaustunde GodMode klasoru olusturuldu.")
        }
    } catch {
        Write-UiLog (Decode-U ("[!] GodMode klasoru olusturulamadi: " + $_.Exception.Message))
    }
})

$script:BtnRunOOSU.Add_Click({
    Start-BackgroundTask "O&O ShutUp10++ indiriliyor ve baslatiliyor..." @{} {
        $ooPath = Join-Path $env:TEMP "OOSU10.exe"
        try {
            Invoke-WebRequest -Uri "https://dl5.oo-software.com/files/ooshutup10/OOSU10.exe" -OutFile $ooPath -UseBasicParsing -ErrorAction Stop
            if (!(Test-Path $ooPath) -or (Get-Item $ooPath).Length -lt 100KB) { throw "Indirilen dosya dogrulanamadi." }
            Start-Process $ooPath
            Log-Bg "[OK] O&O ShutUp10++ acildi."
        } catch {
            Log-Bg ("[!] O&O ShutUp10++ baslatilamadi: " + $_.Exception.Message)
        }
    }
})

$script:BtnFixSystemCorruption.Add_Click({
    Start-BackgroundTask "DISM ve SFC Sistem Onarimi calisiyor..." @{} {
        Log-Bg "[*] DISM /RestoreHealth baslatildi..."
        DISM.exe /Online /Cleanup-Image /RestoreHealth
        $dismCode = $LASTEXITCODE
        Log-Bg ("[*] DISM tamamlandi (Cikis Kodu: $dismCode).")
        Log-Bg "[*] sfc /scannow baslatildi..."
        sfc /scannow
        $sfcCode = $LASTEXITCODE
        Log-Bg ("[*] SFC tamamlandi (Cikis Kodu: $sfcCode).")
        if ($dismCode -eq 0) {
            Log-Bg "[OK] Sistem dosyalari onarimi tamamlandi."
        } else {
            Log-Bg "[!] DISM hata bildirdi; ayrintilar icin yukaridaki ciktiyi inceleyin."
        }
    }
})

$script:BtnFixWinUpdate.Add_Click({
    Start-BackgroundTask "Windows Update bilesenleri sifirlaniyor..." @{} {
        $svcs = @("bits", "wuauserv", "cryptsvc")
        foreach ($s in $svcs) { Stop-Service -Name $s -Force -ErrorAction SilentlyContinue }
        Remove-Item "$env:SystemRoot\SoftwareDistribution\*" -Recurse -Force -ErrorAction SilentlyContinue
        foreach ($s in $svcs) { Start-Service -Name $s -ErrorAction SilentlyContinue }
        $notRunning = @($svcs | Where-Object { (Get-Service -Name $_ -ErrorAction SilentlyContinue).Status -ne "Running" })
        if ($notRunning.Count -eq 0) {
            Log-Bg "[OK] Windows Update onbellegi ve servisleri sifirlandi."
        } else {
            Log-Bg ("[!] Bazi servisler baslatilamadi: " + ($notRunning -join ", "))
        }
    }
})

$script:BtnFixNetwork.Add_Click({
    Start-BackgroundTask "Ag yigini sifirlaniyor..." @{} {
        ipconfig /release | Out-Null
        ipconfig /flushdns | Out-Null
        ipconfig /renew | Out-Null
        # netsh int ip reset basarili olsa da 1 dondurebilir; ciktiyi de kontrol et.
        $ipOut = (netsh int ip reset 2>&1 | Out-String)
        $ipCode = $LASTEXITCODE
        $ipOk = ($ipCode -eq 0) -or ($ipOut -match 'OK|Tamam|basarili|success')
        netsh winsock reset | Out-Null
        $winsockCode = $LASTEXITCODE
        if ($ipOk -and $winsockCode -eq 0) {
            Log-Bg "[OK] Ag ayarlari, IP ve Winsock sifirlandi. Yeniden baslatma onerilir."
        } else {
            Log-Bg ("[!] Ag sifirlama kismen tamamlandi (IP reset: $ipCode$(if ($ipOk) { ' - basarili' } else { '' }), Winsock reset: $winsockCode).")
        }
    }
})

$script:BtnFixWinget.Add_Click({
    Start-BackgroundTask "Winget kaynaklari onariliyor..." @{} {
        if (-not (Test-WingetAvailable)) {
            Log-Bg "[!] winget bulunamadi. Microsoft Store'dan 'App Installer' paketini guncelleyin."
            return
        }
        winget source reset --force
        $resetCode = $LASTEXITCODE
        winget source update
        $updateCode = $LASTEXITCODE
        if ($resetCode -eq 0 -and $updateCode -eq 0) {
            Log-Bg "[OK] Winget kaynaklari sifirlandi ve guncellendi."
        } else {
            Log-Bg ("[!] Winget kaynak onarimi kismen tamamlandi (reset: $resetCode, update: $updateCode).")
        }
    }
})

$script:BtnFixNTP.Add_Click({
    Start-BackgroundTask "Sistem saati senkronize ediliyor..." @{} {
        Start-Service w32time -ErrorAction SilentlyContinue
        w32tm /resync /force | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Log-Bg "[OK] Windows saat senkronizasyonu tamamlandi."
        } else {
            Log-Bg ("[!] Saat senkronizasyonu basarisiz oldu (Cikis Kodu: $LASTEXITCODE).")
        }
    }
})

$script:BtnRunAutologon.Add_Click({
    Start-BackgroundTask "Sysinternals Autologon indiriliyor..." @{} {
        $alPath = Join-Path $env:TEMP "Autologon64.exe"
        try {
            Invoke-WebRequest -Uri "https://live.sysinternals.com/Autologon64.exe" -OutFile $alPath -UseBasicParsing -ErrorAction Stop
            if (!(Test-Path $alPath) -or (Get-Item $alPath).Length -lt 50KB) { throw "Indirilen dosya dogrulanamadi." }
            Start-Process $alPath
            Log-Bg "[OK] Sysinternals Autologon baslatildi."
        } catch {
            Log-Bg ("[!] Sysinternals Autologon baslatilamadi: " + $_.Exception.Message)
        }
    }
})

$script:BtnEnableOpenSSH.Add_Click({
    Start-BackgroundTask "OpenSSH Sunucusu etkinlestiriliyor..." @{} {
        try {
            Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0 -ErrorAction Stop | Out-Null
        } catch {
            Log-Bg ("[!] OpenSSH yetenegi kurulamadi: " + $_.Exception.Message)
            return
        }
        Set-Service -Name sshd -StartupType Automatic -ErrorAction SilentlyContinue
        Start-Service sshd -ErrorAction SilentlyContinue
        if ((Get-Service -Name sshd -ErrorAction SilentlyContinue).Status -eq "Running") {
            Log-Bg "[OK] OpenSSH Sunucusu etkinlestirildi."
        } else {
            Log-Bg "[!] OpenSSH kuruldu ancak sshd servisi baslatilamadi."
        }
    }
})

$script:BtnEnableRegBackup.Add_Click({
    try {
        $cfgPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Configuration Manager"
        if (-not (Test-Path $cfgPath)) { New-Item -Path $cfgPath -Force -ErrorAction Stop | Out-Null }
        Set-ItemProperty -Path $cfgPath -Name "EnablePeriodicBackup" -Type DWord -Value 1 -Force -ErrorAction Stop
        Write-UiLog "[OK] Otomatik Kayit Defteri Yedeklemesi (RegBack) etkinlestirildi."
    } catch {
        Write-UiLog ("[!] RegBack etkinlestirilemedi: " + $_.Exception.Message)
    }
})

$script:BtnRestartExplorer.Add_Click({
    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
    Write-UiLog "[OK] Windows Gezgini (Explorer.exe) yeniden baslatma komutu gonderildi."
})

$script:BtnEnableF8Boot.Add_Click({
    bcdedit /set `{current`} bootmenupolicy Legacy | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-UiLog "[OK] Klasik F8 Guvenli Mod Onyukleme Menusu etkinlestirildi."
    } else {
        Write-UiLog ("[!] F8 onyukleme menusu etkinlestirilemedi (Cikis Kodu: $LASTEXITCODE).")
    }
})
$script:BtnDisableF8Boot.Add_Click({
    bcdedit /set `{current`} bootmenupolicy Standard | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-UiLog "[OK] Standart Windows Onyukleme Menusu geri yuklendi."
    } else {
        Write-UiLog ("[!] Onyukleme menusu geri yuklenemedi (Cikis Kodu: $LASTEXITCODE).")
    }
})

$script:BtnPanelControl.Add_Click({ Start-Process "control.exe" })
$script:BtnPanelNetwork.Add_Click({ Start-Process "ncpa.cpl" })
$script:BtnPanelSystem.Add_Click({ Start-Process "sysdm.cpl" })
$script:BtnPanelPower.Add_Click({ Start-Process "powercfg.cpl" })
$script:BtnPanelSound.Add_Click({ Start-Process "mmsys.cpl" })
$script:BtnPanelPrograms.Add_Click({ Start-Process "appwiz.cpl" })
$script:BtnPanelComputer.Add_Click({ Start-Process "compmgmt.msc" })
$script:BtnPanelMouse.Add_Click({ Start-Process "main.cpl" })
$script:BtnPanelFirewall.Add_Click({ Start-Process "wf.msc" })
$script:BtnPanelRestore.Add_Click({ Start-Process "rstrui.exe" })
$script:BtnPanelTimedate.Add_Click({ Start-Process "timedate.cpl" })
$script:BtnPanelRegion.Add_Click({ Start-Process "intl.cpl" })

# --- SEKME 6: YEDEKLEME & CONFIG DISA/ICE AKTARIM ---
function Export-PetraConfigToPath([string]$path) {
    $exportObj = @{
        Apps      = @($script:SelectedApps.Keys | Where-Object { $script:SelectedApps[$_] -eq $true })
        Tweaks    = @($script:TweakCheckboxes.Keys | Where-Object { $script:TweakCheckboxes[$_].IsChecked -eq $true })
        Features  = @($script:FeatureCheckboxes.Keys | Where-Object { $script:FeatureCheckboxes[$_].IsChecked -eq $true })
        Bloatware = @($script:BloatCheckboxes.Keys | Where-Object { $script:BloatCheckboxes[$_].IsChecked -eq $true })
    }
    $exportObj | ConvertTo-Json -Depth 5 | Set-Content -Path $path -Encoding UTF8
    return $true
}

function Import-PetraConfigFile([string]$path) {
    try {
        $raw = Get-Content -LiteralPath $path -Raw -Encoding UTF8
        if ([string]::IsNullOrWhiteSpace($raw)) { throw "Dosya bos." }
        $imp = $raw | ConvertFrom-Json -ErrorAction Stop
        if ($null -eq $imp) { throw "Gecersiz JSON icerigi." }

        $validIds = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::OrdinalIgnoreCase)
        foreach ($knownId in @($sync.AllAppIds)) { [void]$validIds.Add([string]$knownId) }
        $validAppIds = @{}
        foreach ($id in @($imp.Apps)) {
            if ([string]::IsNullOrWhiteSpace([string]$id)) { continue }
            $fixedId = Resolve-WingetId ([string]$id).Trim()
            # Sadece gercekten config'de bulunan uygulamalari sec (hayalet secim olusmasin).
            if ($validIds.Contains($fixedId)) { $validAppIds[$fixedId] = $true }
        }
        foreach ($id in $validAppIds.Keys) {
            $script:SelectedApps[$id] = $true
            if ($script:AllAppCheckboxes.ContainsKey($id)) { $script:AllAppCheckboxes[$id].IsChecked = $true }
        }
        foreach ($t in @($imp.Tweaks)) {
            $tKey = Get-OrdinalIgnoreCaseKey $script:TweakCheckboxes ([string]$t)
            if ($tKey) { $script:TweakCheckboxes[$tKey].IsChecked = $true }
        }
        foreach ($f in @($imp.Features)) {
            $fKey = Get-OrdinalIgnoreCaseKey $script:FeatureCheckboxes ([string]$f)
            if ($fKey) { $script:FeatureCheckboxes[$fKey].IsChecked = $true }
        }
        foreach ($b in @($imp.Bloatware)) {
            $bKey = Get-OrdinalIgnoreCaseKey $script:BloatCheckboxes ([string]$b)
            if ($bKey) { $script:BloatCheckboxes[$bKey].IsChecked = $true }
        }
        # Arama filtresi aktifse ice aktarilan secimler gorunmesin; filtreyi temizle.
        if ($script:TxtSearch -and -not [string]::IsNullOrWhiteSpace($script:TxtSearch.Text)) {
            $script:SearchDebounceTimer.Stop()
            $script:TxtSearch.Text = ""
        }
        Render-Apps
        Update-AllSelectionCounts
        Write-UiLog ("[OK] Yapilandirma yuklendi (mevcut secimlere eklendi): " + $path)
        return $true
    } catch {
        Write-UiLog ("[!] Yapilandirma yuklenemedi: " + $_.Exception.Message)
        return $false
    }
}

$script:BtnExportConfig.Add_Click({
    $dlg = New-Object Microsoft.Win32.SaveFileDialog
    $dlg.Filter = "JSON Config (*.json)|*.json"
    $dlg.FileName = "PetraOmniTool_Config.json"
    if ($dlg.ShowDialog() -eq $true) {
        try {
            [void](Export-PetraConfigToPath $dlg.FileName)
            Write-UiLog ("[OK] Yapilandirma kaydedildi: " + $dlg.FileName)
        } catch {
            Write-UiLog ("[!] Yapilandirma kaydedilemedi: " + $_.Exception.Message)
        }
    }
})

$script:BtnImportConfig.Add_Click({
    $dlg = New-Object Microsoft.Win32.OpenFileDialog
    $dlg.Filter = "JSON Config (*.json)|*.json"
    if ($dlg.ShowDialog() -ne $true) { return }
    [void](Import-PetraConfigFile $dlg.FileName)
})

$script:BtnExportSysReport.Add_Click({
    $dlg = New-Object Microsoft.Win32.SaveFileDialog
    $dlg.Filter = "Metin Dosyasi (*.txt)|*.txt"
    $dlg.FileName = "Sistem_Raporu.txt"
    if ($dlg.ShowDialog() -eq $true) {
        $os  = Get-CimInstance Win32_OperatingSystem
        $cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
        $gpu = Get-CimInstance Win32_VideoController | Select-Object -ExpandProperty Name
        $rep = @(
            "=== PETRA OMNITOOL v4.0 SISTEM RAPORU ===",
            "Tarih: $(Get-Date)",
            "Isletim Sistemi: $($os.Caption) ($($os.Version))",
            "Islemci: $($cpu.Name)",
            "Ekran Karti: $($gpu -join ', ')",
            "Toplam RAM: $([math]::Round($os.TotalVisibleMemorySize / 1MB, 2)) GB"
        ) -join "`r`n"
        Set-Content -Path $dlg.FileName -Value $rep -Encoding UTF8
        Write-UiLog ("[OK] Sistem raporu kaydedildi: " + $dlg.FileName)
    }
})

$script:BtnCopyCmd.Add_Click({
    try {
        if ($script:TxtRemoteCmd -and -not [string]::IsNullOrWhiteSpace($script:TxtRemoteCmd.Text)) {
            [System.Windows.Clipboard]::SetText($script:TxtRemoteCmd.Text)
        } else {
            [System.Windows.Clipboard]::SetText("irm evrantool.evranumut.workers.dev | iex")
        }
        Write-UiLog (Decode-U "[OK] Uzaktan calistirma komutu panoya kopyalandi.")
    } catch {
        Write-UiLog ("[!] Pano erisimi basarisiz: " + $_.Exception.Message)
    }
})

$script:BtnClearLog.Add_Click({
    $script:TxtLog.Document.Blocks.Clear()
})

function Save-PetraLogToFile([string]$path) {
    if (-not $script:TxtLog -or [string]::IsNullOrWhiteSpace($path)) { return $false }
    try {
        $range = New-Object System.Windows.Documents.TextRange($script:TxtLog.Document.ContentStart, $script:TxtLog.Document.ContentEnd)
        [System.IO.File]::WriteAllText($path, $range.Text, (New-Object System.Text.UTF8Encoding($true)))
        return $true
    } catch {
        return $false
    }
}

$script:BtnSaveLog.Add_Click({
    $dlg = New-Object Microsoft.Win32.SaveFileDialog
    $dlg.Filter = "Metin Dosyasi (*.txt)|*.txt|Tum Dosyalar (*.*)|*.*"
    $dlg.FileName = "Petra_Log_" + (Get-Date -Format "yyyyMMdd_HHmmss") + ".txt"
    if ($dlg.ShowDialog() -eq $true) {
        if (Save-PetraLogToFile $dlg.FileName) {
            Write-UiLog ("[OK] Konsol kaydedildi: " + $dlg.FileName)
        } else {
            Write-UiLog ("[!] Konsol kaydedilemedi: " + $dlg.FileName)
        }
    }
})

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
