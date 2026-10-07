/// Scripts the login WebView runs on Riot's own sign-in page so it reads like
/// part of the app: the app's language, and no cookie banner over the form.
/// Neither touches the credentials form.
library;

/// Riot's sign-in UI (`authenticate.riotgames.com`) picks its language from
/// a `locale` query parameter, which the `/authorize` redirect chain drops,
/// and falls back to `navigator.language` (verified in rso-authenticator-ui
/// 0.127.4). The device language is not the app language, so at document
/// start the page is told the app's language ([tag], e.g. `vi-VN`).
String riotLocaleScript(String tag) {
  final safe = RegExp(r'^[A-Za-z]{2,3}(-[A-Za-z0-9]{2,4})?$').hasMatch(tag)
      ? tag
      : 'en-US';
  return '''
(function () {
  var host = location.hostname;
  if (host !== 'authenticate.riotgames.com' && host !== 'auth.riotgames.com') {
    return;
  }
  try {
    Object.defineProperty(navigator, 'language', { get: function () { return '$safe'; } });
    Object.defineProperty(navigator, 'languages', { get: function () { return ['$safe']; } });
  } catch (e) {}
})();
''';
}

/// Riot's page shows an Osano storage-preferences banner over half of the
/// form on every sign-in (the WebView starts from a clean store each time).
/// The banner itself says closing it continues "with only essential
/// cookies"; the script presses that close button once, which is the most
/// private choice, and never accepts optional cookies.
const consentBannerScript = r'''
(function () {
  if (window.__valhubConsent) return;
  window.__valhubConsent = true;
  var host = location.hostname;
  if (host !== 'authenticate.riotgames.com' && host !== 'auth.riotgames.com') {
    return;
  }
  // The close (X) button first; else "Reject non-essential". Both keep
  // essential cookies only.
  var selectors = [
    '.osano-cm-dialog__close',
    '.osano-cm-dialog .osano-cm-close',
    '.osano-cm-dialog .osano-cm-denyAll',
    '.osano-cm-dialog .osano-cm-button--type_denyAll'
  ];
  function close() {
    for (var i = 0; i < selectors.length; i++) {
      var button = document.querySelector(selectors[i]);
      if (button) {
        button.click();
        return true;
      }
    }
    return false;
  }
  if (close()) return;
  var observer = new MutationObserver(function () {
    if (close()) observer.disconnect();
  });
  observer.observe(document.documentElement, { childList: true, subtree: true });
  setTimeout(function () { observer.disconnect(); }, 30000);
})();
''';
