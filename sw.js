const CACHE_NAME = "bryant1410-v1";
const STATIC_ASSETS = [
  "/",
  "/index.html",
  "/404.html",
  "/favicon.svg",
  "/fonts/mulish-latin-400.woff2",
  "/fonts/saira-extra-condensed-latin-700.woff2",
  "/img/profile-160.avif",
  "/img/profile-320.avif",
  "/img/profile.jpg"
];

self.addEventListener("install", (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => cache.addAll(STATIC_ASSETS))
  );
  self.skipWaiting();
});

self.addEventListener("activate", (event) => {
  event.waitUntil(
    caches.keys().then((keys) =>
      Promise.all(
        keys.map((key) => {
          if (key !== CACHE_NAME) {
            return caches.delete(key);
          }
        })
      )
    ).then(() => self.clients.claim())
  );
});

self.addEventListener("fetch", (event) => {
  const url = new URL(event.request.url);

  // Only handle GET requests from the same origin
  if (event.request.method !== "GET" || url.origin !== self.location.origin) {
    return;
  }

  // Cache-first for fonts, images, and icons
  if (url.pathname.startsWith("/fonts/") || url.pathname.startsWith("/img/") || url.pathname === "/favicon.svg") {
    event.respondWith(
      caches.match(event.request).then((cached) => {
        return cached || fetch(event.request).then((response) => {
          if (response && response.status === 200) {
            const clone = response.clone();
            caches.open(CACHE_NAME).then((cache) => cache.put(event.request, clone));
          }
          return response;
        });
      })
    );
    return;
  }

  // Network-first for pages and other assets
  event.respondWith(
    fetch(event.request)
      .then((response) => {
        if (response && response.status === 200) {
          const clone = response.clone();
          caches.open(CACHE_NAME).then((cache) => cache.put(event.request, clone));
        }
        return response;
      })
      .catch(() => caches.match(event.request).then((cached) => cached || caches.match("/404.html")))
  );
});
