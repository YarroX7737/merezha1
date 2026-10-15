/* Офлайн-кеш: сам додаток і бібліотеки. Дані карти зберігаються окремо в пам'яті пристрою. */
var V = 'merezha-v1';
var SHELL = ['./', 'index.html', 'manifest.webmanifest', 'icon-192.png', 'icon-512.png'];
var CDN = ['unpkg.com', 'cdn.jsdelivr.net', 'fonts.googleapis.com', 'fonts.gstatic.com'];
self.addEventListener('install', function (e) {
  e.waitUntil(caches.open(V).then(function (c) { return Promise.all(SHELL.map(function (u) { return c.add(u).catch(function () {}); })); }).then(function () { return self.skipWaiting(); }));
});
self.addEventListener('activate', function (e) {
  e.waitUntil(caches.keys().then(function (ks) { return Promise.all(ks.filter(function (k) { return k !== V; }).map(function (k) { return caches.delete(k); })); }).then(function () { return self.clients.claim(); }));
});
self.addEventListener('fetch', function (e) {
  var r = e.request; if (r.method !== 'GET') return;
  var u = new URL(r.url), same = u.origin === location.origin;
  if (!same && CDN.indexOf(u.hostname) < 0) return;
  if (same && (r.mode === 'navigate' || /\.html$|\/$/.test(u.pathname))) {
    e.respondWith(fetch(r).then(function (res) { var cp = res.clone(); caches.open(V).then(function (c) { c.put(r, cp); }); return res; }).catch(function () { return caches.match(r).then(function (m) { return m || caches.match('index.html') || caches.match('./'); }); }));
    return;
  }
  e.respondWith(caches.match(r).then(function (m) {
    var net = fetch(r).then(function (res) { if (res && (res.ok || res.type === 'opaque')) { var cp = res.clone(); caches.open(V).then(function (c) { c.put(r, cp); }); } return res; }).catch(function () { return m; });
    return m || net;
  }));
});
