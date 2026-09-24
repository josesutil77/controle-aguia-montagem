// "Cuidador" que guarda uma cópia dos arquivos do app no aparelho,
// para a tela abrir mesmo sem internet. Os DADOS (funcionários) continuam
// vindo do banco de dados quando há conexão.
const CACHE_NAME = 'controle-equipes-v2';
const ARQUIVOS = ['./', './index.html', './manifest.json'];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => cache.addAll(ARQUIVOS))
  );
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((nomes) =>
      Promise.all(nomes.filter((n) => n !== CACHE_NAME).map((n) => caches.delete(n)))
    )
  );
  self.clients.claim();
});

self.addEventListener('fetch', (event) => {
  const url = new URL(event.request.url);
  // Nunca guarda em cache chamadas ao banco de dados: essas precisam sempre ser atuais.
  if (url.hostname.includes('supabase.co')) return;

  // Para a própria página do app: tenta sempre buscar a versão mais nova na internet
  // primeiro (pra você nunca ficar preso numa versão antiga); só usa a cópia salva
  // se estiver sem conexão.
  if (event.request.mode === 'navigate' || url.pathname.endsWith('.html')) {
    event.respondWith(
      fetch(event.request, { cache: 'no-store' })
        .then((resposta) => {
          caches.open(CACHE_NAME).then((cache) => cache.put(event.request, resposta.clone()));
          return resposta;
        })
        .catch(() => caches.match(event.request))
    );
    return;
  }

  event.respondWith(
    caches.match(event.request).then((resposta) => resposta || fetch(event.request))
  );
});
