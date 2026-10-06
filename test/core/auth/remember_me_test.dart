import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/auth/remember_me.dart';
import 'package:valvn/core/auth/session_manager.dart';

void main() {
  group('shouldTickRememberMe', () {
    test("runs on Riot's own login pages only", () {
      expect(
        shouldTickRememberMe(
          Uri.parse('https://authenticate.riotgames.com/?client_id=x'),
        ),
        isTrue,
      );
      expect(
        shouldTickRememberMe(Uri.parse('https://auth.riotgames.com/authorize')),
        isTrue,
      );
    });

    test('never on social sign-in, other hosts, http or nothing', () {
      for (final url in [
        'https://accounts.google.com/o/oauth2/auth',
        'https://appleid.apple.com/auth/authorize',
        'https://riotgames.com.evil.example/',
        'http://authenticate.riotgames.com/',
        'https://playvalorant.com/opt_in',
      ]) {
        expect(shouldTickRememberMe(Uri.parse(url)), isFalse, reason: url);
      }
      expect(shouldTickRememberMe(null), isFalse);
    });
  });

  test('the script ticks #rememberme once per page and checks the host', () {
    expect(rememberMeScript, contains("getElementById('rememberme')"));
    expect(rememberMeScript, contains('if (!box.checked) box.click();'));
    expect(rememberMeScript, contains('window.__valhubRememberMe'));
    expect(rememberMeScript, contains("'authenticate.riotgames.com'"));
  });

  test('describeSsoLifetime keeps the log token-free and readable', () {
    expect(describeSsoLifetime(Duration.zero), 'session');
    expect(describeSsoLifetime(const Duration(days: 30)), '30d');
    expect(describeSsoLifetime(const Duration(hours: 5)), '5h');
  });
}
