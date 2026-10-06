/// "Stay signed in" on Riot's login page (riot-auth §1.5).
///
/// Riot only issues the long-lived, sliding SSO cookie (`ssid`, 30 days,
/// renewed by every silent re-auth) when the user ticks `#rememberme`; the box
/// starts unticked (verified on the live page, 2026-10-07). Left unticked, the
/// session dies within about a day of inactivity and every account then shows
/// "Cần đăng nhập lại" (seen on all six QA accounts after the emulator was off
/// for ~30 h, Riot answering `login_required`). A hint alone was not enough,
/// so the login WebView ticks the box once per page; the user still sees it
/// and can untick it, and the script never touches it again on that page.
library;

/// Hosts of Riot's own login pages (never Google / Apple / Facebook).
const _rememberMeHosts = {'authenticate.riotgames.com', 'auth.riotgames.com'};

/// Whether [rememberMeScript] may run on [url].
bool shouldTickRememberMe(Uri? url) =>
    url != null &&
    url.scheme == 'https' &&
    _rememberMeHosts.contains(url.host.toLowerCase());

/// Ticks `#rememberme` once when it appears (the page is a single-page app,
/// so it waits up to 30 s for the form). A second run on the same page is a
/// no-op, which keeps an untick by the user. Returns nothing of value.
const rememberMeScript = r'''
(function () {
  if (window.__valhubRememberMe) return;
  window.__valhubRememberMe = true;
  var host = location.hostname;
  if (host !== 'authenticate.riotgames.com' && host !== 'auth.riotgames.com') {
    return;
  }
  function tick() {
    var box = document.getElementById('rememberme');
    if (!box || box.type !== 'checkbox') return false;
    if (!box.checked) box.click();
    return true;
  }
  if (tick()) return;
  var observer = new MutationObserver(function () {
    if (tick()) observer.disconnect();
  });
  observer.observe(document.documentElement, { childList: true, subtree: true });
  setTimeout(function () { observer.disconnect(); }, 30000);
})();
''';
