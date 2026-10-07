import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/auth/login_page_scripts.dart';
import 'package:valvn/core/l10n/app_locale.dart';

void main() {
  group('riotLocaleScript', () {
    test('tells Riot the app language of every shipped locale', () {
      for (final locale in AppLocale.values) {
        final script = riotLocaleScript(locale.tag);
        expect(script, contains("return '${locale.tag}'"), reason: locale.tag);
        expect(script, contains("return ['${locale.tag}']"));
      }
    });

    test('only runs on Riot sign-in hosts', () {
      final script = riotLocaleScript('vi-VN');
      expect(script, contains("'authenticate.riotgames.com'"));
      expect(script, contains("'auth.riotgames.com'"));
    });

    test('never injects a malformed tag into the page', () {
      for (final bad in ["vi'); alert(1); ('", '', 'x' * 40, 'vi VN']) {
        final script = riotLocaleScript(bad);
        expect(script, isNot(contains('alert')));
        expect(script, contains("return 'en-US'"), reason: bad);
      }
    });
  });

  group('consentBannerScript', () {
    test('only closes the banner or rejects non-essential cookies', () {
      expect(consentBannerScript, contains('osano-cm-dialog__close'));
      expect(consentBannerScript, contains('denyAll'));
      expect(consentBannerScript, isNot(contains('acceptAll')));
      expect(consentBannerScript, isNot(contains('accept')));
    });

    test('runs once per page and only on Riot hosts', () {
      expect(consentBannerScript, contains('window.__valhubConsent'));
      expect(consentBannerScript, contains("'authenticate.riotgames.com'"));
    });
  });
}
