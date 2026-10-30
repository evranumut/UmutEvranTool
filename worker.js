export default {
  async fetch(request) {
    const githubRawUrl = `https://raw.githubusercontent.com/evranumut/UmutEvranTool/main/UmutEvranTools.ps1?t=${Date.now()}`;
    const response = await fetch(githubRawUrl, {
      headers: { "User-Agent": "PowerShell-Worker-Proxy" }
    });
    return new Response(response.body, {
      status: response.status,
      headers: {
        "content-type": "text/plain; charset=utf-8",
        "cache-control": "no-store, no-cache, must-revalidate, max-age=0"
      }
    });
  }
};