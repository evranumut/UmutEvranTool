# Petra OmniTool

Windows 10/11 için PowerShell + WPF tabanlı, tek dosyaya derlenen sistem yönetim ve kurulum aracı.

## Özellikler

- 280 uygulama için winget/MS Store kurulum, kaldırma ve güncelleme
- 65 tweak, 14 Windows özelliği ve 50 bloatware paketi
- İki tema: **Solar Eclipse** (varsayılan) ve **Deep Ocean**; sağ üstteki simgeden seçilir
- Tema tercihi `%LOCALAPPDATA%\PetraOmniTool\settings.json` içinde saklanır
- Canlı arama (`Ctrl+F` ile odağa alınır), kategori filtreleri ve hazır paketler
- Tweak'leri geri alma (undo), sistem onarımı ve yapılandırma dışa/içe aktarma
- Konsol kayıtlarını metin dosyasına aktarma ("Konsolu Kaydet")
- Tek dosya çıktısı: `UmutEvranTools.ps1` (100% ASCII, uzaktan `irm ... | iex` ile çalıştırılabilir)

## Gereksinimler

- Windows 10 veya Windows 11
- PowerShell 5.1 (Windows PowerShell)
- Yönetici hakları (araç gerekirse kendini yükseltir)
- `winget` / App Installer (uygulama kurulumları için)
- İnternet bağlantısı (uygulama ve ikon indirmeleri için)

## Proje Yapısı

```text
compile.ps1            # Tek dosya derleyici (manifest tabanlı birleştirme)
Deploy.ps1             # Derle + test + GitHub'a gönder
Setup-GitHub.ps1       # Sıfırdan repo kurulumu
worker.js              # Cloudflare Worker (GitHub raw proxy)
wrangler.toml          # Worker yapılandırması
scripts/main.ps1       # Geliştirme yükleyicisi (modülleri dot-source eder)
scripts/modules.psd1   # Modül yükleme sırası
scripts/core/*.ps1     # Çekirdek: tema, bağlama, arka plan, durum/gezinme
scripts/tabs/*.ps1     # Sekme mantığı (uygulamalar, tweak, özellik, bloatware, araçlar, config)
scripts/mas.aio.cmd    # Gömülen AIO komut dosyası
xaml/input.xaml        # Arayüz
assets/logo.ico        # Uygulama / pencere logosu (16–128 px, derlemede gömülür)
config/*.json          # Uygulama, tweak, özellik ve bloatware verileri
UmutEvranTools.ps1     # Üretilen tek dosya çıktı
```

## Güvenlik Notları

- Tweak veya bloatware işlemlerinden önce **Sistem Geri Yükleme Noktası** oluşturun.
- Bazı işlemler (Edge/OneDrive kaldırma, servis kapatma, bloatware silme) tam olarak geri alınamaz.
- Bloatware ve UWP öğeleri varsayılan olarak seçili gelmez; silmeden önce listeyi gözden geçirin.
- Şüpheli/hatalı tweak değişikliklerini geri almak için **Sistem ve Gelişmiş Tweaks** sekmesindeki "Geri Al" akışını kullanın.
- Aracı yalnızca güvendiğiniz bir kaynaktan indirilen güncel sürümle çalıştırın.
- `irm ... | iex` kullanmadan önce betiği indirip içeriğini incelemeniz önerilir.
