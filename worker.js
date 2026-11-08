export default {
  async fetch(request) {
    const githubRawUrl = `https://raw.githubusercontent.com/evranumut/UmutEvranTool/main/UmutEvranTools.ps1?t=${Date.now()}`;
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), 20000);

    const commonHeaders = {
      "content-type": "text/plain; charset=utf-8",
      "cache-control": "no-store, no-cache, must-revalidate, max-age=0",
      "x-content-type-options": "nosniff"
    };

    try {
      const response = await fetch(githubRawUrl, {
        headers: { "User-Agent": "PowerShell-Worker-Proxy" },
        signal: controller.signal
      });

      if (!response.ok) {
        return new Response(
          `Write-Host "[HATA] Guncelleme sunucusundan betik alinamadi (HTTP ${response.status})." -ForegroundColor Red\n` +
          `Write-Host "Lutfen daha sonra tekrar deneyin: irm evrantool.evranumut.workers.dev | iex" -ForegroundColor Yellow\n`,
          { status: 502, headers: commonHeaders }
        );
      }

      const body = await response.text();
      return new Response(body, { status: 200, headers: commonHeaders });
    } catch (error) {
      const reason = error && error.name === "AbortError"
        ? "Istek zaman asimina ugradi."
        : "Sunucuya baglanilamadi.";
      return new Response(
        `Write-Host "[HATA] ${reason}" -ForegroundColor Red\n` +
        `Write-Host "Lutfen internet baglantinizi kontrol edip tekrar deneyin." -ForegroundColor Yellow\n`,
        { status: 504, headers: commonHeaders }
      );
    } finally {
      clearTimeout(timeoutId);
    }
  }
};
