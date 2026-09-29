import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/auth/login_screen.dart';

void main() {
  test('re-login returns to the opener; first sign-in goes to the Store', () {
    expect(shouldPopAfterLogin(hadAccounts: true, canPop: true), isTrue);
    expect(shouldPopAfterLogin(hadAccounts: false, canPop: true), isFalse);
    expect(shouldPopAfterLogin(hadAccounts: true, canPop: false), isFalse);
  });
}
